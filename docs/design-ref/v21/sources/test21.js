// Tests du moteur v21 : parcours A à H et états impossibles. node test21.js
const E = require('./engine21.js'); let ok = 0, ko = 0;
function T(name, cond) { if (cond) ok++; else { ko++; console.log('ÉCHEC', name); } }
function run(s, name, arg) { const r = E.act(s, name, arg); return r; }
function must(s, name, arg) { const r = run(s, name, arg); if (r.err) { console.log('ERREUR inattendue', name, arg, r.err); ko++; return s; } return r.s; }
const V = s => E.view(s);

// Parcours A — journée normale
let s = E.init();
s = must(s, 'job', 'livraison'); T('A boulot paie', s.cash === 28500 && s.en === 75 && s.hour === 12);
s = must(s, 'openmic'); T('A open mic', s.fans === 270);
const h0 = s.hour; let r = run(s, 'job', 'maquis'); // 17h + 5 = 22 ok
s = r.s; T('A deuxième boulot', !r.err);
s = must(s, 'job', 'livraison'); r = run(s, 'job', 'mc'); T('A pas de boulot après 24 h', r.err === 'tard');
s = must(s, 'endDay'); T('A jour suivant', s.day === 2 && s.hour === 8 && s.en === 100);
T('A bilan', s.bil && s.bil.cash === 3500 + 3000 + 4500 + 3500 && s.bil.acts.length >= 3);
T('A bilan vue', V(s).bCash === '+14 500');

// Parcours B — création musicale
s = E.init();
r = run(s, 'record'); T('B pas d\'enregistrement sans texte', r.err === 'pasdetexte');
s = must(s, 'create', ['ambition', 'fiere']); T('B texte', s.cur.st === 'ecrit' && s.cur.tx === 76);
r = run(s, 'release'); T('B pas de sortie non enregistrée', r.err === 'pasenregistre');
s = must(s, 'feat', 'nadia'); T('B featuring payé', s.cash === 17000 && s.cur.feats.length === 1);
T('B Zaki indisponible (rivalité)', run(s, 'feat', 'zaki').err === 'rival');
T('B Orage verrouillée (pop 30)', run(s, 'feat', 'orage').err === 'pop');
s = must(s, 'record'); T('B qualité', s.cur.Q > 0 && s.cur.st === 'enregistre');
T('B titre non sorti absent de la discographie', s.disco.length === 0 && V(s).noRel);
s = must(s, 'release'); T('B sorti', s.disco.length === 1 && s.cur === null && s.disco[0].st === 'sorti');
const d = s.disco[0]; T('B indicateurs distincts', d.Q !== d.vir && typeof d.tier === 'string' && s.pop > 3);
T('B non classé', V(s).unranked && V(s).lGap.indexOf('Non classé') === 0);
T('B rang progresse (XP)', s.xp === 70);
let s2 = must(E.init(), 'create', 'random'); T('B création aléatoire', s2.cur.mode === 'aléatoire');

// Parcours C — clip
s = E.init(); s.cash = 100000;
s = must(s, 'create', ['quartier', 'sombre']);
s = must(s, 'clipPrep', 'sika'); T('C préparé avant sortie', s.cur.clip.st === 'prepare');
T('C pas de publication avant tournage', run(s, 'clipPub').err === 'avantsortie' || run(s, 'clipPub').err === 'pasproduit');
s = must(s, 'clipShoot'); T('C tourné', s.cur.clip.st === 'produit');
T('C publication interdite avant sortie', run(s, 'clipPub').err === 'avantsortie');
s = must(s, 'endDay'); s = must(s, 'record'); s = must(s, 'release');
const L0 = s.disco[0].L; s = must(s, 'clipPub'); T('C publié après sortie', s.disco[0].clip.st === 'publie' && s.disco[0].L > L0);
let s3 = must(must(must(E.init(), 'create', ['quartier', 'sombre']), 'record'), 'release');
T('C préparation impossible après sortie', run(s3, 'clipPrep', 'sika').err === 'clipapres');
T('C réalisateur verrouillé par rang', run(must(E.init(), 'create', ['quartier', 'sombre']), 'clipPrep', 'ilan').err === 'rang');

// Parcours D — relation
s = E.init(); s.cash = 100000;
s = must(s, 'rom', ['lina', 'sortie']); T('D préférence x1.5', s.rom.c.lina.g === 12);
s = must(s, 'rom', ['kadi', 'parler']); T('D courtiser plusieurs', s.rom.c.kadi.g === 6);
T('D max 2 actions par jour', run(s, 'rom', ['lina', 'parler']).err === 'romjour');
T('D officialisation sous le seuil refusée', run(s, 'official', 'lina').err === 'seuil');
s = must(s, 'endDay'); T('D baisse quotidienne sans entretien', s.rom.c.lina.g === 12 && s.rom.c.kadi.g === 6);
s = must(s, 'endDay'); T('D baisse', s.rom.c.lina.g === 11 && s.rom.c.kadi.g === 5);
T('D scène sans concert refusée', run(s, 'rom', ['lina', 'scene']).err === 'pasdeconcert');
for (let i = 0; i < 6; i++) { s = must(s, 'rom', ['lina', 'sortie']); s = must(s, 'rom', ['lina', 'sortie']); s = must(s, 'endDay'); }
T('D jauge ≥ 60', s.rom.c.lina.g >= 60);
s = must(s, 'official', 'lina'); T('D couple', s.rom.off === 'lina');
T('D exclusivité', run(s, 'rom', ['kadi', 'parler']).err === 'exclusif' && run(s, 'official', 'kadi').err === 'exclusif');

// Parcours E — mariage et famille
T('E mariage pas encore possible', run(s, 'proposal', 'oui').err === 'condmariage');
T('E pas d\'enfant avant mariage', run(s, 'famProj', 'oui').err === 'mariage');
while (s.day - s.rom.since < 14 || s.rom.c.lina.g < 80) { s = must(s, 'rom', ['lina', 'sortie']); s = must(s, 'endDay'); }
T('E demande disponible', V(s).canPropose);
let sr = must(s, 'proposal', 'non'); T('E refus : baisse et délai', sr.rom.c.lina.g === s.rom.c.lina.g - 12 && !V(sr).canPropose);
s.cash += 200000; /* test : trésorerie pour la cérémonie */ s = must(s, 'proposal', 'oui'); s = must(s, 'wsel', 'simple'); s = must(s, 'wed'); T('E marié', s.rom.married === 1);
s = must(s, 'famProj', 'oui'); let born = false;
for (let i = 0; i < 30 && !born; i++) { s = must(s, 'rom', ['lina', 'parler']); s = must(s, 'endDay'); born = s.fam.kids.length > 0; }
T('E enfant après mariage (non automatique, projet requis)', born);
T('E bilan mentionne la naissance', s.bil.ev.some(e => e.indexOf('Naissance') === 0));
s = must(s, 'kid', ['0', 'jouer']); T('E interaction parent-enfant', s.fam.kids[0].l === 56);
T('E devoirs : âge requis', run(s, 'kid', ['0', 'devoirs']).err === 'age');
for (let i = 0; i < 7; i++) s = must(s, 'skipYear');
T('E vieillissement enfant', V(s).k0S === 'Enfant' && s.age === 19 + 7);
T('E énergie max selon l\'âge', E.enMaxAge(30) === 95);

// Parcours F — séparation
const before = s.fam.kids.length, hist = s.rom.hist.length;
s = must(s, 'separate'); T('F séparation', !s.rom.off && !s.rom.married && s.rom.div === 1);
T('F histoire et enfant conservés', s.fam.kids.length === before && s.rom.hist.length === hist + 1 && s.fam.kids[0].garde === 'Garde partagée');
T('F ex bloqué', run(s, 'rom', ['lina', 'parler']).err === 'ex');
// rupture par le partenaire (non aléatoire : jauge sous 20)
let p = E.PRE.couple(); p.rom.c.lina.g = 21; p = must(p, 'endDay'); p = must(p, 'endDay');
T('F rupture par le partenaire sous 20', !p.rom.off && p.rom.hist.some(h => h.t.indexOf('Rupture décidée par Lina') === 0));
let w = E.PRE.couple(); w.rom.c.lina.g = 29; w = must(w, 'endDay'); T('F avertissement avant rupture', w.bil.ev.some(e => e.indexOf('Attention') === 0));

// Parcours G — économie
s = E.init(); T('G entreprise verrouillée N3', run(s, 'bizBuy', 'couplet').err === 'rang');
s = E.PRE.carriere(); s = must(s, 'bizBuy', 'couplet'); s = must(s, 'endDay'); T('G revenu entreprise estimé', s.biz.couplet.tot >= 3000 && s.biz.couplet.tot <= 5000);
const c0 = s.cash + 200000; s.cash = c0; s = must(s, 'ask', 'homestudio'); s = must(s, 'assetBuy'); T('G bien acheté', !!s.own.homestudio && s.cash === c0 - 180000);
s = must(s, 'create', ['quartier', 'sombre']); const e0 = s.en; s = must(s, 'record'); T('G effet home studio', e0 - s.en === 15 && s.disco.length === 1 && s.cur.prod === 32 + 4);
T('G merch verrouillé sans 1 000 fans', run(E.init(), 'merch', 'tshirt').err === 'fans');
s = E.PRE.carriere(); s = must(s, 'merch', 'tshirt'); s = must(s, 'endDay'); T('G merch vend (plafonné)', s.merch.tot === Math.round(0.8 * Math.sqrt(2400) * 30));
T('G signature label (rép. 31)', !run(E.PRE.carriere(), 'sign').err);

// Parcours H — carrière et popularité
s = E.PRE.carriere(); const g0 = s.geo.portambre; s = must(s, 'tour'); T('H tournée : géo', s.geo.portambre === g0 + 8 && s.geo.selene === 11);
T('H tournée verrouillée N1', run(E.init(), 'tour').err === 'rang');
s = must(s, 'endDay'); T('H promotion N4 (3 200 XP, pop 20, 1 concert)', s.rank === 4);
const v = V(s); T('H continents distincts des villes', v.c_solo !== v.g_bakoma && v.c_tam === '0');
T('H index calculé', +v.idx.replace(',', '.') > 0);

// Nouvelle année et patrimoine
let y = E.init(); y.age = 29; y = must(y, 'skipYear'); T('Âge 30 : énergie max 95', y.en === 95 && y.bil.aged.em1 === 95);
let y2 = E.init(); y2.age = 29; y2.cash = 400000; y2 = must(y2, 'ask', 'appart'); y2 = must(y2, 'assetBuy'); y2 = must(y2, 'skipYear'); T('Appartement compense +5', y2.en === 100);
console.log('tests réussis', ok, 'échecs', ko); if (ko) process.exitCode = 1;
// ===== v21.2 : création, événements, missions, correctifs d'audit =====
let ok2 = 0, ko2 = 0; function U(n, c) { if (c) ok2++; else { ko2++; console.log('ÉCHEC', n); } }
let c = E.init(); U('création : nom vide refusé', E.act(c, 'finish').err === 'nom');
c = E.act(c, 'setp', 'name=A').s; U('création : nom trop court refusé', E.act(c, 'finish').err === 'nom');
c = E.act(c, 'setp', 'name=<script>').s; U('création : caractères interdits refusés', E.act(c, 'finish').err === 'nom');
c = E.act(c, 'setp', 'name=  Young   SM  ').s; for (let i = 0; i < 20; i++) c = E.act(c, 'setp', 'age=+').s; U('âge plafonné à 30', c.p.age === 30);
c = E.act(c, 'setp', 'age=-').s; c = E.act(c, 'setp', 'origin=tamarel').s; c = E.act(c, 'setp', 'main=trap').s; c = E.act(c, 'setp', 'second=trap').s;
U('second style ≠ style principal', c.p.second === null); c = E.act(c, 'setp', 'second=coupe').s; c = E.act(c, 'setp', 'main=coupe').s; U('principal remplace le second identique', c.p.main === 'coupe' && c.p.second === null);
c = E.act(c, 'setp', 'second=trap').s; c = E.act(c, 'finish').s;
U('création appliquée', c.created === 1 && c.p.name === 'Young SM' && c.age === 29 && c.sk.cha === 11 && c.sk.voix === 11 && c.geo.tamarel === 4 && c.ev === 'kzer');
U('création une seule fois', E.act(c, 'finish').err === 'deja');
U('énergie selon l\'âge choisi', E.enMaxAge(29) === 100);
c = E.act(c, 'evc', 'a').s; U('défi accepté : battle en attente', c.btq === 'kzer' && c.rep === 8); c = E.act(c, 'battle', 2).s; U('défi de K-Zer résolu', c.ev === null && c.rep === 14 && c.btq === null && c.evDone.kzer === 'a' && !c.ms.m3);
U('événement déjà résolu', E.act(c, 'evc', 'a').err === 'rien');
c = E.act(c, 'setui', 'title=Ndolo en feu').s; c = E.act(c, 'create', ['quartier', 'sombre']).s; U('titre manuel', c.cur.title === 'Ndolo en feu' && c.ui.title === '');
c = E.act(c, 'record').s; U('mission 1 et dialogue de Kôrô', !!c.ms.m1 && c.dlg && c.dlg.id === 'kore' && c.dlg.node === 'n1' && c.cash === 33000);
c = E.act(c, 'dch', 'a').s; c = E.act(c, 'dch', 'b').s; U('négociation : −5 énergie, nœud suivant', c.dlg.node === 'n3');
U('Kôrô : cash insuffisant', E.act(Object.assign(JSON.parse(JSON.stringify(c)), { cash: 100 }), 'dch', 'a').err === 'cash');
c = E.act(c, 'dch', 'a').s; U('accord Kôrô (35 %, mix signé)', c.kc.left === 3 && c.kc.bonus === 12 && c.cash === 26000 && c.dlg.done && c.rel.kore === 8); c = E.act(c, 'dclose').s;
c = E.act(c, 'release').s; U('mission 2', !!c.ms.m2);
c = E.act(c, 'endDay').s; c = E.act(c, 'create', ['quartier', 'sombre']).s; const q0 = c.cur.tx; c = E.act(c, 'record').s; U('bonus de production Kôrô (instru gratuite 32 + 12)', c.cur.prod === 44 && c.kc.left === 2);
let pc = E.act(E.init(), 'preset', 'carriere').s; pc = E.act(pc, 'concert').s; const cc1 = pc.cc;
U('concert : billetterie', cc1.tk === Math.min(300, Math.round(40 + 2400 * 0.05 + 14 * 4)) && pc.cash > 320000);
U('concert : délai de 7 jours', E.act(pc, 'concert').err === 'delai');
for (let i = 0; i < 7; i++) pc = E.act(pc, 'endDay').s; U('concert à nouveau possible', !E.act(pc, 'concert').err);
let pt = E.act(E.init(), 'preset', 'carriere').s; pt.geo.portambre = 1; pt.geo.selene = 1; U('tournée : audience insuffisante', E.act(pt, 'tour').err === 'audience');
let pm = E.act(E.init(), 'preset', 'debut').s; pm = E.act(pm, 'job', 'mc').s; U('MC ne donne plus de popularité', pm.pop === 3);
let pr = E.act(E.init(), 'preset', 'carriere').s; U('preset : missions déjà faites non repayées', pr.ms.m1 && pr.ms.m4 && E.act(pr, 'job', 'livraison').s.cash === 320000 + 3500);
console.log('tests v21.2 réussis', ok2, 'échecs', ko2); if (ko2) process.exitCode = 1;
// décisions du 16/10 (Smith)
{
  const R = (s, n, a) => E.act(s, n, a);
  let a = E.act(E.init(), 'preset', 'debut').s; const c0 = a.cash, e0 = a.sk.ecr;
  a = R(a, 'atelier').s; console.log((a.ms.m3 && a.sk.ecr === e0 + 5 && a.cash === c0 - 6000 + 4000 ? 'ok' : 'ÉCHEC') + ' atelier : mission 3, Écriture +5, coût 6 000');
  console.log((E.REG.ranks[2].xp === 1500 ? 'ok' : 'ÉCHEC') + ' seuil N3 relevé à 1 500 XP');
  let b = E.act(E.init(), 'preset', 'carriere').s; b.signed = 1; b = R(b, 'create').s; b = R(b, 'record').s; b = R(b, 'release').s; const t = b.disco[0];
  console.log((t.cut === Math.round(t.L * 0.01) - t.streamRev + t.salesCut && t.salesCut + t.salesRev === Math.round(t.L * 0.012) * 30 && t.salesCut > 0 && t.cut > 0 ? 'ok' : 'ÉCHEC') + ' label : 35 % des revenus d\'écoutes retenus');
  let x = E.act(E.init(), 'preset', 'debut').s; for (let d = 0; d < 7; d++) { x = R(x, 'openmic').s; x = R(x, 'endDay').s; } console.log((x.rank < 3 ? 'ok' : 'ÉCHEC') + ' pas de N3 en une semaine (rang ' + x.rank + ', ' + x.xp + ' XP)');
}
// réintégration studio et battle (17/10)
{
  const R = (s, n, a) => E.act(s, n, a); const ok = (c, t) => console.log((c ? 'ok' : 'ÉCHEC') + ' ' + t);
  let a = E.act(E.init(), 'preset', 'debut').s;
  ok(R(a, 'pick', 'pont').err === 'rang', 'instru Pont des Griots verrouillée en N1');
  ok(R(a, 'pick', 'lagune').err === 'rep', 'Lagune d\'Ambre : réputation 30 requise');
  let b = R(a, 'pick', 'gbaka').s; ok(b.cash === a.cash - 8000 && R(b, 'pick', 'gbaka').s.cash === b.cash, 'instru payée une seule fois');
  b = R(R(b, 'create').s, 'record', [90, 80, 70]).s; ok(b.cur.voix === 80 && b.cur.prod === 56 && b.cur.inst === 'gbaka' && b.ui.inst === null, 'prises et instru dans la qualité');
  ok(b.cur.Q === Math.round(0.35 * b.cur.tx + 0.30 * 80 + 0.35 * 56), 'formule de qualité v20 (texte, voix, production)');
  ok(R(a, 'battle', 3).err === 'rien', 'pas de battle sans défi');
  let c = R(a, 'evc', 'a').s; let l = R(c, 'battle', 1).s; ok(l.fans === a.fans + 12 && l.rep === a.rep && l.bt.win === 0, 'battle perdue 1 / 3');
  let w = R(c, 'battle', 2).s; ok(w.fans === a.fans + 150 && w.rep === a.rep + 6 && w.cash === a.cash + 3000 && w.en === a.en - 15, 'battle gagnée 2 / 3');
}
// dialogues interactifs (17/10)
{
  const R = (s, n, a) => { const r = E.act(s, n, a); if (r.err) throw new Error(n + ' ' + a + ' ' + r.err); return r.s; }; const ok = (c, t) => console.log((c ? 'ok' : 'ÉCHEC') + ' ' + t);
  let a = E.act(E.init(), 'preset', 'debut').s;
  let k = R(R(a, 'create'), 'record'); k = R(k, 'dch', 'a'); k = R(k, 'dch', 'c'); ok(k.dlg.done && k.dq.some(x => x.id === 'kore2' && x.at === k.day + 21) && k.rel.kore === -10, 'refus de Kôrô : retour programmé à 21 jours');
  k = R(k, 'dclose'); for (let d = 0; d < 21; d++) k = R(k, 'endDay'); ok(k.dlg && (k.dlg.id === 'kore2' || k.dq.some(x => x.id === 'kore2')), 'Kôrô revient après 3 semaines');
  let m = a; for (let d = 0; d < 2; d++) m = R(m, 'endDay'); ok(m.dlg && m.dlg.id === 'mgr', 'manager proposée au jour 3');
  m = R(R(m, 'dch', 'a'), 'dch', 'a'); ok(m.mgr === 'maya', 'Maya engagée'); m = R(m, 'dclose');
  const c0 = m.cash; m = R(m, 'openmic'); ok(m.cash === c0 + 3000 - 240, 'commission de 8 % sur le cachet');
  let l = E.act(E.init(), 'preset', 'carriere').s; l = R(l, 'job', 'livraison'); ok(l.dlg.id === 'mgr', 'carrière : la manager passe avant le label'); l = R(R(l, 'dch', 'b'), 'dclose'); const seen = []; while (l.dlg && l.dlg.id !== 'label') { seen.push(l.dlg.id); l = R(R(l, 'dch', 'c'), 'dclose'); } ok(l.dlg && l.dlg.id === 'label' && seen.indexOf('lb_VAG') > -1, 'offre de BSR à 30 de réputation, après les petits labels (' + seen.join(', ') + ')');
  const l0 = l.cash; l = R(R(l, 'dch', 'b'), 'dch', 'a'); ok(l.signed && l.lcut === 0.40 && l.cash === l0 + 180000, 'contre-offre : 180 000 et 40 %');
  l = R(l, 'dclose'); l.ui.inst = null; l = R(R(R(l, 'create'), 'record'), 'release'); const t = l.disco[0]; ok(t.cut === Math.round(t.L * 0.01) - t.streamRev + t.salesCut && t.salesCut + t.salesRev === Math.round(t.L * 0.012) * 30 && Math.abs(t.salesCut - Math.round(t.L * 0.012) * 30 * 0.40) <= 1, 'part du label selon le contrat signé (écoutes et ventes)');
  let x = E.act(E.init(), 'preset', 'debut').s; x = R(x, 'dstart', 'collab'); x = R(R(x, 'dch', 'b'), 'dch', 'a'); x = R(x, 'dclose'); x = R(x, 'create'); ok(x.cur.feats.indexOf('ayana') > -1 && x.cur.duo === 40, 'duo Ayana appliqué au titre suivant (40 %)');
  ok(E.act(x, 'dch', 'a').err === 'rien', 'pas de choix hors dialogue');
}
// offres des 9 autres labels (17/10)
{
  const R = (s, n, a) => { const r = E.act(s, n, a); if (r.err) throw new Error(n + ' ' + a + ' ' + r.err); return r.s; }; const ok = (c, t) => console.log((c ? 'ok' : 'ÉCHEC') + ' ' + t);
  ok(Object.keys(E.LBL).length === 9 && Object.keys(E.LBL).every(k => E.DLG['lb_' + k]), '9 labels ont leur dialogue');
  let a = E.act(E.init(), 'preset', 'debut').s; a.rep = 13; a = R(R(R(a, 'create'), 'record'), 'release');
  const skip = x => { while (!x.dlg.done) { const ch = E.DLG[x.dlg.id].nodes[x.dlg.node].ch; x = R(x, 'dch', ch[ch.length - 1].id); } return R(x, 'dclose'); };
  while (a.dlg && a.dlg.id !== 'lb_AUB') a = skip(a);
  ok(a.dlg && a.dlg.id === 'lb_AUB', 'Aube Nouvelle appelle dès réputation 12 et un single');
  const c0 = a.cash; let b = R(R(a, 'dch', 'b'), 'dch', 'a'); ok(b.signed && b.label === 'AUB' && b.lcut === 0.15 && b.cash === c0 + 30000 && b.lperk === 'dev', 'contre-offre Aube Nouvelle : 15 %');
  b = R(b, 'dclose'); b.rep = 40; b = R(b, 'job', 'livraison'); ok(!b.dlg || !/^lb_|^label$/.test(b.dlg.id), 'plus aucune offre une fois signé');
  b = R(b, 'endDay'); if (b.dlg) b = skip(b); const f0 = b.sk.flow; b = R(R(R(b, 'create'), 'record'), 'release'); ok(b.sk.flow === f0 + 1, 'avantage Aube Nouvelle : Flow +1 par sortie');
  let k = E.act(E.init(), 'preset', 'carriere').s; k.rel.kore = 10; k.disco.push(JSON.parse(JSON.stringify(k.disco[0]))); k = R(k, 'dstart', 'lb_SKP'); k = R(k, 'dch', 'a'); ok(k.label === 'SKP' && k.kc.left === 3 && k.kc.bonus === 12, 'Studio Kôrô Productions : production +12 sur 3 titres');
  let m = E.act(E.init(), 'preset', 'carriere').s; m = R(R(m, 'dstart', 'lb_AMG'), 'dch', 'a'); m.ui.promo = 2; m = R(R(R(m, 'create'), 'record'), 'release'); ok(m.cash > 0 && m.disco[0].promo === 2, 'Ambre Music Group : promo radio offerte');
}
// catalogue, projets, justice (17/10)
{
  const R = (s, n, a) => { const r = E.act(s, n, a); if (r.err) throw new Error(n + ' ' + a + ' ' + r.err); return r.s; }; const ok = (c, t) => console.log((c ? 'ok' : 'ÉCHEC') + ' ' + t);
  let a = E.act(E.init(), 'preset', 'star').s; a.cash = 2e6;
  for (let i = 0; i < 2; i++) { a = R(R(R(a, 'create'), 'record'), 'release'); a = R(a, 'endDay'); a.dlg = null; a.dq = []; }
  ok(a.disco[0].labelAt && a.disco[0].prodBy && a.disco[0].auteur === 'Djo Kéné' && a.disco[0].sales >= 0, 'crédits, label et ventes enregistrés à la sortie');
  ok(E.act(a, 'prel').err === 'pistes', 'EP refusé sans titres choisis');
  a = R(a, 'ptype', 'EP'); a.disco.slice(0, 3).forEach(t => { a = R(a, 'ptk', t.id); }); a = R(a, 'setui', 'ptitle=Ndo Sessions');
  const c0 = a.cash; a = R(a, 'prel'); const p = a.projects[0];
  ok(p.type === 'EP' && p.tracks.length === 3 && p.title === 'Ndo Sessions' && a.cash === c0 - 15000 + p.rev, 'EP de 3 titres sorti (coût 15 000, revenus des ventes)');
  ok(E.act(R(a, 'ptype', 'Album'), 'prel').err === 'pistes', 'album refusé sous 8 titres');
  let c = E.act(E.init(), 'preset', 'carriere').s, n = 0; ok(E.act(c, 'crime', 'recel').err === 'mature', 'activités illégales bloquées tant que le contenu mature est désactivé'); c = R(c, 'mature', 'on'); while (!c.cas && n < 12) { c = R(c, 'crime', 'braquage'); if (!c.cas) c = R(c, 'endDay'); n++; }
  ok(c.cas && c.cas.stage === 'garde' && c.hour === 24, 'arrestation : garde à vue');
  ok(E.act(c, 'job', 'livraison').err === 'garde', 'aucune activité en garde à vue');
  ok(E.act(c, 'crime', 'recel').err === 'garde', 'pas de nouveau délit pendant la garde à vue');
  let d = R(c, 'detention'); ok(d.jail && d.jail.pre, 'détention provisoire'); ok(E.act(d, 'record').err === 'prison', 'pas de studio en prison');
  d = R(d, 'jw'); ok(E.act(d, 'jw').err === 'deja', 'écrire en cellule une fois par jour');
  for (let i = 0; i < 3; i++) d = R(d, 'endDay'); ok(!d.jail, 'sortie de détention le jour du procès');
  const pop0 = d.pop; d = R(d, 'trial', 'coupable'); ok(d.verdict && !d.verdict.acq && d.casier.length === 1 && d.pop === pop0 - 5, 'plaider coupable : condamnation, casier, popularité −5');
  ok(d.verdict.jail <= 21 * 0.65 + 1, 'peine réduite (avocat et aveu)');
  let s1 = E.act(E.init(), 'preset', 'carriere').s; s1.mature = 1; s1.signed = 1; s1.label = 'BLG'; s1.cas = { crime: 'braquage', n: 'Braquage', ch: 'vol à main armée', sev: 4, day: s1.day, trial: s1.day, stage: 'libre', lawyer: 'office', bail: 40000 };
  s1 = R(s1, 'trial', 'coupable'); ok(s1.jail && !s1.signed, 'prison : le label rompt le contrat');
}
// corrections du 17/10 : open mic, popularité, ventes des singles
{
  const R = (s, n, a) => { const r = E.act(s, n, a); if (r.err) throw new Error(n + ' ' + a + ' ' + r.err); return r.s; }; const ok = (c, t) => console.log((c ? 'ok' : 'ÉCHEC') + ' ' + t);
  let a = E.act(E.init(), 'preset', 'debut').s; a = R(a, 'openmic'); ok(E.act(a, 'openmic').err === 'deja', 'open mic : une fois par jour');
  let f = []; for (let d = 0; d < 6; d++) { const f0 = a.fans; a = R(a, 'endDay'); if (a.dlg) a.dlg = null; a = R(a, 'openmic'); f.push(a.fans - f0); }
  ok(f[0] > f[5] && f[5] >= 45, 'open mic répété : gains décroissants (' + f.join(', ') + ')');
  let b = E.act(E.init(), 'preset', 'debut').s; b = R(R(R(b, 'create'), 'record'), 'release'); const t = b.disco[0]; ok(t.salesRev === Math.round(t.L * 0.012) * 30 && t.rev === t.streamRev + t.salesRev, 'ventes des singles : 30 cauris la vente, ajoutées aux revenus');
  let p = E.act(E.init(), 'preset', 'star').s; p.pop = 95; p.dlg = null; p = R(R(R(p, 'create'), 'record'), 'release'); ok(p.pop <= 97, 'popularité : progression ralentie près de 100');
}
// garde-robe à tenues préfabriquées (20/10) — tests d'acceptation 3 à 11 côté moteur
{
  const fs = require('fs'), path = require('path');
  const R = (s, n, a) => { const r = E.act(s, n, a); if (r.err) throw new Error(n + ' ' + a + ' ' + r.err); return r.s; }; const ok = (c, t) => console.log((c ? 'ok' : 'ÉCHEC') + ' ' + t);
  const W = E.WARDROBE, root = path.join(__dirname, '..');
  const manFile = path.join(root, W.base, 'manifest.json');
  if (fs.existsSync(manFile)) {
    const man = JSON.parse(fs.readFileSync(manFile, 'utf8')), pick = o => JSON.stringify({ id: o.id, n: o.n, d: o.d, price: o.price, rank: o.rank, start: o.start, images: o.images, status: o.status });
    ok(JSON.stringify(man.outfits.map(pick)) === JSON.stringify(W.outfits.map(pick)), 'catalogue du moteur identique au manifest.json (une seule source)');
    ok(W.outfits.filter(o => o.status === 'disponible').every(o => ['young', 'mature'].every(v => o.images[v] && fs.existsSync(path.join(root, W.base, o.images[v])))), 'test 3 : chaque tenue disponible a ses deux illustrations sur disque');
  } else console.log('ok manifest.json absent du dossier : contrôle des fichiers ignoré (lancer depuis le zip)');
  ok(W.outfits.filter(o => !(o.images.young && o.images.mature)).every(o => o.status === 'indisponible'), 'une tenue sans ses deux variantes est indisponible');
  let s = E.act(E.init(), 'preset', 'debut').s; const c0 = s.cash;
  ok(s.wd.eq === 'OUTFIT_001' && s.wd.owned.length === 1, 'départ : Hoodie Néon possédé et équipé');
  s = R(s, 'obuy', 'OUTFIT_002'); ok(s.wd.owned.includes('OUTFIT_002') && s.cash === c0 - 6000, 'test 4 : l\'achat ajoute la tenue à l\'inventaire et débite 6 000');
  ok(s.wd.eq === 'OUTFIT_001', 'test 6 : l\'achat n\'équipe pas la tenue');
  ok(E.act(s, 'obuy', 'OUTFIT_002').err === 'deja' && s.cash === c0 - 6000, 'double achat refusé, aucun second débit');
  ok(E.act(s, 'obuy', 'OUTFIT_003').err === 'confirm', 'achat de 18 000 sans confirmation refusé (I-08)');
  ok(E.act(s, 'obuy', 'OUTFIT_005').err === 'indispo', 'tenue sans illustration mature : non achetable');
  ok(E.act(s, 'obuy', 'OUTFIT_004').err === 'rang', 'Veste Nuit : rang N3 requis');
  let poor = JSON.parse(JSON.stringify(s)); poor.cash = 100; ok(E.act(poor, 'obuy', 'OUTFIT_003').err === 'cash' || E.act(poor, 'oask', 'OUTFIT_003').err === 'cash', 'cash insuffisant refusé');
  ok(E.act(s, 'oeq', 'OUTFIT_003').err === 'pasachete', 'impossible d\'équiper une tenue non achetée');
  s = R(s, 'oeq', 'OUTFIT_002'); const r1 = E.resolveLook(s);
  ok(r1.path === W.base + 'young/OUTFIT_002.webp' && r1.variant === 'young', 'test 5 et 8 : équiper change l\'image (jeune, OUTFIT_002)');
  s.rank = W.matureRank; s = R(s, 'endDay'); const r2 = E.resolveLook(s);
  ok(r2.variant === 'mature' && r2.outfit === 'OUTFIT_002' && r2.path === W.base + 'mature/OUTFIT_002.webp' && s.wd.owned.length === 2, 'test 7 : au stade mature, même tenue et même inventaire');
  const saved = JSON.parse(JSON.stringify(s)); ok(E.resolveLook(saved).path === r2.path && saved.wd.eq === 'OUTFIT_002', 'test 10 (moteur) : état sérialisé, même apparence');
  let other = R(E.act(E.init(), 'preset', 'debut').s, 'ap', 'hair=afro'); const r3 = E.resolveLook(other);
  ok(r3.path === null && r3.fallback === 'look', 'test 9 (moteur) : look non couvert → secours maîtrisé, pas de chemin cassé');
  ok(E.ageVariant(Object.assign({}, s, { rank: W.matureRank - 1 })) === 'young', 'variante d\'âge dérivée du rang, jamais stockée');
}
