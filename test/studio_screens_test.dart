import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/widgets/game_nav_bar.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/minigame.dart';
import 'package:rap_empire/domain/studio.dart';

import 'support.dart';

/// Écrans du studio refaits à l'identique des planches v20 : 04.1 à 04.9 et 05.1 à 05.4. Sauvegarde locale factice, sans Supabase.
void main() {
  final picked = pick(const GameState(), 'gbaka');
  final written = write(picked);
  final rec = record(written);

  group('studio (04.1, 04.2)', () {
    testWidgets('04.1 studio vide : bannière, texte, bouton, tuiles, navigation visible', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio');
      expect(txt('Studio Kôrô · Ndolo'), findsOneWidget);
      expect(txt('Aucun son enregistré'), findsOneWidget);
      expect(txt('Choisis une instru, écris ton texte, passe en cabine. Ton premier son ouvre la sortie, les fans et le classement.'), findsOneWidget);
      expect(txt('Nouveau son'), findsOneWidget);
      expect(txt('3 étapes : instru · texte · cabine'), findsOneWidget);
      expect(txt('Instrus'), findsOneWidget);
      expect(txt('Matériel'), findsOneWidget);
      expect(find.byType(GameNavBar), findsOneWidget);
    });

    testWidgets('04.2 un son à sortir : carte, KPI, un seul son à la fois, deux boutons', (tester) async {
      await pumpApp(tester, rec.copyWith(cash: 22000), location: '/studio');
      for (final t in ['Studio', '1 son', 'Gbaka de 6h', 'Drill de Bakoma · instru Gbaka de 6h', 'Qualité', '61', 'Texte', '72', 'Voix', '55', 'Prod.', '56']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(txt('Un seul son à la fois : sors celui-ci pour en enregistrer un autre.'), findsOneWidget); // remplace « Emplacement libre » (faux depuis le blocage du pick)
      expect(txt('Préparer la sortie'), findsOneWidget);
      expect(txt('Single · promo · mise en ligne'), findsOneWidget);
      expect(txt('Nouveau son'), findsOneWidget);
    });

    testWidgets('Nouveau son ouvre le choix d\'instru, sans barre de navigation', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio');
      await tapText(tester, 'Nouveau son');
      expect(txt('Choisis une instru'), findsOneWidget);
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('Matériel : « bientôt »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio');
      await tapText(tester, 'Matériel');
      expect(txt('Matériel : bientôt'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('reprise : instru choisie -> écriture ; texte écrit -> cabine ; rien -> pas de « Reprendre »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio');
      expect(txt('Reprendre'), findsNothing);
      await pumpApp(tester, picked, location: '/studio');
      expect(txt('Reprendre'), findsOneWidget);
      expect(txt('Étape 2 / 3'), findsOneWidget);
      await tapText(tester, 'Reprendre');
      expect(txt('Écrire le texte'), findsOneWidget);
      await pumpApp(tester, written, location: '/studio');
      expect(txt('Session cabine'), findsOneWidget);
      await tapText(tester, 'Reprendre');
      expect(txt('Entrer en cabine'), findsOneWidget);
    });

    testWidgets('son déjà sorti : discographie visible, plus de « Reprendre »', (tester) async {
      await pumpApp(tester, release(rec, 0), location: '/studio');
      expect(txt('Discographie'), findsOneWidget);
      expect(txt('Qualité 61'), findsOneWidget);
      expect(txt('5 418 écoutes'), findsOneWidget);
      expect(txt('1 son'), findsOneWidget);
      expect(txt('Reprendre'), findsNothing);
    });
  });

  group('instrus (04.3, 04.4)', () {
    Future<FakeRepo> openInstru(WidgetTester tester, GameState s) => pumpApp(tester, s, location: '/studio/instru');

    testWidgets('les quatre instrus, prix, qualités, verrous et l\'instru choisie', (tester) async {
      await pumpApp(tester, const GameState(inst: 'gbaka'), location: '/studio/instru', height: 1400);
      expect(txt('Étape 1 / 3'), findsOneWidget);
      for (final t in ['Nuit à Ndo', 'Gbaka de 6h', 'Pont des Griots', "Lagune d'Ambre", 'Gratuit', '8 000 cauris', '15 000 cauris', '40 000 cauris', 'Q32', 'Q56', 'N2', 'Rép. 30', 'DJ Kôrô', 'Sanko Beats', 'Mister Wôrô']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(txt('Une instru achetée est facturée tout de suite. Au-delà de 15 000 cauris, une confirmation est demandée.'), findsOneWidget);
    });

    testWidgets('Gbaka (8 000) : achat direct puis écran d\'écriture', (tester) async {
      final repo = await openInstru(tester, const GameState());
      await tapText(tester, 'Gbaka de 6h');
      expect(txt('Confirmation'), findsNothing);
      expect([repo.current.cash, repo.current.inst], [17000, 'gbaka']);
      expect(txt('Écrire le texte'), findsOneWidget);
      expect(txt('Étape 2 / 3'), findsOneWidget);
    });

    testWidgets('Nuit à Ndo : gratuite', (tester) async {
      final repo = await openInstru(tester, const GameState());
      await tapText(tester, 'Nuit à Ndo');
      expect([repo.current.cash, repo.current.inst], [25000, 'nuit']);
    });

    testWidgets('Pont au niveau 1 : « Niveau requis », rien n\'est débité', (tester) async {
      final repo = await openInstru(tester, const GameState());
      await tapText(tester, 'Pont des Griots');
      expect(txt('Niveau requis'), findsOneWidget);
      expect(txt('Confirmation'), findsNothing);
      expect([repo.current.cash, repo.current.inst], [25000, null]);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Lagune réputation 8 : « Réputation requise »', (tester) async {
      await openInstru(tester, const GameState());
      await tapText(tester, "Lagune d'Ambre");
      expect(txt('Réputation requise'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Gbaka avec 7 999 cauris : « Cash insuffisant »', (tester) async {
      await openInstru(tester, const GameState(cash: 7999));
      await tapText(tester, 'Gbaka de 6h');
      expect(txt('Cash insuffisant'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('04.4 Pont niveau 2 : feuille de confirmation, cash après achat, achat', (tester) async {
      final repo = await openInstru(tester, const GameState(xp: 100));
      await tapText(tester, 'Pont des Griots');
      expect(txt('Confirmation'), findsOneWidget);
      expect(txt('Acheter Pont des Griots ?'), findsOneWidget);
      expect(txt('Achat supérieur à 15 000 cauris. Réservé au niveau 2 ou plus.'), findsOneWidget);
      expect(txt('Prix'), findsOneWidget);
      expect(txt('Cash après achat'), findsOneWidget);
      expect(txt('10 000 cauris'), findsOneWidget);
      expect(txt('− 15 000 cauris'), findsOneWidget);
      await tapText(tester, 'Acheter');
      expect([repo.current.cash, repo.current.inst], [10000, 'pont']);
      expect(txt('Écrire le texte'), findsOneWidget);
    });

    testWidgets('Annuler la confirmation : rien n\'est débité', (tester) async {
      final repo = await openInstru(tester, const GameState(xp: 100));
      await tapText(tester, 'Pont des Griots');
      await tapText(tester, 'Annuler');
      expect([repo.current.cash, repo.current.inst], [25000, null]);
      expect(txt('Confirmation'), findsNothing);
    });

    testWidgets('Lagune réputation 30, 50 000 cauris : confirmation puis 10 000 cauris', (tester) async {
      final repo = await openInstru(tester, const GameState(rep: 30, cash: 50000));
      await tapText(tester, "Lagune d'Ambre");
      expect(txt("Acheter Lagune d'Ambre ?"), findsOneWidget);
      expect(txt('Achat supérieur à 15 000 cauris. Réservé à la réputation 30 ou plus.'), findsOneWidget);
      await tapText(tester, 'Acheter');
      expect([repo.current.cash, repo.current.inst], [10000, 'lagune']);
    });

    testWidgets('retour : studio', (tester) async {
      await openInstru(tester, const GameState());
      await tapBack(tester);
      expect(txt('Aucun son enregistré'), findsOneWidget);
    });
  });

  group('écriture (04.5, 04.6)', () {
    testWidgets('04.5 : instru, dix thèmes à choisir, trois ambiances', (tester) async {
      await pumpApp(tester, picked, location: '/studio/ecriture');
      expect(txt('Écrire le texte'), findsOneWidget);
      expect(txt('Étape 2 / 3'), findsOneWidget);
      expect(txt('Gbaka de 6h · qualité 56'), findsOneWidget);
      for (final t in ['Rue et survie', 'Argent et réussite', 'Ambition et ascension', 'Amour et relations', 'Introspection et mélancolie', 'Gloire et héritage', 'Difficultés, loyauté, rivalité, respect, débrouillardise.', 'Écrire · Sombre', 'Écrire · Fière', 'Écrire · Légère']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(txt('1 h · −20 énergie'), findsNWidgets(3));
    });

    testWidgets('Écrire · Sombre : 04.6 note 72, énergie 80, 09:00, écriture +2', (tester) async {
      final repo = await pumpApp(tester, picked, location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Sombre');
      expect(txt('Ton texte'), findsOneWidget);
      expect(txt('72'), findsWidgets);
      expect(txt('Note texte'), findsOneWidget);
      expect(txt('Estimé'), findsOneWidget);
      expect(txt('Écriture +2'), findsOneWidget);
      expect(txt('−20 énergie · 1 h'), findsOneWidget);
      expect(txt('Passer en cabine'), findsOneWidget);
      expect(txt('Étape 3 / 3'), findsOneWidget);
      expect([repo.current.texte!.note, repo.current.energy, repo.current.hour, repo.current.sk['ecr'], repo.current.texte!.theme], [72, 80, 9, 16, 'rue']);
    });

    testWidgets('valeurs de la planche : extrait du texte, Rimes 70, Images 74', (tester) async {
      await pumpApp(tester, written, location: '/studio/ecriture');
      expect(find.textContaining('Gbaka de six heures, le quartier se réveille'), findsOneWidget);
      expect(txt('Rimes'), findsOneWidget);
      expect(txt('70'), findsOneWidget);
      expect(txt('Images'), findsOneWidget);
      expect(txt('74'), findsOneWidget);
    });

    testWidgets('Fière : note 74 ; Légère : note 70', (tester) async {
      final repo = await pumpApp(tester, picked, location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Fière');
      expect(repo.current.texte!.note, 74);
      await tapBack(tester); // 04.6 -> retour au choix d'ambiance
      await tapText(tester, 'Écrire · Légère');
      expect([repo.current.texte!.note, repo.current.energy, repo.current.sk['ecr']], [70, 60, 18]);
    });

    testWidgets('énergie 19 : « Trop fatigué » avec Dormir, rien n\'est écrit', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 19), location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Sombre');
      expect(txt('Trop fatigué'), findsOneWidget);
      expect(txt('Dormir'), findsOneWidget);
      expect(repo.current.texte, isNull);
    });

    testWidgets('énergie 20 : écriture permise, énergie à 0', (tester) async {
      final repo = await pumpApp(tester, const GameState(inst: 'gbaka', energy: 20), location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Sombre');
      expect(repo.current.energy, 0);
      expect(txt('Ton texte'), findsOneWidget);
    });

    testWidgets('Passer en cabine, retour vers l\'instru', (tester) async {
      await pumpApp(tester, written, location: '/studio/ecriture');
      await tapText(tester, 'Passer en cabine');
      expect(txt('Session cabine'), findsOneWidget);
      await tapBack(tester);
      expect(txt('Ton texte'), findsOneWidget);
    });
  });

  group('cabine (04.7)', () {
    testWidgets('bannière, matériel actif, durée et énergie, deux boutons', (tester) async {
      await pumpApp(tester, written, location: '/studio/cabine');
      for (final t in ['Session cabine', 'Étape 3 / 3', 'Cabine · Studio Kôrô', 'Matériel actif', 'Micro de base · qualité 40', 'Un meilleur micro ajoute jusqu’à +8 à ta voix.', '2 h · −25 énergie', '3 prises', 'Entrer en cabine', 'Acheter du matériel']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('micro studio : « Micro studio · qualité 48 »', (tester) async {
      await pumpApp(tester, written.copyWith(micro: true), location: '/studio/cabine');
      expect(txt('Micro studio · qualité 48'), findsOneWidget);
    });

    testWidgets('Entrer en cabine ouvre le mini-jeu (04.8)', (tester) async {
      await pumpApp(tester, written, location: '/studio/cabine');
      await tester.tap(txt('Entrer en cabine'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(txt('Prise en cours'), findsOneWidget);
    });

    testWidgets('Acheter du matériel : « bientôt »', (tester) async {
      await pumpApp(tester, written, location: '/studio/cabine');
      await tapText(tester, 'Acheter du matériel');
      expect(txt('Matériel : bientôt'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('mini-jeu des prises (04.8) : port de game.js', () {
    testWidgets('textes de la planche, trois pastilles, zone et REC', (tester) async {
      await pumpApp(tester, written, location: '/studio/prises', settle: false);
      for (final t in ['Mini-jeu réel · note de démo', 'Prise en cours', '3 prises', 'Prise 1', 'Prise 2', 'Prise 3', 'Appuie sur REC quand le curseur est dans la zone verte.', 'REC', 'Simuler les 3 prises']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(txt('Le mini-jeu fonctionne : ton timing fixe la note de voix. Si le script est indisponible, utilise « Simuler ».'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('REC à l\'instant 0 : curseur à 1, zone 0,62 : note 13, « Prise ratée, mais gardée »', (tester) async {
      await pumpApp(tester, written, location: '/studio/prises', settle: false);
      // 100 ms écoulées : le curseur est à cursorAt(0,1)
      await tester.tap(txt('REC'));
      await tester.pump();
      final expected = takeScore(cursorAt(0.1), 0);
      expect(txt('Prise 1 · $expected'), findsOneWidget);
      expect(txt(takeMessage(expected)), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('trois prises dans la zone : notes calculées par le domaine, record(), puis le mix', (tester) async {
      final repo = await pumpApp(tester, written, location: '/studio/prises', settle: false);
      // instants (en secondes depuis le début) où le curseur est au centre de la zone de chaque prise
      const t1 = 0.447, dt2 = 0.7765, dt3 = 0.3294; // cursorAt(t) = 0,62 ; 0,34 ; 0,72
      await tester.pump(const Duration(milliseconds: 347)); // 100 + 347 = 447 ms
      await tester.tap(txt('REC'));
      await tester.pump();
      final s1 = takeScore(cursorAt(t1), 0);
      await tester.pump(const Duration(microseconds: 776500));
      await tester.tap(txt('REC'));
      await tester.pump();
      final s2 = takeScore(cursorAt(dt2), 1);
      await tester.pump(const Duration(microseconds: 329400));
      await tester.tap(txt('REC'));
      await tester.pump();
      final s3 = takeScore(cursorAt(dt3), 2);
      expect([s1, s2, s3].every((s) => s >= 95), isTrue, reason: '$s1 $s2 $s3');
      expect(txt('Prise 1 · $s1'), findsOneWidget);
      expect(txt('Prise 2 · $s2'), findsOneWidget);
      expect(txt('Prise 3 · $s3'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800)); // 700 ms avant le mix
      await tester.pumpAndSettle();
      expect(repo.current.takes, [s1, s2, s3]);
      expect(repo.current.song, isNotNull);
      expect(repo.current.energy, 55);
      expect(txt('Mix terminé'), findsOneWidget);
    });

    testWidgets('énergie 24 : après trois prises, « Trop fatigué » et les prises sont effacées', (tester) async {
      final repo = await pumpApp(tester, written.copyWith(energy: 24), location: '/studio/prises', settle: false);
      for (var i = 0; i < 3; i++) {
        await tester.tap(txt('REC'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 500));
      expect(txt('Trop fatigué'), findsOneWidget);
      expect(repo.current.song, isNull);
      expect(txt('Prise 1'), findsOneWidget); // pastilles remises à zéro
    });

    testWidgets('Simuler les 3 prises : notes de démo [74, 48, 43], mix 61', (tester) async {
      final repo = await pumpApp(tester, written, location: '/studio/prises', settle: false);
      await tester.tap(txt('Simuler les 3 prises'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(repo.current.takes, [74, 48, 43]);
      expect(repo.current.song!.q, 61);
      expect(txt('Mix terminé'), findsOneWidget);
    });
  });

  group('mix (04.9)', () {
    testWidgets('qualité 61 / 100, détail, +30 XP, deux boutons, sans navigation', (tester) async {
      await pumpApp(tester, rec, location: '/studio/mix');
      for (final t in ['Mix terminé', 'Gbaka de 6h', '61 / 100', 'Texte', '72', 'Voix', 'Production', '56', '+30 XP', 'Son ajouté au studio', 'Préparer la sortie', 'Récupérer la mission', '+5 000 cauris · +50 XP']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('Récupérer la mission : +5 000 cauris, +50 XP, retour au QG', (tester) async {
      final repo = await pumpApp(tester, rec, location: '/studio/mix');
      await tapText(tester, 'Récupérer la mission');
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m1']], [22000, 80, 'claimed']);
      expect(txt('Salut, Djo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('mission 1 déjà récupérée : pas de bouton « Récupérer la mission »', (tester) async {
      await pumpApp(tester, claim(rec, 'm1'), location: '/studio/mix');
      expect(txt('Récupérer la mission'), findsNothing);
      expect(txt('Préparer la sortie'), findsOneWidget);
    });

    testWidgets('Préparer la sortie', (tester) async {
      await pumpApp(tester, rec, location: '/studio/mix');
      await tapText(tester, 'Préparer la sortie');
      expect(txt('Sortir le son'), findsOneWidget);
    });
  });

  group('sortie (05.1, 05.1b, 05.2)', () {
    final at22000 = rec.copyWith(cash: 22000);

    testWidgets('05.1 : carte du son, Single / EP, promos, estimations, bouton', (tester) async {
      await pumpApp(tester, at22000, location: '/studio/sortie', height: 1400);
      for (final t in ['Sortir le son', 'Gbaka de 6h', 'Qualité', 'Single', 'EP · maquette', 'Promotion', 'Aucune', 'Audience du quartier', 'Gratuit', 'Réseaux sociaux', 'Portée moyenne', '2 000 cauris', 'Radio locale', 'Portée large', '15 000 cauris', 'Écoutes estimées · 24 h', '5 418', 'Cash après promo', 'Estimé · valeurs de démo', 'Sortir le single']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(txt('22 000'), findsWidgets);
    });

    testWidgets('Radio locale : 17 324 écoutes, cash après 7 000 ; Réseaux sociaux : 8 667, 20 000', (tester) async {
      await pumpApp(tester, at22000, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      expect(txt('17 324'), findsOneWidget);
      expect(txt('7 000'), findsOneWidget);
      await tapText(tester, 'Réseaux sociaux');
      expect(txt('8 667'), findsOneWidget);
      expect(txt('20 000'), findsOneWidget);
    });

    testWidgets('EP · maquette : « bientôt »', (tester) async {
      await pumpApp(tester, at22000, location: '/studio/sortie');
      await tapText(tester, 'EP · maquette');
      expect(txt('EP : bientôt'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('05.1b cash 4 200 + Radio locale : -10 800, message de la planche, rien n\'est débité', (tester) async {
      final repo = await pumpApp(tester, rec.copyWith(cash: 4200), location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      expect(txt('Cash insuffisant · 15 000 requis, tu as 4 200'), findsOneWidget);
      expect(txt('-10 800'), findsOneWidget);
      await tapText(tester, 'Sortir le single');
      expect(txt('Cash insuffisant'), findsOneWidget);
      expect(txt('Lancer la promo ?'), findsNothing);
      expect([repo.current.cash, repo.current.rel, repo.current.day], [4200, null, 1]);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Aucune : sortie sans confirmation, état mis à jour, écran de chargement', (tester) async {
      final repo = await pumpApp(tester, at22000, location: '/studio/sortie');
      await tapNoSettle(tester, 'Sortir le single');
      expect(txt('Lancer la promo ?'), findsNothing);
      expect(txt('Mise en ligne'), findsOneWidget);
      final s = repo.current;
      expect([s.cash, s.fans, s.pop, s.energy, s.day, s.hour, s.xp], [22054, 491, 9, 100, 2, 8, 70]);
      expect(s.rel!.listens, 5418);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('05.2 Radio locale : feuille de confirmation, annuler ne débite rien', (tester) async {
      final repo = await pumpApp(tester, at22000, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      await tapText(tester, 'Sortir le single');
      for (final t in ['Confirmation', 'Lancer la promo ?', 'Dépense supérieure à 15 000 cauris.', 'Promo', 'Prix', 'Cash après', '7 000', 'Confirmer et sortir']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      await tapText(tester, 'Annuler');
      expect([repo.current.cash, repo.current.rel], [22000, null]);
      expect(txt('Lancer la promo ?'), findsNothing);
    });

    testWidgets('Radio locale confirmée : +173, +1 185 fans, cash 7 173', (tester) async {
      final repo = await pumpApp(tester, at22000, location: '/studio/sortie');
      await tapText(tester, 'Radio locale');
      await tapText(tester, 'Sortir le single');
      await tapText(tester, 'Confirmer et sortir'); // la jauge de chargement se termine pendant l'attente : on arrive aux résultats
      expect([repo.current.cash, repo.current.fans, repo.current.pop], [7173, 1305, 22]);
      expect(txt('Résultats · 24 h'), findsOneWidget);
      expect(txt('17 324'), findsOneWidget);
    });

    testWidgets('sans son : « Aucun son prêt à sortir »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/sortie');
      expect(txt('Aucun son prêt à sortir.'), findsOneWidget);
    });

    testWidgets('retour vers le studio', (tester) async {
      await pumpApp(tester, at22000, location: '/studio/sortie');
      await tapBack(tester);
      expect(txt('Préparer la sortie'), findsOneWidget);
    });
  });

  group('chargement (05.3) : simulé', () {
    final released = release(rec.copyWith(cash: 22000), 0);

    testWidgets('textes de la planche, étiquette « Chargement simulé », progression', (tester) async {
      await pumpApp(tester, released, location: '/studio/chargement', settle: false);
      for (final t in ['Chargement simulé', 'Mise en ligne', 'Gbaka de 6h arrive sur les plateformes.', 'Voir les résultats']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      await tester.pump(const Duration(milliseconds: 800)); // 100 + 800 = 900 ms sur 1 800 ms
      expect(txt('50 %'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('au bout de 1,8 s : les résultats s\'ouvrent', (tester) async {
      await pumpApp(tester, released, location: '/studio/chargement', settle: false);
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
      expect(txt('Résultats · 24 h'), findsOneWidget);
    });

    testWidgets('Voir les résultats : tout de suite', (tester) async {
      await pumpApp(tester, released, location: '/studio/chargement', settle: false);
      await tester.tap(txt('Voir les résultats'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(txt('Résultats · 24 h'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('résultats (05.4)', () {
    final released = release(claim(rec, 'm1'), 0); // 22 054 cauris, N2 en attente

    testWidgets('écoutes 5 418, gain +54, fans +371, popularité +6, cash 22 054, Top 100', (tester) async {
      await pumpApp(tester, released, location: '/studio/resultats');
      for (final t in ['Résultats · 24 h', 'Gbaka de 6h', 'Écoutes', '5 418', 'Estimé', 'Gain', '+54', 'cauris', 'Fans', '+371', 'Popularité', '+6', 'Cash', 'Top 100 Singles', 'Non classé', 'Seuil d’entrée : ≈ 252 200 écoutes / 7 j (hypothèse de démo).', 'Premier single : pas encore classé. Il faudra plus d’écoutes, de fans et de promo.', 'Retour au QG']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(txt('22 054'), findsWidgets);
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('Retour au QG avec un niveau en attente : écran « Niveau supérieur »', (tester) async {
      await pumpApp(tester, released, location: '/studio/resultats');
      await tapText(tester, 'Retour au QG');
      expect(txt('Niveau supérieur'), findsOneWidget);
    });

    testWidgets('Retour au QG sans niveau en attente : le QG', (tester) async {
      await pumpApp(tester, ack(released), location: '/studio/resultats');
      await tapText(tester, 'Retour au QG');
      expect(txt('Salut, Djo'), findsOneWidget);
    });

    testWidgets('sans sortie : message', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/resultats');
      expect(txt('Aucune sortie pour l’instant.'), findsOneWidget);
    });
  });

  group('parcours complet depuis le QG', () {
    testWidgets('instru, texte, cabine simulée, mix, sortie, chargement, résultats, discographie', (tester) async {
      final repo = await pumpApp(tester, const GameState());
      await tapText(tester, 'Aller au studio');
      await tapText(tester, 'Nouveau son');
      await tapText(tester, 'Gbaka de 6h');
      await tapText(tester, 'Écrire · Sombre');
      await tapText(tester, 'Passer en cabine');
      await tester.tap(txt('Entrer en cabine'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(txt('Simuler les 3 prises'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(txt('Mix terminé'), findsOneWidget);
      expect(repo.current.song!.q, 61);
      await tapText(tester, 'Préparer la sortie');
      await tapText(tester, 'Sortir le single');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(txt('Résultats · 24 h'), findsOneWidget);
      expect(txt('5 418'), findsOneWidget);
      expect([repo.current.cash, repo.current.fans, repo.current.day, repo.current.energy], [17054, 491, 2, 100]);
    });

    testWidgets('énergie basse dans le jeu réel : deux sons de suite, « Trop fatigué » au QG, Dormir, fin de journée', (tester) async {
      Future<void> song() async {
        await tapText(tester, 'Écrire · Sombre');
        await tapText(tester, 'Passer en cabine');
        await tester.tap(txt('Entrer en cabine'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(txt('Simuler les 3 prises'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
      }

      final repo = await pumpApp(tester, picked.copyWith(energy: 45), location: '/studio/ecriture');
      await song(); // 45 - 20 - 25 = 0
      expect(repo.current.energy, 0);
      await tapText(tester, 'Préparer la sortie');
      await tapBack(tester); // studio avec le son à sortir
      await tapText(tester, 'Nouveau son'); // refusé : le son en attente ne doit pas être écrasé (toast, pas de navigation)
      expect(txt('Sors ton son en attente avant d’en créer un autre'), findsOneWidget);
      expect(txt('Choisis une instru'), findsNothing);
      expect(repo.current.song, isNotNull);
      expect(repo.current.song!.title, isNotEmpty); // titre généré à l'écriture
      await tester.pump(const Duration(seconds: 5));
      await tester.tap(navTab('QG'));
      await tester.pumpAndSettle();
      expect(txt('Trop fatigué'), findsOneWidget);
      await tapText(tester, 'Dormir');
      expect(txt('Nouvelle journée'), findsOneWidget);
      expect([repo.current.energy, repo.current.day, repo.current.hour], [100, 2, 8]);
      expect(repo.current.song, isNotNull);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  Future<void> recordWithSimulation(WidgetTester tester) async {
    await tapText(tester, 'Passer en cabine');
    await tester.tap(txt('Entrer en cabine'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(txt('Simuler les 3 prises'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  group('titre du son (généré, aléatoire, saisi)', () {
    testWidgets('le titre est généré automatiquement quand le texte s\u2019affiche', (tester) async {
      final repo = await pumpApp(tester, picked, location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Sombre');
      expect(txt('Titre du son'), findsOneWidget);
      expect(txt('Titre aléatoire'), findsOneWidget);
      expect(repo.current.title, isNotEmpty);
      expect(find.widgetWithText(TextField, repo.current.title!), findsOneWidget);
    });

    testWidgets('Titre aléatoire : un autre titre, affiché dans le champ', (tester) async {
      final repo = await pumpApp(tester, picked, location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Sombre');
      final first = repo.current.title;
      await tapText(tester, 'Titre aléatoire');
      expect(repo.current.title, isNot(first));
      expect(repo.current.title, isNotEmpty);
      expect(find.widgetWithText(TextField, repo.current.title!), findsOneWidget);
    });

    testWidgets('titre saisi à la main : conservé jusqu\u2019au mix', (tester) async {
      final repo = await pumpApp(tester, picked, location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Sombre');
      await tester.enterText(find.byType(TextField), 'Mon premier son');
      await tester.pump();
      expect(repo.current.title, 'Mon premier son');
      await recordWithSimulation(tester);
      expect(txt('Mon premier son'), findsOneWidget);
      expect(repo.current.song!.title, 'Mon premier son');
      expect(repo.current.title, isNull); // le prochain son aura son propre titre
    });

    testWidgets('champ vidé : un titre est généré à l\u2019enregistrement', (tester) async {
      final repo = await pumpApp(tester, picked, location: '/studio/ecriture');
      await tapText(tester, 'Écrire · Sombre');
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(repo.current.title, '');
      await recordWithSimulation(tester);
      expect(repo.current.song!.title.trim(), isNotEmpty);
    });
  });
}
