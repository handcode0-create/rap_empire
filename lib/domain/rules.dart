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

/// Espace pur : aucune dépendance Flutter ni Supabase (testable, reproductible, rejouable côté serveur).
String fmt(num n) {
  final s = n.abs().round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  return n < 0 ? '-$s' : s;
}
