/// Missions de démonstration (MISSIONS du prototype v20, game.js). Seule la mission 1 est affichée au QG pour l'instant.
class Mission {
  final String id, title, hint;
  const Mission(this.id, this.title, this.hint);
}

const mission1 = Mission('m1', 'Enregistre ton premier son', 'Choisis une instru, écris, passe en cabine.');
