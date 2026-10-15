// Captures à 390 x 844 de chaque écran, avec les vraies polices (Poppins, Baloo 2), pour les comparer aux planches v20.
// Usage : CAPTURE_DIR=<dossier> flutter test tool/capture_screens_test.dart   (sans CAPTURE_DIR, ce test ne fait rien)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/providers.dart';
import 'package:rap_empire/app/router.dart';
import 'package:rap_empire/core/theme/app_theme.dart';
import 'package:rap_empire/domain/clock.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';

import '../test/support.dart';

final _boundary = GlobalKey();

Future<void> _loadFonts() async {
  for (final f in const {
    'Poppins': ['Poppins-Regular', 'Poppins-SemiBold', 'Poppins-Bold', 'Poppins-ExtraBold'],
    'Baloo2': ['Baloo2-Variable'],
  }.entries) {
    final loader = FontLoader(f.key);
    for (final file in f.value) {
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }
}

Future<void> _open(WidgetTester tester, GameState start, String location, {SleepReport? report, bool settle = true}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [saveRepoProvider.overrideWithValue(FakeRepo(start)), if (report != null) lastSleepProvider.overrideWith((_) => report)],
    child: RepaintBoundary(key: _boundary, child: MaterialApp.router(theme: buildGameTheme(), routerConfig: buildRouter(initialLocation: location), debugShowCheckedModeBanner: false)),
  ));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tap(WidgetTester tester, String text) async {
  final f = find.byWidgetPredicate((w) => w is Text && w.data != null && w.data!.toLowerCase() == text.toLowerCase());
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

Future<void> _shot(WidgetTester tester, String name) async {
  final dir = Platform.environment['CAPTURE_DIR']!;
  await tester.runAsync(() async {
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await Directory(dir).create(recursive: true);
    await File('$dir/$name.png').writeAsBytes(bytes.buffer.asUint8List());
  });
}

void main() {
  if (Platform.environment['CAPTURE_DIR'] == null) {
    test('captures ignorées (CAPTURE_DIR absent)', () {});
    return;
  }
  setUpAll(_loadFonts);

  final picked = pick(const GameState(), 'gbaka');
  final written = write(picked);
  final rec = record(written);
  final released = release(claim(rec, 'm1'), 0); // cash 22 054, N2 en attente
  final acked = ack(released); // cash 24 054, mission 2 terminée
  final claimed = claim(acked, 'm2'); // cash 34 054

  final shots = <String, Future<void> Function(WidgetTester)>{
    '04-1-Studio-vide': (t) => _open(t, const GameState(), '/studio'),
    '04-2-Studio': (t) => _open(t, rec.copyWith(cash: 22000), '/studio'),
    '04-3-Instru': (t) => _open(t, const GameState(inst: 'gbaka'), '/studio/instru'),
    '04-4-Achat': (t) async {
      await _open(t, const GameState(xp: 120, cash: 24054, day: 2), '/studio/instru');
      await _tap(t, 'Pont des Griots');
    },
    '04-5-Ecriture': (t) => _open(t, picked, '/studio/ecriture'),
    '04-6-Texte': (t) => _open(t, written, '/studio/ecriture'),
    '04-7-Cabine': (t) => _open(t, written, '/studio/cabine'),
    '04-8-Minijeu': (t) async {
      await _open(t, written, '/studio/prises', settle: false); // le curseur anime sans fin : pas de pumpAndSettle
      await t.pump(const Duration(milliseconds: 600));
    },
    '04-9-Mix': (t) => _open(t, rec, '/studio/mix'),
    '05-1-Sortie': (t) => _open(t, rec.copyWith(cash: 22000), '/studio/sortie'),
    '05-1b-Cash-insuffisant': (t) async {
      await _open(t, rec.copyWith(cash: 4200), '/studio/sortie');
      await _tap(t, 'Radio locale');
    },
    '05-2-Promo': (t) async {
      await _open(t, rec.copyWith(cash: 22000), '/studio/sortie');
      await _tap(t, 'Radio locale');
      await _tap(t, 'Sortir le single');
    },
    '05-3-Chargement': (t) async {
      await _open(t, released, '/studio/chargement', settle: false);
      await t.pump(const Duration(milliseconds: 1152)); // 64 % de 1,8 s
    },
    '05-4-Resultats': (t) => _open(t, released, '/studio/resultats'),
    '10-2-Mission-accomplie': (t) => _open(t, acked, '/mission-accomplie'),
    '10-3-Nouvelle-mission': (t) => _open(t, claimed, '/nouvelle-mission'),
    '10-4-Level-up': (t) => _open(t, released, '/niveau'),
    '03-1-QG': (t) => _open(t, const GameState(), '/'),
    '03-2-QG-energie': (t) => _open(t, const GameState(cash: 6000, energy: 12, hour: 14), '/'),
    '03-6-Fin-journee': (t) async {
      const before = GameState(cash: 6000, energy: 12, hour: 14);
      await _open(t, sleep(before), '/fin-journee', report: SleepReport.between(before, sleep(before)));
    },
  };

  for (final e in shots.entries) {
    testWidgets('capture ${e.key}', (tester) async {
      await e.value(tester);
      await _shot(tester, e.key);
      // laisse les minuteries (toasts, chargement) se terminer
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
