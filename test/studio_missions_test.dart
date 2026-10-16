import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/econ.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/missions.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

/// Parité A.claim et A.ack : valeurs obtenues en exécutant game.js (v20) avec Node sur les mêmes entrées.
/// Le parcours canonique (RE.canon) enchaîne : départ, instru, texte, cabine, mission 1, sortie, niveau 2, mission 2.
void main() {
  final rec = record(write(pick(const GameState(), 'gbaka')));

  GameError? errOf(void Function() f) {
    try {
      f();
    } on GameError catch (e) {
      return e;
    }
    return null;
  }

  String status(GameState s) => s.ms.values.take(4).map((v) => v[0]).join(); // t = todo, d = done, c = claimed

  group('récompenses (MISSIONS de game.js, planche 10.1)', () {
    test('m1 : 5 000 cauris, 50 XP', () => expect([missionRewards['m1']!.cash, missionRewards['m1']!.xp], [5000, 50]));
    test('m2 : 10 000 cauris, 80 XP', () => expect([missionRewards['m2']!.cash, missionRewards['m2']!.xp], [10000, 80]));
    test('m3 : 4 000 cauris, 60 XP', () => expect([missionRewards['m3']!.cash, missionRewards['m3']!.xp], [4000, 60]));
    test('m4 : 15 000 cauris, 120 XP', () => expect([missionRewards['m4']!.cash, missionRewards['m4']!.xp], [15000, 120]));
    test('niveaux : N2 2 000, N3 4 000, N4 8 000, N5 15 000 cauris', () => expect(Econ.levelReward, {2: 2000, 3: 4000, 4: 8000, 5: 15000}));
  });

  group('claim', () {
    test('mission 1 terminée : +5 000 cauris, +50 XP, statut récupérée', () {
      final s = claim(rec, 'm1');
      expect([s.cash, s.xp, s.level, s.pend, status(s)], [22000, 80, 1, null, 'cttt']);
      expect([s.energy, s.hour, s.fans], [55, 11, 120]);
    });
    test('mission 1 pas terminée : erreur rien, état inchangé', () {
      const s = GameState();
      expect(errOf(() => claim(s, 'm1'))!.code, 'rien');
      expect([s.cash, s.xp], [25000, 0]);
    });
    test('mission 1 déjà récupérée : erreur rien', () => expect(errOf(() => claim(claim(rec, 'm1'), 'm1'))!.code, 'rien'));
    test('mission inconnue : erreur rien', () => expect(errOf(() => claim(rec, 'm9'))!.code, 'rien'));
    test('60 XP + 50 : niveau 2, 2 000 cauris en attente', () {
      final s = claim(record(write(pick(const GameState(xp: 0), 'gbaka'))).copyWith(xp: 60), 'm1');
      expect([s.cash, s.xp, s.level, s.pend], [22000, 110, 2, const Pending(2, 2000)]);
    });
    test('une mission d\'un autre statut n\'est pas touchée', () {
      final s = claim(rec, 'm1');
      expect([s.ms['m2'], s.ms['m3'], s.ms['m4']], ['todo', 'todo', 'todo']);
    });
  });

  group('ack (niveau gagné)', () {
    final afterRelease = release(claim(rec, 'm1'), 0);
    test('avec N2 en attente : +2 000 cauris, pend effacé', () {
      expect(afterRelease.pend, const Pending(2, 2000));
      final s = ack(afterRelease);
      expect([s.cash, s.pend, s.level, status(s)], [24054, null, 2, 'cdtt']);
    });
    test('sans niveau en attente : aucun effet', () {
      const s = GameState();
      expect(ack(s), same(s));
    });
    test('récompense à 0 : pend effacé, cauris inchangés', () {
      final s = ack(const GameState(xp: 100, pend: Pending(9, 0)));
      expect([s.cash, s.pend], [25000, null]);
    });
    test('deux ack de suite : la récompense n\'est versée qu\'une fois', () {
      expect(ack(ack(afterRelease)).cash, 24054);
    });
  });

  group('parcours canonique de game.js (RE.canon), étape par étape', () {
    const start = GameState();
    final picked = pick(start, 'gbaka');
    final written = write(picked, theme: 'quartier', amb: 'sombre');
    final recorded = record(written, [74, 48, 43]);
    final m1 = claim(recorded, 'm1');
    final released = release(m1, 0);
    final lvl2 = ack(released);
    final m2 = claim(lvl2, 'm2');

    test('start', () => expect([start.cash, start.energy, start.day, start.hour, start.fans, start.pop, start.xp, status(start)], [25000, 100, 1, 8, 120, 3, 0, 'tttt']));
    test('pick', () => expect([picked.cash, picked.energy, picked.hour], [17000, 100, 8]));
    test('write', () => expect([written.energy, written.hour, written.xp], [80, 9, 0]));
    test('rec', () => expect([recorded.energy, recorded.hour, recorded.xp, status(recorded)], [55, 11, 30, 'dttt']));
    test('m1', () => expect([m1.cash, m1.xp, status(m1)], [22000, 80, 'cttt']));
    test('release', () {
      expect([released.cash, released.energy, released.day, released.hour, released.fans, released.pop, released.xp, released.level], [22054, 100, 2, 8, 491, 9, 120, 2]);
      expect(released.rel, const Release(title: 'Gbaka de 6h', listens: 5418, revenue: 54, fans: 371, pop: 6, promo: 0, q: 61));
      expect([status(released), released.pend, released.lw, released.lc, released.fgain], ['cdtt', const Pending(2, 2000), 8127, 5418, 371]);
    });
    test('lvl2', () => expect([lvl2.cash, lvl2.pend, status(lvl2)], [24054, null, 'cdtt']));
    test('m2', () => expect([m2.cash, m2.xp, m2.level, status(m2), m2.pend], [34054, 200, 2, 'cctt', null]));
  });

  group('objectif en cours du QG', () {
    test('départ : mission 1', () => expect(currentObjective(const GameState())!.id, 'm1'));
    test('mission 1 terminée mais pas récupérée : toujours la mission 1', () => expect(currentObjective(rec)!.id, 'm1'));
    test('mission 1 récupérée : mission 2', () => expect(currentObjective(claim(rec, 'm1'))!.id, 'm2'));
    test('missions 1 et 2 récupérées : aucun objectif', () {
      final s = claim(release(claim(rec, 'm1'), 0), 'm2');
      expect(currentObjective(s), isNull);
    });
    test('textes du prototype (MISSIONS et planche 03.1)', () {
      expect(mission1.title, 'Enregistre ton premier son');
      expect(mission2.title, 'Sors ton premier single');
      expect(mission2.hint, 'Ton son est prêt : choisis la promo et mets-le en ligne.');
    });
  });

  group('sauvegarde : missions et niveau en attente', () {
    test('aller-retour JSON', () {
      final s = release(claim(rec, 'm1'), 0);
      final r = GameState.fromJson(s.toJson());
      expect(r.ms, s.ms);
      expect(r.pend, s.pend);
      expect([r.cash, r.xp, r.level], [22054, 120, 2]);
      expect(status(ack(r)), 'cdtt');
    });
  });
}
