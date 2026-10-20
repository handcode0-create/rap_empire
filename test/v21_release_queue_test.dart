import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

J must(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

List l(dynamic x) => x as List;
J m(dynamic x) => x as J;

/// Écrit et enregistre un titre, avec assez d'énergie et d'heures pour la prise.
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
    s = recorded(s);
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
    s['stock'] = [
      for (var i = 0; i < Reg21.stockMax; i++)
        {'id': 'X$i', 'title': 'x', 'st': 'enregistre', 'Q': 50}
    ];
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
    s = must(s, 'prel');
    expect(l(s['stock']), isEmpty);
    expect(l(s['disco']), isEmpty, reason: 'aucun single créé');
    final p = m(l(s['projects'])[0]);
    expect(l(p['tracks']).length, 3);
    expect(l(p['inedits']).length, 3);
    expect(p['sales'], greaterThan(0));
    final next = m(recorded(s)['cur'])['id'];
    expect(ids.contains(next), isFalse);
    expect(act21(s, 'ptk', 'T999').err, 'inconnu');
  });

  test('un projet mélange les singles déjà sortis et les inédits sélectionnés manuellement', () {
    var s = init21()..['fans'] = 5000..['cash'] = 100000;
    s = recorded(s);
    final unreleasedId = m(s['cur'])['id'] as String;
    s = must(s, 'shelve');
    s = recorded(s);
    final secondUnreleasedId = m(s['cur'])['id'] as String;
    s = must(s, 'shelve');
    s = recorded(s);
    s = must(s, 'release');
    final releasedId = m(l(s['disco']).first)['id'] as String;
    s = must(s, 'ptype', 'EP');
    for (final id in [releasedId, unreleasedId, secondUnreleasedId]) {
      s = must(s, 'ptk', id);
    }
    s = must(s, 'ppromo', 1);
    s = must(s, 'prel');
    expect(l(s['projects']).length, 1);
    final p = m(l(s['projects']).first);
    expect(p['tracks'], [releasedId, unreleasedId, secondUnreleasedId]);
    expect(l(p['inedits']).length, 2);
    expect(l(s['disco']).length, 1, reason: 'les inédits ne deviennent pas des singles');
    expect(l(s['stock']), isEmpty);
    expect(p['promoName'], 'Réseaux sociaux');
  });

  test('un EP programmé sort au jour demandé et conserve la campagne choisie', () {
    var s = init21()..['fans'] = 5000..['cash'] = 100000;
    for (var i = 0; i < 3; i++) {
      s = recorded(s);
      s = must(s, 'shelve');
    }
    s = must(s, 'ptype', 'EP');
    for (final song in l(s['stock'])) {
      s = must(s, 'ptk', m(song)['id']);
    }
    s = must(s, 'ppromo', 1);
    final day = s['day'] as num;
    s = must(s, 'pschedule', 2);
    expect(l(s['pendingProjects']).length, 1);
    expect(l(s['stock']), isEmpty, reason: 'les pistes réservées ne doivent pas être réutilisées');
    expect(l(s['projects']), isEmpty, reason: 'le projet ne sort pas avant sa date');
    s = must(s, 'endDay');
    expect(l(s['projects']), isEmpty);
    s = must(s, 'endDay');
    expect(l(s['pendingProjects']), isEmpty);
    expect(l(s['projects']).length, 1);
    final project = m(l(s['projects']).first);
    expect([project['day'], project['promoName'], l(project['inedits']).length],
        [day + 2, 'Réseaux sociaux', 3]);
  });

  test('programmation EP : date invalide et fonds insuffisants ne débitent rien', () {
    var s = init21()..['fans'] = 5000..['cash'] = 16000;
    for (var i = 0; i < 3; i++) {
      s = recorded(s);
      s = must(s, 'shelve');
    }
    s = must(s, 'ptype', 'EP');
    for (final song in l(s['stock'])) {
      s = must(s, 'ptk', m(song)['id']);
    }
    s = must(s, 'ppromo', 1);
    final before = s['cash'];
    expect(act21(s, 'pschedule', 0).err, 'inconnu');
    expect(act21(s, 'pschedule', 1).err, 'cash');
    expect(s['cash'], before);
  });
}
