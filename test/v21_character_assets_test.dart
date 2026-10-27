import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/features/v21/cast21.dart';

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


  test('le manifeste référence les nouveaux personnages générés', () {
    final manifest = File('assets/characters/manifest.json').readAsStringSync();
    for (final id in [
      'awa', 'bakary', 'liv', 'marius', 'kre', 'maze', 'benedicte', 'kofi',
      'kaira', 'tito', 'lazuli', 'nadia-kolo', 'solo', 'mika', 'tamsir',
      'desire', 'naya',
    ]) {
      expect(manifest, contains('"$id"'), reason: 'ID absent du manifeste : $id');
    }
  });

  test('les 63 tenues disposent des variantes jeune et mature en SVG (affichables sur iPhone)', () {
    for (var i = 1; i <= 63; i++) {
      final id = 'OUTFIT_${i.toString().padLeft(3, '0')}';
      for (final age in ['young', 'mature']) {
        final file = File('assets/characters/rapper_001/$age/v21b_$id.svg');
        expect(file.existsSync(), isTrue, reason: '$id / $age');
        expect(file.readAsStringSync(), contains('<svg'), reason: '$id / $age');
      }
    }
  });

  test('chaque artiste du catalogue a son avatar généré (sauf les artistes nommés, qui gardent leur illustration)', () {
    final cat = (jsonDecode(File('assets/data/artistes-demo.json').readAsStringSync())['artistes'] as List).cast<Map>();
    final seen = <String>{};
    var generated = 0;
    for (final a in cat) {
      final id = artistAvatarId21(a['id'] as String);
      expect(id, matches(RegExp(r'^art\d{4}$')));
      if (castId21(a['nom'] as String) != null) continue;
      final f = File('assets/characters/${id}_smile_head.svg');
      expect(f.existsSync(), isTrue, reason: '${a['id']} ${a['nom']}');
      seen.add(f.readAsStringSync());
      generated++;
    }
    expect(generated, greaterThan(900));
    expect(seen.length, greaterThan(generated * 0.95), reason: 'portraits distincts');
    expect(artistAvatarId21('ART-0501'), 'art0501');
    expect(artistAvatarId21(null), isNull);
    expect(artistAvatarId21('djo'), isNull);
  });
}
