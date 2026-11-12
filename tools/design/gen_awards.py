#!/usr/bin/env python3
"""Génère les illustrations de la salle des trophées de RAP EMPIRE : plaques de certification et trophées des cérémonies.

Usage :  python3 tools/design/gen_awards.py        (depuis la racine du dépôt)
Sortie : assets/awards/plaque_<niveau>.svg   (or, platine, double, triple, diamant, vide)
         assets/awards/trophee_<ceremonie>.svg (revelation, rue, grandprix, bakoma) et trophee_vide.svg
Même règles que export_assets.py : SVG pur, pas de filtre, pas de texte (flutter_svg n'affiche pas <text>),
palette unique du jeu. Aucune marque, aucun objet réel : formes inventées (disque, cauri, micro, étoile).
"""
import math, os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'assets', 'awards')

BG, DEEP, S1, S2, LINE = '#14102B', '#0C0820', '#1F1942', '#2B2459', '#3A3270'
ACC, VIOLET, GOLD, CY, OK, INK = '#F43F9D', '#8B5CF6', '#FFC83D', '#3CD6F2', '#3DDC97', '#F8F7FF'

# niveau : (disque clair, disque foncé, liseré, nombre de disques)
LEVELS = {
    'or': ('#FFE08A', '#C9961A', GOLD, 1),
    'platine': ('#F2F4FA', '#9AA3B8', '#D9DEEA', 1),
    'double': ('#F2F4FA', '#9AA3B8', '#D9DEEA', 2),
    'triple': ('#F2F4FA', '#9AA3B8', '#D9DEEA', 3),
    'diamant': ('#E6FBFF', '#3CB8D6', CY, 1),
    'vide': ('#3A3270', '#241D4A', '#4A4280', 1),
}


def disc(cx, cy, r, light, dark, uid):
    grooves = ''.join('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="none" stroke="%s" stroke-opacity=".35" stroke-width="1"/>' % (cx, cy, r * k, dark)
                      for k in (0.92, 0.84, 0.76, 0.68, 0.6, 0.52))
    return ('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="url(#d%s)"/>' % (cx, cy, r, uid) + grooves +
            '<path d="M%.1f %.1f A%.1f %.1f 0 0 1 %.1f %.1f" fill="none" stroke="#FFFFFF" stroke-opacity=".55" stroke-width="3" stroke-linecap="round"/>'
            % (cx - r * 0.7, cy - r * 0.45, r * 0.82, r * 0.82, cx + r * 0.1, cy - r * 0.8) +
            '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>' % (cx, cy, r * 0.3, ACC) +
            '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>' % (cx, cy, r * 0.22, VIOLET) +
            '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>' % (cx, cy, r * 0.05, DEEP))


def plaque(level):
    light, dark, rim, n = LEVELS[level]
    w, h = 240, 300
    defs = ('<defs><linearGradient id="fr" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient>'
            '<linearGradient id="in" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient>' % (rim, dark, S2, DEEP))
    discs = ''
    if n == 1:
        pos = [(120, 128, 70)]
    elif n == 2:
        pos = [(92, 120, 54), (148, 140, 54)]
    else:
        pos = [(78, 112, 46), (120, 132, 46), (162, 152, 46)]
    for i, (cx, cy, r) in enumerate(pos):
        defs += ('<radialGradient id="d%d" cx=".35" cy=".3" r=".8"><stop offset="0" stop-color="%s"/><stop offset=".6" stop-color="%s"/><stop offset="1" stop-color="%s"/></radialGradient>'
                 % (i, light, light, dark))
        discs += disc(cx, cy, r, light, dark, i)
    defs += '</defs>'
    sparkle = ''
    if level == 'diamant':
        for (x, y, s) in [(52, 60, 9), (190, 70, 7), (186, 214, 6), (60, 206, 5)]:
            sparkle += ('<path d="M%d %d L%d %d L%d %d L%d %d Z" fill="%s"/>' % (x, y - s, x + s * 0.35, y, x, y + s, x - s * 0.35, y, CY) +
                        '<path d="M%d %d L%d %d L%d %d L%d %d Z" fill="%s"/>' % (x - s, y, x, y - s * 0.35, x + s, y, x, y + s * 0.35, CY))
    # cartouche (sans texte) : bandes de couleur pour le niveau
    band = '<rect x="60" y="236" width="120" height="14" rx="7" fill="%s"/>' % rim
    band += '<rect x="80" y="258" width="80" height="8" rx="4" fill="%s" fill-opacity=".55"/>' % rim
    opacity = ' opacity=".55"' if level == 'vide' else ''
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d">' % (w, h, w, h) + defs +
            '<rect x="4" y="4" width="232" height="292" rx="20" fill="url(#fr)"/>'
            '<rect x="16" y="16" width="208" height="268" rx="12" fill="url(#in)"/>'
            '<g%s>' % opacity + discs + '</g>' + sparkle + band + '</svg>')


def star(cx, cy, r, color):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * 0.45
        pts.append('%.1f,%.1f' % (cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return '<polygon points="%s" fill="%s"/>' % (' '.join(pts), color)


def trophy(kind):
    """Trophées des quatre cérémonies (formes inventées)."""
    w, h = 220, 300
    metal = {'revelation': ('#FFB6DA', ACC), 'rue': ('#B7F5DA', OK), 'grandprix': ('#D9C8FF', VIOLET), 'bakoma': ('#FFE08A', '#C9961A'), 'vide': ('#4A4280', '#2B2459')}[kind]
    light, dark = metal
    defs = ('<defs><linearGradient id="m" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="%s"/><stop offset=".45" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient>'
            '<linearGradient id="b" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient></defs>' % (dark, light, dark, S2, DEEP))
    base = ('<rect x="50" y="250" width="120" height="34" rx="6" fill="url(#b)"/>'
            '<rect x="64" y="262" width="92" height="10" rx="5" fill="%s" fill-opacity=".8"/>' % light +
            '<rect x="78" y="226" width="64" height="26" rx="4" fill="url(#m)"/>')
    if kind == 'revelation':  # étoile montante
        top = '<rect x="104" y="150" width="12" height="78" rx="6" fill="url(#m)"/>' + star(110, 108, 58, 'url(#m)') + star(110, 108, 26, '#FFFFFF')
    elif kind == 'rue':  # micro levé
        top = ('<rect x="102" y="140" width="16" height="88" rx="8" fill="url(#m)"/>'
               '<ellipse cx="110" cy="98" rx="38" ry="48" fill="url(#m)"/>' +
               ''.join('<line x1="%d" y1="62" x2="%d" y2="136" stroke="%s" stroke-opacity=".5" stroke-width="2"/>' % (x, x, dark) for x in (92, 104, 116, 128)) +
               '<ellipse cx="96" cy="80" rx="8" ry="16" fill="#FFFFFF" fill-opacity=".5"/>')
    elif kind == 'grandprix':  # coupe
        top = ('<path d="M58 70 H162 C162 140 140 178 110 184 C80 178 58 140 58 70 Z" fill="url(#m)"/>'
               '<path d="M58 84 C30 84 30 130 66 138" fill="none" stroke="url(#m)" stroke-width="10" stroke-linecap="round"/>'
               '<path d="M162 84 C190 84 190 130 154 138" fill="none" stroke="url(#m)" stroke-width="10" stroke-linecap="round"/>'
               '<rect x="102" y="182" width="16" height="46" rx="6" fill="url(#m)"/>'
               '<path d="M74 82 C74 120 86 150 104 164" fill="none" stroke="#FFFFFF" stroke-opacity=".5" stroke-width="6" stroke-linecap="round"/>')
    elif kind == 'bakoma':  # cauri d'or sur colonne
        top = ('<rect x="100" y="160" width="20" height="68" rx="8" fill="url(#m)"/>'
               '<ellipse cx="110" cy="104" rx="50" ry="66" fill="url(#m)"/>'
               '<path d="M110 50 C96 80 96 128 110 158 C124 128 124 80 110 50 Z" fill="%s"/>' % dark +
               ''.join('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % (102, y, 118, y, light) for y in (78, 92, 106, 120, 134)) +
               '<ellipse cx="88" cy="80" rx="10" ry="20" fill="#FFFFFF" fill-opacity=".45"/>')
    else:  # emplacement vide
        top = '<ellipse cx="110" cy="120" rx="52" ry="70" fill="none" stroke="#6E6896" stroke-width="4" stroke-dasharray="10 8"/>'
    glow = '' if kind == 'vide' else '<circle cx="110" cy="112" r="96" fill="%s" fill-opacity=".10"/>' % light
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d">' % (w, h, w, h) + defs + glow + top + base + '</svg>')


def uniq(svg, pfx):
    """Identifiants de dégradés propres à chaque fichier (aucune collision si plusieurs SVG sont affichés ensemble)."""
    import re
    ids = set(re.findall(r'id="([^"]+)"', svg))
    for i in sorted(ids, key=len, reverse=True):
        svg = svg.replace('id="%s"' % i, 'id="%s_%s"' % (pfx, i)).replace('url(#%s)' % i, 'url(#%s_%s)' % (pfx, i))
    return svg


def main():
    os.makedirs(OUT, exist_ok=True)
    files = []
    for lv in LEVELS:
        p = os.path.join(OUT, 'plaque_%s.svg' % lv)
        open(p, 'w', encoding='utf-8').write(uniq(plaque(lv), 'p' + lv)); files.append(p)
    for k in ('revelation', 'rue', 'grandprix', 'bakoma', 'vide'):
        p = os.path.join(OUT, 'trophee_%s.svg' % k)
        open(p, 'w', encoding='utf-8').write(uniq(trophy(k), 't' + k)); files.append(p)
    print('\n'.join(os.path.relpath(f, ROOT) for f in files))


if __name__ == '__main__':
    main()
