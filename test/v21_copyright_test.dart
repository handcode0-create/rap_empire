import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/copyright21.dart';
import 'package:rap_empire/domain/v21/engine21.dart';

void main() {
  test('une instrumentale gratuite conserve un risque non nul sans être déclarée illégale', () {
    final rights = copyrightRightsFor21('nuit', 4);
    expect(rights['status'], 'unverified_free');
    expect(rights['risk'], greaterThan(0));
    expect(rights['terms'], contains('non vérifiée'));
  });

  test('une instrumentale du catalogue avec accord ne porte pas le risque des instrus gratuites', () {
    final rights = copyrightRightsFor21('gbaka', 4);
    expect(rights['status'], 'licensed');
    expect(rights['risk'], 0);
  });

  test('pas de réclamation avant le seuil de hit ni avant le délai minimal', () {
    final state = init21();
    final song = <String, dynamic>{
      'id': 'T1', 'title': 'Test', 'L': 50000, 'rev': 5000,
      'rights': copyrightRightsFor21('nuit', 1),
    };
    state['cr'] = initCopyright21();
    expect(copyrightTryClaim21(state, song, 5, 0), isFalse);
    song['L'] = copyrightHitThreshold21;
    expect(copyrightTryClaim21(state, song, 2, 0), isFalse);
  });

  test('le déclenchement est probabiliste et limité aux instrus gratuites non vérifiées', () {
    final state = init21()..['cr'] = initCopyright21();
    final song = <String, dynamic>{
      'id': 'T2', 'title': 'Hit', 'L': 1000000, 'rev': 50000,
      'rights': copyrightRightsFor21('nuit', 1),
    };
    expect(copyrightTryClaim21(state, song, 5, 1), isFalse);
    expect(copyrightTryClaim21(state, song, 5, 0), isTrue);
    expect(copyrightHasOpenClaim21(state), isTrue);
    expect((state['cr'] as Map)['claims'], hasLength(1));
  });

  test('négocier réduit la demande puis régler débite les cauris et sécurise le morceau', () {
    final state = init21()..['cr'] = initCopyright21();
    final song = <String, dynamic>{
      'id': 'T3', 'title': 'Mon hit', 'L': 900000, 'rev': 100000,
      'rights': copyrightRightsFor21('nuit', 1),
    };
    state['disco'] = [song];
    expect(copyrightTryClaim21(state, song, 5, 0), isTrue);
    final initial = copyrightActionCost21(state, 'settle');
    expect(initial, 22000);
    applyCopyrightAction21(state, 'negotiate');
    final negotiated = copyrightActionCost21(state, 'settle');
    expect(negotiated, 15400);
    final paid = applyCopyrightAction21(state, 'settle');
    expect(paid, 15400);
    expect((state['disco'] as List).first['rights']['status'], 'licensed_after_settlement');
    expect(((state['cr'] as Map)['claims'] as List).first['status'], 'settled');
  });

  test('ignorer ou contester peut suspendre le morceau après un délai, jamais immédiatement', () {
    final state = init21()..['cr'] = initCopyright21();
    final song = <String, dynamic>{
      'id': 'T4', 'title': 'Hit', 'L': 900000, 'rev': 100000,
      'rights': copyrightRightsFor21('nuit', 1),
    };
    state['disco'] = [song];
    copyrightTryClaim21(state, song, 5, 0);
    applyCopyrightAction21(state, 'ignore');
    expect(copyrightAdvance21(state, song, 7, 0), isFalse);
    expect(copyrightAdvance21(state, song, 8, 0), isTrue);
    expect(copyrightIsBlocked21(song), isTrue);
  });

  test('la scène de litige propose les quatre décisions et reste rejouable', () {
    final scene = dlg21['copyright'];
    expect(scene, isNotNull);
    expect(scene!.cond(init21()..['cr'] = {
      'nextId': 2,
      'claims': [
        {'id': 'CR1', 'status': 'open', 'songId': 'T1'}
      ],
    }), isTrue);
    expect(scene.nodes['n1']!.ch.map((choice) => choice.id), ['a', 'b', 'c', 'd']);
    expect(scene.nodes['n2']!.ch, hasLength(3));
  });

  test('les anciennes sauvegardes sans état copyright sont normalisées sans risque rétroactif', () {
    final old = init21()..remove('cr');
    final normalized = norm21(old);
    expect((normalized['cr'] as Map)['claims'], isEmpty);
    final legacySong = <String, dynamic>{'id': 'old', 'L': 1000000, 'rev': 50000};
    expect(copyrightClaimChance21(legacySong), 0);
  });
}
