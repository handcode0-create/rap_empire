import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/providers.dart';
import 'package:rap_empire/app/router.dart';
import 'package:rap_empire/data/save_repository.dart';
import 'package:rap_empire/domain/game_state.dart';

/// Dépôt factice : pas de shared_preferences, pas de Supabase. `current` reflète la dernière sauvegarde locale.
class FakeRepo extends SaveRepository {
  GameState current;
  FakeRepo(this.current);
  @override
  Future<GameState> loadLocal() async => current;
  @override
  Future<void> saveLocal(GameState s) async => current = s;
  @override
  Future<void> pushRemote(GameState s) async {}
}

/// Lance l'app en 390 x 844 avec un état de départ donné.
Future<FakeRepo> pumpApp(WidgetTester tester, GameState start, {String location = '/'}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeRepo(start);
  await tester.pumpWidget(ProviderScope(
    overrides: [saveRepoProvider.overrideWithValue(repo)],
    child: MaterialApp.router(theme: ThemeData.dark(useMaterial3: true), routerConfig: buildRouter(initialLocation: location)),
  ));
  await tester.pumpAndSettle();
  return repo;
}
