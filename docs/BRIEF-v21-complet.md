# BRIEF · Mise à jour de l'application à partir de RAP-EMPIRE-v21.zip

Lis ce fichier en entier avant d'agir. Applique les règles de CLAUDE.md : skills chargés, ligne « Skills appliqués » en tête de chaque réponse, rien de cassé dans ce qui fonctionne déjà. Ce brief remplace BRIEF-v21-suite.md (tout ce qu'il contenait est repris ici).

## Règle prioritaire de consolidation différentielle

Le dépôt a déjà évolué depuis la rédaction initiale de ce brief. **Ne traite pas les listes « à créer » ci-dessous comme une preuve d'absence.** Avant toute modification, inspecte le routeur, les écrans, le moteur Dart, `docs/design-ref/v21/sources/engine21.js`, les tests et l'historique Git. Pour chaque exigence, classe-la `[EXISTANT]`, `[INCOMPLET]`, `[ABSENT]` ou `[À VALIDER]`. Ne développe que `[INCOMPLET]` ou `[ABSENT]`; ajoute un test de non-régression. Ne répète pas les fonctionnalités déjà implémentées.

Les décisions de conception validées par le propriétaire restent validées même si un commentaire de code ancien indique encore « proposé ». Distingue toujours la décision de conception de la validation technique des ressources ou paramètres. En particulier, l'architecture de garde-robe à tenues complètes avec variantes jeune/mature est validée ; les illustrations de test ne sont pas finales et les seuils numériques non validés restent provisoires.

## 0 · Préparation

1. S'il n'y a pas encore de dépôt git : `git init`, `.gitignore` Flutter standard (build/, .dart_tool/, .env, toute clé), puis un commit « avant mise à jour v21 complète ». Sinon, un commit de l'état actuel. Ne pousse rien en ligne.
2. Décompresse `RAP-EMPIRE-v21.zip` dans `docs/design-ref/v21/` (remplace la version précédente s'il y en a une). Tu obtiens :
   - `21-*.dc.html` : les planches HTML v21 présentes dans l'archive (inventaire observé dans le dépôt au 20-10-2026 : 76 fichiers HTML distincts ; l'index contient 78 liens, doublons inclus ; recalculer ce nombre après toute mise à jour) ; ouvre `index.html` pour les parcourir ;
   - `sources/engine21.js` : **la référence de toutes les règles** (moteur pur : `act(état, action, argument)` et `view(état)`) ;
   - `sources/test21.js` : les tests du moteur (`node test21.js` depuis `sources/`) ;
   - `sources/binder21.js` : la liaison des écrans du prototype (mini-jeu de cabine, battle) ;
   - `rap.css`, `v20.css`, `v21.css` : les styles de référence.
3. Lance `node docs/design-ref/v21/sources/test21.js` : tout doit être « ok ». C'est le comportement attendu.

## 1 · Règles à porter dans le moteur Dart (lib/domain)

Porte chaque bloc depuis `engine21.js` avec un **test de parité** (même état de départ, mêmes actions, même résultat que le moteur JS), comme pour le studio. Ne réécris pas ce qui est déjà conforme.

| Domaine | Ce qui a changé ou est nouveau | Où dans engine21.js |
| --- | --- | --- |
| Rangs | N3 1 500 XP · N4 3 200 · N5 6 000 · N6 12 000 (N2 reste 100) | `REG.ranks` |
| Missions | Mission 3 = « Fais un atelier d'écriture » ; action atelier : 2 h, −20 énergie, −6 000, Écriture +5 | `REG.missions`, `A.atelier` |
| Création | Pays d'origine au choix (validé) ; carrière toujours à Ndolo | `A.setp`, `A.finish` |
| Studio | Instru payée une fois (`A.pick`, Pont des Griots N2, Lagune d'Ambre réputation 30) ; cabine à 3 prises (`A.record(prises)`) ; qualité = 0,35 texte + 0,30 voix + 0,35 production − fatigue + featurings ; crédits enregistrés (`prodBy`, `labelAt`, `auteur`) | `REG.instrus`, `A.pick`, `A.record`, `A.release` |
| Sortie | Ventes des singles = 1,2 % des streams × 30 cauris, ajoutées aux revenus, part du label déduite ; popularité gagnée plafonnée à 12 et ralentie près de 100 | `A.release` |
| EP et album | `A.ptype`, `A.ptk`, `A.prel` : EP 3 à 7 singles (15 000), album 8 et plus (40 000) ; ventes, rang Top 50 EPs / Top 200 Albums | `REG.proj`, `A.prel` |
| Scène | Open mic une fois par jour, gains décroissants si répété ; concert à la billetterie, 1 par 7 jours ; tournée selon le public régional, 1 par 28 jours | `A.openmic`, `A.concert`, `A.tour` |
| Battle | Défi de K-Zer → battle en 3 rounds (`A.battle(rounds gagnés)`), victoire à 2 : +150 fans, +6 réputation, +3 000 | `A.evc` (kzer), `A.battle` |
| Dialogues | 10 scènes et 9 offres de label en dialogue, déclenchées par la carrière, mémoire des relations | `DLG`, `DLG_ORDER`, `triggers`, `A.dch`, `A.dclose` |
| Labels | 10 labels, chacun son directeur, ses conditions, sa contre-offre et son avantage ; un seul contrat à la fois ; part selon le contrat signé | `LBL`, `PERK`, `lblDlg` |
| Manager | Maya Tessé : 8 % de chaque cachet une fois engagée | `cachet`, `DLG.mgr` |
| Plateformes | Ondéa 70 % des écoutes, Cauri Music 30 %, Klipo = vues des clips (aucun revenu en plus) | `REG.platforms` |
| Justice | Contenu mature **désactivé par défaut** (`A.mature`) ; activités illégales, chaleur, arrestation, caution ou détention, avocat, procès, prison, casier ; un label rompt le contrat en cas de prison | `REG.crimes`, `A.crime`, `A.bail`, `A.detention`, `A.lawyer`, `A.trial`, `JAIL_OK` |

Les valeurs chiffrées restent **provisoires** : garde-les dans des constantes regroupées, jamais en dur dans les écrans.

## 2 · Écrans à créer ou mettre à jour (lib/features/v21/, routes dans lib/app/router21.dart)

Chaque planche du zip est la référence visuelle de son écran. Garde la direction « Néon de Bakoma » et les composants partagés existants.

| Groupe | Planches | Travail |
| --- | --- | --- |
| Démarrage | 21-S0 à 21-S5, 21-S0b | Vérifier la conformité (pays d'origine validé) |
| QG et journée | 21-Q1, 21-Q2, 21-Q3, 21-Q4, 21-V1, 21-J1 | Ajouter au QG les cartes « Dialogue », « Affaire en cours », « En prison » ; atelier dans les activités |
| Studio | 21-M1, **21-M6 Instru**, **21-M7 Cabine**, **21-M8 Mix**, 21-M2, 21-M3, 21-M3b, 21-M4, 21-M5 | Créer M6 à M8 ; dans M1, « Choisir l'instru, puis la cabine » remplace l'enregistrement direct |
| Catalogue | **21-A0, 21-A0b, 21-A1, 21-A2** | Nouveaux : liste des titres, fiche avec crédits, création d'EP/album, résultats |
| Scène | 21-C2, **21-B1 Battle**, **21-B2**, 21-C3, 21-C1 | Créer B1, B2 ; open mic avec effet décroissant |
| Classements | 21-R1, 21-R2 | Lignes Albums et EPs reliées aux projets |
| Business | 21-E1 à 21-E5, 21-L1, **21-L2 Labels** | L2 nouveau : 10 labels, logos, directeurs, statut de l'offre |
| Dialogues | **21-X0 Scènes, 21-X1 Dialogue** | Un seul écran de dialogue générique piloté par `DLG` (décor, personnage, réplique, 2-3 choix avec conséquence et étiquette Certain / Estimé / Incertain / Risque) |
| Plateformes | **21-D1 à 21-D4** | Ondéa, Klipo, Cauri Music (fictives) |
| Personnages | **21-K1** | Galerie (25 personnages) |
| Justice (16+) | **21-Z1 à 21-Z5** | Activités illégales, garde à vue, avocat, tribunal, prison ; écran verrouillé tant que le contenu mature est désactivé |
| Vie perso, famille, profil | 21-01 à 21-14, 21-P1 | P1 : ajouter catalogue, scènes, plateformes, personnages et le réglage « Contenu mature (16+) » |

**Visuels SVG** : les portraits, logos de labels et de plateformes, décors (tribunal, commissariat, cellule) et pochettes sont des SVG inline dans les planches. Extrais-les dans `assets/svg/` (un fichier par élément, nom explicite) et affiche-les avec `flutter_svg` s'il est déjà dans pubspec.yaml. S'il n'y est pas, **demande-moi avant de l'ajouter**. N'invente aucune image : un visuel manquant reste un remplaçant étiqueté.

**Ne pas porter** : 21-Q0 (outil de démonstration), les boutons « Revoir (démo) » de 21-X0, et les planches documentaires 21-00, 21-00b, 21-00c.

## 3 · Règles à respecter

- Monde entièrement fictif : aucune marque réelle. S'il reste des écrans « Spotify », « YouTube », « Apple Music » de ton travail précédent, remplace-les par Ondéa, Klipo et Cauri Music (21-D1 à 21-D4), puis vérifie par recherche qu'il ne reste aucune mention de Spotify, YouTube, Apple, Deezer ou TikTok.
- Aucune navigation automatique : après le mini-jeu ou la battle, un bouton « Écouter le mix » ou « Voir le résultat » apparaît, le joueur le touche.
- Coûts et conséquences affichés avant chaque action ; motif clair quand une action est impossible (voir la table `ERR` de binder21.js pour les messages).
- Aucune nouvelle dépendance sans mon accord écrit. Clé anon seulement côté client, aucun secret dans le dépôt.
- Le code v20 : ne le supprime pas maintenant. À la fin, liste-moi ce qui n'est plus utilisé.

## 4 · Vérification

- `flutter analyze` propre, tous les tests verts, dont les tests de parité.
- Balayage des routes à 390 × 844 et 360 × 800, avec les états début, carrière, star et prison : aucun débordement.
- Tests de widget de bout en bout :
  1. splash → création → QG → défi de K-Zer en battle → studio (instru, cabine, mix) → sortie → catalogue → classements ;
  2. offre de Kôrô en dialogue, négociée à 35 % ;
  3. EP de 3 titres jusqu'au Top 50 EPs ;
  4. offre de label signée après contre-offre ;
  5. contenu mature activé → arrestation → caution → avocat → procès → prison → sortie.
- Captures à 390 px de chaque nouvel écran, à côté de sa planche.

## 5 · Livraison

Avance par groupe (moteur d'abord, puis studio, catalogue, scène, dialogues, labels, plateformes, justice) avec un commit par groupe. Rapport court à la fin : ce qui est porté, les écarts avec les planches ou avec engine21.js, et seulement les décisions qui me bloquent.
