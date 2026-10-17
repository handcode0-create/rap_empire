// Captures à 390 x 844 des écrans v21, avec les vraies polices (Poppins, Baloo 2), à comparer aux planches de docs/design-ref/v21.
// Usage : CAPTURE_DIR=<dossier> [ONLY=21-M6] flutter test tool/capture21_test.dart   (sans CAPTURE_DIR, ce test ne fait rien)
// Les PNG portent le nom de la planche (ex. 21-M6-Instru.png) ; tool/compare21.js les place à côté des planches.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/app/game21.dart';
import 'package:rap_empire/app/router21.dart';
import 'package:rap_empire/core/theme/app_theme.dart';
import 'package:rap_empire/data/save21_repository.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

final _boundary = GlobalKey();

class _Repo extends Save21Repository {
  J current;
  _Repo(this.current);
  @override
  Future<J> load() async => current;
  @override
  Future<void> save(J s) async => current = s;
}

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

/// Une suite d'actions du moteur à partir d'un préréglage : l'état exact montré par la planche.
J st(String preset, [List<(String, dynamic)> steps = const [], void Function(J)? patch]) {
  var s = act21(init21(), 'preset', preset).s;
  for (final (a, g) in steps) {
    final r = act21(s, a, g);
    if (r.err != null) throw StateError('$a $g → ${r.err}');
    s = r.s;
  }
  patch?.call(s);
  return s;
}

class Shot {
  final String board, location;
  final J state;
  final bool animated; // écran animé en continu : pas de pumpAndSettle
  final Future<void> Function(WidgetTester)? after;
  Shot(this.board, this.location, this.state, {this.animated = false, this.after});
}


List<Shot> shots() => [
      // Studio
      Shot('21-M1-Creation', '/studio', st('debut', const [], (s) {
        s['ev'] = null;
      })),
      Shot('21-M6-Instru', '/studio/instru', st('debut', const [('create', ['quartier', 'sombre'])])),
      Shot('21-M7-Cabine', '/studio/cabine', st('debut', const [('create', ['quartier', 'sombre'])]), animated: true),
      Shot('21-M8-Mix', '/studio/mix', st('debut', const [('create', ['ambition', 'fiere']), ('feat', 'nadia'), ('record', [74, 48, 43])])),
      // Catalogue
      Shot('21-A0-Catalogue', '/studio/catalogue', st('star')),
      Shot('21-A0b-Titre', '/studio/catalogue/titre', st('star', const [('ctki', 0)])),
      Shot('21-A1-Projet', '/studio/catalogue/projet', st('star')),
      Shot('21-A1-Projet+choix', '/studio/catalogue/projet', _picked()),
      Shot('21-A2-Projet-sorti', '/studio/catalogue/projet-sorti', st('star')),
      Shot('21-A2-Projet-sorti+EP', '/studio/catalogue/projet-sorti', _epState()),
    ];

List<J> _extraSongs() => [
      for (var i = 0; i < 3; i++)
        {'id': 'X$i', 'title': 'Titre ${i + 3}', 'theme': 'quartier', 'amb': 'sombre', 'mode': 'manuel', 'tx': 72, 'st': 'sorti', 'Q': 60 + i, 'feats': <dynamic>[], 'clip': {'st': 'aucun'}, 'L': 20000 + i * 9000, 'rev': 0, 'fg': 0, 'pg': 0, 'tier': 'Correct', 'promo': 0, 'vir': 30, 'day': 10 + i},
    ];

J _picked() {
  var s = st('star');
  s['disco'] = [...(s['disco'] as List), ..._extraSongs()];
  s = act21(s, 'ptki', 0).s;
  return act21(s, 'ptki', 2).s;
}

J _epState() {
  var s = st('star');
  s['disco'] = [...(s['disco'] as List), ..._extraSongs()];
  for (var i = 0; i < 3; i++) {
    s = act21(s, 'ptki', i).s;
  }
  return act21(s, 'prel').s;
}

void main() {
  final dir = Platform.environment['CAPTURE_DIR'];
  if (dir == null) {
    test('captures ignorées (CAPTURE_DIR absent)', () {});
    return;
  }
  setUpAll(_loadFonts);
  final only = Platform.environment['ONLY'];
  for (final sh in shots().where((s) => only == null || s.board.startsWith(only))) {
    testWidgets('capture ${sh.board}', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = _Repo(sh.state);
      await tester.pumpWidget(ProviderScope(
        overrides: [save21RepoProvider.overrideWithValue(repo)],
        child: RepaintBoundary(
            key: _boundary,
            child: MaterialApp.router(theme: buildGameTheme(), routerConfig: buildRouter21(initialLocation: sh.location), debugShowCheckedModeBanner: false)),
      ));
      if (sh.animated) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      } else {
        await tester.pumpAndSettle();
      }
      await sh.after?.call(tester);
      await tester.runAsync(() async {
        final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        await Directory(dir).create(recursive: true);
        await File('$dir/${sh.board}.png').writeAsBytes(bytes.buffer.asUint8List());
      });
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
