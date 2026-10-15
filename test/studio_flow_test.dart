import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';

import 'support.dart';

/// Parcours d'interface du studio, état injecté puis vérifié dans la sauvegarde locale factice.
void main() {
  Future<void> openInstru(WidgetTester tester) async {
    await tester.tap(find.text('Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouveau son'));
    await tester.pumpAndSettle();
  }

  group('instrus (04.3, 04.4)', () {
    testWidgets('les quatre instrus et leurs verrous sont affichés', (tester) async {
      await pumpApp(tester, const GameState());
      await openInstru(tester);
      expect(find.text('Choisis une instru'), findsOneWidget);
      expect(find.text('Étape 1 / 3'), findsOneWidget);
      for (final t in ['Nuit à Ndo', 'Gbaka de 6h', 'Pont des Griots', "Lagune d'Ambre", 'Gratuit', '8 000 cauris', '15 000 cauris', '40 000 cauris', 'N2', 'Rép. 30']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('Gbaka (8 000) : achat direct, sans confirmation, retour au studio', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(find.text('Gbaka de 6h'));
      await tester.pumpAndSettle();
      expect(find.text('Confirmation'), findsNothing);
      expect([repo.current.cash, repo.current.inst], [17000, 'gbaka']);
      expect(find.text('Instru choisie : Gbaka de 6h'), findsOneWidget);
    });

    testWidgets('Nuit à Ndo : gratuite', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(find.text('Nuit à Ndo'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [25000, 'nuit']);
    });

    testWidgets('Pont au niveau 1 : message « Niveau requis », rien n\'est débité', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(find.text('Pont des Griots'));
      await tester.pumpAndSettle();
      expect(find.text('Niveau requis'), findsOneWidget);
      expect(find.text('Confirmation'), findsNothing);
      expect([repo.current.cash, repo.current.inst], [25000, null]);
    });

    testWidgets('Lagune réputation 8 : « Réputation requise »', (tester) async {
      await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(find.text("Lagune d'Ambre"));
      await tester.pumpAndSettle();
      expect(find.text('Réputation requise'), findsOneWidget);
    });

    testWidgets('Gbaka avec 7 999 cauris : « Cash insuffisant »', (tester) async {
      await pumpApp(tester, const GameState(cash: 7999));
      await openInstru(tester);
      await tester.tap(find.text('Gbaka de 6h'));
      await tester.pumpAndSettle();
      expect(find.text('Cash insuffisant'), findsOneWidget);
    });

    testWidgets('Pont niveau 2 : confirmation à 15 000, cash après achat, achat', (tester) async {
      final repo = await pumpApp(tester, const GameState(xp: 100));
      await openInstru(tester);
      await tester.tap(find.text('Pont des Griots'));
      await tester.pumpAndSettle();
      expect(find.text('Acheter Pont des Griots ?'), findsOneWidget);
      expect(find.text('Cash après achat'), findsOneWidget);
      expect(find.text('10 000 cauris'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Acheter  − 15 000 cauris'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [10000, 'pont']);
    });

    testWidgets('Annuler la confirmation : rien n\'est débité', (tester) async {
      final repo = await pumpApp(tester, const GameState(xp: 100));
      await openInstru(tester);
      await tester.tap(find.text('Pont des Griots'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [25000, null]);
    });

    testWidgets('Lagune réputation 30, 50 000 cauris : confirmation puis 10 000 cauris', (tester) async {
      final repo = await pumpApp(tester, const GameState(rep: 30, cash: 50000));
      await openInstru(tester);
      await tester.tap(find.text("Lagune d'Ambre"));
      await tester.pumpAndSettle();
      expect(find.text("Acheter Lagune d'Ambre ?"), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Acheter  − 40 000 cauris'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [10000, 'lagune']);
    });
  });
}
