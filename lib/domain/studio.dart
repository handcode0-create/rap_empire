import 'econ.dart';
import 'game_state.dart';

/// Actions du studio. Port de A.pick (game.js v20), fonctions pures : aucune dépendance Flutter ni Supabase.

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
  return (i.price > 0 ? pay(s, -i.price) : s).copyWith(inst: i.id);
}
