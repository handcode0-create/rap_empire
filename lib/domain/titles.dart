import 'game_state.dart';
import 'music_catalog.dart';

/// Titres de sons. Absent de game.js (le prototype donne toujours « Gbaka de 6h », ou « Nuit à Ndo » avec l'instru gratuite) :
/// règle ajoutée pour que chaque son ait un titre généré, relançable au hasard ou saisi à la main.
/// Les titres viennent de la bibliothèque musicale (music_catalog.dart) : dictionnaire, modèles et thème du texte.

/// Longueur maximale d'un titre saisi.
const maxTitleLength = 28;

/// Titre pour une graine et un thème (même graine et même thème, même titre). Sans thème, le thème est tiré au hasard par la graine.
String titleFor(int seed, {String? theme}) => generateTitle(seed, themeId: theme, maxLength: maxTitleLength);

/// Graine déterministe tirée de l'état : le titre automatique d'un texte ne dépend que de la partie.
int autoSeed(GameState s) => Object.hash(s.day, s.hour, s.cash, s.xp, s.disco.length, s.texte?.note);

/// Titre à utiliser pour le son en cours : le titre saisi ou généré, sinon un titre généré.
String currentTitle(GameState s) {
  final t = s.title?.trim() ?? '';
  return t.isEmpty ? titleFor(autoSeed(s), theme: s.texte?.theme) : t;
}

/// Donne un titre généré au son en cours s'il n'en a pas (appelé quand le texte s'affiche) ; un titre déjà choisi est conservé.
GameState ensureTitle(GameState s) => (s.title ?? '').trim().isEmpty ? s.copyWith(title: titleFor(autoSeed(s), theme: s.texte?.theme)) : s;

/// Nouveau titre aléatoire ; [seed] vient de l'appelant (l'écran tire le hasard, le domaine reste pur). Évite de redonner le titre actuel.
GameState rerollTitle(GameState s, int seed) {
  var title = titleFor(seed, theme: s.texte?.theme);
  if (title == s.title) title = titleFor(seed + 1, theme: s.texte?.theme);
  return s.copyWith(title: title);
}

/// Titre saisi à la main : espaces rognés, tronqué à [maxTitleLength]. Un titre vide est conservé tel quel (le champ reste modifiable) ;
/// currentTitle() génère alors un titre au moment d'enregistrer.
GameState setTitle(GameState s, String text) {
  final t = text.trim();
  return s.copyWith(title: t.length > maxTitleLength ? t.substring(0, maxTitleLength) : t);
}
