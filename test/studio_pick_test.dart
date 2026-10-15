import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/econ.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';

/// Parité A.pick : valeurs obtenues en exécutant game.js (v20) avec Node sur les mêmes entrées.
/// Entrées : état de départ (25 000 cauris, N1, réputation 8) sauf mention contraire.
void main() {
  GameError? errOf(void Function() f) {
    try {
      f();
    } on GameError catch (e) {
      return e;
    }
    return null;
  }

  group('table des instrus (INSTRU de game.js, planche 04.3)', () {
    test('quatre instrus, prix, qualité, verrous', () {
      expect(instrus.map((i) => [i.id, i.q, i.price, i.lvl, i.rep]).toList(), [
        ['nuit', 32, 0, 1, 0],
        ['gbaka', 56, 8000, 1, 0],
        ['pont', 68, 15000, 2, 0],
        ['lagune', 86, 40000, 1, 30],
      ]);
    });
  });

  group('pick', () {
    test('gbaka au départ : 17 000 cauris, instru gbaka', () {
      final s = pick(const GameState(), 'gbaka');
      expect([s.cash, s.inst, s.energy, s.day, s.hour], [17000, 'gbaka', 100, 1, 8]);
    });
    test('nuit : gratuite, cauris inchangés', () {
      final s = pick(const GameState(), 'nuit');
      expect([s.cash, s.inst], [25000, 'nuit']);
    });
    test('pont au niveau 1 : erreur niveau, état inchangé', () {
      const s = GameState();
      expect(errOf(() => pick(s, 'pont'))!.code, 'niveau');
      expect(s.cash, 25000);
    });
    test('lagune niveau 1, réputation 8 : erreur rep', () => expect(errOf(() => pick(const GameState(), 'lagune'))!.code, 'rep'));
    test('pont niveau 2 (xp 100), 25 000 cauris : 10 000 cauris', () {
      final s = pick(const GameState(xp: 100), 'pont');
      expect([s.cash, s.inst], [10000, 'pont']);
    });
    test('lagune réputation 30, 25 000 cauris : erreur cash', () => expect(errOf(() => pick(const GameState(rep: 30), 'lagune'))!.code, 'cash'));
    test('lagune réputation 30, 50 000 cauris : 10 000 cauris', () {
      final s = pick(const GameState(rep: 30, cash: 50000), 'lagune');
      expect([s.cash, s.inst], [10000, 'lagune']);
    });
    test('gbaka à 7 999 cauris : erreur cash', () => expect(errOf(() => pick(const GameState(cash: 7999), 'gbaka'))!.code, 'cash'));
    test('gbaka à 8 000 cauris : 0 cauris', () => expect(pick(const GameState(cash: 8000), 'gbaka').cash, 0));
    test('niveau vérifié avant le cash (pont, 0 cauris)', () => expect(errOf(() => pick(const GameState(cash: 0), 'pont'))!.code, 'niveau'));
    test('réputation vérifiée avant le cash (lagune, 0 cauris)', () => expect(errOf(() => pick(const GameState(cash: 0), 'lagune'))!.code, 'rep'));
    test('instru inconnue : erreur inconnu', () => expect(errOf(() => pick(const GameState(), 'zzz'))!.code, 'inconnu'));
    test('changer d\'instru est permis et payant', () {
      final s = pick(pick(const GameState(), 'nuit'), 'gbaka');
      expect([s.cash, s.inst], [17000, 'gbaka']);
    });
    test('ne touche pas au reste de l\'état', () {
      const a = GameState(fans: 77, pop: 4, rep: 9, xp: 50, day: 3, hour: 10, energy: 66);
      final b = pick(a, 'gbaka');
      expect([b.fans, b.pop, b.rep, b.xp, b.day, b.hour, b.energy], [77, 4, 9, 50, 3, 10, 66]);
    });
  });

  group('pickBlocker (même ordre que pick)', () {
    test('null quand possible', () => expect(pickBlocker(const GameState(), 'gbaka'), isNull));
    test('niveau, rep, cash', () {
      expect(pickBlocker(const GameState(), 'pont'), 'niveau');
      expect(pickBlocker(const GameState(), 'lagune'), 'rep');
      expect(pickBlocker(const GameState(rep: 30), 'lagune'), 'cash');
    });
  });

  group('confirmation d\'achat (>= 15 000, comme promoCbig de game.js)', () {
    test('seuil', () {
      expect(needsConfirm(14999), isFalse);
      expect(needsConfirm(15000), isTrue);
      expect(needsConfirm(40000), isTrue);
      expect(needsConfirm(8000), isFalse);
    });
  });

  group('messages d\'erreur (ERR de game.js)', () {
    test('cash, énergie, niveau, réputation', () {
      expect(const GameError('cash').message, 'Cash insuffisant');
      expect(const GameError('energie').message, 'Énergie insuffisante : dors ou récupère');
      expect(const GameError('niveau').message, 'Niveau requis');
      expect(const GameError('rep').message, 'Réputation requise');
      expect(const GameError('son').message, 'Aucun son prêt à sortir');
    });
  });

  group('sauvegarde de l\'instru', () {
    test('aller-retour JSON', () {
      final s = pick(const GameState(), 'gbaka');
      expect(GameState.fromJson(s.toJson()).inst, 'gbaka');
    });
    test('ancienne sauvegarde sans instru : lisible, instru nulle', () {
      final s = GameState.fromJson({'v': 1, 'cash': 777});
      expect([s.cash, s.inst], [777, null]);
    });
    test('copyWith(inst: null) efface, sans argument conserve', () {
      final s = pick(const GameState(), 'gbaka');
      expect(s.copyWith(cash: 1).inst, 'gbaka');
      expect(s.copyWith(inst: null).inst, isNull);
    });
  });
}
