import 'game_state.dart';

/// Missions de démonstration (MISSIONS du prototype v20, game.js). Les récompenses sont dans econ.dart (missionRewards).
/// Le QG affiche l'objectif en cours parmi la mission 1 et la mission 2 ; les missions 3 et 4 n'ont pas encore d'écran.
class Mission {
  final String id, title, hint;
  const Mission(this.id, this.title, this.hint);
}

const mission1 = Mission('m1', 'Enregistre ton premier son', 'Choisis une instru, écris, passe en cabine.');
const mission2 = Mission('m2', 'Sors ton premier single', 'Ton son est prêt : choisis la promo et mets-le en ligne.');

/// Titres des quatre missions (MISSIONS[].t de game.js), repris dans le registre.
const missionTitles = {
  'm1': 'Enregistre ton premier son',
  'm2': 'Sors ton premier single',
  'm3': "Fais un atelier d'écriture",
  'm4': 'Atteins 1 000 fans',
  'm5': 'Réussis ton open mic',
  'm6': 'Gagne une battle',
  'm7': 'Donne ton premier concert',
  'm8': 'Sors 3 sons',
  'm9': 'Atteins 5 000 fans',
  'm10': 'Cumule 20 000 écoutes',
};

/// Avancement (0 à 1) des missions qui se mesurent ; null pour celles qui sont une action ponctuelle.
double? missionProgress(String id, GameState s) => switch (id) {
      'm4' => (s.fans / 1000).clamp(0, 1).toDouble(),
      'm8' => (s.disco.length / 3).clamp(0, 1).toDouble(),
      'm9' => (s.fans / 5000).clamp(0, 1).toDouble(),
      'm10' => (s.lc / 20000).clamp(0, 1).toDouble(),
      _ => null,
    };

/// Termine les missions mesurables dont la condition est remplie (appelée après chaque action qui peut y contribuer).
GameState refreshMissions(GameState s) {
  final ms = {...s.ms};
  var changed = false;
  void done(String id, bool ok) {
    if (ok && (ms[id] ?? 'todo') == 'todo') {
      ms[id] = 'done';
      changed = true;
    }
  }

  done('m4', s.fans >= 1000);
  done('m8', s.disco.length >= 3);
  done('m9', s.fans >= 5000);
  done('m10', s.lc >= 20000);
  return changed ? s.copyWith(ms: ms) : s;
}

/// Missions affichées au QG, dans l'ordre.
const qgMissions = [mission1, mission2];

/// Objectif en cours : la première mission du QG pas encore récupérée (null quand toutes le sont).
Mission? currentObjective(GameState s) {
  for (final m in qgMissions) {
    if (s.ms[m.id] != 'claimed') return m;
  }
  return null;
}
