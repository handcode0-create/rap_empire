import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/widgets/character_view.dart';
import 'package:rap_empire/core/widgets/gauge_arc.dart';
import 'package:rap_empire/core/widgets/hero_stat.dart';
import 'package:rap_empire/core/widgets/reward_burst.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';

import 'support.dart';

/// Écrans pilotes de la direction Néon de Bakoma : QG et résultats de sortie (la scène DJ Kôrô est dans test/kore_screens_test.dart). Mêmes providers, mêmes règles ;
/// on vérifie le contenu, les personnages, les cibles de 48 px et l'absence de débordement à 390 × 844 et 360 × 800.

const _sizes = [(390.0, 844.0), (360.0, 800.0)];

final _rec = record(write(pick(const GameState(), 'gbaka')));
final _released = release(claim(_rec, 'm1'), 0);
final _acked = ack(_released);

/// Chaque zone touchable de l'écran (InkWell et GestureDetector avec onTap) mesure au moins 48 × 48 px.
void _expectTapTargets(WidgetTester tester) {
  for (final w in tester.widgetList<InkWell>(find.byType(InkWell))) {
    if (w.onTap == null) continue;
    final size = tester.getSize(find.byWidget(w));
    expect(size.height, greaterThanOrEqualTo(48), reason: 'InkWell ${w.child.runtimeType} ${tester.getTopLeft(find.byWidget(w))} : $size');
    expect(size.width, greaterThanOrEqualTo(48));
  }
  for (final g in tester.widgetList<GestureDetector>(find.byType(GestureDetector))) {
    if (g.onTap == null) continue;
    final size = tester.getSize(find.byWidget(g));
    expect(size.height, greaterThanOrEqualTo(48), reason: 'GestureDetector : $size');
    expect(size.width, greaterThanOrEqualTo(48));
  }
}

void main() {
  group('QG (03.1 · 17.5)', () {
    for (final (w, h) in _sizes) {
      testWidgets('départ à ${w.toInt()} × ${h.toInt()} : héros, appui, tuiles, pas de débordement, cibles ≥ 48', (tester) async {
        await pumpApp(tester, const GameState(), width: w, height: h);
        expect(tester.takeException(), isNull);
        expect(txt('Salut, Djo'), findsOneWidget);
        expect(txt('Objectif en cours'), findsOneWidget);
        expect(txt('Mission 1'), findsOneWidget);
        expect(txt('Aller au studio'), findsOneWidget);
        for (final t in ['Fans', 'Popularité', 'Réputation', 'Studio', 'Créer un son', 'Missions', 'Objectifs et primes', 'Scène', 'Classements', 'Rang : Non classé']) {
          expect(txt(t), findsWidgets, reason: t);
        }
        expect(find.byType(HeroStat), findsNWidgets(3));
        expect(txt('Hors démo'), findsNWidgets(2)); // les deux tuiles verrouillées disent leur condition
        _expectTapTargets(tester);
      });
    }

    testWidgets('Djo (assets/characters) déborde de la carte héroïque, expression selon la situation', (tester) async {
      await pumpApp(tester, const GameState());
      expect(find.byWidgetPredicate((w) => w is CharacterView && w.who == 'djo' && w.mood == 'smile' && w.crop == 'torso'), findsOneWidget);
      await pumpApp(tester, const GameState(energy: 12));
      await tester.tap(txt('Pas maintenant'));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((w) => w is CharacterView && w.who == 'djo' && w.mood == 'worried'), findsOneWidget);
    });

    testWidgets('mission prête : Djo rit, « Récupérer », récompenses visibles', (tester) async {
      await pumpApp(tester, _acked);
      expect(find.byWidgetPredicate((w) => w is CharacterView && w.mood == 'laugh'), findsOneWidget);
      expect(txt('Terminée'), findsOneWidget);
      expect(txt('Récupérer'), findsOneWidget);
      expect(txt('cauris'), findsOneWidget);
      expect(txt('XP'), findsOneWidget);
    });

    testWidgets('« Aller au studio » reste branché sur le même parcours', (tester) async {
      await pumpApp(tester, const GameState());
      await tester.tap(txt('Aller au studio'));
      await tester.pumpAndSettle();
      expect(txt('Aucun son enregistré'), findsOneWidget);
    });

    testWidgets('tuiles : Studio affiche son coût en énergie et en heures ; Scène ouvre la scène', (tester) async {
      await pumpApp(tester, const GameState());
      expect(find.textContaining('−45 énergie · 3 h'), findsOneWidget);
      await tapText(tester, 'Scène');
      expect(txt('Freestyle au carrefour'), findsOneWidget);
    });
  });

  group('Résultats de sortie (05.4)', () {
    for (final (w, h) in _sizes) {
      testWidgets('première sortie à ${w.toInt()} × ${h.toInt()} : chiffre héroïque, cascade, jauge, éclat de victoire, cibles ≥ 48', (tester) async {
        await pumpApp(tester, _released, location: '/studio/resultats', width: w, height: h);
        expect(tester.takeException(), isNull);
        final r = _released.rel!;
        expect(txt('Résultats · 24 h'), findsOneWidget);
        expect(txt('Écoutes'), findsOneWidget);
        expect(txt('Estimé'), findsOneWidget);
        expect(find.text('5 418'), findsOneWidget);
        expect(find.text('+${r.revenue}'), findsOneWidget);
        expect(find.text('+${r.fans}'), findsOneWidget);
        expect(find.text('+${r.pop}'), findsOneWidget);
        expect(txt('Non classé'), findsOneWidget);
        expect(txt('Top 100 Singles'), findsOneWidget);
        expect(find.byType(GaugeArc), findsOneWidget);
        expect(find.byType(RewardBurst), findsOneWidget); // vraie victoire : premier single
        expect(txt('Retour au QG'), findsOneWidget);
        _expectTapTargets(tester);
      });
    }

    testWidgets('deuxième sortie sans niveau gagné : pas d’éclat', (tester) async {
      final second = release(record(write(pick(ack(_released).copyWith(energy: 100), 'nuit'))), 0);
      await pumpApp(tester, second.copyWith(pend: null), location: '/studio/resultats');
      expect(find.byType(RewardBurst), findsNothing);
    });

    testWidgets('niveau gagné : « Retour au QG » ouvre le niveau', (tester) async {
      await pumpApp(tester, _released, location: '/studio/resultats');
      await tester.tap(txt('Retour au QG'));
      await tester.pumpAndSettle();
      expect(txt('Niveau supérieur'), findsWidgets);
    });

    testWidgets('sans sortie : message et retour au studio (inchangé)', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio/resultats');
      expect(txt('Aucune sortie pour l’instant.'), findsOneWidget);
    });
  });

  test('les combinaisons de personnages utilisées existent dans assets/characters (CharacterView n’affiche rien sinon)', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final f in [
      'djo_smile_torso', 'djo_worried_torso', 'djo_laugh_torso', 'djo_serious_torso', 'djo_neutral_torso', 'kore_poised_deal_torso', 'kore_neutral_torso',
      'kore_laugh_torso', 'kore_angry_torso', 'kore_smirk_torso',
    ]) {
      final data = await rootBundle.load('assets/characters/$f.svg');
      expect(data.lengthInBytes, greaterThan(100), reason: f);
    }
  });
}
