import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/widgets/game_nav_bar.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

import 'support.dart';

/// Missions, niveaux et célébrations : carte du QG, 10.2 Mission accomplie, 10.3 Nouvelle mission, 10.4 Niveau supérieur.
void main() {
  final rec = record(write(pick(const GameState(), 'gbaka')));
  final released = release(claim(rec, 'm1'), 0); // 22 054 cauris, N2 en attente, mission 2 terminée
  final acked = ack(released); // 24 054 cauris

  group('carte objectif du QG (03.1)', () {
    testWidgets('départ : mission 1, titre, texte, bouton Aller au studio, pas de « Récupérer »', (tester) async {
      await pumpApp(tester, const GameState());
      for (final t in ['Objectif en cours', 'Mission 1', 'Enregistre ton premier son', 'Choisis une instru, écris, passe en cabine.', 'Aller au studio']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(txt('Terminée'), findsNothing);
      expect(txt('Récupérer'), findsNothing);
    });

    testWidgets('mission 1 terminée : étiquette, puces de récompense, Récupérer', (tester) async {
      final repo = await pumpApp(tester, rec);
      for (final t in ['Terminée', '+5 000', '+50', 'Récupérer']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m1']], [22000, 80, 'claimed']);
      expect(txt('Mission accomplie · +5 000 cauris · +50 XP'), findsOneWidget);
      expect(txt('Mission 2'), findsOneWidget);
      expect(txt('Sors ton premier single'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('mission 2 avec un son prêt : le bouton mène à la sortie', (tester) async {
      await pumpApp(tester, claim(rec, 'm1'));
      expect(txt('Mission 2'), findsOneWidget);
      expect(txt('Ton son est prêt : choisis la promo et mets-le en ligne.'), findsOneWidget);
      await tester.tap(txt('Préparer la sortie'));
      await tester.pumpAndSettle();
      expect(txt('Sortir le son'), findsOneWidget);
    });

    testWidgets('mission 2 sans son : le bouton mène au studio', (tester) async {
      await pumpApp(tester, const GameState(ms: {'m1': 'claimed', 'm2': 'todo', 'm3': 'todo', 'm4': 'todo'}));
      await tester.tap(txt('Aller au studio'));
      await tester.pumpAndSettle();
      expect(txt('Aucun son enregistré'), findsOneWidget);
    });

    testWidgets('mission 2 terminée : Récupérer ouvre « Mission accomplie »', (tester) async {
      await pumpApp(tester, acked);
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect(txt('Premier single sorti'), findsOneWidget);
    });

    testWidgets('missions 1 et 2 récupérées : plus de carte objectif', (tester) async {
      await pumpApp(tester, claim(acked, 'm2'));
      expect(txt('Objectif en cours'), findsNothing);
    });

    testWidgets('les quatre tuiles et le compteur de missions ouvertes', (tester) async {
      await pumpApp(tester, const GameState());
      for (final t in ['Studio', 'Créer un son', 'Scène', 'Open mic, battle', 'Missions', 'Objectifs et primes', 'Classements', 'Rang : Non classé', '10']) {
        expect(txt(t), findsWidgets, reason: t);
      }
    });

    testWidgets('niveau en attente : bandeau « Niveau supérieur à récupérer », il ouvre le niveau', (tester) async {
      await pumpApp(tester, const GameState(xp: 120, pend: Pending(2, 2000)));
      expect(txt('Niveau supérieur à récupérer'), findsOneWidget);
      await tester.tap(txt('Niveau supérieur à récupérer'));
      await tester.pumpAndSettle();
      expect(txt('Espoir du quartier'), findsWidgets);
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('60 XP + mission 1 récupérée : le bandeau de niveau apparaît au QG', (tester) async {
      final repo = await pumpApp(tester, rec.copyWith(xp: 60));
      expect(txt('Niveau supérieur à récupérer'), findsNothing);
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect(repo.current.pend, const Pending(2, 2000));
      expect(txt('Niveau supérieur à récupérer'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('niveau supérieur (10.4)', () {
    testWidgets('N2, nom du niveau, options, +2 000 cauris, Continuer', (tester) async {
      await pumpApp(tester, released, location: '/niveau');
      for (final t in ['Niveau supérieur', 'N2', 'Espoir du quartier', 'Nouvelles options : open mic, instru Pont des Griots, missions avancées.', '+ 2 000 cauris', 'Continuer']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('Continuer : +2 000 cauris, niveau effacé, puis « Mission accomplie » (mission 2 terminée)', (tester) async {
      final repo = await pumpApp(tester, released, location: '/niveau');
      await tester.tap(txt('Continuer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.pend, repo.current.level], [24054, null, 2]);
      expect(txt('Premier single sorti'), findsOneWidget);
    });

    testWidgets('Continuer sans mission 2 terminée : retour au QG', (tester) async {
      final repo = await pumpApp(tester, const GameState(xp: 120, pend: Pending(2, 2000), cash: 5000), location: '/niveau');
      await tester.tap(txt('Continuer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.pend], [7000, null]);
      expect(txt('Salut, Djo'), findsOneWidget);
    });

    testWidgets('niveau 3 : nom du niveau, pas de texte d\'options (aucun dans les planches)', (tester) async {
      await pumpApp(tester, const GameState(xp: 250, pend: Pending(3, 4000)), location: '/niveau');
      expect(txt('N3'), findsWidgets);
      expect(txt('Révélation locale'), findsWidgets);
      expect(txt('+ 4 000 cauris'), findsOneWidget);
      expect(find.textContaining('Nouvelles options'), findsNothing);
    });

    testWidgets('sans niveau en attente : retour au QG', (tester) async {
      await pumpApp(tester, const GameState(), location: '/niveau');
      expect(txt('Salut, Djo'), findsOneWidget);
    });
  });

  group('mission accomplie (10.2)', () {
    testWidgets('textes de la planche, puces +10 000 cauris et +80 XP, Récupérer, Fermer', (tester) async {
      await pumpApp(tester, acked, location: '/mission-accomplie');
      for (final t in ['Mission accomplie', 'Premier single sorti', 'Le quartier a entendu ta voix.', '+10 000 cauris', '+80 XP', 'Récupérer', 'Fermer']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('Récupérer : +10 000 cauris, +80 XP, puis « Nouvelle mission »', (tester) async {
      final repo = await pumpApp(tester, acked, location: '/mission-accomplie');
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m2']], [34054, 200, 'claimed']);
      expect(txt('Fais-toi voir à l\'open mic'), findsOneWidget);
    });

    testWidgets('Fermer : le QG, rien n\'est versé', (tester) async {
      final repo = await pumpApp(tester, acked, location: '/mission-accomplie');
      await tester.tap(txt('Fermer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.ms['m2']], [24054, 'done']);
      expect(txt('Salut, Djo'), findsOneWidget);
    });

    testWidgets('mission 2 pas terminée : retour au QG', (tester) async {
      await pumpApp(tester, const GameState(), location: '/mission-accomplie');
      expect(txt('Salut, Djo'), findsOneWidget);
    });
  });

  group('nouvelle mission (10.3)', () {
    final claimed = claim(acked, 'm2');

    testWidgets('textes de la planche, +3 000 cauris, +60 XP, Y aller, Plus tard', (tester) async {
      await pumpApp(tester, claimed, location: '/nouvelle-mission');
      for (final t in ['Nouvelle mission', "Fais-toi voir à l'open mic", 'Monte sur la scène de Ndolo : les fans et la réputation suivent.', '+3 000 cauris', '+60 XP', 'Y aller', 'Plus tard']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('Y aller : la scène, onglet Scène avec l\'open mic', (tester) async {
      await pumpApp(tester, claimed, location: '/nouvelle-mission');
      await tester.tap(txt('Y aller'));
      await tester.pumpAndSettle();
      expect(txt('Monter sur scène'), findsOneWidget);
    });

    testWidgets('Plus tard : le QG', (tester) async {
      await pumpApp(tester, claimed, location: '/nouvelle-mission');
      await tester.tap(txt('Plus tard'));
      await tester.pumpAndSettle();
      expect(txt('Salut, Djo'), findsOneWidget);
    });
  });

  group('parcours de la planche : résultats, niveau, mission accomplie, nouvelle mission, QG', () {
    testWidgets('Retour au QG, Continuer, Récupérer, Plus tard', (tester) async {
      final repo = await pumpApp(tester, released, location: '/studio/resultats');
      await tester.tap(txt('Retour au QG')); // niveau en attente : 10.4
      await tester.pumpAndSettle();
      expect(txt('Niveau supérieur'), findsOneWidget);
      await tester.tap(txt('Continuer')); // récompense de niveau, puis 10.2
      await tester.pumpAndSettle();
      expect(repo.current.cash, 24054);
      await tester.tap(txt('Récupérer')); // mission 2, puis 10.3
      await tester.pumpAndSettle();
      expect(repo.current.cash, 34054);
      expect(txt('Nouvelle mission'), findsOneWidget);
      await tester.tap(txt('Plus tard'));
      await tester.pumpAndSettle();
      expect(txt('Salut, Djo'), findsOneWidget);
      expect(txt('34 054'), findsWidgets);
      expect(txt('Objectif en cours'), findsNothing);
    });
  });

  group('fin de journée (03.6)', () {
    testWidgets('bilan de la planche : énergie 100 + repos, nuit gratuite démo, avertissement, boutons', (tester) async {
      const before = GameState(cash: 6000, energy: 12, hour: 14);
      final repo = await pumpApp(tester, before);
      expect(txt('Trop fatigué'), findsOneWidget);
      await tester.tap(txt('Dormir'));
      await tester.pumpAndSettle();
      for (final t in ['Nuit passée', 'Nouvelle journée', 'Énergie', '100', '+ repos', 'Nuit', 'Gratuite', 'démo', 'Commencer le jour', 'Retour au QG']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(find.textContaining('la nuit pourra coûter des cauris'), findsOneWidget);
      expect([repo.current.energy, repo.current.day, repo.current.hour], [100, 2, 8]);
      await tester.tap(txt('Commencer le jour'));
      await tester.pumpAndSettle();
      expect(txt('Salut, Djo'), findsOneWidget);
    });
  });
}
