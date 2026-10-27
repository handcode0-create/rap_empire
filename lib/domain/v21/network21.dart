// ignore_for_file: avoid_dynamic_calls
import 'reg21.dart' show J;

/// Espace Réseau v21 (planches 21-N0 à 21-N8, engine21.js « MEDIA », « KLIPO ») : marketing Local / National / Global,
/// médias fictifs, partenaire visible en concert, 50 vidéos Klipo, clips du joueur, public selon le remplissage.
/// [VALIDÉ par Smith le 20/10/2026 : rendus de l'artefact] Prix, durées et effets restent provisoires (D-08).

class Media21 {
  final String id, n, lvl, kind;
  final int c, d, rank, fans;
  final Map<String, num> geo;
  final double pop, boost, spon;
  final int col;
  const Media21(this.id, this.n, this.lvl, this.kind, this.c, this.d, this.rank, this.geo, this.fans, this.pop, this.boost, this.spon, this.col);
}

/// Achat de 15 000 cauris ou plus : confirmation obligatoire (I-08).
const mediaConfirmAt21 = 15000;

const media21 = <String, Media21>{
  'lagune': Media21('lagune', 'Radio Lagune FM', 'local', 'Radio', 5000, 7, 1, {'bakoma': 0.8}, 15, 0.3, 0.05, 0.04, 0xFF3CD6F2),
  'affiches': Media21('affiches', 'Affiches Ndolo', 'local', 'Affichage urbain', 3000, 7, 1, {'bakoma': 0.5}, 8, 0.2, 0.03, 0.03, 0xFFFFC83D),
  'bktv': Media21('bktv', 'Bakoma TV', 'national', 'Télévision', 40000, 7, 3, {'bakoma': 1.2, 'portambre': 1, 'selene': 1}, 90, 0.8, 0.15, 0.1, 0xFFF43F9D),
  'solomag': Media21('solomag', 'Sôlo Mag', 'national', 'Presse', 15000, 14, 3, {'portambre': 0.5, 'selene': 0.5}, 30, 0.3, 0.06, 0.05, 0xFF8B5CF6),
  'spot': Media21('spot', 'Ondéa Spotlight', 'national', 'Plateforme', 20000, 7, 3, {'bakoma': 0.4, 'portambre': 0.4, 'selene': 0.4}, 40, 0.4, 0.2, 0, 0xFF3CD6F2),
  'tamtv': Media21('tamtv', 'Tamarel Live TV', 'global', 'Télévision', 150000, 7, 5, {'tamarel': 2}, 300, 1, 0.18, 0.12, 0xFFFF6BB8),
  'korradio': Media21('korradio', 'Korvane Beats Radio', 'global', 'Radio', 90000, 7, 5, {'korvane': 1.6}, 180, 0.6, 0.1, 0.08, 0xFF3DDC97),
  'aldwave': Media21('aldwave', 'Aldéra Wave', 'global', 'Média web', 120000, 7, 5, {'aldera': 1.8}, 220, 0.8, 0.14, 0.1, 0xFFFFC83D),
};
const mediaOrder21 = ['lagune', 'affiches', 'bktv', 'solomag', 'spot', 'tamtv', 'korradio', 'aldwave'];
const mediaLevelName21 = {'local': 'Local', 'national': 'National', 'global': 'Global'};
const geoName21 = {'bakoma': 'Bakoma', 'portambre': 'Port-Ambre', 'selene': 'Sélène', 'tamarel': 'Tamarel', 'korvane': 'Korvane', 'aldera': 'Aldéra'};

/// Klipo : 50 vidéos de l'univers (données de démonstration : artistes fictifs, vues d'univers, pas des écoutes du joueur).
const klipo21 = <Map<String, Object>>[
  {'id': 'K001', 't': 'Minuit Doré', 'a': 'Kaïra Nox', 'k': 'Clip officiel', 'du': '3:48', 'v': 41200000, 'img': 'assets/klipo/thumbs/T001.svg', 'age': 2},
  {'id': 'K002', 't': 'Pluie d\'Argent', 'a': 'Zaki Mbela', 'k': 'Clip officiel', 'du': '3:21', 'v': 36800000, 'img': 'assets/klipo/thumbs/T002.svg', 'age': 7},
  {'id': 'K003', 't': 'Orage Intérieur', 'a': 'Madame Orage', 'k': 'Clip officiel', 'du': '4:02', 'v': 30100000, 'img': 'assets/klipo/thumbs/T003.svg', 'age': 12},
  {'id': 'K004', 't': 'Brume sur Ndo', 'a': 'Tito Brume', 'k': 'Clip officiel', 'du': '3:12', 'v': 24500000, 'img': 'assets/klipo/thumbs/T004.svg', 'age': 17},
  {'id': 'K005', 't': 'Verre Bleu', 'a': 'Lazuli', 'k': 'Clip officiel', 'du': '3:35', 'v': 22900000, 'img': 'assets/klipo/thumbs/T005.svg', 'age': 22},
  {'id': 'K006', 't': 'Rives Lentes', 'a': 'Sôlo Vance', 'k': 'Clip officiel', 'du': '3:58', 'v': 19300000, 'img': 'assets/klipo/thumbs/T006.svg', 'age': 27},
  {'id': 'K007', 't': 'Douce Lagune', 'a': 'Nadia Kolo', 'k': 'Clip officiel', 'du': '3:27', 'v': 17700000, 'img': 'assets/klipo/thumbs/T007.svg', 'age': 32},
  {'id': 'K008', 't': 'Flux Tendu', 'a': 'Bako Flux', 'k': 'Visualizer', 'du': '2:54', 'v': 15200000, 'img': 'assets/klipo/thumbs/T008.svg', 'age': 37},
  {'id': 'K009', 't': 'Sable Chaud', 'a': 'Dr. Sable', 'k': 'Clip officiel', 'du': '3:09', 'v': 14100000, 'img': 'assets/klipo/thumbs/T009.svg', 'age': 2},
  {'id': 'K010', 't': 'Cendres', 'a': 'Yaya Cendre', 'k': 'Clip officiel', 'du': '3:44', 'v': 12800000, 'img': 'assets/klipo/thumbs/T010.svg', 'age': 7},
  {'id': 'K011', 't': 'Ambre, live au stade', 'a': 'Kaïra Nox', 'k': 'Live', 'du': '6:12', 'v': 11600000, 'img': 'assets/klipo/thumbs/T011.svg', 'age': 12},
  {'id': 'K012', 't': 'Freestyle du carrefour', 'a': 'K-Zer d\'Mabaya', 'k': 'Freestyle', 'du': '2:31', 'v': 9400000, 'img': 'assets/klipo/thumbs/T012.svg', 'age': 17},
  {'id': 'K013', 't': 'Une nuit au Studio Kôrô', 'a': 'DJ Kôrô', 'k': 'Coulisses', 'du': '8:40', 'v': 8800000, 'img': 'assets/klipo/thumbs/T013.svg', 'age': 22},
  {'id': 'K014', 't': 'Session afro-soul', 'a': 'Ayana Dembé', 'k': 'Live', 'du': '5:05', 'v': 8100000, 'img': 'assets/klipo/thumbs/T014.svg', 'age': 27},
  {'id': 'K015', 't': 'Ndolo by night', 'a': 'Zaki Mbela', 'k': 'Visualizer', 'du': '3:02', 'v': 7600000, 'img': 'assets/klipo/thumbs/T015.svg', 'age': 32},
  {'id': 'K016', 't': 'Finale des Quatre Quartiers', 'a': 'Coupe des Quatre Quartiers', 'k': 'Battle', 'du': '12:18', 'v': 7300000, 'img': 'assets/klipo/thumbs/T016.svg', 'age': 37},
  {'id': 'K017', 't': 'Lumbé Express', 'a': 'Bako Flux', 'k': 'Clip officiel', 'du': '3:16', 'v': 6900000, 'img': 'assets/klipo/thumbs/T017.svg', 'age': 2},
  {'id': 'K018', 't': 'Fils du port', 'a': 'Sôlo Vance', 'k': 'Clip officiel', 'du': '3:50', 'v': 6400000, 'img': 'assets/klipo/thumbs/T018.svg', 'age': 7},
  {'id': 'K019', 't': 'Kôtoro Bass', 'a': 'Dr. Sable', 'k': 'Clip officiel', 'du': '2:58', 'v': 6100000, 'img': 'assets/klipo/thumbs/T019.svg', 'age': 12},
  {'id': 'K020', 't': 'Reine de Mabaya', 'a': 'Madame Orage', 'k': 'Clip officiel', 'du': '3:33', 'v': 5800000, 'img': 'assets/klipo/thumbs/T020.svg', 'age': 17},
  {'id': 'K021', 't': 'Feu de brousse', 'a': 'Yaya Cendre', 'k': 'Visualizer', 'du': '3:20', 'v': 5300000, 'img': 'assets/klipo/thumbs/T021.svg', 'age': 22},
  {'id': 'K022', 't': 'Néon Lagune', 'a': 'Lazuli', 'k': 'Clip officiel', 'du': '3:41', 'v': 5000000, 'img': 'assets/klipo/thumbs/T022.svg', 'age': 27},
  {'id': 'K023', 't': 'Gbaka royal', 'a': 'Tito Brume', 'k': 'Clip officiel', 'du': '3:05', 'v': 4700000, 'img': 'assets/klipo/thumbs/T023.svg', 'age': 32},
  {'id': 'K024', 't': 'Cauris d\'or', 'a': 'Kaïra Nox', 'k': 'Clip officiel', 'du': '3:29', 'v': 4400000, 'img': 'assets/klipo/thumbs/T024.svg', 'age': 37},
  {'id': 'K025', 't': 'Sélène nocturne', 'a': 'Nadia Kolo', 'k': 'Live', 'du': '4:47', 'v': 4100000, 'img': 'assets/klipo/thumbs/T025.svg', 'age': 2},
  {'id': 'K026', 't': 'Ring de Kôtoro, demi-finale', 'a': 'Ring de Kôtoro', 'k': 'Battle', 'du': '10:02', 'v': 3900000, 'img': 'assets/klipo/thumbs/T026.svg', 'age': 7},
  {'id': 'K027', 't': 'Pont des Griots, live', 'a': 'Ayana Dembé', 'k': 'Live', 'du': '5:36', 'v': 3600000, 'img': 'assets/klipo/thumbs/T027.svg', 'age': 12},
  {'id': 'K028', 't': 'Marée haute', 'a': 'Zaki Mbela', 'k': 'Clip officiel', 'du': '3:14', 'v': 3300000, 'img': 'assets/klipo/thumbs/T028.svg', 'age': 17},
  {'id': 'K029', 't': 'Silence radio', 'a': 'Madame Orage', 'k': 'Visualizer', 'du': '3:00', 'v': 3100000, 'img': 'assets/klipo/thumbs/T029.svg', 'age': 22},
  {'id': 'K030', 't': 'Tamarel calling', 'a': 'Kaïra Nox', 'k': 'Clip officiel', 'du': '3:52', 'v': 2900000, 'img': 'assets/klipo/thumbs/T030.svg', 'age': 27},
  {'id': 'K031', 't': 'Korvane froid', 'a': 'Tito Brume', 'k': 'Clip officiel', 'du': '3:26', 'v': 2700000, 'img': 'assets/klipo/thumbs/T031.svg', 'age': 32},
  {'id': 'K032', 't': 'Îles d\'Aldéra', 'a': 'Lazuli', 'k': 'Clip officiel', 'du': '4:10', 'v': 2500000, 'img': 'assets/klipo/thumbs/T032.svg', 'age': 37},
  {'id': 'K033', 't': 'Béton tendre', 'a': 'Bako Flux', 'k': 'Freestyle', 'du': '2:22', 'v': 2300000, 'img': 'assets/klipo/thumbs/T033.svg', 'age': 2},
  {'id': 'K034', 't': 'Premier jet', 'a': 'Sôlo Vance', 'k': 'Freestyle', 'du': '2:45', 'v': 2100000, 'img': 'assets/klipo/thumbs/T034.svg', 'age': 7},
  {'id': 'K035', 't': 'Lettre à Ndolo', 'a': 'Yaya Cendre', 'k': 'Clip officiel', 'du': '4:18', 'v': 1900000, 'img': 'assets/klipo/thumbs/T035.svg', 'age': 12},
  {'id': 'K036', 't': 'Coulisses du Parvis', 'a': 'DJ Kôrô', 'k': 'Coulisses', 'du': '7:14', 'v': 1750000, 'img': 'assets/klipo/thumbs/T036.svg', 'age': 17},
  {'id': 'K037', 't': 'Danse du sable', 'a': 'Dr. Sable', 'k': 'Clip officiel', 'du': '3:11', 'v': 1600000, 'img': 'assets/klipo/thumbs/T037.svg', 'age': 22},
  {'id': 'K038', 't': 'Vague argentée', 'a': 'Nadia Kolo', 'k': 'Clip officiel', 'du': '3:38', 'v': 1450000, 'img': 'assets/klipo/thumbs/T038.svg', 'age': 27},
  {'id': 'K039', 't': 'Corps céleste', 'a': 'Ayana Dembé', 'k': 'Clip officiel', 'du': '4:01', 'v': 1300000, 'img': 'assets/klipo/thumbs/T039.svg', 'age': 32},
  {'id': 'K040', 't': 'Rue lumière', 'a': 'K-Zer d\'Mabaya', 'k': 'Clip officiel', 'du': '3:07', 'v': 1180000, 'img': 'assets/klipo/thumbs/T040.svg', 'age': 37},
  {'id': 'K041', 't': 'Trône de verre', 'a': 'Kaïra Nox', 'k': 'Visualizer', 'du': '3:24', 'v': 1060000, 'img': 'assets/klipo/thumbs/T041.svg', 'age': 2},
  {'id': 'K042', 't': 'Halle des Griots, live', 'a': 'Madame Orage', 'k': 'Live', 'du': '6:30', 'v': 960000, 'img': 'assets/klipo/thumbs/T042.svg', 'age': 7},
  {'id': 'K043', 't': 'Sur la lagune', 'a': 'Tito Brume', 'k': 'Coulisses', 'du': '9:12', 'v': 870000, 'img': 'assets/klipo/thumbs/T043.svg', 'age': 12},
  {'id': 'K044', 't': 'Ciel de Kôtoro', 'a': 'Lazuli', 'k': 'Visualizer', 'du': '3:19', 'v': 790000, 'img': 'assets/klipo/thumbs/T044.svg', 'age': 17},
  {'id': 'K045', 't': 'Huit mille voix', 'a': 'Zaki Mbela', 'k': 'Live', 'du': '5:48', 'v': 720000, 'img': 'assets/klipo/thumbs/T045.svg', 'age': 22},
  {'id': 'K046', 't': 'Clé de sol', 'a': 'Nadia Kolo', 'k': 'Clip officiel', 'du': '3:03', 'v': 650000, 'img': 'assets/klipo/thumbs/T046.svg', 'age': 27},
  {'id': 'K047', 't': 'Dernier gbaka', 'a': 'Bako Flux', 'k': 'Clip officiel', 'du': '3:27', 'v': 590000, 'img': 'assets/klipo/thumbs/T047.svg', 'age': 32},
  {'id': 'K048', 't': 'Carnaval des Sables, live', 'a': 'Dr. Sable', 'k': 'Live', 'du': '7:02', 'v': 530000, 'img': 'assets/klipo/thumbs/T048.svg', 'age': 37},
  {'id': 'K049', 't': 'Mains levées', 'a': 'Yaya Cendre', 'k': 'Freestyle', 'du': '2:39', 'v': 480000, 'img': 'assets/klipo/thumbs/T049.svg', 'age': 2},
  {'id': 'K050', 't': 'Ndo City, remix', 'a': 'DJ Kôrô', 'k': 'Visualizer', 'du': '3:45', 'v': 430000, 'img': 'assets/klipo/thumbs/T050.svg', 'age': 7}
];

/// Miniatures des clips du joueur : assets/klipo/mine/M1 à M8.svg.
const myThumbs21 = 8;

/// Décors illustrés des miniatures de clips (0 à 11) ; l'indice 12 est la pochette du titre. Purement visuel.
const clipScenes21 = 12;

num _n(dynamic x) => (x ?? 0) as num;
int _r(num x) => (x + 0.5).floor();
J _mk(J s) => s['mk'] is Map ? s['mk'] as J : <String, dynamic>{};

/// État initial de l'espace Réseau (ajouté par norm21 aux anciennes sauvegardes).
J initMk21() => {'on': <dynamic>[], 'ask': null, 'tot': 0, 'n': 0};

/// Campagnes encore actives aujourd'hui.
List<J> mkActive21(J s) => ((_mk(s)['on'] as List?) ?? const []).map((x) => x as J).where((c) => _n(c['until']) > _n(s['day'])).toList();

/// Bonus d'écoutes des sorties pendant les campagnes (somme des bonus).
double mkBoost21(J s) => mkActive21(s).fold<double>(0, (a, c) => a + (media21[c['id']]?.boost ?? 0));

/// Média partenaire affiché en concert : celui qui offre le plus fort bonus de cachet.
String? mkSponsor21(J s) {
  String? b;
  for (final c in mkActive21(s)) {
    final m = media21[c['id']];
    if (m == null || m.spon == 0) continue;
    if (b == null || m.spon > media21[b]!.spon) b = m.id;
  }
  return b;
}

/// Code d'erreur d'un lancement de campagne, ou null.
String? mkCheck21(J s, String id) {
  final m = media21[id];
  if (m == null) return 'inconnu';
  if (_n(s['rank']) < m.rank) return 'rang';
  if (mkActive21(s).any((c) => c['id'] == id)) return 'campagne';
  if (_n(s['cash']) < m.c) return 'cash';
  return null;
}

double _r1(num x) => (x * 10).round() / 10;

/// Notoriété : Local = Bakoma ; National = Bakoma, Port-Ambre, Sélène ; Global = les 6 villes.
({double local, double national, double global}) notoriety21(J s) {
  final g = (s['geo'] as Map?) ?? const {};
  num v(String k) => _n(g[k]);
  return (
    local: v('bakoma').toDouble(),
    national: _r1((v('bakoma') + v('portambre') + v('selene')) / 3),
    global: _r1((v('bakoma') + v('portambre') + v('selene') + v('tamarel') + v('korvane') + v('aldera')) / 6),
  );
}

/// Clips publiés du joueur (ordre du catalogue, le plus récent d'abord).
List<J> myClips21(J s) => ((s['disco'] as List?) ?? const []).map((x) => x as J).where((t) => t['clip'] is Map && (t['clip'] as Map)['st'] == 'publie').toList();

/// Statistiques d'un clip : vues = 2 par écoute apportée par le clip ; j'aime, commentaires, rétention = estimations de démonstration.
/// Miniature d'un clip : le choix du joueur (0 à 7 : scènes, 8 : pochette du titre), sinon l'ambiance d'office selon l'ordre du clip.
int clipThumb21(Map t, int i) {
  final c = t['clip'];
  final v = c is Map ? c['thumb'] : null;
  return v is int && v >= 0 && v <= clipScenes21 ? v : i % clipScenes21;
}

({int v, int lk, int cm, int ret, String img}) clipStats21(J t, int i) {
  final v = _r(_n(t['clipL']) * 2);
  final r = 0.42 + (_n(t['vir']).toInt() % 23) / 100;
  return (v: v, lk: _r(v * (0.05 + _n(t['Q']) / 2000)), cm: _r(v * 0.006), ret: _r(r * 100), img: 'assets/klipo/mine/M${(i % myThumbs21) + 1}.svg');
}

/// Densité du public (1 à 4) selon le taux de remplissage de la salle.
int crowdLevel21(num f) => f < 0.25 ? 1 : f < 0.5 ? 2 : f < 0.8 ? 3 : 4;
String crowdAsset21(num f) => 'assets/klipo/crowd/crowd_${crowdLevel21(f)}.svg';

/// Vues en format court : 41,2 M, 960 k.
String fmtK21(num v) {
  if (v >= 1e6) {
    final d = (v / 1e5).round();
    return '${d % 10 == 0 ? '${d ~/ 10}' : '${d ~/ 10},${d % 10}'} M';
  }
  return v >= 1e3 ? '${(v / 1e3).round()} k' : '${v.round()}';
}
