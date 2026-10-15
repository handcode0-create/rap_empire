import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router.dart';
import 'core/config/env.dart';
import 'core/theme/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // anonKey volontairement conservé (clé anon, cf. env.example.json) ; migration vers publishableKey à décider.
  // ignore: deprecated_member_use
  if (Env.hasSupabase) await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  runApp(const ProviderScope(child: RapEmpireApp()));
}

class RapEmpireApp extends StatelessWidget {
  const RapEmpireApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(title: 'RAP EMPIRE', theme: buildTheme(), routerConfig: router, debugShowCheckedModeBanner: false);
}
