import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

/// Parité A.record : valeurs obtenues en exécutant game.js (v20) avec Node sur les mêmes entrées.
/// Entrée canonique : départ, instru gbaka, texte quartier / sombre (énergie 80, 09:00, 17 000 cauris).
void main() {
  final afterWrite = write(pick(const GameState(), 'gbaka'));

  GameError? errOf(void Function() f) {
    try {
      f();
    } on GameError catch (e) {
      return e;
    }
    return null;
  }

  List<Object?> view(GameState s) => [s.song!.title, s.song!.q, s.song!.texte, s.song!.voix, s.song!.prod];

  group('record : parcours canonique (planche 04.9 : qualité 61, texte 72, voix 55, prod 56, +30 XP)', () {
    final s = record(afterWrite, [74, 48, 43]);
    test('son : Gbaka de 6h, 61, 72, 55, 56', () => expect(view(s), ['Gbaka de 6h', 61, 72, 55, 56]));
    test('énergie 55, 11:00, XP 30, cauris inchangés', () => expect([s.energy, s.hour, s.day, s.xp, s.cash], [55, 11, 1, 30, 17000]));
    test('prises conservées, voix +1, écriture inchangée', () => expect([s.takes, s.sk['voix'], s.sk['ecr']], [[74, 48, 43], 11, 16]));
    test('mission 1 terminée, les autres non', () => expect(s.ms, {'m1': 'done', 'm2': 'todo', 'm3': 'todo', 'm4': 'todo'}));
    test('instru du son : Gbaka de 6h, pas encore sorti', () => expect([s.song!.inst, s.song!.released], ['Gbaka de 6h', false]));
    test('pas de niveau en attente (30 XP)', () => expect(s.pend, isNull));
    test('prises par défaut = [74, 48, 43]', () {
      expect(record(afterWrite).song, s.song);
      expect(record(afterWrite, const []).song, s.song);
    });
  });

  group('record : prises et instrus', () {
    test('prises [90, 80, 70] : voix 80, qualité 69', () => expect(view(record(afterWrite, [90, 80, 70])), ['Gbaka de 6h', 69, 72, 80, 56]));
    test('nuit : titre « Nuit à Ndo », prod 32, qualité 53, cauris 25 000', () {
      final s = record(write(pick(const GameState(), 'nuit')), [74, 48, 43]);
      expect(view(s), ['Nuit à Ndo', 53, 72, 55, 32]);
      expect([s.cash, s.song!.inst], [25000, 'Nuit à Ndo']);
    });
    test('pont (niveau 2) : prod 68, qualité 66, titre « Gbaka de 6h » (titre fixe du prototype)', () {
      final s = record(write(pick(const GameState(xp: 100), 'pont')), [74, 48, 43]);
      expect(view(s), ['Gbaka de 6h', 66, 72, 55, 68]);
      expect([s.cash, s.xp, s.pend], [10000, 130, null]);
    });
  });

  group('record : sans texte ou sans instru (valeurs par défaut du prototype)', () {
    test('sans texte : note 60, énergie 75, 10:00, qualité 57, écriture inchangée (14)', () {
      final s = record(pick(const GameState(), 'gbaka'), [74, 48, 43]);
      expect(view(s), ['Gbaka de 6h', 57, 60, 55, 56]);
      expect([s.energy, s.hour, s.sk['ecr']], [75, 10, 14]);
    });
    test('sans instru ni texte : prod 32, qualité 49', () {
      final s = record(const GameState(), [74, 48, 43]);
      expect(view(s), ['Gbaka de 6h', 49, 60, 55, 32]);
      expect([s.energy, s.song!.inst], [75, '']);
    });
  });

  group('record : énergie et malus de forme (calculé sur l\'énergie à l\'entrée en cabine)', () {
    test('énergie 24 : erreur energie, état inchangé', () {
      const s = GameState(energy: 24);
      expect(errOf(() => record(s))!.code, 'energie');
      expect(s.song, isNull);
    });
    test('énergie 25 (après écriture sans instru) : permis, énergie 0, 11:00, qualité 45', () {
      final s = record(write(const GameState(energy: 45)), [74, 48, 43]);
      expect(view(s), ['Gbaka de 6h', 45, 72, 55, 32]);
      expect([s.energy, s.hour], [0, 11]);
    });
    const withText = Texte(72, 'quartier', 'sombre');
    test('énergie 30 : malus 5, qualité 56, énergie 5', () {
      final s = record(const GameState(energy: 30, inst: 'gbaka', texte: withText), [74, 48, 43]);
      expect([s.song!.q, s.energy, s.hour], [56, 5, 10]);
    });
    test('énergie 25 : malus 7,5, qualité 54, énergie 0', () {
      final s = record(const GameState(energy: 25, inst: 'gbaka', texte: withText), [74, 48, 43]);
      expect([s.song!.q, s.energy], [54, 0]);
    });
    test('énergie 40 et plus : aucun malus (qualité 61)', () {
      expect(record(const GameState(energy: 40, inst: 'gbaka', texte: withText), [74, 48, 43]).song!.q, 61);
    });
  });

  group('record : micro studio, XP, minuit', () {
    const withText = Texte(72, 'quartier', 'sombre');
    test('micro studio : voix +8 (63), qualité 64', () {
      final s = record(const GameState(micro: true, inst: 'gbaka', texte: withText), [74, 48, 43]);
      expect([s.song!.voix, s.song!.q], [63, 64]);
    });
    test('80 XP + 30 : niveau 2, récompense 2 000 en attente', () {
      final s = record(const GameState(xp: 80, inst: 'gbaka', texte: withText), [74, 48, 43]);
      expect([s.xp, s.level, s.pend], [110, 2, const Pending(2, 2000)]);
    });
    test('23:00 : J2 01:00', () {
      final s = record(const GameState(hour: 23, inst: 'gbaka', texte: withText), [74, 48, 43]);
      expect([s.day, s.hour, s.energy], [2, 1, 75]);
    });
    test('mission 1 déjà récupérée : le statut ne revient pas à « terminée »', () {
      final s = record(const GameState(ms: {'m1': 'claimed', 'm2': 'todo', 'm3': 'todo', 'm4': 'todo'}, inst: 'gbaka', texte: withText));
      expect(s.ms['m1'], 'claimed');
    });
  });

  group('pick efface les prises et le son non sorti (A.pick)', () {
    test('nouvelle instru après un enregistrement', () {
      final s = pick(record(afterWrite), 'nuit');
      expect([s.inst, s.song, s.takes, s.texte], ['nuit', null, <int>[], null]);
    });
  });

  group('addXp (A.addXp)', () {
    test('sous le seuil : pas de niveau en attente', () => expect(addXp(const GameState(xp: 50), 49).pend, isNull));
    test('N2 à 100 XP : 2 000 cauris', () => expect(addXp(const GameState(xp: 50), 50).pend, const Pending(2, 2000)));
    test('N3 à 250 XP : 4 000 cauris', () => expect(addXp(const GameState(xp: 200), 50).pend, const Pending(3, 4000)));
    test('N5 à 900 XP : 15 000 cauris', () => expect(addXp(const GameState(xp: 800), 100).pend, const Pending(5, 15000)));
    test('un niveau déjà atteint ne crée pas de pend', () => expect(addXp(const GameState(xp: 120), 10).pend, isNull));
  });

  group('studioStep (restauration de l\'écran)', () {
    test('sans instru : instru', () => expect(studioStep(const GameState()), StudioStep.instru));
    test('instru choisie : écriture', () => expect(studioStep(pick(const GameState(), 'gbaka')), StudioStep.ecriture));
    test('texte écrit : cabine', () => expect(studioStep(afterWrite), StudioStep.cabine));
    test('son enregistré non sorti : sortie', () => expect(studioStep(record(afterWrite)), StudioStep.sortie));
    test('son déjà sorti, texte conservé : cabine', () {
      final s = record(afterWrite);
      expect(studioStep(s.copyWith(song: s.song!.copyWith(released: true))), StudioStep.cabine);
    });
  });

  group('sauvegarde : instru, texte, prises, son, missions, niveau en attente', () {
    test('aller-retour JSON complet', () {
      final s = record(const GameState(xp: 80, rep: 12).copyWith(inst: 'gbaka', texte: const Texte(75, 'galere', 'fiere')), [90, 80, 70]);
      final r = GameState.fromJson(s.toJson());
      expect(r.inst, 'gbaka');
      expect(r.texte, const Texte(75, 'galere', 'fiere'));
      expect(r.takes, [90, 80, 70]);
      expect(r.song, s.song);
      expect(r.ms, s.ms);
      expect(r.pend, const Pending(2, 2000));
      expect([r.xp, r.energy, r.hour, r.sk['voix'], r.micro, r.style], [110, 75, 10, 11, false, 'drill']);
    });
    test('aller-retour via encode/decode texte', () {
      final s = record(afterWrite);
      expect(GameState.fromJson(Map<String, dynamic>.from(jsonDecode(s.encode()) as Map)).song, s.song);
    });
    test('ancienne sauvegarde sans les nouveaux champs : valeurs par défaut', () {
      final s = GameState.fromJson({'v': 1, 'cash': 5});
      expect([s.song, s.takes, s.pend, s.micro, s.style], [null, <int>[], null, false, 'drill']);
      expect(s.ms, defaultMissions);
    });
    test('copyWith(song: null) efface, sans argument conserve', () {
      final s = record(afterWrite);
      expect(s.copyWith(cash: 1).song, isNotNull);
      expect(s.copyWith(song: null).song, isNull);
    });
  });
}
