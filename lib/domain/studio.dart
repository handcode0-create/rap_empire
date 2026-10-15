import 'clock.dart';
import 'econ.dart';
import 'game_state.dart';
import 'studio_models.dart';

/// Actions du studio. Port de A.pick et A.write (game.js v20), fonctions pures : aucune dépendance Flutter ni Supabase.

Instru instruById(String id) => instrus.firstWhere((i) => i.id == id, orElse: () => throw const GameError('inconnu'));

/// Code d'erreur qui bloquerait le choix de l'instru (null si possible). Même ordre que A.pick : niveau, réputation, cash.
String? pickBlocker(GameState s, String id) {
  final i = instruById(id);
  if (i.lvl > s.level) return 'niveau';
  if (i.rep > 0 && s.rep < i.rep) return 'rep';
  if (s.cash < i.price) return 'cash';
  return null;
}

/// Une confirmation est demandée à partir de [Econ.confirmFrom] cauris (achat d'instru, promo).
bool needsConfirm(int amount) => amount >= Econ.confirmFrom;

/// A.pick : choisir une instru, payée tout de suite si elle est payante.
GameState pick(GameState s, String id) {
  final code = pickBlocker(s, id);
  if (code != null) throw GameError(code);
  final i = instruById(id);
  return (i.price > 0 ? pay(s, -i.price) : s).copyWith(inst: i.id, texte: null);
}

/// Écriture : 1 h et 20 énergie (A.write).
const writeHours = 1, writeEnergy = 20;

/// Note de base du texte, puis décalages d'ambiance et de thème (A.write : 72 + ambiance + thème).
const baseNote = 72;
const ambOffsets = {'sombre': 0, 'fiere': 2, 'legere': -2};
const themeOffsets = {'quartier': 0, 'galere': 1, 'ambition': 2, 'amour': -1};
const ambNames = {'sombre': 'Sombre', 'fiere': 'Fière', 'legere': 'Légère'};
const themeNames = {'quartier': 'Le quartier', 'galere': 'La galère', 'ambition': "L'ambition", 'amour': "L'amour"};

/// Gain de compétence d'écriture par texte (sk.ecr += 2).
const writeSkillGain = 2;

/// Note d'un texte pour un thème et une ambiance (sans effet sur l'état).
int textNote(String theme, String amb) {
  final a = ambOffsets[amb], t = themeOffsets[theme];
  if (a == null || t == null) throw const GameError('inconnu');
  return baseNote + a + t;
}

/// A.write : énergie -20, +1 h, note du texte, écriture +2. Erreur 'energie' sous 20.
GameState write(GameState s, {String theme = 'quartier', String amb = 'sombre'}) {
  if (s.energy < writeEnergy) throw const GameError('energie');
  final note = textNote(theme, amb);
  final n = tick(s.copyWith(energy: s.energy - writeEnergy), writeHours);
  return n.copyWith(texte: Texte(note, theme, amb), sk: {...n.sk, 'ecr': n.sk['ecr']! + writeSkillGain});
}
