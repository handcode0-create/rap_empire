import 'clock.dart';
import 'econ.dart';
import 'game_state.dart';

/// Formations : port de A.formation (game.js v20). Fonctions pures, aucune dépendance Flutter ni Supabase.

/// Noms des compétences (sk de game.js : flow, ecr, voix, cha).
const skillNames = {'ecr': 'Écriture', 'flow': 'Flow', 'voix': 'Voix', 'cha': 'Charisme'};

Formation formationById(String id) => formations.firstWhere((f) => f.id == id, orElse: () => throw const GameError('inconnu'));

/// Motif qui bloquerait la formation (null si possible). Même ordre que A.formation : cash d'abord, puis énergie.
String? trainBlocker(GameState s, String id) {
  final f = formationById(id);
  if (s.cash < f.cost) return 'cash';
  if (s.energy < f.energy) return 'energie';
  return null;
}

/// A.formation : -énergie, +heures (le passage de minuit change le jour), -cauris (inscrits au registre si payant),
/// compétence +gain ; l'atelier d'écriture termine la mission 3 si elle est à faire.
GameState train(GameState s, String id) {
  final code = trainBlocker(s, id);
  if (code != null) throw GameError(code);
  final f = formationById(id);
  var n = tick(s.copyWith(energy: s.energy - f.energy), f.hours);
  if (f.cost > 0) n = pay(n, -f.cost, cat: 'formation', label: 'Formation');
  return n.copyWith(
    sk: {...n.sk, f.skill: (n.sk[f.skill] ?? 0) + f.gain},
    ms: f.unlocksMission3 && n.ms['m3'] == 'todo' ? {...n.ms, 'm3': 'done'} : n.ms,
  );
}

/// Toast de compétence (planche 09.4 : « Écriture +5 · Atelier terminé »). Seul l'atelier a son texte dans la planche ;
/// les autres formations disent « Formation terminée ».
String trainingToast(Formation f) => '${skillNames[f.skill]} +${f.gain} · ${f.unlocksMission3 ? 'Atelier terminé' : 'Formation terminée'}';
