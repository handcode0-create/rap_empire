import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Carrière v21 : intérêt des labels avant les offres, problèmes de début de carrière, boulots selon le rang,
/// missions de carrière à récupérer. Valeurs provisoires (D-08).
J _ok(J s, String a, [dynamic g]) {
  final r = act21(s, a, g);
  expect(r.err, isNull, reason: '$a $g');
  return r.s;
}

J _copy(J s) => jsonDecode(jsonEncode(s)) as J;

J _single(String id, num q) => {
      'id': id, 'title': 'Titre $id', 'theme': 'quartier', 'amb': 'sombre', 'mode': 'manuel', 'tx': 70, 'st': 'sorti', 'Q': q,
      'feats': <dynamic>[], 'clip': {'st': 'aucun'}, 'L': 5000, 'rev': 0, 'fg': 0, 'pg': 0, 'tier': 'Discret', 'promo': 0, 'vir': 30, 'day': 1,
    };

void main() {
  test('labels : pas d\'offre tant que l\'intérêt des labels est insuffisant', () {
    var s = act21(init21(), 'preset', 'debut').s;
    expect(s['lbz'], 0);
    s['ev'] = null;
    s['rep'] = 12;
    s['disco'] = [_single('T1', 60)];
    s['dseen'] = {'kore': 'x', 'mgr': 'x'};
    final before = _ok(_copy(s), 'setui', 'th=amour');
    expect(before['dlg'], isNull);
    expect((before['dq'] as List).where((x) => '${(x as Map)['id']}'.startsWith('lb_')), isEmpty);
    s['lbz'] = Reg21.lbzGate;
    final after = _ok(s, 'setui', 'th=amour');
    expect((after['dlg'] as Map)['id'], 'lb_AUB');
    expect(labelReady21(after), isTrue);
  });

  test('labels : une sortie, une date et un titre de qualité font monter l\'intérêt', () {
    var s = act21(init21(), 'preset', 'carriere').s;
    expect(s['lbz'] as num, greaterThanOrEqualTo(Reg21.lbzGate)); // carrière lancée : les labels suivent déjà
    s['lbz'] = 0;
    s['hour'] = 8;
    s['en'] = 100;
    s['cur'] = null;
    s = _ok(s, 'create', ['quartier', 'sombre']);
    s = _ok(s, 'record');
    final q = ((s['cur'] as Map)['Q'] as num);
    s = _ok(s, 'release');
    expect(s['lbz'], Reg21.lbzSingle + (q >= 70 ? Reg21.lbzGoodSingle : 0));
  });

  test('anciennes sauvegardes : l\'intérêt des labels est reconstitué', () {
    final s = act21(init21(), 'preset', 'star').s..remove('lbz');
    final n = norm21(_copy(s));
    final want = (s['disco'] as List).length * Reg21.lbzSingle + (s['projects'] as List).length * Reg21.lbzProject + (s['shows'] as num) * Reg21.lbzShow;
    expect(n['lbz'], want > Reg21.lbzMax ? Reg21.lbzMax : want);
  });

  test('problèmes de début de carrière : un à la fois, espacés, avec leurs effets', () {
    var s = act21(init21(), 'preset', 'debut').s;
    s['ev'] = null;
    s['evDone'] = {'kzer': 'b'};
    s['dseen'] = {'kore': 'x', 'mgr': 'x'};
    s['disco'] = [_single('T1', 60)];
    s['day'] = 5;
    s = _ok(s, 'setui', 'th=amour');
    expect(s['ev'], 'pb_micro');
    expect(s['pbd'], 5 + Reg21.pbEvery);
    final cash = s['cash'] as num;
    s = _ok(s, 'evc', 'a');
    expect([s['cash'], (s['rel'] as Map)['kore'], s['ev']], [cash - 6000, 2, null]);
    s = _ok(s, 'setui', 'th=amour');
    expect(s['ev'], isNull); // trop tôt pour le suivant
    s['day'] = 8;
    s = _ok(s, 'setui', 'th=amour');
    expect(s['ev'], 'pb_faux');
    final poor = _copy(s)..['cash'] = 100;
    expect(act21(poor, 'evc', 'a').err, 'cash'); // payer l'arnaque demande l'argent
    final r0 = s['rep'] as num;
    s = _ok(s, 'evc', 'b');
    expect(s['rep'], r0 + 2);
  });

  test('problèmes : jamais pour une carrière déjà lancée (préréglages et rang N4 et plus)', () {
    var s = act21(init21(), 'preset', 'star').s;
    s['ev'] = null;
    s = _ok(s, 'setui', 'th=amour');
    expect(s['ev'], isNull);
  });

  test('boulots : les plus rentables se débloquent avec le rang et les compétences', () {
    final d = act21(init21(), 'preset', 'debut').s;
    expect(jobLock21(d, 'livraison'), isNull);
    expect(act21(d, 'job', 'mc').err, 'rang');
    expect(act21(d, 'job', 'assistant').err, 'rang');
    expect(act21(d, 'job', 'plume').err, 'rang');
    final s = act21(init21(), 'preset', 'star').s;
    (s['sk'] as Map)['ecr'] = 10;
    expect(jobLock21(s, 'plume'), 'ecriture');
    (s['sk'] as Map)['ecr'] = 30;
    s['hour'] = 8;
    s['en'] = 100;
    expect(jobLock21(s, 'plume'), isNull);
    final c0 = s['cash'] as num;
    final r = _ok(s, 'job', 'plume');
    expect(r['cash'], c0 + 35000);
    final low = _copy(s);
    (low['sk'] as Map)['voix'] = 5;
    expect(act21(low, 'job', 'pubradio').err, 'voix');
    final rep = _copy(s)..['rep'] = 10;
    expect(act21(rep, 'job', 'jury').err, 'rep');
    // les revenus montent avec le rang
    final byRank = Reg21.jobs.values.toList()..sort((a, b) => ((a['rank'] ?? 1) as num).compareTo((b['rank'] ?? 1) as num));
    expect((byRank.last['cash'] as num) > (byRank.first['cash'] as num), isTrue);
  });

  test('missions de carrière : nombreuses, terminées seules, récompense à récupérer une seule fois', () {
    expect(missions21.length, greaterThanOrEqualTo(60));
    expect(missions21.map((m) => m.id).toSet().length, missions21.length);
    var s = act21(init21(), 'preset', 'star').s;
    s = _ok(s, 'setui', 'th=amour');
    expect(missionState21(s, mission21('c1_single')!), 'done');
    expect(missionState21(s, mission21('c6_fans')!), 'open');
    expect(act21(s, 'mclaim', 'c6_fans').err, 'pasfaite');
    expect(act21(s, 'mclaim', 'zzz').err, 'inconnu');
    final c0 = s['cash'] as num, x0 = s['xp'] as num;
    s = _ok(s, 'mclaim', 'c1_single');
    final (cash, xp) = missionReward21(mission21('c1_single')!);
    expect([s['cash'], s['xp']], [c0 + cash, x0 + xp]);
    expect(missionState21(s, mission21('c1_single')!), 'claimed');
    expect(act21(s, 'mclaim', 'c1_single').err, 'deja');
    expect(missionsClaimed21(s), 1);
    // le chapitre en cours reste le premier tant que toutes ses missions ne sont pas récupérées
    expect(missionChapter21(s), 1);
  });

  test('missions : la partie non créée ne termine rien ; indicateurs lus sur l\'état', () {
    final s = init21();
    expect(act21(s, 'setui', 'th=amour').s['ms2'], isEmpty);
    final st = act21(init21(), 'preset', 'star').s;
    expect(missionMetric21(st, 'singles'), (st['disco'] as List).length);
    expect(missionMetric21(st, 'fans'), st['fans']);
    expect(missionMetric21(st, 'geo_bakoma'), (st['geo'] as Map)['bakoma']);
    expect(missionMetric21(st, 'inconnu'), 0);
  });

  test('formations : coût, compétence, une fois par jour, verrou de rang', () {
    expect(Reg21.trainings.length, greaterThanOrEqualTo(9));
    var s = act21(init21(), 'preset', 'debut').s;
    s['hour'] = 8;
    s['en'] = 100;
    s['cash'] = 50000;
    final v0 = (s['sk'] as Map)['voix'] as num, c0 = s['cash'] as num, tr0 = (s['trained'] ?? 0) as num;
    s = _ok(s, 'train', 'coach');
    expect([(s['sk'] as Map)['voix'], s['cash'], s['trained']], [v0 + 5, c0 - 9000, tr0 + 1]);
    expect(act21(s, 'train', 'coach').err, 'aujourdhui');
    expect(trainLock21(s, 'residence'), 'rang');
    expect(act21(s, 'train', 'residence').err, 'rang');
    expect(act21(s, 'train', 'zzz').err, 'inconnu');
    final poor = _copy(s)..['cash'] = 0;
    expect(act21(poor, 'train', 'shooting').err, 'cash');
    expect(act21(poor, 'train', 'freestyle').err, isNull); // gratuit
    s['day'] = (s['day'] as num) + 1;
    expect(trainLock21(s, 'coach'), isNull);
  });
}
