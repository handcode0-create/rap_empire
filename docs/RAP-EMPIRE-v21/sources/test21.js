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
s = must(s, 'create', ['quartier', 'sombre']); const e0 = s.en; s = must(s, 'record'); T('G effet home studio', e0 - s.en === 15 && s.disco.length === 1 && s.cur.prod === 60);
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
c = E.act(c, 'evc', 'a').s; U('défi de K-Zer résolu', c.ev === null && c.rep === 14 && c.evDone.kzer === 'a' && !c.ms.m3);
U('événement déjà résolu', E.act(c, 'evc', 'a').err === 'rien');
c = E.act(c, 'setui', 'title=Ndolo en feu').s; c = E.act(c, 'create', ['quartier', 'sombre']).s; U('titre manuel', c.cur.title === 'Ndolo en feu' && c.ui.title === '');
c = E.act(c, 'record').s; U('mission 1 et offre de Kôrô', !!c.ms.m1 && c.ev === 'kore' && c.cash === 30000);
U('Kôrô : cash insuffisant', E.act(Object.assign(JSON.parse(JSON.stringify(c)), { cash: 100 }), 'evc', 'a').err === 'cash');
c = E.act(c, 'evc', 'b').s; U('accord Kôrô', c.kc.left === 3 && c.kc.bonus === 12 && c.cash === 23000);
c = E.act(c, 'release').s; U('mission 2', !!c.ms.m2);
c = E.act(c, 'endDay').s; c = E.act(c, 'create', ['quartier', 'sombre']).s; const q0 = c.cur.tx; c = E.act(c, 'record').s; U('bonus de production Kôrô', c.cur.prod === 68 && c.kc.left === 2);
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
  console.log((t.cut === Math.round(t.L * 0.01) - t.rev && t.cut > 0 ? 'ok' : 'ÉCHEC') + ' label : 35 % des revenus d\'écoutes retenus');
  let x = E.act(E.init(), 'preset', 'debut').s; for (let d = 0; d < 7; d++) { x = R(x, 'openmic').s; x = R(x, 'endDay').s; } console.log((x.rank < 3 ? 'ok' : 'ÉCHEC') + ' pas de N3 en une semaine (rang ' + x.rank + ', ' + x.xp + ' XP)');
}
