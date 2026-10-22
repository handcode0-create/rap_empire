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
    expect(r.err, 'rang'); // MC : rang N2 requis (boulots rentables plus tard)
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
    // Sans instru choisie : « Nuit à Ndo » (32, gratuite) + 4 du home studio.
    expect(m(s['cur'])['prod'], 36);
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
    expect([c['ev'], c['rep'], c['btq'], m(c['evDone'])['kzer']], [null, 8, 'kzer', 'a']);
    expect(m(c['ms'])['m3'], isNull);
    expect(act21(c, 'evc', 'a').err, 'rien');
    c = act21(c, 'battle', 2).s;
    expect([c['hour'], c['en'], c['rep'], c['fans'], c['cash'], c['xp']], [9, 85, 14, 270, 28000, 60]);
    c = act21(c, 'setui', 'title=Ndolo en feu').s;
    c = act21(c, 'create', ['quartier', 'sombre']).s;
    expect(m(c['cur'])['title'], 'Ndolo en feu');
    expect(m(c['ui'])['title'], '');
    c = act21(c, 'record').s;
    expect(m(c['ms'])['m1'], isNotNull);
    // L'offre de Kôrô est une scène de dialogue (plus un événement) déclenchée par le premier enregistrement.
    expect([c['ev'], m(c['dlg'])['id'], c['cash']], [null, 'kore', 33000]);
    final poor = clone21(c)..['cash'] = 100;
    c = act21(c, 'dch', 'a').s;
    expect(act21(poor, 'dch', 'a').s['dlg'], isNotNull);
    expect(act21(act21(poor, 'dch', 'a').s, 'dch', 'a').err, 'cash');
    c = act21(c, 'dch', 'b').s;
    c = act21(c, 'dch', 'a').s;
    expect([m(c['kc'])['left'], m(c['kc'])['bonus'], c['cash'], m(c['dlg'])['end']], [3, 12, 26000, 'Accord à 35 %']);
    c = act21(c, 'dclose').s;
    c = act21(c, 'release').s;
    expect(m(c['ms'])['m2'], isNotNull);
    c = act21(c, 'endDay').s;
    c = act21(c, 'create', ['quartier', 'sombre']).s;
    c = act21(c, 'record').s;
    // Sans instru choisie : « Nuit à Ndo » (32) + 12 de production Kôrô.
    expect([m(c['cur'])['prod'], m(c['kc'])['left']], [44, 2]);

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
    // L'open mic ne remplit plus la mission 3 : seul l'atelier la valide.
    a = act21(a, 'openmic').s;
    expect(m(a['ms'])['m3'], isNull);
    final c0 = a['cash'] as num, e0 = m(a['sk'])['ecr'] as num;
    a = act21(a, 'atelier').s;
    expect(m(a['ms'])['m3'], isNotNull);
    expect(m(a['sk'])['ecr'], e0 + 5);
    expect(a['cash'], c0 - 6000 + 4000);
    expect([a['hour'], a['en']], [11, 65]);
    expect(Reg21.missions[2], {'id': 'm3', 't': "Fais un atelier d'écriture", 'cash': 4000, 'xp': 60});
    expect(Reg21.ranks[2]['xp'], 1500);
    var b = act21(init21(), 'preset', 'carriere').s;
    b['signed'] = 1;
    b = act21(b, 'create').s;
    b = act21(b, 'record').s;
    b = act21(b, 'release').s;
    final t = m(l(b['disco']).first);
    // Écoutes et ventes : la part du label (35 %) est déduite des deux ; `cut` les additionne.
    final gross = jsRound((t['L'] as num) * Reg21.listenValue);
    final salesGross = (t['sales'] as num) * Reg21.salePrice;
    expect(t['streamRev'], jsRound(gross * (1 - Reg21.labelCut)));
    expect(t['salesRev'], jsRound(salesGross * (1 - Reg21.labelCut)));
    expect(t['rev'], (t['streamRev'] as num) + (t['salesRev'] as num));
    expect(t['cut'], (gross - (t['streamRev'] as num)) + (salesGross - (t['salesRev'] as num)));
    expect(t['cut'] as num, greaterThan(0));
    var x = act21(init21(), 'preset', 'debut').s;
    for (var d = 0; d < 7; d++) {
      x = act21(x, 'openmic').s;
      x = act21(x, 'endDay').s;
    }
    expect(x['rank'] as num, lessThan(3));
  });

  test('origine choisie, départ de carrière toujours à Ndolo', () {
    var s = act21(init21(), 'setp', 'name=Djo Kene').s;
    s = act21(s, 'setp', 'origin=tamarel').s;
    expect(act21(s, 'setp', 'origin=invalide').err, 'inconnu');
    s = act21(s, 'finish').s;
    expect([m(s['p'])['origin'], s['ev'], m(s['geo'])['tamarel']], ['tamarel', 'kzer', 4]);
    expect(l(s['log']).first['t'], contains('Bienvenue à Ndolo'));
  });

  test('studio : texte, instru payée au choix, trois prises, qualité 0,35 / 0,30 / 0,35', () {
    var s = act21(init21(), 'preset', 'debut').s;
    s = act21(s, 'create', ['quartier', 'sombre']).s;
    expect([m(s['cur'])['st'], s['hour'], s['en'], s['cash']], ['ecrit', 9, 80, 25000]);
    s = act21(s, 'pick', 'gbaka').s;
    expect([m(s['ui'])['inst'], s['cash']], ['gbaka', 17000]);
    expect(act21(s, 'pick', 'pont').err, 'rang');
    s = act21(s, 'record', [90, 80, 70]).s;
    final song = m(s['cur']);
    expect([song['st'], song['takes'], song['voix'], song['prod'], song['Q']], ['enregistre', [90, 80, 70], 80, 56, 69]);
    expect([s['hour'], s['en'], m(s['ui'])['inst']], [11, 55, null]);
    expect(song['prodBy'], 'DJ Kôrô (« Gbaka de 6h »)');
    expect(m(s['ms'])['m1'], isNotNull);
  });

  test('dix thèmes v20 gardés avec note de texte et viralité', () {
    const themes = ['rue', 'argent', 'ambition', 'amour', 'fete', 'ego', 'introspection', 'identite', 'trap', 'gloire'];
    expect(themes.every(Reg21.themes.containsKey), isTrue);
    for (final theme in themes) {
      final s = act21(init21(), 'create', [theme, 'sombre']).s;
      final song = m(s['cur']);
      expect(song['tx'], 72 + (Reg21.themes[theme]!['tx'] as int), reason: theme);
      expect(virOf21(song), greaterThan(Reg21.virBase), reason: theme);
    }
  });

  test('battle K-Zer conserve les issues v20', () {
    var win = act21(init21(), 'preset', 'debut').s;
    win = act21(win, 'evc', 'a').s;
    win = act21(win, 'battle', 3).s;
    expect([win['cash'], win['fans'], win['rep'], win['xp'], m(win['btl'])['win']], [28000, 270, 14, 60, 1]);
    var loss = act21(init21(), 'preset', 'debut').s;
    loss = act21(loss, 'evc', 'a').s;
    loss = act21(loss, 'battle', 1).s;
    // Défaite : +12 fans et 10 XP (engine21.js), pas de cachet.
    expect([loss['cash'], loss['fans'], loss['rep'], loss['xp'], m(loss['btl'])['win']], [25000, 132, 8, 10, 0]);
    expect([loss['btq'], m(loss['bt'])['w'], m(loss['bt'])['vs']], [null, 1, 'kzer']);
  });

  test('ventes des singles : 1,2 % des écoutes × 30 cauris, ajoutées aux revenus', () {
    var s = act21(init21(), 'create', 'random').s;
    s = act21(s, 'record').s;
    final cash0 = s['cash'] as num;
    s = act21(s, 'release').s;
    final song = m(l(s['disco']).first);
    final sales = jsRound((song['L'] as num) * 0.012);
    expect(song['sales'], sales);
    expect(song['salesRev'], sales * 30);
    expect(s['cash'], cash0 + (song['rev'] as num));
    expect(song['rev'], (song['streamRev'] as num) + sales * 30);
    expect(song['labelAt'], 'Indépendant');
    expect(song['auteur'], isA<String>());
  });

  test('managers M2 utilisent commission proposée et forfait au septième jour', () {
    final s = init21()..['rep'] = 15..['xp'] = 120;
    var hired = act21(s, 'hireManager', 'm2');
    expect(hired.err, isNull);
    expect(hired.s['mgr'], 'm2');
    hired.s['day'] = 7;
    final commissioned = act21(hired.s, 'concert');
    // Le rang du concert n’est pas requis ici, on vérifie la commission via un cachet open mic.
    final opened = act21(hired.s, 'openmic');
    expect(opened.err, isNull);
    expect(opened.s['cash'], 27700); // 3 000 − 10 %
    final charged = act21(hired.s, 'endDay');
    expect(charged.s['cash'], hired.s['cash']! - 1500);
    expect(commissioned.err, anyOf(isNull, 'rang'));
  });

  test('justice : contenu mature désactivé par défaut, arrestation, caution, avocat, procès, prison, sortie', () {
    var base = act21(init21(), 'preset', 'debut').s;
    expect(base['mature'], 0);
    expect(act21(base, 'crime', 'braquage').err, 'mature');
    base = must(base, 'mature', 'on');
    base['cash'] = 300000;
    base['heat'] = 80;
    // Premier jour où le braquage mène à une garde à vue (hasard déterministe : graine et jour).
    J? caught;
    for (var d = 1; d < 400 && caught == null; d++) {
      final r = act21(clone21(base)..['day'] = d, 'crime', 'braquage');
      if (r.s['cas'] != null) caught = r.s;
    }
    expect(caught, isNotNull);
    var s = caught!;
    expect([m(s['cas'])['stage'], s['hour'], m(s['cas'])['bail'], m(s['cas'])['lawyer']], ['garde', 24, 40000, 'office']);
    expect(run(s, 'job', 'livraison').err, 'garde');
    // Caution : libre jusqu'au procès, avocat confirmé, puis la peine tombe.
    final free = must(must(s, 'lawyer', 'conf'), 'bail');
    expect(m(free['cas'])['stage'], 'libre');
    expect(run(free, 'trial', 'nc').err, 'proces');
    free['day'] = (m(free['cas'])['trial'] as num);
    final judged = must(free, 'trial', 'nc');
    expect([judged['cas'], m(judged['verdict'])['lawyer']], [null, 'Maître Sandra Lobé']);
    // Détention provisoire : plus rien d'autre que les écrans de réglage, jusqu'à la sortie.
    final held = must(s, 'detention');
    expect(m(held['jail'])['pre'], 1);
    expect(run(held, 'job', 'livraison').err, 'prison');
    expect(run(held, 'concert').err, 'prison');
    final cell = must(must(held, 'jw'), 'js');
    expect(run(cell, 'jw').err, 'deja');
    expect(m(cell['sk'])['ecr'], (m(held['sk'])['ecr'] as num) + 2);
    var out = cell;
    for (var i = 0; i < 3; i++) {
      out = must(out, 'endDay');
    }
    expect(out['jail'], isNull);
    expect(run(out, 'job', 'livraison').err, isNull);
  });

  test('justice : un label rompt le contrat après une condamnation à de la prison', () {
    var s = act21(init21(), 'preset', 'debut').s;
    s['mature'] = 1;
    s['signed'] = 1;
    s['label'] = 'BLG';
    s['lcut'] = 0.4;
    s['lperk'] = 'scene';
    s['cas'] = {'crime': 'braquage', 'n': 'Braquage', 'ch': 'vol à main armée', 'sev': 4, 'day': 1, 'trial': 1, 'stage': 'libre', 'lawyer': 'office', 'bail': 40000};
    s = must(s, 'trial', 'coupable');
    expect(s['signed'], 0);
    expect([s['label'], s['lcut'], s['lperk']], [null, null, null]);
    expect(m(s['jail'])['days'], greaterThan(0));
    expect(l(s['casier']).length, 1);
  });

  test('battle multi-artistes applique les effets au rival choisi', () {
    final result = act21(init21(), 'rivalBattle', ['zaki', 3]);
    expect(result.err, isNull);
    expect([m(result.s['btl'])['rival'], m(result.s['rivals'])['zaki']['lastWin']], ['Zaki Mbela', 1]);
  });

  test('scènes artistes : discussion, provocation et apaisement font évoluer la relation', () {
    var s = act21(init21(), 'artistScene', ['zaki', 'discuter']).s;
    expect([m(m(s['rivals'])['zaki'])['relation'], m(m(s['rivals'])['zaki'])['tension'], s['hour'], s['en']], [5, 0, 9, 95]);
    s = act21(s, 'artistScene', ['zaki', 'provoquer']).s;
    expect([m(m(s['rivals'])['zaki'])['relation'], m(m(s['rivals'])['zaki'])['tension']], [0, 15]);
    s = act21(s, 'artistScene', ['zaki', 'apaiser']).s;
    expect([m(m(s['rivals'])['zaki'])['relation'], m(m(s['rivals'])['zaki'])['tension'], s['cash']], [8, 3, 23000]);
  });

  test('passer la journée copie les plateformes immuables avant les streams passifs', () {
    final s = init21();
    s['disco'] = [
      {
        'id': 'OLD1', 'title': 'Ancien single', 'day': 1, 'launchL': 10000,
        'L': 10000, 'rev': 0, 'cut': 0, 'signed': 0, 'views': 0,
        'platforms': Map.unmodifiable(<dynamic, dynamic>{'ondea': 7000, 'cauri': 3000}),
        'clip': Map.unmodifiable(<dynamic, dynamic>{'st': 'aucun'}),
      }
    ];
    final result = act21(s, 'endDay');
    expect(result.err, isNull);
    expect(result.s['day'], 2);
    expect(m(l(result.s['disco']).single)['L'], greaterThan(10000));
    expect(m(m(l(result.s['disco']).single)['platforms'])['ondea'], greaterThan(7000));
  });

  test('battle : indice de Flow, aucun dès le départ, une réponse écartée dès 20, le bon style annoncé dès 40', () {
    expect(Reg21.flowHintLevel(17), 0); // Flow de départ
    expect(Reg21.flowHintLevel(19), 0);
    expect(Reg21.flowHintLevel(20), 1);
    expect(Reg21.flowHintLevel(39), 1);
    expect(Reg21.flowHintLevel(40), 2);
    expect(Reg21.flowHintLevel(100), 2);
  });
}
