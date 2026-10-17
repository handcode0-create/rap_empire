/* RAP EMPIRE v21 — moteur de DÉMONSTRATION de la zone de consolidation (section 21).
   Pur : aucune dépendance au DOM. État simulé et conservé dans le navigateur : ce n'est PAS une sauvegarde réelle (D-09).
   Toutes les valeurs de REG sont des PARAMÈTRES PROVISOIRES [PROPOSÉ], centralisés ici et sur la planche 21-00b. */
(function (root, f) { if (typeof module === 'object' && module.exports) module.exports = f(); else root.RE21 = f(); })(this, function () {
  var REG = {
    // temps et âge — D-G01, D-G11
    daysPerYear: 364,          // 52 semaines × 7 jours (D-03 validé) [DÉDUIT]
    startAge: 19,              // [PROPOSÉ]
    dayStart: 8, dayEnd: 24,   // la journée ne se termine que sur décision du joueur (D-G11)
    enMaxByAge: [[0, 100], [30, 95], [40, 88], [50, 80], [60, 72]],   // [PROPOSÉ] énergie max selon l'âge
    babyMorning: 5,            // énergie de départ réduite tant qu'un bébé est au foyer [PROPOSÉ]
    // petits boulots — D-G02
    jobs: {
      livraison: { n: 'Livraison à moto · Ndolo', h: 4, e: 25, cash: 3500, need: 'Aucune condition' },
      maquis: { n: 'Service au maquis Le Couplet', h: 5, e: 30, cash: 4500, need: 'Aucune condition' },
      mc: { n: 'Animateur de soirée (MC)', h: 3, e: 20, cash: 6000, cha: 8, need: 'Charisme 8' }
    },
    // entreprises — D-G02 (revenus ESTIMÉS, jamais garantis)
    biz: {
      couplet: { n: 'Maquis Le Couplet (parts)', rank: 3, cost: 250000, lo: 3000, hi: 5000 },
      agence: { n: 'Agence événementielle', rank: 4, cost: 600000, lo: 7000, hi: 12000 },
      studioq: { n: 'Studio de quartier', rank: 5, cost: 1200000, lo: 12000, hi: 20000 }
    },
    // patrimoine — D-G08 : un effet DISTINCT par bien
    assets: {
      moto: { n: 'Moto', cost: 60000, eff: '−5 énergie sur chaque boulot, concert et tournée' },
      appart: { n: 'Appartement à Lumbé', cost: 350000, upkeep: 2000, eff: '+5 énergie max ; entretien 2 000 / jour' },
      homestudio: { n: 'Home studio', cost: 180000, eff: 'Enregistrement : −10 énergie et +4 production' },
      terrain: { n: 'Terrain à Sélène', cost: 500000, lo: 1000, hi: 2000, eff: 'Loyer estimé 1 000 à 2 000 / jour' }
    },
    // création musicale — D-G03, D-G09
    themes: { quartier: { n: 'Le quartier', tx: 0, vir: 10 }, galere: { n: 'La galère', tx: 1, vir: 6 }, ambition: { n: "L'ambition", tx: 2, vir: 12 }, amour: { n: "L'amour", tx: -1, vir: 14 } },
    ambs: { sombre: { n: 'Sombre', tx: 0, vir: 0 }, fiere: { n: 'Fière', tx: 2, vir: 4 }, legere: { n: 'Légère', tx: -2, vir: 8 } },
    virBase: 20, promoVir: [0, 5, 12], clipVir: 15,
    feats: {   // données existantes 08.3 et 16-G ; rôles et effets [PROPOSÉ]
      nadia: { n: 'Nadia Kolo', role: 'Refrain chanté', cost: 8000, q: 2, vir: 6, boost: 1.15, need: null },
      ayana: { n: 'Ayana Dembé', role: 'Refrain afro-soul', cost: 0, share: 50, q: 4, vir: 8, boost: 1.10, need: { pop: 8 } },
      orage: { n: 'Madame Orage', role: 'Couplet invité', cost: 25000, q: 5, vir: 10, boost: 1.25, need: { pop: 30 } },
      zaki: { n: 'Zaki Mbela', role: 'Couplet invité', cost: 40000, q: 5, vir: 12, boost: 1.3, need: { rival: true } }
    },
    maxFeats: 2,
    tiers: [[0, 'Discret'], [10000, 'Correct'], [50000, 'Bon'], [252200, 'Hit · entre au Top 100']],   // 252 200 = R25 (D-16 A)
    // clips — D-G04
    directors: {
      sika: { n: 'Sika Nébo', lv: 'Réalisatrice débutante', cost: 15000, vir: 8, rank: 1 },
      ombre: { n: 'Collectif Ombre Bleue', lv: 'Collectif confirmé', cost: 40000, vir: 15, rank: 2 },
      ilan: { n: 'Ilan Mabé', lv: 'Réalisateur reconnu', cost: 120000, vir: 25, rank: 4 }
    },
    shootE: 30, shootH: 6, clipBoost: 0.25,
    // rang de carrière — D-G05 (noms N1..N6 existants ; seuils relevés le 16/10 par Smith, valeurs provisoires ; conditions [PROPOSÉ])
    ranks: [
      { n: 'Inconnu', xp: 0, cond: null },
      { n: 'Espoir du quartier', xp: 100, cond: null },
      { n: 'Révélation locale', xp: 1500, cond: { singles: 1 }, cl: '1 single sorti' },
      { n: 'Nom qui circule', xp: 3200, cond: { pop: 20, shows: 1 }, cl: 'popularité 20 et 1 concert' },
      { n: 'Star de Bakoma', xp: 6000, cond: { fans: 10000, bon: 1 }, cl: '10 000 fans et 1 titre « Bon »' },
      { n: 'Légende', xp: 12000, cond: { fans: 100000, hit: 1 }, cl: '100 000 fans et 1 hit' }
    ],
    // labels et merchandising — D-G06 (création de label : D-05 validé, provisoire)
    merch: {
      tshirt: { n: 'T-shirts Ndo City', cost: 20000, days: 14, perFan: 0.8, need: { fans: 1000, singles: 1 }, cl: '1 000 fans et 1 single sorti' },
      capsule: { n: 'Collection capsule', cost: 100000, days: 21, perFan: 1.5, need: { fans: 10000, rank: 4 }, cl: '10 000 fans et rang N4' }
    },
    labelRep: 30, ownLabel: { rep: 60, cash: 500000, mgr: 'M3' },
    // scène et géographie — D-G12 (villes et continents fictifs existants ; regroupement en continents [PROPOSÉ])
    cities: { bakoma: 'Bakoma', portambre: 'Port-Ambre', selene: 'Sélène', tamarel: 'Tamarel', korvane: 'Korvane', aldera: 'Aldéra' },
    conts: { solo: { n: 'Rives de Sôlo', c: ['bakoma', 'portambre', 'selene'] }, tam: { n: 'Terres de Tamarel', c: ['tamarel'] }, kor: { n: 'Nord de Korvane', c: ['korvane'] }, ald: { n: "Archipel d'Aldéra", c: ['aldera'] } },
    tour: { n: 'Tournée régionale (Port-Ambre, Sélène)', rank: 3, e: 50, h: 10, cost: 30000, fee: 20000, feeGeo: 2500, fans: 600, geo: 8 },
    intl: { n: 'Date à Tamarel Open Air', rank: 5 },
    // relations et famille — D-G07 (règles validées ; seuils PROPOSÉS)
    romPerDay: 2,                       // VALIDÉ
    romActs: {
      parler: { n: 'Discuter', g: 4, h: 1, e: 5, c: 0 },
      sortie: { n: 'Sortie au maquis', g: 8, h: 3, e: 10, c: 3000 },
      cadeau: { n: 'Offrir un cadeau', g: 6, h: 1, e: 0, c: 5000 },
      scene: { n: 'Inviter à ton concert', g: 7, h: 2, e: 10, c: 0 }
    },
    likeMul: 1.5, dislikeMul: 0.5,
    decayCourt: 1, decayCouple: 2,      // baisse quotidienne sans entretien [PROPOSÉ]
    officialAt: 60, proposeAt: 80, proposeMinDays: 14, refuseCooldown: 14, refuseLoss: 12, warnAt: 30, leaveAt: 20, exBlockDays: 30,
    weddings: { simple: { n: 'Cérémonie simple', cost: 50000, g: 8, pop: 0 }, fete: { n: 'Grande fête de quartier', cost: 150000, g: 12, pop: 3 } },
    kidChance: 0.25,                    // chance par jour une fois le projet d'enfant décidé (démo) [PROPOSÉ]
    coupleCost: 1000, kidCost: 1500, maxKids: 2,
    stages: [[0, 'Bébé'], [1, 'Petite enfance'], [6, 'Enfant'], [12, 'Adolescent'], [18, 'Adulte']],
    kidActs: {
      jouer: { n: 'Jouer ensemble', l: 6, h: 1, e: 10, min: 0 },
      histoire: { n: 'Lire une histoire', l: 4, h: 1, e: 5, min: 1 },
      devoirs: { n: 'Aider aux devoirs', l: 7, h: 2, e: 10, min: 6 },
      studio: { n: "L'emmener au studio", l: 8, h: 2, e: 10, min: 6 }
    },
    // création de l'artiste — styles, quartiers et objectifs EXISTANTS (02.5 à 02.8, game.js) ; âge, origine et second style [PROPOSÉ]
    nameRule: { min: 2, max: 18 },
    ages: [18, 30],
    origins: { bakoma: 'Bakoma', portambre: 'Port-Ambre', selene: 'Sélène', tamarel: 'Tamarel', korvane: 'Korvane', aldera: 'Aldéra' },
    styles: { drill: { n: 'Drill de Bakoma', k: 'flow', kn: 'Flow', d: 'Flow sec, voix grave, ambiance sombre.' }, conscient: { n: 'Rap conscient', k: 'ecr', kn: 'Écriture', d: 'Textes posés, messages forts.' }, coupe: { n: 'Coupé-décalé rap', k: 'cha', kn: 'Charisme', d: 'Énergie de fête, refrains qui tournent.' }, trap: { n: 'Trap bakomaise', k: 'voix', kn: 'Voix', d: 'Mélodies, voix travaillée, basses lourdes.' } },
    mainBonus: 3, secondBonus: 1,
    goals: { quartier: { n: 'Être connu du quartier', d: 'Premier son, premiers fans, un nom qui circule.' }, label: { n: 'Signer en label', d: 'Réputation 30 pour ouvrir les portes.' }, stade: { n: 'Remplir un stade', d: 'Le rêve : une salle pleine à Lumbé.' } },
    skins: { '3': 'Mate', '5': 'Brun foncé', '6': 'Ébène' },
    // missions EXISTANTES (10.1), mission 3 = atelier d'écriture (refus du remplacement, 16/10) ; atelier repris de 09.3
    atelier: { n: 'Atelier d\'écriture', h: 2, e: 20, cost: 6000, sk: 'ecr', gain: 5 }, labelCut: 0.35,
    missions: [{ id: 'm1', t: 'Enregistre ton premier son', cash: 5000, xp: 50 }, { id: 'm2', t: 'Sors ton premier single', cash: 10000, xp: 80 }, { id: 'm3', t: 'Fais un atelier d\'écriture', cash: 4000, xp: 60 }, { id: 'm4', t: 'Atteins 1 000 fans', cash: 15000, xp: 120 }],
    // correctifs issus de l'audit du 16/10 [PROPOSÉ]
    concertEvery: 7, tourEvery: 28, ticketPrice: 80, capacity: 300, tourAudience: 3, merchScale: 30,
    // économie de démonstration reprise de la v20 (D-08)
    listenValue: 0.01, fanSat: 5000, listenCap: 15000000
  };
  var CANDS = {   // 8 candidat(e)s fictifs — profils et préférences visibles (règle 2)
    ines: { n: 'Inès Waly', age: 23, job: 'Styliste', city: 'Lumbé', likes: ['cadeau', 'scene'], dis: ['parler'], comp: 72, bio: 'Habille la moitié des artistes de Lumbé. Aime les tenues réussies et les grandes scènes.' },
    kadi: { n: 'Kadi Sora', age: 25, job: 'Infirmière', city: 'Mabaya', likes: ['parler', 'sortie'], dis: ['scene'], comp: 64, bio: 'Travaille de nuit. Préfère une vraie conversation à un concert bruyant.' },
    lina: { n: 'Lina Mbaré', age: 22, job: 'Danseuse', city: 'Kôtoro', likes: ['scene', 'sortie'], dis: ['cadeau'], comp: 80, bio: 'Danse sur les scènes de Kôtoro. Veut quelqu\'un qui bouge autant qu\'elle.' },
    sefa: { n: 'Sefa Doumbé', age: 27, job: 'Journaliste musique', city: 'Lumbé', likes: ['parler', 'scene'], dis: ['cadeau'], comp: 58, bio: 'Chronique la scène rap. Respecte le travail, se méfie du clinquant.' },
    amara: { n: 'Amara Teki', age: 21, job: 'Étudiante en droit', city: 'Ndolo', likes: ['parler', 'cadeau'], dis: ['sortie'], comp: 69, bio: 'Révise ses examens au maquis du coin. Sincère, curieuse, directe.' },
    yao: { n: 'Yao Bellam', age: 26, job: 'Photographe', city: 'Port-Ambre', likes: ['sortie', 'cadeau'], dis: ['scene'], comp: 61, bio: 'Photographie les rues de Port-Ambre. Aime les balades et les surprises.' },
    noe: { n: 'Noé Akan', age: 28, job: 'Chef cuisinier', city: 'Sélène', likes: ['sortie', 'parler'], dis: ['cadeau'], comp: 66, bio: 'Tient une cuisine à Sélène. Pense déjà à fonder une famille.' },
    teo: { n: 'Téo Gbéli', age: 24, job: 'Animateur radio', city: 'Kôtoro', likes: ['scene', 'parler'], dis: ['sortie'], comp: 75, bio: 'Passe du rap à la radio de Kôtoro. Fan de musique avant tout.' }
  };
  var KIDNAMES = ['Nayla', 'Kenzo'];
  var CID = Object.keys(CANDS);
  var LVN = REG.ranks.map(function (r) { return r.n; });
  var PROMO = [{ n: 'Aucune', c: 0, m: 1 }, { n: 'Réseaux sociaux', c: 2000, m: 1.6 }, { n: 'Radio locale', c: 15000, m: 3.2 }];
  var K = 5420 / (9000 * 0.61), ENTRY = 252200;

  function fmt(n) { n = Math.round(n); var s = String(Math.abs(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ' '); return (n < 0 ? '−' : '') + s; }
  function sg(n) { return (n > 0 ? '+' : '') + fmt(n); }
  function clamp(x, a, b) { return Math.max(a, Math.min(b, x)); }
  function clone(s) { return JSON.parse(JSON.stringify(s)); }
  function rng(s, salt) { var x = Math.sin((s.seed || 7) * 9301 + s.day * 49297 + (salt || 0) * 233) * 233280; return x - Math.floor(x); }
  function enMaxAge(age) { var m = 100; REG.enMaxByAge.forEach(function (p) { if (age >= p[0]) m = p[1]; }); return m; }
  function enMax(s) { return enMaxAge(s.age) + (s.own.appart ? 5 : 0); }
  function stageOf(age) { var n = REG.stages[0][1]; REG.stages.forEach(function (p) { if (age >= p[0]) n = p[1]; }); return n; }

  function init() {
    var s = { v: 21, created: 0, p: { name: '', age: REG.startAge, origin: 'bakoma', main: 'drill', second: null, goal: 'quartier' }, ms: {}, evq: [], ev: null, evDone: {}, kc: { left: 0, bonus: 0, rel: 0, st: '' }, cc: null, lastConcert: -99, lastTour: -99, seed: 7, day: 1, hour: 8, age: REG.startAge, cash: 25000, en: 100, pop: 3, fans: 120, rep: 8, xp: 0, rank: 1,
      sk: { flow: 17, ecr: 14, voix: 10, cha: 8 },
      cur: null, disco: [], shows: 0,
      geo: { bakoma: 4, portambre: 0, selene: 0, tamarel: 0, korvane: 0, aldera: 0 },
      own: {}, biz: {}, merch: null, merchDone: {}, signed: 0,
      ap: { hair: 'hitwist', top: 'hoodie', skin: '3' },
      rom: { c: {}, used: 0, today: {}, off: null, since: 0, married: 0, wed: 0, cool: 0, ex: {}, hist: [], prop: 0, wsel: 'simple' },
      fam: { kids: [], proj: 0, ev: null },
      log: [], bil: null, d0: null, ui: { promo: 0, feat: null }, t: 0, evId: 0 };
    CID.forEach(function (k) { s.rom.c[k] = { g: 0 }; });
    s.d0 = dayStart(s); return s;
  }
  function dayStart(s) { return { cash: s.cash, pop: s.pop, fans: s.fans, xp: s.xp, rank: s.rank, en: s.en, rel: s.rom.off ? s.rom.c[s.rom.off].g : null, geoB: s.geo.bakoma, kids: s.fam.kids.length }; }
  function norm(s) { var d = init(); for (var k in d) if (s[k] === undefined) s[k] = d[k]; return s; }
  function log(s, t, cat) { s.log.unshift({ t: t, c: cat || 'jeu', d: s.day }); if (s.log.length > 40) s.log.length = 40; }
  function pay(s, a) { s.cash = Math.max(0, s.cash + a); }
  function spend(s, h, e) { if (s.hour + h > REG.dayEnd) return 'tard'; if (s.en < e) return 'energie'; s.hour += h; s.en -= e; return null; }
  function geoAdd(s, city, n) { s.geo[city] = clamp(Math.round((s.geo[city] + n) * 10) / 10, 0, 100); }

  // ---------- rang de carrière (D-G05) ----------
  function condOk(s, c) {
    if (!c) return true;
    if (c.singles && s.disco.length < c.singles) return false;
    if (c.pop && s.pop < c.pop) return false;
    if (c.shows && s.shows < c.shows) return false;
    if (c.fans && s.fans < c.fans) return false;
    if (c.bon && !s.disco.some(function (d) { return d.L >= 50000; })) return false;
    if (c.hit && !s.disco.some(function (d) { return d.L >= ENTRY; })) return false;
    return true;
  }
  function promote(s) {
    var R = REG.ranks;
    while (s.rank < R.length && s.xp >= R[s.rank].xp && condOk(s, R[s.rank].cond)) { s.rank++; log(s, 'Promotion : N' + s.rank + ' · ' + R[s.rank - 1].n, 'carriere'); }
  }
  function addXp(s, x) { s.xp += x; promote(s); }

  // ---------- musique (D-G03, D-G04, D-G09) ----------
  function listensFor(Q, fans, promo) { var raw = (9000 + 6 * (fans - 120)) * PROMO[promo].m * (Q / 100) * K; return Math.round(raw / (1 + raw / REG.listenCap)); }
  function virOf(song, promo) {
    var v = REG.virBase + REG.themes[song.theme].vir + REG.ambs[song.amb].vir + REG.promoVir[promo || 0];
    song.feats.forEach(function (f) { v += REG.feats[f].vir; });
    if (song.clip && song.clip.st === 'publie') v += song.clip.vir || 0;
    return clamp(v, 0, 100);
  }
  function tierOf(L) { var t = REG.tiers[0][1]; REG.tiers.forEach(function (p) { if (L >= p[0]) t = p[1]; }); return t; }
  var TITLES = { quartier: ['Gbaka de 6h', 'Ndolo la nuit', 'Carrefour Mabaya', 'Rue des Griots'], galere: ['Poches vides', 'Fin du mois', 'Ticket de bus', 'Pluie sur Kôtoro'], ambition: ['Monter au sommet', 'Plus haut que Lumbé', 'Couronne de cauris', 'Premier stade'], amour: ['Lagune et toi', 'Message de minuit', 'Lumière d\'Ambre', 'Toi et Ndolo'] };

  var A = {};
  A.reset = function () { return init(); };
  A.create = function (s, arg) {   // création manuelle : "theme,amb" ; aléatoire : "random"
    if (s.cur && s.cur.st !== 'sorti') return { s: s, err: 'encours' };
    var n = clone(s), th, am, mode = 'manuel';
    if (arg === 'random' || (Array.isArray(arg) && arg[0] === 'random')) { var tk = Object.keys(REG.themes), ak = Object.keys(REG.ambs); th = tk[Math.floor(rng(n, 11) * tk.length)]; am = ak[Math.floor(rng(n, 12) * ak.length)]; mode = 'aléatoire'; }
    else if (Array.isArray(arg)) { th = arg[0]; am = arg[1]; } else { th = n.ui.th || 'quartier'; am = n.ui.am || 'sombre'; }
    if (!REG.themes[th] || !REG.ambs[am]) return { s: s, err: 'inconnu' };
    var e = spend(n, 1, 20); if (e) return { s: s, err: e };
    var pool = TITLES[th], title = (n.ui.title || '').replace(/\s+/g, ' ').trim().slice(0, 30);
    if (!title) { title = pool[n.disco.length % pool.length]; } else mode = mode === 'aléatoire' ? mode : 'manuel';
    if (n.ui.rt) { title = pool[Math.floor(rng(n, 13) * pool.length)]; }
    n.ui.title = ''; n.ui.rt = 0;
    n.cur = { id: 'T' + (n.disco.length + 1), title: title, theme: th, amb: am, mode: mode, tx: 72 + REG.themes[th].tx + REG.ambs[am].tx, st: 'ecrit', Q: 0, feats: [], clip: { st: 'aucun' } };
    n.sk.ecr += 1; log(n, 'Texte écrit : ' + title + ' (' + mode + ')', 'musique'); return { s: n };
  };
  A.record = function (s) {
    if (!s.cur || s.cur.st !== 'ecrit') return { s: s, err: 'pasdetexte' };
    var hs = !!s.own.homestudio, n = clone(s), e = spend(n, 2, hs ? 15 : 25); if (e) return { s: s, err: e };
    var kb = n.kc && n.kc.left > 0 ? n.kc.bonus : 0; if (kb) n.kc.left--;
    var voix = 55 + (hs ? 2 : 0), prod = 56 + (hs ? 4 : 0) + kb, mal = Math.min(20, Math.max(0, 40 - s.en) / 2);
    var fq = 0; n.cur.feats.forEach(function (f) { fq += REG.feats[f].q; });
    n.cur.voix = voix; n.cur.prod = prod; n.cur.Q = clamp(Math.round(0.35 * n.cur.tx + 0.30 * voix + 0.35 * prod - mal) + fq, 0, 100); n.cur.st = 'enregistre';
    n.sk.voix += 1; addXp(n, 30); log(n, 'Enregistré : ' + n.cur.title + ' · qualité ' + n.cur.Q + (kb ? ' (production Kôrô +' + kb + ')' : ''), 'musique'); queueEv(n, 'kore'); return { s: n };
  };
  A.feat = function (s, id) {
    var f = REG.feats[id]; if (!f) return { s: s, err: 'inconnu' };
    if (!s.cur || s.cur.st === 'sorti') return { s: s, err: 'pasdetitre' };
    if (s.cur.feats.indexOf(id) > -1) return { s: s, err: 'deja' };
    if (s.cur.feats.length >= REG.maxFeats) return { s: s, err: 'maxfeat' };
    if (f.need && f.need.rival) return { s: s, err: 'rival' };
    if (f.need && f.need.pop && s.pop < f.need.pop) return { s: s, err: 'pop' };
    if (s.cash < f.cost) return { s: s, err: 'cash' };
    var n = clone(s); pay(n, -f.cost); n.cur.feats.push(id);
    if (n.cur.st === 'enregistre') n.cur.Q = clamp(n.cur.Q + f.q, 0, 100);
    log(n, 'Featuring : ' + f.n + ' (' + f.role + ')', 'musique'); return { s: n };
  };
  A.unfeat = function (s, id) { if (!s.cur || s.cur.st === 'sorti') return { s: s, err: 'pasdetitre' }; var i = s.cur.feats.indexOf(id); if (i < 0) return { s: s }; var n = clone(s); n.cur.feats.splice(i, 1); if (n.cur.st === 'enregistre') n.cur.Q = clamp(n.cur.Q - REG.feats[id].q, 0, 100); var f = REG.feats[id]; if (f.cost) pay(n, f.cost); return { s: n }; };
  A.promo = function (s, k) { var n = clone(s); n.ui.promo = +k; return { s: n }; };
  A.release = function (s) {
    if (!s.cur || s.cur.st !== 'enregistre') return { s: s, err: 'pasenregistre' };
    var p = PROMO[s.ui.promo]; if (s.cash < p.c) return { s: s, err: 'cash' };
    var n = clone(s), c = n.cur; if (p.c) pay(n, -p.c);
    c.vir = virOf(c, n.ui.promo); var boost = 1; c.feats.forEach(function (f) { boost *= REG.feats[f].boost; });
    var L = Math.round(listensFor(c.Q, n.fans, n.ui.promo) * (0.8 + c.vir / 250) * boost);
    var gross = Math.round(L * REG.listenValue), rev = n.signed ? Math.round(gross * (1 - REG.labelCut)) : gross, fg = Math.ceil(L * 0.07 / (1 + n.fans / REG.fanSat)), pg = Math.floor(L / 900);
    pay(n, rev); n.fans += fg; n.pop = clamp(n.pop + pg, 0, 100);
    geoAdd(n, 'bakoma', Math.min(12, Math.round(L / 1500 * 10) / 10 + 1));
    if (n.ui.promo === 2) { geoAdd(n, 'portambre', 2); geoAdd(n, 'selene', 2); }
    c.st = 'sorti'; c.day = n.day; c.L = L; c.rev = rev; c.cut = gross - rev; c.fg = fg; c.pg = pg; c.tier = tierOf(L); c.promo = n.ui.promo;
    n.disco.unshift(c); n.cur = null; n.last = c.id;
    addXp(n, 40); log(n, 'Sortie : ' + c.title + ' · ' + fmt(L) + ' écoutes · ' + c.tier, 'musique'); return { s: n };
  };
  function clipSong(s) {   // titre visé par le clip : titre en cours, sinon dernier sorti
    if (s.cur && s.cur.st !== 'sorti') return s.cur;
    return s.disco[0] || null;
  }
  A.dir = function (s, id) { var n = clone(s); n.ui.dir = id; return { s: n }; };
  A.clipPrep = function (s, id) {
    var d = REG.directors[id || s.ui.dir]; if (!d) return { s: s, err: 'inconnu' };
    var t = clipSong(s); if (!t) return { s: s, err: 'pasdetitre' };
    if (t.st === 'sorti') return { s: s, err: 'clipapres' };           // D-G04 : préparation AVANT la sortie
    if (t.clip.st !== 'aucun') return { s: s, err: 'deja' };
    if (s.rank < d.rank) return { s: s, err: 'rang' };
    if (s.cash < d.cost) return { s: s, err: 'cash' };
    var n = clone(s), c = clipSong(n); pay(n, -d.cost); c.clip = { st: 'prepare', dir: id || s.ui.dir, vir: d.vir };
    log(n, 'Clip préparé avec ' + d.n + ' pour ' + c.title, 'musique'); return { s: n };
  };
  A.clipShoot = function (s) {
    var t = clipSong(s); if (!t || t.clip.st !== 'prepare') return { s: s, err: 'pasprepare' };
    var n = clone(s), e = spend(n, REG.shootH, REG.shootE - (s.own.moto ? 5 : 0)); if (e) return { s: s, err: e };
    clipSong(n).clip.st = 'produit'; log(n, 'Tournage terminé : ' + clipSong(n).title, 'musique'); return { s: n };
  };
  A.clipPub = function (s) {
    var t = clipSong(s); if (!t) return { s: s, err: 'pasdetitre' };
    if (t.st !== 'sorti') return { s: s, err: 'avantsortie' };         // D-G04 : jamais avant la sortie du titre
    if (t.clip.st !== 'produit') return { s: s, err: 'pasproduit' };
    var n = clone(s), c = n.disco[0]; c.clip.st = 'publie'; var v0 = c.vir; c.vir = virOf(c, c.promo);
    var extra = Math.round(c.L * REG.clipBoost * (c.vir / 100) * 4); c.L += extra; c.tier = tierOf(c.L);
    var fg = Math.ceil(extra * 0.07 / (1 + n.fans / REG.fanSat)); n.fans += fg; n.pop = clamp(n.pop + 2, 0, 100); pay(n, Math.round(extra * REG.listenValue));
    geoAdd(n, 'bakoma', 2); c.clipL = extra; c.clipF = fg; c.vir0 = v0;
    addXp(n, 20); log(n, 'Clip publié : ' + c.title + ' · +' + fmt(extra) + ' écoutes', 'musique'); return { s: n };
  };

  // ---------- scène (D-G12) ----------
  A.openmic = function (s) {
    var n = clone(s), e = spend(n, 1, 15 - (s.own.moto ? 5 : 0)); if (e) return { s: s, err: e };
    var win = s.en >= 40; n.shows++;
    if (win) { n.fans += 150; n.rep += 6; pay(n, 3000); geoAdd(n, 'bakoma', 2); addXp(n, 60); } else { n.fans += 12; addXp(n, 10); }
    log(n, 'Open mic de Ndolo : ' + (win ? 'le public a suivi (+150 fans)' : 'trou de mémoire'), 'scene'); n.om = win ? 1 : 0; return { s: n };
  };
  A.atelier = function (s) {   // 09.3 existant : 2 h, 6 000 cauris, −20 énergie, Écriture +5
    var T = REG.atelier; if (s.cash < T.cost) return { s: s, err: 'cash' };
    var n = clone(s), e = spend(n, T.h, T.e); if (e) return { s: s, err: e };
    pay(n, -T.cost); n.sk[T.sk] += T.gain; n.trained = (n.trained || 0) + 1; addXp(n, 20);
    log(n, 'Atelier d\'écriture : Écriture +' + T.gain + ' (−' + fmt(T.cost) + ' cauris)', 'carriere'); return { s: n };
  };
  A.concert = function (s) {
    if (s.rank < 3) return { s: s, err: 'rang' };
    if (s.day - s.lastConcert < REG.concertEvery) return { s: s, err: 'delai' };
    var n = clone(s), e = spend(n, 4, 35 - (s.own.moto ? 5 : 0)); if (e) return { s: s, err: e };
    var A_ = s.en >= 60, tk = tickets(s), ca = Math.round(tk * REG.ticketPrice * (A_ ? 1 : 0.85)), fg = Math.round(tk * (A_ ? 1.6 : 1.1)), rp = A_ ? 10 : 6;
    n.shows++; n.fans += fg; n.rep += rp; pay(n, ca); geoAdd(n, 'bakoma', 4); n.pop = clamp(n.pop + 1, 0, 100); addXp(n, 90); n.lastConcert = n.day; n.concertDay = n.day;
    n.cc = { g: A_ ? 'A' : 'B', tk: tk, cash: ca, fans: fg, rep: rp, day: n.day };
    log(n, 'Concert au Parvis : ' + tk + ' billets, note ' + (A_ ? 'A' : 'B') + ' · +' + fmt(fg) + ' fans · billetterie ' + fmt(ca), 'scene'); return { s: n };
  };
  A.tour = function (s) {
    var T = REG.tour; if (s.rank < T.rank) return { s: s, err: 'rang' }; if (s.day - s.lastTour < REG.tourEvery) return { s: s, err: 'delai' };
    if ((s.geo.portambre + s.geo.selene) / 2 < REG.tourAudience) return { s: s, err: 'audience' }; if (s.cash < T.cost) return { s: s, err: 'cash' };
    var n = clone(s), e = spend(n, T.h, T.e - (s.own.moto ? 5 : 0)); if (e) return { s: s, err: e };
    var fee = T.fee + Math.round(T.feeGeo * (s.geo.portambre + s.geo.selene)); pay(n, fee - T.cost); n.lastTour = n.day;
    n.cc = { g: 'T', tk: 0, cash: fee - T.cost, fans: T.fans, rep: 4, day: n.day, tour: 1 }; n.rep += 4; n.fans += T.fans; n.shows += 2; geoAdd(n, 'portambre', T.geo); geoAdd(n, 'selene', T.geo); n.pop = clamp(n.pop + 2, 0, 100); addXp(n, 120);
    log(n, 'Tournée régionale : +' + fmt(T.fans) + ' fans, Port-Ambre et Sélène +' + T.geo, 'scene'); return { s: n };
  };

  // ---------- économie (D-G02, D-G06, D-G08) ----------
  A.job = function (s, id) {
    var j = REG.jobs[id]; if (!j) return { s: s, err: 'inconnu' };
    if (j.cha && s.sk.cha < j.cha) return { s: s, err: 'charisme' };
    var n = clone(s), e = spend(n, j.h, j.e - (s.own.moto ? 5 : 0)); if (e) return { s: s, err: e };
    pay(n, j.cash); if (j.pop) n.pop = clamp(n.pop + j.pop, 0, 100); n.lastJob = { id: id, cash: j.cash, e: j.e - (s.own.moto ? 5 : 0), h: j.h };
    log(n, j.n + ' : +' + fmt(j.cash) + ' cauris', 'eco'); return { s: n };
  };
  A.bizBuy = function (s, id) {
    var b = REG.biz[id]; if (!b) return { s: s, err: 'inconnu' }; if (s.biz[id]) return { s: s, err: 'deja' };
    if (s.rank < b.rank) return { s: s, err: 'rang' }; if (s.cash < b.cost) return { s: s, err: 'cash' };
    var n = clone(s); pay(n, -b.cost); n.biz[id] = { since: n.day, tot: 0 }; log(n, 'Entreprise : ' + b.n, 'eco'); return { s: n };
  };
  A.ask = function (s, id) { var n = clone(s); n.ui.buy = id; return { s: n }; };
  A.assetBuy = function (s, id) {
    id = id || s.ui.buy; var a = REG.assets[id]; if (!a) return { s: s, err: 'inconnu' }; if (s.own[id]) return { s: s, err: 'deja' };
    if (s.cash < a.cost) return { s: s, err: 'cash' };
    var n = clone(s); pay(n, -a.cost); n.own[id] = { since: n.day }; n.ui.buy = null;
    if (id === 'appart') n.en = Math.min(enMax(n), n.en + 5);
    log(n, 'Bien acquis : ' + a.n, 'eco'); return { s: n };
  };
  A.merch = function (s, id) {
    var m = REG.merch[id]; if (!m) return { s: s, err: 'inconnu' }; if (s.merch) return { s: s, err: 'encours' };
    if (s.fans < m.need.fans) return { s: s, err: 'fans' }; if (m.need.singles && s.disco.length < m.need.singles) return { s: s, err: 'single' };
    if (m.need.rank && s.rank < m.need.rank) return { s: s, err: 'rang' }; if (s.cash < m.cost) return { s: s, err: 'cash' };
    var n = clone(s); pay(n, -m.cost); n.merch = { id: id, left: m.days, tot: 0 }; log(n, 'Merch lancé : ' + m.n, 'eco'); return { s: n };
  };
  A.sign = function (s) { if (s.signed) return { s: s, err: 'deja' }; if (s.rep < REG.labelRep) return { s: s, err: 'rep' }; var n = clone(s); n.signed = 1; pay(n, 150000); log(n, 'Contrat signé : Bakoma Sound Records (avance 150 000)', 'carriere'); return { s: n }; };

  // ---------- relations (D-G07) ----------
  function rel(s) { return s.rom.off ? s.rom.c[s.rom.off] : null; }
  A.rom = function (s, arg) {
    var cid = arg[0], act = arg[1], C = CANDS[cid], a = REG.romActs[act]; if (!C || !a) return { s: s, err: 'inconnu' };
    if (s.rom.used >= REG.romPerDay) return { s: s, err: 'romjour' };
    if (s.rom.off && s.rom.off !== cid) return { s: s, err: 'exclusif' };
    if (s.rom.ex[cid] && s.day < s.rom.ex[cid]) return { s: s, err: 'ex' };
    if (act === 'scene' && !s.shows) return { s: s, err: 'pasdeconcert' };
    if (s.cash < a.c) return { s: s, err: 'cash' };
    var n = clone(s), e = spend(n, a.h, a.e); if (e) return { s: s, err: e };
    var mul = C.likes.indexOf(act) > -1 ? REG.likeMul : C.dis.indexOf(act) > -1 ? REG.dislikeMul : 1, gain = Math.round(a.g * mul);
    pay(n, -a.c); var c = n.rom.c[cid]; c.g = clamp(c.g + gain, 0, 100); c.met = 1; n.rom.used++; n.rom.today[cid] = 1;
    n.rom.lastAct = { cid: cid, act: act, gain: gain, mul: mul };
    log(n, a.n + ' avec ' + C.n + ' : relation ' + sg(gain) + ' (' + c.g + '/100)', 'perso'); return { s: n };
  };
  A.romc = function (s, act) { return A.rom(s, [s.ui.cand || 'lina', act]); };
  A.romp = function (s, act) { if (!s.rom.off) return { s: s, err: 'pasdecouple' }; return A.rom(s, [s.rom.off, act]); };
  A.th = function (s, id) { var n = clone(s); n.ui.th = id; return { s: n }; };
  A.am = function (s, id) { var n = clone(s); n.ui.am = id; return { s: n }; };
  A.cand = function (s, cid) { var n = clone(s); n.ui.cand = cid; return { s: n }; };
  A.official = function (s, cid) {
    cid = cid || s.ui.cand; var c = s.rom.c[cid]; if (!c) return { s: s, err: 'inconnu' };
    if (s.rom.off) return { s: s, err: 'exclusif' }; if (c.g < REG.officialAt) return { s: s, err: 'seuil' };
    var n = clone(s); n.rom.off = cid; n.rom.since = n.day; n.rom.hist.push({ d: n.day, t: 'En couple avec ' + CANDS[cid].n });
    log(n, 'Couple officialisé avec ' + CANDS[cid].n + ' : relation exclusive', 'perso'); return { s: n };
  };
  function canPropose(s) { var r = rel(s); return !!(r && !s.rom.married && r.g >= REG.proposeAt && s.day - s.rom.since >= REG.proposeMinDays && s.day >= s.rom.cool); }
  A.proposal = function (s, ans) {
    if (!canPropose(s)) return { s: s, err: 'condmariage' };
    var n = clone(s);
    if (ans === 'non') { var r = rel(n); r.g = clamp(r.g - REG.refuseLoss, 0, 100); n.rom.cool = n.day + REG.refuseCooldown; n.rom.hist.push({ d: n.day, t: 'Demande en mariage refusée' }); log(n, 'Tu as refusé la demande : relation −' + REG.refuseLoss + ', nouvelle demande possible dans ' + REG.refuseCooldown + ' jours', 'perso'); return { s: n }; }
    n.rom.prop = 1; log(n, 'Demande acceptée : préparation du mariage', 'perso'); return { s: n };
  };
  A.wsel = function (s, id) { var n = clone(s); n.rom.wsel = id; return { s: n }; };
  A.wed = function (s) {
    if (!s.rom.prop || s.rom.married) return { s: s, err: 'condmariage' };
    var w = REG.weddings[s.rom.wsel]; if (s.cash < w.cost) return { s: s, err: 'cash' };
    var n = clone(s); pay(n, -w.cost); n.rom.married = 1; n.rom.wed = n.day; n.rom.prop = 0; var r = rel(n); r.g = clamp(r.g + w.g, 0, 100);
    n.pop = clamp(n.pop + w.pop, 0, 100); if (w.pop) geoAdd(n, 'bakoma', 2);
    n.rom.hist.push({ d: n.day, t: 'Mariage avec ' + CANDS[n.rom.off].n + ' (' + w.n + ')' }); log(n, 'Mariage célébré : ' + w.n, 'perso'); return { s: n };
  };
  A.separate = function (s) {
    if (!s.rom.off) return { s: s, err: 'pasdecouple' };
    var n = clone(s), cid = n.rom.off; separate(n, cid, 'Séparation décidée par toi'); return { s: n };
  };
  function separate(n, cid, why) {
    n.rom.hist.push({ d: n.day, t: why + ' · ' + CANDS[cid].n + (n.rom.married ? ' (après mariage)' : ' (avant mariage)') });
    n.rom.c[cid].g = Math.min(n.rom.c[cid].g, 10); n.rom.ex[cid] = n.day + REG.exBlockDays; n.rom.off = null; n.rom.prop = 0;
    if (n.rom.married) { n.rom.married = 0; n.rom.div = 1; }
    n.fam.proj = 0; n.fam.kids.forEach(function (k) { k.garde = 'Garde partagée'; });
    n.rom.sep = { why: why, who: CANDS[cid].n, d: n.day };
    log(n, why + ' avec ' + CANDS[cid].n + ' : historique et enfants conservés', 'perso');
  }
  A.famProj = function (s, ans) { if (!s.rom.married) return { s: s, err: 'mariage' }; var n = clone(s); n.fam.proj = ans === 'oui' ? 1 : 0; n.fam.projAsked = 1; log(n, ans === 'oui' ? 'Projet d\'enfant : vous essayez (aucune garantie)' : 'Projet d\'enfant : pas maintenant', 'perso'); return { s: n }; };
  A.kid = function (s, arg) {
    var i = +arg[0], a = REG.kidActs[arg[1]], k = s.fam.kids[i]; if (!k || !a) return { s: s, err: 'inconnu' };
    var age = kidAge(s, k); if (age < a.min) return { s: s, err: 'age' };
    var n = clone(s), e = spend(n, a.h, a.e); if (e) return { s: s, err: e };
    var kk = n.fam.kids[i]; kk.l = clamp(kk.l + a.l, 0, 100); kk.today = 1; log(n, a.n + ' avec ' + kk.n + ' : lien +' + a.l, 'perso'); return { s: n };
  };
  function kidAge(s, k) { return Math.floor((s.day - k.born) / REG.daysPerYear); }
  var FEV = {
    anniv: { need: 'couple', t: 'Anniversaire de couple', q: '« Ce soir, c\'est notre anniversaire. Tu restes avec moi ? »', a: { n: 'Rester ce soir', g: 8, cash: -5000, h: 2 }, b: { n: 'Reporter : tu as du travail', g: -6 } },
    fievre: { need: 'kid', t: 'Fièvre la veille d\'un concert', q: '« Ton enfant a de la fièvre. Tu restes à la maison ? »', a: { n: 'Rester à la maison', l: 10, e: -15 }, b: { n: 'Confier à la famille', l: -5 } },
    dimanche: { need: 'married', t: 'Repas de famille du dimanche', q: '« Les deux familles se retrouvent dimanche. On y va ? »', a: { n: 'Y aller', g: 5, h: 3 }, b: { n: 'Décliner', g: -4 } }
  };
  A.fev = function (s, ch) {
    var id = s.fam.ev; if (!id) return { s: s, err: 'rien' }; var E = FEV[id], o = ch === 'a' ? E.a : E.b, n = clone(s);
    if (o.h && n.hour + o.h > REG.dayEnd) return { s: s, err: 'tard' }; if (o.h) n.hour += o.h;
    if (o.cash) { if (n.cash < -o.cash) return { s: s, err: 'cash' }; pay(n, o.cash); }
    if (o.e) n.en = Math.max(0, n.en + o.e);
    var r = rel(n); if (o.g && r) r.g = clamp(r.g + o.g, 0, 100);
    if (o.l) n.fam.kids.forEach(function (k) { k.l = clamp(k.l + o.l, 0, 100); });
    n.fam.ev = null; n.fam.evDone = { t: E.t, ch: o.n }; log(n, 'Événement familial · ' + E.t + ' : ' + o.n, 'perso'); return { s: n };
  };

  // ---------- fin de journée et bilan (D-G11) ----------
  A.endDay = function (s) {
    var n = clone(s), ev = [], d0 = n.d0 || dayStart(n);
    // revenus passifs
    var inc = 0;
    Object.keys(n.biz).forEach(function (id) { var b = REG.biz[id], x = Math.round(b.lo + (b.hi - b.lo) * rng(n, id.length)); inc += x; n.biz[id].tot += x; ev.push(b.n + ' : ' + sg(x) + ' (estimé)'); });
    if (n.own.terrain) { var A_ = REG.assets.terrain, y = Math.round(A_.lo + (A_.hi - A_.lo) * rng(n, 5)); inc += y; ev.push('Loyer du terrain : ' + sg(y)); }
    if (n.merch) { var M = REG.merch[n.merch.id], z = Math.round(M.perFan * Math.sqrt(n.fans) * REG.merchScale); inc += z; n.merch.tot += z; n.merch.left--; ev.push(M.n + ' : ' + sg(z)); if (n.merch.left <= 0) { n.merchDone[n.merch.id] = n.merch.tot; ev.push(M.n + ' : stock écoulé'); n.merch = null; } }
    pay(n, inc);
    var cost = 0; if (n.own.appart) cost += REG.assets.appart.upkeep;
    if (n.rom.off) cost += REG.coupleCost; cost += n.fam.kids.length * REG.kidCost;
    if (cost) { pay(n, -cost); ev.push('Charges du foyer : ' + sg(-cost)); }
    // relations : baisse sans entretien (règle 7)
    CID.forEach(function (cid) { var c = n.rom.c[cid]; if (!c.met || n.rom.today[cid]) return; var dec = cid === n.rom.off ? REG.decayCouple : (n.rom.off ? 0 : REG.decayCourt); if (dec && c.g > 0) c.g = Math.max(0, c.g - dec); });
    var r = rel(n);
    if (r && r.g < REG.leaveAt) { var who = n.rom.off; separate(n, who, 'Rupture décidée par ' + CANDS[who].n + ' (relation trop dégradée, sous ' + REG.leaveAt + ')'); ev.push('Rupture : ' + CANDS[who].n + ' est parti(e) — relation sous ' + REG.leaveAt); r = null; }
    else if (r && r.g < REG.warnAt) ev.push('Attention : la relation avec ' + CANDS[n.rom.off].n + ' se dégrade (' + r.g + '/100)');
    // enfants (règles 11 et 12)
    if (n.rom.married && n.fam.proj && n.fam.kids.length < REG.maxKids && rng(n, 3) < REG.kidChance) { var nm = KIDNAMES[n.fam.kids.length]; n.fam.kids.push({ n: nm, born: n.day + 1, l: 50, garde: 'Au foyer' }); n.fam.proj = 0; ev.push('Naissance : ' + nm + ' est arrivé(e) au foyer'); n.rom.hist.push({ d: n.day + 1, t: 'Naissance de ' + nm }); }
    // événement familial du lendemain (déterministe)
    if (!n.fam.ev) { if (n.fam.kids.length && n.day % 3 === 0) n.fam.ev = 'fievre'; else if (n.rom.married && n.day % 4 === 1) n.fam.ev = 'dimanche'; else if (n.rom.off && n.day % 5 === 2) n.fam.ev = 'anniv'; }
    // nuit et passage du temps
    var y0 = Math.floor((n.day - 1) / REG.daysPerYear);
    n.day++; n.hour = REG.dayStart; n.rom.used = 0; n.rom.today = {}; n.fam.kids.forEach(function (k) { k.today = 0; });
    var y1 = Math.floor((n.day - 1) / REG.daysPerYear), aged = null;
    if (y1 > y0) { var em0 = enMax(n); n.age++; aged = { age: n.age, em0: em0, em1: enMax(n) }; ev.push('Nouvelle année : ' + n.age + ' ans, énergie max ' + em0 + ' → ' + enMax(n)); n.fam.kids.forEach(function (k) { ev.push(k.n + ' : ' + stageOf(kidAge(n, k))); }); }
    var baby = n.fam.kids.some(function (k) { return kidAge(n, k) < 1 && k.garde === 'Au foyer'; });
    n.en = enMax(n) - (baby ? REG.babyMorning : 0);
    promote(n);
    if (n.rep >= REG.labelRep && !n.signed) queueEv(n, 'label');
    var rel1 = rel(n);
    n.bil = { day: n.day - 1, cash: n.cash - d0.cash, pop: n.pop - d0.pop, fans: n.fans - d0.fans, xp: n.xp - d0.xp, rank0: d0.rank, rank: n.rank, en: n.en, enMax: enMax(n), rel0: d0.rel, rel: rel1 ? rel1.g : null, who: rel1 ? CANDS[n.rom.off].n : '', kids: n.fam.kids.length, kids0: d0.kids,
      fam: ev.filter(function (e) { return /Rupture|Attention|Naissance|Charges du foyer| : (Bébé|Petite enfance|Enfant|Adolescent|Adulte)$/.test(e); }).concat(n.log.filter(function (l) { return l.d === n.day - 1 && l.c === 'perso'; }).map(function (l) { return l.t; })).slice(0, 6),
      ev: ev, acts: n.log.filter(function (l) { return l.d === n.day - 1; }).map(function (l) { return l.t; }).slice(0, 8), aged: aged };
    n.d0 = dayStart(n); n.lastJob = null; n.fam.evDone = null; n.idx0 = idxParts(s).i; return { s: n };
  };
  A.skipYear = function (s) {   // raccourci de démonstration : avance au dernier jour de l'année puis clôt la journée
    var n = clone(s), y = Math.floor((n.day - 1) / REG.daysPerYear); n.day = (y + 1) * REG.daysPerYear; n.d0 = dayStart(n); return A.endDay(n);
  };
  A.ap = function (s, arg) { var p = String(arg).split('='); var n = clone(s); n.ap[p[0]] = p[1]; return { s: n }; };

  // ---------- préréglages de démonstration (raccourcis honnêtement signalés) ----------
  var PRE = {
    debut: function () { return init(); },
    couple: function () { var s = init(); s.day = 20; s.rom.c.lina.g = 82; s.rom.c.lina.met = 1; s.rom.c.kadi.g = 22; s.rom.c.kadi.met = 1; s.rom.off = 'lina'; s.rom.since = 5; s.rom.hist.push({ d: 5, t: 'En couple avec Lina Mbaré' }); s.cash = 220000; s.shows = 1; s.d0 = dayStart(s); return s; },
    marie: function () { var s = PRE.couple(); s.rom.married = 1; s.rom.wed = 18; s.rom.hist.push({ d: 18, t: 'Mariage avec Lina Mbaré (Cérémonie simple)' }); s.fam.proj = 1; s.fam.projAsked = 1; s.d0 = dayStart(s); return s; },
    parent: function () { var s = PRE.marie(); s.fam.proj = 0; s.fam.kids.push({ n: 'Nayla', born: 330, l: 55, garde: 'Au foyer' }); s.day = 400; s.age = 20; s.rom.hist.push({ d: 330, t: 'Naissance de Nayla' }); s.fam.ev = 'fievre'; s.d0 = dayStart(s); return s; },
    carriere: function () { var s = init(); s.day = 30; s.xp = 3100; s.rank = 3; s.trained = 1; s.fans = 2400; s.pop = 18; s.rep = 31; s.cash = 320000; s.shows = 1; s.sk.cha = 12;
      s.disco = [{ id: 'T1', title: 'Gbaka de 6h', theme: 'quartier', amb: 'sombre', mode: 'manuel', tx: 72, st: 'sorti', Q: 61, feats: [], clip: { st: 'aucun' }, L: 5418, rev: 54, fg: 371, pg: 6, tier: 'Discret', promo: 0, vir: 30, day: 3 }];
      s.geo = { bakoma: 14, portambre: 4, selene: 3, tamarel: 0, korvane: 0, aldera: 0 }; s.d0 = dayStart(s); return s; },
    star: function () { var s = PRE.carriere(); s.xp = 6200; s.rank = 5; s.fans = 14800; s.pop = 41; s.cash = 1400000; s.shows = 6;
      s.disco.unshift({ id: 'T2', title: 'Monter au sommet', theme: 'ambition', amb: 'fiere', mode: 'manuel', tx: 76, st: 'sorti', Q: 70, feats: ['nadia'], clip: { st: 'publie', dir: 'ombre', vir: 15 }, L: 84000, rev: 840, fg: 2100, pg: 14, tier: 'Bon', promo: 2, vir: 69, day: 25 });
      s.geo = { bakoma: 46, portambre: 22, selene: 19, tamarel: 3, korvane: 0, aldera: 1 }; s.own.moto = { since: 12 }; s.d0 = dayStart(s); return s; }
  };
  // ---------- création de l'artiste ----------
  function cleanName(x) { return String(x || '').replace(/\s+/g, ' ').trim(); }
  function nameOk(x) { x = cleanName(x); return x.length >= REG.nameRule.min && x.length <= REG.nameRule.max && /^[A-Za-zÀ-ÖØ-öø-ÿ0-9 '\-.]+$/.test(x); }
  A.setp = function (s, arg) {
    var i = String(arg).indexOf('='), k = String(arg).slice(0, i), v = String(arg).slice(i + 1), n = clone(s);
    if (k === 'name') n.p.name = v.slice(0, 40);
    else if (k === 'age') { var a = v === '+' ? n.p.age + 1 : v === '-' ? n.p.age - 1 : +v; n.p.age = clamp(a || REG.startAge, REG.ages[0], REG.ages[1]); }
    else if (k === 'origin' && REG.origins[v]) n.p.origin = v;
    else if (k === 'main' && REG.styles[v]) { n.p.main = v; if (n.p.second === v) n.p.second = null; }
    else if (k === 'second') n.p.second = (REG.styles[v] && v !== n.p.main) ? v : null;
    else if (k === 'goal' && REG.goals[v]) n.p.goal = v;
    else return { s: s, err: 'inconnu' };
    return { s: n };
  };
  A.setui = function (s, arg) { var i = String(arg).indexOf('='), k = String(arg).slice(0, i), v = String(arg).slice(i + 1), n = clone(s); if (['title', 'th', 'am'].indexOf(k) < 0) return { s: s, err: 'inconnu' }; n.ui[k] = v.slice(0, 40); return { s: n }; };
  A.rtitle = function (s) { var n = clone(s); n.ui.rt = 1; n.ui.title = ''; return { s: n }; };
  A.uv = function (s, k) { var n = clone(s); n.ui.uv = clamp(+k || 1, 1, 3); return { s: n }; };
  A.finish = function (s) {
    if (s.created) return { s: s, err: 'deja' };
    if (!nameOk(s.p.name)) return { s: s, err: 'nom' };
    var n = clone(s); n.p.name = cleanName(n.p.name); n.age = n.p.age; n.created = 1;
    n.sk[REG.styles[n.p.main].k] += REG.mainBonus; if (n.p.second) n.sk[REG.styles[n.p.second].k] += REG.secondBonus;
    if (n.p.origin !== 'bakoma') geoAdd(n, n.p.origin, 4);
    n.en = enMax(n); n.d0 = dayStart(n); n.evq = []; queueEv(n, 'kzer');
    log(n, 'Bienvenue à Ndolo, ' + n.p.name + ' : ta carrière commence', 'carriere'); return { s: n };
  };
  // ---------- événements de carrière (EXISTANTS : 03.5 défi de K-Zer, 16-A offre de DJ Kôrô, 08.2 offre de label) ----------
  var EVT = {
    kzer: { t: 'K-Zer d\'Mabaya te défie', who: 'K-Zer d\'Mabaya', q: '« Le nouveau de Ndolo ? Viens prouver que tu sais rapper. Ce soir, au carrefour. »',
      ch: [{ id: 'a', n: 'Répondre en freestyle', c: '1 h · −15 énergie · +6 réputation · +150 fans' }, { id: 'b', n: 'Ignorer', c: '+2 popularité · le défi est clos' }] },
    kore: { t: 'DJ Kôrô a écouté ton son', who: 'DJ Kôrô', q: '« La prod est brute, mais ta voix a du grain. Je te propose un deal : je produis tes trois prochains titres. »',
      ch: [{ id: 'a', n: 'Accepter à 40 %', c: '−8 000 cauris · production +12 sur 3 titres · relation +15' }, { id: 'b', n: 'Négocier à 35 %, mix signé', c: '−7 000 cauris · production +12 sur 3 titres · relation +8' }, { id: 'c', n: 'Refuser', c: 'relation −10 · il s\'en souviendra' }] },
    label: { t: 'Bakoma Sound Records te fait une offre', who: 'Madame Orage', q: '« Six mois, deux sons par trimestre, 150 000 d\'avance. On signe ? »',
      ch: [{ id: 'a', n: 'Signer le contrat', c: '+150 000 cauris d\'avance · 35 % de tes revenus d\'écoutes au label · 6 mois' }, { id: 'b', n: 'Refuser pour l\'instant', c: 'tu restes indépendant' }] }
  };
  function queueEv(n, id) { if (n.evDone[id] || n.ev === id || n.evq.indexOf(id) > -1) return; if (!n.ev) n.ev = id; else n.evq.push(id); }
  A.evc = function (s, ch) {
    var id = s.ev; if (!id) return { s: s, err: 'rien' }; var n = clone(s), cost = 0;
    if (id === 'kzer') { if (ch === 'a') { var e = spend(n, 1, 15); if (e) return { s: s, err: e }; n.rep += 6; n.fans += 150; geoAdd(n, 'bakoma', 2); addXp(n, 20); } else n.pop = clamp(n.pop + 2, 0, 100); }
    if (id === 'kore') { var D = { a: [8000, 15, 'Accord à 40 %'], b: [7000, 8, 'Accord à 35 %, mix signé'], c: [0, -10, 'Refus'] }[ch]; if (!D) return { s: s, err: 'inconnu' }; if (n.cash < D[0]) return { s: s, err: 'cash' }; pay(n, -D[0]); n.kc = { st: D[2], rel: D[1], bonus: ch === 'c' ? 0 : 12, left: ch === 'c' ? 0 : 3 }; }
    if (id === 'label') { if (ch === 'a') { n.signed = 1; pay(n, 150000); } else n.lr = 1; }
    var E = EVT[id], C = E.ch.filter(function (x) { return x.id === ch; })[0]; if (!C) return { s: s, err: 'inconnu' };
    n.evDone[id] = ch; n.evLast = { t: E.t, ch: C.n, c: C.c }; n.ev = n.evq.shift() || null;
    log(n, E.t + ' : ' + C.n + ' (' + C.c + ')', 'evenement'); return { s: n };
  };
  function missions(n) {
    var done = { m1: n.disco.length > 0 || !!(n.cur && n.cur.st === 'enregistre'), m2: n.disco.length > 0, m3: !!n.trained, m4: n.fans >= 1000 };
    REG.missions.forEach(function (m) { if (!n.ms[m.id] && done[m.id] && n.created) { n.ms[m.id] = n.day; pay(n, m.cash); addXp(n, m.xp); log(n, 'Mission accomplie : ' + m.t + ' (+' + fmt(m.cash) + ' cauris, +' + m.xp + ' XP)', 'mission'); } });
  }
  function tickets(s) { return Math.min(REG.capacity, Math.round(40 + s.fans * 0.05 + s.geo.bakoma * 4)); }
  A.preset = function (s, id) { var f = PRE[id]; if (!f) return { s: s, err: 'inconnu' }; var x = f(); if (!x.created) { x.created = 1; x.p.name = 'Djo Kéné'; } if (id === 'debut') { x.ev = 'kzer'; } else { x.evDone.kzer = 'b'; x.ms = {}; var dn = { m1: x.disco.length > 0, m2: x.disco.length > 0, m3: !!x.trained, m4: x.fans >= 1000 }; Object.keys(dn).forEach(function (k) { if (dn[k]) x.ms[k] = 1; }); } return { s: x }; };

  function act(s, name, arg) { s = norm(s); var f = A[name]; if (!f) return { s: s, err: 'inconnu' }; var r = f(s, arg); if (!r.err && r.s !== s) { norm(r.s); missions(r.s); } r.s.t = Date.now(); return r; }

  // ---------- vue : toutes les valeurs affichées ----------
  function view(s) {
    s = norm(s); var o = {}, R = REG.ranks, rk = s.rank, em = enMax(s), r = rel(s);
    var hh = (s.hour < 10 ? '0' : '') + s.hour + ':00', yr = Math.floor((s.day - 1) / REG.daysPerYear) + 1, dy = ((s.day - 1) % REG.daysPerYear) + 1;
    o.cash = fmt(s.cash); o.en = String(s.en); o.enMax = String(em); o.enPct = Math.round(100 * s.en / em); o.time = 'J' + dy + ' · ' + hh; o.hour = hh; o.day = String(s.day); o.dayY = String(dy); o.year = String(yr); o.age = String(s.age);
    o.hoursLeft = String(REG.dayEnd - s.hour); o.late = s.hour >= 22; o.lowEn = s.en < 20;
    o.rankTag = 'N' + rk + ' · ' + R[rk - 1].n.toUpperCase(); o.rankN = 'N' + rk; o.rankName = R[rk - 1].n;
    var lo = R[rk - 1].xp, hi = R[rk] ? R[rk].xp : lo + 600; o.xpPct = clamp(Math.round(100 * (s.xp - lo) / (hi - lo)), 0, 100); o.xp = String(s.xp); o.xpNext = String(hi);
    o.nextName = R[rk] ? R[rk].n : 'Rang maximal'; o.nextCond = R[rk] ? (R[rk].xp + ' XP' + (R[rk].cl ? ' · ' + R[rk].cl : '')) : '—';
    o.nextXpOk = R[rk] ? s.xp >= R[rk].xp : false; o.nextCondOk = R[rk] ? condOk(s, R[rk].cond) : false; o.blocked = !!(R[rk] && s.xp >= R[rk].xp && !condOk(s, R[rk].cond));
    R.forEach(function (x, i) { o['rk' + (i + 1) + 'Done'] = rk > i; o['rk' + (i + 1) + 'Cur'] = rk === i + 1; o['rk' + (i + 1) + 'Todo'] = rk < i + 1; });
    o.fans = fmt(s.fans); o.pop = String(s.pop); o.rep = String(s.rep);
    // journée
    var d0 = s.d0 || dayStart(s); o.dCash = sg(s.cash - d0.cash); o.dFans = sg(s.fans - d0.fans); o.dPop = sg(s.pop - d0.pop);
    o.todayN = String(s.log.filter(function (l) { return l.d === s.day; }).length);
    var tl = s.log.filter(function (l) { return l.d === s.day; }).slice(0, 4); for (var i = 0; i < 4; i++) { o['tl' + i] = tl[i] ? tl[i].t : ''; o['tl' + i + 'On'] = !!tl[i]; }
    o.noToday = !tl.length;
    // bilan
    var b = s.bil; o.hasBil = !!b; o.noBil = !b;
    if (b) {
      o.bDay = String(b.day); o.bCash = sg(b.cash); o.bPop = sg(b.pop); o.bFans = sg(b.fans); o.bXp = sg(b.xp); o.bEn = b.en + ' / ' + b.enMax;
      o.bRank = b.rank > b.rank0 ? 'Promotion : N' + b.rank0 + ' → N' + b.rank : 'N' + b.rank + ' · inchangé';
      o.bRel = b.rel === null ? (b.rel0 !== null ? 'Séparation : relation terminée' : 'Aucune relation officielle') : (b.who + ' : ' + b.rel + '/100 (' + sg(b.rel - (b.rel0 === null ? b.rel : b.rel0)) + ')');
      o.bFam = b.kids ? (b.kids + ' enfant' + (b.kids > 1 ? 's' : '') + (b.kids > b.kids0 ? ' · naissance' : '')) : 'Aucun enfant';
      var evs = b.ev.concat(b.acts); for (var j = 0; j < 7; j++) { o['be' + j] = evs[j] || ''; o['be' + j + 'On'] = !!evs[j]; }
      for (var j2 = 0; j2 < 5; j2++) { var fl = (b.fam || [])[j2]; o['bf' + j2] = fl || ''; o['bf' + j2 + 'On'] = !!fl; } o.bfNone = !(b.fam || []).length;
      o.bAged = !!b.aged; o.bAgedT = b.aged ? 'Tu as ' + b.aged.age + ' ans : énergie max ' + b.aged.em0 + ' → ' + b.aged.em1 : '';
    }
    o.yearPct = Math.round(100 * dy / REG.daysPerYear); o.daysToYear = String(REG.daysPerYear - dy + 1);
    o.enAgeNow = String(enMaxAge(s.age)); o.enAgeNext = String(enMaxAge(s.age + 1)); o.apBonus = s.own.appart ? '+5' : '+0';
    // musique
    var c = s.cur; o.hasCur = !!c; o.noCur = !c; o.curWritten = !!(c && c.st === 'ecrit'); o.curRec = !!(c && c.st === 'enregistre');
    o.curT = c ? c.title : '—'; o.curTheme = c ? REG.themes[c.theme].n : '—'; o.curAmb = c ? REG.ambs[c.amb].n : '—'; o.curMode = c ? c.mode : '—';
    o.curSt = c ? ({ ecrit: 'Texte écrit · à enregistrer', enregistre: 'Enregistré · prêt à sortir' })[c.st] : 'Aucun titre en cours';
    o.curTx = c ? String(c.tx) : '—'; o.curQ = c && c.st === 'enregistre' ? String(c.Q) : '—'; o.curVir = c ? String(virOf(c, s.ui.promo)) : '—';
    o.curFeats = c && c.feats.length ? c.feats.map(function (f) { return REG.feats[f].n + ' (' + REG.feats[f].role + ')'; }).join(' · ') : 'Aucun';
    o.featN = String(c ? c.feats.length : 0); o.featMax = String(REG.maxFeats);
    Object.keys(REG.feats).forEach(function (k) { var f = REG.feats[k], on = !!(c && c.feats.indexOf(k) > -1); o['f_' + k] = on; o['nf_' + k] = !on;
      o['fl_' + k] = !!(f.need && (f.need.rival || (f.need.pop && s.pop < f.need.pop))); o['fa_' + k] = !on && !o['fl_' + k]; });
    if (c) { var bo = 1; c.feats.forEach(function (f) { bo *= REG.feats[f].boost; }); o.predL = fmt(Math.round(listensFor(c.Q || 60, s.fans, s.ui.promo) * (0.8 + virOf(c, s.ui.promo) / 250) * bo)); } else o.predL = '—';
    o.promoN = PROMO[s.ui.promo].n; o.promoC = fmt(PROMO[s.ui.promo].c); o.canRel = !!(c && c.st === 'enregistre');
    var L0 = s.disco[0]; o.hasRel = !!L0; o.noRel = !L0;
    if (L0) { o.lT = L0.title; o.lL = fmt(L0.L); o.lQ = String(L0.Q); o.lVir = String(L0.vir); o.lTier = L0.tier; o.lFans = sg(L0.fg); o.lPop = sg(L0.pg); o.lRev = fmt(L0.rev) + (L0.cut ? ' (après 35 % au label : −' + fmt(L0.cut) + ')' : ''); o.lFeat = L0.feats.length ? L0.feats.map(function (f) { return REG.feats[f].n; }).join(', ') : 'Aucun';
      o.lGap = L0.L >= ENTRY ? 'Entré au Top 100 Singles' : 'Non classé · il manque ' + fmt(ENTRY - L0.L) + ' écoutes (seuil ' + fmt(ENTRY) + ')'; o.lPct = clamp(Math.round(1000 * L0.L / ENTRY) / 10, 0, 100);
      o.lClipL = L0.clipL ? '+' + fmt(L0.clipL) + ' écoutes · ' + sg(L0.clipF) + ' fans · viralité ' + L0.vir0 + ' → ' + L0.vir : ''; o.lClipOn = !!L0.clipL; }
    o.nDisco = String(s.disco.length);
    for (var d = 0; d < 3; d++) { var D = s.disco[d]; o['d' + d + 'On'] = !!D; o['d' + d] = D ? D.title + ' · ' + fmt(D.L) + ' écoutes · ' + D.tier : ''; o['d' + d + 'c'] = D ? ({ aucun: 'Pas de clip', prepare: 'Clip préparé', produit: 'Clip tourné', publie: 'Clip publié' })[D.clip.st] : ''; }
    // clip
    var t = clipSong(s), cs = t ? t.clip.st : 'none'; o.clipT = t ? t.title : 'Aucun titre'; o.clipTSt = t ? (t.st === 'sorti' ? 'Titre sorti' : 'Titre non sorti') : '—';
    o.clipNone = cs === 'aucun'; o.clipPrep = cs === 'prepare'; o.clipShot = cs === 'produit'; o.clipPub = cs === 'publie'; o.clipNoSong = !t;
    o.clipCanPrep = !!(t && t.st !== 'sorti' && cs === 'aucun'); o.clipTooLate = !!(t && t.st === 'sorti' && cs === 'aucun'); o.clipWaitRel = !!(t && t.st !== 'sorti' && cs === 'produit'); o.clipCanPub = !!(t && t.st === 'sorti' && cs === 'produit');
    o.clipStep1 = cs !== 'aucun' && cs !== 'none'; o.clipStep2 = cs === 'produit' || cs === 'publie'; o.clipStep3 = !!(t && t.st === 'sorti'); o.clipStep4 = cs === 'publie';
    o.clipDir = t && t.clip.dir ? REG.directors[t.clip.dir].n : '—'; o.dirSel = s.ui.dir || '';
    Object.keys(REG.directors).forEach(function (k) { o['dl_' + k] = s.rank < REG.directors[k].rank; o['da_' + k] = s.rank >= REG.directors[k].rank; });
    // géographie
    Object.keys(REG.cities).forEach(function (k) { o['g_' + k] = String(Math.round(s.geo[k])); o['gw_' + k] = Math.round(s.geo[k]); });
    Object.keys(REG.conts).forEach(function (k) { var cc = REG.conts[k].c, v = cc.reduce(function (a, x) { return a + s.geo[x]; }, 0) / cc.length; o['c_' + k] = String(Math.round(v)); o['cw_' + k] = Math.round(v); });
    o.tourLock = s.rank < REG.tour.rank; o.tourOk = !o.tourLock; o.concLock = s.rank < 3; o.concOk = s.rank >= 3; o.intlLock = s.rank < REG.intl.rank; o.shows = String(s.shows);
    // économie
    Object.keys(REG.jobs).forEach(function (k) { var j = REG.jobs[k]; o['jl_' + k] = !!(j.cha && s.sk.cha < j.cha); o['je_' + k] = String(j.e - (s.own.moto ? 5 : 0)); });
    o.lastJobOn = !!s.lastJob; if (s.lastJob) { o.ljN = REG.jobs[s.lastJob.id].n; o.ljCash = '+' + fmt(s.lastJob.cash); o.ljE = '−' + s.lastJob.e; o.ljH = s.lastJob.h + ' h'; }
    Object.keys(REG.biz).forEach(function (k) { var B = REG.biz[k]; o['bo_' + k] = !!s.biz[k]; o['bl_' + k] = !s.biz[k] && s.rank < B.rank; o['ba_' + k] = !s.biz[k] && s.rank >= B.rank; o['bt_' + k] = s.biz[k] ? fmt(s.biz[k].tot) : '0'; });
    Object.keys(REG.assets).forEach(function (k) { o['ao_' + k] = !!s.own[k]; o['an_' + k] = !s.own[k]; });
    var bu = s.ui.buy && REG.assets[s.ui.buy]; o.buyN = bu ? bu.n : ''; o.buyC = bu ? fmt(bu.cost) : '0'; o.buyE = bu ? bu.eff : ''; o.buyAfter = bu ? fmt(s.cash - bu.cost) : fmt(s.cash); o.buyOk = !!(bu && s.cash >= bu.cost && !s.own[s.ui.buy]); o.buyKo = !!(bu && s.cash < bu.cost);
    var nb = Object.keys(s.own).length; o.nAssets = String(nb);
    o.patri = fmt(Object.keys(s.own).reduce(function (a, k) { return a + REG.assets[k].cost; }, 0) + Object.keys(s.biz).reduce(function (a, k) { return a + REG.biz[k].cost; }, 0));
    Object.keys(REG.merch).forEach(function (k) { var M = REG.merch[k], ok = s.fans >= M.need.fans && (!M.need.singles || s.disco.length >= M.need.singles) && (!M.need.rank || s.rank >= M.need.rank);
      o['ml_' + k] = !ok && !(s.merch && s.merch.id === k); o['ma_' + k] = ok && !s.merch; o['mo_' + k] = !!(s.merch && s.merch.id === k); o['md_' + k] = !!s.merchDone[k]; o['mt_' + k] = s.merchDone[k] ? fmt(s.merchDone[k]) : ''; });
    o.merchLeft = s.merch ? String(s.merch.left) : '0'; o.merchTot = s.merch ? fmt(s.merch.tot) : '0';
    o.signed = !!s.signed; o.signOk = !s.signed && s.rep >= REG.labelRep; o.signLock = !s.signed && s.rep < REG.labelRep; o.repLeft = String(Math.max(0, REG.labelRep - s.rep));
    o.ownRepOk = s.rep >= REG.ownLabel.rep; o.ownCashOk = s.cash >= REG.ownLabel.cash;
    // classements (D-16 A, R10, D-17 provisoire)
    var best = s.disco.reduce(function (a, x) { return Math.max(a, x.L); }, 0); o.bestL = fmt(best); o.ranked = best >= ENTRY; o.unranked = best < ENTRY; o.entry = fmt(ENTRY); o.gapL = fmt(Math.max(0, ENTRY - best)); o.gapPct = clamp(Math.round(1000 * best / ENTRY) / 10, 0, 100);
    var ip = idxParts(s), idx = ip.i; function d1(x) { return String(Math.round(x * 10) / 10).replace('.', ','); }
    o.iF = d1(ip.f); o.iG = d1(ip.g); o.iC = d1(ip.c); o.iS = d1(ip.s); o.iN = d1(ip.n); o.idx = d1(idx);
    var d0i = s.idx0 === undefined ? idx : s.idx0; o.idxD = (idx - d0i >= 0 ? '+' : '−') + d1(Math.abs(idx - d0i));
    // relations
    o.romLeft = String(REG.romPerDay - s.rom.used); o.romUsed = String(s.rom.used); o.romNone = s.rom.used >= REG.romPerDay; o.romSome = s.rom.used < REG.romPerDay;
    o.inCouple = !!s.rom.off; o.single = !s.rom.off; o.married = !!s.rom.married; o.notMarried = !s.rom.married; o.partner = s.rom.off ? CANDS[s.rom.off].n : '—';
    o.partnerG = r ? String(r.g) : '0'; o.partnerW = r ? r.g : 0; o.since = s.rom.off ? String(s.day - s.rom.since) : '0'; o.relWarn = !!(r && r.g < REG.warnAt); o.relOk = !!(r && r.g >= REG.warnAt);
    o.canPropose = canPropose(s); o.propWait = !!(r && !s.rom.married && !canPropose(s)); o.prop = !!s.rom.prop; o.noProp = !s.rom.prop;
    o.propNeedG = r ? String(Math.max(0, REG.proposeAt - r.g)) : String(REG.proposeAt); o.propNeedD = r ? String(Math.max(0, REG.proposeMinDays - (s.day - s.rom.since), s.rom.cool - s.day)) : String(REG.proposeMinDays);
    o.wsel = s.rom.wsel; o.wN = REG.weddings[s.rom.wsel].n; o.wC = fmt(REG.weddings[s.rom.wsel].cost); o.wAfter = fmt(s.cash - REG.weddings[s.rom.wsel].cost); o.wOk = s.cash >= REG.weddings[s.rom.wsel].cost; o.wKo = !o.wOk;
    o.wedDay = String(s.rom.wed); o.div = !!s.rom.div; o.hasSep = !!s.rom.sep; o.sepWhy = s.rom.sep ? s.rom.sep.why : ''; o.sepWho = s.rom.sep ? s.rom.sep.who : ''; o.sepDay = s.rom.sep ? String(s.rom.sep.d) : '';
    var ui = s.ui.cand || 'lina', C = CANDS[ui], cc2 = s.rom.c[ui]; o.cid = ui; o.cN = C.n; o.cAge = String(C.age); o.cJob = C.job; o.cCity = C.city; o.cBio = C.bio; o.cComp = String(C.comp);
    o.cLikes = C.likes.map(function (a) { return REG.romActs[a].n; }).join(' · '); o.cDis = C.dis.map(function (a) { return REG.romActs[a].n; }).join(' · ');
    o.cG = String(cc2.g); o.cW = cc2.g; o.cCanOff = !s.rom.off && cc2.g >= REG.officialAt; o.cNeedOff = String(Math.max(0, REG.officialAt - cc2.g)); o.cLockOff = !s.rom.off && cc2.g < REG.officialAt;
    o.cIsPartner = s.rom.off === ui; o.cBlocked = !!(s.rom.off && s.rom.off !== ui); o.cEx = !!(s.rom.ex[ui] && s.day < s.rom.ex[ui]); o.cFree = !o.cBlocked && !o.cEx;
    CID.forEach(function (k) { var g = s.rom.c[k].g; o['rg_' + k] = String(g); o['rw_' + k] = g; o['rx_' + k] = !!(s.rom.off && s.rom.off !== k) || !!(s.rom.ex[k] && s.day < s.rom.ex[k]); o['rp_' + k] = s.rom.off === k; o['rf_' + k] = !o['rx_' + k] && !o['rp_' + k]; o['ui_' + k] = ui === k; o['pp_' + k] = s.rom.off === k || (!s.rom.off && s.rom.sep && CANDS[k].n === s.rom.sep.who); });
    Object.keys(REG.romActs).forEach(function (a) { var m = C.likes.indexOf(a) > -1 ? REG.likeMul : C.dis.indexOf(a) > -1 ? REG.dislikeMul : 1; o['ag_' + a] = '+' + Math.round(REG.romActs[a].g * m); o['al_' + a] = m > 1; o['ad_' + a] = m < 1; });
    var la = s.rom.lastAct; o.lastRom = la ? REG.romActs[la.act].n + ' avec ' + CANDS[la.cid].n + ' : ' + sg(la.gain) + (la.mul > 1 ? ' (préférence)' : la.mul < 1 ? ' (n\'aime pas)' : '') : 'Aucune action aujourd\'hui'; o.lastRomOn = !!la;
    for (var h = 0; h < 5; h++) { var H = s.rom.hist[s.rom.hist.length - 1 - h]; o['rh' + h] = H ? 'J' + H.d + ' · ' + H.t : ''; o['rh' + h + 'On'] = !!H; }
    // famille
    var ks = s.fam.kids; o.hasKids = ks.length > 0; o.noKids = !ks.length; o.nKids = String(ks.length); o.proj = !!s.fam.proj; o.projAsked = !!s.fam.projAsked; o.projAsk = !!(s.rom.married && !s.fam.projAsked && !ks.length);
    o.kidLock = !s.rom.married && !ks.length;
    for (var q = 0; q < 2; q++) { var kk = ks[q]; o['k' + q + 'On'] = !!kk; if (kk) { var ag = kidAge(s, kk); o['k' + q + 'N'] = kk.n; o['k' + q + 'A'] = ag + ' an' + (ag > 1 ? 's' : ''); o['k' + q + 'S'] = stageOf(ag); o['k' + q + 'L'] = String(kk.l); o['k' + q + 'W'] = kk.l; o['k' + q + 'G'] = kk.garde;
      Object.keys(REG.kidActs).forEach(function (a) { o['k' + q + 'ok_' + a] = ag >= REG.kidActs[a].min; o['k' + q + 'no_' + a] = ag < REG.kidActs[a].min; }); }
      else { o['k' + q + 'N'] = ''; o['k' + q + 'A'] = ''; o['k' + q + 'S'] = ''; o['k' + q + 'L'] = '0'; o['k' + q + 'W'] = 0; o['k' + q + 'G'] = ''; } }
    var fe = s.fam.ev ? FEV[s.fam.ev] : null; o.hasFev = !!fe; o.noFev = !fe; o.fevT = fe ? fe.t : ''; o.fevQ = fe ? fe.q : ''; o.fevA = fe ? fe.a.n : ''; o.fevB = fe ? fe.b.n : '';
    o.fevAc = fe ? csq(fe.a) : ''; o.fevBc = fe ? csq(fe.b) : ''; o.fevDone = s.fam.evDone ? s.fam.evDone.t + ' : ' + s.fam.evDone.ch : ''; o.fevDoneOn = !!s.fam.evDone;
    o.famCost = fmt((s.rom.off ? REG.coupleCost : 0) + ks.length * REG.kidCost);
    // avatar
    o.apHair = ({ hitwist: 'Twists hi-top', afro: 'Afro', cornrows: 'Nattes collées' })[s.ap.hair]; o.apTop = ({ hoodie: 'Hoodie Néon', bomber: 'Bomber violet', tee: 'T-shirt cyan' })[s.ap.top];
    ['hitwist', 'afro', 'cornrows'].forEach(function (h1) { ['hoodie', 'bomber', 'tee'].forEach(function (t1) { o['av_' + h1 + '_' + t1] = s.ap.hair === h1 && s.ap.top === t1; }); });
    // sauvegarde (simulation)
    o.saveSize = String(JSON.stringify(s).length); o.saveT = s.t ? 'Enregistré dans ce navigateur' : 'État de démonstration (rien n\'est encore enregistré)';
    o.nLog = String(s.log.length);
    // artiste
    var P = s.p, nm = s.created ? P.name : (cleanName(P.name) || 'Nouvel artiste');
    o.name = nm; o.initials = nm.split(' ').map(function (w) { return w.charAt(0); }).join('').slice(0, 2).toUpperCase() || 'NA';
    o.created = !!s.created; o.notCreated = !s.created; o.pName = P.name; o.pAge = String(P.age); o.nameOk = nameOk(P.name); o.nameKo = !nameOk(P.name); o.nameEmpty = !cleanName(P.name);
    o.nameErr = !cleanName(P.name) ? 'Choisis un nom de scène pour continuer.' : !nameOk(P.name) ? 'De ' + REG.nameRule.min + ' à ' + REG.nameRule.max + ' caractères : lettres, chiffres, espace, tiret, apostrophe ou point.' : '';
    o.originN = REG.origins[P.origin]; var co = Object.keys(REG.conts).filter(function (k) { return REG.conts[k].c.indexOf(P.origin) > -1; })[0]; o.originC = co ? REG.conts[co].n : '';
    o.mainN = REG.styles[P.main].n; o.mainK = REG.styles[P.main].kn; o.secondN = P.second ? REG.styles[P.second].n : 'Aucun'; o.secondK = P.second ? REG.styles[P.second].kn : '';
    o.styleLine = REG.styles[P.main].n + (P.second ? ' · ' + REG.styles[P.second].n : ''); o.goalN = REG.goals[P.goal].n;
    o.ageMin = P.age <= REG.ages[0]; o.ageMax = P.age >= REG.ages[1]; o.enStart = String(enMaxAge(P.age));
    Object.keys(REG.styles).forEach(function (k) { o['sm_' + k] = P.main === k; o['ss_' + k] = P.second === k; o['sn_' + k] = P.main !== k && P.second !== k; });
    o.skinN = REG.skins[s.ap.skin] || '';
    ['hitwist', 'afro', 'cornrows'].forEach(function (h1) { ['hoodie', 'bomber', 'tee'].forEach(function (t1) { Object.keys(REG.skins).forEach(function (sk) { o['av_' + h1 + '_' + t1 + '_' + sk] = s.ap.hair === h1 && s.ap.top === t1 && (s.ap.skin || '3') === sk; }); }); });
    o.uv1 = (s.ui.uv || 1) === 1; o.uv2 = s.ui.uv === 2; o.uv3 = s.ui.uv === 3;
    // événements
    var E = s.ev ? EVT[s.ev] : null; o.evOn = !!E; o.evOff = !E; o.evT = E ? E.t : ''; o.evWho = E ? E.who : ''; o.evQ = E ? E.q : ''; o.evKey = s.ev || '';
    ['kzer', 'kore', 'label'].forEach(function (k) { o['ev_' + k] = s.ev === k; });
    for (var c = 0; c < 3; c++) { var C = E && E.ch[c]; o['ec' + c + 'On'] = !!C; o['ec' + c] = C ? C.n : ''; o['ec' + c + 'c'] = C ? C.c : ''; }
    o.evMore = String(s.evq.length); o.evLastOn = !!s.evLast; o.evLast = s.evLast ? s.evLast.t + ' : ' + s.evLast.ch : ''; o.evLastC = s.evLast ? s.evLast.c : '';
    o.koreSt = s.kc && s.kc.st ? s.kc.st + (s.kc.left > 0 ? ' · +' + s.kc.bonus + ' de production sur ' + s.kc.left + ' titre(s)' : '') : 'Aucun accord';
    // missions
    var mn = REG.missions.filter(function (m) { return !s.ms[m.id]; })[0]; o.msOn = !!mn; o.msAll = !mn; o.msT = mn ? mn.t : 'Toutes les missions de départ sont faites'; o.msR = mn ? '+' + fmt(mn.cash) + ' cauris · +' + mn.xp + ' XP' : '';
    o.msN = String(REG.missions.filter(function (m) { return s.ms[m.id]; }).length); o.msTot = String(REG.missions.length);
    REG.missions.forEach(function (m) { o['ms_' + m.id] = !!s.ms[m.id]; o['mt_' + m.id] = !s.ms[m.id]; });
    // journal
    var CAT = { musique: 'Studio', scene: 'Scène', eco: 'Argent', perso: 'Vie perso', carriere: 'Carrière', mission: 'Mission', evenement: 'Événement', jeu: 'Jeu' };
    for (var j3 = 0; j3 < 12; j3++) { var Lg = s.log[j3]; o['jl' + j3 + 'On'] = !!Lg; o['jl' + j3] = Lg ? Lg.t : ''; o['jd' + j3] = Lg ? 'J' + Lg.d + ' · ' + (CAT[Lg.c] || 'Jeu') : ''; }
    o.noLog = !s.log.length;
    // scène : billetterie, délais
    o.tickets = String(tickets(s)); o.ticketCash = fmt(tickets(s) * REG.ticketPrice); o.concertWait = String(Math.max(0, REG.concertEvery - (s.day - s.lastConcert))); o.concertReady = s.rank >= 3 && s.day - s.lastConcert >= REG.concertEvery; o.concertCool = s.rank >= 3 && s.day - s.lastConcert < REG.concertEvery;
    var aud = (s.geo.portambre + s.geo.selene) / 2; o.tourAud = String(Math.round(aud * 10) / 10); o.tourAudOk = aud >= REG.tourAudience; o.tourWait = String(Math.max(0, REG.tourEvery - (s.day - s.lastTour)));
    o.tourReady = s.rank >= 3 && aud >= REG.tourAudience && s.day - s.lastTour >= REG.tourEvery; o.tourNoAud = s.rank >= 3 && aud < REG.tourAudience; o.tourCool = s.rank >= 3 && aud >= REG.tourAudience && s.day - s.lastTour < REG.tourEvery;
    o.tourFee = fmt(REG.tour.fee + Math.round(REG.tour.feeGeo * (s.geo.portambre + s.geo.selene)));
    var cc = s.cc; o.ccOn = !!cc; o.ccOff = !cc; o.ccG = cc ? (cc.tour ? 'Tournée' : 'Note ' + cc.g) : ''; o.ccTk = cc ? String(cc.tk) : '0'; o.ccCash = cc ? fmt(cc.cash) : '0'; o.ccFans = cc ? '+' + fmt(cc.fans) : '0'; o.ccRep = cc ? '+' + cc.rep : '0'; o.ccTour = !!(cc && cc.tour); o.ccSalle = !!(cc && !cc.tour); o.ccFill = cc ? Math.round(100 * cc.tk / REG.capacity) : 0;
    // classements (D-16 A : non classé tant que le seuil n'est pas atteint)
    var bestS = s.disco.reduce(function (a, x) { return x.L > a.L ? x : a; }, { L: 0, title: '' });
    var sr = bestS.L >= ENTRY ? Math.max(8, Math.min(100, Math.round(7 * Math.pow(bestS.L / 8e6, -1 / 1.3)))) : 0;
    o.sRank = sr ? '#' + sr : 'Non classé'; o.sRanked = !!sr; o.sUn = !sr; o.sTitle = bestS.title || 'Aucun titre sorti'; o.sL = fmt(bestS.L);
    var gr = ip.i >= 76.3 ? Math.max(1, Math.round(10 * Math.pow(ip.i / 76.3, -1 / 1.19))) : 0; o.gRank = gr ? '#' + gr : 'Non classé'; o.gIn = !!gr; o.gOut = !gr; o.gGap = d1(Math.max(0, 76.3 - ip.i));
    return o;
  }
  function idxParts(s) {   // R10 : poids 25/15/30/20/10 ; échelles 0-100 de l'étude D-17 v20 (provisoires)
    function lg(x, ref, x0) { return 100 * Math.min(1, Math.log10(1 + Math.max(x, 0) / x0) / Math.log10(1 + ref / x0)); }
    var cat = s.disco.reduce(function (a, x) { return a + x.L; }, 0), ip = { f: lg(s.fans, 5e6, 1e3), g: lg(s.fans - 120, 200e3, 1e3), c: lg(cat, 30e6, 1e4), s: lg(s.shows * 300, 2e6, 5e2), n: Math.min(100, s.pop) };
    ip.i = 0.25 * ip.f + 0.15 * ip.g + 0.30 * ip.c + 0.20 * ip.s + 0.10 * ip.n; return ip;
  }
  function csq(x) { var p = []; if (x.g) p.push('relation ' + sg(x.g)); if (x.l) p.push('lien enfant ' + sg(x.l)); if (x.cash) p.push(sg(x.cash) + ' cauris'); if (x.e) p.push('énergie ' + sg(x.e)); if (x.h) p.push(x.h + ' h'); return p.join(' · '); }
  return { EVT: EVT, nameOk: nameOk, REG: REG, CANDS: CANDS, PROMO: PROMO, ENTRY: ENTRY, init: init, act: act, view: view, fmt: fmt, A: A, PRE: PRE, enMaxAge: enMaxAge, FEV: FEV };
});
