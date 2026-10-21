#!/usr/bin/env python3
"""Génère les logos des 10 labels et des 8 médias de RAP EMPIRE.

Usage :  python3 tools/design/gen_logos.py        (depuis la racine du dépôt)
Sortie : assets/logos/label_<CODE>.svg  (BSR, AMG, RCD, BLG, AUB, LYR, SKP, NUG, SIC, VAG)
         assets/logos/media_<id>.svg    (lagune, affiches, bktv, solomag, spot, tamtv, korradio, aldwave)
SVG pur, carré 128 x 128, pas de filtre. flutter_svg n'affiche pas <text> : les lettres sont dessinées en traits
(petite police vectorielle ci-dessous). Chaque logo a un emblème lié à son identité (planche 18.1, network21.dart).
Palette du jeu uniquement ; aucune marque réelle.
"""
import math, os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'assets', 'logos')

BG, DEEP, S1, S2, LINE = '#14102B', '#0C0820', '#1F1942', '#2B2459', '#3A3270'
ACC, ACC4, ACC7, TINT = '#F43F9D', '#FF6BB8', '#C21E78', '#3A1B52'
VIOLET, GOLD, CY, OK, INK, INK2 = '#8B5CF6', '#FFC83D', '#3CD6F2', '#3DDC97', '#F8F7FF', '#B6B0DD'

# Police en traits : chaque lettre dans une case de 4 x 6 unités.
GLYPHS = {
    'A': 'M0 6 L2 0 L4 6 M0.8 4 H3.2',
    'B': 'M0 3 H2.4 C4.3 3 4.3 6 2.4 6 H0 V0 H2.2 C3.9 0 3.9 3 2.2 3',
    'C': 'M4 1 C3 -0.3 0 -0.3 0 3 C0 6.3 3 6.3 4 5',
    'D': 'M0 0 V6 H1.6 C4.5 6 4.5 0 1.6 0Z',
    'F': 'M4 0 H0 V6 M0 2.9 H3',
    'G': 'M4 1 C3 -0.3 0 -0.3 0 3 C0 6.3 4 6.3 4 3.4 H2.2',
    'I': 'M2 0 V6 M0.8 0 H3.2 M0.8 6 H3.2',
    'K': 'M0 0 V6 M4 0 L0 3.6 M1.4 2.6 L4 6',
    'L': 'M0 0 V6 H4',
    'M': 'M0 6 V0 L2 3.4 L4 0 V6',
    'N': 'M0 6 V0 L4 6 V0',
    'O': 'M2 0 C4.7 0 4.7 6 2 6 C-0.7 6 -0.7 0 2 0Z',
    'P': 'M0 6 V0 H2.4 C4.4 0 4.4 3.4 2.4 3.4 H0',
    'R': 'M0 6 V0 H2.4 C4.4 0 4.4 3.4 2.4 3.4 H0 M2 3.4 L4 6',
    'S': 'M4 0.9 C3 -0.4 0 -0.2 0 1.6 C0 3.4 4 2.6 4 4.4 C4 6.2 1 6.4 0 5.1',
    'T': 'M0 0 H4 M2 0 V6',
    'U': 'M0 0 V4 C0 6.6 4 6.6 4 4 V0',
    'V': 'M0 0 L2 6 L4 0',
    'W': 'M0 0 L1 6 L2 2.2 L3 6 L4 0',
    'Y': 'M0 0 L2 3 L4 0 M2 3 V6',
}


def word(txt, cx, cy, h, col, sw=1.15, gap=1.7):
    """Mot centré en (cx, cy), hauteur de lettre h, en traits arrondis."""
    k = h / 6
    width = len(txt) * 4 + (len(txt) - 1) * gap
    x0 = cx - width * k / 2
    parts = []
    for i, ch in enumerate(txt):
        parts.append('<path transform="translate(%.2f %.2f) scale(%.3f)" d="%s" fill="none" stroke="%s" stroke-width="%.2f" stroke-linecap="round" stroke-linejoin="round"/>'
                     % (x0 + i * (4 + gap) * k, cy - h / 2, k, GLYPHS[ch], col, sw))
    return ''.join(parts)


class Logo:
    def __init__(self, uid):
        self.uid, self.defs, self.body = uid, [], []

    def lin(self, name, c1, c2, vertical=False):
        gid = '%s_%s' % (self.uid, name)
        xy = 'x1="0" y1="0" x2="0" y2="1"' if vertical else 'x1="0" y1="0" x2="1" y2="1"'
        self.defs.append('<linearGradient id="%s" %s><stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient>' % (gid, xy, c1, c2))
        return 'url(#%s)' % gid

    def rad(self, name, c, o=.8):
        gid = '%s_%s' % (self.uid, name)
        self.defs.append('<radialGradient id="%s" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="%s" stop-opacity="%s"/><stop offset="1" stop-color="%s" stop-opacity="0"/></radialGradient>' % (gid, c, o, c))
        return 'url(#%s)' % gid

    def add(self, *s):
        self.body.extend(s)

    def render(self):
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128"><defs>%s</defs>%s</svg>' % (''.join(self.defs), ''.join(self.body))


def pt(cx, cy, r, deg):
    a = math.radians(deg)
    return cx + r * math.cos(a), cy + r * math.sin(a)


def star(cx, cy, R, r, n=5, rot=-90):
    p = []
    for i in range(2 * n):
        x, y = pt(cx, cy, R if i % 2 == 0 else r, rot + i * 180 / n)
        p.append('%.1f %.1f' % (x, y))
    return 'M' + ' L'.join(p) + 'Z'


# ------------------------------------------------------------------------------------------------------------------
# Labels
# ------------------------------------------------------------------------------------------------------------------

def bsr():  # Bakoma Sound Records : sceau doré du label dominant, couronne
    L = Logo('bsr')
    L.add('<circle cx="64" cy="64" r="62" fill="%s"/>' % L.lin('g', '#FFE08A', '#C9961A'))
    L.add('<circle cx="64" cy="64" r="54" fill="%s"/>' % BG, '<circle cx="64" cy="64" r="49" fill="none" stroke="%s" stroke-width="1.5" stroke-dasharray="2 4"/>' % GOLD)
    L.add('<path d="M38 52 L34 30 L50 42 L64 24 L78 42 L94 30 L90 52Z" fill="%s"/><rect x="38" y="52" width="52" height="6" rx="2" fill="%s"/>' % (GOLD, GOLD))
    L.add('<circle cx="64" cy="23" r="3.5" fill="%s"/><circle cx="34" cy="29" r="3" fill="%s"/><circle cx="94" cy="29" r="3" fill="%s"/>' % (ACC, ACC, ACC))
    L.add(word('BSR', 64, 82, 22, INK, 1.25))
    return L.render()


def amg():  # Ambre Music Group : gemme d'ambre, grand public
    L = Logo('amg')
    pts = ' '.join('%.1f %.1f' % pt(64, 64, 62, -90 + i * 60) for i in range(6))
    L.add('<path d="M%sZ" fill="%s"/>' % (pts, L.lin('g', '#FFB347', '#B8560E')))
    inner = ' '.join('%.1f %.1f' % pt(64, 64, 50, -90 + i * 60) for i in range(6))
    L.add('<path d="M%sZ" fill="%s"/>' % (inner, '#2B1A05'))
    L.add('<path d="M64 20 L84 38 L64 50 L44 38Z" fill="%s"/><path d="M64 20 L84 38 L64 32Z" fill="#FFFFFF" opacity=".45"/>' % GOLD)
    L.add(word('AMG', 64, 78, 22, '#FFD58A', 1.3))
    L.add('<rect x="40" y="96" width="48" height="3" rx="1.5" fill="%s"/>' % GOLD)
    return L.render()


def rcd():  # Rythme Cardinal : rose des vents et battement, export afro-fusion
    L = Logo('rcd')
    L.add('<rect width="128" height="128" rx="30" fill="%s"/>' % L.lin('g', ACC, ACC7))
    L.add('<path d="%s" fill="%s" opacity=".9"/>' % (star(64, 44, 26, 6, 4, -90), INK))
    L.add('<path d="%s" fill="%s"/>' % (star(64, 44, 14, 4, 4, -45), GOLD))
    L.add('<path d="M14 66 H42 L48 56 L56 76 L62 62 H114" fill="none" stroke="%s" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" opacity=".85"/>' % BG)
    L.add(word('RCD', 64, 96, 20, INK, 1.3))
    return L.render()


def blg():  # Black Lagune : trap et drill de Kôtoro, eau noire et crocs
    L = Logo('blg')
    L.add('<rect width="128" height="128" rx="22" fill="#05040B"/>', '<rect x="5" y="5" width="118" height="118" rx="18" fill="none" stroke="%s" stroke-width="2"/>' % CY)
    L.add('<path d="M20 30 L30 46 L40 30 L50 46 L60 30 L70 46 L80 30 L90 46 L100 30 L108 30" fill="none" stroke="%s" stroke-width="4" stroke-linejoin="round"/>' % CY)
    for i, y in enumerate((92, 102, 112)):
        L.add('<path d="M16 %d C32 %d 44 %d 64 %d C84 %d 96 %d 112 %d" fill="none" stroke="%s" stroke-width="2.5" stroke-linecap="round" opacity="%.2f"/>' % (y, y - 6, y + 6, y, y - 6, y + 6, y, CY, .9 - i * .25))
    L.add(word('BLG', 64, 66, 22, INK, 1.35))
    return L.render()


def aub():  # Aube Nouvelle : soleil levant des nouveaux talents de Mabaya
    L = Logo('aub')
    L.add('<rect width="128" height="128" rx="64" fill="%s"/>' % L.lin('g', TINT, VIOLET, True))
    for i in range(9):
        x1, y1 = pt(64, 64, 34, 180 + i * 22.5)
        x2, y2 = pt(64, 64, 52, 180 + i * 22.5)
        L.add('<path d="M%.1f %.1f L%.1f %.1f" stroke="%s" stroke-width="4" stroke-linecap="round"/>' % (x1, y1, x2, y2, GOLD))
    L.add('<path d="M36 64 A28 28 0 0 1 92 64Z" fill="%s"/>' % L.lin('s', '#FFE08A', ACC, True))
    L.add('<rect x="22" y="66" width="84" height="4" rx="2" fill="%s"/>' % INK)
    L.add(word('AUB', 64, 92, 20, INK, 1.3))
    return L.render()


def lyr():  # Lyrik Atelier : plume et encre, rap technique
    L = Logo('lyr')
    L.add('<rect width="128" height="128" rx="26" fill="%s"/>' % INK)
    L.add('<rect x="6" y="6" width="116" height="116" rx="21" fill="none" stroke="%s" stroke-width="2"/>' % BG)
    L.add('<path d="M64 14 C82 30 82 50 64 66 C46 50 46 30 64 14Z" fill="%s"/>' % BG)
    L.add('<path d="M64 24 V62" stroke="%s" stroke-width="2.5" stroke-linecap="round"/><circle cx="64" cy="44" r="4" fill="%s"/>' % (INK, ACC))
    L.add('<path d="M40 74 C52 70 76 78 88 74" fill="none" stroke="%s" stroke-width="2.5" stroke-linecap="round"/>' % ACC)
    L.add(word('LYR', 64, 96, 20, BG, 1.35))
    return L.render()


def skp():  # Studio Kôrô Productions : vinyle et casque de DJ Kôrô
    L = Logo('skp')
    L.add('<rect width="128" height="128" rx="28" fill="%s"/>' % L.lin('g', S2, DEEP, True))
    L.add('<circle cx="64" cy="58" r="34" fill="#08060F"/>')
    for k in (30, 25, 20):
        L.add('<circle cx="64" cy="58" r="%d" fill="none" stroke="#FFFFFF" stroke-opacity=".12"/>' % k)
    L.add('<circle cx="64" cy="58" r="11" fill="%s"/><circle cx="64" cy="58" r="2.5" fill="#08060F"/>' % ACC)
    L.add('<path d="M24 62 C24 22 104 22 104 62" fill="none" stroke="%s" stroke-width="5" stroke-linecap="round"/>' % ACC4)
    L.add('<rect x="16" y="56" width="14" height="24" rx="6" fill="%s"/><rect x="98" y="56" width="14" height="24" rx="6" fill="%s"/>' % (ACC, ACC))
    L.add(word('SKP', 64, 106, 18, INK, 1.35))
    return L.render()


def nug():  # Ndolo Underground : plaque d'égout de la rue, pochoir
    L = Logo('nug')
    L.add('<circle cx="64" cy="64" r="62" fill="#3A3A44"/>', '<circle cx="64" cy="64" r="56" fill="#2A2A33"/>')
    for i in range(7):
        y = 22 + i * 14
        L.add('<rect x="20" y="%d" width="88" height="5" rx="2" fill="#464652"/>' % y)
    L.add('<rect x="18" y="48" width="92" height="32" rx="4" fill="%s" transform="rotate(-4 64 64)"/>' % GOLD)
    L.add('<g transform="rotate(-4 64 64)">%s</g>' % word('NUG', 64, 64, 20, DEEP, 1.5))
    for x, y in ((30, 28), (98, 98), (100, 32)):
        L.add('<circle cx="%d" cy="%d" r="2.5" fill="%s"/>' % (x, y, GOLD))
    return L.render()


def sic():  # Sélène Indie Collective : croissant de lune, trois cercles liés
    L = Logo('sic')
    L.add('<rect width="128" height="128" rx="40" fill="%s"/>' % L.lin('g', '#123A55', S1, True))
    L.add('<circle cx="64" cy="46" r="26" fill="%s"/><circle cx="74" cy="40" r="22" fill="#163552"/>' % '#BDF4FF')
    for x in (40, 64, 88):
        L.add('<circle cx="%d" cy="78" r="9" fill="none" stroke="%s" stroke-width="3"/>' % (x, CY))
    L.add('<path d="M49 78 H55 M73 78 H79" stroke="%s" stroke-width="3"/>' % CY)
    L.add(word('SIC', 64, 106, 16, INK, 1.4))
    return L.render()


def vag():  # Vague Argentée : vague d'argent ternie, label en difficulté
    L = Logo('vag')
    L.add('<rect width="128" height="128" rx="24" fill="%s"/>' % L.lin('g', '#D9DEEA', '#7C849A'))
    L.add('<path d="M10 70 C30 40 50 40 64 58 C76 74 96 74 118 46 V118 H10Z" fill="%s"/>' % S1)
    L.add('<path d="M10 70 C30 40 50 40 64 58 C76 74 96 74 118 46" fill="none" stroke="#F2F4FA" stroke-width="4" stroke-linecap="round"/>')
    L.add('<path d="M84 22 L94 22 M100 22 L104 22 M30 26 H40" stroke="%s" stroke-width="3" stroke-linecap="round" opacity=".7"/>' % S1)
    L.add(word('VAG', 64, 94, 20, '#D9DEEA', 1.3))
    return L.render()


# ------------------------------------------------------------------------------------------------------------------
# Médias
# ------------------------------------------------------------------------------------------------------------------

def lagune():  # Radio Lagune FM
    L = Logo('mlag')
    L.add('<rect width="128" height="128" rx="28" fill="%s"/>' % L.lin('g', '#0F4A66', BG, True))
    L.add('<circle cx="64" cy="44" r="8" fill="%s"/>' % CY)
    for r, o in ((18, .9), (28, .6), (38, .35)):
        L.add('<path d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f" fill="none" stroke="%s" stroke-width="4" stroke-linecap="round" opacity="%.2f"/>' % (*pt(64, 44, r, 215), r, r, *pt(64, 44, r, 325), CY, o))
    L.add('<path d="M14 74 C28 66 40 82 54 74 C68 66 80 82 94 74 C104 68 110 72 114 74" fill="none" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % INK)
    L.add(word('FM', 64, 100, 18, INK, 1.4))
    return L.render()


def affiches():  # Affiches Ndolo : affiche collée, coin arraché
    L = Logo('maff')
    L.add('<rect width="128" height="128" rx="20" fill="%s"/>' % BG)
    L.add('<path d="M18 14 H110 V92 L96 114 H18Z" fill="%s" transform="rotate(-3 64 64)"/>' % GOLD)
    L.add('<path d="M110 92 L96 114 L98 96Z" fill="#C9961A" transform="rotate(-3 64 64)"/>')
    L.add('<g transform="rotate(-3 64 64)">%s<rect x="30" y="80" width="68" height="4" rx="2" fill="%s"/><rect x="30" y="90" width="44" height="4" rx="2" fill="%s"/></g>' % (word('AN', 64, 50, 34, BG, 1.2), BG, BG))
    L.add('<circle cx="24" cy="20" r="3" fill="%s"/><circle cx="104" cy="18" r="3" fill="%s"/>' % (ACC, ACC))
    return L.render()


def bktv():  # Bakoma TV
    L = Logo('mbk')
    L.add('<rect width="128" height="128" rx="28" fill="%s"/>' % L.lin('g', ACC, VIOLET))
    L.add('<path d="M48 16 L64 32 L80 16" fill="none" stroke="%s" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>' % INK)
    L.add('<rect x="18" y="32" width="92" height="66" rx="16" fill="%s"/>' % BG)
    L.add(word('BTV', 64, 65, 24, INK, 1.25))
    L.add('<rect x="44" y="104" width="40" height="6" rx="3" fill="%s"/>' % BG)
    return L.render()


def solomag():  # Sôlo Mag : couverture de magazine
    L = Logo('msol')
    L.add('<rect width="128" height="128" rx="18" fill="%s"/>' % VIOLET)
    L.add('<rect x="22" y="12" width="84" height="104" rx="4" fill="%s"/>' % INK)
    L.add('<rect x="22" y="12" width="84" height="30" rx="4" fill="%s"/>' % BG)
    L.add(word('SM', 64, 27, 18, INK, 1.4))
    L.add('<circle cx="64" cy="76" r="22" fill="%s"/><circle cx="64" cy="70" r="9" fill="%s"/><path d="M48 92 C50 80 78 80 80 92Z" fill="%s"/>' % (ACC4, BG, BG))
    L.add('<rect x="30" y="104" width="40" height="4" rx="2" fill="%s"/>' % VIOLET)
    return L.render()


def spot():  # Ondéa Spotlight : projecteur et onde
    L = Logo('mspot')
    L.add('<rect width="128" height="128" rx="64" fill="%s"/>' % BG)
    L.add('<path d="M64 14 L100 104 H28Z" fill="%s"/>' % L.lin('b', CY, BG, True))
    L.add('<rect x="54" y="8" width="20" height="14" rx="4" fill="%s"/>' % INK)
    L.add('<ellipse cx="64" cy="104" rx="38" ry="8" fill="%s"/>' % CY)
    L.add('<path d="M34 76 C42 64 50 88 58 76 C66 64 74 88 82 76 C88 68 92 72 94 76" fill="none" stroke="%s" stroke-width="4" stroke-linecap="round"/>' % INK)
    return L.render()


def tamtv():  # Tamarel Live TV : écran, lecture, globe
    L = Logo('mtam')
    L.add('<rect width="128" height="128" rx="28" fill="%s"/>' % DEEP)
    L.add('<circle cx="64" cy="56" r="40" fill="none" stroke="%s" stroke-width="2.5"/>' % ACC4)
    L.add('<ellipse cx="64" cy="56" rx="18" ry="40" fill="none" stroke="%s" stroke-width="2" opacity=".6"/><path d="M24 56 H104" stroke="%s" stroke-width="2" opacity=".6"/>' % (ACC4, ACC4))
    L.add('<path d="M54 38 L82 56 L54 74Z" fill="%s"/>' % ACC4)
    L.add('<circle cx="100" cy="20" r="6" fill="%s"/>' % ACC)
    L.add(word('TLT', 64, 110, 16, INK, 1.4))
    return L.render()


def korradio():  # Korvane Beats Radio : pylône et ondes
    L = Logo('mkor')
    L.add('<rect width="128" height="128" rx="28" fill="%s"/>' % L.lin('g', '#0E3B2E', BG, True))
    L.add('<path d="M64 20 L46 92 M64 20 L82 92 M52 66 H76 M56 48 H72" stroke="%s" stroke-width="4" stroke-linecap="round"/>' % OK)
    L.add('<circle cx="64" cy="20" r="6" fill="%s"/>' % INK)
    for r, o in ((14, .9), (24, .55)):
        for side in (-1, 1):
            a0, a1 = (200, 250) if side < 0 else (290, 340)
            L.add('<path d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f" fill="none" stroke="%s" stroke-width="3.5" stroke-linecap="round" opacity="%.2f"/>' % (*pt(64, 20, r, a0), r, r, *pt(64, 20, r, a1), OK, o))
    L.add(word('KBR', 64, 108, 16, INK, 1.4))
    return L.render()


def aldwave():  # Aldéra Wave : barres d'onde dorées
    L = Logo('mald')
    L.add('<rect width="128" height="128" rx="36" fill="%s"/>' % S1)
    hs = [14, 26, 40, 56, 40, 64, 46, 30, 52, 34, 20, 12]
    for i, h in enumerate(hs):
        x = 18 + i * 8.4
        L.add('<rect x="%.1f" y="%.1f" width="5" height="%d" rx="2.5" fill="%s"/>' % (x, 52 - h / 2, h, GOLD if i % 3 else ACC))
    L.add(word('AW', 64, 104, 22, INK, 1.3))
    return L.render()


LABELS = {'BSR': bsr, 'AMG': amg, 'RCD': rcd, 'BLG': blg, 'AUB': aub, 'LYR': lyr, 'SKP': skp, 'NUG': nug, 'SIC': sic, 'VAG': vag}
MEDIA = {'lagune': lagune, 'affiches': affiches, 'bktv': bktv, 'solomag': solomag, 'spot': spot, 'tamtv': tamtv, 'korradio': korradio, 'aldwave': aldwave}


def main():
    os.makedirs(OUT, exist_ok=True)
    for k, fn in LABELS.items():
        open(os.path.join(OUT, 'label_%s.svg' % k), 'w').write(fn())
    for k, fn in MEDIA.items():
        open(os.path.join(OUT, 'media_%s.svg' % k), 'w').write(fn())
    print('%d logos écrits dans %s' % (len(LABELS) + len(MEDIA), OUT))


if __name__ == '__main__':
    main()
