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

    testWidgets('Gbaka (8 000) : achat direct, sans confirmation, puis écran d écriture', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(find.text('Gbaka de 6h'));
      await tester.pumpAndSettle();
      expect(find.text('Confirmation'), findsNothing);
      expect([repo.current.cash, repo.current.inst], [17000, 'gbaka']);
      expect(find.text('Écrire le texte'), findsOneWidget);
      expect(find.text('Étape 2 / 3'), findsOneWidget);
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

  group('écriture (04.5, 04.6)', () {
    const gbaka = GameState(inst: 'gbaka', cash: 17000);

    testWidgets('choix du thème et de l’ambiance, rappel de l’instru', (tester) async {
      await pumpApp(tester, gbaka, location: '/studio/ecriture');
      expect(find.text('Écrire le texte'), findsOneWidget);
      expect(find.text('Étape 2 / 3'), findsOneWidget);
      expect(find.text('Gbaka de 6h'), findsOneWidget);
      expect(find.text('· qualité 56'), findsOneWidget);
      for (final t in ['Le quartier', 'La galère', "L'ambition", "L'amour", 'Écrire · Sombre', 'Écrire · Fière', 'Écrire · Légère']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('Écrire · Sombre : note 72, énergie 80, 09:00, écriture +2', (tester) async {
      final repo = await pumpApp(tester, gbaka, location: '/studio/ecriture');
      await tester.tap(find.text('Écrire · Sombre'));
      await tester.pumpAndSettle();
      expect(find.text('Ton texte'), findsOneWidget);
      expect(find.text('72'), findsWidgets);
      expect(find.text('Écriture +2 · −20 énergie · 1 h'), findsOneWidget);
      expect([repo.current.texte!.note, repo.current.energy, repo.current.hour, repo.current.sk['ecr']], [72, 80, 9, 16]);
    });

    testWidgets('La galère + Fière : note 75', (tester) async {
      final repo = await pumpApp(tester, gbaka, location: '/studio/ecriture');
      await tester.tap(find.text('La galère'));
      await tester.pump();
      await tester.tap(find.text('Écrire · Fière'));
      await tester.pumpAndSettle();
      expect(repo.current.texte!.note, 75);
      expect(find.text('La galère · Fière'), findsOneWidget);
    });

    testWidgets('Réécrire revient au choix et remplace le texte (énergie 60)', (tester) async {
      final repo = await pumpApp(tester, gbaka, location: '/studio/ecriture');
      await tester.tap(find.text('Écrire · Sombre'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Réécrire'));
      await tester.pumpAndSettle();
      expect(find.text('Écrire · Légère'), findsOneWidget);
      await tester.ensureVisible(find.text('Écrire · Légère'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Écrire · Légère'));
      await tester.pumpAndSettle();
      expect([repo.current.texte!.note, repo.current.energy, repo.current.sk['ecr']], [70, 60, 18]);
    });

    testWidgets('énergie 19 : « Trop fatigué » avec Dormir, rien n’est écrit', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 19), location: '/studio/ecriture');
      await tester.tap(find.text('Écrire · Sombre'));
      await tester.pumpAndSettle();
      expect(find.text('Trop fatigué'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Dormir'), findsOneWidget);
      expect(repo.current.texte, isNull);
    });

    testWidgets('énergie 20 : écriture permise, énergie à 0', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 20), location: '/studio/ecriture');
      await tester.tap(find.text('Écrire · Sombre'));
      await tester.pumpAndSettle();
      expect(repo.current.energy, 0);
      expect(find.text('Ton texte'), findsOneWidget);
    });

    testWidgets('l’achat d’une instru mène à l’écriture, le texte précédent est effacé', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'nuit'), location: '/studio/instru');
      await tester.tap(find.text('Gbaka de 6h'));
      await tester.pumpAndSettle();
      expect(find.text('Écrire le texte'), findsOneWidget);
      expect(repo.current.texte, isNull);
    });
  });
}
