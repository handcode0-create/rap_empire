// Génère test/fixtures/parity21.json à partir du moteur de référence (docs/design-ref/v21/sources/engine21.js).
// Chaque scénario rejoue des actions sur l'état de départ et note, après chaque pas, le code d'erreur et les valeurs
// observées (chemins « a.b.0.c »). test/parity21_test.dart rejoue les mêmes pas sur le moteur Dart et compare.
// Usage : node tool/gen_parity21.js
'use strict';
const fs = require('fs');
const path = require('path');
const RE = require('../docs/design-ref/v21/sources/engine21.js');

function getPath(o, p) {
  let v = o;
  for (const k of p.split('.')) { if (v === null || v === undefined) return null; v = v[k]; }
  return v === undefined ? null : v;
}
function setPath(o, p, val) {
  const ks = p.split('.'); let v = o;
  for (let i = 0; i < ks.length - 1; i++) { if (v[ks[i]] === null || v[ks[i]] === undefined) v[ks[i]] = {}; v = v[ks[i]]; }
  v[ks[ks.length - 1]] = JSON.parse(JSON.stringify(val));
}
function startState(start) {
  if (start === 'init') return RE.init();
  return RE.act(RE.init(), 'preset', start).s;   // debut, couple, marie, parent, carriere, star
}

const scenarios = [];
function sc(name, start, patch, watch, steps) { scenarios.push({ name, start, patch: patch || {}, watch, steps }); }

const COMMON = ['cash', 'fans', 'pop', 'rep', 'xp', 'rank', 'en', 'hour', 'day'];
const song = (id, Q, L, extra) => Object.assign({ id, title: id, theme: 'quartier', amb: 'sombre', mode: 'manuel', tx: 72, st: 'sorti', Q, feats: [], clip: { st: 'aucun' }, L, rev: 0, fg: 0, pg: 0, tier: 'Discret', promo: 0, vir: 30, day: 3 }, extra || {});

// 1. Rangs et missions
sc('rang N4 par l’atelier (seuil 3 200 XP, popularité 20, 1 concert)', 'carriere', { xp: 3190, pop: 20, shows: 1 },
  COMMON.concat(['sk.ecr', 'trained', 'ms.m3']), [['atelier', null], ['atelier', null]]);
sc('rang N3 : seuil 1 500 XP et 1 single', 'debut', { xp: 1490, rank: 2, disco: [song('T1', 60, 5000)] }, COMMON,
  [['atelier', null]]);
sc('mission 3 : atelier d’écriture', 'debut', {}, COMMON.concat(['sk.ecr', 'trained', 'ms.m3']), [['atelier', null]]);
sc('atelier : refusé sans cash ni heures', 'debut', { cash: 1000 }, COMMON, [['atelier', null]]);

// 2. Création
sc('création : pays d’origine, styles, âge', 'init', {}, ['p.name', 'p.origin', 'p.main', 'p.second', 'p.age', 'age', 'created', 'ev', 'geo', 'sk', 'en'],
  [['finish', null], ['setp', 'name=Djo'], ['setp', 'origin=portambre'], ['setp', 'main=trap'], ['setp', 'second=coupe'], ['setp', 'age=22'], ['setp', 'origin=lune'], ['finish', null], ['finish', null]]);

// 3. Studio
sc('instru : rang, réputation, cash', 'debut', {}, ['cash', 'ui.inst'],
  [['pick', 'pont'], ['pick', 'lagune'], ['pick', 'gbaka'], ['pick', 'gbaka'], ['pick', 'nuit'], ['pick', 'inconnue']]);
sc('instru : Lagune d’Ambre à réputation 30', 'debut', { rep: 30, cash: 100000 }, ['cash', 'ui.inst'], [['pick', 'lagune']]);
sc('titre complet : texte, instru, cabine, sortie', 'debut', {}, COMMON.concat([
  'cur.st', 'cur.tx', 'cur.Q', 'cur.voix', 'cur.prod', 'cur.prodBy', 'cur.takes', 'cur.inst', 'ui.inst', 'sk.voix', 'sk.ecr',
  'disco.0.L', 'disco.0.Q', 'disco.0.rev', 'disco.0.sales', 'disco.0.tier', 'disco.0.cut', 'disco.0.labelAt', 'disco.0.auteur', 'disco.0.salesRev', 'disco.0.streamRev',
  'disco.0.fg', 'disco.0.pg', 'disco.0.vir', 'disco.0.st', 'disco.0.day', 'ms', 'geo']),
  [['record', null], ['create', ['quartier', 'sombre']], ['pick', 'gbaka'], ['record', [80, 70, 60]], ['release', null], ['release', null]]);
sc('cabine : prises par défaut, fatigue et featuring', 'debut', { en: 20 }, COMMON.concat(['cur.Q', 'cur.voix', 'cur.prod', 'cur.takes', 'cur.feats']),
  [['create', ['ambition', 'fiere']], ['feat', 'nadia'], ['record', null]]);
sc('cabine : prises bornées 0-100', 'debut', {}, ['cur.takes', 'cur.voix', 'cur.Q'],
  [['create', ['amour', 'legere']], ['record', [150, -20, 50]]]);
sc('home studio : −10 énergie, +2 voix, +4 production', 'debut', { own: { homestudio: { since: 1 } } }, COMMON.concat(['cur.Q', 'cur.voix', 'cur.prod']),
  [['create', ['quartier', 'sombre']], ['pick', 'gbaka'], ['record', [60, 60, 60]]]);
sc('sortie avec promo radio et part du label', 'carriere', { signed: 1, label: 'BSR', lcut: 0.35, lperk: 'radio', cash: 500000 },
  COMMON.concat(['disco.0.L', 'disco.0.rev', 'disco.0.sales', 'disco.0.cut', 'disco.0.salesRev', 'disco.0.salesCut', 'disco.0.labelAt', 'geo']),
  [['create', ['galere', 'sombre']], ['record', [70, 70, 70]], ['promo', 2], ['release', null]]);
sc('sortie : cash insuffisant pour la promo', 'debut', { cash: 1000 }, ['cash', 'cur.st', 'disco'],
  [['create', ['quartier', 'sombre']], ['record', null], ['promo', 2], ['release', null]]);
sc('sortie : popularité plafonnée à 12 et ralentie près de 100', 'carriere', { pop: 90, fans: 500000, cash: 800000 },
  COMMON.concat(['disco.0.L', 'disco.0.pg', 'disco.0.fg', 'disco.0.rev', 'disco.0.sales']),
  [['create', ['ambition', 'fiere']], ['pick', 'pont'], ['record', [95, 95, 95]], ['promo', 2], ['release', null]]);
sc('sortie en duo : part de la chanteuse', 'debut', { duo: { share: 50 } }, COMMON.concat(['cur.feats', 'cur.duo', 'duo', 'disco.0.duoCut', 'disco.0.rev', 'disco.0.L']),
  [['create', ['quartier', 'sombre']], ['record', null], ['release', null]]);
sc('sortie : bonus de rebond (hype) et réponse au rival (diss)', 'debut', { hype: 9, diss: 1, day: 5 }, COMMON.concat(['hype', 'diss', 'disco.0.L', 'disco.0.hype', 'disco.0.diss']),
  [['create', ['quartier', 'sombre']], ['record', null], ['release', null]]);
sc('avantages de label à la sortie (export, dev, ecr)', 'carriere', { signed: 1, label: 'RCD', lcut: 0.3, lperk: 'export' }, COMMON.concat(['geo', 'sk']),
  [['create', ['quartier', 'sombre']], ['record', null], ['release', null], ['@patch', { lperk: 'dev', en: 100, hour: 8 }], ['create', ['quartier', 'sombre']], ['record', null], ['release', null],
    ['@patch', { lperk: 'ecr', en: 100, hour: 8 }], ['create', ['quartier', 'sombre']], ['record', null], ['release', null]]);

// 4. EP et album
const disco3 = [song('T3', 70, 90000), song('T2', 60, 40000), song('T1', 50, 12000)];
sc('EP de 3 titres', 'star', { disco: disco3, ui: { promo: 0, feat: null } }, COMMON.concat(['projects', 'ui.ptk', 'ui.ptype']),
  [['prel', null], ['ptype', 'EP'], ['ptki', 0], ['ptki', 1], ['prel', null], ['ptki', 2], ['prel', null], ['prel', null]]);
sc('EP : cash insuffisant', 'star', { disco: disco3, cash: 5000 }, ['cash', 'projects'], [['ptki', 0], ['ptki', 1], ['ptki', 2], ['prel', null]]);
const disco8 = Array.from({ length: 8 }, (_, i) => song('T' + (8 - i), 55 + i * 3, 20000 + i * 9000));
sc('album refusé sous 8 titres, accepté à 8', 'star', { disco: disco8 }, COMMON.concat(['projects', 'ui.ptk', 'ui.ptype']),
  [['ptype', 'Album'], ['ptki', 0], ['ptki', 1], ['ptki', 2], ['prel', null], ['ptki', 3], ['ptki', 4], ['ptki', 5], ['ptki', 6], ['ptki', 7], ['prel', null]]);
sc('EP signé en label : part déduite, classement Top 50', 'star', { disco: disco3, signed: 1, label: 'AUB', lcut: 0.2, lperk: 'dev', fans: 60000 }, COMMON.concat(['projects']),
  [['setui', 'ptitle=Nuits de Ndolo'], ['ptki', 0], ['ptki', 1], ['ptki', 2], ['prel', null]]);
sc('EP : décocher un titre', 'star', { disco: disco3 }, ['ui.ptk'], [['ptki', 0], ['ptki', 1], ['ptki', 0], ['ptk', 'T9']]);

// 5. Scène
sc('open mic : gains décroissants sur 7 jours', 'debut', { fans: 0 }, COMMON.concat(['omK', 'omHist', 'omDay', 'om', 'shows', 'geo.bakoma']),
  [['openmic', null], ['openmic', null], ['@patch', { day: 2, hour: 8, en: 100 }], ['openmic', null], ['@patch', { day: 3, hour: 8, en: 100 }], ['openmic', null],
    ['@patch', { day: 4, hour: 8, en: 100 }], ['openmic', null], ['@patch', { day: 5, hour: 8, en: 100 }], ['openmic', null], ['@patch', { day: 6, hour: 8, en: 100 }], ['openmic', null],
    ['@patch', { day: 7, hour: 8, en: 100 }], ['openmic', null], ['@patch', { day: 12, hour: 8, en: 100 }], ['openmic', null]]);
sc('open mic : trou de mémoire sous 40 d’énergie', 'debut', { en: 30 }, COMMON.concat(['om', 'omK', 'shows']), [['openmic', null]]);
sc('open mic avec manager : 8 % de commission', 'debut', { mgr: 'maya', fans: 0 }, COMMON.concat(['mgrTot', 'om']), [['openmic', null]]);
sc('concert : billetterie et délai de 7 jours', 'carriere', {}, COMMON.concat(['cc.g', 'cc.tk', 'cc.cash', 'cc.fans', 'cc.rep', 'lastConcert', 'shows', 'geo.bakoma']),
  [['concert', null], ['concert', null], ['@patch', { day: 38, hour: 8, en: 100 }], ['concert', null]]);
sc('concert : label scène +20 % de billets, manager', 'carriere', { lperk: 'scene', signed: 1, mgr: 'maya' }, COMMON.concat(['cc.tk', 'cc.fans', 'cc.rep', 'cc.g', 'mgrTot']), [['concert', null]]);
sc('concert refusé avant le rang N3', 'debut', {}, COMMON, [['concert', null]]);
sc('tournée : audience, délai de 28 jours', 'star', {}, COMMON.concat(['cc.cash', 'cc.fans', 'cc.rep', 'lastTour', 'shows', 'geo']),
  [['tour', null], ['tour', null], ['@patch', { day: 70, hour: 8, en: 100 }], ['tour', null]]);
sc('tournée : audience insuffisante', 'carriere', { rank: 3 }, COMMON, [['tour', null]]);
sc('défi de K-Zer : battle gagnée (2 rounds sur 3)', 'debut', {}, COMMON.concat(['btq', 'bt', 'ev', 'evDone.kzer', 'geo.bakoma']),
  [['battle', 3], ['evc', 'a'], ['battle', 2], ['battle', 3]]);
sc('défi de K-Zer : battle perdue', 'debut', {}, COMMON.concat(['btq', 'bt', 'ev']), [['evc', 'a'], ['battle', 1]]);
sc('défi de K-Zer : ignoré', 'debut', {}, COMMON.concat(['btq', 'bt', 'ev', 'evDone.kzer']), [['evc', 'b']]);
sc('défi de K-Zer : refus faute d’énergie', 'debut', { en: 10 }, COMMON.concat(['btq', 'ev']), [['evc', 'a']]);
sc('battle gagnée avec label « street » et manager', 'debut', { lperk: 'street', signed: 1, mgr: 'maya' }, COMMON.concat(['bt', 'mgrTot']),
  [['evc', 'a'], ['battle', 3]]);

// 6. Dialogues
sc('Kôrô : négociation à 35 %, mix signé', 'debut', { disco: [song('T1', 60, 5000)] }, COMMON.concat(['dlg', 'dq', 'dseen', 'kc', 'rel']),
  [['setui', 'th=quartier'], ['dch', 'a'], ['dch', 'b'], ['dch', 'a'], ['dch', 'a'], ['dclose', null]]);
sc('Kôrô : déclenché après le premier enregistrement', 'debut', {}, ['dlg', 'dq', 'dseen'],
  [['create', ['quartier', 'sombre']], ['record', null], ['dch', 'zz']]);
sc('Kôrô : bonus de production sur 3 titres', 'debut', { kc: { st: 'Accord à 35 %, mix signé', bonus: 12, left: 3, rel: 8 }, dseen: { kore: 'x' } }, ['cur.prod', 'cur.prodBy', 'cur.Q', 'kc.left', 'dlg'],
  [['create', ['quartier', 'sombre']], ['pick', 'gbaka'], ['record', [70, 70, 70]]]);
sc('Kôrô : refus puis retour 21 jours plus tard', 'debut', { disco: [song('T1', 60, 5000)] }, COMMON.concat(['dlg', 'dq', 'dseen', 'rel']),
  [['setui', 'th=quartier'], ['dch', 'a'], ['dch', 'c'], ['dclose', null], ['@patch', { day: 25 }], ['setui', 'th=quartier'], ['dch', 'a'], ['dclose', null]]);
sc('Kôrô : négociation tendue à 30 %', 'debut', { disco: [song('T1', 60, 5000)] }, COMMON.concat(['dlg', 'dseen', 'kc', 'rel']),
  [['setui', 'th=quartier'], ['dch', 'a'], ['dch', 'b'], ['dch', 'b'], ['dch', 'b'], ['dch', 'a']]);
sc('Kôrô : énergie insuffisante pour négocier', 'debut', { disco: [song('T1', 60, 5000)], en: 3 }, ['dlg', 'en'],
  [['setui', 'th=quartier'], ['dch', 'a'], ['dch', 'b']]);
sc('Kôrô : cash insuffisant pour accepter', 'debut', { disco: [song('T1', 60, 5000)], cash: 100 }, ['dlg', 'cash', 'kc'],
  [['setui', 'th=quartier'], ['dch', 'a'], ['dch', 'a']]);
sc('manager Maya : engagement à 8 %', 'debut', { day: 3 }, COMMON.concat(['mgr', 'dlg', 'rel', 'dseen', 'mgrTot']),
  [['setui', 'th=amour'], ['dch', 'a'], ['dch', 'a'], ['dclose', null], ['openmic', null]]);
sc('manager Maya : négociation à 6 % puis refus', 'debut', { day: 3 }, ['mgr', 'dlg', 'rel', 'dseen'],
  [['setui', 'th=amour'], ['dch', 'a'], ['dch', 'b'], ['dch', 'b'], ['dclose', null]]);
sc('manager : rendez-vous écourté', 'debut', { day: 3 }, ['mgr', 'dlg', 'rel', 'dseen'], [['setui', 'th=amour'], ['dch', 'b']]);
sc('contrat de label Bakoma Sound Records', 'debut', { rep: 30, dseen: { kore: 'x', mgr: 'x' } }, COMMON.concat(['dlg', 'dq', 'dseen', 'signed', 'label', 'lcut', 'lperk']),
  [['setui', 'th=amour'], ['dch', 'a'], ['dch', 'b'], ['dch', 'b'], ['dclose', null]]);
sc('contrat de label : contre-offre à 40 %', 'debut', { rep: 30, dseen: { kore: 'x', mgr: 'x' } }, COMMON.concat(['dlg', 'dseen', 'signed', 'label', 'lcut', 'lperk']),
  [['setui', 'th=amour'], ['dch', 'b'], ['dch', 'a']]);
sc('contrat de label : réfléchir 7 jours', 'debut', { rep: 30, dseen: { kore: 'x', mgr: 'x' } }, ['dlg', 'dq', 'dseen', 'signed'],
  [['setui', 'th=amour'], ['dch', 'c'], ['dclose', null], ['@patch', { day: 9 }], ['setui', 'th=amour']]);
sc('carrière : file de dialogues et offres de labels dans l’ordre', 'carriere', {}, ['dlg', 'dq', 'dseen', 'signed', 'label', 'lcut', 'lperk', 'cash', 'rel'],
  [['dch', 'c'], ['dclose', null], ['dch', 'b'], ['dch', 'a'], ['dclose', null], ['dch', 'c'], ['dclose', null], ['dch', 'a'], ['dclose', null]]);
sc('rival, duo, succès, festival, crise dans l’ordre', 'star', { mgr: 'maya', dseen: { kore: 'x', mgr: 'x' }, bt: { win: 1, w: 3, vs: 'kzer' }, rep: 5 },
  ['dlg', 'dq', 'dseen', 'duo', 'diss', 'hype', 'cash', 'fans', 'pop', 'rep', 'rel', 'hour', 'en', 'shows', 'geo.portambre', 'xp'],
  [['setui', 'th=amour'], ['dch', 'c'], ['dclose', null], ['dch', 'a'], ['dclose', null], ['dch', 'a'], ['dclose', null], ['dch', 'b'], ['dclose', null], ['dch', 'a'], ['dclose', null]]);
sc('offre Aube Nouvelle : conditions et contre-offre 15 %', 'debut', { rep: 12, disco: [song('T1', 60, 5000)], dseen: { kore: 'x', mgr: 'x' } },
  ['dlg', 'dq', 'signed', 'label', 'lcut', 'lperk', 'cash', 'rel', 'dseen'],
  [['setui', 'th=amour'], ['dch', 'b'], ['dch', 'a']]);
sc('offre Vague Argentée : label en difficulté, 75 000 à 35 %', 'debut', { rep: 18, dseen: { kore: 'x', mgr: 'x' } }, ['dlg', 'signed', 'label', 'lcut', 'lperk', 'cash', 'rel'],
  [['setui', 'th=amour'], ['dch', 'b'], ['dch', 'a']]);
sc('offre Studio Kôrô Productions : bonus de production', 'debut', { rel: { kore: 8 }, disco: [song('T1', 60, 5000), song('T2', 60, 5000)], dseen: { kore: 'x', mgr: 'x', rival: 'x' } },
  ['dlg', 'signed', 'label', 'lcut', 'lperk', 'cash', 'rel', 'kc'], [['setui', 'th=amour'], ['dch', 'a']]);
sc('offre Black Lagune : drill, réputation 20', 'debut', { rep: 20, dseen: { kore: 'x', mgr: 'x' } }, ['dlg', 'signed', 'label', 'lcut', 'lperk', 'cash'],
  [['setui', 'th=amour'], ['dch', 'a']]);
sc('offre Sélène Indie Collective, Lyrik, Ambre, Rythme Cardinal, Ndolo Underground', 'debut',
  { rep: 40, shows: 2, pop: 30, sk: { flow: 17, ecr: 25, voix: 10, cha: 8 }, geo: { bakoma: 10, portambre: 8, selene: 7, tamarel: 0, korvane: 0, aldera: 0 }, p: { name: 'Djo', age: 19, origin: 'bakoma', main: 'coupe', second: null, goal: 'quartier' },
    dseen: { kore: 'x', mgr: 'x' } },
  ['dlg', 'dq', 'signed', 'label', 'lcut', 'lperk'], [['setui', 'th=amour']]);
sc('un seul contrat à la fois', 'debut', { rep: 30, signed: 1, label: 'AUB', lcut: 0.2, lperk: 'dev', dseen: { kore: 'x', mgr: 'x' } }, ['dlg', 'dq', 'signed', 'label'],
  [['setui', 'th=amour']]);

// 7. Justice
sc('activités illégales verrouillées sans contenu mature', 'debut', {}, ['cas', 'mature', 'heat', 'cash', 'hour'], [['crime', 'recel'], ['mature', 'on'], ['crime', 'inconnu']]);
function crimeOutcome(id, day, heat, wantArrest) {
  let s = RE.act(RE.init(), 'preset', 'debut').s; s = RE.act(s, 'mature', 'on').s; s.day = day; s.heat = heat;
  const r = RE.act(s, 'crime', id); return !!(r.s.cas) === wantArrest;
}
function findDay(id, heat, wantArrest) { for (let d = 1; d < 400; d++) if (crimeOutcome(id, d, heat, wantArrest)) return d; throw new Error('aucun jour'); }
const dBust = findDay('braquage', 80, true), dOk = findDay('recel', 0, false);
sc('crime réussi : gain et chaleur', 'debut', { mature: 1, day: dOk }, COMMON.concat(['heat', 'crimeN', 'lastCrime', 'cas']), [['crime', 'recel']]);
sc('arrestation, caution, avocat, procès, acquittement ou peine', 'debut', { mature: 1, day: dBust, heat: 80, cash: 300000 },
  COMMON.concat(['heat', 'cas', 'lastCrime', 'jail', 'verdict', 'casier', 'pop', 'fans']),
  [['crime', 'braquage'], ['crime', 'recel'], ['job', 'livraison'], ['lawyer', 'conf'], ['bail', null], ['trial', 'nc'], ['@patch', { day: dBust + 3 }], ['trial', 'nc'], ['lawyer', 'conf']]);
sc('garde à vue : détention provisoire, prison, sortie', 'debut', { mature: 1, day: dBust, heat: 80, cash: 300000 },
  COMMON.concat(['heat', 'cas', 'jail', 'verdict', 'casier', 'jw', 'jsp', 'sk']),
  [['crime', 'braquage'], ['detention', null], ['job', 'livraison'], ['jw', null], ['jw', null], ['js', null], ['js', null], ['@patch', { day: dBust + 3 }], ['trial', 'coupable'], ['jw', null], ['js', null], ['concert', null]]);
sc('procès : plaider coupable, prison, le label rompt le contrat', 'debut', { mature: 1, day: dBust, heat: 80, cash: 300000, signed: 1, label: 'BLG', lcut: 0.4, lperk: 'scene' },
  COMMON.concat(['cas', 'jail', 'verdict', 'casier', 'signed', 'label', 'lcut', 'lperk']),
  [['crime', 'braquage'], ['lawyer', 'tenor'], ['bail', null], ['@patch', { day: dBust + 3 }], ['trial', 'coupable']]);
sc('procès : non coupable avec avocat de commis d’office', 'debut', { mature: 1, day: dBust, heat: 80, cash: 300000 },
  COMMON.concat(['cas', 'jail', 'verdict', 'casier']), [['crime', 'braquage'], ['bail', null], ['@patch', { day: dBust + 3 }], ['trial', 'nc']]);
sc('détenu : fin de journée et sortie de prison', 'debut', { jail: { until: 6, days: 5 }, day: 1 }, ['jail', 'day', 'heat'],
  [['job', 'livraison'], ['endDay', null], ['endDay', null], ['endDay', null], ['endDay', null], ['endDay', null]]);
sc('chaleur qui retombe', 'debut', { heat: 10 }, ['heat', 'day'], [['endDay', null], ['endDay', null], ['endDay', null], ['endDay', null]]);

// 8. Divers : manager, label standard, plateformes, préréglages
sc('préréglage carrière', 'carriere', {}, COMMON.concat(['dseen.kore', 'kc', 'evDone', 'ms', 'ev', 'disco.0.L']), []);
sc('préréglage star', 'star', {}, COMMON.concat(['dseen.kore', 'kc', 'evDone', 'ms', 'ev', 'disco.0.L', 'own']), []);
sc('label standard (sign)', 'carriere', { rep: 31 }, COMMON.concat(['signed', 'label', 'lcut', 'lperk']), [['sign', null], ['sign', null]]);
sc('job, entreprise, bien : inchangés', 'star', {}, COMMON.concat(['biz', 'own']), [['job', 'mc'], ['bizBuy', 'couplet'], ['ask', 'terrain'], ['assetBuy', 'terrain']]);

const out = scenarios.map((S) => {
  let s = startState(S.start);
  Object.keys(S.patch).forEach((k) => setPath(s, k, S.patch[k]));
  const steps = S.steps.map(([a, g]) => {
    if (a === '@patch') { Object.keys(g).forEach((k) => setPath(s, k, g[k])); return { a, g, err: null, out: S.watch.reduce((o, w) => (o[w] = getPath(s, w), o), {}) }; }
    const r = RE.act(s, a, g); s = r.s;
    return { a, g: g === undefined ? null : g, err: r.err || null, out: S.watch.reduce((o, w) => (o[w] = getPath(s, w), o), {}) };
  });
  const first = S.steps.length ? null : { a: '@init', g: null, err: null, out: S.watch.reduce((o, w) => (o[w] = getPath(s, w), o), {}) };
  return { name: S.name, start: S.start, patch: S.patch, watch: S.watch, steps: first ? [first] : steps };
});

const dest = path.join(__dirname, '..', 'test', 'fixtures', 'parity21.json');
fs.mkdirSync(path.dirname(dest), { recursive: true });
fs.writeFileSync(dest, JSON.stringify({ generated: 'node tool/gen_parity21.js', scenarios: out }, null, 1));
console.log(out.length, 'scénarios,', out.reduce((n, s) => n + s.steps.length, 0), 'pas →', dest);
