# RAP EMPIRE · v21 (prototype jouable)

1. Décompresse le dossier.
2. Ouvre `index.html` dans Chrome, Edge ou Firefox, puis « Jouer depuis le splash ».
3. La partie est enregistrée dans le navigateur (7 jours). « Nouvelle partie » sur le splash l'efface.

Contenu
- `21-*.dc.html` : les 76 planches (72 écrans de 390 px, 4 documents).
- `game21.js` : moteur et liaison des écrans, assemblés à partir de `sources/engine21.js` et `sources/binder21.js`.
- `rap.css`, `v20.css`, `v21.css` : styles ; `canvas.json` : disposition du canevas Claude Design.
- `sources/test21.js` : tests du moteur (`node sources/test21.js`, depuis le dossier `sources`).
- `support.js` : petit remplaçant hors ligne du script de l'hébergeur ; il n'est pas nécessaire au jeu.

Les polices viennent de Google Fonts : sans connexion, une police système les remplace.
Tout est fictif (Bakoma, cauris) ; les valeurs chiffrées sont provisoires (voir la planche 21-00b Réglages).

Garde-robe à tenues préfabriquées (proposé, à valider) : planches 21-W0 à 21-W3, illustrations de test dans `assets/characters/rapper_001/` (manifest.json, young/, mature/).

## 21.N — Espace Réseau et marketing (proposé, à valider)

- `21-N0-Reseau` (accès : QG, Profil, résultats de sortie) : notoriété Local / National / Global, trois plateformes, mes clips, marketing.
- `21-N1-Ondea` (cyan, page artiste), `21-N2-Klipo` et `21-N3-Klipo-lecteur` (noir et or, 50 vidéos), `21-N6-Cauri-Music` (rose et or, premium).
- `21-N4-Mes-clips`, `21-N5-Clip` : clips publiés du joueur et leurs statistiques.
- `21-N7-Marketing`, `21-N8-Campagne` : 8 médias fictifs (2 locaux, 3 nationaux dès N3, 3 globaux dès N5), confirmation dès 15 000 cauris (I-08).
- `21-C2-Scene`, `21-C3-Concert` : public visible (4 densités selon le remplissage) et média partenaire sur l'écran géant (+ bonus de cachet).
- Ressources : `assets/klipo/thumbs/T001 à T050.svg`, `assets/klipo/mine/M1 à M8.svg`, `assets/scene/crowd_1 à 4.svg` (SVG sans texte, compatibles flutter_svg). Générateur : `sources/gen_net_svg.py`.
- Prix, durées et effets des campagnes : provisoires (D-08).
