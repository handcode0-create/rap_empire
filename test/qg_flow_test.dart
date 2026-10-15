import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/widgets/game_nav_bar.dart';
import 'package:rap_empire/domain/game_state.dart';

import 'support.dart';

void main() {
  testWidgets('QG au départ : HUD, mission 1, indicateurs, bouton studio', (tester) async {
    await pumpApp(tester, const GameState());
    expect(txt('Djo Kéné'), findsOneWidget);
    expect(txt('N1 · INCONNU'), findsOneWidget);
    expect(txt('25 000'), findsOneWidget);
    expect(txt('J1 08:00'), findsOneWidget);
    expect(txt('Mission 1'), findsOneWidget);
    expect(txt('Enregistre ton premier son'), findsOneWidget);
    expect(txt('Aller au studio'), findsOneWidget);
    expect(txt('Trop fatigué'), findsNothing);
  });

  testWidgets('cinq onglets, barre de 72 px', (tester) async {
    await pumpApp(tester, const GameState());
    for (final t in ['QG', 'Studio', 'Scène', 'Business', 'Profil']) {
      expect(navTab(t), findsOneWidget);
    }
    final bar = find.descendant(of: find.byType(GameNavBar), matching: find.byWidgetPredicate((w) => w is SizedBox && w.height == 72));
    expect(bar, findsOneWidget);
    expect(tester.getSize(bar), const Size(390, 72));
  });

  testWidgets('« Aller au studio » ouvre le studio ; Scène et Profil affichent « Bientôt »', (tester) async {
    await pumpApp(tester, const GameState());
    await tester.tap(txt('Aller au studio'));
    await tester.pumpAndSettle();
    expect(txt('Aucun son enregistré'), findsOneWidget);
    expect(txt('Bientôt'), findsNothing);
    await tester.tap(navTab('QG'));
    await tester.pumpAndSettle();
    expect(txt('Salut, Djo'), findsOneWidget);
    await tester.tap(navTab('Scène'));
    await tester.pumpAndSettle();
    expect(txt('Bientôt'), findsOneWidget);
    await tester.tap(navTab('Profil'));
    await tester.pumpAndSettle();
    expect(txt('Bientôt'), findsOneWidget);
  });

  testWidgets('énergie 12 (planche 03.2) : « Trop fatigué », Dormir, fin de journée (03.6)', (tester) async {
    final repo = await pumpApp(tester, const GameState(cash: 6000, energy: 12, hour: 14));
    expect(txt('Trop fatigué'), findsOneWidget);
    expect(txt('Nuit gratuite · démo'), findsOneWidget);
    await tester.tap(txt('Dormir'));
    await tester.pumpAndSettle();
    expect(txt('Nouvelle journée'), findsOneWidget);
    expect(txt('Nuit passée'), findsOneWidget);
    expect(txt('Énergie'), findsWidgets);
    expect(txt('+ repos'), findsOneWidget);
    expect(txt('Nuit'), findsOneWidget);
    expect(txt('Gratuite'), findsOneWidget);
    expect(txt('démo'), findsOneWidget);
    expect(txt('Commencer le jour'), findsOneWidget);
    expect(txt('Retour au QG'), findsOneWidget);
    expect(repo.current.energy, 100);
    expect(repo.current.day, 2);
    expect(repo.current.hour, 8);
    expect(repo.current.cash, 6000);
    await tester.tap(txt('Commencer le jour'));
    await tester.pumpAndSettle();
    expect(txt('Salut, Djo'), findsOneWidget);
    expect(txt('Trop fatigué'), findsNothing);
    expect(txt('J2 08:00'), findsOneWidget);
  });

  testWidgets('« Pas maintenant » ferme la feuille ; le bandeau d’énergie la rouvre', (tester) async {
    await pumpApp(tester, const GameState(energy: 12));
    await tester.tap(txt('Pas maintenant'));
    await tester.pumpAndSettle();
    expect(txt('Trop fatigué'), findsNothing);
    expect(find.textContaining('Énergie basse (12)'), findsOneWidget);
    await tester.tap(find.textContaining('Énergie basse (12)'));
    await tester.pumpAndSettle();
    expect(txt('Trop fatigué'), findsOneWidget);
    expect(txt('Dormir'), findsOneWidget);
  });

  testWidgets('énergie 20 : pas de feuille ni de bandeau', (tester) async {
    await pumpApp(tester, const GameState(energy: 20));
    expect(txt('Trop fatigué'), findsNothing);
    expect(find.textContaining('Énergie basse'), findsNothing);
  });
}
