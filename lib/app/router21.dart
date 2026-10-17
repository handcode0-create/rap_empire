import 'package:go_router/go_router.dart';
import '../features/v21/catalogue_screens.dart';
import '../features/v21/characters_screen.dart';
import '../features/v21/dialogue_screens.dart';
import '../features/v21/justice_screens.dart';
import '../features/v21/labels_screens.dart';
import '../features/v21/love_screens.dart';
import '../features/v21/music_screens.dart';
import '../features/v21/platform_screens.dart';
import '../features/v21/profile_screens.dart';
import '../features/v21/qg_screens.dart';
import '../features/v21/scene_business_screens.dart';
import '../features/v21/shell21.dart';
import '../features/v21/studio_screens.dart';
import '../features/v21/start_screens.dart';

/// Routes de la v21 (planches 21-*). Cinq onglets : QG, Studio, Scène, Business, Profil. La barre de navigation n'apparaît
/// que sur les écrans racines. Les écrans de vie perso, de journée et de bilan ont le HUD sans navigation (Frame21).
// Écrans qui gardent la barre de navigation : les cinq onglets et le catalogue (21-A0, sans bouton retour).
const _rootPaths = {'/', '/studio', '/scene', '/business', '/profil', '/studio/catalogue'};

/// Routes qui n'ont besoin ni de HUD ni de navigation : démarrage et création de l'artiste.
const startPaths = [
  '/demarrer',
  '/nouvelle-partie',
  '/univers',
  '/artiste/identite',
  '/artiste/look',
  '/artiste/style',
  '/artiste/objectif',
  '/demo'
];

GoRouter buildRouter21({String initialLocation = '/'}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
            path: '/demarrer',
            name: '21-S0-Splash',
            builder: (_, __) => const SplashScreen()),
        GoRoute(
            path: '/nouvelle-partie',
            name: '21-S0b-Nouvelle-partie',
            builder: (_, __) => const NewGameScreen()),
        GoRoute(
            path: '/univers',
            name: '21-S1-Univers',
            builder: (_, __) => const UniversScreen()),
        GoRoute(
            path: '/artiste/identite',
            name: '21-S2-Identite',
            builder: (_, __) => const IdentiteScreen()),
        GoRoute(
            path: '/artiste/look',
            name: '21-S3-Look',
            builder: (_, __) => const LookScreen()),
        GoRoute(
            path: '/artiste/style',
            name: '21-S4-Style',
            builder: (_, __) => const StyleScreen()),
        GoRoute(
            path: '/artiste/objectif',
            name: '21-S5-Objectif',
            builder: (_, __) => const ObjectifScreen()),
        GoRoute(
            path: '/demo',
            name: '21-Q0-Demarrer',
            builder: (_, __) => const DemoScreen()),
        StatefulShellRoute.indexedStack(
          builder: (_, state, shell) => Shell21(
              shell: shell,
              showNav: _rootPaths.contains(state.matchedLocation)),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/',
                  name: '21-Q1-QG',
                  builder: (_, __) => const QgScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/studio',
                  name: '21-M1-Creation',
                  builder: (_, __) => const StudioScreen(),
                  routes: [
                    GoRoute(
                        path: 'instru',
                        name: '04-3-Instru-v21',
                        builder: (_, __) => const Instru21Screen()),
                    GoRoute(
                        path: 'cabine',
                        name: '04-7-Cabine-v21',
                        builder: (_, __) => const Cabine21Screen()),
                    GoRoute(
                        path: 'mix',
                        name: '04-9-Mix-v21',
                        builder: (_, __) => const Mix21Screen()),
                    GoRoute(
                        path: 'catalogue',
                        name: '21-A0-Catalogue',
                        builder: (_, __) => const CatalogueScreen(),
                        routes: [
                          GoRoute(path: 'titre', name: '21-A0b-Titre', builder: (_, __) => const TitreScreen()),
                          GoRoute(path: 'projet', name: '21-A1-Projet', builder: (_, __) => const ProjetScreen()),
                          GoRoute(
                              path: 'projet-sorti',
                              name: '21-A2-Projet-sorti',
                              builder: (_, state) => ProjetSortiScreen(index: int.tryParse(state.uri.queryParameters['i'] ?? '') ?? 0)),
                        ]),
                    GoRoute(
                        path: 'feats',
                        name: '21-M2-Featurings',
                        builder: (_, __) => const FeatsScreen()),
                    GoRoute(
                        path: 'sortie',
                        name: '21-M3-Sortie',
                        builder: (_, __) => const SortieScreen()),
                    GoRoute(
                        path: 'resultats',
                        name: '21-M3b-Resultats',
                        builder: (_, __) => const ResultatsScreen()),
                    GoRoute(
                        path: 'clip',
                        name: '21-M4-Clip',
                        builder: (_, __) => const ClipScreen()),
                    GoRoute(
                        path: 'clip-publie',
                        name: '21-M5-Clip-publie',
                        builder: (_, __) => const ClipPubScreen()),
                  ]),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/scene',
                  name: '21-C2-Scene',
                  builder: (_, __) => const SceneScreen21(),
                  routes: [
                    GoRoute(
                        path: 'battle',
                        name: '06-3-Battle-v21',
                        builder: (_, __) => const Battle21Screen()),
                    GoRoute(
                        path: 'rivalites',
                        name: '06-3-Rivalites-v21',
                        builder: (_, __) => const Rivalites21Screen()),
                    GoRoute(
                        path: 'rival-battle/:target',
                        name: '06-3-Battle-rival-v21',
                        builder: (_, state) => Battle21Screen(target: state.pathParameters['target']!)),
                    GoRoute(
                        path: 'battle-result',
                        name: '06-4-Battle-resultat-v21',
                        builder: (_, __) => const BattleResult21Screen()),
                    GoRoute(
                        path: 'resultat',
                        name: '21-C3-Concert',
                        builder: (_, __) => const ConcertResultScreen()),
                    GoRoute(
                        path: 'popularite',
                        name: '21-C1-Popularite',
                        builder: (_, __) => const PopulariteScreen()),
                  ]),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/business',
                  name: '21-E1-Business',
                  builder: (_, __) => const BusinessScreen21(),
                  routes: [
                    GoRoute(
                        path: 'boulot',
                        name: '21-E2-Boulot',
                        builder: (_, __) => const BoulotScreen()),
                    GoRoute(
                        path: 'entreprises',
                        name: '21-E3-Entreprises',
                        builder: (_, __) => const EntreprisesScreen()),
                    GoRoute(
                        path: 'patrimoine',
                        name: '21-E4-Patrimoine',
                        builder: (_, __) => const PatrimoineScreen()),
                    GoRoute(
                        path: 'achat',
                        name: '21-E5-Achat-bien',
                        builder: (_, __) => const AchatScreen()),
                    GoRoute(
                        path: 'labels',
                        name: '21-L1-Labels-merch',
                        builder: (_, __) => const LabelsScreen(),
                        routes: [GoRoute(path: 'tous', name: '21-L2-Labels', builder: (_, __) => const LabelsAllScreen())]),
                    GoRoute(
                        path: 'manager',
                        name: '20-Manager',
                        builder: (_, __) => const Manager21Screen()),
                    GoRoute(
                        path: 'justice',
                        name: '21-E6-Justice',
                        builder: (_, __) => const Justice21Screen(),
                        routes: [
                          GoRoute(path: 'garde', name: '21-Z2-Garde-a-vue', builder: (_, __) => const GardeScreen()),
                          GoRoute(path: 'avocat', name: '21-Z3-Avocat', builder: (_, __) => const AvocatScreen()),
                          GoRoute(path: 'tribunal', name: '21-Z4-Tribunal', builder: (_, __) => const TribunalScreen()),
                          GoRoute(path: 'prison', name: '21-Z5-Prison', builder: (_, __) => const PrisonScreen()),
                        ]),
                  ]),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/profil',
                  name: '21-P1-Profil',
                  builder: (_, __) => const ProfilScreen21(),
                  routes: [
                    GoRoute(
                        path: 'rang',
                        name: '21-R1-Rang',
                        builder: (_, __) => const RangScreen()),
                    GoRoute(
                        path: 'classements',
                        name: '21-R2-Classements',
                        builder: (_, __) => const ClassementsScreen()),
                    GoRoute(path: 'personnages', name: '21-K1-Personnages', builder: (_, __) => const PersonnagesScreen()),
                    GoRoute(
                        path: 'plateformes',
                        name: '21-D1-Plateformes',
                        builder: (_, __) => const PlateformesScreen(),
                        routes: [
                          GoRoute(path: 'ondea', name: '21-D2-Ondea', builder: (_, __) => const OndeaScreen()),
                          GoRoute(path: 'klipo', name: '21-D3-Klipo', builder: (_, __) => const KlipoScreen()),
                          GoRoute(path: 'cauri', name: '21-D4-Cauri-Music', builder: (_, __) => const CauriMusicScreen()),
                        ]),
                    GoRoute(
                        path: 'annee',
                        name: '21-Q4-Annee',
                        builder: (_, __) => const AnneeScreen()),
                    GoRoute(
                        path: 'reglages',
                        name: '21-00b-Reglages',
                        builder: (_, __) => const ReglagesScreen()),
                  ]),
            ]),
          ],
        ),
        GoRoute(
            path: '/journee',
            name: '21-Q2-Journee',
            builder: (_, __) => const JourneeScreen()),
        GoRoute(
            path: '/bilan',
            name: '21-Q3-Bilan',
            builder: (_, __) => const BilanScreen()),
        GoRoute(
            path: '/journal',
            name: '21-J1-Journal',
            builder: (_, __) => const JournalScreen()),
        GoRoute(
            path: '/dialogue',
            name: '21-X1-Dialogue',
            builder: (_, __) => const DialogueScreen()),
        GoRoute(
            path: '/scenes',
            name: '21-X0-Scenes',
            builder: (_, __) => const ScenesScreen()),
        GoRoute(
            path: '/evenement',
            name: '21-V1-Evenement',
            builder: (_, __) => const EvenementScreen()),
        GoRoute(
            path: '/perso',
            name: '21-01-Candidats',
            builder: (_, __) => const RencontresScreen(),
            routes: [
              GoRoute(
                  path: 'profil',
                  name: '21-02-Profil',
                  builder: (_, __) => const CandProfilScreen()),
              GoRoute(
                  path: 'interactions',
                  name: '21-03-Interactions',
                  builder: (_, __) => const InteractionsScreen()),
              GoRoute(
                  path: 'relation',
                  name: '21-04-Relation',
                  builder: (_, __) => const RelationScreen()),
              GoRoute(
                  path: 'officialiser',
                  name: '21-05-Officialisation',
                  builder: (_, __) => const OfficialScreen()),
              GoRoute(
                  path: 'couple',
                  name: '21-06-Couple',
                  builder: (_, __) => const CoupleScreen()),
              GoRoute(
                  path: 'demande',
                  name: '21-07-Demande',
                  builder: (_, __) => const DemandeScreen()),
              GoRoute(
                  path: 'mariage',
                  name: '21-08-Preparation',
                  builder: (_, __) => const PreparationScreen()),
              GoRoute(
                  path: 'confirmation',
                  name: '21-09-Confirmation',
                  builder: (_, __) => const ConfirmationMariageScreen()),
              GoRoute(
                  path: 'separation',
                  name: '21-10-Separation',
                  builder: (_, __) => const SeparationScreen()),
            ]),
        GoRoute(
            path: '/famille',
            name: '21-11-Enfant',
            builder: (_, __) => const FamilleScreen(),
            routes: [
              GoRoute(
                  path: 'enfant',
                  name: '21-12-Parent-enfant',
                  builder: (_, __) => const ParentEnfantScreen()),
              GoRoute(
                  path: 'evenement',
                  name: '21-13-Evenements',
                  builder: (_, __) => const FamEvenementScreen()),
              GoRoute(
                  path: 'bilan',
                  name: '21-14-Bilan-familial',
                  builder: (_, __) => const BilanFamilialScreen()),
            ]),
      ],
    );
