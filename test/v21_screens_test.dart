import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/game21.dart';
import 'package:rap_empire/app/router21.dart';
import 'package:rap_empire/core/widgets/back_header.dart';
import 'package:rap_empire/data/save21_repository.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/domain/v21/artists21.dart' show parseDirectory21;
import 'package:rap_empire/features/v21/artists_screens.dart' show directory21Provider;
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
    overrides: [
      save21RepoProvider.overrideWithValue(repo),
      directory21Provider.overrideWith((_) async => parseDirectory21(File('assets/data/artistes-demo.json').readAsStringSync())),
    ],
    child: MaterialApp.router(theme: ThemeData.dark(useMaterial3: true), routerConfig: buildRouter21(initialLocation: location)),
  ));
  if (location == '/studio/cabine') {
    await tester.pump(const Duration(milliseconds: 100));
  } else {
    await tester.pumpAndSettle();
  }
  return repo;
}

J preset(String id) {
  if (id == 'prison') {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['jail'] = {'until': s['day'] + 5, 'days': 5};
    return s;
  }
  return act21(init21(), 'preset', id).s;
}

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
    await tapText(tester, 'Tamarel');
    await tapText(tester, 'Continuer');
    expect(txt('Ton look'), findsOneWidget);
    await tapText(tester, 'Afro');
    await tapText(tester, 'Continuer');
    expect(txt('Ton style musical'), findsOneWidget);
    await tester.ensureVisible(txt('Principal').at(1));
    await tester.pumpAndSettle();
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
    expect(txt('SEMAINE 1'), findsOneWidget);
    expect(txt("K-Zer d'Mabaya te défie"), findsOneWidget);

    // défi de K-Zer : la carte du QG ouvre l'événement, la battle se joue en 3 rounds
    await tapText(tester, "K-Zer d'Mabaya te défie");
    await tester.tap(txt('Choisir').first);
    await tester.pumpAndSettle();
    expect(repo.current['btq'], 'kzer');
    await tapText(tester, 'Malin');
    await tapText(tester, 'Agressif');
    await tapText(tester, 'Cool');
    await tapText(tester, 'Voir le résultat');
    expect(txt('BATTLE GAGNÉE · 3 / 3'), findsOneWidget);
    await tapText(tester, 'Retour au QG');

    // studio : texte, instru, cabine, mix, sortie
    await tester.tap(navTab('Studio'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Écrire le texte');
    await tapText(tester, 'Choisir l’instru, puis la cabine');
    await tapText(tester, 'Nuit à Ndo');
    await tester.tap(txt('Passer en cabine'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(txt('Enregistrer sans le mini-jeu'));
    await tester.tap(txt('Enregistrer sans le mini-jeu'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(txt('Écouter le mix'));
    await tester.tap(txt('Écouter le mix'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Préparer la sortie');
    await tapText(tester, 'Sortir le titre');
    expect(txt('Résultats de la sortie'), findsOneWidget);
    expect((repo.current['disco'] as List).length, 1);

    // catalogue puis classements
    await tester.tap(find.descendant(of: find.byType(BackHeader), matching: find.byType(GestureDetector)).first);
    await tester.pumpAndSettle();
    await tapText(tester, 'Catalogue, EP et album');
    expect(txt('CATALOGUE'), findsOneWidget);
    await tester.tap(navTab('Profil'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Classements');
    expect(txt('Top 100 Singles'), findsWidgets); // onglet et en-tête du classement
  });

  testWidgets('journée : événement, boulot, bilan', (tester) async {
    final repo = await pump21(tester, preset('debut'), location: '/evenement');
    expect(txt("K-Zer d'Mabaya te défie"), findsOneWidget);
    await tester.tap(txt('Choisir').first);
    await tester.pumpAndSettle();
    expect(repo.current['ev'], isNull);
    expect(repo.current['btq'], 'kzer');
    expect(txt('Round 1'), findsOneWidget);
    await tapText(tester, 'Malin');
    await tapText(tester, 'Agressif');
    await tapText(tester, 'Cool');
    // aucune navigation automatique : le joueur touche « Voir le résultat »
    expect(txt('Résultat de la battle'), findsNothing);
    await tapText(tester, 'Voir le résultat');
    expect(txt('BATTLE GAGNÉE · 3 / 3'), findsOneWidget);
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
      'platforms': Map.unmodifiable(<dynamic, dynamic>{'plat1': 5000, 'plat2': 3000, 'plat3': 2000}),
      'clip': Map.unmodifiable(<dynamic, dynamic>{'st': 'aucun'}),
    });
    await tapText(tester, 'Terminer la journée');
    expect(txt('Bilan de la journée'), findsOneWidget);
    expect(repo.current['day'], 2);
    await tapText(tester, 'Commencer la journée');
    expect(txt('SEMAINE 1'), findsOneWidget);
  });

  testWidgets('catalogue accepte les plateformes immuables des anciennes sauvegardes', (tester) async {
    final state = preset('debut');
    (state['disco'] as List).add({
      'id': 'OLD1', 'title': 'Ancien single', 'format': 'single', 'year': 1,
      'label': 'Indépendant', 'L': 1200, 'views': 0, 'sales': 0,
      'platforms': Map.unmodifiable(<dynamic, dynamic>{'plat1': 700, 'plat2': 300, 'plat3': 200}),
      'clip': {'st': 'aucun'}, 'feats': <dynamic>[]
    });
    await pump21(tester, state, location: '/studio/catalogue');
    expect(txt('Ancien single'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EP de 3 titres jusqu’au Top 50 EPs', (tester) async {
    final state = preset('star');
    state['fans'] = 400000;
    state['disco'] = [
      for (var i = 0; i < 3; i++)
        {'id': 'T$i', 'title': 'Titre $i', 'theme': 'quartier', 'amb': 'sombre', 'mode': 'manuel', 'tx': 72, 'st': 'sorti', 'Q': 60, 'feats': <dynamic>[], 'clip': {'st': 'aucun'}, 'L': 50000, 'rev': 0, 'fg': 0, 'pg': 0, 'tier': 'Bon', 'promo': 0, 'vir': 30, 'day': 10 + i},
    ];
    final repo = await pump21(tester, state, location: '/studio/catalogue');
    expect(txt('Aucun EP'), findsOneWidget);
    await tapText(tester, 'Créer un EP ou un album');
    expect(txt('Encore 3 titre(s) à choisir'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(txt('Ajouter').first);
      await tester.pumpAndSettle();
    }
    expect(txt('Prêt à sortir'), findsOneWidget);
    await tapText(tester, 'Sortir le projet');
    await tester.pumpAndSettle();
    await tapText(tester, 'Confirmer la sortie');
    await tester.pumpAndSettle();
    expect(txt('Projet sorti'), findsOneWidget);
    final p = (repo.current['projects'] as List).first as J;
    expect([p['type'], (p['tracks'] as List).length, (p['rank'] as num) > 0], ['EP', 3, true]);
    await tapText(tester, 'Voir les classements');
    await tapText(tester, 'Top 50 EPs'); // onglet du classement
    await tester.scrollUntilVisible(txt('TA POSITION'), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    expect(txt('TA POSITION'), findsOneWidget);
    expect(find.textContaining('${p['title']}'), findsWidgets);
  });

  /// Touche le bouton « Choisir » de la n-ième réponse d'un dialogue.
  Future<void> choose(WidgetTester tester, int i) async {
    final f = txt('Choisir').at(i);
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('offre de Kôrô en dialogue, négociée à 35 %', (tester) async {
    var st = preset('debut');
    st = act21(act21(st, 'create', ['quartier', 'sombre']).s, 'record').s;
    expect((st['dlg'] as J)['id'], 'kore');
    final repo = await pump21(tester, st, location: '/');
    // la carte « Dialogue » du QG ouvre la scène
    await tapText(tester, 'Dialogue');
    expect(txt('Échange 1/4'), findsOneWidget);
    await choose(tester, 0); // Rejouer le refrain
    expect(txt('Échange 2/4'), findsOneWidget);
    await choose(tester, 1); // Négocier
    expect(txt('Échange 3/4'), findsOneWidget);
    final cash = repo.current['cash'] as num;
    await choose(tester, 0); // 35 %, mix signé
    expect(txt('Accord à 35 %'), findsOneWidget);
    expect(((repo.current['kc'] as J)['st'], (repo.current['kc'] as J)['left'], repo.current['cash']), ('Accord à 35 %, mix signé', 3, cash - 7000));
    await tapText(tester, 'Continuer');
    expect(repo.current['dlg'], isNull);
  });

  testWidgets('offre de label signée après contre-offre', (tester) async {
    var st = preset('debut');
    st['rep'] = 12;
    st['disco'] = [
      {'id': 'T1', 'title': 'Gbaka', 'theme': 'quartier', 'amb': 'sombre', 'mode': 'manuel', 'tx': 72, 'st': 'sorti', 'Q': 60, 'feats': <dynamic>[], 'clip': {'st': 'aucun'}, 'L': 5000, 'rev': 0, 'fg': 0, 'pg': 0, 'tier': 'Discret', 'promo': 0, 'vir': 30, 'day': 1},
    ];
    st['dseen'] = {'kore': 'x', 'mgr': 'x'};
    st['lbz'] = Reg21.lbzGate; // les labels s'intéressent enfin au joueur
    st = act21(st, 'setui', 'th=amour').s; // déclenche les scènes
    expect((st['dlg'] as J)['id'], 'lb_AUB');
    final repo = await pump21(tester, st, location: '/dialogue');
    expect(txt('Awa Liméa · Découvreuse · Aube Nouvelle (Mabaya)'), findsOneWidget);
    await choose(tester, 1); // Négocier
    expect(txt('15 % sur 18 mois'), findsOneWidget);
    final cash = repo.current['cash'] as num;
    await choose(tester, 0);
    expect([repo.current['signed'], repo.current['label'], repo.current['lcut'], repo.current['cash']], [1, 'AUB', 0.15, cash + 30000]);
    expect(txt('Signé chez Aube Nouvelle (15 %)'), findsOneWidget);
  });

  testWidgets('contenu mature activé, arrestation, caution, avocat, procès, prison, sortie', (tester) async {
    var base = preset('debut');
    base['cash'] = 300000;
    base['heat'] = 80;
    // premier jour où le braquage mène à une garde à vue (hasard déterministe)
    J? arrested;
    var day = 1;
    final on = act21(base, 'mature', 'on').s;
    for (; day < 400 && arrested == null; day++) {
      final r = act21(clone21(on)..['day'] = day, 'crime', 'braquage');
      if (r.s['cas'] != null) arrested = r.s;
    }
    expect(arrested, isNotNull);
    // 1. verrouillé tant que le contenu mature est désactivé
    final repo = await pump21(tester, clone21(base), location: '/business/justice');
    expect(txt('Contenu mature désactivé'), findsOneWidget);
    expect((await ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(game21Provider.notifier).act('crime', 'braquage')), 'mature');
    await tapText(tester, 'Activer le contenu mature (16+)');
    expect(repo.current['mature'], 1);
    // 2. garde à vue : caution puis choix de l'avocat
    final repo2 = await pump21(tester, arrested!, location: '/business/justice/garde');
    expect(txt('Lieutenant Gnaoré'), findsOneWidget);
    await tapText(tester, 'Payer');
    expect((repo2.current['cas'] as J)['stage'], 'libre');
    expect(repo2.current['cash'], 300000 - 40000);
    await tapText(tester, 'Maître Sandra Lobé');
    expect((repo2.current['cas'] as J)['lawyer'], 'conf');
    // 3. tribunal le jour du procès : plaider coupable, puis la prison
    final trial = clone21(repo2.current)..['day'] = (repo2.current['cas'] as J)['trial'];
    final repo3 = await pump21(tester, trial, location: '/business/justice/tribunal');
    // le titre de la carte et son bouton portent le même texte : on touche le bouton (le dernier)
    await tester.ensureVisible(txt('Plaider coupable').last);
    await tester.pumpAndSettle();
    await tester.tap(txt('Plaider coupable').last);
    await tester.pumpAndSettle();
    expect(repo3.current['cas'], isNull);
    expect(repo3.current['verdict'], isNotNull);
    // Le verdict peut condamner à la prison : dans ce cas, le verrou V21 redirige immédiatement
    // l'interface vers la cellule. Vérifier le verdict dans l'état plutôt que chercher le texte hors prison.
    expect((repo3.current['verdict'] as J)['txt'], contains('Coupable'));
    expect((repo3.current['casier'] as List).length, 1);
    final prison = clone21(repo3.current);
    prison['jail'] = {'until': (prison['day'] as num) + 2, 'days': 2};
    final repo4 = await pump21(tester, prison, location: '/business/justice/prison');
    expect(txt('Encore 2 jour(s)'), findsOneWidget);
    await tapText(tester, 'Écrire');
    expect((repo4.current['sk'] as J)['ecr'], (prison['sk'] as J)['ecr'] + 2);
    await tapText(tester, 'Terminer la journée');
    await tapText(tester, 'Commencer la journée');
    expect(repo4.current['day'], (prison['day'] as num) + 1);
  });

  testWidgets('réseau artistique : interaction puis battle avec dialogue du rival', (tester) async {
    final repo = await pump21(tester, preset('debut'), location: '/scene/rivalites');
    expect(txt('Zaki Mbela'), findsWidgets);
    await tapText(tester, 'Discuter');
    expect((repo.current['rivals'] as J)['zaki']['relation'], 5);
    await tapText(tester, 'Répondre en freestyle');
    expect(txt('Djo Kéné · Zaki Mbela'), findsOneWidget);
    expect(txt('« Tu veux ma place sans avoir fait tes preuves. »'), findsOneWidget);
    await tapText(tester, 'Malin');
    await tapText(tester, 'Agressif');
    await tapText(tester, 'Cool');
    await tapText(tester, 'Voir le résultat');
    expect(txt('Battle · Zaki Mbela'), findsOneWidget);
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
    expect(find.textContaining('Effet de ce passage : 100 %'), findsOneWidget);
    await tapText(tester, 'Retour à la scène');
    // une fois par jour : la ligne passe à « reviens demain »
    expect(txt('Déjà joué aujourd’hui · reviens demain'), findsOneWidget);
    expect(repo.current['omK'], 1);
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

  testWidgets('création : le nom apparaît en direct, look et origine se choisissent en tuiles', (tester) async {
    final repo = await pump21(tester, init21(), location: '/artiste/identite');
    expect(txt('TON NOM DE SCÈNE'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'Young SM');
    await tester.pumpAndSettle();
    expect(txt('YOUNG SM'), findsOneWidget);
    await tapText(tester, 'Sélène');
    expect((repo.current['p'] as J)['origin'], 'selene');
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Nattes collées');
    await tapText(tester, 'Bomber violet');
    expect(((repo.current['ap'] as J)['hair'], (repo.current['ap'] as J)['top']), ('cornrows', 'bomber'));
    await tapText(tester, 'Ébène');
    expect((repo.current['ap'] as J)['skin'], '6');
    await tapText(tester, 'Surprends-moi');
    expect(Reg21.skins.containsKey((repo.current['ap'] as J)['skin']), isTrue);
  });

  testWidgets('espace merchandising : catalogue illustré, détail estimé, lancement', (tester) async {
    final s = preset('carriere')..['fans'] = 1500..['cash'] = 100000;
    final repo = await pump21(tester, s, location: '/business/labels');
    expect(txt('AUCUNE PRODUCTION EN VENTE'), findsOneWidget);
    expect(find.byKey(const ValueKey('merch-tshirt')), findsOneWidget);
    expect(find.byKey(const ValueKey('merch-capsule')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('merch-tshirt')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('merch-tshirt')));
    await tester.pumpAndSettle();
    expect(txt('Total estimé'), findsOneWidget);
    expect(find.textContaining('Bénéfice estimé').evaluate().length + find.textContaining('Perte estimée').evaluate().length, 1);
    await tester.tap(txt('Lancer la production'));
    await tester.pumpAndSettle();
    expect((repo.current['merch'] as J)['id'], 'tshirt');
    expect(repo.current['cash'], 80000);
    expect(txt('EN VENTE MAINTENANT'), findsOneWidget);
  });

  testWidgets('ton label : écurie, sources de revenus, libération', (tester) async {
    var s = preset('carriere')..['rank'] = 4..['cash'] = 2000000..['signed'] = 0;
    s = act21(s, 'olabel').s;
    s = act21(s, 'lsignart', {'id': 'ART-9', 'nom': 'Sô Lune', 'palier': 'Débutant', 'genre': 'Rap conscient', 'ville': 'Sélène', 'statut': 'indépendant', 'fans': 2400, 'ecoutes': 15000, 'pop': 20, 'talent': 40}).s;
    final repo = await pump21(tester, s, location: '/business/mon-label');
    expect(txt('REVENU NET ESTIMÉ PAR JOUR'), findsOneWidget);
    expect(txt('Streams'), findsOneWidget);
    expect(find.byKey(const ValueKey('ecurie-ART-9')), findsOneWidget);
    await tapText(tester, 'Libérer l’artiste');
    await tester.tap(txt('Libérer').last);
    await tester.pumpAndSettle();
    expect(((repo.current['olabel'] as J)['roster'] as List), isEmpty);
  });

  testWidgets('ton label : embaucher un profil de l’équipe', (tester) async {
    var s = preset('carriere')..['rank'] = 4..['cash'] = 2000000..['signed'] = 0;
    s = act21(s, 'olabel').s;
    final repo = await pump21(tester, s, location: '/business/mon-label');
    expect(txt('ÉQUIPE'), findsOneWidget);
    await tapText(tester, 'Embaucher');
    await tester.tap(txt('Embaucher').last);
    await tester.pumpAndSettle();
    expect(((repo.current['olabel'] as J)['staff'] as Map)['ar'], 'moussa');
    expect(repo.current['cash'], 2000000 - 500000 - 4200);
    expect(txt('Pourvu'), findsOneWidget);
  });

  testWidgets('espace manager : recruter, voir le contrat, quitter', (tester) async {
    final repo = await pump21(tester, preset('carriere'), location: '/business/manager');
    expect(txt('AUCUN MANAGER'), findsOneWidget);
    await tapText(tester, 'Recruter');
    await tapText(tester, 'Signer le contrat');
    expect(repo.current['mgr'], 'maya');
    expect(txt('Mettre fin au contrat'), findsOneWidget);
    await tapText(tester, 'Mettre fin au contrat');
    await tester.tap(txt('Mettre fin au contrat').last); // bouton de la feuille de confirmation
    await tester.pumpAndSettle();
    expect(repo.current['mgr'], isNull);
    await tester.scrollUntilVisible(txt('Séraphine Aboa'), 300, scrollable: find.byType(Scrollable).first); // M6 listé avec son profil
    expect(txt('Séraphine Aboa'), findsOneWidget);
  });

  testWidgets('espace label : contrat en héros, rupture avec pénalité chiffrée', (tester) async {
    final s = preset('carriere')
      ..['signed'] = 1
      ..['label'] = 'BLG'
      ..['lcut'] = 0.4
      ..['lperk'] = 'scene'
      ..['ladv'] = 80000
      ..['cash'] = 200000;
    final repo = await pump21(tester, s, location: '/business/labels/tous');
    expect(txt('SOUS CONTRAT'), findsOneWidget);
    await tapText(tester, 'Rompre le contrat');
    expect(find.textContaining('96 000'), findsWidgets);
    await tapText(tester, 'Payer 96 000 cauris et rompre');
    expect(repo.current['signed'], 0);
    expect(repo.current['cash'], 104000);
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(txt('Artiste indépendant'), findsOneWidget);
  });

  testWidgets('partie sans artiste : le QG renvoie au démarrage', (tester) async {
    await pump21(tester, init21(), location: '/');
    expect(txt('Commencer'), findsOneWidget);
  });

  testWidgets('garde-robe : achat direct, confirmation à 18 000, équipement', (tester) async {
    final s = preset('carriere')..['cash'] = 60000;
    final repo = await pump21(tester, s, location: '/profil/garde-robe');
    expect(txt('Garde-robe'), findsWidgets);
    expect(txt('Équipée'), findsOneWidget);
    await tapText(tester, 'Survêt Soleil');
    expect(find.textContaining('Aucune condition'), findsOneWidget);
    await tapText(tester, 'Acheter · 6 000 cauris');
    expect(((repo.current['wd'] as J)['owned'] as List), contains('OUTFIT_002'));
    expect(repo.current['cash'], 54000);
    await tapText(tester, 'Équiper');
    expect((repo.current['wd'] as J)['eq'], 'OUTFIT_002');
    // après « Équiper », retour direct à la garde-robe
    await tapText(tester, 'Veste Brume');
    await tapText(tester, 'Acheter · 18 000 cauris');
    expect(txt("Confirmer l'achat"), findsOneWidget);
    await tester.tap(txt('Annuler'));
    await tester.pumpAndSettle();
    expect(repo.current['cash'], 54000);
    expect((repo.current['wd'] as J)['ask'], isNull);
    await tapText(tester, 'Acheter · 18 000 cauris');
    await tester.tap(txt("Confirmer l'achat"));
    await tester.pumpAndSettle();
    expect(repo.current['cash'], 36000);
    expect(((repo.current['wd'] as J)['owned'] as List), contains('OUTFIT_003'));
  });

  testWidgets('garde-robe : onglets Coiffures et Tatouages, achat et équipement', (tester) async {
    final s = preset('carriere')..['cash'] = 60000;
    final repo = await pump21(tester, s, location: '/profil/garde-robe');
    await tester.tap(find.byKey(const ValueKey('onglet-Coiffures')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('apercu-look')), findsOneWidget);
    expect(find.byKey(const ValueKey('cos-fade')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('cos-fade')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cos-fade')));
    await tester.pumpAndSettle();
    await tapText(tester, 'Acheter · 1 500 cauris');
    expect((repo.current['wd'] as J)['hair'], 'fade');
    expect(repo.current['cash'], 58500);

    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onglet-Tatouages')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('cos-main_phalanges')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cos-main_phalanges')));
    await tester.pumpAndSettle();
    await tapText(tester, 'Acheter · 3 000 cauris');
    expect(((repo.current['wd'] as J)['tat'] as Map)['mains'], 'main_phalanges');
    expect(repo.current['cash'], 55500);
    await tapText(tester, 'Retirer ce tatouage');
    expect(((repo.current['wd'] as J)['tat'] as Map).containsKey('mains'), isFalse);
  });

  testWidgets('sortie programmée : date choisie, réserve, titre sorti le jour venu', (tester) async {
    var s = preset('carriere');
    s = act21(s, 'create', ['ambition', 'fiere']).s;
    s = act21(s, 'record').s;
    final title = (s['cur'] as J)['title'] as String;
    final repo = await pump21(tester, s, location: '/studio/sortie');
    await tapText(tester, '+3 jours');
    await tapText(tester, 'Programmer pour ${dateLabel21((s['day'] as num) + 3)}');
    expect(txt('Sorties à venir'), findsOneWidget);
    expect(txt(title), findsOneWidget);
    expect(txt('Programmé'), findsOneWidget);
    expect((repo.current['stock'] as List).length, 1);
    expect(repo.current['cur'], isNull);
    await tapText(tester, 'Annuler la date');
    expect(txt('En réserve'), findsOneWidget);
    expect(((repo.current['stock'] as List).first as J)['relDay'], isNull);
  });

  testWidgets('EP : un titre non sorti de la réserve est proposé comme inédit', (tester) async {
    var s = preset('carriere');
    s = act21(s, 'create', ['ambition', 'fiere']).s;
    s = act21(s, 'record').s;
    s = act21(s, 'shelve').s;
    await pump21(tester, s, location: '/studio/catalogue/projet');
    await tester.scrollUntilVisible(txt('Inédit'), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    expect(txt('Inédit'), findsOneWidget);
  });

  testWidgets('pochettes : choisir la pochette d\'un son depuis le Studio, puis revenir à l\'automatique', (tester) async {
    var s = preset('carriere');
    s = act21(s, 'create', ['ambition', 'fiere']).s;
    s = act21(s, 'record').s;
    final title = (s['cur'] as J)['title'] as String;
    final repo = await pump21(tester, s, location: '/studio/pochettes');
    expect(txt(title), findsOneWidget);
    expect(txt('Automatique'), findsWidgets);
    await tester.tap(txt(title));
    await tester.pumpAndSettle();
    expect(txt('POCHETTE'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('ambiance sombre, variante 3')).first);
    await tester.pumpAndSettle();
    final chosen = (repo.current['cur'] as J)['cover'] as String;
    expect(isCoverPath21(chosen), isTrue);
    expect(chosen.endsWith('_sombre_2.svg'), isTrue);
    expect(txt('Choisie'), findsOneWidget);
    await tester.tap(txt(title));
    await tester.pumpAndSettle();
    await tester.tap(txt('Pochette automatique'));
    await tester.pumpAndSettle();
    expect((repo.current['cur'] as J)['cover'], isNull);
  });

  testWidgets('réserve : titres programmés et sans date, sans débordement à 360 px', (tester) async {
    var s = preset('carriere');
    for (var i = 0; i < 2; i++) {
      s['en'] = 100;
      s['hour'] = 8;
      s = act21(s, 'create', ['ambition', 'fiere']).s;
      s = act21(s, 'record').s;
      s = i == 0 ? act21(s, 'schedule', 7).s : act21(s, 'shelve').s;
    }
    await pump21(tester, s, location: '/studio/reserve', width: 360, height: 800);
    expect(txt('Programmé'), findsOneWidget);
    expect(txt('En réserve'), findsWidgets);
    expect(txt('Sortir maintenant'), findsNWidgets(2));
  });

  testWidgets('trophées : le hall mène à la chambre des certifications et au salon des awards', (tester) async {
    final s = preset('carriere');
    await pump21(tester, s, location: '/profil/trophees');
    expect(txt('Chambre des certifications'), findsOneWidget);
    expect(txt('Salon des awards'), findsOneWidget);
    await tester.tap(txt('Chambre des certifications'));
    await tester.pumpAndSettle();
    expect(txt('Albums'), findsOneWidget);
    await tester.tap(txt('Albums'));
    await tester.pumpAndSettle();
    expect(txt('Aucune œuvre ici. Chaque single, EP ou album peut être certifié : or, platine, double, triple, diamant.'), findsOneWidget);
    await tester.scrollUntilVisible(txt('Échelle des paliers'), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    expect(txt('Échelle des paliers'), findsOneWidget);
  });

  testWidgets('salon des awards : prochaine cérémonie, palmarès et calendrier', (tester) async {
    final s = preset('carriere');
    await pump21(tester, s, location: '/profil/trophees/awards', width: 360, height: 800);
    expect(txt('PROCHAINE CÉRÉMONIE'), findsOneWidget);
    expect(txt('Palmarès'), findsOneWidget);
    await tester.scrollUntilVisible(txt('Prochaine'), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    expect(txt('Prochaine'), findsOneWidget);
  });

  testWidgets('catalogue : filtres Singles / EP et albums', (tester) async {
    var s = preset('carriere');
    s = act21(s, 'create', ['ambition', 'fiere']).s;
    s = act21(s, 'record').s;
    await pump21(tester, s, location: '/studio/catalogue');
    expect(find.byKey(const ValueKey('catalogue-hero')), findsOneWidget);
    await tester.tap(find.textContaining('EP et albums ·'));
    await tester.pumpAndSettle();
    expect(txt('Singles sortis'), findsNothing);
    expect(txt('Aucun EP ni album pour l’instant.'), findsOneWidget);
    await tester.tap(find.textContaining('Singles ·'));
    await tester.pumpAndSettle();
    expect(txt('Singles sortis'), findsOneWidget);
  });

  group('balayage de toutes les routes (aucun débordement ni exception)', () {
    const routes = [
      '/', '/studio', '/dialogue', '/scenes', '/studio/catalogue', '/studio/catalogue/titre', '/studio/catalogue/projet', '/studio/catalogue/projet-sorti', '/studio/instru', '/studio/cabine', '/studio/mix', '/studio/feats', '/studio/sortie', '/studio/resultats', '/studio/clip', '/studio/clip-publie',
      '/scene', '/scene/battle', '/scene/battle-result', '/scene/rivalites', '/scene/festivals', '/scene/booking', '/scene/rival-battle/zaki', '/scene/resultat', '/scene/popularite', '/business', '/business/boulot', '/business/entreprises', '/business/patrimoine', '/business/achat', '/business/formation', '/business/labels', '/business/labels/tous', '/business/manager', '/business/justice', '/business/justice/garde', '/business/justice/avocat', '/business/justice/tribunal', '/business/justice/prison',
      '/profil', '/profil/rang', '/profil/classements', '/profil/trophees', '/profil/wiki', '/profil/trophees/annonce', '/profil/trophees/certifications', '/profil/trophees/awards', '/profil/personnages', '/profil/garde-robe', '/studio/reserve', '/studio/pochettes', '/profil/garde-robe/tenue', '/profil/plateformes', '/profil/plateformes/ondea', '/profil/plateformes/klipo', '/profil/plateformes/cauri',
      '/profil/reseau', '/profil/reseau/ondea', '/profil/reseau/klipo', '/profil/reseau/klipo/video', '/profil/reseau/clips', '/profil/reseau/clips/clip', '/profil/reseau/cauri', '/profil/reseau/marketing',
      '/profil/reseau/ondea/titres', '/profil/reseau/ondea/sortie', '/profil/reseau/ondea/playlist', '/profil/reseau/ondea/playlist/pitch', '/profil/reseau/cauri/titres', '/profil/reseau/cauri/sortie',
      '/profil/reseau/social', '/profil/reseau/social/lueur', '/profil/reseau/social/bakoz', '/profil/reseau/social/griot', '/profil/annee', '/profil/reglages',
      '/journee', '/bilan', '/journal', '/evenement',
      '/perso', '/perso/profil', '/perso/interactions', '/perso/relation', '/perso/officialiser', '/perso/couple', '/perso/demande', '/perso/mariage', '/perso/confirmation', '/perso/separation',
      '/famille', '/famille/enfant', '/famille/evenement', '/famille/bilan',
      '/demarrer', '/nouvelle-partie', '/univers', '/artiste/identite', '/artiste/look', '/artiste/style', '/artiste/objectif', '/demo',
    ];
    for (final size in [(390.0, 844.0), (360.0, 800.0)]) {
      for (final p in ['debut', 'carriere', 'star', 'parent', 'prison']) {
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

  testWidgets('patrimoine : catégories, filtres, biens verrouillés par la réputation, fiche et achat', (tester) async {
    final st = preset('carriere');
    st['cash'] = 600000;
    st['rep'] = 8;
    final repo = await pump21(tester, st, location: '/business/patrimoine');
    expect(find.byKey(const ValueKey('patrimoine-hero')), findsOneWidget);
    expect(txt('VALEUR DU PATRIMOINE'), findsOneWidget);
    final list = find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first;
    // la bague (réputation 8) est disponible, pas la villa (55)
    await tester.scrollUntilVisible(find.byKey(const ValueKey('prod-bague')), 300, scrollable: list);
    expect(find.byKey(const ValueKey('prod-bague')), findsOneWidget);
    // filtre : véhicules seulement
    await tester.scrollUntilVisible(find.byKey(const ValueKey('patrimoine-cats')), -300, scrollable: list);
    await tester.tap(find.textContaining('Véhicules ·'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('prod-scooter')), 200, scrollable: list);
    expect(find.byKey(const ValueKey('prod-scooter')), findsOneWidget);
    expect(find.byKey(const ValueKey('prod-bague'), skipOffstage: false), findsNothing);
    // filtre d'état : verrouillés
    await tester.scrollUntilVisible(txt('Verrouillés'), -200, scrollable: list);
    await tester.tap(txt('Verrouillés'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('prod-scooter'), skipOffstage: false), findsNothing); // rep 0, accessible
    await tester.scrollUntilVisible(find.byKey(const ValueKey('prod-berline')), 200, scrollable: list);
    expect(find.byKey(const ValueKey('prod-berline')), findsOneWidget);
    expect(txt('RÉPUTATION 70'), findsOneWidget);
    // un bien verrouillé ne s'ouvre pas
    await tester.ensureVisible(find.byKey(const ValueKey('prod-berline')));
    await tester.pump();
    await tester.drag(list, const Offset(0, -120));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('prod-berline')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(txt('Réputation insuffisante'), findsWidgets);
    await tester.pumpAndSettle();
    expect(repo.current['ui']['buy'], isNull);
    // disponible : fiche puis achat
    await tester.scrollUntilVisible(txt('Disponibles'), -200, scrollable: list);
    await tester.tap(txt('Disponibles'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('prod-scooter')), 200, scrollable: list);
    await tester.ensureVisible(find.byKey(const ValueKey('prod-scooter')));
    await tester.pump();
    await tester.drag(list, const Offset(0, -120));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('prod-scooter')));
    await tester.pumpAndSettle();
    expect(txt('Fiche du bien'), findsOneWidget);
    expect(txt('Scooter'), findsWidgets);
    await tester.scrollUntilVisible(txt('Acheter'), 300, scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    await tester.tap(txt('Acheter'));
    await tester.pumpAndSettle();
    expect((repo.current['own'] as Map)['scooter'], isNotNull);
    expect(repo.current['cash'], 600000 - 25000);
  });

  testWidgets('battle : mini-jeu de Flow, une tentative par round, aucune animation tant qu’il n’est pas lancé', (tester) async {
    final st = preset('carriere');
    st['btq'] = 'kzer';
    await pump21(tester, st, location: '/scene/battle');
    expect(find.byKey(const ValueKey('battle-flow-hint')), findsOneWidget);
    expect(txt('Écouter le flow'), findsOneWidget);
    await tester.tap(txt('Écouter le flow'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(txt('Fige le flow'), findsOneWidget);
    await tester.tap(txt('Fige le flow'));
    await tester.pumpAndSettle(); // le curseur est arrêté : plus d'animation
    expect(txt('Écouter le flow'), findsNothing);
    expect(find.textContaining('Raté').evaluate().length + find.textContaining('Bien calé').evaluate().length, greaterThan(0));
  });

  testWidgets('réseau artistique : annuaire des 1 000 artistes, recherche, filtres, fiche', (tester) async {
    await pump21(tester, preset('debut'), location: '/scene/rivalites');
    expect(find.byKey(const ValueKey('reseau-hero')), findsOneWidget);
    expect(txt('1 000 artistes'), findsOneWidget);
    final list = find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('annuaire-recherche')), 300, scrollable: list);
    expect(find.byKey(const ValueKey('annuaire-compte')), findsOneWidget);
    // recherche sans accent ni casse
    await tester.enterText(find.byKey(const ValueKey('annuaire-recherche')), 'kaira');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(txt('Kaïra Nox'), 200, scrollable: list);
    expect(txt('1 artiste(s)'), findsOneWidget);
    // fiche d'un artiste
    await tester.ensureVisible(txt('Kaïra Nox'));
    await tester.pump();
    await tester.drag(list, const Offset(0, -120));
    await tester.pump();
    await tester.tap(txt('Kaïra Nox'));
    await tester.pumpAndSettle();
    expect(txt('Superstar internationale'), findsWidgets);
  });
}
