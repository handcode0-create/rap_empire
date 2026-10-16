import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/widgets/cost_row.dart';
import 'package:rap_empire/core/widgets/hero_stat.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';

import 'support.dart';

/// Parcours Studio en direction Néon de Bakoma (accueil, instru, écriture, cabine, prises, mix) : contenu, conséquences affichées avant la décision,
/// pas de débordement et cibles ≥ 48 px à 390 × 844 et 360 × 800.

const _sizes = [(390.0, 844.0), (360.0, 800.0)];

final _picked = pick(const GameState(), 'gbaka');
final _written = write(_picked);
final _rec = record(_written);

void _expectTapTargets(WidgetTester tester) {
  for (final w in tester.widgetList<InkWell>(find.byType(InkWell))) {
    if (w.onTap == null) continue;
    final size = tester.getSize(find.byWidget(w));
    expect(size.height, greaterThanOrEqualTo(48), reason: 'InkWell $size');
    expect(size.width, greaterThanOrEqualTo(48));
  }
  for (final g in tester.widgetList<GestureDetector>(find.byType(GestureDetector))) {
    if (g.onTap == null) continue;
    final size = tester.getSize(find.byWidget(g));
    expect(size.height, greaterThanOrEqualTo(48), reason: 'GestureDetector $size');
    expect(size.width, greaterThanOrEqualTo(48));
  }
}

void main() {
  final screens = <String, (GameState, String)>{
    'studio vide': (const GameState(), '/studio'),
    'studio avec un son à sortir': (_rec, '/studio'),
    'studio avec discographie': (release(_rec, 0), '/studio'),
    'instru': (const GameState(), '/studio/instru'),
    'écriture (choix)': (_picked, '/studio/ecriture'),
    'écriture (texte)': (_written, '/studio/ecriture'),
    'cabine': (_written, '/studio/cabine'),
    'mix': (_rec, '/studio/mix'),
  };
  for (final e in screens.entries) {
    for (final (w, h) in _sizes) {
      testWidgets('${e.key} à ${w.toInt()} × ${h.toInt()} : pas de débordement, cibles ≥ 48', (tester) async {
        await pumpApp(tester, e.value.$1, location: e.value.$2, width: w, height: h);
        expect(tester.takeException(), isNull);
        _expectTapTargets(tester);
      });
    }
  }

  testWidgets('prises à 360 × 800 : pas de débordement, cibles ≥ 48', (tester) async {
    await pumpApp(tester, _written, location: '/studio/prises', settle: false, width: 360, height: 800);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    _expectTapTargets(tester);
  });

  group('studio', () {
    testWidgets('un son à sortir : qualité et notes en chiffres héros, un seul bouton principal, « Nouveau son » explique', (tester) async {
      await pumpApp(tester, _rec, location: '/studio');
      expect(find.byType(HeroStat), findsNWidgets(4)); // qualité + texte, voix, prod.
      expect(txt('Préparer la sortie'), findsOneWidget);
      await tester.tap(txt('Nouveau son'));
      await tester.pump();
      expect(txt('Sors ton son en attente avant d’en créer un autre'), findsOneWidget);
      expect(txt('Choisis une instru'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
    });
  });

  group('instru', () {
    testWidgets('verrous : la condition ET la distance restante', (tester) async {
      await pumpApp(tester, const GameState(xp: 40), location: '/studio/instru');
      expect(txt('N2'), findsOneWidget);
      expect(txt('Il te manque 60 XP'), findsOneWidget); // 100 - 40
      expect(txt('Rép. 30'), findsOneWidget);
      expect(txt('Il te manque 22 de réputation'), findsOneWidget); // 30 - 8
    });
    testWidgets('prix en or avec l’icône cauri ; gratuit en vert', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/instru');
      expect(tester.widget<Text>(txt('8 000 cauris')).style!.color, const Color(0xFFFFC83D));
      expect(tester.widget<Text>(txt('Gratuit')).style!.color, const Color(0xFF3DDC97));
      expect(find.byType(CauriIcon), findsWidgets);
    });
    testWidgets('instru choisie : sélectionnée, étiquette Q accentuée', (tester) async {
      await pumpApp(tester, const GameState(inst: 'gbaka'), location: '/studio/instru');
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.selected == true), findsWidgets);
    });
  });

  group('écriture', () {
    testWidgets('chaque ambiance annonce son coût (Certain) et sa note (Estimé) AVANT la décision', (tester) async {
      await pumpApp(tester, _picked, location: '/studio/ecriture');
      expect(txt('1 h · −20 énergie'), findsNWidgets(3));
      for (final n in ['72', '74', '70']) {
        expect(txt('Note du texte : $n'), findsOneWidget, reason: n); // Sombre 72, Fière 74, Légère 70
      }
      expect(txt('Certain'), findsNWidgets(3));
      expect(txt('Estimé'), findsNWidgets(3));
    });
    testWidgets('texte écrit : note en chiffre héros, Rimes et Images marquées Démo', (tester) async {
      await pumpApp(tester, _written, location: '/studio/ecriture');
      expect(find.byType(HeroStat), findsNWidgets(3));
      expect(txt('Démo'), findsNWidgets(2));
      expect(txt('Passer en cabine'), findsOneWidget);
    });
  });

  group('mix', () {
    testWidgets('qualité en chiffre héros avec « / 100 », détail en cascade, deux boutons', (tester) async {
      await pumpApp(tester, _rec, location: '/studio/mix');
      expect(txt('61 / 100'), findsOneWidget);
      expect(find.byType(HeroStat), findsNWidgets(4));
      expect(txt('Préparer la sortie'), findsOneWidget);
      expect(txt('Récupérer la mission'), findsOneWidget);
    });
  });
}
