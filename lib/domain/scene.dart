import 'clock.dart';
import 'econ.dart';
import 'game_state.dart';
import 'missions.dart';
import 'studio.dart';
import 'training.dart';

/// Scène : open mic, battle, concert et freestyle. Port de A.openmic, A.battle, A.concert et de la formation « Freestyle »
/// (game.js v20). Fonctions pures, aucune dépendance Flutter. Valeurs provisoires dans Econ (D-08).

/// Énergie minimale pour monter sur scène, durée de l'open mic, et énergie sous laquelle le public décroche.
const sceneEnergy = 15, openMicHours = 1, openMicWinEnergy = 40;

/// Concert : niveau et énergie requis (A.concert).
const concertLevel = 3, concertEnergy = 35;

enum SceneKind { openMic, battle, concert }

/// Bilan affiché sur l'écran de résultat de scène.
class SceneResult {
  final SceneKind kind;
  final bool win;
  final int fans, rep, cash, xp;

  /// Concert : note A, B ou C et remplissage de la salle (0 à 100) ; battle : punchlines gagnées sur 3.
  final String? grade;
  final int? crowd, score;
  const SceneResult({required this.kind, required this.win, required this.fans, required this.rep, required this.cash, required this.xp, this.grade, this.crowd, this.score});
}

/// Motif qui empêche la scène (null si possible).
String? sceneBlocker(GameState s, SceneKind k) {
  if (k == SceneKind.concert && s.level < concertLevel) return 'niveau';
  final need = k == SceneKind.concert ? concertEnergy : sceneEnergy;
  if (s.energy < need) return 'energie';
  return null;
}

GameState _cachet(GameState s, int amount, String label) => pay(s, amount, cat: 'cachets', label: label);

GameState _finish(GameState s, String mission, bool ok) {
  final ms = ok && (s.ms[mission] ?? 'todo') == 'todo' ? {...s.ms, mission: 'done'} : s.ms;
  return refreshMissions(s.copyWith(ms: ms));
}

/// A.openmic : 1 h, 15 énergie. Réussi si l'énergie d'avant la scène est d'au moins 40.
(GameState, SceneResult) openMic(GameState s) {
  final code = sceneBlocker(s, SceneKind.openMic);
  if (code != null) throw GameError(code);
  final win = s.energy >= openMicWinEnergy;
  var n = tick(s.copyWith(energy: s.energy - sceneEnergy), openMicHours);
  if (win) {
    n = _cachet(n, Econ.openMicFee, 'Cachet open mic Ndolo');
    n = addXp(n.copyWith(fans: n.fans + 150, fgain: n.fgain + 150, rep: n.rep + 6, lw: n.lw + 450), Econ.xpOpenMic);
  } else {
    n = addXp(n.copyWith(fans: n.fans + 12, fgain: n.fgain + 12), 10);
  }
  return (_finish(n, 'm5', win), SceneResult(kind: SceneKind.openMic, win: win, fans: win ? 150 : 12, rep: win ? 6 : 0, cash: win ? Econ.openMicFee : 0, xp: win ? Econ.xpOpenMic : 10));
}

/// A.battle : [score] punchlines gagnées sur 3 ; gagnée à 2 ou plus.
(GameState, SceneResult) battle(GameState s, int score) {
  final code = sceneBlocker(s, SceneKind.battle);
  if (code != null) throw GameError(code);
  final win = score >= 2;
  var n = tick(s.copyWith(energy: s.energy - sceneEnergy), 1);
  if (win) {
    n = _cachet(n, Econ.battleFee, 'Prime de battle');
    n = addXp(n.copyWith(fans: n.fans + 150, fgain: n.fgain + 150, rep: n.rep + 6, lw: n.lw + 450), 60);
  } else {
    n = n.copyWith(fans: n.fans + 12, fgain: n.fgain + 12);
  }
  return (_finish(n, 'm6', win), SceneResult(kind: SceneKind.battle, win: win, fans: win ? 150 : 12, rep: win ? 6 : 0, cash: win ? Econ.battleFee : 0, xp: win ? 60 : 0, score: score));
}

/// Remplissage de la salle pour une suite d'actions : 'h' (hype) +8, 'r' (rap) +14, +6 de plus si le rap suit un hype. Départ à 50.
int concertCrowd(List<String> seq) {
  var crowd = 50;
  var prev = '';
  for (final a in seq) {
    crowd += a == 'r' ? 14 + (prev == 'h' ? 6 : 0) : 8;
    prev = a;
  }
  return crowd;
}

/// A.concert : niveau 3, 35 énergie, fin de soirée à 23 h. La note (A, B, C) vient du remplissage de la salle.
(GameState, SceneResult) concert(GameState s, [List<String> seq = const ['h', 'r', 'r']]) {
  final code = sceneBlocker(s, SceneKind.concert);
  if (code != null) throw GameError(code);
  final crowd = concertCrowd(seq);
  final g = crowd >= 85 ? 'A' : (crowd >= 70 ? 'B' : 'C');
  final fm = {'A': 1.0, 'B': 0.7, 'C': 0.4}[g]!, cm = {'A': 1.0, 'B': 0.8, 'C': 0.5}[g]!;
  final rp = {'A': 10, 'B': 6, 'C': 2}[g]!;
  final fg = (520 * fm).round(), ca = (Econ.concertFee * cm).round();
  var n = s.copyWith(energy: s.energy - concertEnergy, hour: 23);
  n = _cachet(n, ca, 'Cachet concert Le Parvis');
  n = addXp(n.copyWith(fans: n.fans + fg, fgain: n.fgain + fg, rep: n.rep + rp, lw: n.lw + fg * 3), 90);
  return (_finish(n, 'm7', true), SceneResult(kind: SceneKind.concert, win: g != 'C', fans: fg, rep: rp, cash: ca, xp: 90, grade: g, crowd: crowd.clamp(0, 100)));
}

/// Freestyle au carrefour : la formation gratuite de Flow (+2, 15 énergie, 1 h).
GameState freestyle(GameState s) => train(s, 'flow');
