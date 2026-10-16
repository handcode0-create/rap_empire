import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/widgets/game_nav_bar.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/rules.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';
import 'package:rap_empire/domain/training.dart';

import 'support.dart';

/// Pages Business (matériel 09.1/09.2, formation 09.3/09.4, finances 09.5), missions (10.1), profil (03.4), journal (03.3), passer la journée.
void main() {
  final rec = record(write(pick(const GameState(), 'gbaka')));
  final acked = ack(release(claim(rec, 'm1'), 0)); // mission 2 terminée, 24 054 cauris

  group('rules : prochain niveau et XP restants (nextName et xpLeft de game.js)', () {
    // valeurs obtenues en exécutant game.js avec Node
    const cases = [
      (0, 'Espoir du quartier', 100), (50, 'Espoir du quartier', 50), (100, 'Révélation locale', 150), (120, 'Révélation locale', 130),
      (249, 'Révélation locale', 1), (250, 'Nom qui circule', 250), (499, 'Nom qui circule', 1), (500, 'Star de Bakoma', 400),
      (899, 'Star de Bakoma', 1), (900, 'Légende', 600), (1500, 'Légende', 0), (2000, 'Légende', 0),
    ];
    for (final c in cases) {
      test('${c.$1} XP : ${c.$2}, ${c.$3} XP restants', () {
        expect(nextLevelName(c.$1), c.$2);
        expect(xpToNextLevel(c.$1), c.$3);
      });
    }
  });

  group('Business : matériel (09.1) et achat du micro (09.2)', () {
    testWidgets('titre, tuiles, trois équipements avec leurs valeurs, navigation sur Business', (tester) async {
      await pumpApp(tester, const GameState(), location: '/business');
      for (final t in ['Matériel', 'Démo', 'Finances', 'Revenus, dépenses', 'Formation', 'Compétences', 'Réseau', 'Label, featuring', 'Équipe', 'Manager', 'Micro studio', 'Qualité enregistrement +8', '18 000 cauris', 'Casque monitoring', 'Qualité mix +4', '12 000 cauris', 'Carte son', 'Qualité mix +6', '30 000 cauris']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(find.byType(GameNavBar), findsOneWidget);
    });

    testWidgets('09.2 feuille de confirmation : prix, cash après achat, achat', (tester) async {
      final repo = await pumpApp(tester, const GameState(), location: '/business');
      await tapText(tester, 'Micro studio');
      for (final t in ['Confirmation', 'Acheter le micro studio ?', 'Qualité enregistrement +8 sur ta voix.', 'Prix', 'Cash après achat', '7 000 cauris', '− 18 000 cauris']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      await tapText(tester, 'Acheter');
      expect([repo.current.cash, repo.current.micro], [7000, true]);
      expect(txt('Déjà acheté'), findsOneWidget);
      expect(txt('18 000 cauris'), findsNothing);
    });

    testWidgets('Annuler : rien n’est débité', (tester) async {
      final repo = await pumpApp(tester, const GameState(), location: '/business');
      await tapText(tester, 'Micro studio');
      await tapText(tester, 'Annuler');
      expect([repo.current.cash, repo.current.micro], [25000, false]);
    });

    testWidgets('17 999 cauris : « Cash insuffisant », pas de feuille', (tester) async {
      await pumpApp(tester, const GameState(cash: 17999), location: '/business');
      await tapText(tester, 'Micro studio');
      expect(txt('Cash insuffisant'), findsOneWidget);
      expect(txt('Confirmation'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('micro déjà acheté : « Déjà acheté »', (tester) async {
      await pumpApp(tester, const GameState(micro: true), location: '/business');
      await tapText(tester, 'Micro studio');
      expect(txt('Déjà acheté'), findsWidgets);
      expect(txt('Confirmation'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('casque et carte son : valeurs de la planche, « bientôt » (pas de règle dans game.js)', (tester) async {
      final repo = await pumpApp(tester, const GameState(), location: '/business');
      await tapText(tester, 'Casque monitoring');
      expect(txt('Casque monitoring : bientôt'), findsOneWidget);
      expect(repo.current.cash, 25000);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('l’effet du micro apparaît en cabine : « Micro studio · qualité 48 »', (tester) async {
      await pumpApp(tester, const GameState(micro: true, inst: 'gbaka'), location: '/studio/cabine');
      expect(txt('Micro studio · qualité 48'), findsOneWidget);
    });

    testWidgets('tuiles : Formation et Finances ouvrent leurs pages, Réseau et Équipe « bientôt »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/business');
      await tapText(tester, 'Réseau');
      expect(txt('Réseau : bientôt'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tapText(tester, 'Formation');
      expect(txt('Atelier d’écriture'), findsNothing); // apostrophe droite dans la table : voir le test de la formation
      expect(txt("Atelier d'écriture"), findsOneWidget);
    });
  });

  group('formation (09.3) et toast de compétence (09.4)', () {
    testWidgets('quatre formations avec coût, énergie, temps et compétence', (tester) async {
      await pumpApp(tester, const GameState(), location: '/business/formation');
      for (final t in ['Formation', "Atelier d'écriture", '2 h · 6 000 cauris · −20 énergie · Écriture +5', 'Freestyle au carrefour', '1 h · gratuit · −15 énergie · Flow +2', 'Coach vocal', '2 h · 9 000 cauris · −20 énergie · Voix +5', 'Shooting et réseaux', '2 h · 7 000 cauris · −15 énergie · Charisme +4']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(txt('Chaque formation coûte du temps, de l’énergie et parfois des cauris : elle améliore une compétence.'), findsOneWidget);
      expect(find.byType(GameNavBar), findsOneWidget);
    });

    testWidgets('Atelier d’écriture : effets, toast « Écriture +5 · Atelier terminé », mission 3 terminée', (tester) async {
      final repo = await pumpApp(tester, const GameState(), location: '/business/formation');
      await tapText(tester, "Atelier d'écriture");
      expect([repo.current.cash, repo.current.energy, repo.current.hour, repo.current.sk['ecr'], repo.current.ms['m3']], [19000, 80, 10, 19, 'done']);
      expect(txt('Écriture +5 · Atelier terminé'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Freestyle gratuit : flow +2, rien au registre', (tester) async {
      final repo = await pumpApp(tester, const GameState(), location: '/business/formation');
      await tapText(tester, 'Freestyle au carrefour');
      expect([repo.current.cash, repo.current.energy, repo.current.sk['flow'], repo.current.led], [25000, 85, 19, <LedgerEntry>[]]);
      expect(txt('Flow +2 · Formation terminée'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('énergie 19 : formations à 20 d’énergie indisponibles avec le motif, rien ne se passe au tap', (tester) async {
      final repo = await pumpApp(tester, const GameState(energy: 19), location: '/business/formation');
      expect(txt('Énergie insuffisante : dors ou récupère'), findsNWidgets(2)); // seules les formations à 20 d’énergie
      await tapText(tester, "Atelier d'écriture");
      expect([repo.current.cash, repo.current.energy], [25000, 19]);
    });

    testWidgets('énergie 15 : Freestyle et Shooting possibles, Atelier et Coach indisponibles', (tester) async {
      await pumpApp(tester, const GameState(energy: 15), location: '/business/formation');
      expect(txt('Énergie insuffisante : dors ou récupère'), findsNWidgets(2));
    });

    testWidgets('cash 100 : Atelier, Coach et Shooting indisponibles (« Cash insuffisant »), Freestyle possible', (tester) async {
      await pumpApp(tester, const GameState(cash: 100), location: '/business/formation');
      expect(txt('Cash insuffisant'), findsNWidgets(3));
    });

    testWidgets('cash ET énergie insuffisants : le motif est le cash (même ordre que game.js)', (tester) async {
      await pumpApp(tester, const GameState(cash: 100, energy: 5), location: '/business/formation');
      expect(txt('Cash insuffisant'), findsNWidgets(3));
      expect(txt('Énergie insuffisante : dors ou récupère'), findsOneWidget); // le freestyle, gratuit, ne manque que d’énergie
    });

    testWidgets('retour : Business', (tester) async {
      await pumpApp(tester, const GameState(), location: '/business/formation');
      await tapBack(tester);
      expect(txt('Micro studio'), findsOneWidget);
    });
  });

  group('missions (10.1) : missions 3 et 4', () {
    testWidgets('quatre missions, récompenses, états', (tester) async {
      await pumpApp(tester, const GameState(), location: '/missions');
      for (final t in ['Missions', 'Enregistre ton premier son', '+5 000 cauris · +50 XP', 'Sors ton premier single', '+10 000 cauris · +80 XP', "Fais un atelier d'écriture", '+4 000 cauris · +60 XP', 'Atteins 1 000 fans', '+15 000 cauris · +120 XP']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
      expect(txt('Y aller'), findsWidgets);
      expect(txt('Terminée'), findsNothing);
      expect(find.byType(GameNavBar), findsOneWidget);
    });

    testWidgets('mission 4 : avancement en pourcentage (m4pct)', (tester) async {
      await pumpApp(tester, const GameState(fans: 491), location: '/missions');
      expect(txt('49 %'), findsOneWidget);
    });

    testWidgets('Y aller (mission 3) : la formation', (tester) async {
      await pumpApp(tester, const GameState(), location: '/missions');
      await tester.tap(txt('Y aller').first);
      await tester.pumpAndSettle();
      expect(txt('Freestyle au carrefour'), findsOneWidget);
    });

    testWidgets('atelier d’écriture puis mission 3 : +4 000 cauris, +60 XP', (tester) async {
      final repo = await pumpApp(tester, train(const GameState(), 'ecr'), location: '/missions');
      expect(txt('À récupérer'), findsOneWidget);
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m3']], [23000, 60, 'claimed']);
      expect(txt('Terminée'), findsOneWidget);
      expect(txt('Mission accomplie · +4 000 cauris · +60 XP'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('mission 4 terminée : +15 000 cauris, +120 XP, l’écran « Niveau supérieur » s’ouvre', (tester) async {
      final repo = await pumpApp(tester, const GameState(fans: 1305, ms: {'m1': 'claimed', 'm2': 'claimed', 'm3': 'claimed', 'm4': 'done'}), location: '/missions');
      await tester.tap(txt('Récupérer'));
      await tester.pumpAndSettle();
      expect([repo.current.cash, repo.current.xp, repo.current.ms['m4']], [40000, 120, 'claimed']);
      expect(txt('Niveau supérieur'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('la tuile Missions du QG ouvre la liste', (tester) async {
      await pumpApp(tester, const GameState());
      await tester.tap(txt('Objectifs et primes'));
      await tester.pumpAndSettle();
      expect(txt('Atteins 1 000 fans'), findsOneWidget);
    });
  });

  group('finances (09.5)', () {
    testWidgets('caisse, revenus et dépenses lus dans le registre', (tester) async {
      await pumpApp(tester, claim(acked, 'm2'), location: '/business/finances');
      for (final t in ['Finances', 'Données de démonstration · paramètres provisoires', 'En caisse', '34 054', 'Revenus', 'Écoutes', '+54', 'Cachets', '+0', 'Missions', '+15 000', 'Niveaux', '+2 000', 'Dépenses', 'Instrus', '-8 000', 'Promo', 'Matériel', 'Formations']) {
        expect(txt(t), findsWidgets, reason: t);
      }
    });

    testWidgets('dépenses de formation et de matériel', (tester) async {
      final s = train(const GameState(micro: false), 'voix');
      await pumpApp(tester, s, location: '/business/finances');
      expect(txt('-9 000'), findsOneWidget);
    });

    testWidgets('accessible depuis la tuile Finances de Business', (tester) async {
      await pumpApp(tester, const GameState(), location: '/business');
      await tapText(tester, 'Finances');
      expect(txt('En caisse'), findsOneWidget);
    });
  });

  group('profil (03.4)', () {
    testWidgets('bannière, progression, KPI, compétences, tuiles, bouton', (tester) async {
      await pumpApp(tester, const GameState(), location: '/profil');
      for (final t in ['Djo Kéné', 'N1 · Inconnu', 'Ndolo · Drill de Bakoma', 'Direction d’avatar non choisie (D-01)', 'Prochain niveau : Espoir du quartier', '100 XP restants', 'Fans', '120', 'Popularité', 'Réputation', 'Mes tenues', 'Mes finances', 'Flow', '17', 'Écriture', '14', 'Voix', '10', 'Charisme', '8', 'Recommencer la démo']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(find.byType(GameNavBar), findsOneWidget);
    });

    testWidgets('niveau 2 : prochain niveau et XP restants', (tester) async {
      await pumpApp(tester, const GameState(xp: 120), location: '/profil');
      expect(txt('Prochain niveau : Révélation locale'), findsOneWidget);
      expect(txt('130 XP restants'), findsOneWidget);
    });

    testWidgets('l’onglet Profil ouvre la page', (tester) async {
      await pumpApp(tester, const GameState());
      await tester.tap(navTab('Profil'));
      await tester.pumpAndSettle();
      expect(txt('Mes finances'), findsOneWidget);
    });

    testWidgets('Recommencer la démo : confirmation, puis partie neuve et QG', (tester) async {
      final repo = await pumpApp(tester, acked, location: '/profil');
      await tapText(tester, 'Recommencer la démo');
      expect(txt('Recommencer la démo ?'), findsOneWidget);
      await tapText(tester, 'Recommencer');
      expect([repo.current.cash, repo.current.day, repo.current.xp, repo.current.song, repo.current.led], [25000, 1, 0, null, <LedgerEntry>[]]);
      expect(txt('Salut, Djo'), findsOneWidget);
    });

    testWidgets('Annuler : rien n’est effacé', (tester) async {
      final repo = await pumpApp(tester, acked, location: '/profil');
      await tapText(tester, 'Recommencer la démo');
      await tapText(tester, 'Annuler');
      expect(repo.current.cash, 24054);
    });

    testWidgets('Mes tenues : « bientôt »', (tester) async {
      await pumpApp(tester, const GameState(), location: '/profil');
      await tapText(tester, 'Mes tenues');
      expect(txt('Mes tenues : bientôt'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('journal (03.3)', () {
    testWidgets('la cloche du HUD ouvre le journal : nouvelle mission, bienvenue, texte', (tester) async {
      await pumpApp(tester, const GameState());
      await tester.tap(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Journal'));
      await tester.pumpAndSettle();
      for (final t in ['Journal', 'Nouvelle mission', 'Enregistre ton premier son', 'Bienvenue dans la street', 'Ton aventure commence', 'Jour 1']) {
        expect(txt(t), findsWidgets, reason: t);
      }
      expect(find.byType(GameNavBar), findsNothing);
    });

    testWidgets('événements réels : niveau à récupérer, mission terminée, sortie', (tester) async {
      final released = release(claim(rec, 'm1'), 0);
      await pumpApp(tester, released, location: '/journal');
      for (final t in ['Niveau supérieur', 'Niveau 2 à récupérer', 'Mission terminée', 'Sors ton premier single', 'Sortie', 'Gbaka de 6h · 5 418 écoutes']) {
        expect(txt(t), findsWidgets, reason: t);
      }
    });

    testWidgets('une entrée ouvre sa page ; retour au QG', (tester) async {
      await pumpApp(tester, const GameState(), location: '/journal');
      await tapText(tester, 'Nouvelle mission');
      expect(txt('Atteins 1 000 fans'), findsOneWidget);
    });

    testWidgets('retour : le QG', (tester) async {
      await pumpApp(tester, const GameState(), location: '/journal');
      await tapBack(tester);
      expect(txt('Salut, Djo'), findsOneWidget);
    });
  });

  group('passer la journée sans faire de musique', () {
    testWidgets('bouton au QG : jour suivant 08:00, énergie 100, nuit gratuite, bilan', (tester) async {
      final repo = await pumpApp(tester, const GameState(energy: 100, hour: 15));
      expect(txt('Passer la journée'), findsOneWidget);
      expect(txt('Nuit gratuite · démo'), findsOneWidget);
      await tapText(tester, 'Passer la journée');
      expect(txt('Nouvelle journée'), findsOneWidget);
      expect([repo.current.day, repo.current.hour, repo.current.energy, repo.current.cash], [2, 8, 100, 25000]);
    });

    testWidgets('une formation, puis la nuit : l’énergie revient', (tester) async {
      final repo = await pumpApp(tester, train(const GameState(), 'ecr'));
      expect(repo.current.energy, 80);
      await tapText(tester, 'Passer la journée');
      expect([repo.current.energy, repo.current.day, repo.current.sk['ecr']], [100, 2, 19]);
      await tapText(tester, 'Commencer le jour');
      expect(txt('Salut, Djo'), findsOneWidget);
    });
  });
}
