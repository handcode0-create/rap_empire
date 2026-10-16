# RAP EMPIRE — Audit gameplay et guide de jeu

Basé sur la lecture du code (`lib/domain`, `lib/features`, `lib/app`) et une simulation de l'économie (formules de `rules.dart` / `econ.dart`). Les tests Flutter n'ont pas été exécutés pour cet audit. Toutes les valeurs sont celles de la **démo** (paramètres provisoires D-08).

---

## PARTIE 1 — AUDIT

### 1.1 Ce qui existe (périmètre jouable)

| Zone | État |
|---|---|
| QG (objectif, KPI, passer la journée) | Jouable |
| Studio : instru → écriture → cabine (mini-jeu) → mix → sortie → résultats | Jouable de bout en bout |
| Missions (4) + niveaux 1→5 + récompenses | Jouable |
| Business : matériel (micro seulement), formation, finances | Jouable |
| Profil, fin de journée, reset | Jouable |
| Scène (open mic, battle), Classements, Réseau (label, featuring), Équipe (manager), EP, casque, carte son, tenues | **« Bientôt »** |
| Planches `docs/design-ref` 11 à 20 (boutique, classements, producteurs, label, rivalité, concerts, certifications, cérémonie, managers, crises…) | Non portées |

Le jeu actuel = **une seule boucle** : produire un single, le sortir, recommencer.

### 1.2 La boucle de jeu réelle

```
Instru → Texte (1 h, −20 én.) → Cabine 3 prises (2 h, −25 én.) → Sortie + promo
      → +écoutes, +fans, +pop, +XP → jour suivant 08:00, énergie 100 → recommencer
```
Un cycle = 1 jour, 45 énergie, 70 XP (30 mix + 40 sortie).

### 1.3 Formules clés

- **Qualité** = 0,35·texte + 0,30·voix + 0,35·prod − malus de forme (malus = max(0, 40 − énergie)/2, plafonné à 20).
- **Texte** = 72 + ambiance (Sombre 0 / Fière +2 / Légère −2) + thème (le thème est figé sur « Quartier » dans l'UI, +0).
- **Voix** = moyenne des 3 prises (+8 avec le micro studio).
- **Écoutes** = (9 000 + 6·(fans − 120)) × multiplicateur promo × (Q/100) × 0,987.
- **Revenu** = écoutes × 0,01 cauri. **Fans gagnés** = écoutes × 0,07 / (1 + fans/5 000).
- **XP** : paliers 0 / 100 / 250 / 500 / 900 (N1→N5). Récompenses de niveau : 2 000 / 4 000 / 8 000 / 15 000.

### 1.4 Résultats de simulation (fans 120 au départ, qualité 75)

| Cycle | Sans promo : écoutes / fans | Réseaux (2 000) : écoutes / fans | Cash (Réseaux) |
|---|---|---|---|
| 1 | 6 661 / 576 | 10 655 / 849 | 23 107 |
| 3 | 11 107 / 1 757 | 22 549 / 2 959 | 19 490 |
| 8 | 28 711 / 6 091 | 75 111 / 11 087 | 12 091 |

Revenu par sortie : **67 à 750 cauris**. Une promo Réseaux coûte 2 000, Radio 15 000.

### 1.5 Constats (classés par gravité)

#### 🔴 Bloquants / bugs

**B1 — Un son enregistré peut être perdu sans avertissement.** ✅ *Corrigé : `pick` refuse (erreur « attente ») tant qu'un son n'est pas sorti.*
`studio.pick()` remet `song: null`. Quand un son attend sa sortie, le bouton « Nouveau son » du Studio ouvre le choix d'instru ; choisir une instru **écrase le son non sorti** (et débite l'instru payante). Le texte « Emplacement libre. Enregistre un deuxième son. » laisse croire à deux emplacements. Perte : 45 énergie, 3 h, parfois 8 000+ cauris.
→ Corriger : refuser `pick` tant qu'un son est en attente, ou demander confirmation.

**B2 — L'instru « Lagune d'Ambre » (Q86, 40 000) est inaccessible.**
Elle exige Réputation ≥ 30. La réputation démarre à 8 et **rien dans le code ne l'augmente** (le gain vient de la Scène, non portée). C'est du contenu mort, et le meilleur sur le papier.
→ Soit donner de la réputation (sortie, mission), soit retirer la condition en démo.

**B3 — La mission « Fais-toi voir à l'open mic » (10.3) mène à une impasse.**
« Y aller » ouvre l'onglet Scène = écran « Bientôt ». La promesse (+3 000 cauris, +60 XP) ne peut pas être tenue.

#### 🟠 Équilibrage / design

**E1 — Les compétences ne servent à rien.** ✅ *Corrigé en partie : Écriture et Voix ajoutent +1 de qualité par 3 points au-dessus du départ (Flow et Charisme restent à brancher).*
`flow`, `ecr`, `voix`, `cha` ne sont lues par aucune formule. Écrire donne « Écriture +2 », cabine « Voix +1 », mais la qualité n'en dépend pas. Les formations (6 000 / 9 000 / 7 000 cauris) sont donc un **piège** : seule la mission 3 (atelier d'écriture) donne un gain, et encore : −6 000 pour +4 000 de prime (net −2 000, +60 XP).
→ Faire entrer les compétences dans `quality()` (ex. texte += ecr/…, voix += voix/…) et dans les écoutes (flow, charisme).

**E2 — L'économie en cauris ne tourne pas : les écoutes ne paient pas.**
Revenu moyen par sortie ≈ 100 à 700 cauris contre 2 000 de promo. L'argent vient **uniquement** des missions (34 000) et des niveaux (29 000), soit ~88 000 cauris sur toute la partie, départ compris. Après ça, le cash ne bouge plus. Aucun achat n'est « pesé » : on ne manque jamais d'argent après la mission 4.
→ Relever `listenValue` (×10 à ×50) ou ajouter d'autres sources (cachets de scène, concerts).

**E3 — Aucun enjeu, aucune défaite possible.**
Dormir est gratuit (`nightCost = 0`), l'énergie est remise à 100 à chaque sortie, le temps (jour/heure) n'a aucune conséquence, le cash ne descend pas sous 0. On ne peut pas échouer, ni être pressé. Le « Passer la journée » du QG est un reset gratuit.

**E4 — Choix dominants (pas de vraie décision).**
- Ambiance : **Fière (+2)** bat toujours Sombre (0) et Légère (−2). Le thème n'est pas sélectionnable (tags non cliquables) et les notes Rimes 70 / Images 74 sont codées en dur.
- Promo : **Réseaux sociaux** est le meilleur rapport coût/effet. Radio (15 000) n'est rentable qu'en cycle 1 et vide le cash.
- Les instru payantes apportent peu : Gbaka (+24 prod) ≈ +8 de qualité pour 8 000 cauris. Jouer bien en cabine (+30 de voix) pèse plus lourd que n'importe quel achat.
- Micro studio : +8 voix ≈ +2,4 de qualité pour 18 000 cauris. Rapport très faible.

**E5 — Le mini-jeu est entièrement déterministe.**
Zones fixes (0,62 / 0,34 / 0,72), le curseur repart toujours du bord droit à chaque prise. Il suffit de connaître les délais (voir guide) pour sortir 100 / 100 / 100. Une fois appris, plus aucun défi.
→ Randomiser le centre des zones et/ou la phase du curseur.

**E6 — Progression trop rapide et sans contenu aval.**
Mission 4 (1 000 fans) tombe en 2 sorties. Niveau 2 dès la 1ʳᵉ sortie. Le niveau 5 s'atteint vers le 9ᵉ cycle. Les niveaux 3, 4, 5 ne débloquent rien (aucune instru, aucune fonction). Le seuil Top 100 (252 200 écoutes/semaine) devient atteignable vers le cycle 8–10 avec promo, mais **il n'y a pas d'écran Classements**.
→ La partie se finit en ~1 h de jeu par épuisement du contenu, pas par réussite.

**E7 — Fans sans plafond réel.** Le commentaire annonce une « saturation », mais la formule ne fait que ralentir : les fans passent 14 000 au cycle 8 (Q90 + Réseaux) et la boucle continue linéairement.

#### 🟡 Clarté / UX

- **U1** — « Écoutes estimées · 24 h » à l'écran de sortie, mais la formule représente 7 jours (la semaine = écoutes × 1,5). Libellé trompeur. Le revenu estimé n'est pas affiché alors qu'il est calculé.
- **U2** — Le texte affiché (« Gbaka de six heures, le quartier se réveille… ») est **toujours le même** quels que soient thème et ambiance. Le titre est le seul élément personnalisable.
- **U3** — Aucun didacticiel : l'objectif du QG est la seule guidance. Les règles d'énergie ne sont jamais expliquées avant d'être bloquées.
- **U4** — Plusieurs tuiles mènent à des toasts « bientôt » (Classements, Matériel du studio, Réseau, Équipe, EP, Mes tenues, Casque, Carte son) : beaucoup de promesses non tenues sur les écrans principaux.
- **U5** — Écran Cabine : « Micro de base · qualité 40 / studio · 48 » sont des chiffres décoratifs, sans lien avec la formule (le vrai effet est +8 voix).
- **U6** — La voix peut dépasser 100 avec le micro (aucune borne). Sans conséquence visible, mais incohérent.
- **U7** — Plusieurs gains dans l'interface (« Écriture +2 », « Estimé ») ne sont pas des valeurs de jeu réelles.

### 1.6 Points solides

- Règles pures et testables (`lib/domain`), une trentaine de fichiers de tests.
- Sauvegarde versionnée et rétrocompatible.
- Boucle principale fluide, courte, lisible. Feuille « Trop fatigué » qui redirige proprement vers le repos.
- Mini-jeu de cabine réel, simple à comprendre.
- Confirmation d'achat au-delà de 15 000 cauris.
- Mise en scène (bannières, personnages, toasts, level-up) cohérente.

### 1.7 Priorités recommandées

1. **B1** (perte de son) — correctif de 5 lignes, perte de progression sinon.
2. **E1** (compétences branchées sur les formules) — donne un sens à Formation, Business et à la progression.
3. **E2** (revenus) — redonne de la valeur à chaque dépense.
4. **B2 + B3** — soit ouvrir la réputation / la scène, soit masquer ces éléments en démo.
5. **E5** (mini-jeu variable) puis **E4** (rendre Thème / Ambiance réellement choisissables).
6. Ensuite seulement : Scène, Classements, Réseau, Équipe.

---

## PARTIE 2 — GUIDE DU JOUEUR

### Bienvenue à Bakoma
Tu es **Djo Kéné**, rappeur inconnu du quartier de **Ndolo**. Ton but : sortir des sons, gagner des fans et monter de **Inconnu** à **Star de Bakoma**. La monnaie est le **cauri**. Tu démarres avec **25 000 cauris, 120 fans, 100 d'énergie**.

### Les cinq onglets
| Onglet | Rôle |
|---|---|
| **QG** | Ton objectif en cours, fans / popularité / réputation, accès rapides, « Passer la journée ». |
| **Studio** | Créer et sortir des sons, voir la discographie. |
| **Scène** | *Bientôt* (open mic, battle). |
| **Business** | Matériel, Formation, Finances. |
| **Profil** | Niveau, XP, compétences, reset de la démo. |

### Tes ressources
- **Énergie** (max 100) : chaque action en consomme. Sous 20, tu es « trop fatigué » : il faut dormir.
- **Cauris** : gratuits à dépenser en instrus, promos, matériel, formations.
- **Fans** : ils augmentent ton audience, donc tes écoutes futures.
- **XP / Niveau** : N1 Inconnu → N2 Espoir du quartier (100 XP) → N3 Révélation locale (250) → N4 Nom qui circule (500) → N5 Star de Bakoma (900). Chaque niveau donne des cauris à récupérer (2 000 / 4 000 / 8 000 / 15 000).
- **Popularité** : +1 par 900 écoutes. **Réputation** : pas encore utilisable dans la démo.

### Créer un son (3 étapes)
**1. Instru** (gratuit ou payant, débité tout de suite)
| Instru | Prix | Qualité | Condition |
|---|---|---|---|
| Nuit à Ndo | Gratuit | 32 | — |
| Gbaka de 6h | 8 000 | 56 | — |
| Pont des Griots | 15 000 | 68 | Niveau 2 |
| Lagune d'Ambre | 40 000 | 86 | Réputation 30 (inaccessible pour l'instant) |

**2. Texte** (1 h, −20 énergie) — choisis une ambiance : **Fière** donne la meilleure note (74), Sombre 72, Légère 70. Donne un titre (ou lance « Titre aléatoire »).

**3. Cabine** (2 h, −25 énergie) — 3 prises au mini-jeu. Appuie sur **REC** quand le curseur est dans la zone verte. Plus tu es près du centre, plus la note est haute (100 au centre, −2,3 par centième d'écart). Tu peux aussi « Simuler les 3 prises » (notes fixes 74 / 48 / 43, moyenne 55).

> Astuce timing : le curseur part toujours de la droite et se déplace à ~0,85 de piste par seconde. Pour viser le centre de la zone, appuie environ **0,45 s** après le début de la 1ʳᵉ prise, **0,78 s** après la 2ᵉ, **0,33 s** après la 3ᵉ (le décompte repart à chaque prise). C'est un repère, ajuste à ton écran.

### Sortir le son
Choisis la promo, puis **Sortir le single**.
| Promo | Prix | Effet |
|---|---|---|
| Aucune | 0 | ×1 |
| Réseaux sociaux | 2 000 | ×1,6 écoutes |
| Radio locale | 15 000 | ×3,2 écoutes |

La sortie te donne : écoutes, un petit revenu, des fans, de la popularité, +40 XP. Puis le jeu passe au **jour suivant à 08:00 avec 100 d'énergie**.

### Missions
| # | Mission | Récompense |
|---|---|---|
| 1 | Enregistre ton premier son | 5 000 cauris · 50 XP |
| 2 | Sors ton premier single | 10 000 cauris · 80 XP |
| 3 | Fais un atelier d'écriture (Business › Formation) | 4 000 cauris · 60 XP |
| 4 | Atteins 1 000 fans | 15 000 cauris · 120 XP |

Pense à **récupérer** chaque récompense (bouton « Récupérer »), puis le niveau gagné.

### Business
- **Matériel** : le micro studio (18 000) ajoute +8 à ta voix. Casque et carte son : bientôt.
- **Formation** : Atelier d'écriture (6 000), Freestyle au carrefour (gratuit), Coach vocal (9 000), Shooting et réseaux (7 000). Elles montent tes compétences, qui n'ont **pas encore d'effet sur la qualité** dans cette démo.
- **Finances** : registre de tous tes revenus et dépenses.

### Parcours conseillé (démo)
1. **Jour 1** — Instru gratuite « Nuit à Ndo ». Écrire en **Fière**. Cabine : vise le centre. Sors le single **sans promo** (cash préservé). Récupère mission 1 (+5 000) et mission 2 (+10 000). Tu es N2.
2. **Jour 2** — Prends **Pont des Griots** (15 000) si tu as le cash, sinon Gbaka. Sors avec **Réseaux sociaux** (2 000) : meilleur rapport coût/effet.
3. **Jour 3** — Tu dépasses 1 000 fans : récupère la mission 4 (+15 000). Fais l'atelier d'écriture pour la mission 3 (le gain net est faible, mais +60 XP).
4. **Ensuite** — Enchaîne : instru Q68, ambiance Fière, 100 en cabine, promo Réseaux. Dépense en priorité sur la **promo**, pas sur le micro ni les formations.
5. Radio locale (15 000) : à n'envisager que pour un gros pic de fans, jamais avec un cash serré.

### Règles d'or
- Ne choisis **pas** « Nouveau son » quand un son attend sa sortie : il serait **remplacé** (bug connu).
- Ne dors pas pour rien : la sortie remet déjà l'énergie à 100.
- La qualité dépend d'abord de ta **prise en cabine**, puis de l'instru, puis du texte.
- Les fans font grossir les écoutes suivantes : sortir tôt et souvent vaut mieux que garder un son.
- Ton rang Top 100 demande ~252 000 écoutes sur la semaine ; l'écran des classements n'est pas encore là.

### Questions fréquentes
**Pourquoi la Lagune d'Ambre est verrouillée ?** Elle demande 30 de réputation, qui ne peut pas encore monter.
**À quoi servent les compétences ?** Elles s'affichent dans le Profil, sans influence sur la qualité pour l'instant.
**Puis-je perdre ?** Non : le cash ne descend jamais sous 0 et dormir est gratuit.
**Comment recommencer ?** Profil › « Recommencer la démo ».
