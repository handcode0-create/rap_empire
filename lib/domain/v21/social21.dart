import 'reg21.dart' show J;

/// Réseaux sociaux fictifs v21 [VALIDÉ par Smith le 20/10/2026 : réseaux fictifs jouables].
/// Trois applis de l'univers de Bakoma : Lueur (photos et stories), Bakoz (vidéos courtes), Griot (messages et fils).
/// Publier coûte du temps et de l'énergie, rapporte abonnés, fans et popularité ; une vidéo peut devenir virale,
/// un clash peut tourner à la polémique. Toutes les valeurs sont provisoires (à calibrer, D-08). Aucun réseau réel.

class SocialNet21 {
  final String id, n, kind, tagline;
  final double share; // abonnés de départ = fans × share
  final int col;
  const SocialNet21(this.id, this.n, this.kind, this.tagline, this.share, this.col);
}

const socialNets21 = <String, SocialNet21>{
  'lueur': SocialNet21('lueur', 'Lueur', 'Photos et stories', 'Ton image, ton style, tes coulisses.', 0.5, 0xFFFFC83D),
  'bakoz': SocialNet21('bakoz', 'Bakoz', 'Vidéos courtes', 'Trente secondes pour faire bouger Bakoma.', 0.35, 0xFFF43F9D),
  'griot': SocialNet21('griot', 'Griot', 'Messages et fils', 'Ce que tu dis circule dans toute la ville.', 0.25, 0xFF3CD6F2),
};
const socialOrder21 = ['lueur', 'bakoz', 'griot'];

/// Publications possibles. need : 'song' (un titre sorti), 'cur' (un titre en préparation), 'show' (une date jouée).
class PostType21 {
  final String id, net, n, d;
  final int h, e;
  final double reach, fanRate;
  final int pop;
  final String risk; // Faible, Moyen, Élevé (jamais de pourcentage de réussite isolé)
  final String? need;
  final int hype; // jours d'annonce : bonus de 20 % sur la prochaine sortie dans ce délai (règle existante)
  final bool viral, clash;
  const PostType21(this.id, this.net, this.n, this.d, this.h, this.e, this.reach, this.fanRate, this.pop, this.risk,
      {this.need, this.hype = 0, this.viral = false, this.clash = false});
}

const postTypes21 = <String, PostType21>{
  'photo': PostType21('photo', 'lueur', 'Photo de studio', 'Une photo en cabine, casque sur les oreilles.', 0, 5, 1.0, 0.020, 0, 'Faible'),
  'look': PostType21('look', 'lueur', 'Look du jour', 'Ta tenue équipée, prise dans les rues de Ndolo.', 0, 5, 1.1, 0.018, 1, 'Faible'),
  'coulisses': PostType21('coulisses', 'lueur', 'Coulisses de concert', 'La loge, la foule, le moment avant de monter.', 0, 5, 1.4, 0.025, 1, 'Faible', need: 'show'),
  'extrait': PostType21('extrait', 'bakoz', 'Extrait de ton dernier son', 'Quinze secondes du refrain, en boucle.', 1, 10, 1.3, 0.030, 1, 'Moyen', need: 'song', viral: true),
  'defi': PostType21('defi', 'bakoz', 'Défi de danse', 'Un pas à refaire sur ton son : le quartier relève le défi ou pas.', 1, 15, 1.0, 0.035, 1, 'Élevé', need: 'song', viral: true),
  'freestyle': PostType21('freestyle', 'bakoz', 'Freestyle de 30 secondes', 'Face caméra, sans instru, au carrefour.', 1, 10, 1.1, 0.028, 1, 'Moyen', viral: true),
  'annonce': PostType21('annonce', 'griot', 'Annonce de sortie', 'Date, titre, compte à rebours : la ville attend.', 0, 5, 0.9, 0.012, 0, 'Faible', need: 'cur', hype: 3),
  'merci': PostType21('merci', 'griot', 'Merci aux fans', 'Un message pour ceux qui étaient là au début.', 0, 5, 0.8, 0.015, 0, 'Faible'),
  'clash': PostType21('clash', 'griot', 'Répondre à un rival', 'Une pique publique : la ville choisit son camp.', 0, 10, 1.6, 0.030, 2, 'Élevé', clash: true),
};

/// Publications par jour, tous réseaux confondus.
const postsPerDay21 = 3;

const socialHandles21 = ['kiki_ndolo', 'lumbe.vibes', 'mabaya225', 'sosso.drill', 'tantie.awa', 'gbaka_life', 'koto.flow', 'zouzou.selene', 'ambre.port', 'dj_pikolo'];
const socialComments21 = [
  'Le refrain tourne dans ma tête depuis ce matin.',
  'Ndolo est derrière toi, frère.',
  'On veut la date à Lumbé !',
  'Ça c\'est du vrai, pas du copier-coller.',
  'Le son est lourd, la vidéo encore plus.',
  'Je partage dans tout le quartier.',
  'Tu montes, ça se voit.',
  'Le gbaka de 6 h écoute ça en boucle.',
  'Le look est propre !',
  'Il manque un featuring avec Ayana Dembé.',
];
const socialTrends21 = ['#NdoloDrill', '#GbakaChallenge', '#LumbéNights', '#SonDeMabaya', '#Kôtoro225', '#RivesDeSôlo', '#FreestyleDuCarrefour', '#ParvisLive'];

num _n(dynamic x) => (x ?? 0) as num;
int _r(num x) => (x + 0.5).floor();

/// État initial (ajouté par norm21 aux anciennes sauvegardes).
J initSocial21() => {'f': <String, dynamic>{}, 'posts': <dynamic>[], 'day': 0, 'today': 0, 'buzz': 0, 'tot': 0, 'viral': 0, 'polem': 0};

J _soc(J s) => s['soc'] is Map ? s['soc'] as J : initSocial21();

/// Abonnés d'un réseau : à partir des fans tant que le joueur n'a rien publié dessus.
int followers21(J s, String net) {
  final f = (_soc(s)['f'] as Map?)?[net];
  return f != null ? _n(f).toInt() : _r(_n(s['fans']) * (socialNets21[net]?.share ?? 0));
}

int followersTotal21(J s) => socialOrder21.fold(0, (a, k) => a + followers21(s, k));

/// Publications restantes aujourd'hui.
int postsLeft21(J s) {
  final so = _soc(s);
  return _n(so['day']) == _n(s['day']) ? (postsPerDay21 - _n(so['today']).toInt()).clamp(0, postsPerDay21).toInt() : postsPerDay21;
}

/// Buzz du moment (0 à 100), baisse chaque nuit.
int buzz21(J s) => _n(_soc(s)['buzz']).toInt();

/// Publications du joueur sur un réseau (la plus récente d'abord).
List<J> postsOf21(J s, String net) => ((_soc(s)['posts'] as List?) ?? const []).map((x) => x as J).where((p) => p['net'] == net).toList();

/// Condition manquante pour publier ce type, ou null.
String? postNeed21(J s, PostType21 t) {
  final disco = (s['disco'] as List?) ?? const [];
  if (t.need == 'song' && disco.isEmpty) return 'single';
  if (t.need == 'cur' && s['cur'] == null) return 'pasdetitre';
  if (t.need == 'show' && _n(s['shows']) < 1) return 'pasdeconcert';
  return null;
}

/// Portée estimée d'une publication (avant le hasard du jour : ± 30 %).
int reachEstimate21(J s, PostType21 t) => _r((followers21(s, t.net) * 0.3 + 60 + _n(s['pop']) * 20) * t.reach);

/// Texte de la publication, avec le titre concerné quand il y en a un.
String postText21(J s, PostType21 t) {
  final disco = (s['disco'] as List?) ?? const [];
  final last = disco.isEmpty ? null : (disco.first as Map)['title'];
  final cur = s['cur'] is Map ? (s['cur'] as Map)['title'] : null;
  return switch (t.id) {
    'photo' => 'Session de nuit au studio. Le prochain son arrive.',
    'look' => 'Tenue du jour, Ndolo en fond.',
    'coulisses' => 'Avant de monter sur scène. Merci d\'être venus.',
    'extrait' => 'Extrait : « ${last ?? 'nouveau son'} ». Monte le son.',
    'defi' => 'Défi : refais le pas sur « ${last ?? 'mon son'} » et identifie-moi.',
    'freestyle' => 'Freestyle au carrefour, une prise, zéro instru.',
    'annonce' => '« ${cur != null && '$cur'.isNotEmpty ? cur : 'Nouveau titre'} » arrive bientôt. Restez prêts.',
    'merci' => 'Merci à ceux qui étaient là au début. On ne lâche rien.',
    'clash' => 'Certains parlent beaucoup. Moi je sors des sons.',
    _ => '',
  };
}
