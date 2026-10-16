# RAP EMPIRE · port de la v21 en Flutter

Référence : `docs/RAP-EMPIRE-v21` (50 planches `21-*.dc.html`, moteur `sources/engine21.js`, tests `sources/test21.js`).

## Où est quoi

| Rôle | Fichier |
| --- | --- |
| Paramètres provisoires (REG, candidats, événements) | `lib/domain/v21/reg21.dart` |
| Moteur pur (actions, bilan, relations, famille, économie) | `lib/domain/v21/engine21.dart` |
| Valeurs d'affichage dérivées | `lib/domain/v21/view21.dart` |
| État, sauvegarde, messages d'erreur | `lib/app/game21.dart`, `lib/data/save21_repository.dart` |
| Routes | `lib/app/router21.dart` |
| Coque, HUD | `lib/features/v21/shell21.dart` |
| Démarrage et création de l'artiste (S0 à S5, Q0) | `lib/features/v21/start_screens.dart` |
| QG, journée, bilan, année, journal, événements (Q1 à Q4, J1, V1) | `lib/features/v21/qg_screens.dart` |
| Studio, featurings, sortie, résultats, clip (M1 à M5) | `lib/features/v21/music_screens.dart` |
| Scène, concert, popularité, business, patrimoine, merch, label (C1 à C3, E1 à E5, L1) | `lib/features/v21/scene_business_screens.dart` |
| Vie perso : rencontres, couple, mariage, séparation, famille (01 à 14) | `lib/features/v21/love_screens.dart` |
| Profil, rang, classements, réglages (P1, R1, R2, 00b) | `lib/features/v21/profile_screens.dart` |

## Principes

- Le moteur est un port fidèle : mêmes règles, mêmes codes d'erreur, mêmes valeurs. L'état est un JSON (comme dans le prototype) copié à chaque action.
- Les tests du prototype sont portés dans `test/v21_engine_test.dart` ; `test/v21_screens_test.dart` joue les parcours et balaie toutes les routes à 390 et 360 px.
- Les écrans ne contiennent aucune règle : ils appellent `Game21Notifier.act(nom, argument)`.
- L'avatar du joueur vient de `tools/design/export_assets.py` (fichiers `assets/characters/me_<coiffure>_<haut>_<teint>_<humeur>_<cadrage>.svg`).
- Ce que la v21 ne contient pas : choix de l'instru, cabine, mix et battle de la v20. Le code v20 (`lib/domain/*.dart` hors `v21/`, `lib/features/*` hors `v21/`, `lib/app/router.dart`, `lib/app/providers.dart`) reste dans le dépôt, non branché, avec ses tests.
