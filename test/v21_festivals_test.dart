import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Festivals (invitations à accepter ou refuser) et booking international. Valeurs provisoires (D-08).
J _ok(J s, String a, [dynamic g]) {
  final r = act21(s, a, g);
  expect(r.err, isNull, reason: '$a $g');
  return r.s;
}

void main() {
  test('temps : semaines, jours et années', () {
    expect([weekOf21(1), weekDay21(1), yearOf21(1)], [1, 'Lun', 1]);
    expect([weekOf21(364), weekDay21(364), yearOf21(364)], [52, 'Dim', 1]);
    expect([weekOf21(365), yearOf21(365)], [1, 2]);
    expect(dateLabel21(38), 'S6 · Mer · An 1');
  });

  test('festival : invitation la semaine du festival, accepter rapporte le cachet, une seule fois', () {
    var s = act21(init21(), 'preset', 'star').s;
    s['day'] = 35; // dimanche de la semaine 5
    s['ev'] = null;
    s = _ok(s, 'endDay');
    expect(weekOf21(s['day'] as num), 6);
    expect(festivalInvites21(s).map((i) => i['id']), contains('ndolo'));
    s['hour'] = 8;
    s['en'] = 100;
    s['mgr'] = null;
    final c0 = s['cash'] as num, f0 = s['fans'] as num, sh0 = s['shows'] as num;
    s = _ok(s, 'fest', ['ndolo', 'oui']);
    final f = Reg21.festivals['ndolo']!;
    expect(s['cash'], c0 + (f['fee'] as num));
    expect([s['fans'], s['shows']], [f0 + (f['fans'] as num), sh0 + 1]);
    expect(act21(s, 'fest', ['ndolo', 'oui']).err, 'pasinvite');
    expect((s['cc'] as Map)['lbl'], f['n']);
  });

  test('festival : refuser ferme l\'invitation sans pénalité ; pas d\'invitation sans le niveau requis', () {
    var s = act21(init21(), 'preset', 'star').s;
    s['day'] = 35;
    s['ev'] = null;
    s = _ok(s, 'endDay');
    final c0 = s['cash'] as num, r0 = s['rep'] as num;
    s = _ok(s, 'fest', ['ndolo', 'non']);
    expect([s['cash'], s['rep']], [c0, r0]);
    expect(festivalInvites21(s).where((i) => i['id'] == 'ndolo'), isEmpty);
    var d = act21(init21(), 'preset', 'debut').s;
    d['day'] = 76; // semaine 12 : Lagune d'Ambre demande N2 et popularité 12
    d['ev'] = null;
    d = _ok(d, 'endDay');
    expect(festivalInvites21(d).where((i) => i['id'] == 'lagune'), isEmpty);
  });

  test('booking international : rang N5, frais payés, cachets selon la notoriété, une fois toutes les 4 semaines', () {
    final d = act21(init21(), 'preset', 'debut').s;
    expect(act21(d, 'intl', ['tamarel', 'showcase']).err, 'rang');
    var s = act21(init21(), 'preset', 'star').s;
    s['rank'] = Reg21.intlRank;
    s['cash'] = 1000000;
    s['hour'] = 8;
    s['en'] = 100;
    s['mgr'] = null;
    (s['geo'] as Map)['tamarel'] = 0;
    expect(act21(s, 'intl', ['tamarel', 'tournee']).err, 'audience');
    final q = intlQuote21(s, 'tamarel', 'showcase');
    s = _ok(s, 'intl', ['tamarel', 'showcase']);
    final f = Reg21.intlFormats['showcase']!;
    expect(s['cash'], 1000000 - (f['cost'] as num) + q.fees);
    expect((s['geo'] as Map)['tamarel'], f['geo']);
    s['hour'] = 8;
    s['en'] = 100;
    expect(act21(s, 'intl', ['korvane', 'showcase']).err, 'delai');
    s['day'] = (s['day'] as num) + Reg21.intlEvery;
    expect(intlLock21(s, 'korvane', 'showcase'), isNull);
  });
}
