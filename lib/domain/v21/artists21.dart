import 'dart:convert';

/// Annuaire des artistes de l'univers (assets/data/artistes-demo.json) : 1 000 fiches fictives de démonstration.
/// Lecture seule : aucune règle de jeu ici, uniquement le modèle, la recherche, les filtres et le tri de l'annuaire.
class Artist21 {
  final String id, nom, palier, genre, sousGenre, ville, statut, tendance;
  final String? label, labelDirige, certif;
  final int popularite, talent, rang, ecoutes7j, fans, titres, albums;
  final double indice;
  final int? managerNiveau;
  final List<String> allies, rivaux;
  const Artist21({
    required this.id,
    required this.nom,
    required this.palier,
    required this.genre,
    required this.sousGenre,
    required this.ville,
    required this.statut,
    required this.tendance,
    required this.label,
    required this.labelDirige,
    required this.certif,
    required this.popularite,
    required this.talent,
    required this.rang,
    required this.ecoutes7j,
    required this.fans,
    required this.titres,
    required this.albums,
    required this.indice,
    required this.managerNiveau,
    required this.allies,
    required this.rivaux,
  });

  factory Artist21.fromJson(Map<String, dynamic> j) => Artist21(
        id: j['id'] as String,
        nom: j['nom'] as String,
        palier: j['palier'] as String,
        genre: j['genre'] as String,
        sousGenre: (j['sous_genre'] ?? '') as String,
        ville: j['ville'] as String,
        statut: j['statut'] as String,
        tendance: (j['tendance'] ?? 'stable') as String,
        label: j['label'] as String?,
        labelDirige: j['label_dirige'] as String?,
        certif: j['certif'] as String?,
        popularite: (j['popularite'] as num).toInt(),
        talent: (j['talent'] as num? ?? 40).toInt(),
        rang: (j['rang_global'] as num).toInt(),
        ecoutes7j: (j['ecoutes_7j'] as num).toInt(),
        fans: (j['fans'] as num).toInt(),
        titres: (j['titres'] as num? ?? 0).toInt(),
        albums: (j['albums'] as num? ?? 0).toInt(),
        indice: (j['indice_global'] as num? ?? 0).toDouble(),
        managerNiveau: (j['manager_niveau'] as num?)?.toInt(),
        allies: List<String>.from(j['allies'] as List? ?? const []),
        rivaux: List<String>.from(j['rivaux'] as List? ?? const []),
      );
}

/// Annuaire chargé : artistes triés par rang global et noms des labels.
class Directory21 {
  final List<Artist21> artists;
  final Map<String, String> labels;
  final Map<String, Artist21> _byId;
  Directory21(this.artists, this.labels) : _byId = {for (final a in artists) a.id: a};

  Artist21? byId(String id) => _byId[id];
  List<String> get genres => (artists.map((a) => a.genre).toSet().toList()..sort());
}

Directory21 parseDirectory21(String source) {
  final j = jsonDecode(source) as Map<String, dynamic>;
  final list = [for (final a in j['artistes'] as List) Artist21.fromJson(a as Map<String, dynamic>)]..sort((a, b) => a.rang.compareTo(b.rang));
  return Directory21(list, Map<String, String>.from(j['labels'] as Map));
}

const directoryStatuses21 = <String, String>{
  'tous': 'Tous',
  'signé': 'Signés',
  'indépendant': 'Indépendants',
  'émergent': 'Émergents',
  'en déclin': 'En déclin',
  'en pause': 'En pause',
};

const directorySorts21 = <String, String>{'rang': 'Rang', 'pop': 'Popularité', 'fans': 'Fans', 'hausse': 'En hausse'};

String _fold(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[àâä]'), 'a')
    .replaceAll(RegExp('[îï]'), 'i')
    .replaceAll(RegExp('[ôö]'), 'o')
    .replaceAll(RegExp('[ûüù]'), 'u')
    .replaceAll('ç', 'c');

/// Filtre et trie l'annuaire. [q] : recherche sans accent ni casse dans le nom, le genre, la ville et le label.
List<Artist21> filterArtists21(
  Directory21 d, {
  String q = '',
  String statut = 'tous',
  String? genre,
  String? palier,
  String tri = 'rang',
}) {
  final needle = _fold(q.trim());
  final out = d.artists.where((a) {
    if (statut != 'tous' && a.statut != statut) return false;
    if (genre != null && a.genre != genre) return false;
    if (palier != null && a.palier != palier) return false;
    if (needle.isEmpty) return true;
    final hay = _fold('${a.nom} ${a.genre} ${a.sousGenre} ${a.ville} ${a.label == null ? '' : d.labels[a.label] ?? a.label}');
    return hay.contains(needle);
  }).toList();
  switch (tri) {
    case 'pop':
      out.sort((a, b) => b.popularite != a.popularite ? b.popularite.compareTo(a.popularite) : a.rang.compareTo(b.rang));
    case 'fans':
      out.sort((a, b) => b.fans != a.fans ? b.fans.compareTo(a.fans) : a.rang.compareTo(b.rang));
    case 'hausse':
      int w(Artist21 a) => a.tendance == 'en hausse' ? 0 : (a.tendance == 'stable' ? 1 : 2);
      out.sort((a, b) => w(a) != w(b) ? w(a).compareTo(w(b)) : a.rang.compareTo(b.rang));
    default:
      out.sort((a, b) => a.rang.compareTo(b.rang));
  }
  return out;
}

/// Clé du rival interactif (Reg21.rivals) pour un nom d'artiste, sinon null : seuls ceux-là ont discussion, provocation et battle.
String? rivalKeyOf21(String nom) => switch (nom) {
      'Zaki Mbela' => 'zaki',
      'Madame Orage' => 'orage',
      _ => null,
    };
