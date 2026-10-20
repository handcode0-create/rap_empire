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
