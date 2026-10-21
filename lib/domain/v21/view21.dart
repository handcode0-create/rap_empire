import 'dart:math' as math;
import 'engine21.dart';
import 'reg21.dart';

/// Valeurs d'affichage dérivées de l'état v21 (équivalent des champs de view() du prototype dont les écrans ont besoin).
/// Aucune règle ici : les règles sont dans engine21.dart.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;
List _l(dynamic x) => x is List ? x : const [];

String playerName(J s) {
  final n = cleanName21(_m(s['p'])['name']);
  return n.isEmpty ? 'Nouvel artiste' : n;
}

String initials21(J s) {
  final t = playerName(s).split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).join().toUpperCase();
  return t.isEmpty ? 'NA' : t.substring(0, math.min(2, t.length));
}

int rankOf(J s) => _n(s['rank']).toInt();
String rankName(J s) => Reg21.ranks[rankOf(s) - 1]['n'] as String;
String rankTag(J s) => 'N${rankOf(s)} · ${rankName(s).toUpperCase()}';

/// Progression de la barre d'XP du rang actuel (0 à 1).
double xpFraction(J s) {
  final rk = rankOf(s);
  final lo = Reg21.ranks[rk - 1]['xp'] as num;
  final hi = rk < Reg21.ranks.length ? Reg21.ranks[rk]['xp'] as num : lo + 600;
  return (clamp21(jsRound(100 * (_n(s['xp']) - lo) / (hi - lo)), 0, 100) / 100).toDouble();
}

String hourLabel(J s) => '${_n(s['hour']).toInt().toString().padLeft(2, '0')}:00';
int dayInYear(J s) => ((_n(s['day']) - 1) % Reg21.daysPerYear).toInt() + 1;
int yearOf(J s) => ((_n(s['day']) - 1) / Reg21.daysPerYear).floor() + 1;
String timeLabel(J s) => 'J${dayInYear(s)} · ${hourLabel(s)}';
int hoursLeft(J s) => Reg21.dayEnd - _n(s['hour']).toInt();
String energyLabel(J s) => '${_n(s['en']).toInt()}/${enMax(s)}';
bool isLate(J s) => _n(s['hour']) >= 22;
bool isTired(J s) => _n(s['en']) < 20;

/// Entrées du journal du jour, plus récentes d'abord.
List<J> todayLog(J s) => [for (final l in _l(s['log'])) if (_m(l)['d'] == s['day']) _m(l)];

/// Mission de départ à faire en priorité (null quand toutes sont faites).
J? nextMission(J s) {
  for (final m in Reg21.missions) {
    if (_m(s['ms'])[m['id']] == null) return m;
  }
  return null;
}

int missionsDone(J s) => Reg21.missions.where((m) => _m(s['ms'])[m['id']] != null).length;

/// Une barre de géographie ou de continent, arrondie.
int geoOf(J s, String city) => _n(_m(s['geo'])[city]).round();
int contOf(J s, String cont) {
  final c = (Reg21.conts[cont]!['c'] as List).cast<String>();
  return (c.fold<num>(0, (a, x) => a + _n(_m(s['geo'])[x])) / c.length).round();
}

double tourAudience(J s) => (_n(_m(s['geo'])['portambre']) + _n(_m(s['geo'])['selene'])) / 2;

/// Le meilleur titre sorti (le plus écouté), ou null.
J? bestSong(J s) {
  J? best;
  for (final d in _l(s['disco'])) {
    if (best == null || _n(_m(d)['L']) > _n(best['L'])) best = _m(d);
  }
  return best;
}

/// Rang du meilleur titre au Top 100 Singles (0 = non classé), formule de la planche 21-R2 (provisoire).
int singlesRank(J s) {
  final b = bestSong(s);
  final l = b == null ? 0 : _n(b['L']);
  return l >= Reg21.entry ? math.max(8, math.min(100, jsRound(7 * math.pow(l / 8e6, -1 / 1.3)))) : 0;
}

/// Rang au Top 10 Global (0 = non classé), seuil 76,3 de l'indice.
int globalRank(J s) {
  final i = idxParts21(s).i;
  return i >= 76.3 ? math.max(1, jsRound(10 * math.pow(i / 76.3, -1 / 1.19))) : 0;
}

String d1(num x) => (jsRound(x * 10) / 10).toString().replaceAll('.', ',');

/// Nom lisible d'un état de clip.
String clipLabel(String st) => const {'aucun': 'Pas de clip', 'prepare': 'Clip préparé', 'produit': 'Clip tourné', 'publie': 'Clip publié'}[st] ?? st;

/// Jours de détention restants (0 hors prison).
int jailDaysLeft(J s) {
  final j = s['jail'];
  return j == null ? 0 : math.max(0, _n(_m(j)['until']).toInt() - _n(s['day']).toInt());
}

/// Nom de l'instru d'un titre en cours : `inst` est un identifiant (Reg21.instrus) ; l'ancien parcours y stockait le nom.
String instName21(J cur) {
  final i = Reg21.instrus[cur['instId'] ?? cur['inst']];
  return i != null ? i['n'] as String : '${cur['inst'] ?? '—'}';
}

num instQ21(J cur) => (Reg21.instrus[cur['instId'] ?? cur['inst']]?['Q'] ?? cur['instQ'] ?? 0) as num;

// ---------------------------------------------------------------------------------------------------------------------
// Catalogue, fiches de titres, EP et albums (planches 21-A0 à 21-A2). Valeurs d'affichage seulement.
// ---------------------------------------------------------------------------------------------------------------------

/// Streams cumulés d'un titre : 7 premiers jours, puis +35 % par semaine pendant 12 semaines (provisoire), plus les écoutes du clip.
int streamsTotal(J s, J t) {
  final wk = ((_n(s['day']) - _n(t['day'])) / 7).floor();
  return jsRound(_n(t['L']) * (1 + math.min(wk, 12) * 0.35)) + _n(t['clipL']).toInt();
}

/// Nombre de ventes d'un titre (anciennes sauvegardes : 1,2 % des écoutes).
int salesOf(J t) => (t['sales'] ?? jsRound(_n(t['L']) * Reg21.singleSales)) as int;

/// Rang d'un single au Top 100 (0 = non classé), formule de la planche 21-R2.
int singleRankOf(J t) => _n(t['L']) >= Reg21.entry ? math.max(8, math.min(100, jsRound(7 * math.pow(_n(t['L']) / 8e6, -1 / 1.3)))) : 0;

/// « J25 · Indépendant · Bon » : ligne de détail d'une ligne du catalogue.
String titleMeta(J t) => 'J${t['day']} · ${t['labelAt'] ?? 'Indépendant'} · ${t['tier']}';

/// Meilleur projet (le plus vendu) d'un type, ou null.
J? bestProject(J s, String type) {
  J? best;
  for (final p in _l(s['projects'])) {
    final pj = _m(p);
    if (pj['type'] == type && (best == null || _n(pj['sales']) > _n(best['sales']))) best = pj;
  }
  return best;
}

/// Rang d'un projet : « #12 », ou « Non classé ».
String projectRankLabel(J p) => _n(p['rank']) > 0 ? '#${p['rank']}' : 'Non classé';

/// Nom du classement d'un projet : Top 50 EPs ou Top 200 Albums.
String projectBoard(String type) => type == 'EP' ? 'Top ${Reg21.proj['EP']!['top']} EPs' : 'Top ${Reg21.proj['Album']!['top']} Albums';

/// Titre sélectionné pour la fiche (ui.ctk), à défaut le dernier sorti.
J? selectedTitle(J s) {
  final id = _m(s['ui'])['ctk'];
  final d = _l(s['disco']);
  for (final t in d) {
    if (_m(t)['id'] == id) return _m(t);
  }
  return d.isEmpty ? null : _m(d.first);
}

/// Projets qui contiennent un titre (« EP « Nuits » »).
String titleInProjects(J s, J t) {
  final names = [for (final p in _l(s['projects'])) if (_l(_m(p)['tracks']).contains(t['id'])) '${_m(p)['type']} « ${_m(p)['title']} »'];
  return names.isEmpty ? 'Aucun projet' : names.join(', ');
}

/// Effet actuel de l'open mic en pourcentage : 100 % puis −15 points par passage sur 7 jours glissants (plancher 30 %).
int openMicEffect(J s) {
  final n = _l(s['omHist']).where((d) => _n(s['day']) - _n(d) < Reg21.omWindow).length;
  return jsRound(100 * math.max(Reg21.omFloor, 1 - Reg21.omStep * n));
}

// ---------------------------------------------------------------------------------------------------------------------
// Plateformes fictives (21-D1 à D4) : répartition des écoutes déjà calculées, aucun revenu ni écoute en plus.
// ---------------------------------------------------------------------------------------------------------------------

/// Écoutes d'un titre vues par les plateformes : écoutes de lancement + clip + playlists Ondéa.
int platformListens(J t) => (_n(t['L']) + _n(t['clipL']) + _n(t['plL'])).toInt();

/// Totaux par plateforme sur tout le catalogue.
({int total, int ondea, int cauri, int listeners, int followers, int klipoViews, int clips, int revOndea, int revCauri}) platformTotals(J s) {
  final disco = _l(s['disco']).map(_m).toList();
  final tot = disco.fold<int>(0, (a, t) => a + platformListens(t));
  final clips = disco.where((t) => t['clip'] is Map && (t['clip'] as Map)['st'] == 'publie').toList();
  final p = platformSplit21(tot);
  final vpl = Reg21.platforms['klipo']!['viewsPerClipListen'] as num;
  return (
    total: tot,
    ondea: p.ondea,
    cauri: p.cauri,
    listeners: jsRound(tot * Reg21.listenersRatio),
    followers: jsRound(_n(s['fans']) * 0.6),
    klipoViews: clips.fold<int>(0, (a, t) => a + jsRound(_n(t['clipL']) * vpl)),
    clips: clips.length,
    revOndea: jsRound(tot * (Reg21.platforms['ondea']!['share'] as num) * Reg21.listenValue),
    revCauri: jsRound(tot * (Reg21.platforms['cauri']!['share'] as num) * Reg21.listenValue),
  );
}

/// Date de jeu lisible : « J12 · An 1 ». C'est la date qui sert aux sorties programmées.
String dateLabel21(num day) => 'J${((day - 1) % Reg21.daysPerYear).toInt() + 1} · An ${((day - 1) / Reg21.daysPerYear).floor() + 1}';

/// « demain », « dans 3 jours », « aujourd'hui » par rapport au jour courant.
String dueIn21(num relDay, num today) {
  final d = (relDay - today).toInt();
  return d <= 0 ? "aujourd'hui" : d == 1 ? 'demain' : 'dans $d jours';
}

/// Titres enregistrés non sortis : sorties programmées d'abord (par date), puis la réserve sans date.
List<J> stockSongs21(J s) {
  final all = (s['stock'] as List? ?? const []).map((x) => x as J).toList();
  final dated = all.where((x) => x['relDay'] != null).toList()..sort((a, b) => _n(a['relDay']).compareTo(_n(b['relDay'])));
  return [...dated, ...all.where((x) => x['relDay'] == null)];
}
