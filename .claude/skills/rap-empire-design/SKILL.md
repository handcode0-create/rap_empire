---
name: rap-empire-design
description: Design et implémentation de l'UI de RAP EMPIRE (jeu de simulation rap, Flutter). À utiliser pour tout écran, widget, personnage ou illustration. Le prototype v20 dans docs/design-ref est la référence.
---

# RAP EMPIRE · design de jeu de simulation rap

Une UI qui ne ressemble pas à la planche v20 est fausse, même si elle fonctionne. Palette Material par défaut interdite.

## Méthode obligatoire
1. Ouvrir la planche de référence (docs/design-ref/<id>.dc.html + rap.css + v20.css) et la rendre à 390×844.
2. Reproduire structure, espacements, rayons, textes, composants.
3. Capture à 390 px comparée à la planche ; corriger les écarts avant de livrer.

## Ambiance
Arcade nocturne de rue : violet nuit, magenta et or, coins arrondis, boutons pilule dégradés, bannières illustrées avec personnages 2D expressifs. Un écran = un jeu, pas une app de gestion.

## Tokens (lib/core/theme/tokens.dart, palette unique)
bg #14102B, deep #0C0820, s1 #1F1942, s2 #2B2459, line #3A3270, ink #F8F7FF, ink2 #B6B0DD, acc #F43F9D, acc4 #FF6BB8, acc7 #C21E78, tint #3A1B52, ok #3DDC97, gold #FFC83D (cauris, rangs), cy #3CD6F2 (énergie), violet #8B5CF6. Dégradé 90° #F43F9D → #8B5CF6.
Baloo 2 800 (titres, chiffres) ; Poppins (texte, boutons 800 majuscules). Espacements 4, 8, 12, 16, 24, 32, 48. Cartes rayon 16, bordure 2 px line. Boutons pilule 56 px. Cibles ≥ 48 px. Feuilles rayon 28.

## Anatomie d'un écran de jeu
Barre d'état 24, HUD (mini-avatar DK 40×40, nom, niveau, barre d'XP 6 px, cloche ; puis trois blocs Cash cauris / Énergie / Temps), contenu, barre de navigation 72 px (QG, Studio, Scène, Business, Profil ; trait magenta 3 px sur l'actif) ou bouton retour 48×48. Un seul bouton principal par écran. Écrans de résultat : pas de nav, sortie unique. Six états : disponible, sélectionné, en cours, terminé, verrouillé (cadenas + condition), indisponible.

## Widgets partagés (à construire AVANT les écrans, dans lib/core/widgets/)
HudBar, GameNavBar, SceneBanner (existe), CharacterView (existe), Portrait (monogramme), ChoiceCard + ConsequenceTag (Certain / Estimé / Incertain / Risque), MissionCard, RewardChip, ActionTile, StatKpi, MeterBar, GameToast, BottomSheetGame, PrimaryButton.

## Personnages et illustrations
- Les illustrations sont GÉNÉRÉES par Python (tools/design/) puis exportées en SVG (assets/characters, assets/scenes). Ne jamais dessiner un personnage à la main dans Flutter ; ne jamais modifier un SVG exporté.
- Pour modifier un personnage ou en ajouter : éditer tools/design/cast.py / chars.py, relancer `python3 tools/design/export_assets.py`, commit des SVG.
- Pour une nouvelle combinaison (qui, humeur, geste, pose, cadrage) : l'ajouter à tools/design/used_combos.json puis réexporter. Si elle manque, CharacterView n'affiche rien : ne pas improviser.
- Une fiche fixe par personnage (visage, carnation, coiffure, barbe, accessoires, tenue) ; seules l'expression et le geste varient. Le joueur (djo) porte chaîne et patch BKM, pas les PNJ. La clé `nadia` = Maya Tessé (≠ l'artiste Nadia Kolo).
- Portraits sans illustration : monogramme. Jamais le visage d'un autre personnage.
- Limite connue : flutter_svg n'affiche pas les éléments <text> (pendentif « R », enseignes). Acceptable.
- Avatar éditable du joueur (coiffure, barbe, tenue) : les SVG pré-exportés ne suffisent pas ; il faut exporter les calques ou porter chars.py en Dart. À décider avec Smith.

## Règles de jeu dans l'UI
Cauris ≥ 0 ; énergie 0 à 100 ; confirmation d'achat dès 15 000 cauris ; quatre classements officiels seulement ; distinguer écoutes, auditeurs, fans, ventes ; jamais de pourcentage de réussite isolé ; mêmes chiffres partout pour un même objet. Paramètres d'économie provisoires (D-08) dans econ.dart. Règles de jeu uniquement dans lib/domain, jamais dans les widgets.

## Interdits
Nouvelle couleur ou police ; sixième onglet ; Material brut ; renommer un identifiant d'écran ; élément réel (artiste, lieu, marque) ; présenter une maquette comme fonctionnelle ; figer une illustration définitive sans validation de Smith.
