import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/kore.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

/// Parité avec A.kdeal, KD et A.record de docs/design-ref/game.js (scène A : producteur DJ Kôrô).

GameError? _err(GameState Function() f) {
  try {
    f();
  } on GameError catch (e) {
    return e;
  }
  return null;
}

void main() {
  group('KD : valeurs de game.js', () {
    const expected = {
      // id: [cut, cost, rel, bonus, left, st]
      'acc': ['40 %', 8000, 15, 12, 3, 'acc'],
      'neg': ['35 %', 7000, 8, 12, 3, 'neg'],
      'ins': ['30 %', 0, -5, 0, 0, 'ref'],
      'ref': ['', 0, -10, 0, 0, 'ref'],
      'back': ['45 %', 6000, 5, 12, 3, 'back'],
      'assist': ['tarif assistant', 0, 0, 6, 2, 'assist'],
      'decl': ['', 0, -15, 0, 0, 'decl'],
    };
    for (final e in expected.entries) {
      test('choix ${e.key}', () {
        final c = koreChoices[e.key]!;
        expect([c.cut, c.cost, c.rel, c.bonus, c.left, c.st], e.value);
      });
    }
    test('sept choix, pas un de plus', () => expect(koreChoices.keys.toSet(), expected.keys.toSet()));
  });

  group('A.kdeal', () {
    test('accepter à 40 % : −8 000 cauris, accord, registre « instru »', () {
      final n = kdeal(const GameState(), 'acc');
      expect(n.cash, 17000);
      expect(n.kc, const KoreDeal(st: 'acc', rel: 15, cut: '40 %', cost: 8000, left: 3, bonus: 12));
      expect(n.cat['instru'], -8000);
      expect(n.led.first.label, 'Studio Kôrô : accord');
      expect(n.led.first.amount, -8000);
      expect(n.led.first.cat, 'instru');
    });
    test('un choix gratuit n’écrit rien au registre', () {
      final n = kdeal(const GameState(), 'ref');
      expect([n.cash, n.led.length, n.cat['instru']], [25000, 0, 0]);
      expect(n.kc, const KoreDeal(st: 'ref', rel: -10));
    });
    test('négocier à 35 % : −7 000, relation +8', () {
      final n = kdeal(const GameState(), 'neg');
      expect([n.cash, n.kc.rel, n.kc.cut, n.kc.st], [18000, 8, '35 %', 'neg']);
    });
    test('via l’assistant : gratuit, bonus +6 sur 2 titres', () {
      final n = kdeal(const GameState(), 'assist');
      expect([n.cash, n.kc.bonus, n.kc.left, n.kc.rel], [25000, 6, 2, 0]);
    });
    test('un accord conclu bloque tout nouveau choix (erreur accord), état intact', () {
      for (final done in ['acc', 'neg', 'assist']) {
        final s = const GameState().copyWith(kc: KoreDeal(st: done));
        expect(_err(() => kdeal(s, 'ref'))!.code, 'accord', reason: done);
      }
      expect(_err(() => kdeal(kdeal(const GameState(), 'back'), 'acc'))!.code, 'accord');
    });
    test('après un refus ou un refus définitif, un nouveau choix reste possible', () {
      expect(kdeal(kdeal(const GameState(), 'ref'), 'back').kc.st, 'back');
      expect(kdeal(kdeal(const GameState(), 'decl'), 'assist').kc.st, 'assist');
    });
    test('la relation s’additionne : refus (−10) puis accord à 45 % (+5) = −5', () {
      final n = kdeal(kdeal(const GameState(), 'ref'), 'back');
      expect(n.kc.rel, -5);
      expect(n.cash, 19000);
    });
    test('cash insuffisant : erreur cash, rien ne change', () {
      const s = GameState(cash: 7999);
      expect(_err(() => kdeal(s, 'acc'))!.code, 'cash');
      expect(kdeal(const GameState(cash: 8000), 'acc').cash, 0); // pile le prix : accepté
    });
    test('ordre des erreurs : inconnu, puis accord, puis cash', () {
      expect(_err(() => kdeal(const GameState(), 'zzz'))!.code, 'inconnu');
      expect(_err(() => kdeal(const GameState(cash: 0).copyWith(kc: const KoreDeal(st: 'acc')), 'back'))!.code, 'accord');
    });
    test('messages : « Accord déjà conclu avec Kôrô »', () => expect(const GameError('accord').message, 'Accord déjà conclu avec Kôrô'));
  });

  group('A.record : bonus de production de l’accord', () {
    GameState session(GameState s) => record(write(pick(s.copyWith(song: null), 'nuit')));

    test('sans accord : production = qualité de l’instru', () => expect(session(const GameState()).song!.prod, 32));
    test('accord à 40 % : +12 sur trois titres, puis plus rien', () {
      var s = kdeal(const GameState(), 'acc');
      final prods = <int>[];
      final lefts = <int>[];
      for (var i = 0; i < 4; i++) {
        s = session(s.copyWith(energy: 100));
        prods.add(s.song!.prod);
        lefts.add(s.kc.left);
      }
      expect(prods, [44, 44, 44, 32]);
      expect(lefts, [2, 1, 0, 0]);
    });
    test('via l’assistant : +6 sur deux titres', () {
      var s = kdeal(const GameState(), 'assist');
      final prods = <int>[];
      for (var i = 0; i < 3; i++) {
        s = session(s.copyWith(energy: 100));
        prods.add(s.song!.prod);
      }
      expect(prods, [38, 38, 32]);
    });
    test('le bonus relève la qualité du son (0,35 × 12 ≈ 4 points)', () {
      final base = session(const GameState()).song!.q;
      final boosted = session(kdeal(const GameState(), 'acc')).song!.q;
      expect(boosted - base, inInclusiveRange(4, 5));
    });
    test('la relation et l’accord survivent à l’enregistrement', () {
      final s = session(kdeal(const GameState(), 'acc'));
      expect([s.kc.st, s.kc.rel, s.kc.cut], ['acc', 15, '40 %']);
    });
  });

  group('libellés (kcSt, kcBonus, kcRel de game.js)', () {
    test('état', () {
      expect(koreStatusLabel(const KoreDeal()), 'Aucun accord');
      expect(koreStatusLabel(const KoreDeal(st: 'acc')), 'Accord à 40 %');
      expect(koreStatusLabel(const KoreDeal(st: 'neg')), 'Accord à 35 % (mix signé)');
      expect(koreStatusLabel(const KoreDeal(st: 'ref')), 'Refus : il se souvient');
      expect(koreStatusLabel(const KoreDeal(st: 'back')), 'Accord à 45 %');
      expect(koreStatusLabel(const KoreDeal(st: 'assist')), 'Via son assistant');
      expect(koreStatusLabel(const KoreDeal(st: 'decl')), 'Refus définitif');
    });
    test('bonus et relation', () {
      expect(koreBonusLabel(const KoreDeal(bonus: 12, left: 3)), '+12 production · 3 titres');
      expect(koreBonusLabel(const KoreDeal(bonus: 6, left: 1)), '+6 production · 1 titre');
      expect(koreBonusLabel(const KoreDeal()), 'aucun');
      expect([koreRelLabel(15), koreRelLabel(0), koreRelLabel(-10)], ['+15', '0', '-10']);
    });
    test('coût', () {
      expect(koreCostLabel('acc'), '−8 000 cauris');
      expect(koreCostLabel('ref'), '');
    });
  });

  group('sauvegarde', () {
    test('aller-retour JSON de l’accord et de l’introduction', () {
      final s = kdeal(const GameState(koreIntro: true), 'neg');
      final r = GameState.fromJson(s.toJson());
      expect(r.kc, s.kc);
      expect(r.koreIntro, isTrue);
    });
    test('ancienne sauvegarde sans accord : valeurs par défaut', () {
      final json = const GameState().toJson()..remove('kc')..remove('ki');
      final r = GameState.fromJson(json);
      expect(r.kc, const KoreDeal());
      expect(r.koreIntro, isFalse);
    });
  });
}
