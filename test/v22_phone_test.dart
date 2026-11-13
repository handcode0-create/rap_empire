import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/game21.dart';
import 'package:rap_empire/app/router21.dart';
import 'package:rap_empire/data/save21_repository.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/core/widgets/primary_glow_button.dart';
import 'package:rap_empire/features/v21/scene_business_screens.dart' show SceneScreen21;

class _FakeSave21Repository extends Save21Repository {
  final J current;
  _FakeSave21Repository(this.current);

  @override
  Future<J> load() async => current;

  @override
  Future<void> save(J state) async {}
}

void main() {
  test('les invitations V22 affichées par le téléphone proviennent du moteur existant', () {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['rank'] = 4;
    final invitations = cvView21(s)
        .where((offer) => offer['status'] == 'available')
        .toList();

    expect(invitations, hasLength(3));
    expect(invitations.map((offer) => offer['id']).toSet(), hasLength(3));
    expect(invitations.every((offer) => offer['title'] is String), isTrue);
    expect(invitations.every((offer) => offer['cityName'] is String), isTrue);
  });

  test('l’affichage des invitations ne modifie pas la sauvegarde', () {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['rank'] = 4;

    cvView21(s);

    expect(s.containsKey('cv'), isFalse);
  });

  testWidgets('accepter depuis le téléphone met à jour la même sauvegarde et renouvelle les offres', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final s = act21(init21(), 'preset', 'carriere').s;
    s['rank'] = 4;
    final container = ProviderContainer(
      overrides: [save21RepoProvider.overrideWithValue(_FakeSave21Repository(s))],
    );
    addTearDown(container.dispose);
    await container.read(game21Provider.future);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: ThemeData.dark(useMaterial3: true),
        routerConfig: buildRouter21(initialLocation: '/telephone'),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('ACCEPTER L’INVITATION').first, 250);
    await tester.tap(find.text('ACCEPTER L’INVITATION').first);
    await tester.pumpAndSettle();

    final saved = container.read(game21Provider).requireValue;
    final offers = cvView21(saved);
    expect(offers.where((offer) => offer['status'] == 'accepted'), hasLength(1));
    expect(offers.where((offer) => offer['status'] == 'available'), hasLength(3));
  });

  testWidgets('le bouton ACCEPTER de la page Scène enregistre bien une invitation V22', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final s = act21(init21(), 'preset', 'carriere').s;
    s['rank'] = 4;
    final container = ProviderContainer(
      overrides: [save21RepoProvider.overrideWithValue(_FakeSave21Repository(s))],
    );
    addTearDown(container.dispose);
    await container.read(game21Provider.future);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(body: SceneScreen21()),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final acceptButton = find.widgetWithText(PrimaryGlowButton, 'ACCEPTER');
    expect(acceptButton, findsNWidgets(3));
    await tester.ensureVisible(acceptButton.first);
    final widget = tester.widget<PrimaryGlowButton>(acceptButton.first);
    expect(widget.onPressed, isNotNull);
    await tester.tap(acceptButton.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final saved = container.read(game21Provider).requireValue;
    final offers = cvView21(saved);
    expect(offers.where((offer) => offer['status'] == 'accepted'), hasLength(1));
    expect(offers.where((offer) => offer['status'] == 'available'), hasLength(3));
  });

  testWidgets('le téléphone affiche les invitations et le répertoire sans créer un second moteur', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final s = act21(init21(), 'preset', 'carriere').s;
    s['rank'] = 4;
    await tester.pumpWidget(ProviderScope(
      overrides: [save21RepoProvider.overrideWithValue(_FakeSave21Repository(s))],
      child: MaterialApp.router(
        theme: ThemeData.dark(useMaterial3: true),
        routerConfig: buildRouter21(initialLocation: '/telephone'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('RAP PHONE'), findsOneWidget);
    expect(find.text('BOÎTE DE RÉCEPTION'), findsOneWidget);
    expect(find.text('INVITATION DE CONCERT'), findsNWidgets(3));
    expect(find.text('ACCEPTER L’INVITATION'), findsNWidgets(3));
    expect(find.text('TON TÉLÉPHONE'), findsNothing);
    await tester.scrollUntilVisible(find.text('RÉPERTOIRE'), 250);
    expect(find.text('RÉPERTOIRE'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Manager'), 250);
    expect(find.text('Manager'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Réseaux sociaux'), 250);
    expect(find.text('Réseaux sociaux'), findsOneWidget);
  });
}
