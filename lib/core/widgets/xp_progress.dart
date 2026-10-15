import 'dart:math';
import '../../domain/econ.dart';
import '../../domain/rules.dart';

/// Part de la barre d'XP du HUD, entre 0 et 1 : même calcul que xpPct de game.js (view) :
/// (xp - début du niveau) / (début du niveau suivant - début du niveau), arrondi au pour cent ; le niveau 5 compte 600 XP de plus.
/// Calcul d'affichage uniquement (aucune règle de jeu) : à déplacer dans lib/domain si le dossier le demande.
double xpFraction(int xp) {
  final lvl = levelOf(xp);
  final lo = Econ.levelXp[lvl - 1];
  final hi = lvl < Econ.levelXp.length ? Econ.levelXp[lvl] : Econ.levelXp.last + 600;
  final pct = max(0, min(100, (100 * (xp - lo) / (hi - lo)).round()));
  return pct / 100;
}
