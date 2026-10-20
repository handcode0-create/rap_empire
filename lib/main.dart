import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router21.dart';
import 'core/config/env.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('RE_BOOT main');
    // En release, une erreur de construction d'écran s'affiche en clair au lieu d'un bloc vide.
    ErrorWidget.builder = (d) => Material(
          color: const Color(0xFF14102B),
          child: SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur : ${d.exceptionAsString()}\n\n${d.stack}', style: const TextStyle(color: Color(0xFFFFD5EC), fontSize: 12)))),
        );
    FlutterError.onError = (d) {
      FlutterError.presentError(d);
      debugPrint('FLUTTER_ERROR ${d.exceptionAsString()}\n${d.stack}');
    };
    PlatformDispatcher.instance.onError = (e, st) {
      debugPrint('ZONE_ERROR $e\n$st');
      return true;
    };
    // anonKey volontairement conservé (clé anon, cf. env.example.json) ; migration vers publishableKey à décider.
    // ignore: deprecated_member_use
    if (Env.hasSupabase) await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
    debugPrint('RE_BOOT runApp');
    runApp(const ProviderScope(child: RapEmpireApp()));
  }, (e, st) => debugPrint('ZONE_ERROR $e\n$st'));
}

final _router = buildRouter21(initialLocation: '/demarrer');

class RapEmpireApp extends StatelessWidget {
  const RapEmpireApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(title: 'RAP EMPIRE', theme: buildGameTheme(), routerConfig: _router, debugShowCheckedModeBanner: false);
}
