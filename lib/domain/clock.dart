import 'dart:math';
import 'econ.dart';
import 'game_state.dart';
import 'studio_models.dart';

/// Horloge et repos. Port de tick() et A.sleep du moteur de démo v20 (game.js). Fonctions pures, aucune dépendance Flutter.
/// Pas de créneaux hebdomadaires dans la démo : seulement un jour et une heure.

const maxEnergy = 100;
const wakeHour = 8;

/// Seuil « trop fatigué » (lowEn du prototype : énergie strictement inférieure à 20).
const tiredBelow = 20;

bool isTooTired(GameState s) => s.energy < tiredBelow;

/// tick(s, h) du prototype : avance de [hours] heures, 24 h = jour suivant.
GameState tick(GameState s, int hours) {
  var hour = s.hour + hours, day = s.day;
  while (hour >= 24) {
    hour -= 24;
    day++;
  }
  return s.copyWith(hour: hour, day: day);
}

/// A.sleep du prototype : jour suivant à 08:00, énergie à 100, coût Econ.nightCost (0 en démo, D-08).
/// Les cauris ne descendent jamais sous 0 (comme pay() du prototype) : dormir n'est jamais bloqué.
GameState sleep(GameState s) => s.copyWith(
      led: Econ.nightCost != 0 ? [LedgerEntry(label: 'Nuit', amount: -Econ.nightCost, cat: null, day: s.day), ...s.led] : null,
      cash: max(0, s.cash - Econ.nightCost),
      energy: maxEnergy,
      day: s.day + 1,
      hour: wakeHour,
    );

/// « J1 08:00 » (champ time du prototype).
String formatClock(GameState s) => formatDayHour(s.day, s.hour);

String formatDayHour(int day, int hour) => 'J$day ${hour.toString().padLeft(2, '0')}:00';

/// Bilan de l'écran 03.6 Fin de journée.
class SleepReport {
  final int energyBefore, energyAfter, cost, newDay, newHour;
  const SleepReport({required this.energyBefore, required this.energyAfter, required this.cost, required this.newDay, required this.newHour});

  factory SleepReport.between(GameState before, GameState after) => SleepReport(
        energyBefore: before.energy,
        energyAfter: after.energy,
        cost: before.cash - after.cash,
        newDay: after.day,
        newHour: after.hour,
      );

  int get energyGained => energyAfter - energyBefore;
  String get newClock => formatDayHour(newDay, newHour);
}
