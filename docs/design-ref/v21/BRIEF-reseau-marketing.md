# Brief pour Claude Code (VS Code) : espace Réseau, clips, marketing, public en concert

À coller tel quel dans Claude Code, à la racine du projet Flutter RAP EMPIRE. Le zip `RAP-EMPIRE-v21.zip` décompressé doit être accessible (chemin à indiquer ci-dessous).

---

## Prompt

Tu travailles sur l'application Flutter RAP EMPIRE (handCode Studio). Référence unique : le prototype v21 décompressé dans `<CHEMIN_V21>`. Tu portes une nouvelle fonctionnalité **déjà spécifiée et testée dans le prototype** : l'espace Réseau, les clips du joueur, le marketing Local / National / Global, les médias partenaires et le public visible en concert. Statut produit : **proposé, à valider** ; les valeurs chiffrées sont provisoires.

### Règles non négociables

1. Ne modifie ni ne supprime rien des versions v19 et v20, ni des 81 écrans d'origine. Pas de migration destructive, pas de suppression de sauvegarde, pas de déploiement, pas de push.
2. Monde entièrement fictif. Aucune marque réelle (pas de plateforme, média, logo ou ville réels). Monnaie : cauris uniquement.
3. Cinq onglets seulement (QG, Studio, Scène, Business, Profil). Le Réseau s'ouvre depuis le QG, le Profil et les résultats de sortie : **pas de nouvel onglet**.
4. Tout achat de 15 000 cauris ou plus passe par une feuille de confirmation (invariant I-08).
5. Aucune nouvelle dépendance sans me demander. `flutter_svg` est déjà là ; les SVG fournis ne contiennent **aucun `<text>`** : tout texte (nom du média sur l'écran LED, durée, badges) est un widget `Text` superposé.
6. Le moteur est la source de vérité : porte la logique de `sources/engine21.js` à l'identique (mêmes formules, mêmes erreurs, mêmes arrondis). Ne réinvente aucune règle.
7. Avant chaque groupe : un commit propre et une sauvegarde de branche. Après chaque groupe : `flutter analyze` sans nouvel avertissement et `flutter test` vert. Si quelque chose risque de modifier l'existant, arrête-toi et demande.

### Lis d'abord (lecture seule, 10 minutes maximum)

- `sources/engine21.js` : blocs `MEDIA`, `MEDIA_ORDER`, `KLIPO` (50 vidéos), `mkActive`, `mkBoost`, `mkSponsor`, `mkCheck`, `notoriety`, `myClips`, `clipStats`, `crowdLevel`, actions `A.kv`, `A.mcl`, `A.mkask`, `A.mkcancel`, `A.mkbuy`, `A.mkconfirm`, et les effets dans `A.release` (bonus d'écoutes), `A.concert` (sponsor, `cc.fill`, `cc.media`, `cc.spon`) et `A.endDay` (effets quotidiens, fin de campagne). Le preset `star` contient 3 clips publiés.
- `sources/test21.js` : le bloc « Réseau, marketing, médias en concert, public » (31 tests). Ce sont tes tests de parité.
- Planches de référence visuelle : `21-N0-Reseau` à `21-N8-Campagne`, `21-C2-Scene`, `21-C3-Concert` (ouvre les `.dc.html` dans un navigateur) et `v21.css` (section `21.N`, classes `nx-*`).
- Ressources : `assets/klipo/thumbs/T001-T050.svg`, `assets/klipo/mine/M1-M8.svg`, `assets/scene/crowd_1-4.svg`.

Puis donne-moi en 10 lignes maximum : les fichiers Dart que tu vas créer ou toucher, et les risques. Attends mon « go » seulement si un fichier existant non lié au Réseau doit changer ; sinon enchaîne.

### Accélération : travaille par groupes en parallèle

Utilise des sous-agents (outil Task) pour les groupes indépendants, chacun avec une liste de fichiers **disjointe** pour éviter les conflits. Tu restes l'intégrateur : tu relis chaque diff, tu lances les tests, tu fais les commits.

- **Groupe A, modèle et moteur** (séquentiel, à faire en premier) : état `mk { on: [{id, from, until}], ask, tot, n }`, `kv`, `mcl` ajoutés à la sauvegarde avec valeurs par défaut (anciennes sauvegardes chargées sans erreur) ; catalogues `MEDIA` et `KLIPO` en données Dart constantes ; actions et effets ci-dessus ; vues dérivées (notoriété, clips, campagne en attente, public). Tests de parité : reprends un à un les 31 tests du bloc Réseau de `test21.js` en `test/reseau_test.dart`.
- **Groupe B, ressources** (en parallèle de A) : copie les 62 SVG dans `assets/`, déclare-les dans `pubspec.yaml`, écris un test qui vérifie que chaque chemin de `KLIPO` et `M1-M8`, `crowd_1-4` existe et qu'aucun SVG ne contient `<text`. Prévois un repli (fond sombre) si un fichier manque : jamais d'icône d'image cassée.
- **Groupe C, écrans plateformes** (après A) : Réseau (hub), Ondéa (thème cyan et violet, page artiste), Klipo accueil (noir et or : vidéo à la une, puces de catégories, rails horizontaux qui couvrent les 50 vidéos) et lecteur, Cauri Music (rose et or, éditorial premium). Chaque plateforme garde sa propre identité visuelle, dans la palette du jeu.
- **Groupe D, clips et marketing** (après A, en parallèle de C) : Mes clips (état vide qui renvoie vers le clip du Studio), détail d'un clip (vues, j'aime, commentaires, rétention, écoutes et fans apportés, étiquettes Certain / Estimé), Marketing (trois niveaux, cartes média : en cours, verrouillé avec le rang, cash insuffisant, lancer), feuille de confirmation.
- **Groupe E, scène** (après A) : bandeau « public » sur la Scène (aperçu selon les billets estimés) et sur le résultat de concert : image `crowd_n` selon le remplissage (seuils 25 / 50 / 80 %), écran LED avec le nom du média partenaire en `Text` positionné (zone 101, 28, 188 × 52 dans un cadre 390 × 220, mise à l'échelle), sinon « Le Parvis · Ndolo » ; ligne « bonus de cachet » quand un sponsor est actif.
- **Groupe F, entrées et navigation** : tuiles Réseau et Marketing au QG, ligne Réseau au Profil, tuile Réseau dans les résultats de sortie, bouton « Voir mes clips » après publication d'un clip. Les anciens écrans Plateformes restent accessibles mais ne sont plus liés.

### Critères d'acceptation (à me montrer à la fin)

- 31 tests de parité verts + tests existants verts ; `flutter analyze` propre.
- Parcours manuel, captures à 390 et 360 de large : partie neuve → campagne locale (5 000, sans confirmation) → nationale verrouillée ; preset star → Bakoma TV (confirmation, −40 000) → concert → public plein et « Bakoma TV » sur l'écran → Klipo → vidéo « Verre Bleu » → Mes clips → « Port-Ambre la nuit ».
- Aucune image cassée, aucun débordement, cibles tactiles ≥ 48 px, textes lus par TalkBack (Semantics sur les vignettes et l'écran LED).
- Rapport final court : fichiers créés et modifiés, écarts avec le prototype, ce qui reste provisoire.
