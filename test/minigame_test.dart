import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/minigame.dart';
import 'package:rap_empire/domain/rules.dart';

/// Parité avec game.js (v20) : mini() pour le mini-jeu de cabine, view().gapPct pour le seuil de classement.
/// Les valeurs attendues viennent des mêmes formules exécutées avec Node.
void main() {
  group('zones des trois prises (ZC de game.js)', () {
    test('centres 0,62 / 0,34 / 0,72', () => expect(zoneCenters, [0.62, 0.34, 0.72]));
    test('la zone se répète au-delà de trois prises', () => expect([zoneCenter(0), zoneCenter(3), zoneCenter(4), zoneCenter(5)], [0.62, 0.62, 0.34, 0.72]));
    test('zone verte de 16 % de la piste', () => expect(zoneHalfWidth * 2, closeTo(0.16, 1e-12)));
    test('trois prises par session', () => expect(takesPerSession, 3));
  });

  group('position du curseur (onde triangulaire, vitesse 0,85)', () {
    const expected = [(0.0, 1.0), (0.25, 0.7875), (0.5, 0.575), (1.0, 0.15), (1.17647, 0.0000005), (1.5, 0.275), (2.352941, 0.99999985), (3.0, 0.45), (5.0, 0.75), (10.0, 0.5)];
    for (final e in expected) {
      test('${e.$1} s : ${e.$2}', () => expect(cursorAt(e.$1), closeTo(e.$2, 1e-6)));
    }
    test('toujours entre 0 et 1', () {
      for (var t = 0.0; t < 30; t += 0.037) {
        expect(cursorAt(t), inInclusiveRange(0, 1));
      }
    });
    test('période de 2 / 0,85 s', () => expect(cursorAt(0.4), closeTo(cursorAt(0.4 + 2 / 0.85), 1e-9)));
  });

  group('note d\'une prise : max(0, round(100 - écart x 230))', () {
    // (curseur, prise, note) obtenus avec Node.
    const cases = [
      (0.62, 0, 100), (0.5, 0, 72), (0.0, 0, 0), (1.0, 0, 13),
      (0.34, 1, 100), (0.1, 1, 45), (0.8, 1, 0),
      (0.72, 2, 100), (0.4, 2, 26), (0.95, 2, 47),
      (0.62, 3, 100), (0.5, 5, 49),
    ];
    for (final c in cases) {
      test('curseur ${c.$1}, prise ${c.$2} : ${c.$3}', () => expect(takeScore(c.$1, c.$2), c.$3));
    }
    test('jamais négative', () => expect(takeScore(0, 2), 0));
  });

  group('message d\'une prise', () {
    const cases = {0: 'Prise ratée, mais gardée', 44: 'Prise ratée, mais gardée', 45: 'Prise correcte', 69: 'Prise correcte', 70: 'Prise propre', 100: 'Prise propre'};
    for (final c in cases.entries) {
      test('${c.key} : ${c.value}', () => expect(takeMessage(c.key), c.value));
    }
  });

  group('gapPercent : part du seuil d\'entrée du Top 100 (gapPct de game.js)', () {
    const cases = {0: 0.0, 1000: 0.4, 8127: 3.2, 25986: 10.3, 100000: 39.7, 154931: 61.4, 252200: 100.0, 300000: 100.0};
    for (final c in cases.entries) {
      test('${c.key} écoutes : ${c.value} %', () => expect(gapPercent(c.key), c.value));
    }
    test('parcours canonique : 8 127 écoutes de la semaine, 3,2 % (planche 05.4)', () => expect(gapPercent(8127), 3.2));
  });
}
