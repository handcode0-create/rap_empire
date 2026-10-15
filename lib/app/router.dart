import 'package:go_router/go_router.dart';
import '../features/business/business_screen.dart';
import '../features/business/formation_screen.dart';
import '../features/end_of_day/end_of_day_screen.dart';
import '../features/home/home_screen.dart';
import '../features/missions/level_up_screen.dart';
import '../features/missions/mission_done_screen.dart';
import '../features/missions/missions_screen.dart';
import '../features/missions/new_mission_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/soon/soon_screen.dart';
import '../features/studio/cabine_screen.dart';
import '../features/studio/chargement_screen.dart';
import '../features/studio/ecriture_screen.dart';
import '../features/studio/instru_screen.dart';
import '../features/studio/mix_screen.dart';
import '../features/studio/prises_screen.dart';
import '../features/studio/resultats_screen.dart';
import '../features/studio/sortie_screen.dart';
import '../features/studio/studio_home_screen.dart';

/// Les identifiants d'écran du prototype (ex. 03-1-QG) deviennent des routes. Cinq onglets : QG, Studio, Scène, Business, Profil (I-07).
/// Scène et Profil affichent « Bientôt » jusqu'à leur port. La barre de navigation n'apparaît que sur les écrans racines
/// (la liste des missions 10.1 et la formation 09.3 en font partie, comme dans les planches).
const _rootPaths = {'/', '/missions', '/studio', '/scene', '/business', '/business/formation', '/profil'};

GoRouter buildRouter({String initialLocation = '/'}) => GoRouter(initialLocation: initialLocation, routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, state, shell) => AppShell(shell: shell, showNav: _rootPaths.contains(state.matchedLocation)),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', name: '03-1-QG', builder: (_, __) => const HomeScreen(), routes: [
              GoRoute(path: 'missions', name: '10-1-Missions', builder: (_, __) => const MissionsScreen()),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/studio', name: '04-1-Studio', builder: (_, __) => const StudioHomeScreen(), routes: [
              GoRoute(path: 'instru', name: '04-3-Instru', builder: (_, __) => const InstruScreen()),
              GoRoute(path: 'ecriture', name: '04-5-Ecriture', builder: (_, __) => const EcritureScreen()),
              GoRoute(path: 'cabine', name: '04-7-Cabine', builder: (_, __) => const CabineScreen()),
              GoRoute(path: 'prises', name: '04-8-Minijeu', builder: (_, __) => const PrisesScreen()),
              GoRoute(path: 'mix', name: '04-9-Mix', builder: (_, __) => const MixScreen()),
              GoRoute(path: 'sortie', name: '05-1-Sortie', builder: (_, __) => const SortieScreen()),
              GoRoute(path: 'chargement', name: '05-3-Chargement', builder: (_, __) => const ChargementScreen()),
              GoRoute(path: 'resultats', name: '05-4-Resultats', builder: (_, __) => const ResultatsScreen()),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/scene', name: 'scene', builder: (_, __) => const SoonScreen(title: 'Scène'))]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/business', name: '09-1-Matos', builder: (_, __) => const BusinessScreen(), routes: [
              GoRoute(path: 'formation', name: '09-3-Formation', builder: (_, __) => const FormationScreen()),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/profil', name: 'profil', builder: (_, __) => const SoonScreen(title: 'Profil'))]),
        ],
      ),
      GoRoute(path: '/niveau', name: '10-4-Level-up', builder: (_, __) => const LevelUpScreen()),
      GoRoute(path: '/mission-accomplie', name: '10-2-Mission-accomplie', builder: (_, __) => const MissionDoneScreen()),
      GoRoute(path: '/nouvelle-mission', name: '10-3-Nouvelle-mission', builder: (_, __) => const NewMissionScreen()),
      GoRoute(path: '/fin-journee', name: '03-6-Fin-journee', builder: (_, __) => const EndOfDayScreen()),
    ]);

final router = buildRouter();
