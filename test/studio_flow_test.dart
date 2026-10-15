import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

import 'support.dart';

/// Parcours d'interface du studio, état injecté puis vérifié dans la sauvegarde locale factice.
void main() {
  Future<void> openInstru(WidgetTester tester) async {
    await tester.tap(navTab('Studio'));
    await tester.pumpAndSettle();
    await tester.tap(txt('Nouveau son'));
    await tester.pumpAndSettle();
  }

  group('instrus (04.3, 04.4)', () {
    testWidgets('les quatre instrus et leurs verrous sont affichés', (tester) async {
      await pumpApp(tester, const GameState());
      await openInstru(tester);
      expect(txt('Choisis une instru'), findsOneWidget);
      expect(txt('Étape 1 / 3'), findsOneWidget);
      for (final t in ['Nuit à Ndo', 'Gbaka de 6h', 'Pont des Griots', "Lagune d'Ambre", 'Gratuit', '8 000 cauris', '15 000 cauris', '40 000 cauris', 'N2', 'Rép. 30']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('Gbaka (8 000) : achat direct, sans confirmation, puis écran d écriture', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(txt('Gbaka de 6h'));
      await tester.pumpAndSettle();
      expect(txt('Confirmation'), findsNothing);
      expect([repo.current.cash, repo.current.inst], [17000, 'gbaka']);
      expect(txt('Écrire le texte'), findsOneWidget);
      expect(txt('Étape 2 / 3'), findsOneWidget);
    });

    testWidgets('Nuit à Ndo : gratuite', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(txt('Nuit à Ndo'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [25000, 'nuit']);
    });

    testWidgets('Pont au niveau 1 : message « Niveau requis », rien n\'est débité', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(txt('Pont des Griots'));
      await tester.pumpAndSettle();
      expect(txt('Niveau requis'), findsOneWidget);
      expect(txt('Confirmation'), findsNothing);
      expect([repo.current.cash, repo.current.inst], [25000, null]);
    });

    testWidgets('Lagune réputation 8 : « Réputation requise »', (tester) async {
      await pumpApp(tester, const GameState());
      await openInstru(tester);
      await tester.tap(txt("Lagune d'Ambre"));
      await tester.pumpAndSettle();
      expect(txt('Réputation requise'), findsOneWidget);
    });

    testWidgets('Gbaka avec 7 999 cauris : « Cash insuffisant »', (tester) async {
      await pumpApp(tester, const GameState(cash: 7999));
      await openInstru(tester);
      await tester.tap(txt('Gbaka de 6h'));
      await tester.pumpAndSettle();
      expect(txt('Cash insuffisant'), findsOneWidget);
    });

    testWidgets('Pont niveau 2 : confirmation à 15 000, cash après achat, achat', (tester) async {
      final repo = await pumpApp(tester, const GameState(xp: 100));
      await openInstru(tester);
      await tester.tap(txt('Pont des Griots'));
      await tester.pumpAndSettle();
      expect(txt('Acheter Pont des Griots ?'), findsOneWidget);
      expect(txt('Cash après achat'), findsOneWidget);
      expect(txt('10 000 cauris'), findsOneWidget);
      await tester.tap(txt('Acheter  − 15 000 cauris'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [10000, 'pont']);
    });

    testWidgets('Annuler la confirmation : rien n\'est débité', (tester) async {
      final repo = await pumpApp(tester, const GameState(xp: 100));
      await openInstru(tester);
      await tester.tap(txt('Pont des Griots'));
      await tester.pumpAndSettle();
      await tester.tap(txt('Annuler'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [25000, null]);
    });

    testWidgets('Lagune réputation 30, 50 000 cauris : confirmation puis 10 000 cauris', (tester) async {
      final repo = await pumpApp(tester, const GameState(rep: 30, cash: 50000));
      await openInstru(tester);
      await tester.tap(txt("Lagune d'Ambre"));
      await tester.pumpAndSettle();
      expect(txt("Acheter Lagune d'Ambre ?"), findsOneWidget);
      await tester.tap(txt('Acheter  − 40 000 cauris'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.inst], [10000, 'lagune']);
    });
  });

  group('écriture (04.5, 04.6)', () {
    const gbaka = GameState(inst: 'gbaka', cash: 17000);

    testWidgets('choix du thème et de l’ambiance, rappel de l’instru', (tester) async {
      await pumpApp(tester, gbaka, location: '/studio/ecriture');
      expect(txt('Écrire le texte'), findsOneWidget);
      expect(txt('Étape 2 / 3'), findsOneWidget);
      expect(txt('Gbaka de 6h'), findsOneWidget);
      expect(txt('· qualité 56'), findsOneWidget);
      for (final t in ['Le quartier', 'La galère', "L'ambition", "L'amour", 'Écrire · Sombre', 'Écrire · Fière', 'Écrire · Légère']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('Écrire · Sombre : note 72, énergie 80, 09:00, écriture +2', (tester) async {
      final repo = await pumpApp(tester, gbaka, location: '/studio/ecriture');
      await tester.tap(txt('Écrire · Sombre'));
      await tester.pumpAndSettle();
      expect(txt('Ton texte'), findsOneWidget);
      expect(txt('72'), findsWidgets);
      expect(txt('Écriture +2 · −20 énergie · 1 h'), findsOneWidget);
      expect([repo.current.texte!.note, repo.current.energy, repo.current.hour, repo.current.sk['ecr']], [72, 80, 9, 16]);
    });

    testWidgets('La galère + Fière : note 75', (tester) async {
      final repo = await pumpApp(tester, gbaka, location: '/studio/ecriture');
      await tester.tap(txt('La galère'));
      await tester.pump();
      await tester.tap(txt('Écrire · Fière'));
      await tester.pumpAndSettle();
      expect(repo.current.texte!.note, 75);
      expect(txt('La galère · Fière'), findsOneWidget);
    });

    testWidgets('Réécrire revient au choix et remplace le texte (énergie 60)', (tester) async {
      final repo = await pumpApp(tester, gbaka, location: '/studio/ecriture');
      await tester.tap(txt('Écrire · Sombre'));
      await tester.pumpAndSettle();
      await tester.tap(txt('Réécrire'));
      await tester.pumpAndSettle();
      expect(txt('Écrire · Légère'), findsOneWidget);
      await tester.ensureVisible(txt('Écrire · Légère'));
      await tester.pumpAndSettle();
      await tester.tap(txt('Écrire · Légère'));
      await tester.pumpAndSettle();
      expect([repo.current.texte!.note, repo.current.energy, repo.current.sk['ecr']], [70, 60, 18]);
    });

    testWidgets('énergie 19 : « Trop fatigué » avec Dormir, rien n’est écrit', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 19), location: '/studio/ecriture');
      await tester.tap(txt('Écrire · Sombre'));
      await tester.pumpAndSettle();
      expect(txt('Trop fatigué'), findsOneWidget);
      expect(txt('Dormir'), findsOneWidget);
      expect(repo.current.texte, isNull);
    });

    testWidgets('énergie 20 : écriture permise, énergie à 0', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 20), location: '/studio/ecriture');
      await tester.tap(txt('Écrire · Sombre'));
      await tester.pumpAndSettle();
      expect(repo.current.energy, 0);
      expect(txt('Ton texte'), findsOneWidget);
    });

    testWidgets('l’achat d’une instru mène à l’écriture, le texte précédent est effacé', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'nuit'), location: '/studio/instru');
      await tester.tap(txt('Gbaka de 6h'));
      await tester.pumpAndSettle();
      expect(txt('Écrire le texte'), findsOneWidget);
      expect(repo.current.texte, isNull);
    });
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    if (txt(text).evaluate().isEmpty) {
      // liste paresseuse : l'élément n'est construit qu'une fois proche de l'écran
      await tester.scrollUntilVisible(txt(text), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    }
    await tester.ensureVisible(txt(text));
    await tester.pumpAndSettle();
    await tester.tap(txt(text));
    await tester.pumpAndSettle();
  }

  group('cabine et mix (04.7, 04.9) : parcours réel', () {
    testWidgets('instru, écriture, cabine simulée, mix : 61 / 72 / 55 / 56, +30 XP', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tester.tap(txt('Aller au studio'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Gbaka de 6h');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      expect(txt('Session cabine'), findsOneWidget);
      expect(txt('Étape 3 / 3'), findsOneWidget);
      expect(txt('Micro de base'), findsOneWidget);
      await tapText(tester, 'Simuler les 3 prises');
      expect(txt('Mix terminé'), findsOneWidget);
      expect(txt('61'), findsOneWidget);
      expect(txt('/ 100'), findsOneWidget);
      expect(txt('72'), findsOneWidget);
      expect(txt('55'), findsNWidgets(2)); // voix 55 et énergie 55 dans le HUD
      expect(txt('56'), findsOneWidget);
      expect(txt('+30 XP · Son ajouté au studio'), findsOneWidget);
      final s = repo.current;
      expect([s.energy, s.hour, s.xp, s.cash, s.song!.q, s.ms['m1']], [55, 11, 30, 17000, 61, 'done']);
      expect(txt('J1 11:00'), findsOneWidget);
      await tapText(tester, 'Retour au studio');
      expect(txt('Gbaka de 6h'), findsWidgets);
      expect(txt('Qualité'), findsOneWidget);
      expect(txt('Kôrô · Ndolo · 1 son'), findsOneWidget);
    });

    testWidgets('cabine avec énergie 24 : « Trop fatigué », aucun son enregistré', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 24), location: '/studio/cabine');
      await tapText(tester, 'Simuler les 3 prises');
      expect(txt('Trop fatigué'), findsOneWidget);
      expect(repo.current.song, isNull);
    });

    testWidgets('énergie basse dans le jeu réel : deux sons de suite, « Trop fatigué » au QG, Dormir', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tester.tap(txt('Aller au studio'));
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
      await tester.tap(navTab('QG'));
      await tester.pumpAndSettle();
      expect(txt('Trop fatigué'), findsOneWidget);
      await tester.tap(txt('Dormir'));
      await tester.pumpAndSettle();
      expect(txt('Nouvelle journée'), findsOneWidget);
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
      expect(txt('Écrire le texte'), findsOneWidget);
    });
    testWidgets('texte écrit : Reprendre la cabine', (tester) async {
      final base = write(pick(const GameState(), 'gbaka'));
      await pumpApp(tester, base, location: '/studio');
      await tapText(tester, 'Reprendre : Passer en cabine');
      expect(txt('Session cabine'), findsOneWidget);
    });
    testWidgets('son enregistré : Reprendre sur la sortie', (tester) async {
      final base = record(write(pick(const GameState(), 'gbaka')));
      await pumpApp(tester, base, location: '/studio');
      await tapText(tester, 'Reprendre : Préparer la sortie');
      expect(txt('Sortir le son'), findsOneWidget);
    });
    testWidgets('son déjà sorti : pas de « Reprendre », discographie visible', (tester) async {
      final base = release(record(write(pick(const GameState(), 'gbaka'))), 0);
      await pumpApp(tester, base, location: '/studio');
      expect(find.textContaining('Reprendre'), findsNothing);
      expect(txt('Discographie'), findsOneWidget);
      expect(txt('Q61 · 5 418 écoutes'), findsOneWidget);
    });
  });

  group('sortie (05.1, 05.2) et résultats (05.4)', () {
    // Canon : son 61 enregistré, cash porté à 22 000 comme sur les planches 05.2 et 05.4.
    final rec = record(write(pick(const GameState(), 'gbaka'))).copyWith(cash: 22000);

    testWidgets('promo et estimations : 5 418 écoutes, cash après 22 000', (tester) async {
      await pumpApp(tester, rec, location: '/studio/sortie');
      expect(txt('Sortir le son'), findsOneWidget);
      expect(txt('Single'), findsOneWidget);
      for (final t in ['Aucune', 'Réseaux sociaux', 'Radio locale', 'Gratuit', '2 000 cauris', '15 000 cauris', 'Audience du quartier', 'Portée moyenne', 'Portée large']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(txt('Écoutes estimées · 24 h'), findsOneWidget);
      expect(txt('5 418'), findsOneWidget);
      expect(txt('Cash après promo'), findsOneWidget);
      expect(txt('22 000'), findsWidgets);
    });

    testWidgets('Radio locale : 17 324 écoutes estimées, cash après 7 000', (tester) async {
      await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      expect(txt('17 324'), findsOneWidget);
      expect(txt('7 000'), findsOneWidget);
    });

    testWidgets('Réseaux sociaux : 8 667 écoutes estimées', (tester) async {
      await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Réseaux sociaux');
      expect(txt('8 667'), findsOneWidget);
      expect(txt('20 000'), findsOneWidget);
    });

    testWidgets('cash 4 200 + Radio locale (planche 05.1b) : message, -10 800, rien n’est débité', (tester) async {
      final repo = await pumpApp(tester, rec.copyWith(cash: 4200), location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      expect(txt('Cash insuffisant · 15 000 requis, tu as 4 200'), findsOneWidget);
      expect(txt('-10 800'), findsOneWidget);
      await tapText(tester, 'Sortir le single');
      expect(txt('Cash insuffisant'), findsOneWidget);
      expect(txt('Lancer la promo ?'), findsNothing);
      expect([repo.current.cash, repo.current.rel, repo.current.day], [4200, null, 1]);
    });

    testWidgets('Aucune : sortie sans confirmation, résultats 5 418 / +54 / +371 / +6, cash 22 054', (tester) async {
      final repo = await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Sortir le single');
      expect(txt('Lancer la promo ?'), findsNothing);
      expect(txt('Résultats · 24 h'), findsOneWidget);
      expect(txt('5 418'), findsOneWidget);
      expect(txt('+ 54 cauris'), findsOneWidget);
      expect(txt('+ 371'), findsOneWidget);
      expect(txt('+ 6'), findsOneWidget);
      expect(txt('22 054'), findsWidgets);
      final s = repo.current;
      expect([s.cash, s.fans, s.pop, s.energy, s.day, s.hour, s.xp], [22054, 491, 9, 100, 2, 8, 70]);
      expect(s.rel!.listens, 5418);
      expect(txt('J2 08:00'), findsOneWidget);
    });

    testWidgets('Radio locale : confirmation (cash après 7 000), annuler ne débite rien', (tester) async {
      final repo = await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      await tapText(tester, 'Sortir le single');
      expect(txt('Lancer la promo ?'), findsOneWidget);
      expect(txt('Cash après'), findsOneWidget);
      await tapText(tester, 'Annuler');
      expect([repo.current.cash, repo.current.rel], [22000, null]);
      expect(txt('Lancer la promo ?'), findsNothing);
      expect(txt('Sortir le single'), findsOneWidget);
    });

    testWidgets('Radio locale confirmée : 17 324 écoutes, +173, +1 185 fans, cash 7 173', (tester) async {
      final repo = await pumpApp(tester, rec, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      await tapText(tester, 'Sortir le single');
      await tapText(tester, 'Confirmer et sortir');
      expect(txt('Résultats · 24 h'), findsOneWidget);
      expect(txt('17 324'), findsOneWidget);
      expect(txt('+ 173 cauris'), findsOneWidget);
      expect(txt('+ 1 185'), findsOneWidget);
      expect([repo.current.cash, repo.current.fans, repo.current.pop], [7173, 1305, 22]);
    });

    testWidgets('sans son : « Aucun son prêt à sortir »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/sortie');
      expect(txt('Aucun son prêt à sortir.'), findsOneWidget);
    });

    testWidgets('résultats sans sortie : message', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/resultats');
      expect(txt('Aucune sortie pour l’instant.'), findsOneWidget);
    });

    testWidgets('parcours complet depuis le QG : instru, texte, cabine, mix, sortie, résultats, discographie', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tester.tap(txt('Aller au studio'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Gbaka de 6h');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      await tapText(tester, 'Simuler les 3 prises');
      await tapText(tester, 'Préparer la sortie');
      await tapText(tester, 'Sortir le single');
      expect(txt('Résultats · 24 h'), findsOneWidget);
      expect(txt('5 418'), findsOneWidget);
      expect([repo.current.cash, repo.current.fans, repo.current.day, repo.current.energy], [17054, 491, 2, 100]);
      await tapText(tester, 'Retour au studio');
      expect(txt('Discographie'), findsOneWidget);
      expect(txt('Q61 · 5 418 écoutes'), findsOneWidget);
      expect(txt('Kôrô · Ndolo · 1 son'), findsOneWidget);
      expect(find.textContaining('Reprendre'), findsNothing);
      // un deuxième son s’ajoute
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Nuit à Ndo');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      await tapText(tester, 'Simuler les 3 prises');
      expect(txt('Niveau supérieur'), findsOneWidget); // 30 + 40 + 30 = 100 XP : N2 dès le 2e enregistrement
      await tapText(tester, 'Continuer');
      await tapText(tester, 'Préparer la sortie');
      await tapText(tester, 'Sortir le single');
      await tapText(tester, 'Retour au studio');
      expect(txt('Kôrô · Ndolo · 2 sons'), findsOneWidget);
      expect(repo.current.disco.map((d) => d.title), ['Gbaka de 6h', 'Nuit à Ndo']);
    });
  });

  group('missions et niveau (10.1, 10.4)', () {
    final rec = record(write(pick(const GameState(), 'gbaka')));

    testWidgets('départ : mission 1, jauge vide, pas de bouton Récupérer', (tester) async {
      await pumpApp(tester, const GameState());
      expect(txt('Mission 1'), findsOneWidget);
      expect(txt('Enregistre ton premier son'), findsOneWidget);
      expect(txt('Aller au studio'), findsOneWidget);
      expect(txt('Terminée'), findsNothing);
      expect(txt('Récupérer'), findsNothing);
    });

    testWidgets('mission 1 terminée : Récupérer verse 5 000 cauris et 50 XP, puis la mission 2 apparaît', (tester) async {
      final repo = await pumpApp(tester, rec);
      expect(txt('Terminée'), findsOneWidget);
      expect(txt('+5 000'), findsOneWidget);
      expect(txt('+50'), findsOneWidget);
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m1']], [22000, 80, 'claimed']);
      expect(txt('Mission accomplie · +5 000 cauris · +50 XP'), findsOneWidget);
      expect(txt('Mission 2'), findsOneWidget);
      expect(txt('Sors ton premier single'), findsOneWidget);
      expect(txt('Ton son est prêt : choisis la promo et mets-le en ligne.'), findsOneWidget);
      expect(txt('Niveau supérieur'), findsNothing);
    });

    testWidgets('mission 2 terminée après la sortie : Récupérer verse 10 000 cauris et 80 XP', (tester) async {
      final s = claim(rec, 'm1');
      final released = ack(release(s, 0));
      final repo = await pumpApp(tester, released);
      expect(txt('Mission 2'), findsOneWidget);
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m2']], [34054, 200, 'claimed']);
      expect(txt('Mission 1'), findsNothing);
      expect(txt('Mission 2'), findsNothing);
      expect(txt('OBJECTIF EN COURS'), findsNothing);
    });

    testWidgets('60 XP + mission 1 : la feuille « Niveau supérieur » N2 apparaît avec 2 000 cauris', (tester) async {
      final repo = await pumpApp(tester, rec.copyWith(xp: 60));
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect(txt('Niveau supérieur'), findsOneWidget);
      expect(txt('N2'), findsWidgets);
      expect(txt('Espoir du quartier'), findsWidgets);
      expect(txt('Nouvelles options : open mic, instru Pont des Griots, missions avancées.'), findsOneWidget);
      expect(txt('+ 2 000 cauris'), findsOneWidget);
      expect(repo.current.pend, const Pending(2, 2000));
      expect(repo.current.cash, 22000);
      await tester.tap(txt('Continuer'));
      await tester.pumpAndSettle();
      expect(txt('Niveau supérieur'), findsNothing);
      expect([repo.current.cash, repo.current.pend, repo.current.level], [24000, null, 2]);
      expect(txt('N2 · ESPOIR DU QUARTIER'), findsOneWidget);
    });

    testWidgets('niveau en attente dans la sauvegarde : la feuille s’ouvre au rechargement, une seule fois', (tester) async {
      final repo = await pumpApp(tester, const GameState(xp: 120, pend: Pending(2, 2000), cash: 5000));
      expect(txt('Niveau supérieur'), findsOneWidget);
      await tester.tap(txt('Continuer'));
      await tester.pumpAndSettle();
      expect(txt('Niveau supérieur'), findsNothing);
      expect([repo.current.cash, repo.current.pend], [7000, null]);
      await tester.tap(navTab('Studio'));
      await tester.pumpAndSettle();
      expect(txt('Niveau supérieur'), findsNothing);
    });

    testWidgets('la sortie qui fait passer N2 ouvre la feuille sur l’écran des résultats', (tester) async {
      final repo = await pumpApp(tester, rec.copyWith(xp: 80), location: '/studio/sortie');
      await tapText(tester, 'Sortir le single');
      expect(txt('Résultats · 24 h'), findsOneWidget);
      expect(txt('Niveau supérieur'), findsOneWidget);
      await tester.tap(txt('Continuer'));
      await tester.pumpAndSettle();
      expect([repo.current.pend, repo.current.cash, repo.current.level], [null, 19054, 2]);
    });

    testWidgets('parcours : cabine, récupérer la mission 1 au QG, sortie, niveau, mission 2', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tester.tap(txt('Aller au studio'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Gbaka de 6h');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      await tapText(tester, 'Simuler les 3 prises');
      await tester.tap(navTab('QG'));
      await tester.pumpAndSettle();
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp], [22000, 80]);
      await tester.pump(const Duration(seconds: 4)); // la bulle « Mission accomplie » disparaît
      await tester.pumpAndSettle();
      expect(txt('Mission 2'), findsOneWidget);
      await tester.tap(txt('Préparer la sortie')); // le son est prêt : le bouton du QG mène à la sortie
      await tester.pumpAndSettle();
      await tapText(tester, 'Sortir le single');
      expect(txt('Niveau supérieur'), findsOneWidget); // 80 + 40 = 120 XP
      await tapText(tester, 'Continuer');
      expect([repo.current.cash, repo.current.xp, repo.current.level], [24054, 120, 2]);
      await tester.tap(navTab('QG'));
      await tester.pumpAndSettle();
      expect(txt('Mission 2'), findsOneWidget);
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m2']], [34054, 200, 'claimed']);
    });
  });
}
