import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('les nouveaux personnages du registre ont des portraits générés en 2D', () {
    const ids = [
      'awa', 'bakary', 'liv', 'marius', 'kre', 'maze', 'benedicte', 'kofi',
      'kaira', 'tito', 'lazuli', 'nadia-kolo', 'solo', 'mika', 'tamsir',
      'desire', 'naya',
    ];
    for (final id in ids) {
      final file = File('assets/characters/${id}_cool_bust.svg');
      expect(file.existsSync(), isTrue, reason: 'Portrait généré manquant : $id');
      final svg = file.readAsStringSync();
      expect(svg, contains('<svg'), reason: id);
      expect(svg, contains('</svg>'), reason: id);
    }
  });

  test('les nouveaux avatars de personnages sont présents et distincts', () {
    const ids = ['mika', 'tamsir', 'desire', 'naya'];
    final sources = <String>[];
    for (final id in ids) {
      final file = File('assets/svg/galerie-$id.svg');
      expect(file.existsSync(), isTrue, reason: id);
      final svg = file.readAsStringSync();
      expect(svg, contains('<svg'), reason: id);
      expect(svg, contains('</svg>'), reason: id);
      sources.add(svg);
    }
    expect(sources.toSet().length, ids.length, reason: 'Chaque personnage doit avoir son propre avatar.');
  });

  test('les nouvelles tenues disposent des variantes jeune et mature en SVG', () {
    for (final id in ['OUTFIT_006', 'OUTFIT_007', 'OUTFIT_008', 'OUTFIT_009']) {
      for (final age in ['young', 'mature']) {
        final file = File('assets/characters/rapper_001/$age/$id.svg');
        expect(file.existsSync(), isTrue, reason: '$id / $age');
        expect(file.readAsStringSync(), contains('<svg'), reason: '$id / $age');
      }
    }
  });
}
