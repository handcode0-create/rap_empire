import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// V22 Dynamic Concert Engine : invitations, cachets, sponsor, public, déplacements, renouvellement. Valeurs provisoires.
J m(dynamic x) => x as J;

J start({int rank = 4, int seed = 7}) {
  final s = act21(init21(), 'preset', 'carriere').s;
  s['rank'] = rank;
  s['seed'] = seed;
  return s;
}

void main() {
  test('avant le rang 3 : aucune invitation, acceptation refusée', () {
    final s = start(rank: 2);
    expect(cvView21(s), isEmpty);
    expect(act21(s, 'cvAccept', 'x').err, 'rang');
  });

  test('trois invitations sans doublon de type, valeurs cohérentes', () {
    for (final rank in [3, 4, 5]) {
      final l = cvView21(start(rank: rank));
      expect(l.length, 3);
      expect(l.map((o) => o['type']).toSet().length, 3);
      expect(l.map((o) => o['id']).toSet().length, 3);
      for (final o in l) {
        final t = Cv21.types[o['type']]!;
        expect(o['att'] as num, lessThanOrEqualTo(o['cap'] as num));
        expect(o['fill'] as num, inInclusiveRange(0, 100));
        expect(o['fee'] as num, inInclusiveRange(t.feeLo, t.feeHi));
        expect(o['prestige'] as num, inInclusiveRange(1, 5));
        expect((o['exp'] as num), greaterThan(0));
        final sp = o['sponsor'];
        if (sp != null) expect(m(sp)['bonus'] as num, greaterThanOrEqualTo(0));
        if (o['type'] == 'sponsored_event') expect(sp, isNotNull);
      }
    }
  });

  test('rouvrir l’écran ne relance pas le hasard', () {
    final s = start();
    final a = cvView21(s).map((o) => o['id']).toList();
    final b = cvView21(s).map((o) => o['id']).toList();
    expect(a, b);
    // L'acceptation ne change pas non plus les autres invitations.
    final r = act21(s, 'cvAccept', a.first);
    expect(r.err, isNull);
    expect(cvView21(r.s).map((o) => o['id']).toList(), a);
    expect(cvView21(r.s).firstWhere((o) => o['id'] == a.first)['status'], 'accepted');
  });

  test('plus de prestige à haut rang qu’à bas rang (tendance, pas une règle)', () {
    int big(int rank) {
      var n = 0;
      for (var seed = 1; seed <= 40; seed++) {
        for (var day = 1; day <= 5; day++) {
          final s = start(rank: rank, seed: seed * 13);
          s['day'] = day;
          n += cvView21(s).where((o) => Cv21.types[o['type']]!.fam == 2).length;
        }
      }
      return n;
    }
    expect(big(5), greaterThan(big(3)));
    expect(big(3), greaterThan(0), reason: 'une invitation prestigieuse reste possible à bas rang');
  });

  test('concert joué : cachet figé, sponsor et déplacement comptés une seule fois', () {
    var s = start();
    final o = cvView21(s).first;
    s = act21(s, 'cvAccept', o['id']).s;
    final cash0 = s['cash'] as num;
    final shows0 = s['shows'] as num;
    final r = act21(s, 'cvPlay', o['id']);
    expect(r.err, isNull);
    final cc = m(r.s['cc']);
    final fee = o['fee'] as num;
    final bonus = o['sponsor'] == null ? 0 : m(o['sponsor'])['bonus'] as num;
    final cost = cvTravel21(o);
    expect((r.s['cash'] as num) - cash0, fee + bonus - (cc['managerCut'] as num) - cost);
    expect(cc['gross'], fee + bonus - cost);
    expect(r.s['shows'], shows0 + 1);
    expect(cc['tk'] as num, lessThanOrEqualTo(cc['cap'] as num));
    // Pas de double paiement : le même concert ne peut plus être joué.
    expect(act21(r.s, 'cvPlay', o['id']).err, 'inconnu');
    expect(cvView21(r.s).any((x) => x['id'] == o['id']), isFalse);
  });

  test('un concert joué impose le délai de 7 jours et renouvelle la série', () {
    var s = start();
    final l = cvView21(s);
    s = act21(s, 'cvAccept', l[0]['id']).s;
    s = act21(s, 'cvAccept', l[1]['id']).s;
    s = act21(s, 'cvPlay', l[0]['id']).s;
    expect(act21(s, 'cvPlay', l[1]['id']).err, 'delai');
    final after = cvView21(s);
    expect(after.where((o) => o['status'] == 'available').length, 3);
    expect(after.map((o) => o['id']).toSet().length, after.length);
  });

  test('nouveau jour : acceptées conservées, pas de doublon d’identifiant, public ≤ capacité', () {
    var s = start();
    final first = cvView21(s)[0];
    s = act21(s, 'cvAccept', first['id']).s;
    final ids = <dynamic>{};
    for (var d = 0; d < 20; d++) {
      s = act21(s, 'endDay').s;
      final l = cvView21(s);
      expect(l.any((o) => o['id'] == first['id'] && o['status'] == 'accepted'), isTrue);
      expect(l.where((o) => o['status'] == 'available').length, lessThanOrEqualTo(3));
      expect(l.map((o) => o['id']).toSet().length, l.length);
      for (final o in l) {
        expect(o['att'] as num, lessThanOrEqualTo(o['cap'] as num));
        if (o['status'] == 'available') expect(o['exp'] as num, greaterThanOrEqualTo(s['day'] as num));
        ids.add(o['id']);
      }
    }
    expect(ids.length, greaterThan(3));
  });

  test('déplacement : cash insuffisant refusé, frais déduits sinon', () {
    var s = start(rank: 5);
    Map<String, dynamic>? away;
    for (var d = 0; d < 40 && away == null; d++) {
      for (final o in cvView21(s)) {
        if (cvTravel21(o) > 0) away = o;
      }
      if (away == null) s = act21(s, 'endDay').s;
    }
    expect(away, isNotNull);
    s = act21(s, 'cvAccept', away!['id']).s;
    final poor = Map<String, dynamic>.from(s)..['cash'] = 0;
    expect(act21(poor, 'cvPlay', away['id']).err, 'cash');
  });

  test('le concert v21 « Le Parvis » reste disponible', () {
    final s = start();
    expect(act21(s, 'concert').err, isNull);
  });
}
