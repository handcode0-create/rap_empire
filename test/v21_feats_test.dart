import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/features/v21/cast21.dart';

/// Featurings : quatorze artistes invités, du quartier aux stars du Top 10 ; chacun illustré, débloqué par la popularité.
void main() {
  test('quatorze artistes, tous illustrés, cachets et exigences croissants', () {
    expect(Reg21.feats.length, 14);
    for (final f in Reg21.feats.values) {
      final id = castId21(f['n'] as String);
      expect(id, isNotNull, reason: '${f['n']}');
      expect(File('assets/characters/${id}_smile_head.svg').existsSync(), isTrue, reason: '${f['n']}');
      expect(f['share'] == null || f['cost'] == 0, isTrue); // une part de revenus n'est affichée que pour un featuring sans cachet
    }
    final byPop = Reg21.feats.values.where((f) => f['needPop'] != null).toList()..sort((a, b) => (a['needPop'] as num).compareTo(b['needPop'] as num));
    expect((byPop.last['cost'] as num) > (byPop.first['cost'] as num), isTrue);
  });

  test('un nouvel artiste s\'ajoute à un titre, une star reste verrouillée sans popularité', () {
    var s = act21(init21(), 'preset', 'debut').s;
    s['hour'] = 8;
    s['en'] = 100;
    s['cash'] = 200000;
    s = act21(s, 'create', ['quartier', 'sombre']).s;
    final c0 = s['cash'] as num;
    final r = act21(s, 'feat', 'naya');
    expect(r.err, isNull);
    expect(r.s['cash'], c0 - 5000);
    s['pop'] = 10;
    expect(act21(s, 'feat', 'kaira').err, 'pop');
    s['pop'] = 80;
    expect(act21(s, 'feat', 'kaira').err, isNull);
  });
}
