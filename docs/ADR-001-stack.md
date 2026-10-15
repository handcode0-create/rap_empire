# ADR-001 · Stack : Flutter (web + Android) + Supabase

Statut : **accepté par Smith le 15/10/2026** (levée de la réserve D-10 ; I-05 satisfait par la demande explicite de démarrage).
Réserves ouvertes : D-09 (sauvegarde), D-16 (départ classé ou non), D-01 (illustrations définitives).

## Décisions
| Sujet | Choix | Raison |
|---|---|---|
| UI | Flutter stable, cibles **Android** et **Web** | Une base de code, maquettes mobile-first 390×844 |
| État | Riverpod | Déjà dans la stack de Smith ; état immuable, testable |
| Navigation | go_router | Identifiants d'écran du prototype = noms de routes |
| Moteur de jeu | Dart **pur** (`lib/domain`), sans Flutter ni Supabase | Parité avec `engine.js`, tests, rejouable |
| Sauvegarde | Locale d'abord (shared_preferences), puis `public.saves` (jsonb versionné) | D-09 option 2 : hors ligne + synchronisation |
| Backend | Supabase : Auth, Postgres + RLS, catalogue en lecture seule | Stack maîtrisée, RLS par joueur |
| Conflit de sync (provisoire) | `updated_at` le plus récent gagne, ancienne copie gardée (slot `previous`) | À valider |

## Règles
1. Aucune règle de jeu dans les widgets : tout passe par `lib/domain`.
2. Les paramètres d'économie restent dans `econ.dart` (provisoires, D-08).
3. Le client n'embarque que la clé `anon` ; jamais `service_role`.
4. Palette et tokens uniques (`tokens.dart`). Pas de nouvel onglet de navigation.
5. Chaque port d'une action du prototype est accompagné d'un test de parité avec `engine.js`.

## Ordre de conversion (annexe G)
sauvegarde → QG + calendrier → studio/sorties → classements → scène → industrie → managers → avatar (après D-01).
