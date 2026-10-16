import 'dart:math' as math;
import 'engine21.dart';
import 'reg21.dart';

/// Valeurs d'affichage dérivées de l'état v21 (équivalent des champs de view() du prototype dont les écrans ont besoin).
/// Aucune règle ici : les règles sont dans engine21.dart.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;
List _l(dynamic x) => x as List;

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
