import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Charge les polices embarquées (Poppins, Baloo 2) avant tous les tests : les tests de widgets reproduisent ainsi la mise en page réelle
/// d'un téléphone au lieu de la police de remplacement, bien plus large.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
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
  await testMain();
}
