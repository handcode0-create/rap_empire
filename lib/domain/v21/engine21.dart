// ignore_for_file: avoid_dynamic_calls, prefer_const_declarations, unnecessary_cast
import 'dart:convert';
import 'dart:math' as math;
import '../title_dictionary.dart';
import 'awards21.dart';
import 'playlists21.dart';
import 'dialogues21.dart';
import 'missions21.dart';
import 'network21.dart';
import 'social21.dart';
import 'reg21.dart';
import 'wardrobe21.dart';

export 'awards21.dart';
export 'charts21.dart';
export 'playlists21.dart';
export 'dialogues21.dart';
export 'missions21.dart';
export 'network21.dart';
export 'social21.dart';
export 'wardrobe21.dart';

/// Moteur RAP EMPIRE v21. Port de docs/design-ref/v21/sources/engine21.js : mêmes règles, mêmes valeurs, mêmes codes d'erreur.
/// Écarts assumés avec le prototype (extensions déjà présentes dans l'application) : 10 thèmes de la bibliothèque musicale, titres générés,
/// biens supplémentaires, niveaux de manager M1 à M6, revenus de catalogue quotidiens, rivaux autres que K-Zer. Tests de parité : test/parity21_test.dart.
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
  final s = r
      .abs()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
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

int enMax(J s) => enMaxAge(_n(s['age']).toInt()) +
    (_m(s['own'])['appart'] != null ? 5 : 0) +
    (_m(s['own'])['maison'] != null ? 10 : 0);

String stageOf(int age) {
  var n = Reg21.stages.first.$2;
  for (final (a, v) in Reg21.stages) {
    if (age >= a) n = v;
  }
  return n;
}

int kidAge(J s, J k) =>
    ((_n(s['day']) - _n(k['born'])) / Reg21.daysPerYear).floor();

J? partner(J s) {
  final off = _m(s['rom'])['off'];
  return off == null ? null : _m(_m(_m(s['rom'])['c'])[off]);
}

// ---------------------------------------------------------------------------------------------------------------------
// État initial
// ---------------------------------------------------------------------------------------------------------------------

J init21() {
  final s = <String, dynamic>{
    'v': 21,
    'wd': initWardrobe21(),
    'mk': initMk21(),
    'soc': initSocial21(),
    'kv': 0,
    'mcl': 0,
    'lbz': 0,
    'ms2': <String, dynamic>{},
    'mc2': <String, dynamic>{},
    'pbd': 0,
    'aw': <String, dynamic>{'done': <String, dynamic>{}, 'hist': <dynamic>[]},
    'certSeen': <String, dynamic>{},
    'pl': <String, dynamic>{'plc': <String, dynamic>{}, 'cool': <String, dynamic>{}, 'last': null},
    'awNews': <dynamic>[],
    'stock': <dynamic>[],
    'pendingProjects': <dynamic>[],
    'songSeq': 0,
    'created': 0,
    'btq': null,
    'bt': null,
    'btl': null,
    'mature': 0,
    'projects': <dynamic>[],
    'heat': 0,
    'crimeN': 0,
    'cas': null,
    'casier': <dynamic>[],
    'dlg': null,
    'dq': <dynamic>[],
    'dseen': <String, dynamic>{},
    'rel': <String, dynamic>{},
    'mgr': null,
    'lcut': null,
    'duo': null,
    'hype': 0,
    'diss': 0,
    'p': {
      'name': '',
      'age': Reg21.startAge,
      'origin': 'bakoma',
      'main': 'drill',
      'second': null,
      'goal': 'quartier'
    },
    'ms': <String, dynamic>{},
    'evq': <dynamic>[],
    'ev': null,
    'evDone': <String, dynamic>{},
    'kc': {'left': 0, 'bonus': 0, 'rel': 0, 'st': ''},
    'cc': null,
    'lastConcert': -99,
    'lastTour': -99,
    'seed': 7,
    'day': 1,
    'hour': 8,
    'age': Reg21.startAge,
    'cash': 25000,
    'en': 100,
    'pop': 3,
    'fans': 120,
    'rep': 8,
    'xp': 0,
    'rank': 1,
    'sk': {'flow': 17, 'ecr': 14, 'voix': 10, 'cha': 8},
    'cur': null,
    'disco': <dynamic>[],
    'shows': 0,
    'geo': {
      'bakoma': 4,
      'portambre': 0,
      'selene': 0,
      'tamarel': 0,
      'korvane': 0,
      'aldera': 0
    },
    'own': <String, dynamic>{},
    'biz': <String, dynamic>{},
    'merch': null,
    'merchDone': <String, dynamic>{},
    'signed': 0,
    'jail': null,
    'jphone': 0,
    'jrep': 0,
    'jrec': -1,
    'jrio': -1,
    'jfight': -1,
    'rivals': <String, dynamic>{},
    'managerPaid': 0,
    'ap': {'hair': 'hitwist', 'top': 'hoodie', 'skin': '3'},
    'rom': {
      'c': <String, dynamic>{},
      'used': 0,
      'today': <String, dynamic>{},
      'off': null,
      'since': 0,
      'married': 0,
      'wed': 0,
      'cool': 0,
      'ex': <String, dynamic>{},
      'hist': <dynamic>[],
      'prop': 0,
      'wsel': 'simple'
    },
    'fam': {'kids': <dynamic>[], 'proj': 0, 'ev': null},
    'log': <dynamic>[],
    'bil': null,
    'd0': null,
    'ui': {'promo': 0, 'ppromo': 0, 'feat': null},
    't': 0,
    'evId': 0,
  };
  for (final k in cands21.keys) {
    _m(_m(s['rom'])['c'])[k] = {'g': 0};
  }
  s['d0'] = dayStart21(s);
  return s;
}

J dayStart21(J s) {
  final r = partner(s);
  return {
    'cash': s['cash'],
    'pop': s['pop'],
    'fans': s['fans'],
    'xp': s['xp'],
    'rank': s['rank'],
    'en': s['en'],
    'rel': r?['g'],
    'geoB': _m(s['geo'])['bakoma'],
    'kids': _l(_m(s['fam'])['kids']).length
  };
}

/// Complète une ancienne sauvegarde avec les champs ajoutés depuis (comme norm du prototype).
J norm21(J s) {
  final d = init21();
  // Anciennes sauvegardes sans intérêt des labels : on le reconstitue à partir de la carrière déjà faite.
  if (!s.containsKey('lbz') && s.containsKey('disco')) {
    s['lbz'] = math.min(Reg21.lbzMax, _l(s['disco']).length * Reg21.lbzSingle + _l(s['projects']).length * Reg21.lbzProject + _n(s['shows']) * Reg21.lbzShow);
  }
  for (final k in d.keys) {
    s.putIfAbsent(k, () => d[k]);
  }
  // Anciennes sauvegardes : manager, détention, attente de battle.
  if (s.containsKey('mg')) {
    if (_t(s['mg']) && !_t(s['mgr'])) s['mgr'] = s['mgLevel'] == null || s['mgLevel'] == 'm1' ? 'maya' : s['mgLevel'];
    s.remove('mg');
    s.remove('mgLevel');
  }
  if (s['jail'] is num) {
    final left = _n(s['jail']);
    s['jail'] = left > 0 ? {'until': _n(s['day']) + left, 'days': left} : null;
  }
  s.remove('charges');
  s.remove('project');
  if (s.containsKey('battlePending')) {
    if (_t(s['battlePending']) && s['btq'] == null) s['btq'] = 'kzer';
    s.remove('battlePending');
  }
  _migrateInedits(s);
  return s;
}

/// Anciennes sauvegardes : les inédits d'un projet sorti avant le 21/10/2026 n'avaient ni écoutes ni ventes propres.
/// Ils entrent au catalogue avec leur part des écoutes du projet (au prorata de la qualité). Revenus passés non rejoués.
void _migrateInedits(J s) {
  List lst(dynamic x) => x is List ? x : const [];
  final projects = lst(s['projects']);
  if (projects.every((p) => lst(_m(p)['inedits']).isEmpty)) return;
  final disco = List<dynamic>.of(lst(s['disco']));
  final ids = disco.map((x) => _m(x)['id']).toSet();
  var added = false;
  for (final p in projects.map(_m)) {
    final all = lst(p['inedits']).map(_m).toList();
    final ined = all.where((i) => !ids.contains(i['id'])).toList();
    if (ined.isEmpty) continue;
    final qs = all.fold<num>(0, (a, i) => a + _n(i['Q'])) + lst(p['tracks']).where((id) => ids.contains(id)).length * _n(p['Q']);
    for (final i in ined) {
      final st = jsRound(_n(p['L']) * (qs > 0 ? _n(i['Q']) / qs : 0));
      disco.add(<String, dynamic>{
        'id': i['id'], 'title': i['title'], 'Q': i['Q'], 'st': 'sorti', 'day': p['day'],
        'L': st, 'launchL': st, 'sales': jsRound(st * Reg21.singleSales), 'rev': 0, 'streamRev': 0, 'salesRev': 0, 'cut': 0,
        'feats': <dynamic>[], 'clip': <String, dynamic>{'st': 'aucun'}, 'tier': tierOf21(st), 'fg': 0, 'pg': 0, 'labelAt': p['labelAt'] ?? 'Indépendant',
      });
      ids.add(i['id']);
      added = true;
    }
  }
  if (added) s['disco'] = disco;
}

void _log(J s, String t, [String cat = 'jeu']) {
  final lg = _l(s['log']);
  lg.insert(0, {'t': t, 'c': cat, 'd': s['day']});
  if (lg.length > 40) lg.removeRange(40, lg.length);
}

void _pay(J s, num a) => s['cash'] = math.max(0, _n(s['cash']) + a);

num _cachet(J s, num amount, String label) {
  final tier = managerTier21(s);
  final commission = tier == null ? 0 : jsRound(amount * (tier['rate'] as num));
  _pay(s, amount - commission);
  if (tier == null) return 0;
  s['managerPaid'] = _n(s['managerPaid']) + commission;
  s['mgrTot'] = _n(s['mgrTot']) + commission;
  _log(s, 'Manager ${tier['n']} : −${fmt21(commission)} cauris (${((tier['rate'] as num) * 100).toStringAsFixed(0)} % de $label)',
      'eco');
  return commission;
}

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
  if (c['singles'] != null && _l(s['disco']).length < (c['singles'] as num)) {
    return false;
  }
  if (c['pop'] != null && _n(s['pop']) < (c['pop'] as num)) return false;
  if (c['shows'] != null && _n(s['shows']) < (c['shows'] as num)) return false;
  if (c['fans'] != null && _n(s['fans']) < (c['fans'] as num)) return false;
  if (c['bon'] != null && !_l(s['disco']).any((d) => _n(_m(d)['L']) >= 50000)) {
    return false;
  }
  if (c['hit'] != null &&
      !_l(s['disco']).any((d) => _n(_m(d)['L']) >= Reg21.entry)) {
    return false;
  }
  return true;
}

void _promote(J s) {
  final r = Reg21.ranks;
  while (_n(s['rank']) < r.length &&
      _n(s['xp']) >= (r[_n(s['rank']).toInt()]['xp'] as num) &&
      condOk21(s, r[_n(s['rank']).toInt()])) {
    s['rank'] = _n(s['rank']) + 1;
    _log(s, 'Promotion : N${s['rank']} · ${r[_n(s['rank']).toInt() - 1]['n']}',
        'carriere');
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
  final raw = (9000 + 6 * (fans - 120)) *
      (promos21[promo]['m'] as num) *
      (q / 100) *
      _k;
  return jsRound(raw / (1 + raw / Reg21.listenCap));
}

/// Répartition des écoutes entre les plateformes fictives Ondéa (70 %) et Cauri Music (30 %).
J _platformStreams21(num total) {
  final p = platformSplit21(total);
  return {'ondea': p.ondea, 'cauri': p.cauri};
}

int virOf21(J song, [int promo = 0]) {
  var v = Reg21.virBase +
      (Reg21.themes[song['theme']]!['vir'] as int) +
      (Reg21.ambs[song['amb']]!['vir'] as int) +
      Reg21.promoVir[promo];
  for (final f in _l(song['feats'])) {
    v += Reg21.feats[f]!['vir'] as int;
  }
  final clip = song['clip'];
  if (clip != null && _m(clip)['st'] == 'publie') {
    v += _n(_m(clip)['vir']).toInt();
  }
  return clamp21(v, 0, 100).toInt();
}

String tierOf21(num l) {
  var t = Reg21.tiers.first.$2;
  for (final (a, n) in Reg21.tiers) {
    if (l >= a) t = n;
  }
  return t;
}

/// Titres déjà pris par le joueur (son en cours, réserve, sortis, EP et albums) : le dictionnaire ne les reproduit pas.
Set<String> usedTitles21(J s) {
  final out = <String>{};
  void take(dynamic x) {
    if (x is Map && x['title'] is String) out.add(x['title'] as String);
  }

  take(s['cur']);
  for (final k in ['disco', 'stock', 'projects', 'pendingProjects']) {
    for (final x in _l(s[k] ?? const [])) {
      take(x);
      if (x is Map) {
        for (final y in _l(x['inedits'] ?? const [])) {
          take(y);
        }
      }
    }
  }
  return out;
}

int _titleSeed21(J s) => _n(s['seed']).toInt() + _n(s['day']).toInt() * 31 + _l(s['disco']).length * 101 + _l(s['stock']).length * 17 + _n(s['songSeq']).toInt() * 211;

String _randomTitle21(J s, String theme) =>
    pickTitle(_titleSeed21(s), kind: TitleKind.single, theme: theme, used: usedTitles21(s), maxLength: 30);

/// Idées de titres pour l'écran (n'écrit rien dans la partie) : [kind] vaut 'single', 'EP' ou 'Album', [page] fait défiler les idées.
List<String> titleIdeas21(J s, {String kind = 'single', int page = 0, int count = 3}) {
  final ui = _m(s['ui']);
  final k = kind == 'EP' ? TitleKind.ep : (kind == 'Album' ? TitleKind.album : TitleKind.single);
  return titleIdeas(_titleSeed21(s), kind: k, theme: k == TitleKind.single ? (ui['th'] ?? 'quartier') as String : null, page: page, count: count, used: usedTitles21(s));
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
  return jsRound(listensFor21(q, _n(s['fans']), promo) *
      (0.8 + virOf21(song, promo) / 250) *
      featBoost21(song));
}

J? _clipSong(J s) {
  final cur = s['cur'];
  if (cur != null && _m(cur)['st'] != 'sorti') return _m(cur);
  final d = _l(s['disco']);
  return d.isEmpty ? null : _m(d.first);
}

/// Titre visé par le clip : le titre en cours, sinon le dernier sorti.
J? clipSong21(J s) => _clipSong(s);

int tickets21(J s) => math.min(
    Reg21.capacity,
    jsRound((40 + _n(s['fans']) * 0.05 + _n(_m(s['geo'])['bakoma']) * 4) *
        (s['lperk'] == 'scene' ? 1.2 : 1)));

/// Indice du Top 10 Global (R10) et ses cinq parties. Échelles provisoires de l'étude D-17.
({double f, double g, double c, double s, double n, double i}) idxParts21(J s) {
  double lg(num x, num ref, num x0) =>
      100 * math.min(1, _log10(1 + math.max(x, 0) / x0) / _log10(1 + ref / x0));
  final cat = _l(s['disco']).fold<num>(0, (a, x) => a + _n(_m(x)['L']));
  final f = lg(_n(s['fans']), 5e6, 1e3),
      g = lg(_n(s['fans']) - 120, 200e3, 1e3),
      c = lg(cat, 30e6, 1e4),
      sc = lg(_n(s['shows']) * 300, 2e6, 5e2);
  final n = math.min(100, _n(s['pop'])).toDouble();
  return (
    f: f,
    g: g,
    c: c,
    s: sc,
    n: n,
    i: 0.25 * f + 0.15 * g + 0.30 * c + 0.20 * sc + 0.10 * n
  );
}

double _log10(num x) => math.log(x) / math.ln10;

// ---------------------------------------------------------------------------------------------------------------------
// Relations
// ---------------------------------------------------------------------------------------------------------------------

bool canPropose21(J s) {
  final r = partner(s);
  final rom = _m(s['rom']);
  return r != null &&
      !_t(rom['married']) &&
      _n(r['g']) >= Reg21.proposeAt &&
      _n(s['day']) - _n(rom['since']) >= Reg21.proposeMinDays &&
      _n(s['day']) >= _n(rom['cool']);
}

// ---------------------------------------------------------------------------------------------------------------------
// Événements de carrière
// ---------------------------------------------------------------------------------------------------------------------

void _queueEv(J n, String id) {
  if (_t(_m(n['evDone'])[id]) || n['ev'] == id || _l(n['evq']).contains(id)) {
    return;
  }
  if (n['ev'] == null) {
    n['ev'] = id;
  } else {
    _l(n['evq']).add(id);
  }
}

void _missions(J n) {
  final cur = n['cur'];
  final done = {
    'm1': _l(n['disco']).isNotEmpty ||
        (cur != null && _m(cur)['st'] == 'enregistre'),
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
      _log(
          n,
          'Mission accomplie : ${m['t']} (+${fmt21(m['cash'] as num)} cauris, +${m['xp']} XP)',
          'mission');
    }
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Séparation
// ---------------------------------------------------------------------------------------------------------------------

void _separate(J n, String cid, String why) {
  final rom = _m(n['rom']);
  _l(rom['hist']).add({
    'd': n['day'],
    't':
        '$why · ${cands21[cid]!['n']}${_t(rom['married']) ? ' (après mariage)' : ' (avant mariage)'}'
  });
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
  _log(n, '$why avec ${cands21[cid]!['n']} : historique et enfants conservés',
      'perso');
}

// ---------------------------------------------------------------------------------------------------------------------
// Création de l'artiste
// ---------------------------------------------------------------------------------------------------------------------

String cleanName21(dynamic x) =>
    (x ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();

bool nameOk21(dynamic x) {
  final n = cleanName21(x);
  return n.length >= Reg21.nameMin &&
      n.length <= Reg21.nameMax &&
      RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ0-9 '\-.]+$").hasMatch(n);
}

// ---------------------------------------------------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------------------
// Dialogues, labels, justice : aides (port de engine21.js, mise à jour v21 complète)
// ---------------------------------------------------------------------------------------------------------------------

dynamic _copy(dynamic v) => v is Map || v is List ? jsonDecode(jsonEncode(v)) : v;

/// Commission du manager : Maya (M1, `mgr == 'maya'`) prend 8 % ; les autres niveaux suivent managerTiers.
J? managerTier21(J s) {
  final m = s['mgr'];
  if (!_t(m)) return null;
  return Reg21.managerTiers[m == 'maya' ? 'm1' : m];
}

/// Nom du label signé (Bakoma Sound Records par défaut).
String lblName21(J n) => lbl21[n['label']]?.n ?? 'Bakoma Sound Records';

/// Ventes cumulées d'un projet ou d'un titre selon les plateformes fictives (aucun revenu en plus des écoutes).
({int ondea, int cauri}) platformSplit21(num listens) => (
      ondea: jsRound(listens * (Reg21.platforms['ondea']!['share'] as num)),
      cauri: jsRound(listens * (Reg21.platforms['cauri']!['share'] as num)),
    );

void _queueDlg(J n, String id, [num d = 0]) {
  if (_t(_m(n['dseen'])[id]) && d == 0) return;
  final cur = n['dlg'];
  if ((cur != null && _m(cur)['id'] == id) || _l(n['dq']).any((x) => _m(x)['id'] == id)) return;
  _l(n['dq']).add({'id': id, 'at': _n(n['day']) + d});
}

/// Déclenche les scènes de dialogue de la carrière puis ouvre la première dont le jour est venu.
void _triggers(J n) {
  if (!_t(n['created'])) return;
  final seen = _m(n['dseen']);
  for (final id in dlgOrder21) {
    if (!_t(seen[id]) && dlg21[id]!.cond(n)) _queueDlg(n, id);
  }
  if (n['dlg'] == null) {
    final dq = _l(n['dq']);
    for (var i = 0; i < dq.length; i++) {
      if (_n(_m(dq[i])['at']) <= _n(n['day'])) {
        n['dlg'] = {'id': _m(dq[i])['id'], 'node': 'n1', 'path': <dynamic>[]};
        dq.removeAt(i);
        break;
      }
    }
  }
}

/// Conséquences d'un choix de dialogue. Renvoie un code d'erreur ('cash', 'energie', 'tard') ou null.
String? _applyEff(J n, J? e) {
  if (e == null) return null;
  final cash = e['cash'] as num?;
  if (_t(cash) && cash! < 0 && _n(n['cash']) < -cash) return 'cash';
  if (_t(e['h']) || _t(e['en'])) {
    final er = _spend(n, _n(e['h']), _n(e['en']));
    if (er != null) return er;
  }
  if (_t(cash)) _pay(n, cash!);
  if (_t(e['cachet'])) _cachet(n, e['cachet'] as num, 'scène');
  for (final k in const ['fans', 'rep', 'xp', 'shows']) {
    if (_t(e[k])) {
      if (k == 'xp') {
        _addXp(n, e['xp'] as num);
      } else {
        n[k] = _n(n[k]) + (e[k] as num);
      }
    }
  }
  if (_t(e['pop'])) n['pop'] = clamp21(_n(n['pop']) + (e['pop'] as num), 0, 100);
  if (e['rel'] != null) {
    final rel = _m(n['rel']);
    _m(e['rel']).forEach((k, v) => rel[k] = clamp21(_n(rel[k]) + (v as num), -100, 100));
  }
  if (e['geo'] != null) _m(e['geo']).forEach((k, v) => _geoAdd(n, k, v as num));
  if (e['kc'] != null) {
    final kc = _m(e['kc']);
    n['kc'] = {'st': kc['st'], 'bonus': kc['bonus'], 'left': kc['left'], 'rel': _n(_m(n['rel'])['kore'])};
  }
  if (e['set'] != null) {
    _m(e['set']).forEach((k, v) {
      if (k == 'sk.ecr') {
        _m(n['sk'])['ecr'] = _n(_m(n['sk'])['ecr']) + (v as num);
      } else {
        n[k] = _copy(v);
      }
    });
    if (_m(e['set'])['lperk'] == 'prod') {
      n['kc'] = {'st': 'Label Studio Kôrô Productions', 'bonus': 12, 'left': 3, 'rel': _n(_m(n['rel'])['kore'])};
    }
  }
  if (_t(e['hype'])) n['hype'] = _n(n['day']) + (e['hype'] as num);
  if (e['q'] != null) _queueDlg(n, _l(e['q'])[0] as String, _l(e['q'])[1] as num);
  return null;
}

/// Actions autorisées en prison (avec les écrans de réglage) : le reste répond 'prison'.
const jailOk21 = {
  'endDay', 'jw', 'js', 'jrecord', 'jphone', 'jrio', 'jfight', 'dch', 'dclose', 'dstart', 'preset', 'setui', 'setp', 'uv', 'ap', 'reset', 'skipYear', 'ctk',
  'ctki', 'ptype', 'ptk', 'ptki', 'trial', 'lawyer', 'mature', 'osel', 'ocancel', 'kv', 'mcl', 'mkcancel', 'mclaim', 'awseen'
};

/// Numéro du prochain titre : croissant même quand des titres restent en réserve ou partent dans un EP / album.
int _nextSongSeq(J n) {
  final seq = math.max(_n(n['songSeq']), _l(n['disco']).length).toInt() + 1;
  n['songSeq'] = seq;
  return seq;
}

int _promoCost(J s, int promo) => (s['lperk'] == 'radio' && promo == 2) ? 0 : (promos21[promo]['c'] as num).toInt();

/// Sortie d'un titre : écoutes, ventes, revenus, fans, popularité. Partagée par la sortie immédiate, le titre sorti de la réserve
/// et la sortie programmée qui arrive à échéance. Le coût de la promotion est payé avant par l'appelant.
void _doRelease(J n, J c, int promo) {
  c['vir'] = virOf21(c, promo);
  var L = jsRound(listensFor21(_n(c['Q']), _n(n['fans']), promo) * (0.8 + _n(c['vir']) / 250) * featBoost21(c));
  if (_t(n['hype']) && _n(n['day']) <= _n(n['hype'])) {
    L = jsRound(L * 1.2);
    c['hype'] = 1;
  }
  n['hype'] = 0;
  if (_t(n['diss'])) {
    L = jsRound(L * 1.1);
    c['diss'] = 1;
    n['diss'] = 0;
  }
  // [VALIDÉ 20/10, valeurs provisoires] campagnes marketing actives : bonus d'écoutes de la sortie.
  final mb = mkBoost21(n);
  if (mb > 0) {
    L = jsRound(L * (1 + mb));
    c['mkB'] = jsRound(mb * 100);
  }
  final cutRate = _t(n['lcut']) ? _n(n['lcut']) : Reg21.labelCut;
  final signed = _t(n['signed']);
  final gross = jsRound(L * Reg21.listenValue);
  var rev = signed ? jsRound(gross * (1 - cutRate)) : gross;
  final fg = (L * 0.07 / (1 + _n(n['fans']) / Reg21.fanSat)).ceil();
  var pg = (L / 900).floor();
  if (c['duo'] != null) {
    final dc = jsRound(rev * _n(c['duo']) / 100);
    rev -= dc;
    c['duoCut'] = dc;
  }
  final sl = jsRound(L * Reg21.singleSales);
  final sg0 = sl * Reg21.salePrice;
  final sr = signed ? jsRound(sg0 * (1 - cutRate)) : sg0;
  c['salesRev'] = sr;
  c['cut'] = _n(c['cut']);
  c['salesCut'] = sg0 - sr;
  rev += sr;
  pg = jsRound(math.min(12, pg) * (1 - _n(n['pop']) / 100));
  _pay(n, rev);
  n['fans'] = _n(n['fans']) + fg;
  n['pop'] = clamp21(_n(n['pop']) + pg, 0, 100);
  _geoAdd(n, 'bakoma', math.min(12, jsRound(L / 1500 * 10) / 10 + 1));
  if (promo == 2) {
    _geoAdd(n, 'portambre', 2);
    _geoAdd(n, 'selene', 2);
  }
  c['labelAt'] = signed ? lblName21(n) : 'Indépendant';
  c['auteur'] = _m(n['p'])['name'];
  c['sales'] = sl;
  final perk = n['lperk'];
  final sk = _m(n['sk']);
  if (perk == 'export') {
    _geoAdd(n, 'portambre', 3);
    _geoAdd(n, 'selene', 3);
  }
  if (perk == 'dev') {
    sk['flow'] = _n(sk['flow']) + 1;
    sk['voix'] = _n(sk['voix']) + 1;
  }
  if (perk == 'ecr') sk['ecr'] = _n(sk['ecr']) + 2;
  c['st'] = 'sorti';
  c['day'] = n['day'];
  c['L'] = L;
  c['launchL'] = L;
  c['rev'] = rev;
  c['streamRev'] = rev - sr;
  c['cut'] = gross - _n(c['streamRev']) - _n(c['duoCut']) + _n(c['salesCut']);
  c['fg'] = fg;
  c['pg'] = pg;
  c['tier'] = tierOf21(L);
  c['promo'] = promo;
  c['label'] = c['labelAt'];
  c['signed'] = signed ? 1 : 0;
  c['year'] = 1 + ((_n(n['day']) - 1) / Reg21.daysPerYear).floor();
  c['views'] = _m(c['clip'])['st'] == 'publie' ? jsRound(L * .35) : 0;
  final split = platformSplit21(L);
  c['platforms'] = {'ondea': split.ondea, 'cauri': split.cauri};
  _l(n['disco']).insert(0, c);
  n['last'] = c['id'];
  _addXp(n, 40);
  _log(n, 'Sortie : ${c['title']} · ${fmt21(L)} écoutes · ${c['tier']}', 'musique');
}

/// Sorties programmées arrivées à échéance (date de sortie <= jour courant) : elles sortent dans l'ordre des dates.
List<String> _releaseDue(J n) {
  final stock = _l(n['stock']);
  final due = stock.map(_m).where((c) => c['relDay'] != null && _n(c['relDay']) <= _n(n['day'])).toList()
    ..sort((a, b) => _n(a['relDay']).compareTo(_n(b['relDay'])));
  final out = <String>[];
  for (final c in due) {
    stock.removeWhere((x) => identical(x, c));
    final promo = _n(c['promoSel']).toInt();
    c.remove('relDay');
    c.remove('promoSel');
    _doRelease(n, c, promo);
    out.add('Sortie programmée : ${c['title']}');
  }
  return out;
}

/// Termine un EP ou un album. Les titres sortis sont relus depuis la discographie à la date réelle de sortie ;
/// les inédits restent des pistes du projet et ne deviennent jamais des singles.
void _releaseProject(J n, J draft) {
  final ids = _l(draft['tracks']).cast<String>();
  final snapshots = _l(draft['trackData']).map(_m).toList();
  final disco = _l(n['disco']).map(_m).toList();
  final tr = <J>[];
  for (final id in ids) {
    J? live;
    for (final x in disco) { if (x['id'] == id) live = x; }
    if (live != null) {
      tr.add(live);
    } else {
      for (final x in snapshots) { if (x['id'] == id) tr.add(x); }
    }
  }
  if (tr.isEmpty || tr.length != ids.length) return;
  final type = draft['type'] as String;
  final p = Reg21.proj[type]!;
  final promo = _n(draft['promo']).toInt().clamp(0, promos21.length - 1).toInt();
  final multiplier = promos21[promo]['m'] as num;
  num listens(J x) => x['st'] == 'sorti' ? _n(x['L']) : jsRound(listensFor21(_n(x['Q']), _n(n['fans']), 0));
  final inedits = tr.where((x) => x['st'] != 'sorti').toList();
  final q = jsRound(tr.fold<num>(0, (sum, x) => sum + _n(x['Q'])) / tr.length);
  final baseStreams = jsRound(tr.fold<num>(0, (sum, x) => sum + listens(x)) * 0.3 + _n(n['fans']) * 2);
  // Effet marketing provisoire : le multiplicateur de portée single s'applique aux écoutes du projet.
  final streams = jsRound(baseStreams * multiplier);
  final fans = _n(n['fans']);
  final sales = jsRound(fans * 0.06 * q / 60 * (type == 'Album' ? 1.3 : 1) + streams * 0.004);
  final gross = sales * Reg21.salePrice;
  final revenue = _t(n['signed']) ? jsRound(gross * (1 - (_t(n['lcut']) ? _n(n['lcut']) : Reg21.labelCut))) : gross;
  final newFans = jsRound(sales * 2);
  final top = p['top'] as num, entry = p['entry'] as num, k = p['k'] as num;
  final rank = sales >= entry ? math.max(1, math.min(top, jsRound(top * math.pow(sales / entry, -k)))) : 0;
  _pay(n, revenue);

  // Les inédits deviennent des pistes du catalogue à la sortie du projet,
  // sans déclencher une seconde sortie single. Ils ont leurs propres écoutes,
  // ventes à l'unité et revenus quotidiens comme les autres titres du catalogue.
  final allListenWeight = tr.fold<num>(0, (sum, x) => sum + listens(x));
  final cutRate = _t(n['lcut']) ? _n(n['lcut']) : Reg21.labelCut;
  for (final track in inedits) {
    final weight = allListenWeight > 0 ? listens(track) / allListenWeight : 1 / inedits.length;
    final trackStreams = jsRound(streams * weight);
    final trackSales = jsRound(trackStreams * Reg21.singleSales);
    final streamGross = jsRound(trackStreams * Reg21.listenValue);
    final salesGross = trackSales * Reg21.salePrice;
    final trackStreamNet = _t(n['signed']) ? jsRound(streamGross * (1 - cutRate)) : streamGross;
    final trackSalesNet = _t(n['signed']) ? jsRound(salesGross * (1 - cutRate)) : salesGross;
    final trackCut = streamGross - trackStreamNet + salesGross - trackSalesNet;
    final split = _platformStreams21(trackStreams);
    final title = <String, dynamic>{
      ...track,
      'st': 'sorti',
      'day': n['day'],
      'L': trackStreams,
      'launchL': trackStreams,
      'rev': trackStreamNet + trackSalesNet,
      'streamRev': trackStreamNet,
      'sales': trackSales,
      'salesRev': trackSalesNet,
      'salesCut': salesGross - trackSalesNet,
      'cut': trackCut,
      'labelAt': _t(n['signed']) ? lblName21(n) : 'Indépendant',
      'auteur': _m(n['p'])['name'],
      'tier': tierOf21(trackStreams),
      'signed': _t(n['signed']),
      'platforms': split,
      'fg': 0,
      'pg': 0,
    };
    _l(n['disco']).insert(0, title);
    _pay(n, trackStreamNet + trackSalesNet);
  }
  n['fans'] = fans + newFans;
  n['pop'] = clamp21(_n(n['pop']) + math.min(6, (sales / 400).floor()), 0, 100);
  _addXp(n, type == 'Album' ? 150 : 80);
  final projects = _l(n['projects']);
  projects.insert(0, {
    'id': draft['id'] ?? 'P${projects.length + 1}',
    'type': type, 'title': draft['title'], 'tracks': List<dynamic>.of(ids), 'day': n['day'],
    'Q': q, 'L': streams, 'sales': sales, 'rev': revenue, 'cut': gross - revenue,
    'fans': newFans, 'rank': rank,
    if (promo != 0) 'promo': promo,
    if (promo != 0) 'promoName': promos21[promo]['n'],
    if (promo != 0) 'promoCost': _n(draft['promoCost']),
    'labelAt': _t(n['signed']) ? lblName21(n) : 'Indépendant',
    if (inedits.isNotEmpty) 'inedits': [for (final x in inedits) {'id': x['id'], 'title': x['title'], 'Q': x['Q']}],
  });
  _l(n['stock']).removeWhere((x) => ids.contains(_m(x)['id']));
  _log(n, '$type sorti : ${draft['title']} · ${tr.length} titres · ${fmt21(sales)} ventes · campagne ${promos21[promo]['n']} · ${rank != 0 ? '#$rank au Top $top' : 'non classé'}', 'musique');
}

int _projectPromoCost(J s, int promo) =>
    (s['lperk'] == 'radio' && promo == 2) ? 0 : (promos21[promo]['c'] as num).toInt();

Res _post(J s, String id) {
  final t = postTypes21[id];
  if (t == null) return _no(s, 'inconnu');
  final need = postNeed21(s, t);
  if (need != null) return _no(s, need);
  if (postsLeft21(s) <= 0) return _no(s, 'postjour');
  final n = clone21(s);
  final e = _spend(n, t.h, t.e);
  if (e != null) return _no(s, e);
  final so = _m(n['soc']);
  final f0 = followers21(n, t.net);
  // [VALIDÉ 20/10] chiffres aléatoires : portée, j'aime, commentaires et abonnés varient à chaque publication.
  final salt = 77 + _n(so['tot']) * 13 + id.length + _n(n['nonce']);
  final r = rng21(n, salt), r2 = rng21(n, salt + 1), r3 = rng21(n, salt + 2), r4 = rng21(n, salt + 3);
  var reach = jsRound(reachEstimate21(n, t) * (0.6 + 0.8 * r));
  final viral = t.viral && r > 0.88, polem = t.clash && r < 0.35;
  if (viral) reach = jsRound(reach * (3 + 2 * r2));
  final likes = jsRound(reach * (0.07 + 0.1 * r2)), cm = jsRound(reach * (0.005 + 0.012 * r3)) + 1, nf = jsRound(reach * (0.03 + 0.025 * r4)), fg = jsRound(reach * t.fanRate * (0.8 + 0.4 * r3));
  _m(so['f'])[t.net] = f0 + nf;
  n['fans'] = _n(n['fans']) + fg;
  n['pop'] = clamp21(_n(n['pop']) + t.pop + (viral ? 2 : 0), 0, 100);
  _geoAdd(n, 'bakoma', viral ? 1.5 : 0.3);
  if (t.hype > 0) n['hype'] = _n(n['day']) + t.hype;
  if (polem) n['rep'] = math.max(0, _n(n['rep']) - 2);
  if (t.clash && !polem) n['rep'] = _n(n['rep']) + 1;
  so['buzz'] = clamp21(_n(so['buzz']) + (viral ? 35 : polem ? 25 : 8), 0, 100);
  if (_n(so['day']) != _n(n['day'])) {
    so['day'] = n['day'];
    so['today'] = 0;
  }
  so['today'] = _n(so['today']) + 1;
  final tot = _n(so['tot']).toInt() + 1;
  so['tot'] = tot;
  if (viral) so['viral'] = _n(so['viral']) + 1;
  if (polem) so['polem'] = _n(so['polem']) + 1;
  final ci = (r * 1000).floor();
  final posts = _l(so['posts']);
  posts.insert(0, {
    'id': 'P$tot', 'net': t.net, 'type': id, 'day': n['day'], 'txt': postText21(n, t), 'reach': reach, 'likes': likes, 'cm': cm, 'nf': nf, 'fg': fg,
    'viral': viral ? 1 : 0, 'polem': polem ? 1 : 0,
    'c': [ci % socialComments21.length, (ci ~/ 7 + 3) % socialComments21.length], 'u': [ci % socialHandles21.length, (ci ~/ 3 + 5) % socialHandles21.length],
  });
  if (posts.length > 30) posts.removeRange(30, posts.length);
  _addXp(n, viral ? 25 : 8);
  _log(n, 'Publication ${socialNets21[t.net]!.n} : ${t.n} · ${fmt21(reach)} vues · +${fmt21(fg)} fans${viral ? ' · virale !' : ''}${polem ? ' · polémique (réputation −2)' : ''}', 'carriere');
  return _ok(n);
}

Res _mkBuy(J s, String id, bool ok) {
  final e = mkCheck21(s, id);
  if (e != null) return _no(s, e);
  final m = media21[id]!;
  if (m.c >= mediaConfirmAt21 && !ok) return _no(s, 'confirm');
  final n = clone21(s);
  final mk = _m(n['mk']);
  _pay(n, -m.c);
  _l(mk['on']).add({'id': id, 'from': n['day'], 'until': _n(n['day']) + m.d});
  mk['ask'] = null;
  mk['tot'] = _n(mk['tot']) + m.c;
  mk['n'] = _n(mk['n']) + 1;
  _log(n, 'Campagne ${mediaLevelName21[m.lvl]} : ${m.n} (${m.d} j, −${fmt21(m.c)} cauris)', 'eco');
  return _ok(n);
}

final Map<String, Action> actions21 = {
  // ---- Espace Réseau (21-N0 à 21-N8) [VALIDÉ 20/10, valeurs provisoires] ----
  'kv': (s, a) {
    final i = a is num ? a.toInt() : int.tryParse('$a') ?? -1;
    if (i < 0 || i >= klipo21.length) return _no(s, 'inconnu');
    final n = clone21(s);
    n['kv'] = i;
    return _ok(n);
  },
  'mcl': (s, a) {
    final i = a is num ? a.toInt() : int.tryParse('$a') ?? -1;
    if (i < 0 || i >= myClips21(s).length) return _no(s, 'inconnu');
    final n = clone21(s);
    n['mcl'] = i;
    return _ok(n);
  },
  'mkask': (s, id) {
    final e = mkCheck21(s, '$id');
    if (e != null) return _no(s, e);
    final n = clone21(s);
    _m(n['mk'])['ask'] = '$id';
    return _ok(n);
  },
  'mkcancel': (s, a) {
    final n = clone21(s);
    _m(n['mk'])['ask'] = null;
    return _ok(n);
  },
  'mkbuy': (s, id) => _mkBuy(s, '$id', false),
  'post': (s, id) => _post(s, '$id'),
  'mkconfirm': (s, a) {
    final ask = _m(s['mk'])['ask'];
    if (ask == null) return _no(s, 'rien');
    return _mkBuy(s, '$ask', true);
  },
  'reset': (s, a) => _ok(init21()),

  'create': (s, arg) {
    if (s['cur'] != null && _m(s['cur'])['st'] != 'sorti') {
      return _no(s, 'encours');
    }
    final n = clone21(s);
    String th, am, mode = 'manuel';
    final ui = _m(n['ui']);
    if (arg == 'random' ||
        (arg is List && arg.isNotEmpty && arg[0] == 'random')) {
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
    if (!Reg21.themes.containsKey(th) || !Reg21.ambs.containsKey(am)) {
      return _no(s, 'inconnu');
    }
    final e = _spend(n, 1, 20);
    if (e != null) return _no(s, e);
    var title = cleanName21(ui['title']);
    if (title.length > 30) title = title.substring(0, 30);
    if (title.isEmpty) {
      title = _randomTitle21(n, th);
    } else {
      mode = mode == 'aléatoire' ? mode : 'manuel';
    }
    if (_t(ui['rt'])) title = _randomTitle21(n, th);
    ui['title'] = '';
    ui['rt'] = 0;
    n['cur'] = {
      'id': 'T${_nextSongSeq(n)}',
      'title': title,
      'theme': th,
      'amb': am,
      'mode': mode,
      'tx': 72 +
          (Reg21.themes[th]!['tx'] as int) +
          (Reg21.ambs[am]!['tx'] as int),
      'st': 'ecrit',
      'Q': 0,
      'feats': <dynamic>[],
      'clip': {'st': 'aucun'},
    };
    if (n['duo'] != null) {
      final cur = _m(n['cur']);
      _l(cur['feats']).add('ayana');
      cur['duo'] = _m(n['duo'])['share'];
      n['duo'] = null;
    }
    final sk = _m(n['sk']);
    sk['ecr'] = _n(sk['ecr']) + 1;
    _log(n, 'Texte écrit : $title ($mode)', 'musique');
    return _ok(n);
  },

  // Instru choisie (04.3), payée au choix ; utilisée à la prochaine prise de cabine.
  'pick': (s, id) {
    final i = Reg21.instrus[id];
    if (i == null) return _no(s, 'inconnu');
    final cur = s['cur'];
    if (cur != null && _m(cur)['st'] == 'enregistre') return _no(s, 'encours');
    if (_m(s['ui'])['inst'] == id) return _ok(s);
    if (_n(s['rank']) < (i['rank'] as num)) return _no(s, 'rang');
    if (i['rep'] != null && _n(s['rep']) < (i['rep'] as num)) return _no(s, 'rep');
    if (_n(s['cash']) < (i['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    if (_n(i['cost']) != 0) _pay(n, -(i['cost'] as num));
    _m(n['ui'])['inst'] = id;
    _log(n, 'Instru choisie : ${i['n']}${_n(i['cost']) != 0 ? ' (−${fmt21(i['cost'] as num)})' : ' (gratuite)'}', 'musique');
    return _ok(n);
  },

  // Cabine à 3 prises : qualité = 0,35 texte + 0,30 voix + 0,35 production − fatigue + featurings.
  'record': (s, takes) {
    final cur0 = s['cur'];
    if (cur0 == null || _m(cur0)['st'] != 'ecrit') return _no(s, 'pasdetexte');
    final hs = _m(s['own'])['homestudio'] != null;
    final n = clone21(s);
    final e = _spend(n, 2, hs ? 15 : 25);
    if (e != null) return _no(s, e);
    final kc = _m(n['kc']);
    final kb = _n(kc['left']) > 0 ? _n(kc['bonus']) : 0;
    if (kb != 0) kc['left'] = _n(kc['left']) - 1;
    final cur = _m(n['cur']);
    // `takes` : liste de prises 0-100 ; à défaut, les prises par défaut (cabine sans mini-jeu).
    final src = takes is List && takes.isNotEmpty ? takes : Reg21.takesDefault;
    final tk = src.take(3).map((x) => clamp21(jsRound(x is num ? x : (num.tryParse('$x') ?? 0)), 0, 100)).toList();
    final ui = _m(n['ui']);
    final iid = (ui['inst'] ?? 'nuit') as String;
    final inst = Reg21.instrus[iid]!;
    final voix = jsRound(tk.fold<num>(0, (a, b) => a + b) / tk.length) + (hs ? 2 : 0);
    final prod = _n(inst['Q']) + (hs ? 4 : 0) + kb;
    final mal = math.min(20, math.max(0, 40 - _n(s['en'])) / 2);
    cur['takes'] = tk;
    cur['inst'] = iid;
    ui['inst'] = null;
    cur['prodBy'] = kb != 0
        ? 'DJ Kôrô (Studio Kôrô)'
        : inst['who'] == 'Gratuite'
            ? 'Instru libre « ${inst['n']} »'
            : '${inst['who']} (« ${inst['n']} »)';
    var fq = 0;
    for (final f in _l(cur['feats'])) {
      fq += Reg21.feats[f]!['q'] as int;
    }
    cur['voix'] = voix;
    cur['prod'] = prod;
    cur['Q'] = clamp21(
        jsRound(0.35 * _n(cur['tx']) + 0.30 * voix + 0.35 * prod - mal) + fq, 0, 100);
    cur['st'] = 'enregistre';
    final sk = _m(n['sk']);
    sk['voix'] = _n(sk['voix']) + 1;
    _addXp(n, 30);
    _log(n, 'Enregistré : ${cur['title']} · qualité ${cur['Q']}${kb != 0 ? ' (production Kôrô +$kb)' : ''}', 'musique');
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
    if (f['needPop'] != null && _n(s['pop']) < (f['needPop'] as num)) {
      return _no(s, 'pop');
    }
    if (_n(s['cash']) < (f['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -(f['cost'] as num));
    final c = _m(n['cur']);
    _l(c['feats']).add(id);
    if (c['st'] == 'enregistre') {
      c['Q'] = clamp21(_n(c['Q']) + (f['q'] as num), 0, 100);
    }
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
    if (c['st'] == 'enregistre') {
      c['Q'] = clamp21(_n(c['Q']) - (f['q'] as num), 0, 100);
    }
    if (_n(f['cost']) != 0) _pay(n, f['cost'] as num);
    return _ok(n);
  },

  'promo': (s, k) {
    final n = clone21(s);
    _m(n['ui'])['promo'] = k is num ? k : int.tryParse('$k') ?? 0;
    return _ok(n);
  },

  // Sortie d'un single : écoutes, ventes (1,2 % des streams × 30 cauris), part du label déduite, popularité plafonnée à 12 et ralentie près de 100.
  'release': (s, a) {
    final cur0 = s['cur'];
    if (cur0 == null || _m(cur0)['st'] != 'enregistre') return _no(s, 'pasenregistre');
    final promo = _n(_m(s['ui'])['promo']).toInt();
    final p = promos21[promo];
    final pc = (s['lperk'] == 'radio' && promo == 2) ? 0 : p['c'] as num;
    if (_n(s['cash']) < pc) return _no(s, 'cash');
    final n = clone21(s);
    final c = _m(n['cur']);
    if (pc != 0) _pay(n, -pc);
    _doRelease(n, c, promo);
    n['cur'] = null;
    return _ok(n);
  },

  // ---------- réserve et sorties programmées (titres enregistrés, non sortis) ----------
  // Le titre en cours, une fois enregistré, peut partir en réserve (sans date) ou être programmé (J+1 à J+Reg21.relMaxDays).
  // Un titre en réserve peut entrer dans un EP ou un album, sortir tout de suite, ou être programmé. La date est celle du jeu.
  'shelve': (s, a) {
    final cur = s['cur'];
    if (cur == null || _m(cur)['st'] != 'enregistre') return _no(s, 'pasenregistre');
    if (_l(s['stock']).length >= Reg21.stockMax) return _no(s, 'reserve');
    final n = clone21(s);
    final c = _m(n['cur']);
    _l(n['stock']).add(c);
    n['cur'] = null;
    _log(n, 'En réserve : ${c['title']}', 'musique');
    return _ok(n);
  },

  'schedule': (s, arg) {
    final fromList = arg is List && arg.length == 2;
    final id = fromList ? arg[0] : null;
    final days = int.tryParse('${fromList ? arg[1] : arg}') ?? 0;
    if (days < 1 || days > Reg21.relMaxDays) return _no(s, 'inconnu');
    final cur = s['cur'];
    J? song;
    if (id == null) {
      if (cur == null || _m(cur)['st'] != 'enregistre') return _no(s, 'pasenregistre');
      if (_l(s['stock']).length >= Reg21.stockMax) return _no(s, 'reserve');
      song = _m(cur);
    } else {
      for (final x in _l(s['stock'])) {
        if (_m(x)['id'] == id) song = _m(x);
      }
      if (song == null) return _no(s, 'inconnu');
    }
    final paid = _t(song['promoPaid']);
    final promo = paid ? _n(song['promoSel']).toInt() : _n(_m(s['ui'])['promo']).toInt();
    final pc = paid ? 0 : _promoCost(s, promo);
    if (_n(s['cash']) < pc) return _no(s, 'cash');
    final n = clone21(s);
    final c = id == null ? _m(n['cur']) : _l(n['stock']).map(_m).firstWhere((x) => x['id'] == id);
    if (pc != 0) _pay(n, -pc);
    c['promoSel'] = promo;
    c['promoPaid'] = 1;
    c['relDay'] = _n(n['day']) + days;
    if (id == null) {
      _l(n['stock']).add(c);
      n['cur'] = null;
    }
    _log(n, 'Sortie programmée : ${c['title']} · ${dateLabel21(_n(c['relDay']))}${pc != 0 ? ' (promotion −${fmt21(pc)})' : ''}', 'musique');
    return _ok(n);
  },

  'unschedule': (s, id) {
    if (!_l(s['stock']).any((x) => _m(x)['id'] == id && _m(x)['relDay'] != null)) return _no(s, 'inconnu');
    final n = clone21(s);
    final c = _l(n['stock']).map(_m).firstWhere((x) => x['id'] == id);
    c['relDay'] = null;
    _log(n, 'Sortie annulée, titre remis en réserve : ${c['title']}', 'musique');
    return _ok(n);
  },

  /// Sortie immédiate d'un titre en réserve (promotion choisie dans la sortie, déjà payée si le titre a été programmé).
  'rnow': (s, id) {
    J? song;
    for (final x in _l(s['stock'])) {
      if (_m(x)['id'] == id) song = _m(x);
    }
    if (song == null) return _no(s, 'inconnu');
    final paid = _t(song['promoPaid']);
    final promo = paid ? _n(song['promoSel']).toInt() : _n(_m(s['ui'])['promo']).toInt();
    final pc = paid ? 0 : _promoCost(s, promo);
    if (_n(s['cash']) < pc) return _no(s, 'cash');
    final n = clone21(s);
    final c = _l(n['stock']).map(_m).firstWhere((x) => x['id'] == id);
    if (pc != 0) _pay(n, -pc);
    _l(n['stock']).removeWhere((x) => identical(x, c));
    c.remove('relDay');
    c.remove('promoSel');
    _doRelease(n, c, promo);
    return _ok(n);
  },

  // ---------- catalogue : fiche d'un titre, EP et album (13.3, 13.4, 05-5) ----------
  'ctk': (s, id) => _setUi(s, 'ctk', id),
  'ctki': (s, i) {
    final d = _l(s['disco']), k = int.tryParse('$i') ?? -1;
    if (k < 0 || k >= d.length) return _no(s, 'inconnu');
    return _setUi(s, 'ctk', _m(d[k])['id']);
  },
  'ptype': (s, t) => Reg21.proj.containsKey(t) ? _setUi(s, 'ptype', t) : _no(s, 'inconnu'),
  'ppromo': (s, k) => _setUi(s, 'ppromo', clamp21(int.tryParse('$k') ?? 0, 0, promos21.length - 1).toInt()),
  'ptk': (s, id) {
    if (![..._l(s['disco']), ..._l(s['stock'])].any((x) => _m(x)['id'] == id)) return _no(s, 'inconnu');
    final n = clone21(s), ui = _m(n['ui']);
    final cur = ((ui['ptk'] as List?) ?? <dynamic>[]).toList();
    ui['ptk'] = cur.contains(id) ? cur.where((x) => x != id).toList() : [...cur, id];
    return _ok(n);
  },
  'ptki': (s, i) {
    final d = _l(s['disco']), k = int.tryParse('$i') ?? -1;
    if (k < 0 || k >= d.length) return _no(s, 'inconnu');
    return actions21['ptk']!(s, _m(d[k])['id']);
  },
  'prel': (s, a) {
    final ui0 = _m(s['ui']);
    final type = (ui0['ptype'] ?? 'EP') as String, p = Reg21.proj[type]!;
    final ids = ((ui0['ptk'] as List?) ?? const []).cast<String>();
    if (ids.length < (p['min'] as num) || ids.length > (p['max'] as num)) return _no(s, 'pistes');
    final available = [..._l(s['disco']), ..._l(s['stock'])].map(_m).toList();
    final tracks = ids.map((id) => available.where((x) => x['id'] == id).firstOrNull).toList();
    if (tracks.any((x) => x == null)) return _no(s, 'inconnu');
    final promo = _n(_m(s['ui'])['ppromo']).toInt().clamp(0, promos21.length - 1).toInt();
    final promoCost = _projectPromoCost(s, promo);
    final total = (p['cost'] as num) + promoCost;
    if (_n(s['cash']) < total) return _no(s, 'cash');
    final n = clone21(s);
    final err = _spend(n, p['h'] as num, p['e'] as num);
    if (err != null) return _no(s, err);
    _pay(n, -total);
    final ui = _m(n['ui']);
    var title = cleanName21(ui['ptitle']);
    if (title.length > 30) title = title.substring(0, 30);
    if (title.isEmpty) {
      title = '${type == 'EP' ? 'EP n° ' : 'Album n° '}${_l(n['projects']).where((x) => _m(x)['type'] == type).length + _l(n['pendingProjects'] ?? const []).where((x) => _m(x)['type'] == type).length + 1}';
    }
    final draft = <String, dynamic>{
      'id': 'P${_l(n['projects']).length + _l(n['pendingProjects'] ?? const []).length + 1}',
      'type': type, 'title': title, 'tracks': List<dynamic>.of(ids),
      'trackData': [for (final x in tracks) Map<String, dynamic>.from(x!)],
      'promo': promo, 'promoCost': promoCost,
    };
    _releaseProject(n, draft);
    ui['ptk'] = <dynamic>[];
    ui['ptitle'] = '';
    _log(n, '$type publié immédiatement : $title · campagne ${promos21[promo]['n']} · coût ${fmt21(total)} cauris', 'musique');
    return _ok(n);
  },

  'pschedule': (s, arg) {
    final days = int.tryParse('$arg') ?? 0;
    if (days < 1 || days > Reg21.relMaxDays) return _no(s, 'inconnu');
    final ui0 = _m(s['ui']);
    final type = (ui0['ptype'] ?? 'EP') as String, p = Reg21.proj[type]!;
    final ids = ((ui0['ptk'] as List?) ?? const []).cast<String>();
    if (ids.length < (p['min'] as num) || ids.length > (p['max'] as num)) return _no(s, 'pistes');
    final available = [..._l(s['disco']), ..._l(s['stock'])].map(_m).toList();
    final tracks = ids.map((id) => available.where((x) => x['id'] == id).firstOrNull).toList();
    if (tracks.any((x) => x == null)) return _no(s, 'inconnu');
    final promo = _n(_m(s['ui'])['ppromo']).toInt().clamp(0, promos21.length - 1).toInt();
    final promoCost = _projectPromoCost(s, promo);
    final total = (p['cost'] as num) + promoCost;
    if (_n(s['cash']) < total) return _no(s, 'cash');
    final n = clone21(s);
    final err = _spend(n, p['h'] as num, p['e'] as num);
    if (err != null) return _no(s, err);
    _pay(n, -total);
    final ui = _m(n['ui']);
    var title = cleanName21(ui['ptitle']);
    if (title.length > 30) title = title.substring(0, 30);
    if (title.isEmpty) {
      title = (type == 'EP' ? 'EP n° ' : 'Album n° ') + (_l(n['projects']).where((x) => _m(x)['type'] == type).length + _l(n['pendingProjects'] ?? const []).where((x) => _m(x)['type'] == type).length + 1).toString();
    }
    final pending = <String, dynamic>{
      'id': 'P${_l(n['projects']).length + _l(n['pendingProjects'] ?? const []).length + 1}',
      'type': type, 'title': title, 'tracks': List<dynamic>.of(ids),
      'trackData': [for (final x in tracks) Map<String, dynamic>.from(x!)],
      'promo': promo, 'promoCost': promoCost, 'relDay': _n(n['day']) + days,
    };
    n['pendingProjects'] ??= <dynamic>[];
    _l(n['pendingProjects']).add(pending);
    _l(n['stock']).removeWhere((x) => ids.contains(_m(x)['id']));
    ui['ptk'] = <dynamic>[];
    ui['ptitle'] = '';
    _log(n, '$type programmé : $title · ${dateLabel21(_n(pending['relDay']))} · campagne ${promos21[promo]['n']} · coût ${fmt21(total)} cauris', 'musique');
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
    if (t == null || _m(t['clip'])['st'] != 'prepare') {
      return _no(s, 'pasprepare');
    }
    final n = clone21(s);
    final e = _spend(
        n, Reg21.shootH, Reg21.shootE - (_m(s['own'])['moto'] != null ? 5 : 0));
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
    final extra =
        jsRound(_n(c['L']) * Reg21.clipBoost * (_n(c['vir']) / 100) * 4);
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
    _log(
        n, 'Clip publié : ${c['title']} · +${fmt21(extra)} écoutes', 'musique');
    return _ok(n);
  },

  // ---------- scène ----------
  // ---------- scène ----------
  // Open mic : une fois par jour ; les gains diminuent de 15 % par passage sur 7 jours glissants (plancher 30 %).
  'openmic': (s, a) {
    if (s['omDay'] == s['day']) return _no(s, 'deja');
    final n = clone21(s);
    final e = _spend(n, 1, 15 - (_m(s['own'])['moto'] != null ? 5 : 0));
    if (e != null) return _no(s, e);
    final hist = (((n['omHist'] as List?) ?? const []).cast<num>()).where((d) => _n(n['day']) - d < Reg21.omWindow).toList();
    final k = math.max(Reg21.omFloor, 1 - Reg21.omStep * hist.length);
    hist.add(_n(n['day']));
    n['omHist'] = hist;
    n['omDay'] = n['day'];
    n['omK'] = k;
    final win = _n(s['en']) >= 40;
    n['shows'] = _n(n['shows']) + 1;
    n['omCash'] = 0;
    n['omCut'] = 0;
    if (win) {
      n['fans'] = _n(n['fans']) + jsRound(Reg21.omFans * k);
      n['rep'] = _n(n['rep']) + (k >= 0.7 ? 6 : 3);
      final managerCut = _cachet(n, Reg21.omCash, 'open mic');
      n['omCash'] = Reg21.omCash - managerCut;
      n['omCut'] = managerCut;
      _geoAdd(n, 'bakoma', 2 * k);
      _addXp(n, jsRound(60 * k));
    } else {
      n['fans'] = _n(n['fans']) + 12;
      _addXp(n, 10);
    }
    _log(n, "Open mic de Ndolo : ${win ? 'le public a suivi (+150 fans)' : 'trou de mémoire'}", 'scene');
    n['om'] = win ? 1 : 0;
    return _ok(n);
  },

  // Battle de K-Zer : 3 rounds, victoire à 2 (`wins` = rounds gagnés).
  'battle': (s, wins) {
    if (s['btq'] == null) return _no(s, 'rien');
    final n = clone21(s);
    final e = _spend(n, 1, 15);
    if (e != null) return _no(s, e);
    final w = clamp21(jsRound(wins is num ? wins : (num.tryParse('$wins') ?? 0)), 0, 3).toInt();
    final win = w >= Reg21.battleWin;
    num cash = 0, managerCut = 0, fans;
    if (win) {
      fans = 150 + (n['lperk'] == 'street' ? 50 : 0);
      n['fans'] = _n(n['fans']) + fans;
      n['rep'] = _n(n['rep']) + 6;
      managerCut = _cachet(n, Reg21.battleFee, 'battle');
      cash = Reg21.battleFee - managerCut;
      _geoAdd(n, 'bakoma', 2);
      _addXp(n, 60);
    } else {
      fans = 12;
      n['fans'] = _n(n['fans']) + 12;
      _addXp(n, 10);
    }
    n['bt'] = {'win': win ? 1 : 0, 'w': w, 'vs': s['btq']};
    // détail du résultat pour l'écran 21-B2 (extension : le prototype ne le calcule pas)
    n['btl'] = {
      'win': win ? 1 : 0, 'score': w, 'fans': fans, 'gross': win ? Reg21.battleFee : 0, 'cash': cash,
      'managerCut': managerCut, 'rep': win ? 6 : 0, 'xp': win ? 60 : 10,
    };
    n['btq'] = null;
    _log(n, "Battle contre K-Zer d'Mabaya : ${win ? 'victoire ' : 'défaite '}$w / 3${win ? ' (+150 fans, +6 réputation, +3 000)' : ' (+12 fans)'}", 'scene');
    return _ok(n);
  },

  // ---------- dialogues (section 16 et 19) ----------
  'dch': (s, ch) {
    final d = s['dlg'];
    if (d == null || _t(_m(d)['done'])) return _no(s, 'rien');
    final D = dlg21[_m(d)['id']]!, N = D.nodes[_m(d)['node']]!;
    final C = N.ch.where((x) => x.id == ch).toList();
    if (C.isEmpty) return _no(s, 'inconnu');
    final c = C.first;
    final n = clone21(s);
    final er = _applyEff(n, c.e);
    if (er != null) return _no(s, er);
    final dn = _m(n['dlg']);
    _l(dn['path']).add(c.n);
    if (c.go != null) {
      dn['node'] = c.go;
      return _ok(n);
    }
    dn['done'] = 1;
    dn['end'] = c.end;
    dn['c'] = c.c;
    _m(n['dseen'])[dn['id'] as String] = c.end;
    _log(n, '${D.t} : ${c.end} (${c.c})', 'evenement');
    return _ok(n);
  },
  'dclose': (s, a) {
    final d = s['dlg'];
    if (d == null) return _ok(s);
    if (!_t(_m(d)['done'])) return _no(s, 'encours');
    final n = clone21(s);
    n['dlg'] = null;
    _triggers(n);
    return _ok(n);
  },
  // Raccourci de démonstration : lance une scène pour la revoir (non porté dans l'interface : voir BRIEF §2).
  'dstart': (s, id) {
    if (!dlg21.containsKey(id)) return _no(s, 'inconnu');
    final n = clone21(s);
    final cur = n['dlg'];
    if (cur != null && !_t(_m(cur)['done']) && _m(cur)['id'] != id && !_t(_m(cur)['demo'])) {
      _l(n['dq']).insert(0, {'id': _m(cur)['id'], 'at': n['day']});
    }
    n['dlg'] = {'id': id, 'node': 'n1', 'path': <dynamic>[], 'demo': 1};
    n['dq'] = _l(n['dq']).where((x) => _m(x)['id'] != id).toList();
    return _ok(n);
  },

  // ---------- manager ----------
  // Rompre le contrat (la signature se fait par le dialogue 19-6 « mgr » ou par hireManager).
  'mgr': (s, a) {
    if (!_t(s['mgr'])) return _no(s, 'rien');
    final n = clone21(s);
    n['mgr'] = null;
    _log(n, 'Contrat de ${managerTier21(s)?['n'] ?? 'ta manager'} terminé', 'business');
    return _ok(n);
  },
  'hireManager': (s, id) {
    if (id is! String || !Reg21.managerTiers.containsKey(id)) return _no(s, 'inconnu');
    final tier = Reg21.managerTiers[id]!;
    if (_n(s['rep']) < (tier['rep'] as num) || _n(s['xp']) < (tier['xp'] as num)) return _no(s, 'rang');
    final n = clone21(s);
    n['mgr'] = id == 'm1' ? 'maya' : id;
    _log(n, 'Contrat signé avec ${tier['n']} · ${((tier['rate'] as num) * 100).toStringAsFixed(0)} % de chaque cachet', 'business');
    return _ok(n);
  },

  // ---------- label (contrat standard 08-2, sans dialogue) ----------
  'sign': (s, a) {
    if (_t(s['signed'])) return _no(s, 'deja');
    if (_n(s['rep']) < Reg21.labelRep) return _no(s, 'rep');
    final n = clone21(s);
    n['signed'] = 1;
    n['label'] = 'BSR';
    n['lcut'] = 0.35;
    n['lperk'] = 'radio';
    _pay(n, 150000);
    _log(n, 'Contrat signé : Bakoma Sound Records (avance 150 000)', 'carriere');
    return _ok(n);
  },

  // ---------- activités illégales, police, tribunal, prison (contenu mature 16+) ----------
  'mature': (s, v) {
    final n = clone21(s);
    n['mature'] = v == 'on' ? 1 : 0;
    _log(n, 'Contenu mature (16+) ${_t(n['mature']) ? 'activé' : 'désactivé'}', 'jeu');
    return _ok(n);
  },
  'crime': (s, id) {
    final C = Reg21.crimes[id];
    if (C == null) return _no(s, 'inconnu');
    if (!_t(s['mature'])) return _no(s, 'mature');
    if (s['cas'] != null) return _no(s, 'affaire');
    final n = clone21(s);
    final e = _spend(n, C['h'] as num, C['e'] as num);
    if (e != null) return _no(s, e);
    n['crimeN'] = _n(n['crimeN']) + 1;
    final risk = math.min(85, (C['risk'] as num) + jsRound(_n(n['heat']) / 2));
    final roll = rng21(n, 97 + _n(n['crimeN']) * 13) * 100;
    n['heat'] = math.min(100, _n(n['heat']) + (C['heat'] as num));
    if (roll < risk) {
      n['cas'] = {
        'crime': id, 'n': C['n'], 'ch': C['ch'], 'sev': C['sev'], 'day': n['day'], 'trial': _n(n['day']) + Reg21.trialIn,
        'stage': 'garde', 'lawyer': 'office', 'bail': (C['sev'] as num) * Reg21.bailPer, 'risk': risk,
      };
      n['hour'] = Reg21.dayEnd;
      _log(n, 'Arrêté pendant : ${C['n']} (risque $risk %) · garde à vue', 'justice');
      n['lastCrime'] = {'n': C['n'], 'ok': 0, 'risk': risk};
    } else {
      final g = jsRound((C['lo'] as num) + ((C['hi'] as num) - (C['lo'] as num)) * rng21(n, 41 + _n(n['crimeN'])));
      _pay(n, g);
      n['rep'] = _n(n['rep']) + ((C['sev'] as num) >= 3 ? 1 : 0);
      n['lastCrime'] = {'n': C['n'], 'ok': 1, 'gain': g, 'risk': risk};
      _log(n, '${C['n']} : +${fmt21(g)} cauris · chaleur ${n['heat']}', 'justice');
    }
    return _ok(n);
  },
  'bail': (s, a) {
    final c = s['cas'];
    if (c == null || _m(c)['stage'] != 'garde') return _no(s, 'rien');
    if (_n(s['cash']) < _n(_m(c)['bail'])) return _no(s, 'cash');
    final n = clone21(s), cs = _m(n['cas']);
    _pay(n, -_n(cs['bail']));
    cs['stage'] = 'libre';
    _log(n, 'Caution payée : ${fmt21(_n(cs['bail']))} · procès le jour ${cs['trial']}', 'justice');
    return _ok(n);
  },
  'detention': (s, a) {
    final c = s['cas'];
    if (c == null || _m(c)['stage'] != 'garde') return _no(s, 'rien');
    final n = clone21(s), cs = _m(n['cas']);
    cs['stage'] = 'detenu';
    n['jail'] = {'until': cs['trial'], 'days': Reg21.trialIn, 'pre': 1};
    _log(n, "Détention provisoire jusqu'au procès (jour ${cs['trial']})", 'justice');
    return _ok(n);
  },
  'lawyer': (s, id) {
    final lw = Reg21.lawyers[id];
    final c = s['cas'];
    if (lw == null || c == null) return _no(s, 'rien');
    if (_m(c)['paid'] == id) return _ok(s);
    if (_n(s['cash']) < (lw['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s), cs = _m(n['cas']);
    _pay(n, -(lw['cost'] as num));
    cs['lawyer'] = id;
    cs['paid'] = id;
    _log(n, 'Avocat : ${lw['n']}${_n(lw['cost']) != 0 ? ' (−${fmt21(lw['cost'] as num)})' : ''}', 'justice');
    return _ok(n);
  },
  'trial': (s, plea) {
    final c = s['cas'];
    if (c == null || _m(c)['stage'] == 'garde') return _no(s, 'rien');
    if (_n(s['day']) < _n(_m(c)['trial'])) return _no(s, 'proces');
    final n = clone21(s), cs = _m(n['cas']);
    final lw = Reg21.lawyers[cs['lawyer']]!, S = Reg21.sentences[_n(cs['sev']).toInt()]!;
    final guilty = plea == 'coupable';
    final pAcq = guilty ? 0 : clamp21((lw['skill'] as num) - _n(cs['sev']) * 8 + 10, 0, 70);
    final roll = rng21(n, 151 + _n(n['crimeN'])) * 100;
    bool acq;
    String txt;
    num fine, jail;
    if (roll < pAcq) {
      acq = true;
      txt = 'Relaxé : les preuves ne suffisent pas';
      fine = 0;
      jail = 0;
    } else {
      acq = false;
      final red = 1 - (lw['skill'] as num) / 100 - (guilty ? 0.25 : 0);
      var jd = math.max(0, jsRound((S['jail'] as num) * red));
      fine = jsRound((S['fine'] as num) * (guilty ? 0.8 : 1));
      if (_t(S['jail']) && jd < 2) {
        jd = 0;
        fine += 15000;
      }
      jail = jd;
      txt = jd != 0
          ? "Coupable : $jd jour(s) de prison${fine != 0 ? " et ${fmt21(fine)} d'amende" : ''}"
          : "Coupable : ${fmt21(fine)} d'amende${_t(S['sursis']) ? ' et prison avec sursis' : ''}";
    }
    if (fine != 0) _pay(n, -fine);
    if (!acq) {
      n['pop'] = clamp21(_n(n['pop']) - 5, 0, 100);
      n['fans'] = jsRound(_n(n['fans']) * 0.92);
      _l(n['casier']).add({'ch': cs['ch'], 'day': n['day'], 'v': txt});
    } else {
      n['pop'] = clamp21(_n(n['pop']) + 1, 0, 100);
    }
    if (jail != 0) {
      n['jail'] = {'until': _n(n['day']) + jail, 'days': jail};
      if (_t(n['signed'])) {
        _log(n, '${lblName21(n)} rompt ton contrat après la condamnation', 'carriere');
        txt += ' · ${lblName21(n)} rompt ton contrat';
        n['signed'] = 0;
        n['label'] = null;
        n['lperk'] = null;
        n['lcut'] = null;
      }
    }
    n['verdict'] = {
      'ch': cs['ch'], 'txt': txt, 'acq': acq ? 1 : 0, 'lawyer': lw['n'], 'plea': guilty ? 'Coupable' : 'Non coupable',
      'jail': jail, 'fine': fine,
    };
    n['cas'] = null;
    n['heat'] = math.max(0, _n(n['heat']) - 20);
    _log(n, 'Verdict (${cs['ch']}) : $txt', 'justice');
    return _ok(n);
  },
  // Enregistrement carcéral : qualité volontairement faible, améliorée par le téléphone satellite.
  'jrecord': (s, a) {
    if (!_t(s['jail'])) return _no(s, 'prison');
    if (_n(s['jrec']) == _n(s['day'])) return _no(s, 'deja');
    if (s['cur'] != null && _m(s['cur'])['st'] != 'sorti') return _no(s, 'encours');
    final n = clone21(s);
    final phone = _t(n['jphone']);
    final quality = phone ? 62 : 24;
    final title = 'Freestyle de cellule J${n['day']}';
    n['cur'] = {
      'id': 'T${_nextSongSeq(n)}', 'title': title, 'theme': 'quartier', 'amb': 'sombre',
      'mode': 'prison', 'tx': quality, 'st': 'enregistre', 'Q': quality,
      'quality': quality, 'jailRecord': 1, 'feats': <dynamic>[], 'clip': {'st': 'aucun'},
    };
    n['jrec'] = n['day'];
    _m(n['sk'])['voix'] = _n(_m(n['sk'])['voix']) + 1;
    _log(n, 'Enregistrement en cellule : $title · qualité $quality/100${phone ? ' (téléphone satellite)' : ' (téléphone basique)'}', 'musique');
    return _ok(n);
  },
  // Le téléphone satellite améliore les prises futures, sans effacer la qualité des titres déjà enregistrés.
  'jphone': (s, a) {
    if (!_t(s['jail'])) return _no(s, 'prison');
    if (_t(s['jphone'])) return _no(s, 'deja');
    const cost = 18000;
    if (_n(s['cash']) < cost) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -cost);
    n['jphone'] = 1;
    _log(n, 'Téléphone satellite acheté en prison (−$cost cauris) : qualité des prochains enregistrements améliorée', 'justice');
    return _ok(n);
  },
  // RIO : défi musical carcéral, enregistré comme un morceau distinct et publiable après la libération.
  'jrio': (s, a) {
    if (!_t(s['jail'])) return _no(s, 'prison');
    if (_n(s['jrio']) == _n(s['day'])) return _no(s, 'deja');
    if (s['cur'] != null && _m(s['cur'])['st'] != 'sorti') return _no(s, 'encours');
    final n = clone21(s);
    final phone = _t(n['jphone']);
    final quality = phone ? 68 : 28;
    final title = 'RIO de cellule';
    n['cur'] = {
      'id': 'T${_nextSongSeq(n)}', 'title': title, 'theme': 'quartier', 'amb': 'sombre',
      'mode': 'rio-prison', 'tx': quality, 'st': 'enregistre', 'Q': quality,
      'quality': quality, 'jailRecord': 1, 'rio': 1, 'feats': <dynamic>[], 'clip': {'st': 'aucun'},
    };
    n['jrio'] = n['day'];
    n['jrep'] = _n(n['jrep']) + 2;
    n['rep'] = _n(n['rep']) + 1;
    _log(n, 'RIO de cellule créé · qualité $quality/100 · réputation carcérale +2', 'justice');
    return _ok(n);
  },
  // Affrontement fictif résolu par le moteur : pas de commandes ni de détails de violence réelle.
  'jfight': (s, a) {
    if (!_t(s['jail'])) return _no(s, 'prison');
    if (_n(s['jfight']) == _n(s['day'])) return _no(s, 'deja');
    final n = clone21(s);
    final won = rng21(s, 710 + _n(s['jrep'])) >= .38;
    n['jfight'] = n['day'];
    if (won) {
      n['jrep'] = _n(n['jrep']) + 3;
      n['rep'] = _n(n['rep']) + 1;
      n['en'] = math.max(0, _n(n['en']) - 12);
      _log(n, 'Affrontement scénarisé remporté : réputation carcérale +3, énergie −12', 'justice');
    } else {
      n['jrep'] = math.max(0, _n(n['jrep']) - 1);
      n['en'] = math.max(0, _n(n['en']) - 22);
      _log(n, 'Affrontement scénarisé perdu : énergie −22, réputation carcérale −1', 'justice');
    }
    return _ok(n);
  },
  'jw': (s, a) {
    if (!_t(s['jail'])) return _no(s, 'rien');
    if (s['jw'] == s['day']) return _no(s, 'deja');
    final n = clone21(s);
    n['jw'] = n['day'];
    _m(n['sk'])['ecr'] = _n(_m(n['sk'])['ecr']) + 2;
    _log(n, 'En cellule : textes écrits (Écriture +2)', 'justice');
    return _ok(n);
  },
  'js': (s, a) {
    if (!_t(s['jail'])) return _no(s, 'rien');
    if (s['jsp'] == s['day']) return _no(s, 'deja');
    final n = clone21(s);
    n['jsp'] = n['day'];
    _m(n['sk'])['cha'] = _n(_m(n['sk'])['cha']) + 1;
    n['en'] = math.min(enMax(n), _n(n['en']) + 10);
    _log(n, 'En cellule : sport (Charisme +1)', 'justice');
    return _ok(n);
  },

  // Garde-robe à tenues préfabriquées (21-W0 à 21-W3). L'achat n'équipe pas ; confirmation dès Wardrobe21.confirmAt.
  'osel': (s, id) {
    if (id is! String || outfit21(id) == null) return _no(s, 'inconnu');
    final n = clone21(s);
    _m(n['wd'])['sel'] = id;
    _m(n['wd'])['ask'] = null;
    return _ok(n);
  },

  'oask': (s, id) {
    if (id is! String) return _no(s, 'inconnu');
    final e = outfitCheck21(s, id);
    if (e != null) return _no(s, e);
    final n = clone21(s);
    _m(n['wd'])['sel'] = id;
    _m(n['wd'])['ask'] = id;
    return _ok(n);
  },

  'obuy': (s, id) {
    if (id is! String) return _no(s, 'inconnu');
    final e = outfitCheck21(s, id);
    if (e != null) return _no(s, e);
    final o = outfit21(id)!;
    if ((o['price'] as num) >= Wardrobe21.confirmAt && _m(s['wd'])['ask'] != id) return _no(s, 'confirm');
    final n = clone21(s);
    final wd = _m(n['wd']);
    _pay(n, -(o['price'] as num));
    _l(wd['owned']).add(id);
    wd['ask'] = null;
    wd['sel'] = id;
    _log(n, 'Tenue achetée : ${o['n']}${(o['price'] as num) != 0 ? ' (−${fmt21(o['price'] as num)})' : ''}', 'eco');
    return _ok(n);
  },

  'oasksel': (s, a) => actions21['oask']!(s, _m(s['wd'])['sel']),
  'obuysel': (s, a) => actions21['obuy']!(s, _m(s['wd'])['sel']),
  'oconfirm': (s, a) {
    final ask = _m(s['wd'])['ask'];
    return ask == null ? _no(s, 'rien') : actions21['obuy']!(s, ask);
  },
  'oeqsel': (s, a) => actions21['oeq']!(s, _m(s['wd'])['sel']),
  'ocancel': (s, a) {
    final n = clone21(s);
    _m(n['wd'])['ask'] = null;
    return _ok(n);
  },

  'oeq': (s, id) {
    if (id is! String || outfit21(id) == null) return _no(s, 'inconnu');
    final wd = _m(s['wd']);
    if (!_l(wd['owned']).contains(id)) return _no(s, 'pasachete');
    if (wd['eq'] == id) return _ok(s);
    final n = clone21(s);
    _m(n['wd'])['eq'] = id;
    _m(n['wd'])['sel'] = id;
    _log(n, 'Tenue équipée : ${outfit21(id)!['n']}', 'jeu');
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
    _log(
        n,
        "Atelier d'écriture : Écriture +${t['gain']} (−${fmt21(t['cost'] as num)} cauris)",
        'carriere');
    return _ok(n);
  },

  // Formation (Reg21.trainings) : coût, temps, énergie, gain de compétence ; une fois par jour chacune.
  'train': (s, id) {
    final t = Reg21.trainings[id];
    if (t == null) return _no(s, 'inconnu');
    final lock = trainLock21(s, '$id');
    if (lock != null) return _no(s, lock);
    if (_n(s['cash']) < (t['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    final e = _spend(n, t['h'] as num, t['e'] as num);
    if (e != null) return _no(s, e);
    _pay(n, -(t['cost'] as num));
    final sk = _m(n['sk']);
    final gains = <String>[];
    _m(t['gain']).forEach((k, v) {
      sk[k] = _n(sk[k]) + (v as num);
      gains.add('${Reg21.skillNames[k] ?? k} +$v');
    });
    final td = n['trDay'] is Map ? _m(n['trDay']) : <String, dynamic>{};
    td['$id'] = n['day'];
    n['trDay'] = td;
    n['trained'] = _n(n['trained']) + 1;
    _addXp(n, 10 + (t['h'] as num).toInt() * 5);
    _log(n, '${t['n']} : ${gains.join(', ')}${_n(t['cost']) > 0 ? ' (−${fmt21(t['cost'] as num)} cauris)' : ''}', 'carriere');
    return _ok(n);
  },

  'artistScene': (s, args) {
    if (args is! List || args.length != 2) return _no(s, 'inconnu');
    final id = args[0], choice = args[1];
    if (id is! String || !Reg21.rivals.containsKey(id) || id == 'kzer') return _no(s, 'inconnu');
    const choices = {
      'discuter': {'h': 1, 'e': 5, 'cash': 0, 'rel': 5, 'tension': -3},
      'provoquer': {'h': 1, 'e': 10, 'cash': 0, 'rel': -5, 'tension': 15},
      'apaiser': {'h': 1, 'e': 8, 'cash': 2000, 'rel': 8, 'tension': -12},
    };
    if (choice is! String || !choices.containsKey(choice)) return _no(s, 'inconnu');
    final spec = choices[choice]!;
    if (_n(s['cash']) < (spec['cash'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    final err = _spend(n, spec['h'] as num, spec['e'] as num);
    if (err != null) return _no(s, err);
    final links = _m(n['rivals']);
    final current = links[id] is Map
        ? Map<String, dynamic>.from(links[id] as Map)
        : <String, dynamic>{};
    current['relation'] = clamp21(_n(current['relation']) + (spec['rel'] as num), -100, 100);
    current['tension'] = clamp21(_n(current['tension']) + (spec['tension'] as num), 0, 100);
    current['day'] = n['day'];
    links[id] = current;
    if ((spec['cash'] as num) > 0) _pay(n, -(spec['cash'] as num));
    final label = switch (choice) {
      'discuter' => 'Discussion avec ${Reg21.rivals[id]}',
      'provoquer' => 'Provocation de ${Reg21.rivals[id]}',
      _ => 'Tentative d’apaisement avec ${Reg21.rivals[id]}',
    };
    n['artistLast'] = {'id': id, 'choice': choice, 'relation': current['relation'], 'tension': current['tension']};
    _log(n, '$label · relation ${sg21(spec['rel'] as num)}, tension ${sg21(spec['tension'] as num)}', 'scene');
    return _ok(n);
  },

  'concert': (s, a) {
    if (_n(s['rank']) < 3) return _no(s, 'rang');
    if (_n(s['day']) - _n(s['lastConcert']) < Reg21.concertEvery) {
      return _no(s, 'delai');
    }
    final n = clone21(s);
    final own = _m(s['own']);
    final e = _spend(n, 4, 35 - (own['moto'] != null ? 5 : 0) -
        (own['voiture'] != null ? 5 : 0));
    if (e != null) return _no(s, e);
    final top = _n(s['en']) >= 60, tk = tickets21(s);
    final ca = jsRound(tk * Reg21.ticketPrice * (top ? 1 : 0.85)),
        fg = jsRound(tk * (top ? 1.6 : 1.1)),
        rp = top ? 10 : 6;
    // [VALIDÉ 20/10] média partenaire : bonus de cachet, nom affiché sur l'écran géant.
    final sp = mkSponsor21(s), sb = sp == null ? 0 : jsRound(ca * media21[sp]!.spon);
    n['shows'] = _n(n['shows']) + 1;
    n['fans'] = _n(n['fans']) + fg;
    n['rep'] = _n(n['rep']) + rp;
    final managerCut = _cachet(n, ca + sb, 'concert');
    _geoAdd(n, 'bakoma', 4);
    n['pop'] = clamp21(_n(n['pop']) + 1, 0, 100);
    _addXp(n, 90);
    n['lastConcert'] = n['day'];
    n['concertDay'] = n['day'];
    n['cc'] = {
      'g': top ? 'A' : 'B',
      'tk': tk,
      'gross': ca + sb,
      'cash': ca + sb - managerCut,
      'managerCut': managerCut,
      'fans': fg,
      'rep': rp,
      'day': n['day'],
      'media': sp,
      'spon': sb,
      'fill': jsRound(100 * tk / Reg21.capacity)
    };
    _log(
        n,
        'Concert au Parvis : $tk billets, note ${top ? 'A' : 'B'} · +${fmt21(fg)} fans · billetterie ${fmt21(ca)}',
        'scene');
    return _ok(n);
  },

  // Invitation à un festival : 'oui' (le joueur joue et touche le cachet) ou 'non' (refus poli, aucune pénalité).
  'fest': (s, a) {
    if (a is! List || a.length != 2) return _no(s, 'inconnu');
    final id = '${a[0]}', yes = a[1] == 'oui';
    final f = Reg21.festivals[id];
    final inv = festivalInvite21(s, id);
    if (f == null) return _no(s, 'inconnu');
    if (inv == null) return _no(s, 'pasinvite');
    final n = clone21(s);
    final fi = _m(n['fi']);
    final key = '${inv['k']}';
    if (!yes) {
      fi[key] = 'refuse';
      _log(n, 'Invitation déclinée : ${f['n']}', 'scene');
      return _ok(n);
    }
    final e = _spend(n, f['h'] as num, f['e'] as num);
    if (e != null) return _no(s, e);
    final fee = f['fee'] as num;
    final cut = _cachet(n, fee, 'festival');
    fi[key] = 'joue';
    n['fans'] = _n(n['fans']) + (f['fans'] as num);
    n['rep'] = _n(n['rep']) + (f['rep'] as num);
    n['shows'] = _n(n['shows']) + 1;
    n['pop'] = clamp21(_n(n['pop']) + 1, 0, 100);
    _geoAdd(n, '${f['place']}', f['geo'] as num);
    _addXp(n, 40 + (f['rep'] as int) * 10);
    n['cc'] = {'g': 'F', 'tk': 0, 'gross': fee, 'cash': fee - cut, 'managerCut': cut, 'fans': f['fans'], 'rep': f['rep'], 'day': n['day'], 'tour': 1, 'lbl': '${f['n']}'};
    _log(n, '${f['n']} : cachet ${fmt21(fee)} cauris, +${fmt21(f['fans'] as num)} fans', 'scene');
    return _ok(n);
  },

  // Booking international : [marché, format]. Frais de voyage payés d'avance, cachets selon la notoriété locale.
  'intl': (s, a) {
    if (a is! List || a.length != 2) return _no(s, 'inconnu');
    final mk = '${a[0]}', fm = '${a[1]}';
    final f = Reg21.intlFormats[fm];
    if (f == null || !Reg21.intlMarkets.containsKey(mk)) return _no(s, 'inconnu');
    final lock = intlLock21(s, mk, fm);
    if (lock != null) return _no(s, lock);
    final n = clone21(s);
    final e = _spend(n, f['h'] as num, f['e'] as num);
    if (e != null) return _no(s, e);
    final q = intlQuote21(s, mk, fm);
    _pay(n, -(f['cost'] as num));
    final cut = _cachet(n, q.fees, 'tournée internationale');
    n['intlLast'] = n['day'];
    n['fans'] = _n(n['fans']) + q.fans;
    n['rep'] = _n(n['rep']) + 5;
    n['shows'] = _n(n['shows']) + (f['dates'] as num);
    n['pop'] = clamp21(_n(n['pop']) + 2, 0, 100);
    _geoAdd(n, mk, f['geo'] as num);
    _addXp(n, 150 + (f['dates'] as int) * 20);
    final net = q.fees - cut - (f['cost'] as num);
    n['cc'] = {'g': 'I', 'tk': 0, 'gross': q.fees, 'cash': net, 'managerCut': cut, 'fans': q.fans, 'rep': 5, 'day': n['day'], 'tour': 1,
      'lbl': '${f['n']} à ${Reg21.intlMarkets[mk]!['n']}'};
    final hist = n['intl'] is List ? _l(n['intl']) : <dynamic>[];
    hist.insert(0, {'mk': mk, 'fm': fm, 'd': n['day'], 'net': net, 'fans': q.fans});
    n['intl'] = hist;
    _log(n, '${f['n']} à ${Reg21.intlMarkets[mk]!['n']} : ${f['dates']} dates, cachets ${fmt21(q.fees)}, frais ${fmt21(f['cost'] as num)}', 'scene');
    return _ok(n);
  },

  'tour': (s, a) {
    final t = Reg21.tour;
    if (_n(s['rank']) < (t['rank'] as num)) return _no(s, 'rang');
    if (_n(s['day']) - _n(s['lastTour']) < Reg21.tourEvery) {
      return _no(s, 'delai');
    }
    final geo = _m(s['geo']);
    if ((_n(geo['portambre']) + _n(geo['selene'])) / 2 < Reg21.tourAudience) {
      return _no(s, 'audience');
    }
    if (_n(s['cash']) < (t['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    final own = _m(s['own']);
    final e = _spend(n, t['h'] as num,
        (t['e'] as num) - (own['moto'] != null ? 5 : 0) -
            (own['voiture'] != null ? 5 : 0));
    if (e != null) return _no(s, e);
    final fee = (t['fee'] as num) +
        jsRound(
            (t['feeGeo'] as num) * (_n(geo['portambre']) + _n(geo['selene'])));
    final managerCut = _cachet(n, fee, 'tournée');
    _pay(n, -(t['cost'] as num));
    n['lastTour'] = n['day'];
    n['cc'] = {
      'g': 'T',
      'tk': 0,
      'gross': fee - (t['cost'] as num),
      'cash': fee - managerCut - (t['cost'] as num),
      'managerCut': managerCut,
      'fans': t['fans'],
      'rep': 4,
      'day': n['day'],
      'tour': 1
    };
    n['rep'] = _n(n['rep']) + 4;
    n['fans'] = _n(n['fans']) + (t['fans'] as num);
    n['shows'] = _n(n['shows']) + 2;
    _geoAdd(n, 'portambre', t['geo'] as num);
    _geoAdd(n, 'selene', t['geo'] as num);
    n['pop'] = clamp21(_n(n['pop']) + 2, 0, 100);
    _addXp(n, 120);
    _log(
        n,
        'Tournée régionale : +${fmt21(t['fans'] as num)} fans, Port-Ambre et Sélène +${t['geo']}',
        'scene');
    return _ok(n);
  },

  // ---------- économie ----------
  'job': (s, id) {
    final j = Reg21.jobs[id];
    if (j == null) return _no(s, 'inconnu');
    final lock = jobLock21(s, id as String);
    if (lock != null) return _no(s, lock);
    final n = clone21(s);
    final moto = _m(s['own'])['moto'] != null ? 5 : 0;
    final e = _spend(n, j['h'] as num, (j['e'] as num) - moto);
    if (e != null) return _no(s, e);
    _pay(n, j['cash'] as num);
    n['lastJob'] = {
      'id': id,
      'cash': j['cash'],
      'e': (j['e'] as num) - moto,
      'h': j['h']
    };
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
    if (id == 'appart' || id == 'maison') {
      n['en'] = math.min(enMax(n), _n(n['en']) + (a['energy'] as num? ?? 5));
    }
    if (a['prestige'] != null) n['rep'] = _n(n['rep']) + (a['prestige'] as num);
    _log(n, 'Bien acquis : ${a['n']}', 'eco');
    return _ok(n);
  },

  'merch': (s, id) {
    final m = Reg21.merch[id];
    if (m == null) return _no(s, 'inconnu');
    if (s['merch'] != null) return _no(s, 'encours');
    if (_n(s['fans']) < (m['fans'] as num)) return _no(s, 'fans');
    if (m['singles'] != null && _l(s['disco']).length < (m['singles'] as num)) {
      return _no(s, 'single');
    }
    if (m['rank'] != null && _n(s['rank']) < (m['rank'] as num))
    {
      return _no(s, 'rang');
    }
    if (_n(s['cash']) < (m['cost'] as num)) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -(m['cost'] as num));
    n['merch'] = {'id': id, 'left': m['days'], 'tot': 0};
    _log(n, 'Merch lancé : ${m['n']}', 'eco');
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
    _l(r['hist'])
        .add({'d': n['day'], 't': 'En couple avec ${cands21[cid]!['n']}'});
    _log(
        n,
        'Couple officialisé avec ${cands21[cid]!['n']} : relation exclusive',
        'perso');
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
      _log(
          n,
          'Tu as refusé la demande : relation −${Reg21.refuseLoss}, nouvelle demande possible dans ${Reg21.refuseCooldown} jours',
          'perso');
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
    _l(r['hist']).add({
      'd': n['day'],
      't': 'Mariage avec ${cands21[r['off']]!['n']} (${w['n']})'
    });
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
    _log(
        n,
        ans == 'oui'
            ? "Projet d'enfant : vous essayez (aucune garantie)"
            : "Projet d'enfant : pas maintenant",
        'perso');
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
    if (o['h'] != null && _n(n['hour']) + (o['h'] as num) > Reg21.dayEnd) {
      return _no(s, 'tard');
    }
    if (o['h'] != null) n['hour'] = _n(n['hour']) + (o['h'] as num);
    if (o['cash'] != null) {
      if (_n(n['cash']) < -(o['cash'] as num)) return _no(s, 'cash');
      _pay(n, o['cash'] as num);
    }
    if (o['e'] != null) n['en'] = math.max(0, _n(n['en']) + (o['e'] as num));
    final r = partner(n);
    if (o['g'] != null && r != null) {
      r['g'] = clamp21(_n(r['g']) + (o['g'] as num), 0, 100);
    }
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
      p['age'] = clamp21(a == null || a == 0 ? Reg21.startAge : a, Reg21.ageMin,
              Reg21.ageMax)
          .toInt();
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
    if (!['title', 'th', 'am', 'ptitle', 'projectTitle'].contains(k)) return _no(s, 'inconnu');
    final n = clone21(s);
    _m(n['ui'])[k] = v.length > 40 ? v.substring(0, 40) : v;
    return _ok(n);
  },

  // Titre du prochain EP ou album : tiré du dictionnaire, sans reprendre un titre déjà pris (la saisie libre reste possible).
  'rptitle': (s, a) {
    final n = clone21(s);
    final ui = _m(n['ui']);
    final type = (ui['ptype'] ?? 'EP') == 'Album' ? 'Album' : 'EP';
    final taken = usedTitles21(n)..add(cleanName21(ui['ptitle']));
    final seed = _titleSeed21(n) + _n(ui['ptn']).toInt() * 977;
    ui['ptn'] = _n(ui['ptn']).toInt() + 1;
    ui['ptitle'] = pickTitle(seed, kind: type == 'Album' ? TitleKind.album : TitleKind.ep, used: taken, maxLength: 30);
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
    _log(n, 'Bienvenue à Ndolo, ${p['name']} : ta carrière commence',
        'carriere');
    return _ok(n);
  },

  'evc': (s, ch) {
    final id = s['ev'] as String?;
    if (id == null) return _no(s, 'rien');
    final n = clone21(s);
    if (id == 'kzer') {
      if (ch == 'a') {
        if (_n(s['en']) < 15) return _no(s, 'energie');
        if (_n(s['hour']) + 1 > Reg21.dayEnd) return _no(s, 'tard');
        n['btq'] = 'kzer';
      } else {
        n['pop'] = clamp21(_n(n['pop']) + 2, 0, 100);
      }
    }
    if (id == 'kore') {
      const d = {
        'a': (8000, 15, 'Accord à 40 %'),
        'b': (7000, 8, 'Accord à 35 %, mix signé'),
        'c': (0, -10, 'Refus')
      };
      final x = d[ch];
      if (x == null) return _no(s, 'inconnu');
      if (_n(n['cash']) < x.$1) return _no(s, 'cash');
      _pay(n, -x.$1);
      n['kc'] = {
        'st': x.$3,
        'rel': x.$2,
        'bonus': ch == 'c' ? 0 : 12,
        'left': ch == 'c' ? 0 : 3
      };
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
    final fx = c.first['e'];
    if (fx is Map) {
      final err = _evFx(n, fx);
      if (err != null) return _no(s, err);
    }
    _m(n['evDone'])[id] = ch;
    n['evLast'] = {'t': e['t'], 'ch': c.first['n'], 'c': c.first['c']};
    final q = _l(n['evq']);
    q.removeWhere((queued) => queued == id);
    n['ev'] = q.isEmpty ? null : q.removeAt(0);
    _log(n, '${e['t']} : ${c.first['n']} (${c.first['c']})', 'evenement');
    return _ok(n);
  },

  /// Annonce de certification ou de cérémonie vue : elle quitte la file.
  'awseen': (s, a) {
    if (_l(s['awNews']).isEmpty) return _no(s, 'rien');
    final n = clone21(s);
    _l(n['awNews']).removeAt(0);
    return _ok(n);
  },

  /// Proposer un single à une playlist Ondéa : [id de playlist, id du titre, approche]. 1 h, −5 énergie.
  'plpitch': (s, arg) {
    if (arg is! List || arg.length != 3) return _no(s, 'inconnu');
    final p = playlist21('${arg[0]}');
    final ap = '${arg[2]}';
    if (p == null || !pitchApproaches21.containsKey(ap)) return _no(s, 'inconnu');
    final t = _l(s['disco']).map(_m).where((x) => x['id'] == arg[1]).firstOrNull;
    if (t == null) return _no(s, 'pasdetitre');
    if (placement21(s, p.id) != null) return _no(s, 'deja');
    if (cooldown21(s, p.id) != null) return _no(s, 'delai');
    final cost = pitchApproaches21[ap]!.cost;
    if (_n(s['cash']) < cost) return _no(s, 'cash');
    final n = clone21(s);
    final err = _spend(n, 1, 5);
    if (err != null) return _no(s, err);
    if (cost > 0) _pay(n, -cost);
    final sc = pitchScore21(s, p, t, ap);
    final ok = sc.total >= p.threshold;
    final pl = _m(n['pl']);
    pl['plc'] ??= <String, dynamic>{};
    pl['cool'] ??= <String, dynamic>{};
    final rel = _m(n['rel']);
    if (ok) {
      _m(pl['plc'])[p.id] = {'tid': t['id'], 'from': n['day'], 'until': _n(n['day']) + playlistDays21};
      rel[p.curator] = _n(rel[p.curator]) + 3;
    } else {
      _m(pl['cool'])[p.id] = _n(n['day']) + playlistCooldown21;
      rel[p.curator] = _n(rel[p.curator]) - 1;
    }
    pl['last'] = {'id': p.id, 'tid': t['id'], 't': t['title'], 'ok': ok ? 1 : 0, 'score': sc.total.round(), 'th': p.threshold, 'ap': ap, 'daily': playlistDaily21(p, t), 'd': n['day']};
    _log(n, ok ? '« ${t['title']} » entre dans la playlist ${p.n} ($playlistDays21 jours)' : '${p.curatorName} refuse « ${t['title']} » pour ${p.n}', 'musique');
    return _ok(n);
  },

  'mclaim': (s, id) {
    final m = mission21('$id');
    if (m == null) return _no(s, 'inconnu');
    if (_m(s['ms2'])[m.id] == null) return _no(s, 'pasfaite');
    if (_m(s['mc2'])[m.id] != null) return _no(s, 'deja');
    final n = clone21(s);
    final (cash, xp) = missionReward21(m);
    _m(n['mc2'])[m.id] = n['day'];
    _pay(n, cash);
    _addXp(n, xp);
    _log(n, 'Mission récupérée : ${m.t} (+${fmt21(cash)} cauris, +$xp XP)', 'mission');
    return _ok(n);
  },

  'rivalBattle': (s, arg) {
    if (arg is! List || arg.length != 2) return _no(s, 'inconnu');
    final id = arg[0]; final score = arg[1];
    if (id is! String || !Reg21.rivals.containsKey(id) || id == 'kzer') return _no(s, 'inconnu');
    if (score is! num || score < 0 || score > 3) return _no(s, 'inconnu');
    final n = clone21(s);
    final err = _spend(n, 1, 15);
    if (err != null) return _no(s, err);
    final win = score >= 2;
    final fans = win ? 150 : 12;
    final cut = win ? _cachet(n, 3000, 'battle contre ${Reg21.rivals[id]}') : 0;
    n['fans'] = _n(n['fans']) + fans;
    if (win) { n['rep'] = _n(n['rep']) + 6; _geoAdd(n, 'bakoma', 2); _addXp(n, 60); }
    _m(n['rivals'])[id] = {'lastWin': win ? 1 : 0, 'day': n['day'], 'level': _n(_m(n['rivals'])[id]?['level']) + 1};
    n['btl'] = {'win': win ? 1 : 0, 'score': score, 'fans': fans, 'gross': win ? 3000 : 0, 'cash': win ? 3000 - cut : 0, 'managerCut': cut, 'rep': win ? 6 : 0, 'xp': win ? 60 : 0, 'rival': Reg21.rivals[id]};
    _log(n, 'Battle contre ${Reg21.rivals[id]} : ${win ? 'victoire' : 'défaite'} ($score/3)', 'scene');
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
  final mul = _l(c['likes']).contains(act)
      ? Reg21.likeMul
      : (_l(c['dis']).contains(act) ? Reg21.dislikeMul : 1.0);
  final gain = jsRound((a['g'] as num) * mul);
  _pay(n, -(a['c'] as num));
  final r = _m(n['rom']);
  final cc = _m(_m(r['c'])[cid]);
  cc['g'] = clamp21(_n(cc['g']) + gain, 0, 100);
  cc['met'] = 1;
  r['used'] = _n(r['used']) + 1;
  _m(r['today'])[cid] = 1;
  r['lastAct'] = {'cid': cid, 'act': act, 'gain': gain, 'mul': mul};
  _log(n, '${a['n']} avec ${c['n']} : relation ${sg21(gain)} (${cc['g']}/100)',
      'perso');
  return _ok(n);
}

Res _endDay(J s) {
  final n = clone21(s);
  final ev = <String>[];
  final d0 = n['d0'] != null ? _m(n['d0']) : dayStart21(n);
  n['heat'] = math.max(0, _n(n['heat']) - Reg21.heatDecay);
  final jl = n['jail'];
  if (jl != null && _n(n['day']) + 1 >= _n(_m(jl)['until'])) {
    ev.add('Sortie de prison après ${_m(jl)['days']} jour(s)');
    _log(n, 'Sortie de prison', 'justice');
    n['jail'] = null;
  }
  // revenus passifs
  num inc = 0;
  final mt = managerTier21(n);
  if (mt != null && _n(mt['fee']) != 0 && _n(n['day']) % 7 == 0) {
    final fee = mt['fee'] as num;
    inc -= fee;
    ev.add('Manager ${mt['n']} : −${fmt21(fee)} cauris (forfait hebdomadaire)');
    n['managerPaid'] = _n(n['managerPaid']) + fee;
  }
  var catalogListensTotal = 0;
  for (final rawSong in _l(n['disco'])) {
    final song = _m(rawSong);
    // Le catalogue v20 rapporte 8 % des écoutes de lancement au premier jour,
    // puis perd 20 % par jour et s'arrête après 14 jours.
    final age = _n(n['day']) - _n(song['day']) + 1;
    final launchListens = _n(song['launchL'] ?? song['L']);
    final daily = age < 1 || age > Reg21.catalogDays
        ? 0
        : math
            .max(
                1,
                jsRound(launchListens *
                    Reg21.catalogDaily *
                    math.pow(Reg21.catalogDecay, age - 1)))
            .toInt();
    if (daily == 0) {
      song['lastDayL'] = 0;
      song['lastDayRev'] = 0;
      song['lastDayViews'] = 0;
      continue;
    }
    final gross = jsRound(daily * Reg21.listenValue);
    final cut = _t(song['signed']) ? jsRound(gross * Reg21.labelCut) : 0;
    final net = gross - cut;
    song['L'] = _n(song['L']) + daily;
    song['rev'] = _n(song['rev']) + net;
    song['cut'] = _n(song['cut']) + cut;
    song['lastDayL'] = daily;
    song['lastDayRev'] = net;
    // Les sauvegardes web peuvent fournir une ImmutableMap<dynamic, dynamic>.
    // La copie normalise les clés et permet d'ajouter les écoutes de la journée.
    final rawPlatforms = song['platforms'];
    final platforms = rawPlatforms is Map
        ? Map<String, dynamic>.from(rawPlatforms)
        : <String, dynamic>{};
    song['platforms'] = platforms;
    final split = _platformStreams21(daily);
    for (final platform in split.keys) {
      platforms[platform] = _n(platforms[platform]) + _n(split[platform]);
    }
    final clip = song['clip'];
    if (clip is Map && _m(clip)['st'] == 'publie') {
      final views = math.max(1, jsRound(daily * .35));
      song['views'] = _n(song['views']) + views;
      song['lastDayViews'] = views;
    }
    inc += net;
    catalogListensTotal += daily;
    ev.add(
        '${song['title']} : +$daily écoutes${cut > 0 ? ' · label −$cut' : ''}');
  }
  if (catalogListensTotal > 0) {
    n['fans'] = _n(n['fans']) +
        (catalogListensTotal * 0.07 / (1 + _n(n['fans']) / Reg21.fanSat))
            .ceil();
  }
  for (final id in _m(n['biz']).keys.toList()) {
    final b = Reg21.biz[id]!;
    final x = jsRound((b['lo'] as num) +
        ((b['hi'] as num) - (b['lo'] as num)) * rng21(n, id.length));
    inc += x;
    final bz = _m(_m(n['biz'])[id]);
    bz['tot'] = _n(bz['tot']) + x;
    ev.add('${b['n']} : ${sg21(x)} (estimé)');
  }
  if (_m(n['own'])['terrain'] != null) {
    final t = Reg21.assets['terrain']!;
    final y = jsRound(
        (t['lo'] as num) + ((t['hi'] as num) - (t['lo'] as num)) * rng21(n, 5));
    inc += y;
    ev.add('Loyer du terrain : ${sg21(y)}');
  }
  if (_m(n['own'])['bateau'] != null) {
    final b = Reg21.assets['bateau']!;
    final y = jsRound((b['lo'] as num) + ((b['hi'] as num) - (b['lo'] as num)) * rng21(n, 7));
    inc += y;
    ev.add('Location du bateau : ${sg21(y)}');
  }
  if (n['merch'] != null) {
    final mm = _m(n['merch']);
    final m = Reg21.merch[mm['id']]!;
    final z = jsRound(
        (m['perFan'] as num) * math.sqrt(_n(n['fans'])) * Reg21.merchScale);
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
  // [VALIDÉ 20/10, valeurs provisoires] campagnes marketing : effets quotidiens, puis fin de campagne.
  final mk = _m(n['mk']);
  for (final c in mkActive21(n)) {
    final m = media21[c['id']]!;
    m.geo.forEach((g, v) => _geoAdd(n, g, v));
    n['fans'] = _n(n['fans']) + m.fans;
    n['pop'] = clamp21(((_n(n['pop']) + m.pop) * 10).round() / 10, 0, 100);
  }
  for (final c in _l(mk['on']).map(_m)) {
    if (_n(c['until']) == _n(n['day']) + 1) ev.add('Campagne terminée : ${media21[c['id']]?.n ?? c['id']}');
  }
  mk['on'] = _l(mk['on']).where((c) => _n(_m(c)['until']) > _n(n['day']) + 1).toList();
  // [VALIDÉ 20/10, valeurs provisoires] réseaux sociaux : le buzz retombe, les abonnés suivent la popularité.
  final so = _m(n['soc']);
  so['buzz'] = jsRound(_n(so['buzz']) * 0.7);
  final sf = _m(so['f']);
  for (final k in sf.keys.toList()) {
    sf[k] = _n(sf[k]) + jsRound(_n(n['pop']) * (socialNets21[k]?.share ?? 0) * 0.5);
  }
  num cost = 0;
  if (_m(n['own'])['appart'] != null) {
    cost += Reg21.assets['appart']!['upkeep'] as num;
  }
  if (_m(n['own'])['maison'] != null) {
    cost += Reg21.assets['maison']!['upkeep'] as num;
  }
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
    final dec = cid == rom['off']
        ? Reg21.decayCouple
        : (rom['off'] != null ? 0 : Reg21.decayCourt);
    if (dec != 0 && _n(c['g']) > 0) c['g'] = math.max(0, _n(c['g']) - dec);
  }
  var r = partner(n);
  if (r != null && _n(r['g']) < Reg21.leaveAt) {
    final who = rom['off'] as String;
    _separate(n, who,
        'Rupture décidée par ${cands21[who]!['n']} (relation trop dégradée, sous ${Reg21.leaveAt})');
    ev.add(
        'Rupture : ${cands21[who]!['n']} est parti(e) — relation sous ${Reg21.leaveAt}');
    r = null;
  } else if (r != null && _n(r['g']) < Reg21.warnAt) {
    ev.add(
        'Attention : la relation avec ${cands21[rom['off']]!['n']} se dégrade (${r['g']}/100)');
  }
  // enfants
  final fam = _m(n['fam']);
  final kids = _l(fam['kids']);
  if (_t(rom['married']) &&
      _t(fam['proj']) &&
      kids.length < Reg21.maxKids &&
      rng21(n, 3) < Reg21.kidChance) {
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
  ev.addAll(_releaseDue(n));
  n['pendingProjects'] ??= <dynamic>[];
  final pendingProjects = _l(n['pendingProjects']);
  final dueProjects = pendingProjects.map(_m).where((p) => p['relDay'] != null && _n(p['relDay']) <= _n(n['day'])).toList()
    ..sort((a, b) => _n(a['relDay']).compareTo(_n(b['relDay'])));
  for (final p in dueProjects) {
    pendingProjects.removeWhere((x) => _m(x)['id'] == p['id']);
    _releaseProject(n, p);
    ev.add('Sortie programmée : ${p['title']}');
  }
  ev.addAll(_playlistsDay(n));
  ev.addAll(_awardsDay(n));
  ev.addAll(_festivalsDay(n));
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
  final baby =
      kids.any((k) => kidAge(n, _m(k)) < 1 && _m(k)['garde'] == 'Au foyer');
  n['en'] = enMax(n) - (baby ? Reg21.babyMorning : 0);
  _promote(n);
  final rel1 = partner(n);
  final famRe = RegExp(
      r'Rupture|Attention|Naissance|Charges du foyer| : (Bébé|Petite enfance|Enfant|Adolescent|Adulte)$');
  final yesterday =
      _l(n['log']).map(_m).where((l) => l['d'] == _n(n['day']) - 1).toList();
  n['bil'] = {
    'day': _n(n['day']) - 1,
    'cash': _n(n['cash']) - _n(d0['cash']),
    'pop': _n(n['pop']) - _n(d0['pop']),
    'fans': _n(n['fans']) - _n(d0['fans']),
    'xp': _n(n['xp']) - _n(d0['xp']),
    'rank0': d0['rank'],
    'rank': n['rank'],
    'en': n['en'],
    'enMax': enMax(n),
    'rel0': d0['rel'],
    'rel': rel1?['g'],
    'who': rel1 != null ? cands21[rom['off']]!['n'] : '',
    'kids': kids.length,
    'kids0': d0['kids'],
    'fam': [
      ...ev.where(famRe.hasMatch),
      ...yesterday.where((l) => l['c'] == 'perso').map((l) => l['t'])
    ].take(6).toList(),
    'ev': ev,
    'acts': yesterday.map((l) => l['t']).take(8).toList(),
    'aged': aged,
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
    _l(rom['hist'])
        .add({'d': 18, 't': 'Mariage avec Lina Mbaré (Cérémonie simple)'});
    _m(s['fam'])['proj'] = 1;
    _m(s['fam'])['projAsked'] = 1;
    s['d0'] = dayStart21(s);
    return s;
  },
  'parent': () {
    final s = presets21['marie']!();
    final fam = _m(s['fam']);
    fam['proj'] = 0;
    _l(fam['kids'])
        .add({'n': 'Nayla', 'born': 330, 'l': 55, 'garde': 'Au foyer'});
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
      {
        'id': 'T1',
        'title': 'Gbaka de 6h',
        'theme': 'quartier',
        'amb': 'sombre',
        'mode': 'manuel',
        'tx': 72,
        'st': 'sorti',
        'Q': 61,
        'feats': <dynamic>[],
        'clip': {'st': 'aucun'},
        'L': 5418,
        'rev': 54,
        'fg': 371,
        'pg': 6,
        'tier': 'Discret',
        'promo': 0,
        'vir': 30,
        'day': 3
      },
    ];
    s['geo'] = {
      'bakoma': 14,
      'portambre': 4,
      'selene': 3,
      'tamarel': 0,
      'korvane': 0,
      'aldera': 0
    };
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
    _l(s['disco']).insert(0, {
      'id': 'T2',
      'title': 'Monter au sommet',
      'theme': 'ambition',
      'amb': 'fiere',
      'mode': 'manuel',
      'tx': 76,
      'st': 'sorti',
      'Q': 70,
      'feats': ['nadia'],
      'clip': {'st': 'publie', 'dir': 'ombre', 'vir': 15},
      'L': 84000,
      'rev': 840,
      'fg': 2100,
      'pg': 14,
      'tier': 'Bon',
      'promo': 2,
      'vir': 69,
      'day': 25
    });
    s['geo'] = {
      'bakoma': 46,
      'portambre': 22,
      'selene': 19,
      'tamarel': 3,
      'korvane': 0,
      'aldera': 1
    };
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
    x['evDone'] = {..._m(x['evDone']), 'kzer': 'b', for (final p in problemOrder21) p: 'preset'};
    x['lbz'] = math.max(_n(x['lbz']), Reg21.lbzGate);
    _m(x['dseen'])['kore'] = 'Accord à 35 % (préréglage)';
    final kc = _m(x['kc']);
    if (!_t(kc['st'])) x['kc'] = {'st': 'Accord à 35 %, mix signé', 'bonus': 12, 'left': 0, 'rel': 8};
    x['ms'] = <String, dynamic>{};
    final dn = {
      'm1': _l(x['disco']).isNotEmpty,
      'm2': _l(x['disco']).isNotEmpty,
      'm3': _t(x['trained']),
      'm4': _n(x['fans']) >= 1000
    };
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
  // Hasard des publications : l'instant de l'action (0 dans les tests, donc reproductible).
  st['nonce'] = now % 1000003;
  final f = name == 'preset' ? _preset : actions21[name];
  if (f == null || name.startsWith('_')) return _no(st, 'inconnu');
  if (_t(st['jail']) && !jailOk21.contains(name)) return _no(st, 'prison');
  final cas = st['cas'];
  if (cas != null && _m(cas)['stage'] == 'garde' && !const {'bail', 'detention', 'lawyer', 'ctk'}.contains(name) && !jailOk21.contains(name)) {
    return _no(st, 'garde');
  }
  final before = (singles: _l(st['disco']).map((x) => _m(x)['id']).toSet(), projects: _l(st['projects']).length, shows: _n(st['shows']), viral: _n(_m(st['soc'])['viral']));
  final r = f(st, arg);
  if (r.err == null && !identical(r.s, st)) {
    norm21(r.s);
    if (name != 'preset') _labelInterest(r.s, before);
    _missions(r.s);
    _missions2(r.s);
    _problems(r.s);
    _triggers(r.s);
    r.s['t'] = now;
  }
  return r;
}

// ---------------------------------------------------------------------------------------------------------------------
// Playlists Ondéa : écoutes quotidiennes des titres placés, fin des placements (valeurs provisoires, D-08)
// ---------------------------------------------------------------------------------------------------------------------

List<String> _playlistsDay(J n) {
  final ev = <String>[];
  final plc = _m(_m(n['pl'])['plc']);
  for (final p in playlists21) {
    final x = plc[p.id];
    if (x is! Map) continue;
    final t = _l(n['disco']).map(_m).where((d) => d['id'] == x['tid']).firstOrNull;
    if (t != null && _n(x['until']) >= _n(n['day'])) {
      final g = playlistDaily21(p, t);
      t['plL'] = _n(t['plL']) + g;
      n['fans'] = _n(n['fans']) + (g / 100).round();
    }
    if (_n(x['until']) <= _n(n['day'])) {
      plc.remove(p.id);
      ev.add('Fin de « ${t?['title'] ?? '?'} » dans ${p.n}');
      _log(n, '« ${t?['title'] ?? '?'} » quitte la playlist ${p.n}', 'musique');
    }
  }
  return ev;
}

// ---------------------------------------------------------------------------------------------------------------------
// Certifications et cérémonies (awards21.dart), vérifiées à chaque nouvelle journée. Valeurs provisoires (D-02, D-08).
// ---------------------------------------------------------------------------------------------------------------------

/// Annonce à célébrer (salle des trophées) : 8 au plus, la plus ancienne d'abord.
void _awNews(J n, J item) {
  n['awNews'] ??= <dynamic>[];
  final l = _l(n['awNews']);
  l.add(item);
  while (l.length > 8) {
    l.removeAt(0);
  }
}

List<String> _awardsDay(J n) {
  final ev = <String>[];
  final seen = _m(n['certSeen']);
  for (final c in certs21(n)) {
    if (c.level > _n(seen[c.id] ?? -1)) {
      seen[c.id] = c.level;
      ev.add('${c.name} : ${c.title}');
      _log(n, 'Certification : ${c.name} pour ${c.title} (${fmt21(c.units)} unités)', 'carriere');
      _awNews(n, {'k': 'cert', 'id': c.id, 't': c.title, 'kind': c.kind, 'lv': c.level, 'u': c.units, 'd': n['day']});
    }
  }
  final day = _n(n['day']), y = yearOf21(day), w = weekOf21(day);
  final aw = _m(n['aw']);
  aw['done'] ??= <String, dynamic>{};
  aw['hist'] ??= <dynamic>[];
  // Semaine 41 : nominations de l'année annoncées et figées (les résultats se décident ensuite à chaque cérémonie).
  aw['nom'] ??= <String, dynamic>{};
  if (w >= nominationsWeek21 && w < ceremonies21.first.week && _m(aw['nom'])['$y'] == null) {
    final noms = nominations21(n);
    _m(aw['nom'])['$y'] = [for (final x in noms) '${x.$1.id}-${x.$2.id}'];
    _log(n, noms.isEmpty ? 'Nominations de l\'année : aucune pour toi' : 'Nominations de l\'année : ${noms.length} catégorie(s)', 'carriere');
    _awNews(n, {
      'k': 'nom', 'y': y, 'd': day,
      'cats': [for (final x in noms) {'n': x.$2.n, 'c': x.$1.id}],
    });
    ev.add(noms.isEmpty ? 'Nominations : aucune cette année' : 'Nominations : ${noms.length} catégorie(s)');
  }
  for (final c in ceremonies21) {
    final key = '$y-${c.id}';
    if (w < c.week || _m(aw['done'])[key] != null) continue;
    _m(aw['done'])[key] = day;
    final res = ceremonyResults21(n, c, frozenNominations21(n));
    var wins = 0, noms = 0;
    for (final cat in c.cats) {
      final r = res[cat.id];
      if (r == null) continue;
      _l(aw['hist']).add({'y': y, 'c': c.id, 'cat': cat.id, 'res': r, 'd': day});
      if (r == 'win') {
        wins++;
        n['rep'] = _n(n['rep']) + 2 * c.prestige;
        n['fans'] = _n(n['fans']) + 300 * c.prestige;
        _addXp(n, 50 * c.prestige);
        _log(n, '${c.n} : lauréat « ${cat.n} »', 'carriere');
      } else {
        noms++;
        n['rep'] = _n(n['rep']) + 1;
        n['fans'] = _n(n['fans']) + 80;
        _log(n, '${c.n} : nommé « ${cat.n} »', 'carriere');
      }
    }
    aw['last'] = {'c': c.id, 'y': y, 'wins': wins, 'noms': noms};
    _awNews(n, {
      'k': 'cer', 'c': c.id, 'y': y, 'wins': wins, 'noms': noms, 'd': day,
      'cats': [for (final cat in c.cats) if (res[cat.id] != null) {'n': cat.n, 'res': res[cat.id]}],
    });
    ev.add(wins > 0 ? '${c.n} : $wins trophée(s)' : noms > 0 ? '${c.n} : $noms nomination(s)' : '${c.n} : pas de nomination cette année');
  }
  return ev;
}

// ---------------------------------------------------------------------------------------------------------------------
// Intérêt des labels, problèmes de début de carrière, missions de carrière, boulots (valeurs provisoires, D-08)
// ---------------------------------------------------------------------------------------------------------------------

/// Les labels s'intéressent au joueur au fil de ses sorties, de ses dates et de ses publications virales.
void _labelInterest(J n, ({Set singles, int projects, num shows, num viral}) b) {
  if (!_t(n['created'])) return;
  var g = 0;
  for (final x in _l(n['disco']).map(_m)) {
    if (!b.singles.contains(x['id'])) g += Reg21.lbzSingle + (_n(x['Q']) >= 70 ? Reg21.lbzGoodSingle : 0);
  }
  g += math.max(0, _l(n['projects']).length - b.projects) * Reg21.lbzProject;
  g += math.max(0, _n(n['shows']) - b.shows).toInt() * Reg21.lbzShow;
  g += math.max(0, _n(_m(n['soc'])['viral']) - b.viral).toInt() * Reg21.lbzViral;
  if (g > 0) n['lbz'] = math.min(Reg21.lbzMax, _n(n['lbz']) + g);
}

/// Un problème de début de carrière à la fois, espacés de quelques jours, tant que le joueur n'a pas percé.
void _problems(J n) {
  if (!_t(n['created']) || n['ev'] != null || _n(n['rank']) > Reg21.pbMaxRank || _n(n['day']) < _n(n['pbd'])) return;
  final done = _m(n['evDone']);
  final singles = _l(n['disco']).length, shows = _n(n['shows']), day = _n(n['day']);
  final cond = <String, bool>{
    'pb_micro': singles >= 1 && day >= 3,
    'pb_faux': singles >= 1 && day >= 5 && !_t(n['signed']),
    'pb_cachet': shows >= 1 && day >= 4,
    'pb_critique': singles >= 2 && day >= 6,
    'pb_fuite': singles >= 3 || (singles >= 2 && n['cur'] != null),
    'pb_sono': shows >= 2,
  };
  for (final id in problemOrder21) {
    if (done[id] == null && cond[id] == true) {
      _queueEv(n, id);
      n['pbd'] = day + Reg21.pbEvery;
      return;
    }
  }
}

/// Effets génériques d'un choix d'événement : coût d'abord vérifié, puis appliqué.
String? _evFx(J n, Map fx) {
  final cash = fx['cash'] as num?;
  if (cash != null && cash < 0 && _n(n['cash']) < -cash) return 'cash';
  if (_t(fx['h']) || _t(fx['en'])) {
    final er = _spend(n, _n(fx['h']), _n(fx['en']));
    if (er != null) return er;
  }
  if (cash != null) _pay(n, cash);
  for (final k in const ['fans', 'rep']) {
    if (fx[k] != null) n[k] = math.max(0, _n(n[k]) + (fx[k] as num));
  }
  if (fx['pop'] != null) n['pop'] = clamp21(_n(n['pop']) + (fx['pop'] as num), 0, 100);
  if (fx['lbz'] != null) n['lbz'] = math.min(Reg21.lbzMax, _n(n['lbz']) + (fx['lbz'] as num));
  if (fx['xp'] != null) _addXp(n, fx['xp'] as num);
  if (fx['rel'] is Map) {
    (fx['rel'] as Map).forEach((k, v) => _m(n['rel'])[k] = _n(_m(n['rel'])[k]) + (v as num));
  }
  return null;
}

/// Missions de carrière : elles se terminent seules ; la récompense attend la récupération (action mclaim).
void _missions2(J n) {
  if (!_t(n['created'])) return;
  final done = _m(n['ms2']);
  for (final m in missions21) {
    if (done[m.id] == null && missionMetric21(n, m.metric) >= m.goal) {
      done[m.id] = n['day'];
    }
  }
}

/// Condition manquante d'un boulot (code d'erreur) ou null s'il est accessible.
/// Pourquoi une formation est indisponible (null : disponible) : rang insuffisant ou déjà suivie aujourd'hui.
String? trainLock21(J s, String id) {
  final t = Reg21.trainings[id];
  if (t == null) return 'inconnu';
  if (_n(s['rank']) < (t['rank'] as num)) return 'rang';
  if (s['trDay'] is Map && _n(_m(s['trDay'])[id]) == _n(s['day']) && _m(s['trDay'])[id] != null) return 'aujourdhui';
  return null;
}

/// Invitations de festival : chaque jour, si la semaine d'un festival commence et que le joueur y est éligible
/// (rang et popularité), l'invitation s'ouvre jusqu'à la fin de la semaine. Rien ne change dans les stats.
List<String> _festivalsDay(J n) {
  final ev = <String>[];
  if (!_t(n['created'])) return ev;
  final fi = n['fi'] is Map ? _m(n['fi']) : <String, dynamic>{};
  final day = _n(n['day']);
  for (final id in Reg21.festivalOrder) {
    final f = Reg21.festivals[id]!;
    for (final w in _l(f['weeks'])) {
      if (weekOf21(day) != w) continue;
      final k = '${yearOf21(day)}-$id-$w';
      if (fi[k] != null) continue;
      if (_n(n['rank']) < (f['rank'] as num) || _n(n['pop']) < (f['pop'] as num)) continue;
      fi[k] = 'invite';
      ev.add('Invitation : ${f['n']} (${f['city']}) · cachet ${fmt21(f['fee'] as num)} cauris');
    }
  }
  if (fi.isNotEmpty) n['fi'] = fi;
  return ev;
}

/// Invitation ouverte pour ce festival cette semaine (k : clé), ou null.
J? festivalInvite21(J s, String id) {
  final f = Reg21.festivals[id];
  if (f == null || s['fi'] is! Map) return null;
  final day = _n(s['day']);
  for (final w in _l(f['weeks'])) {
    final k = '${yearOf21(day)}-$id-$w';
    if (weekOf21(day) == w && _m(s['fi'])[k] == 'invite') return {'k': k, 'id': id, 'w': w};
  }
  return null;
}

/// Toutes les invitations ouvertes aujourd'hui.
List<J> festivalInvites21(J s) => [for (final id in Reg21.festivalOrder) if (festivalInvite21(s, id) != null) festivalInvite21(s, id)!];

/// Pourquoi une tournée internationale n'est pas possible (null : possible).
String? intlLock21(J s, String mk, String fm) {
  final f = Reg21.intlFormats[fm];
  if (f == null) return 'inconnu';
  if (_n(s['rank']) < Reg21.intlRank) return 'rang';
  if (s['intlLast'] != null && _n(s['day']) - _n(s['intlLast']) < Reg21.intlEvery) return 'delai';
  if (_n(_m(s['geo'])[mk]) < (f['needGeo'] as num)) return 'audience';
  if (_n(s['cash']) < (f['cost'] as num)) return 'cash';
  return null;
}

/// Devis d'une tournée internationale : cachets (par date × notoriété locale) et fans estimés.
({int fees, int fans, int perDate}) intlQuote21(J s, String mk, String fm) {
  final f = Reg21.intlFormats[fm]!;
  final g = _n(_m(s['geo'])[mk]);
  final perDate = jsRound((f['perDate'] as num) * (1 + g / 50));
  return (fees: perDate * (f['dates'] as int), fans: jsRound((f['fans'] as num) * (1 + g / 100)), perDate: perDate);
}

String? jobLock21(J s, String id) {
  final j = Reg21.jobs[id];
  if (j == null) return 'inconnu';
  if (j['rank'] != null && _n(s['rank']) < (j['rank'] as num)) return 'rang';
  if (j['cha'] != null && _n(_m(s['sk'])['cha']) < (j['cha'] as num)) return 'charisme';
  if (j['voix'] != null && _n(_m(s['sk'])['voix']) < (j['voix'] as num)) return 'voix';
  if (j['ecr'] != null && _n(_m(s['sk'])['ecr']) < (j['ecr'] as num)) return 'ecriture';
  if (j['rep'] != null && _n(s['rep']) < (j['rep'] as num)) return 'rep';
  return null;
}
