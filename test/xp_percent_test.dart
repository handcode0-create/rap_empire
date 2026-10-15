import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/rules.dart';

/// Parité xpPct de game.js (v20, view) : valeurs obtenues en exécutant game.js avec Node (xp -> pourcentage de la barre d'XP).
void main() {
  const expected = {0: 0, 1: 1, 50: 50, 99: 99, 100: 0, 120: 13, 175: 50, 249: 99, 250: 0, 499: 100, 500: 0, 899: 100, 900: 0, 1000: 17, 1500: 100, 2000: 100};
  for (final e in expected.entries) {
    test('${e.key} XP : ${e.value} %', () => expect(xpPercent(e.key), e.value));
  }
  test('toujours entre 0 et 100', () {
    for (var xp = 0; xp <= 2500; xp += 7) {
      expect(xpPercent(xp), inInclusiveRange(0, 100));
    }
  });
}
