import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/network21.dart';

/// Logos des labels et des médias générés par tools/design/gen_logos.py : un fichier par label et par média, sans <text>.
void main() {
  test('chaque label et chaque média a son logo', () {
    const labels = ['BSR', 'AMG', 'RCD', 'BLG', 'AUB', 'LYR', 'SKP', 'NUG', 'SIC', 'VAG'];
    final files = [for (final c in labels) 'assets/logos/label_$c.svg', for (final id in media21.keys) 'assets/logos/media_$id.svg'];
    for (final f in files) {
      final svg = File(f);
      expect(svg.existsSync(), isTrue, reason: f);
      expect(svg.readAsStringSync().contains('<text'), isFalse, reason: f);
    }
    expect(files.toSet().length, files.length);
  });
}
