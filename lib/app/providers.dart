import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/save_repository.dart';
import '../domain/clock.dart' as clock;
import '../domain/game_state.dart';
import '../domain/kore.dart' as kore;
import '../domain/scene.dart' as scene;
import '../domain/studio.dart' as studio;
import '../domain/titles.dart' as titles;
import '../domain/training.dart' as training;

final saveRepoProvider = Provider((_) => SaveRepository());

/// Dernier bilan de nuit, lu par l'écran 03.6 Fin de journée. Éphémère : non sauvegardé.
final lastSleepProvider = StateProvider<clock.SleepReport?>((_) => null);

/// Dernier bilan de scène (open mic, battle, concert), lu par l'écran de résultat. Éphémère : non sauvegardé.
final lastSceneProvider = StateProvider<scene.SceneResult?>((_) => null);

class GameNotifier extends AsyncNotifier<GameState> {
  @override
  Future<GameState> build() => ref.read(saveRepoProvider).loadLocal();

  /// Applique une action pure puis persiste (local, puis distant si connecté).
  Future<void> apply(GameState Function(GameState) action) async {
    final cur = state.requireValue;
    final next = action(cur);
    state = AsyncData(next);
    final repo = ref.read(saveRepoProvider);
    await repo.saveLocal(next);
    repo.pushRemote(next).ignore();
  }

  /// Studio : chaque action appelle une fonction pure de lib/domain/studio.dart ; une GameError remonte à l'écran.
  Future<void> pickInstru(String id) => apply((s) => studio.pick(s, id));
  Future<void> writeText({String theme = 'rue', String amb = 'sombre'}) => apply((s) => studio.write(s, theme: theme, amb: amb));

  /// Cabine : notes des trois prises du mini-jeu ; sans argument, les prises simulées du prototype (« Simuler les 3 prises »).
  Future<void> recordSession([List<int>? takes]) => apply((s) => studio.record(s, takes));

  /// Sortie d'un single avec la promo choisie (index de promos).
  Future<void> releaseSingle(int promo) => apply((s) => studio.release(s, promo));

  /// Titre du son en cours : saisi à la main, ou tiré au hasard (le hasard vient d'ici, le domaine reste pur).
  Future<void> setTitle(String text) => apply((s) => titles.setTitle(s, text));
  Future<void> ensureTitle() => apply(titles.ensureTitle);
  Future<void> rerollTitle() => apply((s) => titles.rerollTitle(s, Random().nextInt(1 << 30)));

  /// Scène : chaque action appelle une fonction pure de lib/domain/scene.dart ; le bilan est gardé pour l'écran de résultat.
  Future<void> _stage((GameState, scene.SceneResult) Function(GameState) action) async {
    final (next, result) = action(state.requireValue);
    ref.read(lastSceneProvider.notifier).state = result;
    await apply((_) => next);
  }

  Future<void> openMic() => _stage(scene.openMic);
  Future<void> battle(int score) => _stage((s) => scene.battle(s, score));
  Future<void> concert(List<String> seq) => _stage((s) => scene.concert(s, seq));
  Future<void> freestyleScene() => apply(scene.freestyle);

  /// Recommencer la démo (A.reset de game.js) : état de départ, bilan de nuit effacé.
  Future<void> resetGame() async {
    ref.read(lastSleepProvider.notifier).state = null;
    await apply((_) => newGameState.copyWith(seed: Random().nextInt(1 << 20)));
  }

  /// DJ Kôrô (scène A, lib/domain/kore.dart) : un choix de l'offre ; une GameError (cash, accord) remonte à l'écran.
  Future<void> koreDeal(String id) => apply((s) => kore.kdeal(s, id));

  /// L'introduction de Kôrô (16-A1) a été montrée : elle ne s'ouvre plus d'elle-même au Studio.
  /// Attend la fin du chargement de la sauvegarde : l'écoute peut être la toute première route ouverte.
  Future<void> markKoreSeen() async {
    await future;
    await apply((s) => s.koreIntro ? s.copyWith(koreIntro: false) : s);
  }

  /// Matériel et formation (Business).
  Future<void> buyMicro() => apply(studio.buyMicro);
  Future<void> train(String id) => apply((s) => training.train(s, id));

  /// Missions : récupérer une récompense, puis la récompense de niveau.
  Future<void> claimMission(String id) => apply((s) => studio.claim(s, id));
  Future<void> acknowledgeLevel() => apply(studio.ack);

  /// Dormir : la règle est dans lib/domain/clock.dart ; ici seulement l'enchaînement état, bilan et sauvegarde.
  Future<void> sleep() async {
    final before = state.requireValue;
    final after = clock.sleep(before);
    ref.read(lastSleepProvider.notifier).state = clock.SleepReport.between(before, after);
    await apply((_) => after);
  }
}

final gameProvider = AsyncNotifierProvider<GameNotifier, GameState>(GameNotifier.new);
