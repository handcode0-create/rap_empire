/* RAP EMPIRE v20 — moteur de DÉMONSTRATION (paramètres provisoires, non validés). Pur : aucune dépendance au DOM. */
(function (root, f) { if (typeof module === 'object' && module.exports) module.exports = f(); else root.RE = f(); })(this, function () {
  /* ===== ÉCONOMIE DE DÉMONSTRATION — PARAMÈTRES PROVISOIRES (D-08), centralisés ici, modifiables, NON VALIDÉS ===== */
  var ECON = {
    listenValue: 0.01,      // cauris par écoute monétisée (1 cauri pour 100 écoutes) — D-08
    monetised: 1,           // part des écoutes monétisées (démo : 100 %)
    labelCut: 0.20,         // commission du label sur les revenus musicaux nets du catalogue sous contrat — D-08
    nightCost: 0,           // nuit gratuite pendant la phase initiale — D-08
    labelAdvance: 150000,   // avance d'un contrat de label (08-2), versée à la signature
    fanSat: 5000,           // saturation de la conversion en fans (évite la croissance exponentielle) — test D-08
    listenCap: 15000000,    // plafond doux des écoutes hebdomadaires d'une sortie (≈ rang 1 : 12,4 M)
    mgrCut: 0.08,           // commission du manager M1 sur les cachets (19.1 : 8 % + 800 / sem. ; le fixe n'est pas prélevé en démo)
    featFee: 8000, featBoost: 1.15,   // featuring Nadia Kolo (08.3) : +15 % d'écoutes sur la prochaine sortie
    micro: 18000, concertFee: 25000, openMicFee: 3000, battleFee: 3000,
    levelReward: { 2: 2000, 3: 4000, 4: 8000, 5: 15000 }
  };
  var PROG = null;
  var LV = [0, 100, 250, 500, 900];                                     // XP des niveaux N1..N5
  var LVN = ['Inconnu', 'Espoir du quartier', 'Révélation locale', 'Nom qui circule', 'Star de Bakoma'];
  var LVR = ECON.levelReward;
  var INSTRU = {
    nuit: { id: 'nuit', name: 'Nuit à Ndo', who: 'Gratuite', Q: 32, price: 0, lvl: 1 },
    gbaka: { id: 'gbaka', name: 'Gbaka de 6h', who: 'DJ Kôrô', Q: 56, price: 8000, lvl: 1 },
    pont: { id: 'pont', name: 'Pont des Griots', who: 'Sanko Beats', Q: 68, price: 15000, lvl: 2 },
    lagune: { id: 'lagune', name: "Lagune d'Ambre", who: 'Mister Wôrô', Q: 86, price: 40000, lvl: 1, rep: 30 }
  };
  var MISSIONS = {
    m1: { t: 'Enregistre ton premier son', cash: 5000, xp: 50 },
    m2: { t: 'Sors ton premier single', cash: 10000, xp: 80 },
    m3: { t: "Fais un atelier d'écriture", cash: 4000, xp: 60 },
    m4: { t: 'Atteins 1 000 fans', cash: 15000, xp: 120 }
  };
  var STYLES = { drill: { n: 'Drill de Bakoma', k: 'flow' }, conscient: { n: 'Rap conscient', k: 'ecr' }, coupe: { n: 'Coupé-décalé rap', k: 'cha' }, trap: { n: 'Trap bakomaise', k: 'voix' } };
  var GOALS = { quartier: 'Être connu du quartier', label: 'Signer en label', stade: 'Remplir un stade' };
  var SHOP = { veste: { n: 'Veste Brume', p: 18000, l: 1 }, survet: { n: 'Survêt Soleil', p: 6000, l: 1 }, vestenuit: { n: 'Veste Nuit', p: 12000, l: 3 }, casquette: { n: 'Casquette Ndo', p: 4000, l: 1 }, chaine: { n: 'Chaîne dorée', p: 25000, l: 1 } };
  var PROMO = [{ n: 'Aucune', c: 0, m: 1 }, { n: 'Réseaux sociaux', c: 2000, m: 1.6 }, { n: 'Radio locale', c: 15000, m: 3.2 }];
  var K = 5420 / (9000 * 0.61), ENTRY = 252200;
  function fmt(n) { n = Math.round(n); var s = String(Math.abs(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ' '); return (n < 0 ? '-' : '') + s; }
  function lvlOf(xp) { var l = 1; for (var i = 0; i < LV.length; i++) if (xp >= LV[i]) l = i + 1; return l; }
  function init() {
    return { v: 1, cash: 25000, en: 100, day: 1, hour: 8, fans: 120, pop: 3, rep: 8, xp: 0, lvl: 1,
      sk: { flow: 17, ecr: 14, voix: 10, cha: 8 }, micro: false,
      inst: null, texte: null, takes: [], song: null, rel: null, pend: null,
      lw: 0, lc: 0, ms: { m1: 'todo', m2: 'todo', m3: 'todo', m4: 'todo' },
      led: [], cat: { manager: 0, label: 0, ecoutes: 0, cachets: 0, mission: 0, instru: 0, promo: 0, materiel: 0, formation: 0, boutique: 0, niveau: 0 },
      style: 'drill', goal: 'quartier', hood: 'Ndolo', ap: { skin: '3', hair: 'hitwist', beard: 'stubble', face: 'none', top: 'hoodie', shoes: 'sneak', acc: 'chain' }, outf: 0, nout: 4, kc: { st: '', rel: 0, cut: '', cost: 0, left: 0, bonus: 0 }, ct: null, dirf: 'all', fol: {}, offsel: 'BSR', mcmp: 'rosine', lr: 0, feat: 0, mg: 0, own: { hoodie: 1, tshirt: 1, jade: 1 }, om: null, bt: null, cc: null, ui: { promo: 0, kind: 'single', buy: null, set: { gbaka: 1, free: 1 } }, fgain: 0, t: 0 };
  }
  function norm(s) { var d = init(); for (var k in d) if (s[k] === undefined) s[k] = d[k]; for (var k2 in d.own) if (s.own[k2] === undefined && s.own === d.own) s.own[k2] = d.own[k2]; if (!s.ui.hasOwnProperty('buy')) s.ui.buy = null; if (s.cat.manager === undefined) s.cat.manager = 0; if (s.cat.label === undefined) s.cat.label = 0; return s; }
  function clone(s) { return JSON.parse(JSON.stringify(s)); }
  function pay(s, amt, cat, label) { s.cash += amt; if (s.cash < 0) s.cash = 0; s.led.unshift({ l: label, a: amt, c: cat, d: s.day }); if (cat) s.cat[cat] = (s.cat[cat] || 0) + amt; }
  function cachet(n, amt, label) { pay(n, amt, 'cachets', label); if (n.mg) { var c = Math.round(amt * ECON.mgrCut); pay(n, -c, 'manager', 'Manager Maya Tessé ' + Math.round(ECON.mgrCut * 100) + ' %'); } }
  function addXp(s, x) { s.xp += x; var n = lvlOf(s.xp); if (n > s.lvl) { s.pend = { lvl: n, reward: LVR[n] || 0 }; s.lvl = n; } }
  function tick(s, h) { s.hour += h; while (s.hour >= 24) { s.hour -= 24; s.day++; } }
  function listensFor(Q, fans, promo, feat) { var raw = (9000 + 6 * (fans - 120)) * PROMO[promo].m * (Q / 100) * K * (feat ? ECON.featBoost : 1); return Math.round(raw / (1 + raw / ECON.listenCap)); }
  function quality(texte, voix, prod, en) { var mal = Math.min(20, Math.max(0, 40 - en) / 2); return Math.max(0, Math.round(0.35 * texte + 0.30 * voix + 0.35 * prod - mal)); }
  function indexParts(a) {   // étude D-17 (sim_d17b, variante V2 : croissance absolue), échelles fixes 0-100 : PROVISOIRE
    function lg(x, ref, x0) { return 100 * Math.min(1, Math.log10(1 + Math.max(x, 0) / x0) / Math.log10(1 + ref / x0)); }
    var c = { f: lg(a.fans, 5e6, 1e3), g: lg(a.g, 200e3, 1e3), c: lg(a.cat, 30e6, 1e4), s: lg(a.sc, 2e6, 5e2), n: Math.min(100, a.n) };
    c.i = Math.round((0.25 * c.f + 0.15 * c.g + 0.30 * c.c + 0.20 * c.s + 0.10 * c.n) * 10) / 10; return c;
  }
  function fixedIndex(a) { return indexParts(a).i; }
  var A = {};
  A.reset = function () { return init(); };
  A.pick = function (s, id) {
    var i = INSTRU[id]; if (!i) return { s: s, err: 'inconnu' };
    if (i.lvl > s.lvl) return { s: s, err: 'niveau' };
    if (i.rep && s.rep < i.rep) return { s: s, err: 'rep' };
    if (s.cash < i.price) return { s: s, err: 'cash' };
    var n = clone(s); if (i.price) pay(n, -i.price, 'instru', 'Instru ' + i.name); n.inst = i; n.texte = null; n.takes = []; n.song = null; return { s: n };
  };
  A.write = function (s, theme, amb) {
    if (s.en < 20) return { s: s, err: 'energie' };
    var n = clone(s); n.en -= 20; tick(n, 1);
    var note = 72 + ({ sombre: 0, fiere: 2, legere: -2 })[amb || 'sombre'] + ({ quartier: 0, galere: 1, ambition: 2, amour: -1 })[theme || 'quartier'];
    n.texte = { note: note, theme: theme || 'quartier', amb: amb || 'sombre' }; n.sk.ecr += 2; return { s: n };
  };
  A.record = function (s, takes) {
    if (s.en < 25) return { s: s, err: 'energie' };
    var n = clone(s); n.en -= 25; tick(n, 2); takes = (takes && takes.length) ? takes.map(Number) : [74, 48, 43];
    var voix = Math.round(takes.reduce(function (a, b) { return a + b; }, 0) / takes.length) + (n.micro ? 8 : 0);
    var prod = (n.inst ? n.inst.Q : 32) + ((n.kc && n.kc.left > 0) ? n.kc.bonus : 0), tx = n.texte ? n.texte.note : 60;
    n.takes = takes; n.song = { title: n.inst && n.inst.id === 'nuit' ? 'Nuit à Ndo' : 'Gbaka de 6h', Q: quality(tx, voix, prod, s.en - 25 + 25), texte: tx, voix: voix, prod: prod, inst: n.inst ? n.inst.name : '' };
    n.song.Q = quality(tx, voix, prod, 100);   // forme : malus calculé à l'entrée en cabine ci-dessous
    var mal = Math.min(20, Math.max(0, 40 - s.en) / 2); n.song.Q = Math.max(0, Math.round(0.35 * tx + 0.30 * voix + 0.35 * prod - mal));
    if (n.kc && n.kc.left > 0) n.kc.left--; n.sk.voix += 1; addXp(n, 30); if (n.ms.m1 === 'todo') n.ms.m1 = 'done'; return { s: n };
  };
  A.claim = function (s, id) {
    var m = MISSIONS[id]; if (!m || s.ms[id] !== 'done') return { s: s, err: 'rien' };
    var n = clone(s); n.ms[id] = 'claimed'; pay(n, m.cash, 'mission', 'Mission : ' + m.t); addXp(n, m.xp); return { s: n };
  };
  A.promo = function (s, k) { var n = clone(s); n.ui.promo = +k; return { s: n }; };
  A.kind = function (s, k) { var n = clone(s); n.ui.kind = k; return { s: n }; };
  A.release = function (s) {
    if (!s.song) return { s: s, err: 'son' };
    var p = PROMO[s.ui.promo]; if (s.cash < p.c) return { s: s, err: 'cash' };
    var n = clone(s); if (p.c) pay(n, -p.c, 'promo', 'Promo : ' + p.n);
    var L = listensFor(n.song.Q, n.fans, n.ui.promo, n.feat), rev = Math.round(L * ECON.monetised * ECON.listenValue), fg = Math.ceil(L * 0.07 / (1 + n.fans / ECON.fanSat)), pg = Math.floor(L / 900);
    pay(n, rev, 'ecoutes', 'Écoutes · ' + n.song.title); if (n.ct) { var cut = Math.round(rev * ECON.labelCut); pay(n, -cut, 'label', 'Part label ' + Math.round(ECON.labelCut * 100) + ' %'); n.rel_cut = cut; } n.fans += fg; n.pop += pg; n.fgain += fg; n.lw = Math.round(L * 1.5); n.lc += L;
    n.rel = { title: n.song.title, L: L, rev: rev, fans: fg, pop: pg, promo: n.ui.promo, Q: n.song.Q };
    n.feat = 0; n.day += 1; n.hour = 8; n.en = 100; addXp(n, 40); if (n.ms.m2 === 'todo') n.ms.m2 = 'done';
    if (n.fans >= 1000 && n.ms.m4 === 'todo') n.ms.m4 = 'done'; return { s: n };
  };
  A.ack = function (s) { if (!s.pend) return { s: s }; var n = clone(s); if (n.pend.reward) pay(n, n.pend.reward, 'niveau', 'Niveau ' + n.pend.lvl); n.pend = null; return { s: n }; };
  A.formation = function (s, id) {
    var F = { ecr: { c: 6000, e: 20, h: 2, k: 'ecr', g: 5, m3: true }, flow: { c: 0, e: 15, h: 1, k: 'flow', g: 2 }, voix: { c: 9000, e: 20, h: 2, k: 'voix', g: 5 }, cha: { c: 7000, e: 15, h: 2, k: 'cha', g: 4 } }[id];
    if (!F) return { s: s, err: 'inconnu' }; if (s.cash < F.c) return { s: s, err: 'cash' }; if (s.en < F.e) return { s: s, err: 'energie' };
    var n = clone(s); n.en -= F.e; tick(n, F.h); if (F.c) pay(n, -F.c, 'formation', 'Formation'); n.sk[F.k] += F.g; if (F.m3 && n.ms.m3 === 'todo') n.ms.m3 = 'done'; return { s: n };
  };
  A.gear = function (s) { if (s.micro) return { s: s, err: 'deja' }; if (s.cash < ECON.micro) return { s: s, err: 'cash' }; var n = clone(s); pay(n, -ECON.micro, 'materiel', 'Micro studio'); n.micro = true; return { s: n }; };
  A.ignore = function (s) { if (s.ign) return { s: s }; var n = clone(s); n.pop += 2; n.ign = 1; return { s: n }; };
  A.sleep = function (s) { var n = clone(s); if (ECON.nightCost) pay(n, -ECON.nightCost, null, 'Nuit'); n.day += 1; n.hour = 8; n.en = 100; return { s: n }; };
  A.openmic = function (s) {
    if (s.en < 15) return { s: s, err: 'energie' };
    var n = clone(s); n.en -= 15; tick(n, 1); var win = s.en >= 40;
    if (win) { n.fans += 150; n.fgain += 150; n.rep += 6; cachet(n, ECON.openMicFee, 'Cachet open mic Ndolo'); addXp(n, 60); n.lw += 450; }
    else { n.fans += 12; n.fgain += 12; addXp(n, 10); }
    n.om = { win: win }; if (n.fans >= 1000 && n.ms.m4 === 'todo') n.ms.m4 = 'done'; return { s: n };
  };
  A.battle = function (s, score) {
    if (s.en < 15) return { s: s, err: 'energie' };
    var n = clone(s); n.en -= 15; tick(n, 1); var win = score >= 2;
    if (win) { n.fans += 150; n.fgain += 150; n.rep += 6; cachet(n, ECON.battleFee, 'Prime de battle'); addXp(n, 60); n.lw += 450; } else { n.fans += 12; n.fgain += 12; }
    n.bt = { win: win, score: score }; return { s: n };
  };
  A.concert = function (s, seq) {
    if (s.lvl < 3) return { s: s, err: 'niveau' }; if (s.en < 35) return { s: s, err: 'energie' };
    var n = clone(s); n.en -= 35; n.hour = 23; var crowd = 50, prev = '';
    (seq && seq.length ? seq : ['h', 'r', 'r']).forEach(function (a) { if (a === 'r') { crowd += 14 + (prev === 'h' ? 6 : 0); } else { crowd += 8; } prev = a; });
    var g = crowd >= 85 ? 'A' : crowd >= 70 ? 'B' : 'C', m = { A: 1, B: 0.7, C: 0.4 }[g], cm = { A: 1, B: 0.8, C: 0.5 }[g], rp = { A: 10, B: 6, C: 2 }[g];
    var fg = Math.round(520 * m), ca = Math.round(ECON.concertFee * cm);
    n.fans += fg; n.fgain += fg; n.rep += rp; cachet(n, ca, 'Cachet concert Le Parvis'); addXp(n, 90); n.lw += fg * 3;
    n.cc = { crowd: Math.min(100, crowd), g: g, fans: fg, cash: ca, rep: rp }; if (n.fans >= 1000 && n.ms.m4 === 'todo') n.ms.m4 = 'done'; return { s: n };
  };
  A.label = function (s) { var n = clone(s); if (n.ct) { n.ct = null; return { s: n }; } n.ct = { label: 'BSR', day: n.day }; pay(n, ECON.labelAdvance, 'label', 'Avance Bakoma Sound Records (démo)'); return { s: n }; };
  A.style = function (s, id) { var st = STYLES[id]; if (!st) return { s: s, err: 'inconnu' }; var n = clone(s); if (n.style && STYLES[n.style]) n.sk[STYLES[n.style].k] -= 3; n.style = id; n.sk[st.k] += 3; return { s: n }; };
  A.goal = function (s, id) { if (!GOALS[id]) return { s: s, err: 'inconnu' }; var n = clone(s); n.goal = id; return { s: n }; };
  var APN = { skin: ['Clair', 'Doré', 'Caramel', 'Mate', 'Brun', 'Brun foncé', 'Ébène', 'Nuit'], hair: { fade: 'Dégradé', afro: 'Afro', braids: 'Tresses', locks: 'Locks', cornrows: 'Nattes collées', knots: 'Bantu knots', hitwist: 'Twists hi-top', bald: 'Rasé' }, beard: { none: 'Aucune', stubble: 'Barbe de 3 jours', goatee: 'Bouc', full: 'Barbe pleine' }, top: { hoodie: 'Hoodie Néon', tee: 'T-shirt Lazuli', bomber: 'Bomber', blazer: 'Veste' }, shoes: { sneak: 'Baskets', high: 'Montantes', boots: 'Boots' }, acc: { chain: 'Chaîne dorée', cap: 'Casquette Ndo', none: 'Aucun' } };
  A.ap = function (s, arg) { var p = String(arg).split('='); if (p.length < 2) return { s: s, err: 'inconnu' }; var n = clone(s); n.ap[p[0]] = p[1]; return { s: n }; };
  A.outfit = function (s, id) { var n = clone(s); n.outf = Number(id); return { s: n }; };
  A.saveo = function (s) { if (s.nout >= 6) return { s: s, err: 'plein' }; var n = clone(s); n.nout++; n.outf = n.nout - 1; return { s: n }; };
  // scène A : producteur DJ Kôrô — choix à conséquences (valeurs de démo ; la part n'est pas appliquée aux revenus : économie D-08 à valider)
  var KD = { acc: { cut: '40 %', cost: 8000, rel: 15, bonus: 12, left: 3, st: 'acc' }, neg: { cut: '35 %', cost: 7000, rel: 8, bonus: 12, left: 3, st: 'neg' }, ins: { cut: '30 %', cost: 0, rel: -5, bonus: 0, left: 0, st: 'ref' }, ref: { cut: '', cost: 0, rel: -10, bonus: 0, left: 0, st: 'ref' },
    back: { cut: '45 %', cost: 6000, rel: 5, bonus: 12, left: 3, st: 'back' }, assist: { cut: 'tarif assistant', cost: 0, rel: 0, bonus: 6, left: 2, st: 'assist' }, decl: { cut: '', cost: 0, rel: -15, bonus: 0, left: 0, st: 'decl' } };
  A.kdeal = function (s, id) {
    var d = KD[id]; if (!d) return { s: s, err: 'inconnu' };
    if (s.kc.st === 'acc' || s.kc.st === 'neg' || s.kc.st === 'back' || s.kc.st === 'assist') return { s: s, err: 'accord' };
    if (s.cash < d.cost) return { s: s, err: 'cash' };
    var n = clone(s); if (d.cost) pay(n, -d.cost, 'instru', 'Studio Kôrô : accord'); var rel = (n.kc.rel || 0) + d.rel;
    n.kc = { st: d.st, rel: rel, cut: d.cut, cost: d.cost, left: d.left, bonus: d.bonus }; return { s: n };
  };
  A.hood = function (s, id) { var n = clone(s); n.hood = id; return { s: n }; };
  A.sign = function (s) { if (s.ct) return { s: s, err: 'deja' }; if (s.rep < 30) return { s: s, err: 'rep' }; return A.label(s); };
  A.refuse = function (s) { var n = clone(s); n.lr = 1; return { s: n }; };
  A.feat = function (s) { if (s.feat) return { s: s, err: 'deja' }; if (s.cash < ECON.featFee) return { s: s, err: 'cash' }; var n = clone(s); pay(n, -ECON.featFee, 'promo', 'Featuring Nadia Kolo'); n.feat = 1; return { s: n }; };
  A.dirf = function (s, id) { var n = clone(s); n.dirf = id; return { s: n }; };
  A.follow = function (s, id) { var n = clone(s); n.fol[id] = n.fol[id] ? 0 : 1; return { s: n }; };
  A.offsel = function (s, id) { var n = clone(s); n.offsel = id; return { s: n }; };
  A.mcmp = function (s, id) { var n = clone(s); n.mcmp = id; return { s: n }; };
  A.mgr = function (s) { var n = clone(s); n.mg = n.mg ? 0 : 1; return { s: n }; };
  A.ask = function (s, id) { if (!SHOP[id]) return { s: s, err: 'inconnu' }; var n = clone(s); n.ui.buy = id; return { s: n }; };
  A.buy = function (s, id) {
    id = id || s.ui.buy; var it = SHOP[id]; if (!it) return { s: s, err: 'inconnu' }; if (s.own[id]) return { s: s, err: 'deja' };
    if (s.lvl < it.l) return { s: s, err: 'niveau' }; if (s.cash < it.p) return { s: s, err: 'cash' };
    var n = clone(s); pay(n, -it.p, 'boutique', it.n); n.own[id] = 1; n.ui.buy = null; return { s: n };
  };
  A.setl = function (s, k) { var n = clone(s); n.ui.set[k] = n.ui.set[k] ? 0 : 1; return { s: n }; };
  function act(s, name, arg) { s = norm(s); var f = A[name]; if (!f) return { s: s, err: 'inconnu' }; var r = f(s, arg); r.s.t = Date.now(); return r; }
  function view(s) {
    s = norm(s);
    var lvl = s.lvl, lo = LV[lvl - 1], hi = LV[lvl] || LV[LV.length - 1] + 600, pct = Math.max(0, Math.min(100, Math.round(100 * (s.xp - lo) / (hi - lo))));
    var hh = (s.hour < 10 ? '0' : '') + s.hour + ':00';
    var gain28 = s.fgain;   // D-17 V2 : croissance ABSOLUE (fans gagnés), pas en %
    var ip = indexParts({ fans: s.fans, g: gain28, cat: s.lc, sc: (s.cc ? 300 : 0) + (s.om && s.om.win ? 60 : 0), n: s.pop }), idx = ip.i;
    function d1(x) { return String(Math.round(x * 10) / 10).replace('.', ','); }
    var rank = s.lw >= ENTRY ? 100 : null, gap = Math.max(0, ENTRY - s.lw);
    var ms = s.ms, st = !s.song ? 'studio' : !s.rel ? 'sortir' : (!s.om && !s.bt) ? 'scene' : !s.cc ? (s.lvl >= 3 ? 'concert' : 'scene') : 'label';
    var r = s.rel || {}, cc = s.cc || {}, ccg = cc.g || '';
    var mv = {}; ['m1', 'm2', 'm3', 'm4'].forEach(function (k) { ['todo', 'done', 'claimed'].forEach(function (z) { mv[k + '_' + z] = ms[k] === z; }); });
    var out = {
      cash: fmt(s.cash), en: String(s.en), time: 'J' + s.day + ' ' + hh, lvlTag: 'N' + lvl + ' · ' + LVN[lvl - 1].toUpperCase(), lvlName: LVN[lvl - 1], lvlN: 'N' + lvl,
      xpPct: pct, xp: String(s.xp), xpNext: String(hi), xpLeft: String(Math.max(0, hi - s.xp)), nextName: LVN[lvl] || 'Légende',
      fans: fmt(s.fans), pop: String(s.pop), rep: String(s.rep), repPct: Math.min(100, Math.round(100 * s.rep / 30)),
      flow: String(s.sk.flow), ecr: String(s.sk.ecr), voix: String(s.sk.voix), cha: String(s.sk.cha),
      rank: rank ? '#' + rank : 'Non classé', lw: fmt(s.lw), gap: fmt(gap), gapPct: Math.min(100, Math.round(100 * s.lw / ENTRY * 10) / 10), entry: fmt(ENTRY), idx: String(idx).replace('.', ','), nF: d1(ip.f), nG: d1(ip.g), nC: d1(ip.c), nS: d1(ip.s), nN: d1(ip.n),
      lowEn: s.en < 20, hasSong: !!s.song, noSong: !s.song, lv3: s.lvl >= 3, nolv3: s.lvl < 3, pend: !!s.pend,
      songT: s.song ? s.song.title : '', songQ: s.song ? String(s.song.Q) : '', songTx: s.song ? String(s.song.texte) : '', songVx: s.song ? String(s.song.voix) : '', songPr: s.song ? String(s.song.prod) : '',
      stage: st, st_studio: st === 'studio', st_sortir: st === 'sortir', st_scene: st === 'scene', st_concert: st === 'concert', st_label: st === 'label',
      instN: s.inst ? s.inst.name : '', instQ: s.inst ? String(s.inst.Q) : '', note: s.texte ? String(s.texte.note) : '',
      micro: !!s.micro, noMicro: !s.micro, predL: s.song ? fmt(listensFor(s.song.Q, s.fans, s.ui.promo, s.feat)) : '0', predRev: s.song ? fmt(Math.round(listensFor(s.song.Q, s.fans, s.ui.promo, s.feat) * ECON.monetised * ECON.listenValue)) : '0', omWin: !!(s.om && s.om.win), btWin: !!(s.bt && s.bt.win), mLabel: s.ms.m4 === 'claimed' ? 'Récupérée' : s.ms.m4 === 'done' ? 'À récupérer' : '',
      rL: fmt(r.L || 0), rRev: fmt(r.rev || 0), rFans: fmt(r.fans || 0), rPop: String(r.pop || 0), hasRel: !!s.rel, noRel: !s.rel,
      ccG: ccg, ccFans: fmt(cc.fans || 0), ccCash: fmt(cc.cash || 0), ccRep: String(cc.rep || 0), ccCrowd: String(cc.crowd || 0),
      day: String(s.day), spent: fmt(-(s.cat.instru + s.cat.promo + s.cat.materiel + s.cat.formation + s.cat.boutique)), earned: fmt(s.cat.ecoutes + s.cat.cachets + s.cat.mission + s.cat.niveau),
      pendN: s.pend ? 'N' + s.pend.lvl : '', pendName: s.pend ? LVN[s.pend.lvl - 1] : '', pendR: s.pend ? fmt(s.pend.reward) : '0',
      promoN: PROMO[s.ui.promo].n, promoC: fmt(PROMO[s.ui.promo].c), promoC0: s.ui.promo === 0, promoCbig: PROMO[s.ui.promo].c >= 15000, cashAfter: fmt(s.cash - PROMO[s.ui.promo].c),
      m1: ms.m1, m2: ms.m2, m3: ms.m3, m4: ms.m4, m4pct: Math.min(100, Math.round(s.fans / 10)), msOpen: ['m1', 'm2', 'm3', 'm4'].filter(function (k) { return ms[k] === 'todo'; }).length,
      msDone: ['m1', 'm2', 'm3', 'm4'].filter(function (k) { return ms[k] === 'done'; }).length,
      dirAll: s.dirf === 'all', dirSig: s.dirf === 'sig', dirInd: s.dirf === 'ind', dirEmg: s.dirf === 'emg', fol_laz: !!s.fol.laz, nofol_laz: !s.fol.laz, nFol: String(Object.keys(s.fol).filter(function (k) { return s.fol[k]; }).length), offBSR: s.offsel === 'BSR', offAUB: s.offsel === 'AUB', offNUG: s.offsel === 'NUG', offName: ({ BSR: 'Bakoma Sound Records', AUB: 'Aube Nouvelle', NUG: 'Ndolo Underground' })[s.offsel], offBsr: s.offsel === 'BSR', offOther: s.offsel !== 'BSR', mcRos: s.mcmp === 'rosine', mcAns: s.mcmp === 'anselme', mcOther: s.mcmp !== 'rosine' && s.mcmp !== 'anselme', cEco: fmt(s.cat.ecoutes), cCac: fmt(s.cat.cachets), cMis: fmt(s.cat.mission), cNiv: fmt(s.cat.niveau), cIns: fmt(s.cat.instru), cPro: fmt(s.cat.promo), cMat: fmt(s.cat.materiel), cFor: fmt(s.cat.formation), cMgr: fmt(s.cat.manager), cBou: fmt(s.cat.boutique), mg: !!s.mg, noMg: !s.mg, feat: !!s.feat, noFeat: !s.feat, offer: s.rep >= 30 && !s.ct && !s.lr, labelLocked: s.rep < 30 && !s.ct, repLeft: String(Math.max(0, 30 - s.rep)), refused: !!s.lr && !s.ct, styleName: STYLES[s.style].n, goalName: GOALS[s.goal], hoodName: s.hood, repMab: String(3 + (s.bt && s.bt.win ? 6 : 0)), repKot: '0', featCash: fmt(ECON.featFee), mgrPct: Math.round(ECON.mgrCut * 100) + ' %', buyName: s.ui.buy ? SHOP[s.ui.buy].n : '', buyPrice: s.ui.buy ? fmt(SHOP[s.ui.buy].p) : '0', buyAfter: s.ui.buy ? fmt(s.cash - SHOP[s.ui.buy].p) : fmt(s.cash), buyOk: !!s.ui.buy && s.cash >= SHOP[s.ui.buy].p, buyKo: !!s.ui.buy && s.cash < SHOP[s.ui.buy].p, lockN3: s.lvl < 3, unN3: s.lvl >= 3, own_veste: !!s.own.veste, no_veste: !s.own.veste, own_survet: !!s.own.survet, no_survet: !s.own.survet, own_vestenuit: !!s.own.vestenuit, no_vestenuit: !s.own.vestenuit, own_casquette: !!s.own.casquette, no_casquette: !s.own.casquette, own_chaine: !!s.own.chaine, no_chaine: !s.own.chaine, apSkin: APN.skin[Number(s.ap.skin)], apHair: APN.hair[s.ap.hair], apBeard: APN.beard[s.ap.beard], apTop: APN.top[s.ap.top], apShoes: APN.shoes[s.ap.shoes], apAcc: APN.acc[s.ap.acc], nout: String(s.nout), ou0: s.nout > 0, ou1: s.nout > 1, ou2: s.nout > 2, ou3: s.nout > 3, ou4: s.nout > 4, ou5: s.nout > 5, nu0: s.nout <= 0, nu1: s.nout <= 1, nu2: s.nout <= 2, nu3: s.nout <= 3, nu4: s.nout <= 4, nu5: s.nout <= 5, noutLeft: String(6 - s.nout), noutFree: s.nout < 6, noutFull: s.nout >= 6, outName: ['Studio', 'Scène', 'Street', 'Soirée', 'Studio 2', 'Scène 2'][s.outf] || 'Tenue', kcSt: ({ acc: 'Accord à 40 %', neg: 'Accord à 35 % (mix signé)', ref: 'Refus : il se souvient', back: 'Accord à 45 %', assist: 'Via son assistant', decl: 'Refus définitif' })[s.kc.st] || 'Aucun accord', kcCut: s.kc.cut || '–', kcCost: fmt(s.kc.cost), kcRel: (s.kc.rel > 0 ? '+' : '') + s.kc.rel, kcBonus: s.kc.left > 0 ? '+' + s.kc.bonus + ' production · ' + s.kc.left + ' titre' + (s.kc.left > 1 ? 's' : '') : 'aucun', kcOpen: !s.kc.st, kcDone: ['acc', 'neg', 'back', 'assist'].indexOf(s.kc.st) > -1, kcRef: s.kc.st === 'ref', kcCan8: s.cash >= 8000, cLab: fmt(s.cat.label), ct: !!s.ct, noCt: !s.ct, labelPct: Math.round(ECON.labelCut*100)+' %', listenV: String(ECON.listenValue).replace('.',','), per100: String(Math.round(ECON.listenValue*100*100)/100).replace('.',','), relCut: fmt(s.rel_cut||0), relNet: fmt(((s.rel&&s.rel.rev)||0)-(s.rel_cut||0))
    };
    for (var q in mv) out[q] = mv[q];
    return out;
  }
  var CANON = [  // parcours de démonstration : [nom de l'étape, action, argument]
    ['start', null], ['pick', 'pick', 'gbaka'], ['write', 'write', ['quartier', 'sombre']], ['rec', 'record', [74, 48, 43]],
    ['m1', 'claim', 'm1'], ['release', 'release'], ['lvl2', 'ack'], ['m2', 'claim', 'm2'], ['open', 'openmic'], ['lvl3', 'ack'], ['concert', 'concert', ['h', 'r', 'r']]
  ];
  function canon() {
    var s = init(), out = {}; out.start = clone(s);
    CANON.slice(1).forEach(function (c) {
      var a = c[2]; var r = c[1] === 'write' ? A.write(s, a[0], a[1]) : act(s, c[1], a); s = r.s; s.t = 0; out[c[0]] = clone(s);
    }); return out;
  }
  return { init: init, act: act, view: view, canon: canon, fmt: fmt, INSTRU: INSTRU, MISSIONS: MISSIONS, PROMO: PROMO, LV: LV, LVN: LVN, listensFor: listensFor, ENTRY: ENTRY, ECON: ECON, A: A };
});
/* RAP EMPIRE v20 — liaison DOM du prototype. Amélioration progressive : sans stockage ni script, chaque écran affiche les valeurs de la démo canonique. */
(function () {
  try {
    var KEY = 're20', TTL = 30 * 60 * 1000, RE = window.RE;
    function store(op, v) {
      var r = null;
      try { r = op === 'g' ? localStorage.getItem(KEY) : (v === null ? localStorage.removeItem(KEY) : localStorage.setItem(KEY, v)); if (op === 'g' && r) return r; if (op !== 'g') return; } catch (e) {}
      try { r = op === 'g' ? sessionStorage.getItem(KEY) : (v === null ? sessionStorage.removeItem(KEY) : sessionStorage.setItem(KEY, v)); if (op === 'g' && r) return r; if (op !== 'g') return; } catch (e) {}
      try {
        if (op === 'g') { var m = (window.name || '').match(/re20=(\{.*\})$/); return m ? m[1] : null; }
        window.name = v === null ? '' : 're20=' + v;
      } catch (e) {}
      return null;
    }
    function load() { var j = store('g'); if (!j) return null; try { var s = JSON.parse(j); if (!s || !s.t || Date.now() - s.t > TTL) return null; return s; } catch (e) { return null; } }
    function save(s) { s.t = Date.now(); store('s', JSON.stringify(s)); }
    var S = load(), base = null, scr = null;
    function snap() { if (S) return S; if (!scr) scr = document.querySelector('.scr'); if (!base && scr && scr.getAttribute('data-snap')) { try { base = JSON.parse(decodeURIComponent(escape(atob(scr.getAttribute('data-snap'))))); } catch (e) {} } return base || RE.init(); }
    function toast(msg) {
      var t = document.createElement('div'); t.className = 'toast e top'; t.setAttribute('role', 'alert'); t.textContent = msg;
      var h = document.querySelector('.scr'); if (!h) return; h.appendChild(t); setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 2200);
    }
    var ERR = { cash: 'Cash insuffisant', energie: 'Énergie insuffisante : dors ou récupère', niveau: 'Niveau requis', rep: 'Réputation requise', son: 'Aucun son prêt à sortir', deja: 'Déjà acheté', accord: 'Accord déjà conclu avec Kôrô', plein: 'Garde-robe pleine (6 tenues)', rien: 'Rien à récupérer' };
    function get(o, p) { return p.split('.').reduce(function (a, k) { return a == null ? a : a[k]; }, o); }
    function render() {
      var SS = S || snap(); var v = RE.view(SS), i, els;
      els = document.querySelectorAll('[data-b]'); for (i = 0; i < els.length; i++) { var k = els[i].getAttribute('data-b'); if (v[k] !== undefined) els[i].textContent = v[k]; }
      els = document.querySelectorAll('[data-w]'); for (i = 0; i < els.length; i++) { var w = v[els[i].getAttribute('data-w')]; if (w !== undefined) els[i].style.width = w + '%'; }
      els = document.querySelectorAll('[data-if]'); for (i = 0; i < els.length; i++) { var r = els[i].getAttribute('data-if'), neg = r.charAt(0) === '!'; var val = !!v[neg ? r.slice(1) : r]; if (neg) val = !val; if (val) els[i].removeAttribute('hidden'); else els[i].setAttribute('hidden', ''); }
      els = document.querySelectorAll('[data-hr]'); for (i = 0; i < els.length; i++) { var p = els[i].getAttribute('data-hr').split('|'), kv = p[0].split('='); els[i].setAttribute('href', ((String(v[kv[0]]) === kv[1]) ? p[1] : p[2]) + '.dc.html'); }
      els = document.querySelectorAll('[data-on]'); for (i = 0; i < els.length; i++) { var q = els[i].getAttribute('data-on').split('='); if (String(get(SS, q[0])) === q[1]) els[i].classList.add('sel'); else els[i].classList.remove('sel'); }
    }
    function run(spec) {
      var c = spec.indexOf(':'), name = c < 0 ? spec : spec.slice(0, c), arg = c < 0 ? undefined : spec.slice(c + 1);
      if (name === 'reset') { store('s', null); S = null; base = null; return { ok: true }; }
      if (arg !== undefined && arg.indexOf(',') > -1) arg = arg.split(','); 
      if (name === 'write' && !Array.isArray(arg)) arg = [arg];
      var cur = snap(), r;
      if (name === 'write') r = RE.act(cur, 'write', [arg[0], arg[1]]); else r = RE.act(cur, name, arg);
      if (name === 'write' && r.s) { r.s.t = Date.now(); }
      if (r.err) { toast(ERR[r.err] || 'Action impossible'); return { ok: false }; }
      S = r.s; save(S); render(); return { ok: true };
    }
    window.RE20 = { run: run, state: function () { return snap(); }, render: render, toast: toast };
    document.addEventListener('click', function (e) {
      var t = e.target && e.target.closest ? e.target.closest('[data-act],[data-sel]') : null; if (!t) return;
      var spec = t.getAttribute('data-act') || t.getAttribute('data-sel'), sel = !t.getAttribute('data-act');
      var specs = spec.split(';'), ok = true;
      for (var i = 0; i < specs.length && ok; i++) ok = run(specs[i]).ok;
      if (!ok || sel) { e.preventDefault(); e.stopPropagation(); }
    }, true);
    /* mini-jeu de cabine */
    function mini() {
      var el = document.getElementById('mg'); if (!el) return;
      var cur = el.querySelector('.mg-cur'), zone = el.querySelector('.mg-zone'), btn = document.getElementById('mg-rec'), msg = document.getElementById('mg-msg'), nxt = document.getElementById('mg-next');
      var ZC = [0.62, 0.34, 0.72], takes = [], t0 = Date.now(), done = false, p = 0;
      function zc() { return ZC[takes.length % 3]; }
      function place() { zone.style.left = (zc() * 100 - 8) + '%'; }
      place();
      function loop() { if (done) return; var t = (Date.now() - t0) / 1000 * 0.85; p = Math.abs(((t % 2) + 2) % 2 - 1); cur.style.left = (p * 100) + '%'; requestAnimationFrame(loop); }
      requestAnimationFrame(loop);
      btn.addEventListener('click', function (e) {
        e.preventDefault(); e.stopPropagation(); if (done) return;
        var sc = Math.max(0, Math.round(100 - Math.abs(p - zc()) * 230)); takes.push(sc);
        var n = takes.length, chip = el.querySelector('.mg-t' + n); if (chip) { chip.textContent = 'Prise ' + n + ' · ' + sc; chip.classList.add('on'); }
        if (msg) msg.textContent = sc >= 70 ? 'Prise propre' : sc >= 45 ? 'Prise correcte' : 'Prise ratée, mais gardée';
        if (n >= 3) { done = true; var r = RE.act(snap(), 'record', takes); if (r.err) { toast(ERR[r.err]); done = false; takes = []; return; } S = r.s; save(S); if (nxt) setTimeout(function () { nxt.click(); }, 700); }
        else { t0 = Date.now(); place(); }
      }, true);
    }
    /* séquences : concert et battle */
    function seq() {
      var el = document.getElementById('sq'); if (!el) return; var kind = el.getAttribute('data-sq'), N = 3, picks = [], nxt = document.getElementById('sq-next'), nxtL = document.getElementById('sq-lose');
      var meter = el.querySelector('.sq-fill'), val = el.querySelector('.sq-val'), steps = el.querySelectorAll('.sq-step'), crowd = 50, prev = '', wins = 0;
      var KZ = ['malin', 'agressif', 'cool'];
      var btns = el.querySelectorAll('[data-pick]');
      for (var i = 0; i < btns.length; i++) btns[i].addEventListener('click', function (e) {
        e.preventDefault(); e.stopPropagation(); if (picks.length >= N) return; var pk = this.getAttribute('data-pick'); picks.push(pk);
        if (kind === 'concert') { crowd += pk === 'r' ? 14 + (prev === 'h' ? 6 : 0) : 8; prev = pk; if (meter) meter.style.width = Math.min(100, crowd) + '%'; if (val) val.textContent = Math.min(100, crowd); }
        else { var win = pk === KZ[picks.length - 1]; if (win) wins++; if (meter) meter.style.width = (wins / N * 100) + '%'; if (val) val.textContent = wins + ' / ' + N; var line = el.querySelector('.sq-res' + picks.length); if (line) line.textContent = win ? 'Round gagné' : 'Round perdu'; }
        for (var j = 0; j < steps.length; j++) { if (j < picks.length) steps[j].classList.add('on'); }
        var nn = el.querySelector('.sq-n'); if (nn) nn.textContent = Math.min(N, picks.length + 1);
        if (picks.length >= N) {
          var r = kind === 'concert' ? RE.act(snap(), 'concert', picks) : RE.act(snap(), 'battle', wins);
          if (r.err) { toast(ERR[r.err]); picks = []; return; } S = r.s; save(S);
          var go = kind === 'battle' && wins < 2 ? nxtL : nxt; if (go) setTimeout(function () { go.click(); }, 600);
        }
      });
    }
    function auto() { var a = document.querySelector('[data-auto]'); if (!a) return; var p = a.getAttribute('data-auto').split('|'); setTimeout(function () { location.href = p[1] + '.dc.html'; }, +p[0]); }
    var inited = false;
    function ready() { if (!document.querySelector('.scr')) return false; render(); if (!inited) { inited = true; mini(); seq(); auto(); } return true; }
    var tries = 0, tm = setInterval(function () { tries++; ready(); if (tries > 30) clearInterval(tm); }, 100);
  } catch (err) { /* le prototype reste lisible sans script */ }
})();
