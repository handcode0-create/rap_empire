// Captures avant / après de la proposition « Néon de Bakoma » (docs/BRIEF.md §3) : QG, résultats de sortie, décision narrative.
// Usage : CAPTURE_DIR=<dossier> CAPTURE_W=390 CAPTURE_H=844 [CAPTURE_ONLY=qg,resultats] flutter test tool/capture_neon_test.dart
// Sans CAPTURE_DIR, ce test ne fait rien.
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
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/kore.dart';
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

Future<void> _tap(WidgetTester tester, String text) async {
  final f = find.byWidgetPredicate((w) => w is Text && w.data != null && w.data!.toLowerCase() == text.toLowerCase());
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester, GameState start, String location, {bool settle = true}) async {
  final w = double.parse(Platform.environment['CAPTURE_W'] ?? '390'), h = double.parse(Platform.environment['CAPTURE_H'] ?? '844');
  tester.view.physicalSize = Size(w, h);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [saveRepoProvider.overrideWithValue(FakeRepo(start))],
    child: RepaintBoundary(key: _boundary, child: MaterialApp.router(theme: buildGameTheme(), routerConfig: buildRouter(initialLocation: location), debugShowCheckedModeBanner: false)),
  ));
  if (settle) {
    await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  final dir = Platform.environment['CAPTURE_DIR']!;
  final w = Platform.environment['CAPTURE_W'] ?? '390';
  await tester.runAsync(() async {
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await Directory(dir).create(recursive: true);
    await File('$dir/$name-$w.png').writeAsBytes(bytes.buffer.asUint8List());
  });
}

final _rec = record(write(pick(const GameState(), 'gbaka')));

void main() {
  if (Platform.environment['CAPTURE_DIR'] == null) {
    test('captures ignorées (CAPTURE_DIR absent)', () {});
    return;
  }
  setUpAll(_loadFonts);

  final released = release(claim(_rec, 'm1'), 0);
  final acked = ack(released);
  final picked = pick(const GameState(), 'gbaka');
  final written = write(picked);

  final shots = <String, Future<void> Function(WidgetTester)>{
    'studio-vide': (t) => _open(t, const GameState(), '/studio'),
    'studio-son': (t) => _open(t, _rec.copyWith(cash: 22000), '/studio'),
    'instru': (t) => _open(t, const GameState(inst: 'gbaka'), '/studio/instru'),
    'achat': (t) async {
      await _open(t, const GameState(xp: 120, cash: 24054, day: 2), '/studio/instru');
      await _tap(t, 'Pont des Griots');
    },
    'ecriture': (t) => _open(t, picked, '/studio/ecriture'),
    'texte': (t) => _open(t, written, '/studio/ecriture'),
    'cabine': (t) => _open(t, written, '/studio/cabine'),
    'prises': (t) async {
      await _open(t, written, '/studio/prises', settle: false);
      await t.pump(const Duration(milliseconds: 600));
    },
    'mix': (t) => _open(t, _rec, '/studio/mix'),
    'qg': (t) => _open(t, const GameState(), '/'),
    'qg-mission-prete': (t) => _open(t, acked, '/'),
    'resultats': (t) => _open(t, released, '/studio/resultats'),
    'dialogue-ecoute-kore': (t) => _open(t, newGameState, '/dialogue/ecoute-kore'),
    'dialogue-offre-kore': (t) => _open(t, acked, '/dialogue/offre-kore'),
    'dialogue-contre-offre-kore': (t) => _open(t, acked, '/dialogue/contre-offre-kore'),
    'dialogue-accord-kore': (t) => _open(t, kdeal(acked, 'acc'), '/dialogue/accord-kore'),
    'dialogue-refus-kore': (t) => _open(t, kdeal(acked, 'ref'), '/dialogue/refus-kore'),
    'dialogue-retour-kore': (t) => _open(t, kdeal(acked, 'ref'), '/dialogue/retour-kore'),
  };
  final only = Platform.environment['CAPTURE_ONLY']?.split(',');

  for (final e in shots.entries) {
    if (only != null && !only.contains(e.key)) continue;
    testWidgets('capture ${e.key}', (tester) async {
      await e.value(tester);
      await _shot(tester, e.key);
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
