import 'package:go_router/go_router.dart';
import '../features/end_of_day/end_of_day_screen.dart';
import '../features/home/home_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/soon/soon_screen.dart';
import '../features/studio/cabine_screen.dart';
import '../features/studio/ecriture_screen.dart';
import '../features/studio/instru_screen.dart';
import '../features/studio/mix_screen.dart';
import '../features/studio/resultats_screen.dart';
import '../features/studio/sortie_screen.dart';
import '../features/studio/studio_home_screen.dart';

/// Les identifiants d'écran du prototype (ex. 03-1-QG) deviennent des routes. Cinq onglets : QG, Studio, Scène, Business, Profil (I-07).
/// Seul le QG est réel ; les autres onglets affichent « Bientôt » jusqu'à leur port.
GoRouter buildRouter({String initialLocation = '/'}) => GoRouter(initialLocation: initialLocation, routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', name: '03-1-QG', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/studio', name: '04-1-Studio', builder: (_, __) => const StudioHomeScreen(), routes: [
              GoRoute(path: 'instru', name: '04-3-Instru', builder: (_, __) => const InstruScreen()),
              GoRoute(path: 'ecriture', name: '04-5-Ecriture', builder: (_, __) => const EcritureScreen()),
              GoRoute(path: 'cabine', name: '04-7-Cabine', builder: (_, __) => const CabineScreen()),
              GoRoute(path: 'mix', name: '04-9-Mix', builder: (_, __) => const MixScreen()),
              GoRoute(path: 'sortie', name: '05-1-Sortie', builder: (_, __) => const SortieScreen()),
              GoRoute(path: 'resultats', name: '05-4-Resultats', builder: (_, __) => const ResultatsScreen()),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/scene', name: 'scene', builder: (_, __) => const SoonScreen(title: 'Scène'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/business', name: 'business', builder: (_, __) => const SoonScreen(title: 'Business'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/profil', name: 'profil', builder: (_, __) => const SoonScreen(title: 'Profil'))]),
        ],
      ),
      GoRoute(path: '/fin-journee', name: '03-6-Fin-journee', builder: (_, __) => const EndOfDayScreen()),
    ]);

final router = buildRouter();
