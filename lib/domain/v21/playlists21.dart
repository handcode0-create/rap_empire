// Playlists éditoriales d'Ondéa : chaque playlist a un curateur (personnage du cast, identité fixe).
// Le joueur propose un single ; le curateur l'écoute ; le score de la proposition est comparé à un seuil.
// Accepté : le titre entre 14 jours dans la playlist et gagne des écoutes chaque jour. Refusé : retour possible après 7 jours.
// Valeurs provisoires (D-08).
import 'dart:math' as math;
import 'reg21.dart';

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map ? x as J : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

class Playlist21 {
  final String id, n, curator, curatorName, desc, cover;
  final List<String> styles; // styles musicaux attendus (vide : tous)
  final List<String> artists; // artistes de l'univers déjà présents dans la playlist
  final int minQ, followers;
  final String quote; // réplique d'accueil du curateur
  const Playlist21(this.id, this.n, this.curator, this.curatorName, this.desc, this.cover, this.styles, this.artists, this.minQ, this.followers, this.quote);
  /// Seuil à atteindre pour entrer dans la playlist.
  int get threshold => minQ + 8;
}

const playlists21 = <Playlist21>[
  Playlist21('drill', 'Drill de Bakoma', 'sadia', 'Sadia Kouamé', 'Le son sombre des quartiers : basses lourdes, flows serrés.', 'assets/klipo/thumbs/T012.svg',
      ['drill', 'trap'], ['Kaïra Nox', "K-Zer d'Mabaya", 'Zaki Mbela', 'Tamsir Koffi'], 60, 180000,
      '« Ici, chaque titre doit cogner dès la première mesure. Fais-moi écouter ce que tu as. »'),
  Playlist21('nuits', 'Nuits de Lumbé', 'malik', 'Malik Ebo', 'Mélodies de fin de soirée, refrains qui restent.', 'assets/klipo/thumbs/T013.svg',
      ['coupe', 'trap'], ['Naya Rêve', 'Nadia Kolo', 'Sôlo Vance', 'Bako Flux'], 55, 140000,
      '« La nuit, les gens veulent une mélodie qu\'ils fredonnent en rentrant. Tu l\'as, cette mélodie ? »'),
  Playlist21('afro', 'Afro-soul Sélène', 'yele', 'Yélé Dossou', 'Voix chaudes, textes qui parlent du cœur et de la terre.', 'assets/klipo/thumbs/T006.svg',
      ['conscient', 'coupe'], ['Ayana Dembé', 'Lazuli', 'Tito Brume', 'Yaya Cendre'], 58, 120000,
      '« Je cherche une âme, pas un tube. Raconte-moi quelque chose de vrai. »'),
  Playlist21('talents', 'Nouveaux talents', 'tidjane', 'Tidjane Bah', 'Les noms de demain, choisis chaque semaine.', 'assets/klipo/thumbs/T021.svg',
      [], ['Naya Rêve', 'Tamsir Koffi', "K-Zer d'Mabaya", 'Ayana Dembé'], 45, 90000,
      '« Personne ne te connaît encore ? Parfait, c\'est mon rayon. Montre-moi pourquoi on devrait t\'écouter. »'),
];

Playlist21? playlist21(String? id) {
  for (final p in playlists21) {
    if (p.id == id) return p;
  }
  return null;
}

/// Façons de présenter son titre au curateur.
const pitchApproaches21 = <String, ({String n, String c, int cost})>{
  'son': (n: 'Laisser parler le son', c: 'Aucun argument : seule la musique compte.', cost: 0),
  'histoire': (n: "Raconter l'histoire du titre", c: 'Le charisme compte (jusqu\'à +15 au score).', cost: 0),
  'promo': (n: 'Proposer une mise en avant commune', c: '5 000 cauris de promotion partagée : +12 au score.', cost: 5000),
};

const playlistDays21 = 14, playlistCooldown21 = 7, playlistDailyRate21 = 0.02;

/// Jury du curateur : variation déterministe de −8 à +8 selon la playlist, le titre et le jour.
double _mood(String key) {
  var h = 7;
  for (final u in key.codeUnits) {
    h = (h * 31 + u) % 1000003;
  }
  return (h % 1601) / 100 - 8;
}

/// Décomposition du score d'une proposition (affichée avant de décider ; le jury reste incertain).
({double q, double fit, double pop, double approach, double jury, double total}) pitchScore21(J s, Playlist21 p, J track, String approach) {
  final style = '${_m(s['p'])['main']}';
  final q = _n(track['Q']) * 0.55;
  final fit = p.styles.isEmpty ? (_n(s['rank']) <= 3 ? 10.0 : 4.0) : (p.styles.contains(style) ? 15.0 : 0.0);
  final pop = math.min(40, _n(s['pop'])) * 0.4;
  final ap = approach == 'histoire' ? math.min(15, _n(_m(s['sk'])['cha']) * 0.5).toDouble() : approach == 'promo' ? 12.0 : 0.0;
  final jury = _mood('${p.id}|${track['id']}|${_n(s['day'])}');
  return (q: q, fit: fit, pop: pop.toDouble(), approach: ap, jury: jury, total: q + fit + pop + ap + jury);
}

/// État des playlists : placements actifs, attentes après un refus, dernière proposition.
J playlistState21(J s) => _m(s['pl']);

/// Placement actif d'une playlist (titre, jusqu'à quel jour), ou null.
J? placement21(J s, String plId) {
  final x = _m(playlistState21(s)['plc'])[plId];
  return x is Map && _n(x['until']) > _n(s['day']) ? x as J : null;
}

/// Jour à partir duquel on peut reproposer un titre (null : tout de suite).
int? cooldown21(J s, String plId) {
  final c = _m(playlistState21(s)['cool'])[plId];
  return c != null && _n(c) > _n(s['day']) ? _n(c).toInt() : null;
}

/// Écoutes gagnées par jour dans une playlist.
int playlistDaily21(Playlist21 p, J track) => (p.followers * playlistDailyRate21 * _n(track['Q']) / 100).round();

/// Titres du joueur placés aujourd'hui (id de playlist → id du titre).
Map<String, String> placedTracks21(J s) => {
      for (final p in playlists21)
        if (placement21(s, p.id) != null) p.id: '${placement21(s, p.id)!['tid']}',
    };

/// Singles sortis du joueur, du plus récent au plus ancien.
List<J> pitchableTracks21(J s) => _l(s['disco']).map(_m).toList();
