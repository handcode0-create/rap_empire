import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';

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

  Future<void> tapText(WidgetTester tester, String text) async {
    if (find.text(text).evaluate().isEmpty) {
      // liste paresseuse : l'élément n'est construit qu'une fois proche de l'écran
      await tester.scrollUntilVisible(find.text(text), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    }
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  group('cabine et mix (04.7, 04.9) : parcours réel', () {
    testWidgets('instru, écriture, cabine simulée, mix : 61 / 72 / 55 / 56, +30 XP', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tester.tap(find.text('Aller au studio'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Gbaka de 6h');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      expect(find.text('Session cabine'), findsOneWidget);
      expect(find.text('Étape 3 / 3'), findsOneWidget);
      expect(find.text('Micro de base'), findsOneWidget);
      await tapText(tester, 'Simuler les 3 prises');
      expect(find.text('Mix terminé'), findsOneWidget);
      expect(find.text('61'), findsOneWidget);
      expect(find.text('/ 100'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('55'), findsNWidgets(2)); // voix 55 et énergie 55 dans le HUD
      expect(find.text('56'), findsOneWidget);
      expect(find.text('+30 XP · Son ajouté au studio'), findsOneWidget);
      final s = repo.current;
      expect([s.energy, s.hour, s.xp, s.cash, s.song!.q, s.ms['m1']], [55, 11, 30, 17000, 61, 'done']);
      expect(find.text('J1 11:00'), findsOneWidget);
      await tapText(tester, 'Retour au studio');
      expect(find.text('Gbaka de 6h'), findsWidgets);
      expect(find.text('Qualité'), findsOneWidget);
      expect(find.text('Kôrô · Ndolo · 1 son'), findsOneWidget);
    });

    testWidgets('cabine avec énergie 24 : « Trop fatigué », aucun son enregistré', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 24), location: '/studio/cabine');
      await tapText(tester, 'Simuler les 3 prises');
      expect(find.text('Trop fatigué'), findsOneWidget);
      expect(repo.current.song, isNull);
    });

    testWidgets('énergie basse dans le jeu réel : deux sons de suite, « Trop fatigué » au QG, Dormir', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tester.tap(find.text('Aller au studio'));
      await tester.pumpAndSettle();
      for (final instru in ['Gbaka de 6h', 'Nuit à Ndo']) {
        await tapText(tester, 'Nouveau son');
        await tapText(tester, instru);
        await tapText(tester, 'Écrire · Sombre');
        await tapText(tester, 'Passer en cabine');
        await tapText(tester, 'Simuler les 3 prises');
        if (instru == 'Gbaka de 6h') await tapText(tester, 'Retour au studio');
      }
      expect(repo.current.energy, 10);
      expect(repo.current.song!.title, 'Nuit à Ndo');
      await tester.tap(find.text('QG'));
      await tester.pumpAndSettle();
      expect(find.text('Trop fatigué'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Dormir'));
      await tester.pumpAndSettle();
      expect(find.text('Nouvelle journée'), findsOneWidget);
      expect([repo.current.energy, repo.current.day, repo.current.hour], [100, 2, 8]);
      expect(repo.current.song, isNotNull);
    });
  });

  group('reprise de l’étape en cours (restauration au rechargement)', () {
    testWidgets('rien en cours : pas de « Reprendre »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio');
      expect(find.textContaining('Reprendre'), findsNothing);
    });
    testWidgets('instru choisie : Reprendre l’écriture', (tester) async {
      await pumpApp(tester, const GameState(inst: 'gbaka'), location: '/studio');
      await tapText(tester, 'Reprendre : Écrire le texte');
      expect(find.text('Écrire le texte'), findsOneWidget);
    });
    testWidgets('texte écrit : Reprendre la cabine', (tester) async {
      final base = write(pick(const GameState(), 'gbaka'));
      await pumpApp(tester, base, location: '/studio');
      await tapText(tester, 'Reprendre : Passer en cabine');
      expect(find.text('Session cabine'), findsOneWidget);
    });
    testWidgets('son enregistré : Reprendre sur la sortie', (tester) async {
      final base = record(write(pick(const GameState(), 'gbaka')));
      await pumpApp(tester, base, location: '/studio');
      await tapText(tester, 'Reprendre : Préparer la sortie');
      expect(find.text('Sortir le son'), findsOneWidget);
    });
    testWidgets('son déjà sorti : pas de « Reprendre », discographie visible', (tester) async {
      final base = release(record(write(pick(const GameState(), 'gbaka'))), 0);
      await pumpApp(tester, base, location: '/studio');
      expect(find.textContaining('Reprendre'), findsNothing);
      expect(find.text('Discographie'), findsOneWidget);
      expect(find.text('Q61 · 5 418 écoutes'), findsOneWidget);
    });
  });

  group('sortie (05.1, 05.2) et résultats (05.4)', () {
    // Canon : son 61 enregistré, cash porté à 22 000 comme sur les planches 05.2 et 05.4.
    final rec = record(write(pick(const GameState(), 'gbaka'))).copyWith(cash: 22000);

    testWidgets('promo et estimations : 5 418 écoutes, cash après 22 000', (tester) async {
      await pumpApp(tester, rec, location: '/studio/sortie');
      expect(find.text('Sortir le son'), findsOneWidget);
      expect(find.text('Single'), findsOneWidget);
      for (final t in ['Aucune', 'Réseaux sociaux', 'Radio locale', 'Gratuit', '2 000 cauris', '15 000 cauris', 'Audience du quartier', 'Portée moyenne', 'Portée large']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.text('Écoutes estimées · 24 h'), findsOneWidget);
      expect(find.text('5 418'), findsOneWidget);
      expect(find.text('Cash après promo'), findsOneWidget);
      expect(find.text('22 000'), findsWidgets);
    });

    testWidgets('Radio locale : 17 324 écoutes estimées, cash après 7 000', (tester) async {
      await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      expect(find.text('17 324'), findsOneWidget);
      expect(find.text('7 000'), findsOneWidget);
    });

    testWidgets('Réseaux sociaux : 8 667 écoutes estimées', (tester) async {
      await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Réseaux sociaux');
      expect(find.text('8 667'), findsOneWidget);
      expect(find.text('20 000'), findsOneWidget);
    });

    testWidgets('cash 4 200 + Radio locale (planche 05.1b) : message, -10 800, rien n’est débité', (tester) async {
      final repo = await pumpApp(tester, rec.copyWith(cash: 4200), location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      expect(find.text('Cash insuffisant · 15 000 requis, tu as 4 200'), findsOneWidget);
      expect(find.text('-10 800'), findsOneWidget);
      await tapText(tester, 'Sortir le single');
      expect(find.text('Cash insuffisant'), findsOneWidget);
      expect(find.text('Lancer la promo ?'), findsNothing);
      expect([repo.current.cash, repo.current.rel, repo.current.day], [4200, null, 1]);
    });

    testWidgets('Aucune : sortie sans confirmation, résultats 5 418 / +54 / +371 / +6, cash 22 054', (tester) async {
      final repo = await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Sortir le single');
      expect(find.text('Lancer la promo ?'), findsNothing);
      expect(find.text('Résultats · 24 h'), findsOneWidget);
      expect(find.text('5 418'), findsOneWidget);
      expect(find.text('+ 54 cauris'), findsOneWidget);
      expect(find.text('+ 371'), findsOneWidget);
      expect(find.text('+ 6'), findsOneWidget);
      expect(find.text('22 054'), findsWidgets);
      final s = repo.current;
      expect([s.cash, s.fans, s.pop, s.energy, s.day, s.hour, s.xp], [22054, 491, 9, 100, 2, 8, 70]);
      expect(s.rel!.listens, 5418);
      expect(find.text('J2 08:00'), findsOneWidget);
    });

    testWidgets('Radio locale : confirmation (cash après 7 000), annuler ne débite rien', (tester) async {
      final repo = await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      await tapText(tester, 'Sortir le single');
      expect(find.text('Lancer la promo ?'), findsOneWidget);
      expect(find.text('Cash après'), findsOneWidget);
      await tapText(tester, 'Annuler');
      expect([repo.current.cash, repo.current.rel], [22000, null]);
      expect(find.text('Lancer la promo ?'), findsNothing);
      expect(find.text('Sortir le single'), findsOneWidget);
    });

    testWidgets('Radio locale confirmée : 17 324 écoutes, +173, +1 185 fans, cash 7 173', (tester) async {
      final repo = await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      await tapText(tester, 'Sortir le single');
      await tapText(tester, 'Confirmer et sortir');
      expect(find.text('Résultats · 24 h'), findsOneWidget);
      expect(find.text('17 324'), findsOneWidget);
      expect(find.text('+ 173 cauris'), findsOneWidget);
      expect(find.text('+ 1 185'), findsOneWidget);
      expect([repo.current.cash, repo.current.fans, repo.current.pop], [7173, 1305, 22]);
    });

    testWidgets('sans son : « Aucun son prêt à sortir »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/sortie');
      expect(find.text('Aucun son prêt à sortir.'), findsOneWidget);
    });

    testWidgets('résultats sans sortie : message', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/resultats');
      expect(find.text('Aucune sortie pour l’instant.'), findsOneWidget);
    });

    testWidgets('parcours complet depuis le QG : instru, texte, cabine, mix, sortie, résultats, discographie', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tester.tap(find.text('Aller au studio'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Gbaka de 6h');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      await tapText(tester, 'Simuler les 3 prises');
      await tapText(tester, 'Préparer la sortie');
      await tapText(tester, 'Sortir le single');
      expect(find.text('Résultats · 24 h'), findsOneWidget);
      expect(find.text('5 418'), findsOneWidget);
      expect([repo.current.cash, repo.current.fans, repo.current.day, repo.current.energy], [17054, 491, 2, 100]);
      await tapText(tester, 'Retour au studio');
      expect(find.text('Discographie'), findsOneWidget);
      expect(find.text('Q61 · 5 418 écoutes'), findsOneWidget);
      expect(find.text('Kôrô · Ndolo · 1 son'), findsOneWidget);
      expect(find.textContaining('Reprendre'), findsNothing);
      // un deuxième son s’ajoute
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Nuit à Ndo');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      await tapText(tester, 'Simuler les 3 prises');
      await tapText(tester, 'Préparer la sortie');
      await tapText(tester, 'Sortir le single');
      await tapText(tester, 'Retour au studio');
      expect(find.text('Kôrô · Ndolo · 2 sons'), findsOneWidget);
      expect(repo.current.disco.map((d) => d.title), ['Gbaka de 6h', 'Nuit à Ndo']);
    });
  });
}
