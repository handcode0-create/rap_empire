// ignore_for_file: avoid_dynamic_calls, prefer_const_declarations, unnecessary_cast
import 'dart:convert';
import 'dart:math' as math;
import 'reg21.dart';

/// Moteur RAP EMPIRE v21. Port fidèle de docs/RAP-EMPIRE-v21/sources/engine21.js : mêmes règles, mêmes valeurs, mêmes codes d'erreur.
/// L'état est un JSON (J), copié à chaque action puis sauvegardé tel quel. Pur : aucune dépendance Flutter, aucune horloge réelle
/// (le hasard de la journée vient de la graine et du jour, comme dans le prototype). Valeurs provisoires : voir reg21.dart.

/// Résultat d'une action : le nouvel état, ou l'état inchangé et un code d'erreur (« cash », « energie », « tard », « rang »…).
class Res {
  final J s;
  final String? err;
  const Res(this.s, [this.err]);
}

typedef Action = Res Function(J s, dynamic arg);

// ---------------------------------------------------------------------------------------------------------------------
// Outils
// ---------------------------------------------------------------------------------------------------------------------

/// Math.round de JavaScript : arrondi vers +∞ à .5.
int jsRound(num x) => (x + 0.5).floor();

num clamp21(num x, num a, num b) => math.max(a, math.min(b, x));
J clone21(J s) => jsonDecode(jsonEncode(s)) as J;
List<dynamic> _l(dynamic x) => x as List<dynamic>;
J _m(dynamic x) => x as J;
num _n(dynamic x) => (x ?? 0) as num;
bool _t(dynamic x) => x != null && x != 0 && x != false && x != '';

String fmt21(num n) {
  final r = jsRound(n);
  final s = r.abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  return r < 0 ? '−$s' : s;
}

String sg21(num n) => (n > 0 ? '+' : '') + fmt21(n);

/// Hasard déterministe du prototype : dépend de la graine, du jour et d'un sel.
double rng21(J s, [num salt = 0]) {
  final seed = _t(s['seed']) ? _n(s['seed']) : 7;
  final x = math.sin(seed * 9301 + _n(s['day']) * 49297 + salt * 233) * 233280;
  return x - x.floorToDouble();
}

int enMaxAge(int age) {
  var m = 100;
  for (final (a, v) in Reg21.enMaxByAge) {
    if (age >= a) m = v;
  }
  return m;
}

int enMax(J s) => enMaxAge(_n(s['age']).toInt()) + (_m(s['own'])['appart'] != null ? 5 : 0);

String stageOf(int age) {
  var n = Reg21.stages.first.$2;
  for (final (a, v) in Reg21.stages) {
    if (age >= a) n = v;
  }
  return n;
}

int kidAge(J s, J k) => ((_n(s['day']) - _n(k['born'])) / Reg21.daysPerYear).floor();

J? partner(J s) {
  final off = _m(s['rom'])['off'];
  return off == null ? null : _m(_m(_m(s['rom'])['c'])[off]);
}

// ---------------------------------------------------------------------------------------------------------------------
// État initial
// ---------------------------------------------------------------------------------------------------------------------

J init21() {
  final s = <String, dynamic>{
    'v': 21, 'created': 0,
    'p': {'name': '', 'age': Reg21.startAge, 'origin': 'bakoma', 'main': 'drill', 'second': null, 'goal': 'quartier'},
    'ms': <String, dynamic>{}, 'evq': <dynamic>[], 'ev': null, 'evDone': <String, dynamic>{},
    'kc': {'left': 0, 'bonus': 0, 'rel': 0, 'st': ''},
    'cc': null, 'lastConcert': -99, 'lastTour': -99, 'seed': 7, 'day': 1, 'hour': 8, 'age': Reg21.startAge,
    'cash': 25000, 'en': 100, 'pop': 3, 'fans': 120, 'rep': 8, 'xp': 0, 'rank': 1,
    'sk': {'flow': 17, 'ecr': 14, 'voix': 10, 'cha': 8},
    'cur': null, 'disco': <dynamic>[], 'shows': 0,
    'geo': {'bakoma': 4, 'portambre': 0, 'selene': 0, 'tamarel': 0, 'korvane': 0, 'aldera': 0},
    'own': <String, dynamic>{}, 'biz': <String, dynamic>{}, 'merch': null, 'merchDone': <String, dynamic>{}, 'signed': 0,
    'ap': {'hair': 'hitwist', 'top': 'hoodie', 'skin': '3'},
    'rom': {'c': <String, dynamic>{}, 'used': 0, 'today': <String, dynamic>{}, 'off': null, 'since': 0, 'married': 0, 'wed': 0, 'cool': 0, 'ex': <String, dynamic>{}, 'hist': <dynamic>[], 'prop': 0, 'wsel': 'simple'},
    'fam': {'kids': <dynamic>[], 'proj': 0, 'ev': null},
    'log': <dynamic>[], 'bil': null, 'd0': null, 'ui': {'promo': 0, 'feat': null}, 't': 0, 'evId': 0,
  };
  for (final k in cands21.keys) {
    _m(_m(s['rom'])['c'])[k] = {'g': 0};
  }
  s['d0'] = dayStart21(s);
  return s;
}

J dayStart21(J s) {
  final r = partner(s);
  return {'cash': s['cash'], 'pop': s['pop'], 'fans': s['fans'], 'xp': s['xp'], 'rank': s['rank'], 'en': s['en'], 'rel': r?['g'], 'geoB': _m(s['geo'])['bakoma'], 'kids': _l(_m(s['fam'])['kids']).length};
}

/// Complète une ancienne sauvegarde avec les champs ajoutés depuis (comme norm du prototype).
J norm21(J s) {
  final d = init21();
  for (final k in d.keys) {
    s.putIfAbsent(k, () => d[k]);
  }
  return s;
}

void _log(J s, String t, [String cat = 'jeu']) {
  final lg = _l(s['log']);
  lg.insert(0, {'t': t, 'c': cat, 'd': s['day']});
  if (lg.length > 40) lg.removeRange(40, lg.length);
}

void _pay(J s, num a) => s['cash'] = math.max(0, _n(s['cash']) + a);

/// Heures et énergie d'une action. Renvoie 'tard' ou 'energie' si impossible, sinon null (et applique le coût).
String? _spend(J s, num h, num e) {
  if (_n(s['hour']) + h > Reg21.dayEnd) return 'tard';
  if (_n(s['en']) < e) return 'energie';
  s['hour'] = _n(s['hour']) + h;
  s['en'] = _n(s['en']) - e;
  return null;
}

void _geoAdd(J s, String city, num n) {
  final g = _m(s['geo']);
  g[city] = clamp21(jsRound((_n(g[city]) + n) * 10) / 10, 0, 100);
}

Res _ok(J s) => Res(s);
Res _no(J s, String e) => Res(s, e);

// ---------------------------------------------------------------------------------------------------------------------
// Rang de carrière
// ---------------------------------------------------------------------------------------------------------------------

bool condOk21(J s, J c) {
  if (c['singles'] != null && _l(s['disco']).length < (c['singles'] as num)) return false;
  if (c['pop'] != null && _n(s['pop']) < (c['pop'] as num)) return false;
  if (c['shows'] != null && _n(s['shows']) < (c['shows'] as num)) return false;
  if (c['fans'] != null && _n(s['fans']) < (c['fans'] as num)) return false;
  if (c['bon'] != null && !_l(s['disco']).any((d) => _n(_m(d)['L']) >= 50000)) return false;
  if (c['hit'] != null && !_l(s['disco']).any((d) => _n(_m(d)['L']) >= Reg21.entry)) return false;
  return true;
}

void _promote(J s) {
  final r = Reg21.ranks;
  while (_n(s['rank']) < r.length && _n(s['xp']) >= (r[_n(s['rank']).toInt()]['xp'] as num) && condOk21(s, r[_n(s['rank']).toInt()])) {
    s['rank'] = _n(s['rank']) + 1;
    _log(s, 'Promotion : N${s['rank']} · ${r[_n(s['rank']).toInt() - 1]['n']}', 'carriere');
  }
}

void _addXp(J s, num x) {
  s['xp'] = _n(s['xp']) + x;
  _promote(s);
}

// ---------------------------------------------------------------------------------------------------------------------
// Musique
// ---------------------------------------------------------------------------------------------------------------------

final _k = 5420 / (9000 * 0.61);

int listensFor21(num q, num fans, int promo) {
  final raw = (9000 + 6 * (fans - 120)) * (promos21[promo]['m'] as num) * (q / 100) * _k;
  return jsRound(raw / (1 + raw / Reg21.listenCap));
}

int virOf21(J song, [int promo = 0]) {
  var v = Reg21.virBase + (Reg21.themes[song['theme']]!['vir'] as int) + (Reg21.ambs[song['amb']]!['vir'] as int) + Reg21.promoVir[promo];
  for (final f in _l(song['feats'])) {
    v += Reg21.feats[f]!['vir'] as int;
  }
  final clip = song['clip'];
  if (clip != null && _m(clip)['st'] == 'publie') v += _n(_m(clip)['vir']).toInt();
  return clamp21(v, 0, 100).toInt();
}

String tierOf21(num l) {
  var t = Reg21.tiers.first.$2;
  for (final (a, n) in Reg21.tiers) {
    if (l >= a) t = n;
  }
  return t;
}

double featBoost21(J song) {
  var b = 1.0;
  for (final f in _l(song['feats'])) {
    b *= (Reg21.feats[f]!['boost'] as num).toDouble();
  }
  return b;
}

/// Écoutes prévues pour le titre en cours avec la promotion choisie.
int predictedListens21(J s) {
  final c = s['cur'];
  if (c == null) return 0;
  final song = _m(c);
  final promo = _n(_m(s['ui'])['promo']).toInt();
  final q = _t(song['Q']) ? song['Q'] as num : 60;
  return jsRound(listensFor21(q, _n(s['fans']), promo) * (0.8 + virOf21(song, promo) / 250) * featBoost21(song));
}

J? _clipSong(J s) {
  final cur = s['cur'];
  if (cur != null && _m(cur)['st'] != 'sorti') return _m(cur);
  final d = _l(s['disco']);
  return d.isEmpty ? null : _m(d.first);
}

/// Titre visé par le clip : le titre en cours, sinon le dernier sorti.
J? clipSong21(J s) => _clipSong(s);

int tickets21(J s) => math.min(Reg21.capacity, jsRound(40 + _n(s['fans']) * 0.05 + _n(_m(s['geo'])['bakoma']) * 4));

/// Indice du Top 10 Global (R10) et ses cinq parties. Échelles provisoires de l'étude D-17.
({double f, double g, double c, double s, double n, double i}) idxParts21(J s) {
  double lg(num x, num ref, num x0) => 100 * math.min(1, _log10(1 + math.max(x, 0) / x0) / _log10(1 + ref / x0));
  final cat = _l(s['disco']).fold<num>(0, (a, x) => a + _n(_m(x)['L']));
  final f = lg(_n(s['fans']), 5e6, 1e3), g = lg(_n(s['fans']) - 120, 200e3, 1e3), c = lg(cat, 30e6, 1e4), sc = lg(_n(s['shows']) * 300, 2e6, 5e2);
  final n = math.min(100, _n(s['pop'])).toDouble();
  return (f: f, g: g, c: c, s: sc, n: n, i: 0.25 * f + 0.15 * g + 0.30 * c + 0.20 * sc + 0.10 * n);
}

double _log10(num x) => math.log(x) / math.ln10;

// ---------------------------------------------------------------------------------------------------------------------
// Relations
// ---------------------------------------------------------------------------------------------------------------------

bool canPropose21(J s) {
  final r = partner(s);
  final rom = _m(s['rom']);
  return r != null && !_t(rom['married']) && _n(r['g']) >= Reg21.proposeAt && _n(s['day']) - _n(rom['since']) >= Reg21.proposeMinDays && _n(s['day']) >= _n(rom['cool']);
}

// ---------------------------------------------------------------------------------------------------------------------
// Événements de carrière
// ---------------------------------------------------------------------------------------------------------------------

void _queueEv(J n, String id) {
  if (_t(_m(n['evDone'])[id]) || n['ev'] == id || _l(n['evq']).contains(id)) return;
  if (n['ev'] == null) {
    n['ev'] = id;
  } else {
    _l(n['evq']).add(id);
  }
}

void _missions(J n) {
  final cur = n['cur'];
  final done = {
    'm1': _l(n['disco']).isNotEmpty || (cur != null && _m(cur)['st'] == 'enregistre'),
    'm2': _l(n['disco']).isNotEmpty,
    'm3': _t(n['trained']),
    'm4': _n(n['fans']) >= 1000,
  };
  for (final m in Reg21.missions) {
    final id = m['id'] as String;
    if (!_t(_m(n['ms'])[id]) && done[id]! && _t(n['created'])) {
      _m(n['ms'])[id] = n['day'];
      _pay(n, m['cash'] as num);
      _addXp(n, m['xp'] as num);
      _log(n, 'Mission accomplie : ${m['t']} (+${fmt21(m['cash'] as num)} cauris, +${m['xp']} XP)', 'mission');
    }
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Séparation
// ---------------------------------------------------------------------------------------------------------------------

void _separate(J n, String cid, String why) {
  final rom = _m(n['rom']);
  _l(rom['hist']).add({'d': n['day'], 't': '$why · ${cands21[cid]!['n']}${_t(rom['married']) ? ' (après mariage)' : ' (avant mariage)'}'});
  final c = _m(_m(rom['c'])[cid]);
  c['g'] = math.min(_n(c['g']), 10);
  _m(rom['ex'])[cid] = _n(n['day']) + Reg21.exBlockDays;
  rom['off'] = null;
  rom['prop'] = 0;
  if (_t(rom['married'])) {
    rom['married'] = 0;
    rom['div'] = 1;
  }
  final fam = _m(n['fam']);
  fam['proj'] = 0;
  for (final k in _l(fam['kids'])) {
    _m(k)['garde'] = 'Garde partagée';
  }
  rom['sep'] = {'why': why, 'who': cands21[cid]!['n'], 'd': n['day']};
  _log(n, '$why avec ${cands21[cid]!['n']} : historique et enfants conservés', 'perso');
}

// ---------------------------------------------------------------------------------------------------------------------
// Création de l'artiste
// ---------------------------------------------------------------------------------------------------------------------

String cleanName21(dynamic x) => (x ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();

bool nameOk21(dynamic x) {
  final n = cleanName21(x);
  return n.length >= Reg21.nameMin && n.length <= Reg21.nameMax && RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ0-9 '\-.]+$").hasMatch(n);
}

// ---------------------------------------------------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------------------------------------------------

final Map<String, Action> actions21 = {
  'reset': (s, a) => _ok(init21()),

  'create': (s, arg) {
    if (s['cur'] != null && _m(s['cur'])['st'] != 'sorti') return _no(s, 'encours');
    final n = clone21(s);
    String th, am, mode = 'manuel';
    final ui = _m(n['ui']);
    if (arg == 'random' || (arg is List && arg.isNotEmpty && arg[0] == 'random')) {
      final tk = Reg21.themes.keys.toList(), ak = Reg21.ambs.keys.toList();
      th = tk[(rng21(n, 11) * tk.length).floor()];
      am = ak[(rng21(n, 12) * ak.length).floor()];
      mode = 'aléatoire';
    } else if (arg is List) {
      th = arg[0] as String;
      am = arg[1] as String;
    } else {
      th = (ui['th'] ?? 'quartier') as String;
      am = (ui['am'] ?? 'sombre') as String;
    }
    if (!Reg21.themes.containsKey(th) || !Reg21.ambs.containsKey(am)) return _no(s, 'inconnu');
    final e = _spend(n, 1, 20);
    if (e != null) return _no(s, e);
    final pool = titles21[th]!;
    var title = cleanName21(ui['title']);
    if (title.length > 30) title = title.substring(0, 30);
    if (title.isEmpty) {
      title = pool[_l(n['disco']).length % pool.length];
    } else {
      mode = mode == 'aléatoire' ? mode : 'manuel';
    }
    if (_t(ui['rt'])) title = pool[(rng21(n, 13) * pool.length).floor()];
    ui['title'] = '';
    ui['rt'] = 0;
    n['cur'] = {
      'id': 'T${_l(n['disco']).length + 1}', 'title': title, 'theme': th, 'amb': am, 'mode': mode,
      'tx': 72 + (Reg21.themes[th]!['tx'] as int) + (Reg21.ambs[am]!['tx'] as int), 'st': 'ecrit', 'Q': 0, 'feats': <dynamic>[], 'clip': {'st': 'aucun'},
    };
    final sk = _m(n['sk']);
    sk['ecr'] = _n(sk['ecr']) + 1;
    _log(n, 'Texte écrit : $title ($mode)', 'musique');
    return _ok(n);
  },

  'record': (s, a) {
    if (s['cur'] == null || _m(s['cur'])['st'] != 'ecrit') return _no(s, 'pasdetexte');
    final hs = _m(s['own'])['homestudio'] != null;
    final n = clone21(s);
    final e = _spend(n, 2, hs ? 15 : 25);
    if (e != null) return _no(s, e);
    final kc = _m(n['kc']);
    final kb = _n(kc['left']) > 0 ? _n(kc['bonus']) : 0;
    if (kb != 0) kc['left'] = _n(kc['left']) - 1;
    final voix = 55 + (hs ? 2 : 0), prod = 56 + (hs ? 4 : 0) + kb;
    final mal = math.min(20, math.max(0, 40 - _n(s['en'])) / 2);
    final cur = _m(n['cur']);
    var fq = 0;
    for (final f in _l(cur['feats'])) {
      fq += Reg21.feats[f]!['q'] as int;
    }
    cur['voix'] = voix;
    cur['prod'] = prod;
    cur['Q'] = clamp21(jsRound(0.35 * _n(cur['tx']) + 0.30 * voix + 0.35 * prod - mal) + fq, 0, 100);
    cur['st'] = 'enregistre';
    final sk = _m(n['sk']);
    sk['voix'] = _n(sk['voix']) + 1;
    _addXp(n, 30);
    _log(n, 'Enregistré : ${cur['title']} · qualité ${cur['Q']}${kb != 0 ? ' (production Kôrô +$kb)' : ''}', 'musique');
    _queueEv(n, 'kore');
    return _ok(n);
  },

  'feat': (s, id) {
    final f = Reg21.feats[id];
    if (f == null) return _no(s, 'inconnu');
    final cur = s['cur'];
    if (cur == null || _m(cur)['st'] == 'sorti') return _no(s, 'pasdetitre');
    if (_l(_m(cur)['feats']).contains(id)) return _no(s, 'deja');
    if (_l(_m(cur)['feats']).length >= Reg21.maxFeats) return _no(s, 'maxfeat');
    if (f['needRival'] == true) return _no(s, 'rival');
    if (f['needPop'] != null && _n(s['pop']) < (f['needPop'] as num)) return _no(s, 'pop');
    if (_n(s['cash']) < (f['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -(f['cost'] as num));
    final c = _m(n['cur']);
    _l(c['feats']).add(id);
    if (c['st'] == 'enregistre') c['Q'] = clamp21(_n(c['Q']) + (f['q'] as num), 0, 100);
    _log(n, 'Featuring : ${f['n']} (${f['role']})', 'musique');
    return _ok(n);
  },

  'unfeat': (s, id) {
    final cur = s['cur'];
    if (cur == null || _m(cur)['st'] == 'sorti') return _no(s, 'pasdetitre');
    final i = _l(_m(cur)['feats']).indexOf(id);
    if (i < 0) return _ok(s);
    final n = clone21(s);
    final c = _m(n['cur']);
    _l(c['feats']).removeAt(i);
    final f = Reg21.feats[id]!;
    if (c['st'] == 'enregistre') c['Q'] = clamp21(_n(c['Q']) - (f['q'] as num), 0, 100);
    if (_n(f['cost']) != 0) _pay(n, f['cost'] as num);
    return _ok(n);
  },

  'promo': (s, k) {
    final n = clone21(s);
    _m(n['ui'])['promo'] = k is num ? k : int.tryParse('$k') ?? 0;
    return _ok(n);
  },

  'release': (s, a) {
    final cur = s['cur'];
    if (cur == null || _m(cur)['st'] != 'enregistre') return _no(s, 'pasenregistre');
    final promo = _n(_m(s['ui'])['promo']).toInt();
    final p = promos21[promo];
    if (_n(s['cash']) < (p['c'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    final c = _m(n['cur']);
    if (_n(p['c']) != 0) _pay(n, -(p['c'] as num));
    c['vir'] = virOf21(c, promo);
    final boost = featBoost21(c);
    final l = jsRound(listensFor21(_n(c['Q']), _n(n['fans']), promo) * (0.8 + _n(c['vir']) / 250) * boost);
    final gross = jsRound(l * Reg21.listenValue);
    final rev = _t(n['signed']) ? jsRound(gross * (1 - Reg21.labelCut)) : gross;
    final fg = (l * 0.07 / (1 + _n(n['fans']) / Reg21.fanSat)).ceil();
    final pg = (l / 900).floor();
    _pay(n, rev);
    n['fans'] = _n(n['fans']) + fg;
    n['pop'] = clamp21(_n(n['pop']) + pg, 0, 100);
    _geoAdd(n, 'bakoma', math.min(12, jsRound(l / 1500 * 10) / 10 + 1));
    if (promo == 2) {
      _geoAdd(n, 'portambre', 2);
      _geoAdd(n, 'selene', 2);
    }
    c['st'] = 'sorti';
    c['day'] = n['day'];
    c['L'] = l;
    c['rev'] = rev;
    c['cut'] = gross - rev;
    c['fg'] = fg;
    c['pg'] = pg;
    c['tier'] = tierOf21(l);
    c['promo'] = promo;
    _l(n['disco']).insert(0, c);
    n['cur'] = null;
    n['last'] = c['id'];
    _addXp(n, 40);
    _log(n, 'Sortie : ${c['title']} · ${fmt21(l)} écoutes · ${c['tier']}', 'musique');
    return _ok(n);
  },

  'dir': (s, id) {
    final n = clone21(s);
    _m(n['ui'])['dir'] = id;
    return _ok(n);
  },

  'clipPrep': (s, id) {
    final did = (id ?? _m(s['ui'])['dir']) as String?;
    final d = did == null ? null : Reg21.directors[did];
    if (d == null) return _no(s, 'inconnu');
    final t = _clipSong(s);
    if (t == null) return _no(s, 'pasdetitre');
    if (t['st'] == 'sorti') return _no(s, 'clipapres');
    if (_m(t['clip'])['st'] != 'aucun') return _no(s, 'deja');
    if (_n(s['rank']) < (d['rank'] as num)) return _no(s, 'rang');
    if (_n(s['cash']) < (d['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    final c = _clipSong(n)!;
    _pay(n, -(d['cost'] as num));
    c['clip'] = {'st': 'prepare', 'dir': did, 'vir': d['vir']};
    _log(n, 'Clip préparé avec ${d['n']} pour ${c['title']}', 'musique');
    return _ok(n);
  },

  'clipShoot': (s, a) {
    final t = _clipSong(s);
    if (t == null || _m(t['clip'])['st'] != 'prepare') return _no(s, 'pasprepare');
    final n = clone21(s);
    final e = _spend(n, Reg21.shootH, Reg21.shootE - (_m(s['own'])['moto'] != null ? 5 : 0));
    if (e != null) return _no(s, e);
    final c = _clipSong(n)!;
    _m(c['clip'])['st'] = 'produit';
    _log(n, 'Tournage terminé : ${c['title']}', 'musique');
    return _ok(n);
  },

  'clipPub': (s, a) {
    final t = _clipSong(s);
    if (t == null) return _no(s, 'pasdetitre');
    if (t['st'] != 'sorti') return _no(s, 'avantsortie');
    if (_m(t['clip'])['st'] != 'produit') return _no(s, 'pasproduit');
    final n = clone21(s);
    final c = _m(_l(n['disco']).first);
    _m(c['clip'])['st'] = 'publie';
    final v0 = c['vir'];
    c['vir'] = virOf21(c, _n(c['promo']).toInt());
    final extra = jsRound(_n(c['L']) * Reg21.clipBoost * (_n(c['vir']) / 100) * 4);
    c['L'] = _n(c['L']) + extra;
    c['tier'] = tierOf21(_n(c['L']));
    final fg = (extra * 0.07 / (1 + _n(n['fans']) / Reg21.fanSat)).ceil();
    n['fans'] = _n(n['fans']) + fg;
    n['pop'] = clamp21(_n(n['pop']) + 2, 0, 100);
    _pay(n, jsRound(extra * Reg21.listenValue));
    _geoAdd(n, 'bakoma', 2);
    c['clipL'] = extra;
    c['clipF'] = fg;
    c['vir0'] = v0;
    _addXp(n, 20);
    _log(n, 'Clip publié : ${c['title']} · +${fmt21(extra)} écoutes', 'musique');
    return _ok(n);
  },

  // ---------- scène ----------
  'openmic': (s, a) {
    final n = clone21(s);
    final e = _spend(n, 1, 15 - (_m(s['own'])['moto'] != null ? 5 : 0));
    if (e != null) return _no(s, e);
    final win = _n(s['en']) >= 40;
    n['shows'] = _n(n['shows']) + 1;
    if (win) {
      n['fans'] = _n(n['fans']) + 150;
      n['rep'] = _n(n['rep']) + 6;
      _pay(n, 3000);
      _geoAdd(n, 'bakoma', 2);
      _addXp(n, 60);
    } else {
      n['fans'] = _n(n['fans']) + 12;
      _addXp(n, 10);
    }
    _log(n, "Open mic de Ndolo : ${win ? 'le public a suivi (+150 fans)' : 'trou de mémoire'}", 'scene');
    n['om'] = win ? 1 : 0;
    return _ok(n);
  },

  'atelier': (s, a) {
    final t = Reg21.atelier;
    if (_n(s['cash']) < (t['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    final e = _spend(n, t['h'] as num, t['e'] as num);
    if (e != null) return _no(s, e);
    _pay(n, -(t['cost'] as num));
    final sk = _m(n['sk']);
    sk[t['sk']] = _n(sk[t['sk']]) + (t['gain'] as num);
    n['trained'] = _n(n['trained']) + 1;
    _addXp(n, 20);
    _log(n, "Atelier d'écriture : Écriture +${t['gain']} (−${fmt21(t['cost'] as num)} cauris)", 'carriere');
    return _ok(n);
  },

  'concert': (s, a) {
    if (_n(s['rank']) < 3) return _no(s, 'rang');
    if (_n(s['day']) - _n(s['lastConcert']) < Reg21.concertEvery) return _no(s, 'delai');
    final n = clone21(s);
    final e = _spend(n, 4, 35 - (_m(s['own'])['moto'] != null ? 5 : 0));
    if (e != null) return _no(s, e);
    final top = _n(s['en']) >= 60, tk = tickets21(s);
    final ca = jsRound(tk * Reg21.ticketPrice * (top ? 1 : 0.85)), fg = jsRound(tk * (top ? 1.6 : 1.1)), rp = top ? 10 : 6;
    n['shows'] = _n(n['shows']) + 1;
    n['fans'] = _n(n['fans']) + fg;
    n['rep'] = _n(n['rep']) + rp;
    _pay(n, ca);
    _geoAdd(n, 'bakoma', 4);
    n['pop'] = clamp21(_n(n['pop']) + 1, 0, 100);
    _addXp(n, 90);
    n['lastConcert'] = n['day'];
    n['concertDay'] = n['day'];
    n['cc'] = {'g': top ? 'A' : 'B', 'tk': tk, 'cash': ca, 'fans': fg, 'rep': rp, 'day': n['day']};
    _log(n, 'Concert au Parvis : $tk billets, note ${top ? 'A' : 'B'} · +${fmt21(fg)} fans · billetterie ${fmt21(ca)}', 'scene');
    return _ok(n);
  },

  'tour': (s, a) {
    final t = Reg21.tour;
    if (_n(s['rank']) < (t['rank'] as num)) return _no(s, 'rang');
    if (_n(s['day']) - _n(s['lastTour']) < Reg21.tourEvery) return _no(s, 'delai');
    final geo = _m(s['geo']);
    if ((_n(geo['portambre']) + _n(geo['selene'])) / 2 < Reg21.tourAudience) return _no(s, 'audience');
    if (_n(s['cash']) < (t['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    final e = _spend(n, t['h'] as num, (t['e'] as num) - (_m(s['own'])['moto'] != null ? 5 : 0));
    if (e != null) return _no(s, e);
    final fee = (t['fee'] as num) + jsRound((t['feeGeo'] as num) * (_n(geo['portambre']) + _n(geo['selene'])));
    _pay(n, fee - (t['cost'] as num));
    n['lastTour'] = n['day'];
    n['cc'] = {'g': 'T', 'tk': 0, 'cash': fee - (t['cost'] as num), 'fans': t['fans'], 'rep': 4, 'day': n['day'], 'tour': 1};
    n['rep'] = _n(n['rep']) + 4;
    n['fans'] = _n(n['fans']) + (t['fans'] as num);
    n['shows'] = _n(n['shows']) + 2;
    _geoAdd(n, 'portambre', t['geo'] as num);
    _geoAdd(n, 'selene', t['geo'] as num);
    n['pop'] = clamp21(_n(n['pop']) + 2, 0, 100);
    _addXp(n, 120);
    _log(n, 'Tournée régionale : +${fmt21(t['fans'] as num)} fans, Port-Ambre et Sélène +${t['geo']}', 'scene');
    return _ok(n);
  },

  // ---------- économie ----------
  'job': (s, id) {
    final j = Reg21.jobs[id];
    if (j == null) return _no(s, 'inconnu');
    if (j['cha'] != null && _n(_m(s['sk'])['cha']) < (j['cha'] as num)) return _no(s, 'charisme');
    final n = clone21(s);
    final moto = _m(s['own'])['moto'] != null ? 5 : 0;
    final e = _spend(n, j['h'] as num, (j['e'] as num) - moto);
    if (e != null) return _no(s, e);
    _pay(n, j['cash'] as num);
    n['lastJob'] = {'id': id, 'cash': j['cash'], 'e': (j['e'] as num) - moto, 'h': j['h']};
    _log(n, '${j['n']} : +${fmt21(j['cash'] as num)} cauris', 'eco');
    return _ok(n);
  },

  'bizBuy': (s, id) {
    final b = Reg21.biz[id];
    if (b == null) return _no(s, 'inconnu');
    if (_m(s['biz'])[id] != null) return _no(s, 'deja');
    if (_n(s['rank']) < (b['rank'] as num)) return _no(s, 'rang');
    if (_n(s['cash']) < (b['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -(b['cost'] as num));
    _m(n['biz'])[id] = {'since': n['day'], 'tot': 0};
    _log(n, 'Entreprise : ${b['n']}', 'eco');
    return _ok(n);
  },

  'ask': (s, id) {
    final n = clone21(s);
    _m(n['ui'])['buy'] = id;
    return _ok(n);
  },

  'assetBuy': (s, arg) {
    final id = (arg ?? _m(s['ui'])['buy']) as String?;
    final a = id == null ? null : Reg21.assets[id];
    if (a == null) return _no(s, 'inconnu');
    if (_m(s['own'])[id] != null) return _no(s, 'deja');
    if (_n(s['cash']) < (a['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -(a['cost'] as num));
    _m(n['own'])[id!] = {'since': n['day']};
    _m(n['ui'])['buy'] = null;
    if (id == 'appart') n['en'] = math.min(enMax(n), _n(n['en']) + 5);
    _log(n, 'Bien acquis : ${a['n']}', 'eco');
    return _ok(n);
  },

  'merch': (s, id) {
    final m = Reg21.merch[id];
    if (m == null) return _no(s, 'inconnu');
    if (s['merch'] != null) return _no(s, 'encours');
    if (_n(s['fans']) < (m['fans'] as num)) return _no(s, 'fans');
    if (m['singles'] != null && _l(s['disco']).length < (m['singles'] as num)) return _no(s, 'single');
    if (m['rank'] != null && _n(s['rank']) < (m['rank'] as num)) return _no(s, 'rang');
    if (_n(s['cash']) < (m['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -(m['cost'] as num));
    n['merch'] = {'id': id, 'left': m['days'], 'tot': 0};
    _log(n, 'Merch lancé : ${m['n']}', 'eco');
    return _ok(n);
  },

  'sign': (s, a) {
    if (_t(s['signed'])) return _no(s, 'deja');
    if (_n(s['rep']) < Reg21.labelRep) return _no(s, 'rep');
    final n = clone21(s);
    n['signed'] = 1;
    _pay(n, Reg21.labelAdvance);
    _log(n, 'Contrat signé : Bakoma Sound Records (avance 150 000)', 'carriere');
    return _ok(n);
  },

  // ---------- relations ----------
  'rom': (s, arg) => _rom(s, arg as List),
  'romc': (s, act) => _rom(s, [_m(s['ui'])['cand'] ?? 'lina', act]),
  'romp': (s, act) {
    final off = _m(s['rom'])['off'];
    if (off == null) return _no(s, 'pasdecouple');
    return _rom(s, [off, act]);
  },
  'th': (s, id) => _setUi(s, 'th', id),
  'am': (s, id) => _setUi(s, 'am', id),
  'cand': (s, cid) => _setUi(s, 'cand', cid),

  'official': (s, arg) {
    final cid = (arg ?? _m(s['ui'])['cand']) as String?;
    final c = cid == null ? null : _m(_m(s['rom'])['c'])[cid];
    if (c == null) return _no(s, 'inconnu');
    final rom = _m(s['rom']);
    if (rom['off'] != null) return _no(s, 'exclusif');
    if (_n(_m(c)['g']) < Reg21.officialAt) return _no(s, 'seuil');
    final n = clone21(s);
    final r = _m(n['rom']);
    r['off'] = cid;
    r['since'] = n['day'];
    _l(r['hist']).add({'d': n['day'], 't': 'En couple avec ${cands21[cid]!['n']}'});
    _log(n, 'Couple officialisé avec ${cands21[cid]!['n']} : relation exclusive', 'perso');
    return _ok(n);
  },

  'proposal': (s, ans) {
    if (!canPropose21(s)) return _no(s, 'condmariage');
    final n = clone21(s);
    if (ans == 'non') {
      final r = partner(n)!;
      r['g'] = clamp21(_n(r['g']) - Reg21.refuseLoss, 0, 100);
      final rom = _m(n['rom']);
      rom['cool'] = _n(n['day']) + Reg21.refuseCooldown;
      _l(rom['hist']).add({'d': n['day'], 't': 'Demande en mariage refusée'});
      _log(n, 'Tu as refusé la demande : relation −${Reg21.refuseLoss}, nouvelle demande possible dans ${Reg21.refuseCooldown} jours', 'perso');
      return _ok(n);
    }
    _m(n['rom'])['prop'] = 1;
    _log(n, 'Demande acceptée : préparation du mariage', 'perso');
    return _ok(n);
  },

  'wsel': (s, id) {
    final n = clone21(s);
    _m(n['rom'])['wsel'] = id;
    return _ok(n);
  },

  'wed': (s, a) {
    final rom = _m(s['rom']);
    if (!_t(rom['prop']) || _t(rom['married'])) return _no(s, 'condmariage');
    final w = Reg21.weddings[rom['wsel']]!;
    if (_n(s['cash']) < (w['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -(w['cost'] as num));
    final r = _m(n['rom']);
    r['married'] = 1;
    r['wed'] = n['day'];
    r['prop'] = 0;
    final p = partner(n)!;
    p['g'] = clamp21(_n(p['g']) + (w['g'] as num), 0, 100);
    n['pop'] = clamp21(_n(n['pop']) + (w['pop'] as num), 0, 100);
    if (_n(w['pop']) != 0) _geoAdd(n, 'bakoma', 2);
    _l(r['hist']).add({'d': n['day'], 't': 'Mariage avec ${cands21[r['off']]!['n']} (${w['n']})'});
    _log(n, 'Mariage célébré : ${w['n']}', 'perso');
    return _ok(n);
  },

  'separate': (s, a) {
    final off = _m(s['rom'])['off'];
    if (off == null) return _no(s, 'pasdecouple');
    final n = clone21(s);
    _separate(n, off as String, 'Séparation décidée par toi');
    return _ok(n);
  },

  'famProj': (s, ans) {
    if (!_t(_m(s['rom'])['married'])) return _no(s, 'mariage');
    final n = clone21(s);
    final fam = _m(n['fam']);
    fam['proj'] = ans == 'oui' ? 1 : 0;
    fam['projAsked'] = 1;
    _log(n, ans == 'oui' ? "Projet d'enfant : vous essayez (aucune garantie)" : "Projet d'enfant : pas maintenant", 'perso');
    return _ok(n);
  },

  'kid': (s, arg) {
    final l = arg as List;
    final i = int.tryParse('${l[0]}') ?? -1;
    final a = Reg21.kidActs[l[1]];
    final kids = _l(_m(s['fam'])['kids']);
    if (i < 0 || i >= kids.length || a == null) return _no(s, 'inconnu');
    final k = _m(kids[i]);
    if (kidAge(s, k) < (a['min'] as num)) return _no(s, 'age');
    final n = clone21(s);
    final e = _spend(n, a['h'] as num, a['e'] as num);
    if (e != null) return _no(s, e);
    final kk = _m(_l(_m(n['fam'])['kids'])[i]);
    kk['l'] = clamp21(_n(kk['l']) + (a['l'] as num), 0, 100);
    kk['today'] = 1;
    _log(n, '${a['n']} avec ${kk['n']} : lien +${a['l']}', 'perso');
    return _ok(n);
  },

  'fev': (s, ch) {
    final id = _m(s['fam'])['ev'] as String?;
    if (id == null) return _no(s, 'rien');
    final e = fev21[id]!;
    final o = _m(ch == 'a' ? e['a'] : e['b']);
    final n = clone21(s);
    if (o['h'] != null && _n(n['hour']) + (o['h'] as num) > Reg21.dayEnd) return _no(s, 'tard');
    if (o['h'] != null) n['hour'] = _n(n['hour']) + (o['h'] as num);
    if (o['cash'] != null) {
      if (_n(n['cash']) < -(o['cash'] as num)) return _no(s, 'cash');
      _pay(n, o['cash'] as num);
    }
    if (o['e'] != null) n['en'] = math.max(0, _n(n['en']) + (o['e'] as num));
    final r = partner(n);
    if (o['g'] != null && r != null) r['g'] = clamp21(_n(r['g']) + (o['g'] as num), 0, 100);
    if (o['l'] != null) {
      for (final k in _l(_m(n['fam'])['kids'])) {
        _m(k)['l'] = clamp21(_n(_m(k)['l']) + (o['l'] as num), 0, 100);
      }
    }
    final fam = _m(n['fam']);
    fam['ev'] = null;
    fam['evDone'] = {'t': e['t'], 'ch': o['n']};
    _log(n, 'Événement familial · ${e['t']} : ${o['n']}', 'perso');
    return _ok(n);
  },

  // ---------- fin de journée ----------
  'endDay': (s, a) => _endDay(s),

  'skipYear': (s, a) {
    final n = clone21(s);
    final y = ((_n(n['day']) - 1) / Reg21.daysPerYear).floor();
    n['day'] = (y + 1) * Reg21.daysPerYear;
    n['d0'] = dayStart21(n);
    return _endDay(n);
  },

  'ap': (s, arg) {
    final p = '$arg'.split('=');
    final n = clone21(s);
    _m(n['ap'])[p[0]] = p[1];
    return _ok(n);
  },

  // ---------- création de l'artiste et événements ----------
  'setp': (s, arg) {
    final str = '$arg';
    final i = str.indexOf('=');
    final k = str.substring(0, i), v = str.substring(i + 1);
    final n = clone21(s);
    final p = _m(n['p']);
    if (k == 'name') {
      p['name'] = v.length > 40 ? v.substring(0, 40) : v;
    } else if (k == 'age') {
      final cur = _n(p['age']).toInt();
      final a = v == '+' ? cur + 1 : (v == '-' ? cur - 1 : int.tryParse(v));
      p['age'] = clamp21(a == null || a == 0 ? Reg21.startAge : a, Reg21.ageMin, Reg21.ageMax).toInt();
    } else if (k == 'origin' && Reg21.origins.containsKey(v)) {
      p['origin'] = v;
    } else if (k == 'main' && Reg21.styles.containsKey(v)) {
      p['main'] = v;
      if (p['second'] == v) p['second'] = null;
    } else if (k == 'second') {
      p['second'] = (Reg21.styles.containsKey(v) && v != p['main']) ? v : null;
    } else if (k == 'goal' && Reg21.goals.containsKey(v)) {
      p['goal'] = v;
    } else {
      return _no(s, 'inconnu');
    }
    return _ok(n);
  },

  'setui': (s, arg) {
    final str = '$arg';
    final i = str.indexOf('=');
    final k = str.substring(0, i), v = str.substring(i + 1);
    if (!['title', 'th', 'am'].contains(k)) return _no(s, 'inconnu');
    final n = clone21(s);
    _m(n['ui'])[k] = v.length > 40 ? v.substring(0, 40) : v;
    return _ok(n);
  },

  'rtitle': (s, a) {
    final n = clone21(s);
    final ui = _m(n['ui']);
    ui['rt'] = 1;
    ui['title'] = '';
    return _ok(n);
  },

  'uv': (s, k) {
    final n = clone21(s);
    _m(n['ui'])['uv'] = clamp21(int.tryParse('$k') ?? 1, 1, 3);
    return _ok(n);
  },

  'finish': (s, a) {
    if (_t(s['created'])) return _no(s, 'deja');
    if (!nameOk21(_m(s['p'])['name'])) return _no(s, 'nom');
    final n = clone21(s);
    final p = _m(n['p']);
    p['name'] = cleanName21(p['name']);
    n['age'] = p['age'];
    n['created'] = 1;
    final sk = _m(n['sk']);
    final mk = Reg21.styles[p['main']]!['k'] as String;
    sk[mk] = _n(sk[mk]) + Reg21.mainBonus;
    if (p['second'] != null) {
      final sck = Reg21.styles[p['second']]!['k'] as String;
      sk[sck] = _n(sk[sck]) + Reg21.secondBonus;
    }
    if (p['origin'] != 'bakoma') _geoAdd(n, p['origin'] as String, 4);
    n['en'] = enMax(n);
    n['d0'] = dayStart21(n);
    n['evq'] = <dynamic>[];
    _queueEv(n, 'kzer');
    _log(n, 'Bienvenue à Ndolo, ${p['name']} : ta carrière commence', 'carriere');
    return _ok(n);
  },

  'evc': (s, ch) {
    final id = s['ev'] as String?;
    if (id == null) return _no(s, 'rien');
    final n = clone21(s);
    if (id == 'kzer') {
      if (ch == 'a') {
        final e = _spend(n, 1, 15);
        if (e != null) return _no(s, e);
        n['rep'] = _n(n['rep']) + 6;
        n['fans'] = _n(n['fans']) + 150;
        _geoAdd(n, 'bakoma', 2);
        _addXp(n, 20);
      } else {
        n['pop'] = clamp21(_n(n['pop']) + 2, 0, 100);
      }
    }
    if (id == 'kore') {
      const d = {'a': (8000, 15, 'Accord à 40 %'), 'b': (7000, 8, 'Accord à 35 %, mix signé'), 'c': (0, -10, 'Refus')};
      final x = d[ch];
      if (x == null) return _no(s, 'inconnu');
      if (_n(n['cash']) < x.$1) return _no(s, 'cash');
      _pay(n, -x.$1);
      n['kc'] = {'st': x.$3, 'rel': x.$2, 'bonus': ch == 'c' ? 0 : 12, 'left': ch == 'c' ? 0 : 3};
    }
    if (id == 'label') {
      if (ch == 'a') {
        n['signed'] = 1;
        _pay(n, Reg21.labelAdvance);
      } else {
        n['lr'] = 1;
      }
    }
    final e = evt21[id]!;
    final c = _l(e['ch']).map(_m).where((x) => x['id'] == ch).toList();
    if (c.isEmpty) return _no(s, 'inconnu');
    _m(n['evDone'])[id] = ch;
    n['evLast'] = {'t': e['t'], 'ch': c.first['n'], 'c': c.first['c']};
    final q = _l(n['evq']);
    n['ev'] = q.isEmpty ? null : q.removeAt(0);
    _log(n, '${e['t']} : ${c.first['n']} (${c.first['c']})', 'evenement');
    return _ok(n);
  },
};

Res _setUi(J s, String k, dynamic v) {
  final n = clone21(s);
  _m(n['ui'])[k] = v;
  return _ok(n);
}

Res _rom(J s, List arg) {
  final cid = arg[0] as String, act = arg[1] as String;
  final c = cands21[cid], a = Reg21.romActs[act];
  if (c == null || a == null) return _no(s, 'inconnu');
  final rom = _m(s['rom']);
  if (_n(rom['used']) >= Reg21.romPerDay) return _no(s, 'romjour');
  if (rom['off'] != null && rom['off'] != cid) return _no(s, 'exclusif');
  final ex = _m(rom['ex'])[cid];
  if (ex != null && _n(s['day']) < _n(ex)) return _no(s, 'ex');
  if (act == 'scene' && !_t(s['shows'])) return _no(s, 'pasdeconcert');
  if (_n(s['cash']) < (a['c'] as num)) return _no(s, 'cash');
  final n = clone21(s);
  final e = _spend(n, a['h'] as num, a['e'] as num);
  if (e != null) return _no(s, e);
  final mul = _l(c['likes']).contains(act) ? Reg21.likeMul : (_l(c['dis']).contains(act) ? Reg21.dislikeMul : 1.0);
  final gain = jsRound((a['g'] as num) * mul);
  _pay(n, -(a['c'] as num));
  final r = _m(n['rom']);
  final cc = _m(_m(r['c'])[cid]);
  cc['g'] = clamp21(_n(cc['g']) + gain, 0, 100);
  cc['met'] = 1;
  r['used'] = _n(r['used']) + 1;
  _m(r['today'])[cid] = 1;
  r['lastAct'] = {'cid': cid, 'act': act, 'gain': gain, 'mul': mul};
  _log(n, '${a['n']} avec ${c['n']} : relation ${sg21(gain)} (${cc['g']}/100)', 'perso');
  return _ok(n);
}

Res _endDay(J s) {
  final n = clone21(s);
  final ev = <String>[];
  final d0 = n['d0'] != null ? _m(n['d0']) : dayStart21(n);
  // revenus passifs
  num inc = 0;
  for (final id in _m(n['biz']).keys.toList()) {
    final b = Reg21.biz[id]!;
    final x = jsRound((b['lo'] as num) + ((b['hi'] as num) - (b['lo'] as num)) * rng21(n, id.length));
    inc += x;
    final bz = _m(_m(n['biz'])[id]);
    bz['tot'] = _n(bz['tot']) + x;
    ev.add('${b['n']} : ${sg21(x)} (estimé)');
  }
  if (_m(n['own'])['terrain'] != null) {
    final t = Reg21.assets['terrain']!;
    final y = jsRound((t['lo'] as num) + ((t['hi'] as num) - (t['lo'] as num)) * rng21(n, 5));
    inc += y;
    ev.add('Loyer du terrain : ${sg21(y)}');
  }
  if (n['merch'] != null) {
    final mm = _m(n['merch']);
    final m = Reg21.merch[mm['id']]!;
    final z = jsRound((m['perFan'] as num) * math.sqrt(_n(n['fans'])) * Reg21.merchScale);
    inc += z;
    mm['tot'] = _n(mm['tot']) + z;
    mm['left'] = _n(mm['left']) - 1;
    ev.add('${m['n']} : ${sg21(z)}');
    if (_n(mm['left']) <= 0) {
      _m(n['merchDone'])[mm['id'] as String] = mm['tot'];
      ev.add('${m['n']} : stock écoulé');
      n['merch'] = null;
    }
  }
  _pay(n, inc);
  num cost = 0;
  if (_m(n['own'])['appart'] != null) cost += Reg21.assets['appart']!['upkeep'] as num;
  if (_m(n['rom'])['off'] != null) cost += Reg21.coupleCost;
  cost += _l(_m(n['fam'])['kids']).length * Reg21.kidCost;
  if (cost != 0) {
    _pay(n, -cost);
    ev.add('Charges du foyer : ${sg21(-cost)}');
  }
  // relations : baisse sans entretien
  final rom = _m(n['rom']);
  for (final cid in cands21.keys) {
    final c = _m(_m(rom['c'])[cid]);
    if (!_t(c['met']) || _m(rom['today'])[cid] != null) continue;
    final dec = cid == rom['off'] ? Reg21.decayCouple : (rom['off'] != null ? 0 : Reg21.decayCourt);
    if (dec != 0 && _n(c['g']) > 0) c['g'] = math.max(0, _n(c['g']) - dec);
  }
  var r = partner(n);
  if (r != null && _n(r['g']) < Reg21.leaveAt) {
    final who = rom['off'] as String;
    _separate(n, who, 'Rupture décidée par ${cands21[who]!['n']} (relation trop dégradée, sous ${Reg21.leaveAt})');
    ev.add('Rupture : ${cands21[who]!['n']} est parti(e) — relation sous ${Reg21.leaveAt}');
    r = null;
  } else if (r != null && _n(r['g']) < Reg21.warnAt) {
    ev.add('Attention : la relation avec ${cands21[rom['off']]!['n']} se dégrade (${r['g']}/100)');
  }
  // enfants
  final fam = _m(n['fam']);
  final kids = _l(fam['kids']);
  if (_t(rom['married']) && _t(fam['proj']) && kids.length < Reg21.maxKids && rng21(n, 3) < Reg21.kidChance) {
    final nm = kidNames21[kids.length];
    kids.add({'n': nm, 'born': _n(n['day']) + 1, 'l': 50, 'garde': 'Au foyer'});
    fam['proj'] = 0;
    ev.add('Naissance : $nm est arrivé(e) au foyer');
    _l(rom['hist']).add({'d': _n(n['day']) + 1, 't': 'Naissance de $nm'});
  }
  // événement familial du lendemain (déterministe)
  if (fam['ev'] == null) {
    final d = _n(n['day']).toInt();
    if (kids.isNotEmpty && d % 3 == 0) {
      fam['ev'] = 'fievre';
    } else if (_t(rom['married']) && d % 4 == 1) {
      fam['ev'] = 'dimanche';
    } else if (rom['off'] != null && d % 5 == 2) {
      fam['ev'] = 'anniv';
    }
  }
  // nuit et passage du temps
  final y0 = ((_n(n['day']) - 1) / Reg21.daysPerYear).floor();
  n['day'] = _n(n['day']) + 1;
  n['hour'] = Reg21.dayStart;
  rom['used'] = 0;
  rom['today'] = <String, dynamic>{};
  for (final k in kids) {
    _m(k)['today'] = 0;
  }
  final y1 = ((_n(n['day']) - 1) / Reg21.daysPerYear).floor();
  Map<String, dynamic>? aged;
  if (y1 > y0) {
    final em0 = enMax(n);
    n['age'] = _n(n['age']) + 1;
    aged = {'age': n['age'], 'em0': em0, 'em1': enMax(n)};
    ev.add('Nouvelle année : ${n['age']} ans, énergie max $em0 → ${enMax(n)}');
    for (final k in kids) {
      ev.add('${_m(k)['n']} : ${stageOf(kidAge(n, _m(k)))}');
    }
  }
  final baby = kids.any((k) => kidAge(n, _m(k)) < 1 && _m(k)['garde'] == 'Au foyer');
  n['en'] = enMax(n) - (baby ? Reg21.babyMorning : 0);
  _promote(n);
  if (_n(n['rep']) >= Reg21.labelRep && !_t(n['signed'])) _queueEv(n, 'label');
  final rel1 = partner(n);
  final famRe = RegExp(r'Rupture|Attention|Naissance|Charges du foyer| : (Bébé|Petite enfance|Enfant|Adolescent|Adulte)$');
  final yesterday = _l(n['log']).map(_m).where((l) => l['d'] == _n(n['day']) - 1).toList();
  n['bil'] = {
    'day': _n(n['day']) - 1, 'cash': _n(n['cash']) - _n(d0['cash']), 'pop': _n(n['pop']) - _n(d0['pop']), 'fans': _n(n['fans']) - _n(d0['fans']), 'xp': _n(n['xp']) - _n(d0['xp']),
    'rank0': d0['rank'], 'rank': n['rank'], 'en': n['en'], 'enMax': enMax(n), 'rel0': d0['rel'], 'rel': rel1?['g'], 'who': rel1 != null ? cands21[rom['off']]!['n'] : '',
    'kids': kids.length, 'kids0': d0['kids'],
    'fam': [...ev.where(famRe.hasMatch), ...yesterday.where((l) => l['c'] == 'perso').map((l) => l['t'])].take(6).toList(),
    'ev': ev, 'acts': yesterday.map((l) => l['t']).take(8).toList(), 'aged': aged,
  };
  n['d0'] = dayStart21(n);
  n['lastJob'] = null;
  fam['evDone'] = null;
  n['idx0'] = idxParts21(s).i;
  return _ok(n);
}

// ---------------------------------------------------------------------------------------------------------------------
// Préréglages de démonstration
// ---------------------------------------------------------------------------------------------------------------------

final Map<String, J Function()> presets21 = {
  'debut': init21,
  'couple': () {
    final s = init21();
    s['day'] = 20;
    final c = _m(_m(s['rom'])['c']);
    _m(c['lina'])['g'] = 82;
    _m(c['lina'])['met'] = 1;
    _m(c['kadi'])['g'] = 22;
    _m(c['kadi'])['met'] = 1;
    final rom = _m(s['rom']);
    rom['off'] = 'lina';
    rom['since'] = 5;
    _l(rom['hist']).add({'d': 5, 't': 'En couple avec Lina Mbaré'});
    s['cash'] = 220000;
    s['shows'] = 1;
    s['d0'] = dayStart21(s);
    return s;
  },
  'marie': () {
    final s = presets21['couple']!();
    final rom = _m(s['rom']);
    rom['married'] = 1;
    rom['wed'] = 18;
    _l(rom['hist']).add({'d': 18, 't': 'Mariage avec Lina Mbaré (Cérémonie simple)'});
    _m(s['fam'])['proj'] = 1;
    _m(s['fam'])['projAsked'] = 1;
    s['d0'] = dayStart21(s);
    return s;
  },
  'parent': () {
    final s = presets21['marie']!();
    final fam = _m(s['fam']);
    fam['proj'] = 0;
    _l(fam['kids']).add({'n': 'Nayla', 'born': 330, 'l': 55, 'garde': 'Au foyer'});
    s['day'] = 400;
    s['age'] = 20;
    _l(_m(s['rom'])['hist']).add({'d': 330, 't': 'Naissance de Nayla'});
    fam['ev'] = 'fievre';
    s['d0'] = dayStart21(s);
    return s;
  },
  'carriere': () {
    final s = init21();
    s['day'] = 30;
    s['xp'] = 3100;
    s['rank'] = 3;
    s['trained'] = 1;
    s['fans'] = 2400;
    s['pop'] = 18;
    s['rep'] = 31;
    s['cash'] = 320000;
    s['shows'] = 1;
    _m(s['sk'])['cha'] = 12;
    s['disco'] = [
      {'id': 'T1', 'title': 'Gbaka de 6h', 'theme': 'quartier', 'amb': 'sombre', 'mode': 'manuel', 'tx': 72, 'st': 'sorti', 'Q': 61, 'feats': <dynamic>[], 'clip': {'st': 'aucun'}, 'L': 5418, 'rev': 54, 'fg': 371, 'pg': 6, 'tier': 'Discret', 'promo': 0, 'vir': 30, 'day': 3},
    ];
    s['geo'] = {'bakoma': 14, 'portambre': 4, 'selene': 3, 'tamarel': 0, 'korvane': 0, 'aldera': 0};
    s['d0'] = dayStart21(s);
    return s;
  },
  'star': () {
    final s = presets21['carriere']!();
    s['xp'] = 6200;
    s['rank'] = 5;
    s['fans'] = 14800;
    s['pop'] = 41;
    s['cash'] = 1400000;
    s['shows'] = 6;
    _l(s['disco']).insert(0, {'id': 'T2', 'title': 'Monter au sommet', 'theme': 'ambition', 'amb': 'fiere', 'mode': 'manuel', 'tx': 76, 'st': 'sorti', 'Q': 70, 'feats': ['nadia'], 'clip': {'st': 'publie', 'dir': 'ombre', 'vir': 15}, 'L': 84000, 'rev': 840, 'fg': 2100, 'pg': 14, 'tier': 'Bon', 'promo': 2, 'vir': 69, 'day': 25});
    s['geo'] = {'bakoma': 46, 'portambre': 22, 'selene': 19, 'tamarel': 3, 'korvane': 0, 'aldera': 1};
    _m(s['own'])['moto'] = {'since': 12};
    s['d0'] = dayStart21(s);
    return s;
  },
};

Res _preset(J s, dynamic id) {
  final f = presets21[id];
  if (f == null) return _no(s, 'inconnu');
  final x = f();
  if (!_t(x['created'])) {
    x['created'] = 1;
    _m(x['p'])['name'] = 'Djo Kéné';
  }
  if (id == 'debut') {
    x['ev'] = 'kzer';
  } else {
    x['evDone'] = {..._m(x['evDone']), 'kzer': 'b'};
    x['ms'] = <String, dynamic>{};
    final dn = {'m1': _l(x['disco']).isNotEmpty, 'm2': _l(x['disco']).isNotEmpty, 'm3': _t(x['trained']), 'm4': _n(x['fans']) >= 1000};
    for (final e in dn.entries) {
      if (e.value) _m(x['ms'])[e.key] = 1;
    }
  }
  return _ok(x);
}

// ---------------------------------------------------------------------------------------------------------------------
// Point d'entrée
// ---------------------------------------------------------------------------------------------------------------------

/// Exécute une action sur un état : complète l'état, applique l'action, termine les missions de départ puis date l'état.
/// [now] : date de l'enregistrement en millisecondes (le domaine ne lit pas l'horloge).
Res act21(J s, String name, [dynamic arg, int now = 0]) {
  final st = norm21(s);
  final f = name == 'preset' ? _preset : actions21[name];
  if (f == null) return _no(st, 'inconnu');
  final r = name == 'preset' ? _preset(st, arg) : (f as Action)(st, arg);
  if (r.err == null && !identical(r.s, st)) {
    norm21(r.s);
    _missions(r.s);
    r.s['t'] = now;
  }
  return r;
}
