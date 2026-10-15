import 'dart:math';

/// Mini-jeu de la cabine : port de mini() dans la liaison DOM de game.js (v20). Fonctions pures, sans horloge :
/// l'écran fournit le temps écoulé depuis le début de la prise.
///
/// Le curseur va et vient sur la piste (0 à 1). À chaque prise, une zone verte de 16 % de la piste est centrée sur
/// [zoneCenters] ; le joueur appuie sur REC, la note de la prise baisse avec l'écart entre le curseur et le centre de la zone.
/// Trois prises donnent les trois notes de voix passées à record() (studio.dart).

/// Centres de zone des trois prises (ZC de game.js).
const zoneCenters = [0.62, 0.34, 0.72];

/// Nombre de prises d'une session de cabine.
const takesPerSession = 3;

/// Vitesse du curseur (unités de t par seconde) et demi-largeur de la zone verte (la zone fait 16 % de la piste).
const cursorSpeed = 0.85;
const zoneHalfWidth = 0.08;

/// Perte de note par unité d'écart entre le curseur et le centre de la zone.
const scoreSlope = 230;

double zoneCenter(int take) => zoneCenters[take % zoneCenters.length];

/// Position du curseur (0 à 1) [seconds] secondes après le début de la prise : onde triangulaire de période 2 / 0,85 s.
double cursorAt(double seconds) {
  final t = seconds * cursorSpeed;
  return (((t % 2) + 2) % 2 - 1).abs();
}

/// Note d'une prise (0 à 100) : 100 - écart x 230, arrondie, jamais négative.
int takeScore(double cursor, int take) => max(0, (100 - (cursor - zoneCenter(take)).abs() * scoreSlope).round());

/// Message affiché après une prise.
String takeMessage(int score) => score >= 70
    ? 'Prise propre'
    : score >= 45
        ? 'Prise correcte'
        : 'Prise ratée, mais gardée';
