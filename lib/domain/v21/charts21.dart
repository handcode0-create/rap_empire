// Classements de l'univers (autres artistes) simulés semaine après semaine : de nouveaux titres sortent, montent,
// puis redescendent. Déterministe (même semaine, même classement) et 100 % fictif. Valeurs provisoires (D-08).
// Les lignes du joueur restent calculées par view21 (singlesRank, globalRank, bestProject).
import 'dart:math' as math;

num _n(dynamic x) => (x ?? 0) as num;

class ChartArtist21 {
  final String n;
  final double power; // écoutes hebdomadaires d'un titre au sommet, en millions
  final int period, offset; // un single toutes les [period] semaines, décalé de [offset]
  const ChartArtist21(this.n, this.power, this.period, this.offset);
}

const chartArtists21 = <ChartArtist21>[
  ChartArtist21('Kaïra Nox', 13.0, 7, 0),
  ChartArtist21('Zaki Mbela', 12.2, 6, 2),
  ChartArtist21('Madame Orage', 11.1, 8, 4),
  ChartArtist21('Tito Brume', 10.0, 7, 5),
  ChartArtist21('Lazuli', 9.4, 6, 1),
  ChartArtist21('Sôlo Vance', 8.9, 9, 3),
  ChartArtist21('Nadia Kolo', 8.3, 7, 6),
  ChartArtist21('Bako Flux', 7.9, 5, 2),
  ChartArtist21('Dr. Sable', 7.4, 8, 7),
  ChartArtist21('Yaya Cendre', 7.0, 6, 4),
  ChartArtist21('Ayana Dembé', 6.6, 7, 3),
  ChartArtist21('Naya Rêve', 6.2, 5, 1),
  ChartArtist21("K-Zer d'Mabaya", 5.1, 6, 5),
  ChartArtist21('Tamsir Koffi', 4.6, 7, 2),
];

const _w1 = ['Minuit', 'Pluie', 'Brume', 'Lagune', 'Sable', 'Orage', 'Cendres', 'Verre', 'Rives', 'Ambre', 'Néon', 'Gbaka', 'Pont', 'Lumière', 'Écho', 'Fièvre', 'Soleil', 'Marée', 'Cauri', 'Tonnerre', 'Silence', 'Velours'];
const _w2 = ["d'Argent", 'sur Ndo', 'de Lumbé', 'du Port', 'de Mabaya', 'de Minuit', 'sans Fin', 'en Feu', "d'Ambre", 'du Carrefour', 'de Kôtoro', 'à Sélène', 'sous la Pluie', 'du Matin', "d'Or", 'du Quartier'];
const _albumWords = ['Chroniques', 'Rivages', 'Nuits', 'Héritage', 'Mosaïque', 'Saisons', 'Vertiges', 'Horizons', 'Racines', 'Lumières'];
const _epWords = ['Sessions', 'Fragments', 'Esquisses', 'Carnets', 'Échos', 'Instants'];

int _h(String s) {
  var h = 7;
  for (final u in s.codeUnits) {
    h = (h * 31 + u) % 1000003;
  }
  return h;
}

/// Semaine absolue de jeu (1, 2, 3… sans revenir à 1 chaque année) : le classement change chaque semaine.
int chartWeek21(num day) => ((day - 1) / 7).floor() + 1;

/// Titre du j-ième single d'un artiste (fixe pour toujours).
String chartTitle21(String artist, int j) {
  final h = _h('$artist#$j');
  return '${_w1[h % _w1.length]} ${_w2[(h ~/ 7) % _w2.length]}';
}

class ChartRow21 {
  final String t, a;
  final num value;
  final int rank;
  final int? prev; // rang la semaine précédente (null : nouvelle entrée)
  const ChartRow21(this.t, this.a, this.value, this.rank, this.prev);
  /// Évolution : '+2', '-1', '=', 'NEW'.
  String get mv => prev == null ? 'NEW' : prev == rank ? '=' : (prev! > rank ? '+${prev! - rank}' : '-${rank - prev!}');
}

double _jit(String key) => 0.86 + (_h(key) % 1000) / 1000 * 0.28;

/// Courbe d'un titre : montée la première semaine, sommet la deuxième, puis baisse de 12 % par semaine.
double _curve(int age) => age < 0 ? 0 : age == 0 ? 0.72 : age == 1 ? 1.0 : math.pow(0.88, age - 1).toDouble();

List<({String t, String a, double v})> _songsAt(int w) {
  final out = <({String t, String a, double v})>[];
  for (final ar in chartArtists21) {
    // singles sortis ces 24 dernières semaines
    final last = ((w - ar.offset) / ar.period).floor();
    for (var j = last; j >= last - 24 ~/ ar.period && j >= -4; j--) {
      final rel = ar.offset + j * ar.period;
      final age = w - rel;
      if (age < 0 || age > 24) continue;
      final hit = 0.7 + (_h('${ar.n}*$j') % 1000) / 1000 * 0.6; // certains titres marchent mieux que d'autres
      out.add((t: chartTitle21(ar.n, j), a: ar.n, v: ar.power * 1e6 * hit * _curve(age) * _jit('${ar.n}$j@$w')));
    }
  }
  out.sort((a, b) => b.v.compareTo(a.v));
  return out;
}

List<({String t, String a, double v})> _projectsAt(int w, bool ep) {
  final out = <({String t, String a, double v})>[];
  for (final ar in chartArtists21) {
    final period = ep ? 13 : 26, off = (ar.offset * 3 + (ep ? 5 : 0)) % period;
    final last = ((w - off) / period).floor();
    for (var j = last; j >= last - 1; j--) {
      final age = w - (off + j * period);
      if (age < 0 || age > 30) continue;
      final words = ep ? _epWords : _albumWords;
      final title = ep ? '${chartTitle21(ar.n, j * 3 + 1).split(' ').first} ${words[_h('${ar.n}e$j') % words.length]}' : words[_h('${ar.n}a$j') % words.length];
      final peak = (ep ? 0.45e6 : 2.0e6) * ar.power / 13;
      out.add((t: title, a: ar.n, v: peak * _curve(age) * _jit('${ar.n}$ep$j@$w')));
    }
  }
  out.sort((a, b) => b.v.compareTo(a.v));
  return out;
}

List<({String t, String a, double v})> _artistsAt(int w) {
  final sums = <String, double>{};
  for (final s in _songsAt(w)) {
    sums[s.a] = (sums[s.a] ?? 0) + s.v;
  }
  final mx = sums.values.fold<double>(1, math.max);
  final out = [for (final e in sums.entries) (t: e.key, a: '', v: 60 + 38.4 * e.value / mx)];
  out.sort((a, b) => b.v.compareTo(a.v));
  return out;
}

/// Lignes d'un classement de l'univers pour la semaine du jour [day]. [board] : singles, albums, eps, global.
List<ChartRow21> chart21(String board, num day, {int top = 10}) {
  final w = chartWeek21(day);
  List<({String t, String a, double v})> at(int x) => switch (board) {
        'albums' => _projectsAt(x, false),
        'eps' => _projectsAt(x, true),
        'global' => _artistsAt(x),
        _ => _songsAt(x),
      };
  final now = at(w), before = at(w - 1);
  final prevRank = <String, int>{for (var i = 0; i < before.length; i++) '${before[i].t}|${before[i].a}': i + 1};
  return [
    for (var i = 0; i < math.min(top, now.length); i++)
      ChartRow21(now[i].t, now[i].a, board == 'global' ? (now[i].v * 10).round() / 10 : now[i].v.round(), i + 1, prevRank['${now[i].t}|${now[i].a}']),
  ];
}

/// Toutes les valeurs de la semaine (sans limite de rang), de la plus forte à la plus faible : sert à placer le joueur.
List<double> chartValues21(String board, num day) {
  final w = chartWeek21(day);
  final rows = switch (board) { 'albums' => _projectsAt(w, false), 'eps' => _projectsAt(w, true), 'global' => _artistsAt(w), _ => _songsAt(w) };
  return [for (final r in rows) board == 'global' ? (r.v * 10).round() / 10 : r.v.roundToDouble()];
}

/// Courbe de vie d'une sortie (semaine 0 : 72 %, semaine 1 : sommet, puis −12 % par semaine), commune à tous les artistes.
double chartCurve21(int ageWeeks) => _curve(ageWeeks);

/// Titres récents d'un ensemble d'artistes (pour remplir une playlist), du plus écouté au moins écouté.
List<({String t, String a})> recentSongs21(num day, bool Function(String artist) keep, {int n = 6}) =>
    [for (final s in _songsAt(chartWeek21(day)).where((s) => keep(s.a)).take(n)) (t: s.t, a: s.a)];

/// Valeur affichable d'une écoute ou d'une vente (« 12,4 M », « 420 k »).
String chartVal21(num v) {
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1).replaceAll('.', ',')} M';
  if (v >= 1e3) return '${(v / 1e3).round()} k';
  return '${_n(v).round()}';
}
