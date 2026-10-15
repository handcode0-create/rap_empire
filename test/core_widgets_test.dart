import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/theme/app_theme.dart';
import 'package:rap_empire/core/widgets/bottom_sheet_game.dart';
import 'package:rap_empire/core/widgets/choice_card.dart';
import 'package:rap_empire/core/widgets/game_nav_bar.dart';
import 'package:rap_empire/core/widgets/game_toast.dart';
import 'package:rap_empire/core/widgets/hud_bar.dart';
import 'package:rap_empire/core/widgets/meter_bar.dart';
import 'package:rap_empire/core/widgets/mission_card.dart';
import 'package:rap_empire/core/widgets/portrait.dart';
import 'package:rap_empire/core/widgets/primary_button.dart';
import 'package:rap_empire/core/widgets/reward_chip.dart';
import 'package:rap_empire/core/widgets/scene_banner.dart';
import 'package:rap_empire/core/widgets/stat_kpi.dart';
import 'package:rap_empire/core/widgets/xp_progress.dart';

import 'support.dart';

Future<void> _pump(WidgetTester tester, Widget child, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: buildGameTheme(), home: Scaffold(body: SafeArea(child: child))));
  await tester.pump();
}

void main() {
  group('xpFraction : parité avec xpPct de game.js (view)', () {
    // Valeurs obtenues en exécutant game.js (v20) avec Node : xp -> pourcentage de la barre.
    const expected = {0: 0, 1: 1, 50: 50, 99: 99, 100: 0, 120: 13, 175: 50, 249: 99, 250: 0, 499: 100, 500: 0, 899: 100, 900: 0, 1000: 17, 1500: 100, 2000: 100};
    for (final e in expected.entries) {
      test('${e.key} XP : ${e.value} %', () => expect(xpFraction(e.key), e.value / 100));
    }
  });

  group('PrimaryButton', () {
    testWidgets('texte en majuscules, sous-libellé, tap, 56 px de haut', (tester) async {
      var taps = 0;
      await _pump(tester, PrimaryButton(label: 'Dormir', sublabel: 'Nuit gratuite · démo', onPressed: () => taps++));
      expect(txt('DORMIR'), findsOneWidget);
      expect(txt('NUIT GRATUITE · DÉMO'), findsOneWidget);
      expect(tester.getSize(find.byType(PrimaryButton)).height, greaterThanOrEqualTo(56));
      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 1);
    });
    testWidgets('indisponible : aucun tap', (tester) async {
      var taps = 0;
      await _pump(tester, PrimaryButton(label: 'Non', onPressed: () => taps++, style: GameButtonStyle.disabled));
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      expect(taps, 0);
    });
    testWidgets('onPressed nul : désactivé', (tester) async {
      await _pump(tester, const PrimaryButton(label: 'Non', onPressed: null));
      expect(tester.widget<InkWell>(find.descendant(of: find.byType(PrimaryButton), matching: find.byType(InkWell))).onTap, isNull);
    });
    testWidgets('compact : 48 px minimum', (tester) async {
      await _pump(tester, PrimaryButton(label: 'Ok', onPressed: () {}, compact: true));
      expect(tester.getSize(find.byType(PrimaryButton)).height, greaterThanOrEqualTo(48)); // cible tactile minimale
    });
  });

  group('MeterBar', () {
    testWidgets('remplit la part demandée', (tester) async {
      await _pump(tester, const SizedBox(width: 200, child: MeterBar(value: .5)));
      await tester.pumpAndSettle();
      final fill = tester.getSize(find.descendant(of: find.byType(MeterBar), matching: find.byType(AnimatedContainer)));
      expect(fill.width, 100);
    });
    testWidgets('valeur bornée entre 0 et 1', (tester) async {
      await _pump(tester, const SizedBox(width: 200, child: MeterBar(value: 3)));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.descendant(of: find.byType(MeterBar), matching: find.byType(AnimatedContainer))).width, 200);
    });
    testWidgets('mince (HUD) 6 px, standard 10 px', (tester) async {
      await _pump(tester, const Column(children: [MeterBar(value: .2, thin: true), SizedBox(height: 8), MeterBar(value: .2)]));
      expect(tester.getSize(find.byType(MeterBar).first).height, 6);
      expect(tester.getSize(find.byType(MeterBar).last).height, 10);
    });
  });

  group('GameNavBar', () {
    testWidgets('cinq onglets, 72 px, onglet actif signalé', (tester) async {
      var tapped = -1;
      await _pump(tester, Align(alignment: Alignment.bottomCenter, child: GameNavBar(currentIndex: 2, onTap: (i) => tapped = i)));
      for (final e in GameNavBar.entries) {
        expect(txt(e.label), findsOneWidget);
      }
      expect(GameNavBar.entries.map((e) => e.label), ['QG', 'Studio', 'Scène', 'Business', 'Profil']);
      expect(tester.getSize(find.byType(GameNavBar)).height, closeTo(72 + 2, 3)); // 72 + bordure haute de 2
      await tester.tap(txt('Profil'));
      expect(tapped, 4);
    });
  });

  group('HudBar', () {
    testWidgets('niveau, cauris, énergie et temps affichés', (tester) async {
      await _pump(tester, const HudBar(name: 'Djo Kéné', levelLabel: 'N1 · Inconnu', xp: .3, cash: '25 000', energy: '100', time: 'J1 08:00'));
      for (final t in ['DK', 'Djo Kéné', 'N1 · INCONNU', 'CASH · CAURIS', '25 000', 'ÉNERGIE', '100', 'TEMPS', 'J1 08:00']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
    });
    testWidgets('un libellé de niveau long ne déborde pas', (tester) async {
      await _pump(tester, const HudBar(name: 'Djo Kéné', levelLabel: 'N2 · Espoir du quartier', xp: .1, cash: '24 054', energy: '100', time: 'J2 08:00'));
      expect(tester.takeException(), isNull);
    });
    testWidgets('la cloche appelle onBell', (tester) async {
      var rung = 0;
      await _pump(tester, HudBar(name: 'Djo', levelLabel: 'N1', xp: 0, cash: '0', energy: '0', time: 'J1', onBell: () => rung++));
      await tester.tap(find.bySemanticsLabel('Journal'));
      expect(rung, 1);
    });
  });

  group('MissionCard', () {
    testWidgets('étiquette, titre en majuscules, texte, bouton sombre', (tester) async {
      var go = 0;
      await _pump(
        tester,
        SingleChildScrollView(child: MissionCard(tag: 'Mission 1', title: 'Enregistre ton premier son', hint: 'Choisis une instru.', progress: 0, actionLabel: 'Aller au studio', onAction: () => go++)),
      );
      expect(txt('OBJECTIF EN COURS'), findsOneWidget);
      expect(txt('MISSION 1'), findsOneWidget);
      expect(txt('ENREGISTRE TON PREMIER SON'), findsOneWidget);
      expect(txt('Choisis une instru.'), findsOneWidget);
      await tester.tap(txt('ALLER AU STUDIO'));
      expect(go, 1);
    });
    testWidgets('terminée : étiquette et puces de récompense', (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: MissionCard(
            tag: 'Mission 1',
            statusTag: 'Terminée',
            title: 'Sors ton single',
            progress: 1,
            rewards: const [RewardChip(value: '+5 000', label: 'cauris'), RewardChip(value: '+50', label: 'XP')],
            actionLabel: 'Récupérer',
            onAction: () {},
          ),
        ),
      );
      for (final t in ['TERMINÉE', '+5 000', 'CAURIS', '+50', 'XP', 'RÉCUPÉRER']) {
        expect(txt(t), findsOneWidget, reason: t);
      }
    });
  });

  group('StatKpi', () {
    testWidgets('libellé en majuscules, valeur et variation', (tester) async {
      await _pump(tester, const StatKpi(label: 'Énergie', value: '100', delta: '+ repos', big: true));
      expect(txt('ÉNERGIE'), findsOneWidget);
      expect(txt('100'), findsOneWidget);
      expect(txt('+ repos'), findsOneWidget);
    });
  });

  group('SceneBanner', () {
    testWidgets('bannière du QG : le portrait de 64 px dépasse du bas de 11 px (calcul de art.ban)', (tester) async {
      await _pump(
        tester,
        const SizedBox(width: 358, child: SceneBanner(kind: 'qg_sky', height: 72, name: 'Salut, Djo', chars: [BannerChar('djo', crop: 'torso', width: 64, left: 306)])),
      );
      expect(tester.getSize(find.byType(SceneBanner)).height, 72);
      final p = tester.widgetList<Positioned>(find.byType(Positioned)).firstWhere((p) => p.width == 64);
      expect(p.bottom, closeTo(72 - 64 * 340 / 260, 0.01)); // -11,69 : le haut du portrait reste dans la bannière
      expect(txt('SALUT, DJO'), findsOneWidget);
    });
    testWidgets('rôle et nom en surimpression', (tester) async {
      await _pump(tester, const SizedBox(width: 358, child: SceneBanner(kind: 'studio', role: 'Nuit passée', name: 'Nouvelle journée', height: 200)));
      expect(txt('NUIT PASSÉE'), findsOneWidget);
      expect(txt('NOUVELLE JOURNÉE'), findsOneWidget);
    });
  });

  group('GameToast', () {
    testWidgets('s\'affiche en haut de l\'écran, jamais en bas, puis disparaît', (tester) async {
      await _pump(tester, Builder(builder: (context) => TextButton(onPressed: () => showGameToast(context, 'Mission accomplie', kind: ToastKind.success), child: const Text('go'))));
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(txt('MISSION ACCOMPLIE'), findsOneWidget);
      final y = tester.getTopLeft(txt('MISSION ACCOMPLIE')).dy;
      expect(y, lessThan(120)); // sous la barre d'état, au-dessus du contenu (planche : top 40)
      await tester.pump(const Duration(seconds: 4));
      expect(txt('MISSION ACCOMPLIE'), findsNothing);
    });
    testWidgets('un nouveau toast remplace le précédent', (tester) async {
      await _pump(tester, Builder(builder: (context) => TextButton(onPressed: () => showGameToast(context, 'Un'), onLongPress: () => showGameToast(context, 'Deux'), child: const Text('go'))));
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.longPress(find.text('go'));
      await tester.pump();
      expect(txt('UN'), findsNothing);
      expect(txt('DEUX'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('BottomSheetGame', () {
    testWidgets('feuille ouverte au style v20 : contenu et boutons', (tester) async {
      await _pump(tester, Builder(builder: (context) => TextButton(onPressed: () => showGameSheet<void>(context, builder: (_) => const Text('Contenu de la feuille')), child: const Text('go'))));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheetGame), findsOneWidget);
      expect(find.text('Contenu de la feuille'), findsOneWidget);
    });
    testWidgets('non fermable : le geste de fermeture est refusé', (tester) async {
      await _pump(tester, Builder(builder: (context) => TextButton(onPressed: () => showGameSheet<void>(context, dismissible: false, builder: (_) => const Text('À acquitter')), child: const Text('go'))));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(195, 20)); // sur le voile
      await tester.pumpAndSettle();
      expect(find.text('À acquitter'), findsOneWidget);
    });
  });

  group('ChoiceCard et ConsequenceTag', () {
    testWidgets('quatre natures de conséquence, texte associé', (tester) async {
      await _pump(
        tester,
        const SingleChildScrollView(
          child: ChoiceCard(title: 'Accepter', consequences: [
            Consequence(ConsequenceKind.certain, '−30 énergie'),
            Consequence(ConsequenceKind.estimated, 'Recette ≈ 12 000 cauris'),
            Consequence(ConsequenceKind.uncertain, 'Réaction de Madame Orage'),
            Consequence(ConsequenceKind.risk, 'Élevé'),
          ]),
        ),
      );
      for (final t in ['Certain', 'Estimé', 'Incertain', 'Risque', '−30 énergie', 'Recette ≈ 12 000 cauris']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });
    testWidgets('tap, et refus quand la carte est verrouillée', (tester) async {
      var n = 0;
      await _pump(tester, Column(children: [ChoiceCard(title: 'Libre', onTap: () => n++), ChoiceCard(title: 'Verrouillée', locked: true, onTap: () => n += 10)]));
      await tester.tap(find.text('Libre'));
      await tester.tap(find.text('Verrouillée'));
      expect(n, 1);
    });
  });

  group('Portrait', () {
    testWidgets('monogramme : initiales en majuscules', (tester) async {
      await _pump(tester, const Portrait('mk', size: 52));
      expect(find.text('MK'), findsOneWidget);
      expect(tester.getSize(find.byType(Portrait)), const Size(52, 52));
    });
  });
}
