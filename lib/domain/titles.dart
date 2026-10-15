import 'game_state.dart';

/// Titres de sons. Absent de game.js (le prototype donne toujours « Gbaka de 6h », ou « Nuit à Ndo » avec l'instru gratuite) :
/// règle ajoutée pour que chaque son ait un titre généré, relançable au hasard ou saisi à la main. Les mots sont de la fiction de Bakoma (provisoires).

const _nouns = ['Gbaka', 'Marché', 'Soleil', 'Ciel', 'Quartier', 'Rêve', 'Fièvre', 'Écho'];
const _ends = ['de 6h', 'de minuit', 'de Ndolo', 'de Mabaya', 'de Kôtoro', 'de Lumbé', "de l'aube", 'de la lagune'];

/// Longueur maximale d'un titre saisi.
const maxTitleLength = 28;

/// Les 64 titres générables (nom + complément). « Gbaka de 6h », le titre du prototype, en fait partie.
final List<String> generatedTitles = [for (final n in _nouns) for (final e in _ends) '$n $e'];

/// Titre pour une graine donnée (même graine, même titre).
String titleFor(int seed) => generatedTitles[seed.abs() % generatedTitles.length];

/// Graine déterministe tirée de l'état : le titre automatique d'un texte ne dépend que de la partie.
int autoSeed(GameState s) => Object.hash(s.day, s.hour, s.cash, s.xp, s.disco.length, s.texte?.note);

/// Titre à utiliser pour le son en cours : le titre saisi ou généré, sinon un titre généré.
String currentTitle(GameState s) {
  final t = s.title?.trim() ?? '';
  return t.isEmpty ? titleFor(autoSeed(s)) : t;
}

/// Donne un titre généré au son en cours s'il n'en a pas (appelé quand le texte s'affiche) ; un titre déjà choisi est conservé.
GameState ensureTitle(GameState s) => (s.title ?? '').trim().isEmpty ? s.copyWith(title: titleFor(autoSeed(s))) : s;

/// Nouveau titre aléatoire ; [seed] vient de l'appelant (l'écran tire le hasard, le domaine reste pur). Évite de redonner le titre actuel.
GameState rerollTitle(GameState s, int seed) {
  var title = titleFor(seed);
  if (title == s.title) title = titleFor(seed + 1);
  return s.copyWith(title: title);
}

/// Titre saisi à la main : espaces rognés, tronqué à [maxTitleLength]. Un titre vide est conservé tel quel (le champ reste modifiable) ;
/// currentTitle() génère alors un titre au moment d'enregistrer.
GameState setTitle(GameState s, String text) {
  final t = text.trim();
  return s.copyWith(title: t.length > maxTitleLength ? t.substring(0, maxTitleLength) : t);
}
