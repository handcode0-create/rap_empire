import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/clock.dart';
import 'package:rap_empire/domain/econ.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/catalog.dart';
import 'package:rap_empire/domain/missions.dart';
import 'package:rap_empire/domain/studio_models.dart';

/// Valeurs de référence : moteur de démo v20 (game.js : tick, A.sleep, lowEn) et planches 03.1, 03.2, 03.6.
/// engine.js n'est pas dans l'archive v20 ; game.js en est la source.
void main() {
  _catalogTests();
  group('tick (parité game.js)', () {
    test('1 h : 08:00 -> 09:00, même jour (A.write)', () {
      final s = tick(const GameState(), 1);
      expect([s.day, s.hour], [1, 9]);
    });
    test('passage de minuit : J1 23:00 + 2 h = J2 01:00', () {
      final s = tick(const GameState(day: 1, hour: 23), 2);
      expect([s.day, s.hour], [2, 1]);
    });
    test('24 h pile : J1 08:00 + 24 h = J2 08:00', () {
      final s = tick(const GameState(), 24);
      expect([s.day, s.hour], [2, 8]);
    });
    test('plusieurs jours : J1 08:00 + 48 h = J3 08:00', () {
      final s = tick(const GameState(), 48);
      expect([s.day, s.hour], [3, 8]);
    });
    test('ne touche à rien d\'autre', () {
      const a = GameState(cash: 6000, energy: 55, fans: 9);
      final b = tick(a, 3);
      expect([b.cash, b.energy, b.fans], [6000, 55, 9]);
    });
  });

  group('sleep (parité game.js A.sleep, planches 03.2 -> 03.6)', () {
    // 03.2 : J1 14:00, énergie 12, 6 000 cauris. 03.6 : J2 08:00, énergie 100, 6 000 cauris.
    const tired = GameState(cash: 6000, energy: 12, day: 1, hour: 14);
    test('énergie 100, jour suivant, 08:00', () {
      final s = sleep(tired);
      expect([s.energy, s.day, s.hour], [100, 2, 8]);
    });
    test('nuit gratuite en démo : cauris inchangés (Econ.nightCost = 0)', () {
      expect(Econ.nightCost, 0);
      expect(sleep(tired).cash, 6000);
    });
    test('conserve le reste de l\'état (fans, popularité, réputation, xp, quartier, version)', () {
      const a = GameState(version: 1, cash: 6000, energy: 12, fans: 77, pop: 4, rep: 9, xp: 120, hood: 'Ndolo');
      final b = sleep(a);
      expect([b.version, b.fans, b.pop, b.rep, b.xp, b.hood], [1, 77, 4, 9, 120, 'Ndolo']);
    });
    test('dormir à 23:00 passe aussi au jour suivant 08:00', () {
      final s = sleep(const GameState(day: 4, hour: 23, energy: 5));
      expect([s.day, s.hour, s.energy], [5, 8, 100]);
    });
    test('dormir sans fatigue reste permis (prototype : aucun garde-fou)', () {
      final s = sleep(const GameState());
      expect([s.day, s.hour, s.energy], [2, 8, 100]);
    });
  });

  group('trop fatigué (lowEn : énergie < 20)', () {
    test('19 : fatigué', () => expect(isTooTired(const GameState(energy: 19)), isTrue));
    test('20 : pas fatigué', () => expect(isTooTired(const GameState(energy: 20)), isFalse));
    test('12 (planche 03.2) : fatigué', () => expect(isTooTired(const GameState(energy: 12)), isTrue));
    test('100 (départ) : pas fatigué', () => expect(isTooTired(const GameState()), isFalse));
  });

  group('formatClock (champ time du prototype)', () {
    test('J1 08:00 (planche 03.1)', () => expect(formatClock(const GameState()), 'J1 08:00'));
    test('J1 14:00 (planche 03.2)', () => expect(formatClock(const GameState(hour: 14)), 'J1 14:00'));
    test('J2 08:00 (planche 03.6)', () => expect(formatClock(const GameState(day: 2)), 'J2 08:00'));
    test('heure à zéro : J3 00:00', () => expect(formatClock(const GameState(day: 3, hour: 0)), 'J3 00:00'));
  });

  group('SleepReport (03.6 Fin de journée)', () {
    test('bilan entre avant et après la nuit', () {
      const before = GameState(cash: 6000, energy: 12, day: 1, hour: 14);
      final r = SleepReport.between(before, sleep(before));
      expect([r.energyBefore, r.energyAfter, r.energyGained, r.cost, r.newDay], [12, 100, 88, 0, 2]);
      expect(r.newClock, 'J2 08:00'); // planche 03.6
    });
  });

  group('mission 1 (MISSIONS.m1 et planche 03.1)', () {
    test('textes du prototype', () {
      expect(mission1.id, 'm1');
      expect(mission1.title, 'Enregistre ton premier son');
      expect(mission1.hint, 'Choisis une instru, écris, passe en cabine.');
    });
  });
}

void _catalogTests() {
  group('catalogue : écoutes passives chaque nuit', () {
    const song = DiscoEntry(title: 'Gbaka de 6h', q: 61, listens: 5418, day: 2);
    test('le lendemain de la sortie, le son rapporte écoutes, cauris et fans', () {
      final s = sleep(const GameState(day: 2, disco: [song]));
      expect(s.cash, greaterThan(25000));
      expect(s.fans, greaterThan(120));
      expect(s.lc, greaterThan(0));
    });
    test('les écoutes baissent d\'un jour à l\'autre', () {
      expect(catalogListens(song, 2), lessThan(catalogListens(song, 1)));
    });
    test('le son passe de mode après le délai', () {
      expect(catalogListens(song, Econ.catalogDays), greaterThan(0));
      expect(catalogListens(song, Econ.catalogDays + 1), 0);
    });
    test('sans son sorti, rien ne change', () {
      final s = sleep(const GameState());
      expect((s.cash, s.fans), (25000, 120));
    });
  });
}
