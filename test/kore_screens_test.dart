import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/core/widgets/character_view.dart';
import 'package:rap_empire/core/widgets/cost_row.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/kore.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

import 'support.dart';

/// Scène DJ Kôrô (planches 16-A1 à 16-A6) branchée sur kdeal : les choix appliquent les effets réels (cauris, relation, bonus de production).

const _sizes = [(390.0, 844.0), (360.0, 800.0)];

final _rec = record(write(pick(const GameState(), 'gbaka')));
final _acked = ack(release(claim(_rec, 'm1'), 0)); // cash 24 054

void _expectTapTargets(WidgetTester tester) {
  for (final w in tester.widgetList<InkWell>(find.byType(InkWell))) {
    if (w.onTap == null) continue;
    final size = tester.getSize(find.byWidget(w));
    expect(size.height, greaterThanOrEqualTo(48), reason: '$size');
    expect(size.width, greaterThanOrEqualTo(48));
  }
  for (final g in tester.widgetList<GestureDetector>(find.byType(GestureDetector))) {
    if (g.onTap == null) continue;
    final size = tester.getSize(find.byWidget(g));
    expect(size.height, greaterThanOrEqualTo(48), reason: '$size');
  }
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(txt(text).first);
  await tester.pumpAndSettle();
  await tester.tap(txt(text).first);
  await tester.pumpAndSettle();
}

void main() {
  group('A2 · offre de Kôrô', () {
    for (final (w, h) in _sizes) {
      testWidgets('à ${w.toInt()} × ${h.toInt()} : scène, réplique, trois choix étiquetés, pas de débordement, cibles ≥ 48', (tester) async {
        await pumpApp(tester, _acked, location: '/dialogue/offre-kore', width: w, height: h);
        expect(tester.takeException(), isNull);
        expect(txt('Offre de Kôrô'), findsOneWidget);
        expect(txt('Étape 2 / 6'), findsOneWidget);
        expect(txt('DJ Kôrô'), findsOneWidget);
        expect(find.textContaining('je prends 40 %'), findsOneWidget);
        for (final c in ['Accepter de travailler avec lui', 'Négocier les conditions', 'Refuser et rester indépendant']) {
          expect(txt(c), findsOneWidget, reason: c);
        }
        expect(txt('Certain'), findsNWidgets(3));
        expect(txt('Estimé'), findsNWidgets(2));
        expect(txt('Incertain'), findsNWidgets(2));
        expect(txt('Risque'), findsOneWidget);
        expect(txt('Valeurs de démo · D-08'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is CharacterView && w.who == 'kore' && w.mood == 'poised' && w.gesture == 'deal'), findsOneWidget);
        _expectTapTargets(tester);
      });
    }

    testWidgets('solde après accord sur le cash réel ; insuffisant signalé', (tester) async {
      await pumpApp(tester, _acked, location: '/dialogue/offre-kore');
      expect(find.byType(CostRow), findsOneWidget);
      expect(find.text('Solde après : 16 054'), findsOneWidget);
      await pumpApp(tester, _acked.copyWith(cash: 5000), location: '/dialogue/offre-kore');
      expect(find.textContaining('Cash insuffisant ·'), findsOneWidget);
    });

    testWidgets('accord déjà conclu : bandeau, choix inactifs', (tester) async {
      final done = kdeal(_acked, 'acc');
      final repo = await pumpApp(tester, done, location: '/dialogue/offre-kore');
      expect(find.textContaining('Accord déjà conclu : Accord à 40 %'), findsOneWidget);
      await tester.ensureVisible(txt('Refuser et rester indépendant'));
      await tester.tap(txt('Refuser et rester indépendant'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(txt('Refus'), findsNothing);
      expect(repo.current.kc, done.kc);
    });
  });

  group('parcours : accepter', () {
    testWidgets('A2 → A4 : −8 000 cauris, accord à 40 %, relation +15, bonus lu dans l’accord réel', (tester) async {
      final repo = await pumpApp(tester, _acked, location: '/dialogue/offre-kore');
      await _tap(tester, 'Accepter de travailler avec lui');
      expect(txt('Accord conclu'), findsWidgets);
      expect(repo.current.cash, 16054);
      expect(repo.current.kc, const KoreDeal(st: 'acc', rel: 15, cut: '40 %', cost: 8000, left: 3, bonus: 12));
      expect(txt('Conséquences enregistrées'), findsOneWidget);
      expect(txt('Accord à 40 %'), findsOneWidget);
      expect(find.text('−8 000'), findsOneWidget);
      expect(txt('+15'), findsOneWidget);
      expect(txt('+12 production · 3 titres'), findsOneWidget);
      expect(repo.current.cat['instru'], -8000 - 8000); // instru Gbaka (8 000) + accord (8 000)
      await _tap(tester, 'Aller au studio');
      expect(txt('Studio'), findsWidgets);
    });

    testWidgets('cash insuffisant : toast, on reste sur l’offre, rien ne change', (tester) async {
      final poor = _acked.copyWith(cash: 5000);
      final repo = await pumpApp(tester, poor, location: '/dialogue/offre-kore');
      await _tap(tester, 'Accepter de travailler avec lui');
      expect(txt('Cash insuffisant'), findsOneWidget);
      expect(txt('Offre de Kôrô'), findsOneWidget);
      expect(repo.current.cash, 5000);
      expect(repo.current.kc, const KoreDeal());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('bonus de production appliqué au prochain son enregistré', (tester) async {
      final deal = kdeal(_acked, 'acc').copyWith(song: null, energy: 100);
      final s = record(write(pick(deal, 'nuit')));
      expect(s.song!.prod, 32 + 12);
      expect(s.kc.left, 2);
    });
  });

  group('parcours : négocier', () {
    testWidgets('A2 → A3 : contre-offre, 35 % et mix signé → A4', (tester) async {
      final repo = await pumpApp(tester, _acked, location: '/dialogue/offre-kore');
      await _tap(tester, 'Négocier les conditions');
      expect(txt('Contre-offre'), findsWidgets);
      expect(txt('Étape 3 / 6'), findsOneWidget);
      expect(find.textContaining('je descends à 35 %'), findsOneWidget);
      expect(repo.current.kc, const KoreDeal()); // négocier seul n'engage rien
      await _tap(tester, '35 % et mix signé');
      expect(repo.current.kc, const KoreDeal(st: 'neg', rel: 8, cut: '35 %', cost: 7000, left: 3, bonus: 12));
      expect(repo.current.cash, 17054);
      expect(txt('Accord à 35 % (mix signé)'), findsOneWidget);
    });

    testWidgets('A3 : insister à 30 % → refus (relation −5) ; revenir à 40 % → relation +15 (game.js, pas +3 de la planche)', (tester) async {
      final repo = await pumpApp(tester, _acked, location: '/dialogue/contre-offre-kore');
      expect(find.textContaining('Relation +15 · −8 000 cauris'), findsOneWidget);
      await _tap(tester, 'Insister à 30 %');
      expect(repo.current.kc, const KoreDeal(st: 'ref', rel: -5, cut: '30 %'));
      expect(txt('Refus'), findsWidgets);
      expect(txt('-5'), findsOneWidget);
      final repo2 = await pumpApp(tester, _acked, location: '/dialogue/contre-offre-kore');
      await _tap(tester, 'Revenir à l’offre initiale (40 %)');
      expect(repo2.current.kc.st, 'acc');
    });
  });

  group('parcours : refuser puis revenir', () {
    testWidgets('A2 → A5 (relation −10) → A6 → accepter à 45 % : −6 000, relation −5, retour au QG', (tester) async {
      final repo = await pumpApp(tester, _acked, location: '/dialogue/offre-kore');
      await _tap(tester, 'Refuser et rester indépendant');
      expect(txt('Mémoire du personnage'), findsOneWidget);
      expect(txt('-10'), findsOneWidget);
      expect(find.textContaining('Kôrô se souvient du refus'), findsOneWidget);
      expect(repo.current.cash, 24054);
      await _tap(tester, 'Trois semaines plus tard');
      expect(txt('3 semaines plus tard'), findsWidgets);
      expect(txt('Étape 6 / 6'), findsOneWidget);
      await _tap(tester, 'Accepter à 45 %');
      expect(repo.current.kc, const KoreDeal(st: 'back', rel: -5, cut: '45 %', cost: 6000, left: 3, bonus: 12));
      expect(repo.current.cash, 18054);
      expect(txt('Salut, Djo'), findsOneWidget); // QG
      expect(find.byWidgetPredicate((w) => w is Text && (w.data ?? '').toLowerCase().contains('accord conclu')), findsOneWidget); // toast (casse ignorée)
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('A6 : via l’assistant (bonus +6 sur 2 titres) et refus définitif', (tester) async {
      final repo = await pumpApp(tester, kdeal(_acked, 'ref'), location: '/dialogue/retour-kore');
      await _tap(tester, 'Passer par son assistant');
      expect(repo.current.kc, const KoreDeal(st: 'assist', rel: -10, cut: 'tarif assistant', left: 2, bonus: 6));
      expect(repo.current.cash, 24054);
      await tester.pump(const Duration(seconds: 5));
      final repo2 = await pumpApp(tester, kdeal(_acked, 'ref'), location: '/dialogue/retour-kore');
      await _tap(tester, 'Décliner définitivement');
      expect(repo2.current.kc.st, 'decl');
      expect(repo2.current.kc.rel, -25);
      expect(txt('Mes finances'), findsNothing); // on est au Business (réseau), pas au profil
    });

    testWidgets('A5 après refus définitif : pas de « Trois semaines plus tard »', (tester) async {
      await pumpApp(tester, kdeal(_acked, 'decl'), location: '/dialogue/refus-kore');
      expect(txt('Refus définitif'), findsWidgets);
      expect(txt('Trois semaines plus tard'), findsNothing);
    });

    testWidgets('A6 à 360 × 800 : pas de débordement, cibles ≥ 48', (tester) async {
      await pumpApp(tester, kdeal(_acked, 'ref'), location: '/dialogue/retour-kore', width: 360, height: 800);
      expect(tester.takeException(), isNull);
      expect(txt('Scène différente de A2 : Kôrô se souvient de ton refus.'), findsOneWidget);
      _expectTapTargets(tester);
    });
  });

  group('première visite au Studio (16-A1)', () {
    testWidgets('nouvelle partie : le Studio ouvre l’écoute de Kôrô, une seule fois', (tester) async {
      final repo = await pumpApp(tester, newGameState, location: '/studio');
      expect(txt('Studio Kôrô'), findsWidgets);
      expect(txt('Étape 1 / 6'), findsOneWidget);
      expect(find.textContaining('la prod est brute'), findsOneWidget);
      expect(repo.current.koreIntro, isFalse); // marquée comme montrée
    });

    testWidgets('retour au Studio : plus de redirection, une carte « DJ Kôrô · Offre » reste joignable → A2', (tester) async {
      await pumpApp(tester, newGameState, location: '/studio');
      await tapBack(tester);
      expect(txt('Aucun son enregistré'), findsOneWidget);
      expect(txt('DJ Kôrô'), findsOneWidget);
      expect(txt('Offre'), findsOneWidget);
      await _tap(tester, 'DJ Kôrô');
      expect(txt('Offre de Kôrô'), findsOneWidget);
    });

    testWidgets('A1 → A2 : les deux choix mènent à l’offre sans effet', (tester) async {
      final repo = await pumpApp(tester, newGameState, location: '/dialogue/ecoute-kore');
      final before = repo.current.cash;
      await _tap(tester, 'Rejouer le refrain');
      expect(txt('Offre de Kôrô'), findsOneWidget);
      expect(repo.current.cash, before);
      expect(repo.current.kc, const KoreDeal());
    });

    testWidgets('une partie déjà commencée (koreIntro faux) ouvre le Studio sans dialogue', (tester) async {
      await pumpApp(tester, const GameState(), location: '/studio');
      expect(txt('Aucun son enregistré'), findsOneWidget);
    });

    testWidgets('après un accord, la carte Kôrô disparaît du Studio ; après un refus elle devient « Retour »', (tester) async {
      await pumpApp(tester, kdeal(_acked, 'acc'), location: '/studio');
      expect(txt('DJ Kôrô'), findsNothing);
      await pumpApp(tester, kdeal(_acked, 'ref'), location: '/studio');
      expect(txt('Retour'), findsOneWidget);
    });
  });
}
