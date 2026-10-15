import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';

import 'support.dart';

void main() {
  testWidgets('QG au départ : HUD, mission 1, indicateurs, bouton studio', (tester) async {
    await pumpApp(tester, const GameState());
    expect(find.text('Djo Kéné'), findsOneWidget);
    expect(find.text('N1 · INCONNU'), findsOneWidget);
    expect(find.text('25 000'), findsOneWidget);
    expect(find.text('J1 08:00'), findsOneWidget);
    expect(find.text('Mission 1'), findsOneWidget);
    expect(find.text('Enregistre ton premier son'), findsOneWidget);
    expect(find.text('Aller au studio'), findsOneWidget);
    expect(find.text('Trop fatigué'), findsNothing);
  });

  testWidgets('cinq onglets, barre de 72 px', (tester) async {
    await pumpApp(tester, const GameState());
    for (final t in ['QG', 'Studio', 'Scène', 'Business', 'Profil']) {
      expect(find.text(t), findsOneWidget);
    }
    final bar = find.byWidgetPredicate((w) => w is SizedBox && w.height == 72);
    expect(bar, findsOneWidget);
    expect(tester.getSize(bar), const Size(390, 72));
  });

  testWidgets('« Aller au studio » ouvre le studio ; Scène et Profil affichent « Bientôt »', (tester) async {
    await pumpApp(tester, const GameState());
    await tester.tap(find.text('Aller au studio'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun son enregistré'), findsOneWidget);
    expect(find.text('Bientôt'), findsNothing);
    await tester.tap(find.text('QG'));
    await tester.pumpAndSettle();
    expect(find.text('Salut, Djo'), findsOneWidget);
    await tester.tap(find.text('Scène'));
    await tester.pumpAndSettle();
    expect(find.text('Bientôt'), findsOneWidget);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Bientôt'), findsOneWidget);
  });

  testWidgets('énergie 12 (planche 03.2) : « Trop fatigué », Dormir, fin de journée (03.6)', (tester) async {
    final repo = await pumpApp(tester, const GameState(cash: 6000, energy: 12, hour: 14));
    expect(find.text('Trop fatigué'), findsOneWidget);
    expect(find.text('Nuit gratuite · démo'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Dormir'));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle journée'), findsOneWidget);
    expect(find.text('Gratuite · démo'), findsOneWidget);
    expect(find.text('100  (+88 repos)'), findsOneWidget);
    expect(repo.current.energy, 100);
    expect(repo.current.day, 2);
    expect(repo.current.hour, 8);
    expect(repo.current.cash, 6000);
    await tester.tap(find.text('Commencer le jour'));
    await tester.pumpAndSettle();
    expect(find.text('Salut, Djo'), findsOneWidget);
    expect(find.text('Trop fatigué'), findsNothing);
    expect(find.text('J2 08:00'), findsOneWidget);
  });

  testWidgets('« Pas maintenant » ferme la feuille ; le bandeau reste avec Dormir', (tester) async {
    await pumpApp(tester, const GameState(energy: 12));
    await tester.tap(find.text('Pas maintenant'));
    await tester.pumpAndSettle();
    expect(find.text('Trop fatigué'), findsNothing);
    expect(find.textContaining('Énergie basse (12)'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Dormir'), findsOneWidget);
  });

  testWidgets('énergie 20 : pas de feuille ni de bandeau', (tester) async {
    await pumpApp(tester, const GameState(energy: 20));
    expect(find.text('Trop fatigué'), findsNothing);
    expect(find.textContaining('Énergie basse'), findsNothing);
  });
}
