import 'package:go_router/go_router.dart';
import '../features/business/business_screen.dart';
import '../features/business/finances_screen.dart';
import '../features/business/formation_screen.dart';
import '../features/dialogue/kore_screens.dart';
import '../features/end_of_day/end_of_day_screen.dart';
import '../features/home/home_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/wardrobe_screen.dart';
import '../features/missions/level_up_screen.dart';
import '../features/missions/mission_done_screen.dart';
import '../features/missions/missions_screen.dart';
import '../features/missions/new_mission_screen.dart';
import '../features/scene/scene_screens.dart';
import '../features/shell/app_shell.dart';
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
/// La barre de navigation n'apparaît que sur les écrans racines
/// (la liste des missions 10.1 et la formation 09.3 en font partie, comme dans les planches).
const _rootPaths = {'/', '/missions', '/studio', '/scene', '/business', '/business/formation', '/business/finances', '/profil'};

/// Décors de la direction Néon de Bakoma, un lieu par écran migré (QG : toit de Ndolo la nuit ; Studio : cabine de DJ Kôrô ; résultats : coulisses).
/// Les écrans pas encore migrés gardent le fond v20.
const _scenes = {
  '/': 'qg_sky',
  '/studio': 'studio',
  '/studio/instru': 'studio',
  '/studio/ecriture': 'studio',
  '/studio/cabine': 'studio',
  '/studio/prises': 'studio',
  '/studio/mix': 'studio',
  '/studio/resultats': 'backstage',
  '/scene': 'stage',
};

GoRouter buildRouter({String initialLocation = '/'}) => GoRouter(initialLocation: initialLocation, routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, state, shell) => AppShell(shell: shell, showNav: _rootPaths.contains(state.matchedLocation), scene: _scenes[state.matchedLocation]),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', name: '03-1-QG', builder: (_, __) => const HomeScreen(), routes: [
              GoRoute(path: 'missions', name: '10-1-Missions', builder: (_, __) => const MissionsScreen()),
              GoRoute(path: 'journal', name: '03-3-Journal', builder: (_, __) => const JournalScreen()),
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
          StatefulShellBranch(routes: [
            GoRoute(path: '/scene', name: '06-1-Scene', builder: (_, __) => const SceneScreen(), routes: [
              GoRoute(path: 'openmic', name: '06-2-OpenMic', builder: (_, __) => const OpenMicScreen()),
              GoRoute(path: 'battle', name: '06-3-Battle', builder: (_, __) => const BattleScreen()),
              GoRoute(path: 'concert', name: '07-2-Concert', builder: (_, __) => const ConcertScreen()),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/business', name: '09-1-Matos', builder: (_, __) => const BusinessScreen(), routes: [
              GoRoute(path: 'formation', name: '09-3-Formation', builder: (_, __) => const FormationScreen()),
              GoRoute(path: 'finances', name: '09-5-Finances', builder: (_, __) => const FinancesScreen()),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profil', name: '03-4-Profil', builder: (_, __) => const ProfileScreen(), routes: [
              GoRoute(path: 'tenues', name: '03-4-Tenues', builder: (_, __) => const WardrobeScreen()),
            ]),
          ]),
        ],
      ),
      GoRoute(path: '/scene-resultat', name: '06-4-Resultat-scene', builder: (_, __) => const SceneResultScreen()),
      GoRoute(path: '/niveau', name: '10-4-Level-up', builder: (_, __) => const LevelUpScreen()),
      GoRoute(path: '/mission-accomplie', name: '10-2-Mission-accomplie', builder: (_, __) => const MissionDoneScreen()),
      GoRoute(path: '/nouvelle-mission', name: '10-3-Nouvelle-mission', builder: (_, __) => const NewMissionScreen()),
      GoRoute(path: '/dialogue/ecoute-kore', name: '16-A1-Producteur-ecoute', builder: (_, __) => const EcouteKoreScreen()),
      GoRoute(path: '/dialogue/offre-kore', name: '16-A2-Producteur-offre', builder: (_, __) => const OffreKoreScreen()),
      GoRoute(path: '/dialogue/contre-offre-kore', name: '16-A3-Producteur-negocie', builder: (_, __) => const ContreOffreKoreScreen()),
      GoRoute(path: '/dialogue/accord-kore', name: '16-A4-Producteur-accord', builder: (_, __) => const AccordKoreScreen()),
      GoRoute(path: '/dialogue/refus-kore', name: '16-A5-Producteur-refus', builder: (_, __) => const RefusKoreScreen()),
      GoRoute(path: '/dialogue/retour-kore', name: '16-A6-Producteur-retour', builder: (_, __) => const RetourKoreScreen()),
      GoRoute(path: '/fin-journee', name: '03-6-Fin-journee', builder: (_, __) => const EndOfDayScreen()),
    ]);

final router = buildRouter();
