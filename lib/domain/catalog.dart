import 'dart:math';
import 'econ.dart';
import 'game_state.dart';
import 'missions.dart';
import 'studio_models.dart';

/// Catalogue : chaque son sorti continue d'être écouté les jours suivants, de moins en moins, puis passe de mode.
/// Fonctions pures, appelées au passage de la journée (clock.sleep). Valeurs provisoires dans Econ (D-08).

/// Écoutes d'un son [age] jours après sa sortie (1 = premier jour). 0 une fois passé de mode.
/// Tant que le son vit, au moins 1 écoute par jour : même un petit son rapporte quelque chose.
int catalogListens(DiscoEntry e, int age) {
  if (age < 1 || age > Econ.catalogDays) return 0;
  return max(1, (e.listens * Econ.catalogDaily * pow(Econ.catalogDecay, age - 1)).round());
}

/// Gain d'une nuit : écoutes, cauris et fans.
class CatalogGain {
  final int listens, cash, fans;
  const CatalogGain({this.listens = 0, this.cash = 0, this.fans = 0});
}

/// Gain du catalogue pour passer au jour [newDay]. Fans comme à la sortie : conversion saturée par le nombre de fans.
CatalogGain catalogGain(GameState s, int newDay) {
  var listens = 0;
  for (final e in s.disco) {
    listens += catalogListens(e, newDay - (e.day < 0 ? s.day : e.day));
  }
  if (listens == 0) return const CatalogGain();
  return CatalogGain(
    listens: listens,
    cash: (listens * Econ.monetised * Econ.listenValue).round(),
    fans: (listens * Econ.fanConversion / (1 + s.fans / Econ.fanSat)).ceil(),
  );
}

/// Applique le gain du catalogue : cauris (registre), fans, écoutes. Date les sons des anciennes sauvegardes.
GameState applyCatalog(GameState s, int newDay) {
  final g = catalogGain(s, newDay);
  final disco = [for (final e in s.disco) e.day < 0 ? e.withDay(s.day) : e];
  if (g.listens == 0) return s.copyWith(disco: disco);
  var n = s.copyWith(disco: disco);
  if (g.cash > 0) n = pay(n, g.cash, cat: 'ecoutes', label: 'Écoutes du catalogue');
  return refreshMissions(n.copyWith(fans: n.fans + g.fans, fgain: n.fgain + g.fans, lw: n.lw + g.listens, lc: n.lc + g.listens));
}
