import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/game21.dart';
import 'package:rap_empire/app/router21.dart';
import 'package:rap_empire/data/save21_repository.dart';
import 'package:rap_empire/domain/v21/artists21.dart' show parseDirectory21;
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/features/v21/artists_screens.dart' show directory21Provider;
import 'package:rap_empire/features/v21/copyright_screens.dart';

import 'support.dart' show tapText, txt;

/// Droits d'auteur : animation spéciale, avis, rendez-vous, issue, carte du QG, choix des instrus.
class _Repo extends Save21Repository {
  J current;
  _Repo(this.current);
  @override
  Future<J> load() async => current;
  @override
  Future<void> save(J s) async => current = s;
}

Future<_Repo> _pump(WidgetTester tester, J start, String location, {double width = 390, double height = 844}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _Repo(start);
  await tester.pumpWidget(ProviderScope(
    key: UniqueKey(),
    overrides: [
      save21RepoProvider.overrideWithValue(repo),
      directory21Provider.overrideWith((_) async => parseDirectory21(File('assets/data/artistes-demo.json').readAsStringSync())),
    ],
    child: MaterialApp.router(theme: ThemeData.dark(useMaterial3: true), routerConfig: buildRouter21(initialLocation: location)),
  ));
  await tester.pumpAndSettle();
  return repo;
}

J _m(dynamic x) => x as J;

/// Carrière avec un titre viral sur une instru non autorisée, jusqu'à l'avis de réclamation.
J claimState() {
  var s = act21(init21(), 'preset', 'carriere').s;
  (s['disco'] as List).insert(0, <String, dynamic>{
    'id': 'T90', 'title': 'Titre test', 'day': s['day'], 'L': 3000000, 'launchL': 3000000, 'rev': 400000, 'inst': 'brume', 'signed': 0,
    'platforms': <String, dynamic>{}, 'clip': <String, dynamic>{'st': 'aucun'}, 'st': 'sorti',
    'cr': <String, dynamic>{'st': 'nonaut', 'lic': 'nonaut', 'owner': 'woro'},
  });
  for (var i = 0; i < 60; i++) {
    s = act21(s, 'endDay').s;
    if (s['crc'] != null && _m(s['crc'])['st'] == 'avis') break;
  }
  expect(_m(s['crc'])['st'], 'avis');
  s['dlg'] = null;
  s['dq'] = <dynamic>[];
  s['cash'] = 2000000;
  return s;
}

void main() {
  testWidgets('animation spéciale : alerte, titre, montant qui compte, puis bouton actif', (tester) async {
    var done = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CopyrightStrike(kind: 'avis', title: 'Titre test', owner: 'Mister Wôrô', headline: 'LITIGE DE DROITS D’AUTEUR', amount: 140000, stakes: const ['Une conséquence'], onDone: () => done = true),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    expect(txt('AVIS DE RÉCLAMATION · DROITS D’AUTEUR'), findsWidgets);
    await tester.pumpAndSettle();
    expect(txt('LITIGE DE DROITS D’AUTEUR'), findsOneWidget);
    expect(txt('${fmt21(140000)} cauris'), findsOneWidget);
    expect(txt('« Titre test »'), findsOneWidget);
    await tester.tap(txt('Voir l’avis'));
    expect(done, isTrue);
  });

  testWidgets('animation spéciale : état final immédiat quand l’appareil réduit les animations', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Scaffold(
          body: SingleChildScrollView(
            child: CopyrightStrike(kind: 'retrait', title: 'Titre test', owner: 'Ondéa', headline: 'TITRE RETIRÉ', amount: 0, stakes: const [], onDone: () {}),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(txt('TITRE RETIRÉ'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('avis : animation, puis les quatre réponses ; payer règle le litige', (tester) async {
    final s = claimState();
    final repo = await _pump(tester, s, '/droits');
    expect(txt('LITIGE DE DROITS D’AUTEUR'), findsOneWidget);
    await tapText(tester, 'Voir l’avis');
    expect(_m(repo.current['crc'])['seen'], 1);
    for (final t in ['Négocier un accord', 'Payer immédiatement', 'Contester la réclamation', 'Ignorer la réclamation']) {
      expect(txt(t), findsOneWidget, reason: t);
    }
    final amt = crDue21(repo.current);
    await tapText(tester, 'Payer ${fmt21(amt)}');
    expect([repo.current['crc'], repo.current['cash']], [null, 2000000 - amt]);
  });

  testWidgets('rendez-vous : le producteur refuse la moitié, la tension monte', (tester) async {
    final s = claimState();
    _m(s['crc'])['seen'] = 1;
    s['mgr'] = null;
    s['signed'] = 0;
    final repo = await _pump(tester, s, '/droits');
    await tapText(tester, 'Aller au rendez-vous');
    expect(_m(repo.current['crc'])['st'], 'nego');
    expect(find.byType(RendezVousScreen), findsOneWidget);
    final half = ((_m(repo.current['crc'])['amt'] as num) * .5).round();
    await tapText(tester, 'Proposer ${fmt21(half)}');
    expect([_m(repo.current['crc'])['node'], _m(repo.current['crc'])['tension']], ['refus', 1]);
    expect(txt('Très tendu').evaluate().isNotEmpty || txt('Tendu').evaluate().isNotEmpty, isTrue);
    expect(txt('Payer ce qu’il demande'), findsOneWidget);
  });

  testWidgets('retrait : issue mise en scène, puis le QG', (tester) async {
    final s = claimState();
    s['crOut'] = {'type': 'retrait', 'title': 'Titre test', 'fans': 120, 'pop': 4, 'rep': 3, 'why': 'test', 'seen': 0, 'day': s['day']};
    s['crc'] = null;
    final repo = await _pump(tester, s, '/droits');
    expect(txt('TITRE RETIRÉ'), findsOneWidget);
    await tapText(tester, 'Compris');
    expect(_m(repo.current['crOut'])['seen'], 1);
  });

  testWidgets('QG : carte de litige urgente qui ouvre l’avis', (tester) async {
    final s = claimState();
    await _pump(tester, s, '/');
    expect(txt('LITIGE DE DROITS D’AUTEUR'), findsOneWidget);
    await tapText(tester, 'LITIGE DE DROITS D’AUTEUR');
    expect(find.byType(CopyrightStrike), findsOneWidget);
  });

  testWidgets('instrus : trois familles, conditions affichées, licence exclusive', (tester) async {
    var s = act21(init21(), 'preset', 'carriere').s;
    s = act21(s, 'create', ['quartier', 'sombre']).s;
    final repo = await _pump(tester, s, '/studio/instru', height: 2600);
    for (final t in ['GRATUITES SUR KLIPO', 'SOUS LICENCE', 'AVEC UN PRODUCTEUR DU JEU', 'Non autorisée', 'Avec conditions', 'Libre de droits']) {
      expect(txt(t).evaluate().isNotEmpty || find.textContaining(t).evaluate().isNotEmpty, isTrue, reason: t);
    }
    final c0 = repo.current['cash'] as num;
    await tapText(tester, 'Licence exclusive · ${fmt21(8000 * CrReg21.exclMult)}');
    expect([(repo.current['ui'] as J)['inst'], (repo.current['ui'] as J)['instLic'], repo.current['cash']], ['gbaka', 'excl', c0 - 8000 * CrReg21.exclMult]);
  });

  testWidgets('fiche du titre : statut des droits et licence à acheter', (tester) async {
    final s = act21(init21(), 'preset', 'carriere').s;
    final t = _m((s['disco'] as List).first);
    t['inst'] = 'minuit';
    t['L'] = 600000;
    t['cr'] = <String, dynamic>{'st': 'cond', 'lic': 'cond', 'owner': 'tamsir'};
    (s['ui'] as J)['ctk'] = t['id'];
    await _pump(tester, s, '/studio/catalogue/titre', height: 2600);
    expect(find.textContaining('DROITS D’AUTEUR'), findsWidgets);
    expect(find.textContaining('Acheter la licence', findRichText: true).evaluate().isNotEmpty || txt('Acheter la licence · ${fmt21(crRegPrice21(t))} cauris').evaluate().isNotEmpty, isTrue);
  });
}
