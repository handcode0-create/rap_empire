import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router21.dart';
import 'features/v21/day_clock21.dart';
import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/svg_precache.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
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
    runApp(const ProviderScope(child: RapEmpireApp()));
    // Pochettes et miniatures de Klipo, Ondéa et Cauri Music : préchargées pour éviter les cases vides.
    unawaited(precacheSvgs([
      for (var i = 1; i <= 8; i++) 'assets/klipo/mine/M$i.svg',
      for (var i = 1; i <= 50; i++) 'assets/klipo/thumbs/T${i.toString().padLeft(3, '0')}.svg',
      for (var i = 1; i <= 8; i++) ...['assets/covers/al_$i.svg', 'assets/covers/ep_$i.svg'],
    ]));
  }, (e, st) => debugPrint('ZONE_ERROR $e\n$st'));
}

final _router = buildRouter21(initialLocation: '/demarrer');

class RapEmpireApp extends StatelessWidget {
  const RapEmpireApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
      title: 'RAP EMPIRE',
      theme: buildGameTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => DayClock21(router: _router, child: child ?? const SizedBox()));
}
