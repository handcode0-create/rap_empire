import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/save_repository.dart';
import '../domain/game_state.dart';

final saveRepoProvider = Provider((_) => SaveRepository());

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
}

final gameProvider = AsyncNotifierProvider<GameNotifier, GameState>(GameNotifier.new);
