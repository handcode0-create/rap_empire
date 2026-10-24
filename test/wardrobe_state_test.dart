import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../lib/domain/game_state.dart';

void main() {
  group('wardrobe save compatibility', () {
    test('legacy saves receive the default outfit without migration', () {
      final state = GameState.fromJson(<String, dynamic>{'v': 1});

      expect(state.outfitOwned, contains('OUTFIT_001'));
      expect(state.equippedOutfit, 'OUTFIT_001');
      expect(state.avatarStage, 'young');
    });

    test('owned outfits, equipped outfit and avatar stage survive serialization', () {
      const original = GameState(
        outfitOwned: ['OUTFIT_001', 'OUTFIT_002'],
        equippedOutfit: 'OUTFIT_002',
        avatarStage: 'mature',
      );

      final decoded = jsonDecode(original.encode()) as Map<String, dynamic>;
      final restored = GameState.fromJson(decoded);

      expect(restored.outfitOwned, ['OUTFIT_001', 'OUTFIT_002']);
      expect(restored.equippedOutfit, 'OUTFIT_002');
      expect(restored.avatarStage, 'mature');
    });
  });
}
