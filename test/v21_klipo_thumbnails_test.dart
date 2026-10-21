import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('vignettes Klipo et publics de concert existent sans texte SVG', () async {
    final paths = <String>[
      for (var i = 1; i <= 50; i++)
        'assets/klipo/thumbs/T${i.toString().padLeft(3, '0')}.svg',
      for (var i = 1; i <= 8; i++) 'assets/klipo/mine/M$i.svg',
      for (var i = 1; i <= 4; i++) 'assets/klipo/crowd/crowd_$i.svg',
    ];
    for (final path in paths) {
      final svg = await rootBundle.loadString(path);
      expect(svg, contains('<svg'), reason: path);
      expect(svg, isNot(contains('<text')), reason: '$path ne doit pas intégrer de texte');
    }
  });
}
