#!/usr/bin/env python3
"""Génère lib/core/widgets/game_icons.dart à partir des icônes --i-* de docs/design-ref/rap.css (Lucide, trait 2).

Usage : python3 tools/design/gen_icons.py   (depuis la racine du dépôt Flutter)
"""
import os, re, urllib.parse

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
css = open(os.path.join(ROOT, 'docs', 'design-ref', 'rap.css'), encoding='utf-8').read()
icons = {}
for name, data in re.findall(r'--i-([a-z]+):url\("data:image/svg\+xml,(.*?)"\);?', css, flags=re.S):
    svg = urllib.parse.unquote(data)
    icons[name] = svg
out = ["// GÉNÉRÉ par tools/design/gen_icons.py depuis docs/design-ref/rap.css : ne pas modifier à la main.",
       "// Icônes Lucide du prototype v20 (trait de 2, noir : recolorées par GameIcon).",
       "const Map<String, String> gameIconSvgs = {"]
for name in sorted(icons):
    assert '"""' not in icons[name]
    out.append("  '%s': r'''%s'''," % (name, icons[name]))
out.append("};")
path = os.path.join(ROOT, 'lib', 'core', 'widgets', 'game_icons.dart')
open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
print('%d icônes : %s' % (len(icons), ', '.join(sorted(icons))))
