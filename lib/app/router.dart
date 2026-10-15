import 'package:go_router/go_router.dart';
import '../features/end_of_day/end_of_day_screen.dart';
import '../features/home/home_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/soon/soon_screen.dart';

/// Les identifiants d'écran du prototype (ex. 03-1-QG) deviennent des routes. Cinq onglets : QG, Studio, Scène, Business, Profil (I-07).
/// Seul le QG est réel ; les autres onglets affichent « Bientôt » jusqu'à leur port.
GoRouter buildRouter() => GoRouter(routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', name: '03-1-QG', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/studio', name: 'studio', builder: (_, __) => const SoonScreen(title: 'Studio'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/scene', name: 'scene', builder: (_, __) => const SoonScreen(title: 'Scène'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/business', name: 'business', builder: (_, __) => const SoonScreen(title: 'Business'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/profil', name: 'profil', builder: (_, __) => const SoonScreen(title: 'Profil'))]),
        ],
      ),
      GoRoute(path: '/fin-journee', name: '03-6-Fin-journee', builder: (_, __) => const EndOfDayScreen()),
    ]);

final router = buildRouter();
