// Certifications et cérémonies de récompenses v21 (propositions 18.4 et 18.5, ramenées à l'économie du jeu).
// Toutes les valeurs sont provisoires (D-02, D-08). Une certification n'est jamais retirée (I-20) ;
// au plus 3 victoires par artiste et par cérémonie (I-23) ; une défaite n'est jamais purement négative.
import 'dart:math' as math;
import 'reg21.dart';

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map ? x as J : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

// ---------------------------------------------------------------------------------------------------------------------
// Certifications
// ---------------------------------------------------------------------------------------------------------------------

const certLevels21 = ['or', 'platine', 'double', 'triple', 'diamant'];
const certNames21 = {
  'or': "Disque d'or",
  'platine': 'Disque de platine',
  'double': 'Double disque de platine',
  'triple': 'Triple disque de platine',
  'diamant': 'Disque de diamant',
};

/// Seuils de certification calqués sur la grille de la SNEP française (demandé par Smith le 22/10/2026), en unités par format.
/// Album et EP : équivalents-ventes (ventes + streams ÷ 1 500) : or 50 000, platine 100 000, double 200 000, triple 300 000, diamant 500 000.
/// Single : équivalents-streams (écoutes + téléchargements × 150) : or 15 M, platine 30 M, diamant 50 M ; la SNEP ne délivre ni double
/// ni triple platine pour un single (0 = palier inexistant). Les EP suivent la grille des albums (hypothèse à confirmer).
const certThresholds21 = <String, List<int>>{
  'Single': [15000000, 30000000, 0, 0, 50000000],
  'EP': [50000, 100000, 200000, 300000, 500000],
  'Album': [50000, 100000, 200000, 300000, 500000],
};

class Cert21 {
  final String id, title, kind;
  final int units;
  final int level; // -1 : pas encore certifié, 0 à 4 : or à diamant
  const Cert21(this.id, this.title, this.kind, this.units, this.level);
  String? get levelId => level < 0 ? null : certLevels21[level];
  String get name => level < 0 ? 'Pas encore certifié' : certNames21[certLevels21[level]]!;
  int? get next {
    final th = certThresholds21[kind]!;
    for (var i = level + 1; i < th.length; i++) {
      if (th[i] > 0) return th[i];
    }
    return null;
  }
  String get plaque => 'assets/awards/plaque_${levelId ?? 'vide'}.svg';
}

/// Écoutes cumulées d'un single : celles qu'affichent les plateformes (sortie et jours suivants, clip, playlists).
int _streams(J t) => (_n(t['L']) + _n(t['clipL']) + _n(t['plL'])).round();

/// Équivalences de la SNEP : 1 téléchargement de single = 150 streams ; 1 vente d'album ou d'EP = 1 500 streams.
const streamsPerSingleSale21 = 150, streamsPerAlbumSale21 = 1500;

int _level(String kind, int units) {
  final th = certThresholds21[kind]!;
  var lv = -1;
  for (var i = 0; i < th.length; i++) {
    if (th[i] > 0 && units >= th[i]) lv = i;
  }
  return lv;
}

/// Unités certifiables d'un single : équivalents-streams (écoutes + téléchargements × 150).
int singleUnits21(J s, J t) => (_n(t['sales'] ?? (_n(t['L']) * Reg21.singleSales)) * streamsPerSingleSale21 + _streams(t)).round();

/// Unités certifiables d'un EP ou d'un album : équivalents-ventes (ventes + streams ÷ 1 500).
int projectUnits21(J p) => (_n(p['sales']) + _n(p['L']) / streamsPerAlbumSale21).round();

/// Toutes les œuvres du joueur avec leur certification (la plus haute d'abord).
List<Cert21> certs21(J s) {
  final out = <Cert21>[
    for (final x in _l(s['disco']).map(_m))
      Cert21('${x['id']}', '${x['title']}', 'Single', singleUnits21(s, x), _level('Single', singleUnits21(s, x))),
    for (final p in _l(s['projects']).map(_m))
      Cert21('${p['id']}', '${p['title']}', p['type'] == 'EP' ? 'EP' : 'Album', projectUnits21(p), _level(p['type'] == 'EP' ? 'EP' : 'Album', projectUnits21(p))),
  ];
  out.sort((a, b) => b.level != a.level ? b.level.compareTo(a.level) : b.units.compareTo(a.units));
  return out;
}

int certCount21(J s) => certs21(s).where((c) => c.level >= 0).length;

// ---------------------------------------------------------------------------------------------------------------------
// Cérémonies
// ---------------------------------------------------------------------------------------------------------------------

class AwardCat21 {
  final String id, n;
  const AwardCat21(this.id, this.n);
}

class Ceremony21 {
  final String id, n, place;
  final int week, prestige;
  final List<AwardCat21> cats;
  const Ceremony21(this.id, this.n, this.place, this.week, this.prestige, this.cats);
  String get trophy => 'assets/awards/trophee_$id.svg';
  /// Seuils de score (provisoires) : nomination puis victoire.
  double get nominateAt => 44.0 + 5 * prestige;
  double get winAt => 58.0 + 6 * prestige;
}

const ceremonies21 = <Ceremony21>[
  Ceremony21('revelation', 'Coupe Révélation', 'Halle des Griots, Ndolo', 43, 1, [AwardCat21('rev', "Révélation de l'année"), AwardCat21('emergent', 'Meilleur artiste émergent')]),
  Ceremony21('rue', 'Prix de la Rue', 'Carrefour de Mabaya', 45, 2,
      [AwardCat21('live', 'Meilleure performance live'), AwardCat21('feat', 'Meilleur featuring'), AwardCat21('public', 'Récompense du public')]),
  Ceremony21('grandprix', 'Grand Prix du Rap', 'Théâtre de Lumbé', 47, 3,
      [AwardCat21('single', "Single de l'année"), AwardCat21('projet', 'Meilleur projet rap'), AwardCat21('clip', 'Meilleur clip')]),
  Ceremony21('bakoma', 'Trophées de Bakoma', 'Stade de Lumbé', 52, 4,
      [AwardCat21('artiste', "Artiste de l'année"), AwardCat21('album', "Album de l'année"), AwardCat21('indep', 'Meilleur indépendant')]),
];

/// Semaine de l'année (1 à 52) et année de carrière (1, 2…) d'un jour de jeu.
int weekOf21(num day) => (((day - 1) % Reg21.daysPerYear) / 7).floor() + 1;
int yearOf21(num day) => ((day - 1) / Reg21.daysPerYear).floor() + 1;

/// Le temps du jeu se lit en semaines : 7 jours (lundi à dimanche) par semaine, 52 semaines par an.
const weekDays21 = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
String weekDay21(num day) => weekDays21[((day - 1) % 7).toInt()];

/// Date lisible : « S12 · Mer · An 1 ».
String dateLabel21(num day) => 'S${weekOf21(day)} · ${weekDay21(day)} · An ${yearOf21(day)}';

/// Prochaine cérémonie et nombre de jours avant elle.
(Ceremony21, int) nextCeremony21(J s) {
  final day = _n(s['day']).toInt();
  final w = weekOf21(day);
  final start = day - ((day - 1) % Reg21.daysPerYear);
  final done = _m(_m(s['aw'])['done']);
  final y = yearOf21(day);
  for (final c in ceremonies21) {
    if (c.week >= w && done['$y-${c.id}'] == null) return (c, math.max(0, start + (c.week - 1) * 7 - day));
  }
  final c = ceremonies21.first;
  return (c, start + Reg21.daysPerYear + (c.week - 1) * 7 - day);
}

/// Jury : variation déterministe de −10 à +10 (même partie, même résultat).
double _jury(J s, String key) {
  var h = 7;
  for (final u in '$key${_n(s['seed'])}${yearOf21(_n(s['day']))}'.codeUnits) {
    h = (h * 31 + u) % 1000003; // reste petit : même résultat sur mobile, web et tests
  }
  return (h % 2001) / 100 - 10;
}

double _commercial(J s) {
  final tot = _l(s['disco']).map(_m).fold<num>(0, (a, t) => a + _n(t['L']) + _n(t['clipL'])) + _l(s['projects']).map(_m).fold<num>(0, (a, p) => a + _n(p['L']));
  return math.min(100, math.log(tot + 1) / math.ln10 * 15).toDouble();
}

/// Score R17 (provisoire) : 0,35 qualité + 0,25 résultats commerciaux + 0,20 impact + 0,10 popularité (plafonnée à 80) + 0,10 jury.
/// Renvoie null si le joueur n'est pas éligible à la catégorie.
double? awardScore21(J s, Ceremony21 c, AwardCat21 cat) {
  final disco = _l(s['disco']).map(_m).toList();
  final projects = _l(s['projects']).map(_m).toList();
  final bestQ = disco.fold<num>(0, (a, t) => math.max(a, _n(t['Q'])));
  final pop = math.min(80, _n(s['pop'])).toDouble();
  final impact = math.min(100, _n(s['rep']) * 1.2).toDouble();
  final base = 0.35 * bestQ + 0.25 * _commercial(s) + 0.20 * impact + 0.10 * pop + _jury(s, '${c.id}-${cat.id}');
  switch (cat.id) {
    case 'rev':
      return yearOf21(_n(s['day'])) <= 1 && disco.isNotEmpty ? base + 4 : null;
    case 'emergent':
      return _n(s['rank']) <= 3 && disco.isNotEmpty ? base : null;
    case 'live':
      return _n(s['shows']) >= 3 ? base * 0.8 + math.min(25, _n(s['shows']) * 2) : null;
    case 'feat':
      return disco.any((t) => _l(t['feats']).isNotEmpty) ? base : null;
    case 'public':
      return disco.isNotEmpty ? 0.6 * pop + 0.4 * math.min(100, _n(s['fans']) / 1000) + 20 + _jury(s, 'public') : null;
    case 'single':
      return disco.isNotEmpty ? 0.5 * bestQ + 0.5 * _commercial(s) + 0.1 * pop + _jury(s, 'single') : null;
    case 'projet':
      return projects.isNotEmpty ? base + 3 : null;
    case 'clip':
      return disco.any((t) => _m(t['clip'])['st'] == 'publie') ? base : null;
    case 'artiste':
      return disco.length >= 3 ? base : null;
    case 'album':
      return projects.any((p) => p['type'] != 'EP') ? base + 2 : null;
    case 'indep':
      return (s['signed'] == null || s['signed'] == 0) && disco.isNotEmpty ? base : null;
  }
  return null;
}

/// Résultats d'une cérémonie : 'win', 'nom' ou null (non nommé) par catégorie, au plus 3 victoires.
/// [nominated] : nominations figées à la semaine 41 (clés « cérémonie-catégorie ») ; null = calcul direct.
Map<String, String?> ceremonyResults21(J s, Ceremony21 c, [Set<String>? nominated]) {
  final out = <String, String?>{};
  var wins = 0;
  for (final cat in c.cats) {
    final sc = awardScore21(s, c, cat);
    final isNom = nominated != null ? nominated.contains('${c.id}-${cat.id}') : (sc != null && sc >= c.nominateAt);
    if (sc == null || !isNom) {
      out[cat.id] = null;
    } else if (sc >= c.winAt && wins < 3) {
      out[cat.id] = 'win';
      wins++;
    } else {
      out[cat.id] = 'nom';
    }
  }
  return out;
}

/// Semaine d'annonce des nominations de l'année.
const nominationsWeek21 = 41;

/// Nominations calculées (clés « cérémonie-catégorie ») à partir de l'état actuel.
List<(Ceremony21, AwardCat21)> nominations21(J s) => [
      for (final c in ceremonies21)
        for (final cat in c.cats)
          if ((awardScore21(s, c, cat) ?? -1) >= c.nominateAt) (c, cat),
    ];

/// Nominations figées de l'année en cours (null si pas encore annoncées).
Set<String>? frozenNominations21(J s) {
  final y = yearOf21(_n(s['day']));
  final f = _m(_m(s['aw'])['nom'])['$y'];
  return f is List ? f.map((e) => '$e').toSet() : null;
}

/// Palmarès enregistré (aw.hist) : victoires et nominations.
List<J> awardHistory21(J s) => _l(_m(s['aw'])['hist']).map(_m).toList();
int awardWins21(J s) => awardHistory21(s).where((h) => h['res'] == 'win').length;
int awardNoms21(J s) => awardHistory21(s).where((h) => h['res'] == 'nom').length;
