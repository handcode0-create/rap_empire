import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Port des tests du moteur v21 (docs/RAP-EMPIRE-v21/sources/test21.js) : parcours A à H, création, événements et décisions du 16/10.
Res run(J s, String name, [dynamic arg]) => act21(s, name, arg);
J must(J s, String name, [dynamic arg]) {
  final r = run(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

J m(dynamic x) => x as J;
List l(dynamic x) => x as List;

void main() {
  test('parcours A : une journée normale', () {
    var s = init21();
    s = must(s, 'job', 'livraison');
    expect([s['cash'], s['en'], s['hour']], [28500, 75, 12]);
    s = must(s, 'openmic');
    expect(s['fans'], 270);
    var r = run(s, 'job', 'maquis');
    s = r.s;
    expect(r.err, isNull);
    s = must(s, 'job', 'livraison');
    r = run(s, 'job', 'mc');
    expect(r.err, 'tard');
    s = must(s, 'endDay');
    expect([s['day'], s['hour'], s['en']], [2, 8, 100]);
    expect(m(s['bil'])['cash'], 3500 + 3000 + 4500 + 3500);
    expect(l(m(s['bil'])['acts']).length, greaterThanOrEqualTo(3));
  });

  test('parcours B : création musicale', () {
    var s = init21();
    expect(run(s, 'record').err, 'pasdetexte');
    s = must(s, 'create', ['ambition', 'fiere']);
    expect([m(s['cur'])['st'], m(s['cur'])['tx']], ['ecrit', 76]);
    expect(run(s, 'release').err, 'pasenregistre');
    s = must(s, 'feat', 'nadia');
    expect([s['cash'], l(m(s['cur'])['feats']).length], [17000, 1]);
    expect(run(s, 'feat', 'zaki').err, 'rival');
    expect(run(s, 'feat', 'orage').err, 'pop');
    s = must(s, 'record');
    expect(m(s['cur'])['Q'], greaterThan(0));
    expect(m(s['cur'])['st'], 'enregistre');
    expect(l(s['disco']), isEmpty);
    s = must(s, 'release');
    expect(l(s['disco']).length, 1);
    expect(s['cur'], isNull);
    final d = m(l(s['disco']).first);
    expect(d['st'], 'sorti');
    expect(d['Q'], isNot(d['vir']));
    expect(d['tier'], isA<String>());
    expect(s['pop'], greaterThan(3));
    expect(s['xp'], 70);
    final s2 = must(init21(), 'create', 'random');
    expect(m(s2['cur'])['mode'], 'aléatoire');
  });

  test('parcours C : clip', () {
    var s = init21();
    s['cash'] = 100000;
    s = must(s, 'create', ['quartier', 'sombre']);
    s = must(s, 'clipPrep', 'sika');
    expect(m(m(s['cur'])['clip'])['st'], 'prepare');
    expect(['avantsortie', 'pasproduit'], contains(run(s, 'clipPub').err));
    s = must(s, 'clipShoot');
    expect(m(m(s['cur'])['clip'])['st'], 'produit');
    expect(run(s, 'clipPub').err, 'avantsortie');
    s = must(s, 'endDay');
    s = must(s, 'record');
    s = must(s, 'release');
    final l0 = m(l(s['disco']).first)['L'] as num;
    s = must(s, 'clipPub');
    expect(m(m(l(s['disco']).first)['clip'])['st'], 'publie');
    expect(m(l(s['disco']).first)['L'] as num, greaterThan(l0));
    final s3 = must(must(must(init21(), 'create', ['quartier', 'sombre']), 'record'), 'release');
    expect(run(s3, 'clipPrep', 'sika').err, 'clipapres');
    expect(run(must(init21(), 'create', ['quartier', 'sombre']), 'clipPrep', 'ilan').err, 'rang');
  });

  test('parcours D à F : relation, mariage, famille, séparation', () {
    var s = init21();
    s['cash'] = 100000;
    s = must(s, 'rom', ['lina', 'sortie']);
    expect(m(m(m(s['rom'])['c'])['lina'])['g'], 12);
    s = must(s, 'rom', ['kadi', 'parler']);
    expect(m(m(m(s['rom'])['c'])['kadi'])['g'], 6);
    expect(run(s, 'rom', ['lina', 'parler']).err, 'romjour');
    expect(run(s, 'official', 'lina').err, 'seuil');
    s = must(s, 'endDay');
    expect([m(m(m(s['rom'])['c'])['lina'])['g'], m(m(m(s['rom'])['c'])['kadi'])['g']], [12, 6]);
    s = must(s, 'endDay');
    expect([m(m(m(s['rom'])['c'])['lina'])['g'], m(m(m(s['rom'])['c'])['kadi'])['g']], [11, 5]);
    expect(run(s, 'rom', ['lina', 'scene']).err, 'pasdeconcert');
    for (var i = 0; i < 6; i++) {
      s = must(s, 'rom', ['lina', 'sortie']);
      s = must(s, 'rom', ['lina', 'sortie']);
      s = must(s, 'endDay');
    }
    expect(m(m(m(s['rom'])['c'])['lina'])['g'] as num, greaterThanOrEqualTo(60));
    s = must(s, 'official', 'lina');
    expect(m(s['rom'])['off'], 'lina');
    expect(run(s, 'rom', ['kadi', 'parler']).err, 'exclusif');
    expect(run(s, 'official', 'kadi').err, 'exclusif');

    // mariage et famille
    expect(run(s, 'proposal', 'oui').err, 'condmariage');
    expect(run(s, 'famProj', 'oui').err, 'mariage');
    while ((s['day'] as num) - (m(s['rom'])['since'] as num) < 14 || (m(m(m(s['rom'])['c'])['lina'])['g'] as num) < 80) {
      s = must(s, 'rom', ['lina', 'sortie']);
      s = must(s, 'endDay');
    }
    expect(canPropose21(s), isTrue);
    final sr = must(s, 'proposal', 'non');
    expect(m(m(m(sr['rom'])['c'])['lina'])['g'], (m(m(m(s['rom'])['c'])['lina'])['g'] as num) - 12);
    expect(canPropose21(sr), isFalse);
    s['cash'] = (s['cash'] as num) + 200000;
    s = must(s, 'proposal', 'oui');
    s = must(s, 'wsel', 'simple');
    s = must(s, 'wed');
    expect(m(s['rom'])['married'], 1);
    s = must(s, 'famProj', 'oui');
    var born = false;
    for (var i = 0; i < 30 && !born; i++) {
      s = must(s, 'rom', ['lina', 'parler']);
      s = must(s, 'endDay');
      born = l(m(s['fam'])['kids']).isNotEmpty;
    }
    expect(born, isTrue);
    expect(l(m(s['bil'])['ev']).any((e) => (e as String).startsWith('Naissance')), isTrue);
    s = must(s, 'kid', ['0', 'jouer']);
    expect(m(l(m(s['fam'])['kids'])[0])['l'], 56);
    expect(run(s, 'kid', ['0', 'devoirs']).err, 'age');
    for (var i = 0; i < 7; i++) {
      s = must(s, 'skipYear');
    }
    expect(stageOf(kidAge(s, m(l(m(s['fam'])['kids'])[0]))), 'Enfant');
    expect(s['age'], 19 + 7);
    expect(enMaxAge(30), 95);

    // séparation
    final before = l(m(s['fam'])['kids']).length, hist = l(m(s['rom'])['hist']).length;
    s = must(s, 'separate');
    expect([m(s['rom'])['off'], m(s['rom'])['married'], m(s['rom'])['div']], [null, 0, 1]);
    expect(l(m(s['fam'])['kids']).length, before);
    expect(l(m(s['rom'])['hist']).length, hist + 1);
    expect(m(l(m(s['fam'])['kids'])[0])['garde'], 'Garde partagée');
    expect(run(s, 'rom', ['lina', 'parler']).err, 'ex');
  });

  test('rupture par le partenaire sous 20, avertissement sous 30', () {
    var p = presets21['couple']!();
    m(m(m(p['rom'])['c'])['lina'])['g'] = 21;
    p = must(p, 'endDay');
    p = must(p, 'endDay');
    expect(m(p['rom'])['off'], isNull);
    expect(l(m(p['rom'])['hist']).any((h) => (m(h)['t'] as String).startsWith('Rupture décidée par Lina')), isTrue);
    var w = presets21['couple']!();
    m(m(m(w['rom'])['c'])['lina'])['g'] = 29;
    w = must(w, 'endDay');
    expect(l(m(w['bil'])['ev']).any((e) => (e as String).startsWith('Attention')), isTrue);
  });

  test('parcours G : économie', () {
    var s = init21();
    expect(run(s, 'bizBuy', 'couplet').err, 'rang');
    s = act21(init21(), 'preset', 'carriere').s;
    s = must(s, 'bizBuy', 'couplet');
    s = must(s, 'endDay');
    final tot = m(m(s['biz'])['couplet'])['tot'] as num;
    expect(tot, inInclusiveRange(3000, 5000));
    final c0 = (s['cash'] as num) + 200000;
    s['cash'] = c0;
    s = must(s, 'ask', 'homestudio');
    s = must(s, 'assetBuy');
    expect(m(s['own'])['homestudio'], isNotNull);
    expect(s['cash'], c0 - 180000);
    s = must(s, 'create', ['quartier', 'sombre']);
    final e0 = s['en'] as num;
    s = must(s, 'record');
    expect(e0 - (s['en'] as num), 15);
    expect(l(s['disco']).length, 1);
    expect(m(s['cur'])['prod'], 60);
    expect(run(init21(), 'merch', 'tshirt').err, 'fans');
    s = act21(init21(), 'preset', 'carriere').s;
    s = must(s, 'merch', 'tshirt');
    s = must(s, 'endDay');
    expect(m(s['merch'])['tot'], jsRound(0.8 * 49.0 * 30));
    expect(act21(act21(init21(), 'preset', 'carriere').s, 'sign').err, isNull);
  });

  test('parcours H : carrière et popularité', () {
    var s = act21(init21(), 'preset', 'carriere').s;
    final g0 = m(s['geo'])['portambre'] as num;
    s = must(s, 'tour');
    expect(m(s['geo'])['portambre'], g0 + 8);
    expect(m(s['geo'])['selene'], 11);
    expect(run(init21(), 'tour').err, 'rang');
    s = must(s, 'endDay');
    expect(s['rank'], 4);
    expect(idxParts21(s).i, greaterThan(0));
  });

  test('nouvelle année et patrimoine', () {
    var y = init21();
    y['age'] = 29;
    y = must(y, 'skipYear');
    expect(y['en'], 95);
    expect(m(m(y['bil'])['aged'])['em1'], 95);
    var y2 = init21();
    y2['age'] = 29;
    y2['cash'] = 400000;
    y2 = must(y2, 'ask', 'appart');
    y2 = must(y2, 'assetBuy');
    y2 = must(y2, 'skipYear');
    expect(y2['en'], 100);
  });

  test('création de l’artiste, événements, missions et correctifs d’audit', () {
    var c = init21();
    expect(act21(c, 'finish').err, 'nom');
    c = act21(c, 'setp', 'name=A').s;
    expect(act21(c, 'finish').err, 'nom');
    c = act21(c, 'setp', 'name=<script>').s;
    expect(act21(c, 'finish').err, 'nom');
    c = act21(c, 'setp', 'name=  Young   SM  ').s;
    for (var i = 0; i < 20; i++) {
      c = act21(c, 'setp', 'age=+').s;
    }
    expect(m(c['p'])['age'], 30);
    c = act21(c, 'setp', 'age=-').s;
    c = act21(c, 'setp', 'origin=tamarel').s;
    c = act21(c, 'setp', 'main=trap').s;
    c = act21(c, 'setp', 'second=trap').s;
    expect(m(c['p'])['second'], isNull);
    c = act21(c, 'setp', 'second=coupe').s;
    c = act21(c, 'setp', 'main=coupe').s;
    expect([m(c['p'])['main'], m(c['p'])['second']], ['coupe', null]);
    c = act21(c, 'setp', 'second=trap').s;
    c = act21(c, 'finish').s;
    expect(c['created'], 1);
    expect(m(c['p'])['name'], 'Young SM');
    expect([c['age'], m(c['sk'])['cha'], m(c['sk'])['voix'], m(c['geo'])['tamarel'], c['ev']], [29, 11, 11, 4, 'kzer']);
    expect(act21(c, 'finish').err, 'deja');
    c = act21(c, 'evc', 'a').s;
    expect([c['ev'], c['rep'], m(c['evDone'])['kzer']], [null, 14, 'a']);
    expect(m(c['ms'])['m3'], isNull);
    expect(act21(c, 'evc', 'a').err, 'rien');
    c = act21(c, 'setui', 'title=Ndolo en feu').s;
    c = act21(c, 'create', ['quartier', 'sombre']).s;
    expect(m(c['cur'])['title'], 'Ndolo en feu');
    expect(m(c['ui'])['title'], '');
    c = act21(c, 'record').s;
    expect(m(c['ms'])['m1'], isNotNull);
    expect([c['ev'], c['cash']], ['kore', 30000]);
    final poor = clone21(c)..['cash'] = 100;
    expect(act21(poor, 'evc', 'a').err, 'cash');
    c = act21(c, 'evc', 'b').s;
    expect([m(c['kc'])['left'], m(c['kc'])['bonus'], c['cash']], [3, 12, 23000]);
    c = act21(c, 'release').s;
    expect(m(c['ms'])['m2'], isNotNull);
    c = act21(c, 'endDay').s;
    c = act21(c, 'create', ['quartier', 'sombre']).s;
    c = act21(c, 'record').s;
    expect([m(c['cur'])['prod'], m(c['kc'])['left']], [68, 2]);

    // concert et tournée
    var pc = act21(init21(), 'preset', 'carriere').s;
    pc = act21(pc, 'concert').s;
    expect(m(pc['cc'])['tk'], 300 < 40 + 2400 * 0.05 + 14 * 4 ? 300 : jsRound(40 + 2400 * 0.05 + 14 * 4));
    expect(pc['cash'] as num, greaterThan(320000));
    expect(act21(pc, 'concert').err, 'delai');
    for (var i = 0; i < 7; i++) {
      pc = act21(pc, 'endDay').s;
    }
    expect(act21(pc, 'concert').err, isNull);
    final pt = act21(init21(), 'preset', 'carriere').s;
    m(pt['geo'])['portambre'] = 1;
    m(pt['geo'])['selene'] = 1;
    expect(act21(pt, 'tour').err, 'audience');
    var pm = act21(init21(), 'preset', 'debut').s;
    pm = act21(pm, 'job', 'mc').s;
    expect(pm['pop'], 3);
    final pr = act21(init21(), 'preset', 'carriere').s;
    expect(m(pr['ms'])['m1'], isNotNull);
    expect(m(pr['ms'])['m4'], isNotNull);
    expect(act21(pr, 'job', 'livraison').s['cash'], 320000 + 3500);
  });

  test('décisions du 16/10 : atelier, rangs, part du label, rythme', () {
    var a = act21(init21(), 'preset', 'debut').s;
    final c0 = a['cash'] as num, e0 = m(a['sk'])['ecr'] as num;
    a = act21(a, 'atelier').s;
    expect(m(a['ms'])['m3'], isNotNull);
    expect(m(a['sk'])['ecr'], e0 + 5);
    expect(a['cash'], c0 - 6000 + 4000);
    expect(Reg21.ranks[2]['xp'], 1500);
    var b = act21(init21(), 'preset', 'carriere').s;
    b['signed'] = 1;
    b = act21(b, 'create').s;
    b = act21(b, 'record').s;
    b = act21(b, 'release').s;
    final t = m(l(b['disco']).first);
    expect(t['cut'], jsRound((t['L'] as num) * 0.01) - (t['rev'] as num));
    expect(t['cut'] as num, greaterThan(0));
    var x = act21(init21(), 'preset', 'debut').s;
    for (var d = 0; d < 7; d++) {
      x = act21(x, 'openmic').s;
      x = act21(x, 'endDay').s;
    }
    expect(x['rank'] as num, lessThan(3));
  });
}
