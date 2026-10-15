import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/rules.dart';

/// Valeurs de référence issues du moteur du prototype v20 (engine.js), pour garantir la parité.
void main() {
  test('qualité : texte 72, voix 55, prod 56, énergie 100 = 61', () => expect(quality(72, 55, 56, 100), 61));
  test('malus de forme sous 40 énergie', () => expect(quality(72, 55, 56, 20), 51));
  test('écoutes (parité prototype)', () {
    expect(listensFor(61, 120, 0), 5418);
    expect(listensFor(61, 120, 2), 17324);
    expect(listensFor(61, 500, 1, feat: true), 12489);
    expect(listensFor(86, 5000, 2), 103287);
  });
  test('niveaux', () {
    expect(levelOf(0), 1);
    expect(levelOf(100), 2);
    expect(levelOf(899), 4);
    expect(levelOf(900), 5);
  });
  test('cauris jamais négatifs (I-09)', () {
    expect(() => pay(const GameState(cash: 100), -200), throwsA(isA<GameError>()));
    expect(pay(const GameState(cash: 100), -100).cash, 0);
  });
  test('copyWith conserve la version de sauvegarde', () {
    const s = GameState(version: 2);
    expect(s.copyWith(cash: 1).version, 2);
    expect(s.copyWith(version: 3).version, 3);
  });
  test('sauvegarde aller-retour', () {
    const s = GameState(cash: 777, xp: 120);
    expect(GameState.fromJson(s.toJson()).cash, 777);
    expect(GameState.fromJson(s.toJson()).level, 2);
  });
}
