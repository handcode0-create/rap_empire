import 'dart:math';
import 'econ.dart';

const _k = 5420 / (9000 * 0.61);

/// R1 + R2 simplifiées de la démo : note du son (texte, voix, production) moins le malus de forme.
int quality(num texte, num voix, num prod, num energie) {
  final malus = min(20.0, max(0, 40 - energie) / 2);
  return max(0, (0.35 * texte + 0.30 * voix + 0.35 * prod - malus).round());
}

/// Écoutes sur 7 jours d'une sortie (formule de démo, plafond doux).
int listensFor(num q, num fans, int promo, {bool feat = false}) {
  final raw = (9000 + 6 * (fans - 120)) * promos[promo].mult * (q / 100) * _k * (feat ? Econ.featBoost : 1);
  return (raw / (1 + raw / Econ.listenCap)).round();
}

int levelOf(int xp) {
  var l = 1;
  for (var i = 0; i < Econ.levelXp.length; i++) {
    if (xp >= Econ.levelXp[i]) l = i + 1;
  }
  return l;
}

/// Pourcentage (0 à 100) de la barre d'XP du HUD : xpPct de game.js (view).
/// (xp - début du niveau) / (début du niveau suivant - début du niveau), arrondi au pour cent ; le niveau 5 compte 600 XP de plus.
int xpPercent(int xp) {
  final lvl = levelOf(xp);
  final lo = Econ.levelXp[lvl - 1];
  final hi = lvl < Econ.levelXp.length ? Econ.levelXp[lvl] : Econ.levelXp.last + 600;
  return max(0, min(100, (100 * (xp - lo) / (hi - lo)).round()));
}

/// Part (0 à 100, une décimale) du seuil d'entrée du Top 100 Singles atteinte par les écoutes de la semaine :
/// gapPct de game.js (view) = min(100, round(100 x lw / ENTRY x 10) / 10).
double gapPercent(int weekListens) => min(100, (100 * weekListens / Econ.entryListens * 10).round() / 10);

/// Nom du niveau suivant (nextName de game.js : LVN[lvl] ou « Légende » au niveau maximal).
String nextLevelName(int xp) {
  final l = levelOf(xp);
  return l < Econ.levelNames.length ? Econ.levelNames[l] : 'Légende';
}

/// XP restants avant le niveau suivant (xpLeft de game.js ; le niveau 5 compte 600 XP de plus).
int xpToNextLevel(int xp) {
  final l = levelOf(xp);
  final hi = l < Econ.levelXp.length ? Econ.levelXp[l] : Econ.levelXp.last + 600;
  return max(0, hi - xp);
}

/// Avancement (0 à 100) de la mission « Atteins 1 000 fans » : m4pct de game.js = min(100, round(fans / 10)).
int fansMissionPercent(int fans) => min(100, (fans / 10).round());

/// Espace pur : aucune dépendance Flutter ni Supabase (testable, reproductible, rejouable côté serveur).
String fmt(num n) {
  final s = n.abs().round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  return n < 0 ? '-$s' : s;
}
