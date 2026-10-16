import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/theme/app_theme.dart';
import 'package:rap_empire/core/theme/neon_tokens.dart';
import 'package:rap_empire/core/theme/tokens.dart';
import 'package:rap_empire/core/theme/v20.dart';
import 'package:rap_empire/core/widgets/cascade.dart';
import 'package:rap_empire/core/widgets/cost_row.dart';
import 'package:rap_empire/core/widgets/game_scaffold.dart';
import 'package:rap_empire/core/widgets/gauge_arc.dart';
import 'package:rap_empire/core/widgets/glass_card.dart';
import 'package:rap_empire/core/widgets/hero_stat.dart';
import 'package:rap_empire/core/widgets/locked_tile.dart';
import 'package:rap_empire/core/widgets/primary_glow_button.dart';
import 'package:rap_empire/core/widgets/reward_burst.dart';

import 'support.dart';

/// Composants de la direction Néon de Bakoma (docs/BRIEF.md) : un test de widget par composant, plus contraste, cibles de 48 px et débordements.

Future<void> _pump(WidgetTester tester, Widget child, {double width = 390, double height = 844, bool reduceMotion = false, double textScale = 1}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: buildGameTheme(),
    builder: (context, c) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion, textScaler: TextScaler.linear(textScale)), child: c!),
    home: Scaffold(backgroundColor: Tk.bg, body: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: child))),
  ));
}

double _lum(Color c) {
  double ch(double v) => v <= .03928 ? v / 12.92 : pow((v + .055) / 1.055, 2.4).toDouble();
  return .2126 * ch(c.r) + .7152 * ch(c.g) + .0722 * ch(c.b);
}

double _ratio(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  return (max(la, lb) + .05) / (min(la, lb) + .05);
}

Color _over(Color top, Color bottom) => Color.alphaBlend(top, bottom);

void main() {
  group('NeonTokens (ThemeExtension)', () {
    test('enregistrés dans buildGameTheme, valeurs de la direction', () {
      final t = buildGameTheme().extension<NeonTokens>()!;
      expect(t.rGlass, 20);
      expect(t.cascadeStep, const Duration(milliseconds: 80));
      expect([t.fast, t.base, t.slow].every((d) => d.inMilliseconds >= 150 && d.inMilliseconds <= 350), isTrue);
      expect(t.enter, Curves.easeOutCubic);
      expect(t.exit, Curves.easeInCubic);
    });
    test('lerp et copyWith', () {
      final a = NeonTokens.standard, b = a.copyWith(glassFill: Colors.black);
      expect(a.lerp(b, 1).glassFill, Colors.black);
      expect(a.lerp(null, .5), a);
      expect(b.rGlass, 20);
    });
    testWidgets('sans extension dans le thème : valeurs standard', (tester) async {
      late NeonTokens got;
      await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: Builder(builder: (c) {
        got = NeonTokens.of(c);
        return const SizedBox();
      })));
      expect(got, NeonTokens.standard);
    });
  });

  group('GlassCard', () {
    testWidgets('affiche son contenu ; rayon 20 et bord 1 px blanc à 10 %', (tester) async {
      await _pump(tester, const GlassCard(child: Text('Bonjour')));
      expect(find.text('Bonjour'), findsOneWidget);
      final ink = tester.widget<Ink>(find.byType(Ink));
      final deco = ink.decoration! as BoxDecoration;
      expect(deco.borderRadius, BorderRadius.circular(20));
      expect((deco.border! as Border).top.width, 1);
      expect(deco.color, NeonTokens.standard.glassFill);
    });
    testWidgets('touchable : cible d’au moins 48 px, appelle onTap', (tester) async {
      var taps = 0;
      await _pump(tester, GlassCard(onTap: () => taps++, child: const Text('x')));
      expect(tester.getSize(find.byType(GlassCard)).height, greaterThanOrEqualTo(48));
      await tester.tap(find.byType(GlassCard));
      expect(taps, 1);
    });
    testWidgets('accent : liseré coloré, halo retirable', (tester) async {
      await _pump(tester, const Column(children: [GlassCard(accent: GlassAccent.gold, child: Text('a')), GlassCard(accent: GlassAccent.magenta, halo: false, child: Text('b'))]));
      final decos = tester.widgetList<DecoratedBox>(find.descendant(of: find.byType(GlassCard), matching: find.byType(DecoratedBox))).where((d) => d.decoration is BoxDecoration && (d.decoration as BoxDecoration).boxShadow != null).toList();
      expect(decos.first.decoration as BoxDecoration, isA<BoxDecoration>());
      final shadows = decos.map((d) => (d.decoration as BoxDecoration).boxShadow!.first.blurRadius).toList();
      expect(shadows, contains(NeonTokens.standard.haloBlur)); // halo or
      expect(shadows.where((b) => b == NeonTokens.standard.haloBlur).length, 1); // le second n'a pas de halo
    });
  });

  group('HeroStat', () {
    testWidgets('compte de 0 jusqu’à la valeur formatée', (tester) async {
      await _pump(tester, const HeroStat(label: 'Écoutes', value: 5418, size: 56));
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      final mid = int.parse((tester.widget<Text>(find.byWidgetPredicate((w) => w is Text && RegExp(r'^[0-9 ]+$').hasMatch(w.data ?? ''))).data!).replaceAll(' ', ''));
      expect(mid, inInclusiveRange(1, 5417));
      await tester.pumpAndSettle();
      expect(find.text('5 418'), findsOneWidget);
      expect(find.text('ÉCOUTES'), findsOneWidget);
    });
    testWidgets('animations désactivées : valeur finale immédiate', (tester) async {
      await _pump(tester, const HeroStat(label: 'Fans', value: 120, prefix: '+'), reduceMotion: true);
      expect(find.text('+120'), findsOneWidget);
    });
    testWidgets('lu par les lecteurs d’écran comme un seul libellé', (tester) async {
      final h = tester.ensureSemantics();
      await _pump(tester, const HeroStat(label: 'Gain', value: 54, prefix: '+'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Gain +54'), findsOneWidget);
      h.dispose();
    });
    testWidgets('gros chiffre à 320 px et texte à 200 % : pas de débordement', (tester) async {
      await _pump(tester, const SizedBox(width: 120, child: HeroStat(label: 'Cash · cauris', value: 12345678, size: 56)), width: 320, textScale: 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('PrimaryGlowButton', () {
    testWidgets('pilule de 56 px, encre sombre sur dégradé rose, halo magenta, appelle onPressed', (tester) async {
      var taps = 0;
      await _pump(tester, PrimaryGlowButton(label: 'Aller au studio', onPressed: () => taps++));
      expect(tester.getSize(find.byType(PrimaryGlowButton)).height, greaterThanOrEqualTo(56));
      final text = tester.widget<Text>(find.text('ALLER AU STUDIO'));
      expect(text.style!.color, Tk.bg);
      final boxes = tester.widgetList<DecoratedBox>(find.descendant(of: find.byType(PrimaryGlowButton), matching: find.byType(DecoratedBox)));
      expect(boxes.any((b) => (b.decoration as BoxDecoration).boxShadow?.first.color == NeonTokens.standard.glowMagenta), isTrue);
      await tester.tap(find.byType(PrimaryGlowButton));
      expect(taps, 1);
    });
    testWidgets('désactivé : sans halo, sans appel', (tester) async {
      await _pump(tester, const PrimaryGlowButton(label: 'Plus tard', onPressed: null));
      await tester.tap(find.byType(PrimaryGlowButton), warnIfMissed: false);
      final boxes = tester.widgetList<DecoratedBox>(find.descendant(of: find.byType(PrimaryGlowButton), matching: find.byType(DecoratedBox)));
      expect(boxes.every((b) => (b.decoration as BoxDecoration).boxShadow == null), isTrue);
    });
    testWidgets('se comprime au toucher (retour en 150 ms)', (tester) async {
      await _pump(tester, PrimaryGlowButton(label: 'Go', onPressed: () {}));
      final g = await tester.startGesture(tester.getCenter(find.byType(PrimaryGlowButton)));
      await tester.pump(const Duration(milliseconds: 160));
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, lessThan(1));
      await g.up();
    });
    testWidgets('360 px, texte à 200 % : pas de débordement', (tester) async {
      await _pump(tester, PrimaryGlowButton(label: 'Préparer la sortie', sublabel: 'Single · promo · mise en ligne', onPressed: () {}), width: 360, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('CostRow', () {
    testWidgets('cauris en or avec icône et solde après', (tester) async {
      await _pump(tester, const CostRow(kind: CostKind.cauris, label: 'Si tu acceptes', amount: 8000, balanceAfter: 17000));
      expect(find.text('−8 000'), findsOneWidget);
      expect(tester.widget<Text>(find.text('−8 000')).style!.color, Tk.gold);
      expect(find.byType(CauriIcon), findsOneWidget);
      expect(find.text('Solde après : 17 000'), findsOneWidget);
    });
    testWidgets('solde négatif : « Cash insuffisant »', (tester) async {
      await _pump(tester, const CostRow(kind: CostKind.cauris, label: 'Prix', amount: 8000, balanceAfter: -2000));
      expect(find.textContaining('Cash insuffisant'), findsOneWidget);
    });
    testWidgets('énergie en cyan, temps en heures, gain avec +', (tester) async {
      await _pump(tester, const Column(children: [
        CostRow(kind: CostKind.energy, label: 'Énergie', amount: 45),
        CostRow(kind: CostKind.time, label: 'Temps', amount: 3),
        CostRow(kind: CostKind.cauris, label: 'Gain', amount: 54, gain: true),
      ]));
      expect(tester.widget<Text>(find.text('−45')).style!.color, Tk.cy);
      expect(find.text('3 h'), findsOneWidget);
      expect(find.text('+54'), findsOneWidget);
    });
  });

  group('LockedTile', () {
    testWidgets('cadenas, condition exacte et distance restante, touchable ≥ 48 px', (tester) async {
      var taps = 0;
      await _pump(tester, LockedTile(title: 'Pont des Griots', subtitle: 'Sanko Beats', condition: 'Niveau 2', remaining: '120 XP restants', onTap: () => taps++));
      expect(find.text('NIVEAU 2'), findsOneWidget);
      expect(find.text('120 XP restants'), findsOneWidget);
      expect(tester.getSize(find.byType(LockedTile)).height, greaterThanOrEqualTo(48));
      await tester.tap(find.byType(LockedTile));
      expect(taps, 1);
    });
    testWidgets('lecteur d’écran : verrouillé + condition', (tester) async {
      final h = tester.ensureSemantics();
      await _pump(tester, const LockedTile(title: 'Scène', subtitle: 'Open mic', condition: 'Pas encore dans la démo', onTap: null));
      expect(find.bySemanticsLabel(RegExp('verrouillé')), findsNothing); // sans onTap, la carte n'est pas un bouton
      await _pump(tester, LockedTile(title: 'Scène', subtitle: 'Open mic', condition: 'Pas encore dans la démo', onTap: () {}));
      expect(find.bySemanticsLabel(RegExp('Scène, verrouillé. Pas encore dans la démo')), findsOneWidget);
      h.dispose();
    });
    testWidgets('deux tuiles côte à côte à 360 px : pas de débordement', (tester) async {
      await _pump(
        tester,
        const Row(children: [
          Expanded(child: LockedTile(title: 'Classements', subtitle: 'Rang : Non classé', condition: 'Pas encore dans la démo')),
          SizedBox(width: 10),
          Expanded(child: LockedTile(title: 'Scène', subtitle: 'Open mic, battle', condition: 'Pas encore dans la démo')),
        ]),
        width: 360,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('GaugeArc', () {
    testWidgets('texte central, pourcentage lu, valeur 0 et 1 sans erreur', (tester) async {
      final h = tester.ensureSemantics();
      await _pump(tester, const Column(children: [
        GaugeArc(value: .032, label: 'Seuil', centerText: '3,2 %'),
        GaugeArc(value: 0, label: 'Zéro'),
        GaugeArc(value: 1.5, label: 'Plein'),
      ]));
      await tester.pumpAndSettle();
      expect(find.text('3,2 %'), findsOneWidget);
      expect(find.text('0 %'), findsOneWidget);
      expect(find.text('100 %'), findsOneWidget); // valeur bornée à 1
      expect(find.bySemanticsLabel('Seuil'), findsOneWidget);
      h.dispose();
    });
  });

  group('RewardBurst', () {
    testWidgets('joue une fois puis ne garde que le filigrane ; ne capte pas les touches', (tester) async {
      var taps = 0;
      await _pump(tester, SizedBox(height: 300, child: Stack(children: [GestureDetector(key: const Key('dessous'), behavior: HitTestBehavior.opaque, onTap: () => taps++, child: const SizedBox.expand()), const RewardBurst(haptic: false)])));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.tap(find.byKey(const Key('dessous')));
      expect(taps, 1);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.takeException(), isNull);
    });
    testWidgets('animations désactivées : aucune animation', (tester) async {
      await _pump(tester, const RewardBurst(haptic: false), reduceMotion: true);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('Cascade', () {
    testWidgets('tous les enfants sont dans l’arbre, visibles à la fin (80 ms de décalage)', (tester) async {
      await _pump(tester, const Cascade(children: [Text('un'), Text('deux'), Text('trois')]));
      expect(find.text('trois'), findsOneWidget);
      expect(tester.widget<Opacity>(find.ancestor(of: find.text('trois'), matching: find.byType(Opacity)).first).opacity, 0);
      await tester.pump(const Duration(milliseconds: 100));
      final first = tester.widget<Opacity>(find.ancestor(of: find.text('un'), matching: find.byType(Opacity)).first).opacity;
      final last = tester.widget<Opacity>(find.ancestor(of: find.text('trois'), matching: find.byType(Opacity)).first).opacity;
      expect(first, greaterThan(last));
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.ancestor(of: find.text('trois'), matching: find.byType(Opacity)).first).opacity, 1);
    });
    testWidgets('animations désactivées : tout visible tout de suite', (tester) async {
      await _pump(tester, const Cascade(children: [Text('un'), Text('deux')]), reduceMotion: true);
      expect(tester.widget<Opacity>(find.ancestor(of: find.text('deux'), matching: find.byType(Opacity)).first).opacity, 1);
    });
  });

  group('GameScaffold', () {
    testWidgets('sans décor : HUD et contenu', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(theme: buildGameTheme(), home: const GameScaffold(hud: Text('HUD'), body: Text('Contenu'))));
      expect(find.text('HUD'), findsOneWidget);
      expect(find.text('Contenu'), findsOneWidget);
      expect(find.byType(ImageFiltered), findsNothing);
    });
    testWidgets('avec décor illustré flou : charge assets/scenes/<scene>.svg', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(theme: buildGameTheme(), home: const GameScaffold(scene: 'qg_sky', hud: Text('HUD'), body: Text('Contenu'))));
      await tester.pumpAndSettle();
      expect(find.byType(ImageFiltered), findsOneWidget);
      expect(find.text('Contenu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Contraste ≥ 4,5 : 1 sur le verre fumé', () {
    final glass = _over(NeonTokens.standard.glassFill, Tk.bg);
    final pairs = <String, (Color, Color)>{
      'ink sur verre': (Tk.ink, glass),
      'ink2 (V20) sur verre': (V20.ink2, glass),
      'or (cauris) sur verre': (Tk.gold, glass),
      'cyan (énergie) sur verre': (Tk.cy, glass),
      'vert texte sur verre': (V20.okText, glass),
      'texte rose (accent) sur verre': (V20.accText, glass),
      'texte or clair sur verre': (V20.hintGoldText, glass),
      'texte risque sur verre': (V20.riskText, glass),
      'ink sur fond': (Tk.ink, Tk.bg),
      'encre sur bouton rose': (Tk.bg, V20.pinkBtn),
      'encre sur bouton lilas': (Tk.bg, V20.lilacBtn),
      'encre sur pastille verte (tag ok)': (Tk.bg, Tk.ok),
    };
    for (final e in pairs.entries) {
      test(e.key, () => expect(_ratio(e.value.$1, e.value.$2), greaterThanOrEqualTo(4.5)));
    }
  });

  // Rappel : les écrans eux-mêmes (QG, résultats, dialogue) sont couverts dans test/neon_screens_test.dart.
  test('support.dart disponible', () => expect(FakeRepo, isNotNull));
}
