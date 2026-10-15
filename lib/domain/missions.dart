import 'game_state.dart';

/// Missions de démonstration (MISSIONS du prototype v20, game.js). Les récompenses sont dans econ.dart (missionRewards).
/// Le QG affiche l'objectif en cours parmi la mission 1 et la mission 2 ; les missions 3 et 4 n'ont pas encore d'écran.
class Mission {
  final String id, title, hint;
  const Mission(this.id, this.title, this.hint);
}

const mission1 = Mission('m1', 'Enregistre ton premier son', 'Choisis une instru, écris, passe en cabine.');
const mission2 = Mission('m2', 'Sors ton premier single', 'Ton son est prêt : choisis la promo et mets-le en ligne.');

/// Missions affichées au QG, dans l'ordre.
const qgMissions = [mission1, mission2];

/// Objectif en cours : la première mission du QG pas encore récupérée (null quand toutes le sont).
Mission? currentObjective(GameState s) {
  for (final m in qgMissions) {
    if (s.ms[m.id] != 'claimed') return m;
  }
  return null;
}
