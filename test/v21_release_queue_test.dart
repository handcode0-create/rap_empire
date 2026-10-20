import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Réserve de titres enregistrés et sorties programmées (date de jeu), EP / album avec titres non sortis.
J must(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

List l(dynamic x) => x as List;
J m(dynamic x) => x as J;

/// Écrit et enregistre un titre (énergie et heures remises à plein pour enchaîner les prises).
J recorded(J s) {
  s = clone21(s)
    ..['en'] = 100
    ..['hour'] = 8;
  s = must(s, 'create', ['ambition', 'fiere']);
  return must(s, 'record');
}

void main() {
  test('un titre enregistré part en réserve et libère le studio', () {
    var s = recorded(init21());
    s = must(s, 'shelve');
    expect(s['cur'], isNull);
    expect(l(s['stock']).length, 1);
    expect(l(s['disco']), isEmpty);
    s = recorded(s); // on peut enchaîner un deuxième titre
    expect(m(s['cur'])['id'], isNot(m(l(s['stock'])[0])['id']));
  });

  test('sortie programmée : le titre sort quand le jour du jeu arrive', () {
    var s = recorded(init21());
    final day = s['day'] as num;
    s = must(s, 'schedule', 3);
    expect(m(l(s['stock'])[0])['relDay'], day + 3);
    expect(s['cur'], isNull);
    expect(act21(s, 'schedule', 0).err, 'inconnu');
    expect(act21(s, 'schedule', Reg21.relMaxDays + 1).err, 'inconnu');
    for (var i = 0; i < 2; i++) {
      s = must(s, 'endDay');
      expect(l(s['disco']), isEmpty, reason: 'jour ${s['day']}');
    }
    s = must(s, 'endDay');
    expect(l(s['stock']), isEmpty);
    expect(l(s['disco']).length, 1);
    expect(m(l(s['disco'])[0])['st'], 'sorti');
    expect(m(l(s['disco'])[0])['day'], s['day']);
    expect(l(m(s['bil'])['ev']).any((e) => '$e'.contains('Sortie programmée')), isTrue);
  });

  test('annuler la date remet le titre en réserve, sortie immédiate depuis la réserve', () {
    var s = recorded(init21());
    s = must(s, 'schedule', 5);
    final id = m(l(s['stock'])[0])['id'];
    s = must(s, 'unschedule', id);
    expect(m(l(s['stock'])[0])['relDay'], isNull);
    expect(act21(s, 'unschedule', id).err, 'inconnu');
    s = must(s, 'rnow', id);
    expect(l(s['stock']), isEmpty);
    expect(l(s['disco']).length, 1);
    expect(act21(s, 'rnow', id).err, 'inconnu');
  });

  test('réserve limitée', () {
    var s = init21();
    s['stock'] = [for (var i = 0; i < Reg21.stockMax; i++) {'id': 'X$i', 'title': 'x', 'st': 'enregistre', 'Q': 50}];
    s = recorded(s);
    expect(act21(s, 'shelve').err, 'reserve');
  });

  test('un EP prend des titres non sortis, qui ne sortent pas en single', () {
    var s = init21()..['fans'] = 5000;
    for (var i = 0; i < 3; i++) {
      s = must(recorded(s), 'shelve');
    }
    final ids = [for (final x in l(s['stock'])) m(x)['id'] as String];
    expect(ids.toSet().length, 3, reason: 'identifiants uniques');
    s['cash'] = 100000;
    s = must(s, 'ptype', 'EP');
    for (final id in ids) {
      s = must(s, 'ptk', id);
    }
    s['en'] = 100;
    s['hour'] = 8;
    s = must(s, 'prel');
    expect(l(s['stock']), isEmpty);
    expect(l(s['disco']), isEmpty, reason: 'aucun single créé');
    final p = m(l(s['projects'])[0]);
    expect(l(p['tracks']).length, 3);
    expect(l(p['inedits']).length, 3);
    expect(p['sales'], greaterThan(0));
    // un nouveau titre ne reprend pas un numéro déjà donné
    final next = m(recorded(s)['cur'])['id'];
    expect(ids.contains(next), isFalse);
    expect(act21(s, 'ptk', 'T999').err, 'inconnu');
  });
}
