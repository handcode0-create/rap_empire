import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/providers.dart';
import 'package:rap_empire/app/router.dart';
import 'package:rap_empire/core/widgets/back_header.dart';
import 'package:rap_empire/core/widgets/game_nav_bar.dart';
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
Future<FakeRepo> pumpApp(WidgetTester tester, GameState start, {String location = '/', bool settle = true, double height = 844}) async {
  tester.view.physicalSize = Size(390, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeRepo(start);
  await tester.pumpWidget(ProviderScope(
    key: UniqueKey(), // plusieurs pumpApp dans un même test : un état neuf à chaque fois
    overrides: [saveRepoProvider.overrideWithValue(repo)],
    child: MaterialApp.router(theme: ThemeData.dark(useMaterial3: true), routerConfig: buildRouter(initialLocation: location)),
  ));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // écran animé en continu (mini-jeu) : pas de pumpAndSettle ; le temps écoulé vaut ensuite exactement 100 ms
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  return repo;
}

/// Texte affiché, sans tenir compte de la casse : la v20 met boutons, étiquettes et toasts en majuscules (text-transform CSS).
Finder txt(String text) => find.byWidgetPredicate((w) {
      if (w is! Text) return false;
      final t = w.data ?? w.textSpan?.toPlainText();
      return t != null && t.toLowerCase() == text.toLowerCase();
    }, description: 'texte « $text » (casse ignorée)');

/// Fait défiler la liste jusqu'au texte s'il n'est pas encore construit (listes paresseuses), puis le touche.
Future<void> tapText(WidgetTester tester, String text) async {
  if (txt(text).evaluate().isEmpty) {
    await tester.scrollUntilVisible(txt(text), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
  }
  await tester.ensureVisible(txt(text).first);
  await tester.pumpAndSettle();
  await tester.tap(txt(text).first);
  await tester.pumpAndSettle();
}

/// Bouton retour (48 x 48) de l'en-tête d'un écran de détail.
Future<void> tapBack(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(BackHeader), matching: find.byType(GestureDetector)).first);
  await tester.pumpAndSettle();
}

/// Onglet de la barre de navigation (QG, Studio, Scène, Business, Profil), sans le confondre avec une tuile ou un titre du même nom.
Finder navTab(String label) => find.descendant(of: find.byType(GameNavBar), matching: txt(label));

/// Touche un texte sans attendre que l'écran se stabilise (écrans animés : mini-jeu, chargement) : une image, puis [after] de temps simulé.
Future<void> tapNoSettle(WidgetTester tester, String text, {Duration after = const Duration(milliseconds: 400)}) async {
  if (txt(text).evaluate().isEmpty) {
    await tester.scrollUntilVisible(txt(text), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
  }
  await tester.ensureVisible(txt(text).first);
  await tester.pump();
  await tester.tap(txt(text).first);
  await tester.pump();
  await tester.pump(after);
}
