import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/econ.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/missions.dart';
import 'package:rap_empire/domain/scene.dart';
import 'package:rap_empire/domain/studio_models.dart';

/// Valeurs de référence : game.js v20 (A.openmic, A.battle, A.concert) et planches 06.1 à 06.5.
void main() {
  group('open mic (A.openmic)', () {
    test('énergie 100 : réussi, +150 fans, +6 rép., cachet 3 000, 1 h, −15 énergie, +60 XP', () {
      final (s, r) = openMic(const GameState());
      expect(r.win, isTrue);
      expect((s.fans, s.rep, s.cash, s.energy, s.hour, s.xp), (270, 14, 28000, 85, 9, 60));
      expect(s.ms['m5'], 'done');
    });
    test('énergie 39 : raté, +12 fans, pas de cachet, +10 XP, mission non terminée', () {
      final (s, r) = openMic(const GameState(energy: 39));
      expect(r.win, isFalse);
      expect((s.fans, s.cash, s.xp, s.energy), (132, 25000, 10, 24));
      expect(s.ms['m5'], 'todo');
    });
    test('énergie 40 : le seuil est inclus', () => expect(openMic(const GameState(energy: 40)).$2.win, isTrue));
    test('énergie 14 : refusé', () => expect(() => openMic(const GameState(energy: 14)), throwsA(isA<GameError>())));
  });

  group('battle (A.battle)', () {
    test('2 punchlines sur 3 : gagnée, prime 3 000, +150 fans', () {
      final (s, r) = battle(const GameState(), 2);
      expect(r.win, isTrue);
      expect((s.fans, s.cash, s.rep), (270, 28000, 14));
      expect(s.ms['m6'], 'done');
    });
    test('1 punchline sur 3 : perdue, +12 fans, pas de prime', () {
      final (s, r) = battle(const GameState(), 1);
      expect(r.win, isFalse);
      expect((s.fans, s.cash), (132, 25000));
      expect(s.ms['m6'], 'todo');
    });
  });

  group('concert (A.concert)', () {
    const n3 = GameState(xp: 250);
    test('niveau 2 : verrouillé', () => expect(() => concert(const GameState(xp: 100)), throwsA(isA<GameError>())));
    test('Hype, Rap, Rap : salle 92 %, note A, cachet 25 000, +520 fans, 23 h', () {
      final (s, r) = concert(n3, ['h', 'r', 'r']);
      expect((r.grade, r.cash, r.fans, s.hour, s.energy), ('A', 25000, 520, 23, 65));
      expect(s.ms['m7'], 'done');
    });
    test('Hype ×3 : salle 74 %, note B', () => expect(concert(n3, ['h', 'h', 'h']).$2.grade, 'B'));
    test('la note C reste une participation : cachet réduit, mission terminée', () {
      expect(concertCrowd(['h', 'h', 'h']), 74);
      final (s, r) = concert(n3, ['h', 'h']);
      expect((r.grade, r.cash), ('C', 12500));
      expect(s.ms['m7'], 'done');
    });
  });

  group('missions mesurables', () {
    test('Sors 3 sons', () {
      const d = DiscoEntry(title: 'a', q: 50, listens: 100, day: 2);
      expect(refreshMissions(const GameState(disco: [d, d])).ms['m8'], 'todo');
      expect(refreshMissions(const GameState(disco: [d, d, d])).ms['m8'], 'done');
    });
    test('5 000 fans et 20 000 écoutes', () {
      expect(refreshMissions(const GameState(fans: 5000)).ms['m9'], 'done');
      expect(refreshMissions(const GameState(lc: 20000)).ms['m10'], 'done');
      expect(refreshMissions(const GameState(fans: 4999)).ms['m9'], 'todo');
    });
    test('chaque mission a un titre et une récompense', () {
      for (final id in missionTitles.keys) {
        expect(missionRewards[id], isNotNull, reason: id);
        expect(defaultMissions[id], 'todo', reason: id);
      }
    });
    test('une récompense récupérée ne redevient pas terminée', () {
      expect(refreshMissions(const GameState(fans: 5000, ms: {'m9': 'claimed'})).ms['m9'], 'claimed');
    });
  });

  test('freestyle : Flow +2, −15 énergie, 1 h', () {
    final s = freestyle(const GameState());
    expect((s.sk['flow'], s.energy, s.hour, s.cash), (19, 85, 9, 25000));
    expect(Econ.openMicFee, 3000);
  });
}
