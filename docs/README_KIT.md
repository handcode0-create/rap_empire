# Kit design RAP EMPIRE pour le dépôt Flutter

Contenu (à copier à la racine de rap_empire_app, en conservant les chemins) :
- `tools/design/` : générateurs Python des personnages et décors (chars.py, chars2.py, cast.py, scenes.py, art.py) + `export_assets.py`
- `assets/characters/` (309 SVG) et `assets/scenes/` (6 décors) : exportés, prêts à l'emploi
- `lib/core/widgets/character_view.dart`, `scene_banner.dart` : affichage des SVG (dépendance : flutter_svg)
- `docs/design-ref/` : le prototype v20 (planches .dc.html, rap.css, v20.css, game.js) = référence visuelle
- `.claude/skills/rap-empire-design/SKILL.md` : règles que Claude Code doit suivre

À faire dans le dépôt :
1. `flutter pub add flutter_svg`, puis ajouter `assets/characters/` et `assets/scenes/` dans `flutter: assets:` de pubspec.yaml.
2. Régénérer à volonté : `python3 tools/design/export_assets.py` (Python 3, aucune dépendance).
