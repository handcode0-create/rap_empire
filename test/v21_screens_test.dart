import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/game21.dart';
import 'package:rap_empire/app/router21.dart';
import 'package:rap_empire/data/save21_repository.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/features/v21/studio_screens.dart' show Cabine21Screen;

import 'support.dart' show navTab, tapText, txt;

/// Écrans de la v21 : parcours de création, journée, studio, scène, vie perso, et balayage de toutes les routes à 390 et 360 px.
class FakeRepo21 extends Save21Repository {
  J current;
  FakeRepo21(this.current);
  @override
  Future<J> load() async => current;
  @override
  Future<void> save(J s) async => current = s;
}

Future<FakeRepo21> pump21(WidgetTester tester, J start, {String location = '/', double width = 390, double height = 844}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeRepo21(start);
  await tester.pumpWidget(ProviderScope(
    key: UniqueKey(),
    overrides: [save21RepoProvider.overrideWithValue(repo)],
    child: MaterialApp.router(theme: ThemeData.dark(useMaterial3: true), routerConfig: buildRouter21(initialLocation: location)),
  ));
  if (location == '/studio/cabine') {
    await tester.pump(const Duration(milliseconds: 100));
  } else {
    await tester.pumpAndSettle();
  }
  return repo;
}

J preset(String id) => act21(init21(), 'preset', id).s;

void main() {
  testWidgets('création de l’artiste : splash, univers, identité, look, style, objectif, QG', (tester) async {
    final repo = await pump21(tester, init21(), location: '/demarrer');
    expect(txt('Commencer'), findsOneWidget);
    await tester.tap(txt('Commencer'));
    await tester.pumpAndSettle();
    expect(txt('Pose ton flow'), findsOneWidget);
    await tapText(tester, 'Suivant');
    await tapText(tester, 'Suivant');
    expect(txt('Vise la légende'), findsOneWidget);
    await tapText(tester, 'Créer mon artiste');
    expect(txt('Choisis un nom de scène pour continuer.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Young SM');
    await tester.pumpAndSettle();
    await tester.tap(txt('Tamarel'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Continuer');
    expect(txt('Ton look'), findsOneWidget);
    await tester.tap(txt('Afro'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Continuer');
    expect(txt('Ton style musical'), findsOneWidget);
    await tester.tap(txt('Principal').at(1));
    await tester.pumpAndSettle();
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Signer en label');
    await tapText(tester, 'Entrer dans la street');
    expect(repo.current['created'], 1);
    expect((repo.current['p'] as J)['name'], 'Young SM');
    expect((repo.current['p'] as J)['origin'], 'tamarel');
    expect((repo.current['ap'] as J)['hair'], 'afro');
    expect((repo.current['p'] as J)['goal'], 'label');
    expect(txt('JOUR 1'), findsOneWidget);
    expect(txt("K-Zer d'Mabaya te défie"), findsOneWidget);
  });

  testWidgets('journée : événement, boulot, bilan', (tester) async {
    final repo = await pump21(tester, preset('debut'), location: '/evenement');
    expect(txt("K-Zer d'Mabaya te défie"), findsOneWidget);
    await tester.tap(find.text('RÉPONDRE EN FREESTYLE').last);
    await tester.pumpAndSettle();
    expect(repo.current['ev'], isNull);
    expect(repo.current['btq'], 'kzer');
    expect(txt('Battle · K-Zer'), findsOneWidget);
    await tapText(tester, 'Malin');
    await tapText(tester, 'Agressif');
    await tapText(tester, 'Cool');
    expect(txt('VICTOIRE'), findsOneWidget);
    expect([repo.current['fans'], repo.current['rep'], repo.current['cash']], [270, 14, 28000]);
    await tapText(tester, 'Retour au QG');
    await tester.tap(navTab('Business'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Livraison à moto · Ndolo');
    expect(txt('Résultat du boulot'), findsOneWidget);
    expect(txt('+3 500'), findsOneWidget);
    await tester.tap(txt('Retour au QG'));
    await tester.pumpAndSettle();
    (repo.current['disco'] as List).add({
      'id': 'OLD1', 'title': 'Ancien single', 'day': 1, 'launchL': 10000,
      'L': 10000, 'rev': 0, 'cut': 0, 'signed': 0, 'views': 0,
      'platforms': Map.unmodifiable(<dynamic, dynamic>{'spotify': 5000, 'apple': 3000, 'youtube': 2000}),
      'clip': Map.unmodifiable(<dynamic, dynamic>{'st': 'aucun'}),
    });
    await tapText(tester, 'Terminer la journée');
    expect(txt('Bilan de la journée'), findsOneWidget);
    expect(repo.current['day'], 2);
    await tapText(tester, 'Commencer la journée');
    expect(txt('JOUR 2'), findsOneWidget);
  });

  testWidgets('catalogue accepte les plateformes immuables des anciennes sauvegardes', (tester) async {
    final state = preset('debut');
    (state['disco'] as List).add({
      'id': 'OLD1', 'title': 'Ancien single', 'format': 'single', 'year': 1,
      'label': 'Indépendant', 'L': 1200, 'views': 0, 'sales': 0,
      'platforms': Map.unmodifiable(<dynamic, dynamic>{'spotify': 700, 'apple': 300, 'youtube': 200}),
      'clip': {'st': 'aucun'}, 'feats': <dynamic>[]
    });
    await pump21(tester, state, location: '/studio/catalogue');
    expect(txt('Ancien single'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('réseau artistique : interaction puis battle avec dialogue du rival', (tester) async {
    final repo = await pump21(tester, preset('debut'), location: '/scene/rivalites');
    expect(txt('Zaki Mbela'), findsOneWidget);
    await tapText(tester, 'Discuter');
    expect((repo.current['rivals'] as J)['zaki']['relation'], 5);
    await tapText(tester, 'Répondre en freestyle');
    expect(txt('Battle · Zaki Mbela'), findsOneWidget);
    expect(txt('« Tu veux ma place sans avoir fait tes preuves. »'), findsOneWidget);
    await tapText(tester, 'Malin');
    await tapText(tester, 'Agressif');
    await tapText(tester, 'Cool');
    expect(txt('Résultat · Zaki Mbela'), findsOneWidget);
    expect(repo.current['btl']['rival'], 'Zaki Mbela');
  });

  testWidgets('studio : écrire, enregistrer, sortir, résultats', (tester) async {
    final repo = await pump21(tester, preset('carriere'), location: '/studio');
    await tapText(tester, 'Écrire le texte');
    expect((repo.current['cur'] as J)['st'], 'ecrit');
    await tapText(tester, 'Choisir l’instru, puis la cabine');
    await tapText(tester, 'Gbaka de 6h');
    expect([repo.current['cash'], (repo.current['ui'] as J)['inst']], [312000, 'gbaka']);
    await tester.tap(txt('Passer en cabine'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Cabine21Screen), findsOneWidget);
    await tester.ensureVisible(txt('Enregistrer sans le mini-jeu'));
    await tester.tap(txt('Enregistrer sans le mini-jeu'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect((repo.current['cur'] as J)['st'], 'enregistre');
    // aucune navigation automatique : le joueur touche « Écouter le mix »
    expect(find.byType(Cabine21Screen), findsOneWidget);
    await tester.ensureVisible(txt('Écouter le mix'));
    await tester.tap(txt('Écouter le mix'));
    await tester.pumpAndSettle();
    expect(txt('MIX TERMINÉ'), findsOneWidget);
    await tapText(tester, 'Préparer la sortie');
    await tapText(tester, 'Sortir le titre');
    expect(txt('Résultats de la sortie'), findsOneWidget);
    expect((repo.current['disco'] as List).length, 2);
    expect(repo.current['cur'], isNull);
    expect(repo.current['hour'], 11);
  });

  testWidgets('scène : open mic puis résultat', (tester) async {
    final repo = await pump21(tester, preset('debut'), location: '/scene');
    await tapText(tester, 'Open mic de Ndolo');
    expect(repo.current['fans'], 270);
    expect(txt('Résultat de la date'), findsOneWidget);
  });

  testWidgets('vie de couple : le couple, la demande, le mariage', (tester) async {
    final repo = await pump21(tester, preset('couple'), location: '/perso/couple');
    expect(txt('Lina Mbaré'), findsWidgets);
    expect(txt('Une demande en mariage t’attend'), findsOneWidget);
    await tester.tap(txt('Une demande en mariage t’attend'));
    await tester.pumpAndSettle();
    expect(txt('Lina Mbaré te demande en mariage'), findsOneWidget);
    await tester.tap(txt('Accepter').last);
    await tester.pumpAndSettle();
    expect(txt('Préparer le mariage'), findsOneWidget);
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Confirmer le mariage');
    expect((repo.current['rom'] as J)['married'], 1);
    expect(txt('Vous êtes marié(e)s'), findsOneWidget);
  });

  testWidgets('famille : événement à choix et interactions parent-enfant', (tester) async {
    final repo = await pump21(tester, preset('parent'), location: '/famille/evenement');
    expect(txt("Fièvre la veille d'un concert"), findsOneWidget);
    await tester.tap(txt('Choisir').first);
    await tester.pumpAndSettle();
    expect((repo.current['fam'] as J)['ev'], isNull);
    final r2 = await pump21(tester, preset('parent'), location: '/famille/enfant');
    expect(txt('Jouer ensemble'), findsOneWidget);
    await tester.tap(txt('Jouer ensemble'));
    await tester.pumpAndSettle();
    expect(r2.current['hour'], 9);
  });

  testWidgets('partie sans artiste : le QG renvoie au démarrage', (tester) async {
    await pump21(tester, init21(), location: '/');
    expect(txt('Commencer'), findsOneWidget);
  });

  group('balayage de toutes les routes (aucun débordement ni exception)', () {
    const routes = [
      '/', '/studio', '/studio/instru', '/studio/cabine', '/studio/mix', '/studio/feats', '/studio/sortie', '/studio/resultats', '/studio/clip', '/studio/clip-publie',
      '/scene', '/scene/battle', '/scene/battle-result', '/scene/rivalites', '/scene/rival-battle/zaki', '/scene/resultat', '/scene/popularite', '/business', '/business/boulot', '/business/entreprises', '/business/patrimoine', '/business/achat', '/business/labels', '/business/manager', '/business/justice',
      '/profil', '/profil/rang', '/profil/classements', '/profil/annee', '/profil/reglages',
      '/journee', '/bilan', '/journal', '/evenement',
      '/perso', '/perso/profil', '/perso/interactions', '/perso/relation', '/perso/officialiser', '/perso/couple', '/perso/demande', '/perso/mariage', '/perso/confirmation', '/perso/separation',
      '/famille', '/famille/enfant', '/famille/evenement', '/famille/bilan',
      '/demarrer', '/nouvelle-partie', '/univers', '/artiste/identite', '/artiste/look', '/artiste/style', '/artiste/objectif', '/demo',
    ];
    for (final size in [(390.0, 844.0), (360.0, 800.0)]) {
      for (final p in ['debut', 'star', 'parent']) {
        testWidgets('${size.$1.toInt()} px · état $p', (tester) async {
          for (final r in routes) {
            final s = preset(p);
            if (r == '/bilan') {
              s['bil'] = act21(s, 'endDay').s['bil'];
            }
            await pump21(tester, s, location: r, width: size.$1, height: size.$2);
            expect(tester.takeException(), isNull, reason: '$r ($p, ${size.$1})');
          }
        });
      }
    }
  });
}
