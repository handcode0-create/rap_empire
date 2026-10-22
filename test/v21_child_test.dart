import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

J must(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

J kid(J s) => ((s['fam'] as J)['kids'] as List)[0] as J;

void main() {
  J parent() => act21(init21(), 'preset', 'parent').s;

  test('un moment ensemble développe une facette et laisse un souvenir', () {
    var s = parent();
    s = must(s, 'kid', ['0', 'jouer']);
    final k = kid(s);
    expect((k['dev'] as J)['eveil'], 4);
    expect((k['mem'] as List).length, 1);
    expect(((k['mem'] as List)[0] as J)['t'], contains('Jouer ensemble'));
    expect(k['l'], 61);
  });

  test('les souvenirs sont plafonnés', () {
    var s = parent();
    s['hour'] = 8;
    final k = kid(s);
    for (var i = 0; i < Reg21.kidMemMax + 3; i++) {
      (k['mem'] ??= <dynamic>[]);
      s['en'] = 100;
      s['hour'] = 8;
      s = must(s, 'kid', ['0', 'jouer']);
    }
    expect((kid(s)['mem'] as List).length, Reg21.kidMemMax);
    expect((kid(s)['dev'] as J)['eveil'], 40);
  });

  test('garde : nounou pour un bébé, école interdite avant 3 ans, pas deux fois la même', () {
    var s = parent();
    expect(act21(s, 'kgarde', ['0', 'École']).err, 'age');
    expect(act21(s, 'kgarde', ['0', 'Au foyer']).err, 'deja');
    expect(act21(s, 'kgarde', ['0', 'Crèche']).err, 'inconnu');
    expect(kidGardeCost21(kid(s)), 0);
    s = must(s, 'kgarde', ['0', 'Nounou']);
    expect(kid(s)['garde'], 'Nounou');
    expect(kidGardeCost21(kid(s)), 800);
    expect(((kid(s)['mem'] as List)[0] as J)['t'], 'Garde : Nounou');
  });

  test('la garde est facturée chaque jour et supprime la fatigue du bébé', () {
    final a = must(parent(), 'endDay');
    var b = must(parent(), 'kgarde', ['0', 'Nounou']);
    b = must(b, 'endDay');
    expect((a['cash'] as num) - (b['cash'] as num), 800);
    expect((b['en'] as num) - (a['en'] as num), Reg21.babyMorning);
  });

  test('l’école fait progresser le savoir chaque jour', () {
    var s = parent();
    kid(s)['born'] = 400 - 4 * Reg21.daysPerYear;
    s = must(s, 'kgarde', ['0', 'École']);
    s = must(s, 'endDay');
    s = must(s, 'endDay');
    expect((kid(s)['dev'] as J)['savoir'], 2 * Reg21.schoolDaily);
  });
}
