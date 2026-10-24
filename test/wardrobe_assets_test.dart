import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every wardrobe manifest entry points to packaged young and mature SVGs', () async {
    final raw = await rootBundle.loadString('assets/characters/rapper_001/manifest.json');
    final manifest = jsonDecode(raw) as Map<String, dynamic>;
    final outfits = manifest['outfits'] as List;

    expect(outfits, isNotEmpty);

    for (final rawOutfit in outfits) {
      final outfit = Map<String, dynamic>.from(rawOutfit as Map);
      final id = outfit['id'] as String;
      final images = Map<String, dynamic>.from(outfit['images'] as Map);

      for (final stage in const ['young', 'mature']) {
        final relativePath = images[stage] as String;
        expect(
          relativePath.startsWith('$stage/'),
          isTrue,
          reason: '$id must reference its $stage variant',
        );
        await rootBundle.load('assets/characters/rapper_001/$relativePath');
      }
    }
  });
}
