import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/save_repository.dart';
import '../domain/clock.dart' as clock;
import '../domain/game_state.dart';
import '../domain/studio.dart' as studio;

final saveRepoProvider = Provider((_) => SaveRepository());

/// Dernier bilan de nuit, lu par l'écran 03.6 Fin de journée. Éphémère : non sauvegardé.
final lastSleepProvider = StateProvider<clock.SleepReport?>((_) => null);

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
  Future<void> writeText({String theme = 'quartier', String amb = 'sombre'}) => apply((s) => studio.write(s, theme: theme, amb: amb));

  /// Dormir : la règle est dans lib/domain/clock.dart ; ici seulement l'enchaînement état, bilan et sauvegarde.
  Future<void> sleep() async {
    final before = state.requireValue;
    final after = clock.sleep(before);
    ref.read(lastSleepProvider.notifier).state = clock.SleepReport.between(before, after);
    await apply((_) => after);
  }
}

final gameProvider = AsyncNotifierProvider<GameNotifier, GameState>(GameNotifier.new);
