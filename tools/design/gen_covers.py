#!/usr/bin/env python3
"""Génère les pochettes de RAP EMPIRE : singles (selon le thème et l'ambiance du son) et projets (albums, EP).

Usage :  python3 tools/design/gen_covers.py        (depuis la racine du dépôt)
Sortie : assets/covers/s_<theme>_<ambiance>_<variante>.svg   pochettes de single (13 thèmes x 3 ambiances x 6 variantes)
         assets/covers/al_<n>.svg                            pochettes d'album (8), Djo Kéné en couleur
         assets/covers/ep_<n>.svg                            pochettes d'EP (8), Djo Kéné en silhouette
Mêmes règles que export_assets.py et gen_awards.py : SVG pur, carré 300 x 300, pas de filtre, pas de <text>
(flutter_svg ne l'affiche pas), palette unique du jeu. Aucune marque ni lieu réel : motifs inventés de Bakoma
(immeubles de Ndolo, gbaka, cauris, lagune, vinyles). Le personnage vient des exports de cast.py (assets/characters).
"""
import math, os, random, re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'assets', 'covers')
CHARS = os.path.join(ROOT, 'assets', 'characters')

BG, DEEP, S1, S2, LINE = '#14102B', '#0C0820', '#1F1942', '#2B2459', '#3A3270'
ACC, ACC4, ACC7, TINT = '#F43F9D', '#FF6BB8', '#C21E78', '#3A1B52'
VIOLET, GOLD, CY, OK, INK = '#8B5CF6', '#FFC83D', '#3CD6F2', '#3DDC97', '#F8F7FF'

W = 300

# ambiance : (haut du fond, bas du fond, accent, second accent, lumière)
AMBS = {
    'sombre': (BG, DEEP, ACC, VIOLET, ACC4),
    'fiere': (TINT, DEEP, GOLD, ACC, '#FFE08A'),
    'legere': ('#123A55', S1, CY, ACC4, '#BDF4FF'),
}

THEMES = ['quartier', 'galere', 'ambition', 'amour', 'rue', 'argent', 'fete', 'ego', 'introspection', 'identite', 'trap', 'gloire', 'autre']


def f(x):
    return ('%.1f' % x).rstrip('0').rstrip('.')


class Svg:
    def __init__(self, uid):
        self.uid, self.defs, self.body = uid, [], []

    def grad(self, name, c1, c2, vertical=True, o1=1, o2=1):
        gid = '%s_%s' % (self.uid, name)
        xy = 'x1="0" y1="0" x2="0" y2="1"' if vertical else 'x1="0" y1="0" x2="1" y2="1"'
        self.defs.append('<linearGradient id="%s" %s><stop offset="0" stop-color="%s" stop-opacity="%s"/><stop offset="1" stop-color="%s" stop-opacity="%s"/></linearGradient>' % (gid, xy, c1, o1, c2, o2))
        return 'url(#%s)' % gid

    def glow(self, name, c, o=0.8):
        gid = '%s_%s' % (self.uid, name)
        self.defs.append('<radialGradient id="%s" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="%s" stop-opacity="%s"/><stop offset="1" stop-color="%s" stop-opacity="0"/></radialGradient>' % (gid, c, o, c))
        return 'url(#%s)' % gid

    def add(self, s):
        self.body.append(s)

    def render(self):
        return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d"><defs>%s</defs>%s</svg>'
                % (W, W, W, W, ''.join(self.defs), ''.join(self.body)))


# ------------------------------------------------------------------------------------------------------------------
# Briques
# ------------------------------------------------------------------------------------------------------------------

def background(s, a, r, v):
    top, bot, acc, acc2, light = a
    s.add('<rect width="300" height="300" fill="%s"/>' % s.grad('bg', top, bot))
    if v == 1:  # grand disque de lumière
        s.add('<circle cx="%s" cy="%s" r="%s" fill="%s"/>' % (f(150 + r.uniform(-40, 40)), f(r.uniform(90, 130)), f(r.uniform(95, 120)), s.glow('sun', acc, .75)))
    elif v == 2:  # bandes obliques
        for i in range(-2, 9):
            x = i * 46
            s.add('<path d="M%s 0 L%s 0 L%s 300 L%s 300Z" fill="%s" opacity=".07"/>' % (f(x), f(x + 20), f(x - 110), f(x - 130), acc))
        s.add('<circle cx="80" cy="70" r="110" fill="%s"/>' % s.glow('g2', acc2, .45))
    else:
        s.add('<circle cx="%s" cy="%s" r="140" fill="%s"/>' % (f(r.uniform(60, 240)), f(r.uniform(40, 120)), s.glow('g1', acc2, .55)))


def grain(s, r, n=90):
    for _ in range(n):
        s.add('<circle cx="%s" cy="%s" r="%s" fill="#FFFFFF" opacity="%s"/>' % (f(r.uniform(0, 300)), f(r.uniform(0, 300)), f(r.uniform(.4, 1.2)), f(r.uniform(.04, .16))))


def finish(s, a, r, v, sticker=True):
    top, bot, acc, acc2, light = a
    s.add('<rect width="300" height="300" fill="%s"/>' % s.grad('vg', '#000000', '#000000', True, 0, .45))
    grain(s, r)
    if v == 1:  # liseré de pochette
        s.add('<rect x="12" y="12" width="276" height="276" rx="4" fill="none" stroke="%s" stroke-opacity=".55" stroke-width="2"/>' % light)
    if sticker:  # étiquette décorative, sans texte
        x = 300 - 58 if r.random() < .5 else 16
        s.add('<rect x="%d" y="262" width="42" height="22" rx="3" fill="%s" opacity=".9"/><rect x="%d" y="268" width="26" height="3" rx="1.5" fill="%s"/><rect x="%d" y="274" width="18" height="3" rx="1.5" fill="%s"/>'
              % (x, INK, x + 8, DEEP, x + 8, DEEP))


def skyline(s, r, base, col, lit, hmin=60, hmax=150, op=1):
    x = -10
    out = ''
    while x < 310:
        w = r.uniform(26, 52)
        h = r.uniform(hmin, hmax)
        out += '<rect x="%s" y="%s" width="%s" height="%s" fill="%s"/>' % (f(x), f(base - h), f(w + 1), f(h + 1), col)
        for wy in range(int(base - h + 10), int(base - 8), 12):
            for wx in range(int(x + 6), int(x + w - 6), 10):
                if r.random() < .3:
                    out += '<rect x="%d" y="%d" width="4" height="5" fill="%s" opacity="%s"/>' % (wx, wy, lit, f(r.uniform(.5, 1)))
        x += w + r.uniform(0, 6)
    s.add('<g opacity="%s">%s</g>' % (op, out))


def gbaka(s, x, y, body, glass, lamp):
    s.add('<g transform="translate(%s %s)"><rect x="0" y="0" width="120" height="46" rx="12" fill="%s"/><rect x="10" y="8" width="22" height="16" rx="3" fill="%s"/>'
          '<rect x="36" y="8" width="22" height="16" rx="3" fill="%s"/><rect x="62" y="8" width="22" height="16" rx="3" fill="%s"/><rect x="88" y="8" width="24" height="18" rx="4" fill="%s"/>'
          '<rect x="0" y="30" width="120" height="5" fill="%s" opacity=".6"/><circle cx="26" cy="48" r="10" fill="%s"/><circle cx="26" cy="48" r="4" fill="%s"/><circle cx="94" cy="48" r="10" fill="%s"/>'
          '<circle cx="94" cy="48" r="4" fill="%s"/><circle cx="116" cy="34" r="4" fill="%s"/></g>'
          % (f(x), f(y), body, glass, glass, glass, glass, lamp, DEEP, LINE, DEEP, LINE, lamp))


def cauri(x, y, sc, fill, line):
    return ('<g transform="translate(%s %s) scale(%s)"><ellipse cx="0" cy="0" rx="14" ry="20" fill="%s"/><path d="M0 -15 C-5 -6 -5 6 0 15 C5 6 5 -6 0 -15Z" fill="%s"/>'
            '<path d="M-3 -8 h6 M-3.5 -3 h7 M-3.5 2 h7 M-3 7 h6" stroke="%s" stroke-width="1.4" stroke-linecap="round"/></g>' % (f(x), f(y), f(sc), fill, line, fill))


def star(cx, cy, R, rr, n=5, rot=-90):
    pts = []
    for i in range(n * 2):
        ang = math.radians(rot + i * 180 / n)
        rad = R if i % 2 == 0 else rr
        pts.append('%s %s' % (f(cx + rad * math.cos(ang)), f(cy + rad * math.sin(ang))))
    return 'M' + ' L'.join(pts) + 'Z'


def vinyl(s, cx, cy, R, label, label2):
    s.add('<circle cx="%s" cy="%s" r="%s" fill="#08060F"/>' % (f(cx), f(cy), f(R)))
    for k in (.92, .82, .72, .62, .52):
        s.add('<circle cx="%s" cy="%s" r="%s" fill="none" stroke="#FFFFFF" stroke-opacity=".08"/>' % (f(cx), f(cy), f(R * k)))
    s.add('<path d="M%s %s A%s %s 0 0 1 %s %s" fill="none" stroke="#FFFFFF" stroke-opacity=".25" stroke-width="3" stroke-linecap="round"/>'
          % (f(cx - R * .7), f(cy - R * .5), f(R * .85), f(R * .85), f(cx + R * .15), f(cy - R * .82)))
    s.add('<circle cx="%s" cy="%s" r="%s" fill="%s"/><circle cx="%s" cy="%s" r="%s" fill="%s"/><circle cx="%s" cy="%s" r="%s" fill="#08060F"/>'
          % (f(cx), f(cy), f(R * .32), label, f(cx), f(cy), f(R * .2), label2, f(cx), f(cy), f(R * .04)))


def mic(x, y, sc, body, grille):
    return ('<g transform="translate(%s %s) scale(%s)"><rect x="-16" y="-48" width="32" height="46" rx="16" fill="%s"/>'
            '<path d="M-16 -36 h32 M-16 -26 h32 M-16 -16 h32 M-6 -48 v46 M6 -48 v46" stroke="%s" stroke-width="2" opacity=".6"/>'
            '<path d="M-24 -18 v4 a24 24 0 0 0 48 0 v-4" fill="none" stroke="%s" stroke-width="5" stroke-linecap="round"/><rect x="-3" y="10" width="6" height="26" fill="%s"/>'
            '<rect x="-16" y="34" width="32" height="6" rx="3" fill="%s"/></g>' % (f(x), f(y), f(sc), grille, body, body, body, body))


def crown(x, y, sc, fill, gem):
    return ('<g transform="translate(%s %s) scale(%s)"><path d="M-40 20 L-46 -22 L-22 0 L0 -32 L22 0 L46 -22 L40 20Z" fill="%s"/><rect x="-42" y="20" width="84" height="12" rx="3" fill="%s"/>'
            '<circle cx="0" cy="-34" r="5" fill="%s"/><circle cx="-46" cy="-24" r="4" fill="%s"/><circle cx="46" cy="-24" r="4" fill="%s"/><circle cx="0" cy="26" r="4" fill="%s"/></g>'
            % (f(x), f(y), f(sc), fill, fill, gem, gem, gem, DEEP))


def heart(x, y, sc, fill):
    return '<path transform="translate(%s %s) scale(%s)" d="M0 30 C-40 4 -44 -24 -22 -30 C-10 -33 -2 -24 0 -16 C2 -24 10 -33 22 -30 C44 -24 40 4 0 30Z" fill="%s"/>' % (f(x), f(y), f(sc), fill)


# ------------------------------------------------------------------------------------------------------------------
# Motifs par thème
# ------------------------------------------------------------------------------------------------------------------

def m_quartier(s, a, r, v):
    top, bot, acc, acc2, light = a
    skyline(s, r, 230, S2, light, 50, 110, .7)
    skyline(s, r, 250, DEEP, acc, 70, 150)
    s.add('<rect x="0" y="236" width="300" height="64" fill="%s"/>' % DEEP)
    gbaka(s, r.uniform(40, 140), 206, acc if v != 2 else acc2, light, GOLD)
    s.add('<path d="M0 270 L300 262" stroke="%s" stroke-width="2" stroke-dasharray="14 10" opacity=".5"/>' % light)


def m_rue(s, a, r, v):
    top, bot, acc, acc2, light = a
    skyline(s, r, 260, DEEP, light, 120, 220)
    s.add('<path d="M110 300 L140 150 L160 150 L190 300Z" fill="%s" opacity=".9"/>' % S1)
    s.add('<path d="M148 300 L149 160 L151 160 L152 300Z" fill="%s" opacity=".7"/>' % light)
    x = r.choice([60, 230])
    s.add('<rect x="%d" y="70" width="5" height="190" fill="%s"/><path d="M%d 70 h26 v6 h-26Z" fill="%s"/><circle cx="%d" cy="80" r="40" fill="%s"/><circle cx="%d" cy="78" r="5" fill="%s"/>'
          % (x, LINE, x, LINE, x + 24, s.glow('lamp', light, .7), x + 24, light))


def m_galere(s, a, r, v):
    top, bot, acc, acc2, light = a
    s.add('<rect x="146" y="70" width="6" height="190" fill="%s"/><path d="M128 70 h42 l-6 10 h-30Z" fill="%s"/>' % (LINE, LINE))
    s.add('<ellipse cx="149" cy="160" rx="70" ry="110" fill="%s"/>' % s.glow('cone', light, .35))
    for _ in range(70):
        x, y = r.uniform(0, 300), r.uniform(0, 250)
        s.add('<path d="M%s %s l-4 14" stroke="%s" stroke-width="1.3" opacity="%s" stroke-linecap="round"/>' % (f(x), f(y), light, f(r.uniform(.2, .6))))
    s.add('<rect x="0" y="252" width="300" height="48" fill="%s"/><ellipse cx="149" cy="268" rx="60" ry="8" fill="%s" opacity=".35"/>' % (DEEP, light))
    for i in range(4):
        s.add('<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="none" stroke="%s" opacity=".4"/>' % (f(r.uniform(40, 260)), f(r.uniform(262, 290)), f(r.uniform(8, 18)), f(r.uniform(2, 4)), light))


def m_ambition(s, a, r, v):
    top, bot, acc, acc2, light = a
    n = 7
    for i in range(n):
        x = 30 + i * 34
        y = 270 - (i + 1) * 26
        s.add('<rect x="%d" y="%d" width="36" height="%d" fill="%s"/><rect x="%d" y="%d" width="36" height="4" fill="%s"/>' % (x, y, 300 - y, S2 if i % 2 else S1, x, y, acc))
    s.add('<path d="%s" fill="%s"/>' % (star(260, 58, 26, 11), GOLD))
    s.add('<circle cx="260" cy="58" r="60" fill="%s"/>' % s.glow('st', GOLD, .45))
    for i in range(12):
        s.add('<path d="%s" fill="%s" opacity="%s"/>' % (star(r.uniform(10, 200), r.uniform(10, 120), 3, 1.2, 4), light, f(r.uniform(.4, .9))))


def m_amour(s, a, r, v):
    top, bot, acc, acc2, light = a
    s.add('<circle cx="150" cy="150" r="110" fill="%s"/>' % s.glow('h', acc, .5))
    s.add(heart(150, 140, 2.6, acc))
    s.add(heart(168, 150, 1.6, acc2) if v == 2 else heart(150, 140, 1.7, ACC7 if acc == ACC else acc2))
    s.add('<path d="M40 250 C100 210 200 290 260 240" fill="none" stroke="%s" stroke-width="3" opacity=".6"/>' % light)
    for _ in range(14):
        s.add(heart(r.uniform(20, 280), r.uniform(20, 280), r.uniform(.15, .3), light).replace('/>', ' opacity=".5"/>'))


def m_argent(s, a, r, v):
    top, bot, acc, acc2, light = a
    for i in range(6):
        y = 250 - i * 14
        s.add('<ellipse cx="110" cy="%d" rx="44" ry="11" fill="%s"/><ellipse cx="110" cy="%d" rx="44" ry="11" fill="none" stroke="#C9961A"/>' % (y, GOLD, y))
    for i in range(4):
        y = 250 - i * 14
        s.add('<ellipse cx="200" cy="%d" rx="40" ry="10" fill="%s"/><ellipse cx="200" cy="%d" rx="40" ry="10" fill="none" stroke="#C9961A"/>' % (y, '#FFE08A', y))
    for _ in range(9):
        s.add(cauri(r.uniform(30, 270), r.uniform(30, 150), r.uniform(.8, 1.6), INK, '#C9B9A0'))


def m_fete(s, a, r, v):
    top, bot, acc, acc2, light = a
    s.add('<circle cx="150" cy="80" r="40" fill="%s"/>' % S2)
    for i in range(8):
        for j in range(6):
            s.add('<rect x="%d" y="%d" width="9" height="9" fill="%s" opacity="%s"/>' % (114 + i * 9, 44 + j * 12, light, f(r.uniform(.3, 1))))
    s.add('<circle cx="150" cy="80" r="40" fill="none" stroke="%s" stroke-width="2"/>' % light)
    for k in range(9):
        ang = math.radians(20 + k * 18)
        s.add('<path d="M150 80 L%s %s L%s %s Z" fill="%s" opacity=".12"/>' % (f(150 + 300 * math.cos(ang) - 14), f(80 + 300 * math.sin(ang)), f(150 + 300 * math.cos(ang) + 14), f(80 + 300 * math.sin(ang)), [acc, acc2, light][k % 3]))
    for x in (34, 222):
        s.add('<rect x="%d" y="170" width="44" height="100" rx="6" fill="%s"/><circle cx="%d" cy="200" r="13" fill="%s"/><circle cx="%d" cy="242" r="17" fill="%s"/><circle cx="%d" cy="242" r="6" fill="%s"/>'
              % (x, DEEP, x + 22, LINE, x + 22, LINE, x + 22, acc))
    for _ in range(40):
        s.add('<rect x="%s" y="%s" width="5" height="9" fill="%s" transform="rotate(%d %s %s)"/>' % (f(r.uniform(0, 300)), f(r.uniform(110, 280)), r.choice([acc, acc2, GOLD, CY]), r.randint(0, 180), f(r.uniform(0, 300)), f(r.uniform(0, 300))))


def m_ego(s, a, r, v):
    top, bot, acc, acc2, light = a
    s.add('<circle cx="150" cy="140" r="100" fill="%s"/>' % s.glow('e', acc, .55))
    s.add('<path d="M168 30 L120 150 L150 150 L130 270 L190 120 L158 120 L180 30Z" fill="%s" opacity=".35"/>' % light)
    s.add(crown(150, 92, 1.0, GOLD, acc))
    s.add(mic(150, 210, 1.05, INK, LINE))


def m_introspection(s, a, r, v):
    top, bot, acc, acc2, light = a
    s.add('<circle cx="190" cy="100" r="46" fill="%s"/><circle cx="208" cy="88" r="40" fill="%s"/>' % (light, top))
    s.add('<circle cx="190" cy="100" r="110" fill="%s"/>' % s.glow('m', light, .25))
    s.add('<rect x="0" y="200" width="300" height="100" fill="%s"/>' % s.grad('wat', S1, DEEP))
    for i in range(7):
        y = 212 + i * 11
        w = 70 - i * 6
        s.add('<rect x="%s" y="%d" width="%s" height="2" rx="1" fill="%s" opacity="%s"/>' % (f(190 - w / 2 + r.uniform(-6, 6)), y, f(w), light, f(.6 - i * .07)))
    s.add('<path d="M0 200 L40 176 L80 192 L120 168 L170 196 L230 182 L300 198 L300 202 L0 202Z" fill="%s"/>' % DEEP)


def m_identite(s, a, r, v):
    top, bot, acc, acc2, light = a
    cols = [acc, GOLD, acc2, CY, INK]
    for i in range(10):
        y = i * 30
        c = cols[i % len(cols)]
        s.add('<rect x="0" y="%d" width="300" height="10" fill="%s" opacity=".18"/>' % (y + 10, c))
        for k in range(10):
            if (i + k) % 2:
                s.add('<path d="M%d %d l10 -8 l10 8 l-10 8Z" fill="%s" opacity=".35"/>' % (k * 30 + 5, y + 15, c))
    s.add('<circle cx="150" cy="150" r="78" fill="%s"/><circle cx="150" cy="150" r="78" fill="none" stroke="%s" stroke-width="4"/>' % (DEEP, GOLD))
    s.add(cauri(150, 150, 2.6, INK, '#C9B9A0'))
    for k in range(12):
        ang = math.radians(k * 30)
        s.add('<circle cx="%s" cy="%s" r="5" fill="%s"/>' % (f(150 + 92 * math.cos(ang)), f(150 + 92 * math.sin(ang)), [acc, GOLD, acc2][k % 3]))


def m_trap(s, a, r, v):
    top, bot, acc, acc2, light = a
    for i, x in enumerate((30, 90, 210, 270)):
        s.add('<rect x="%d" y="40" width="22" height="260" fill="%s"/>' % (x - 11, S1 if i % 2 else DEEP))
    for i in range(9):
        y = 30 + i * 22
        s.add('<ellipse cx="150" cy="%d" rx="14" ry="10" fill="none" stroke="%s" stroke-width="5"/>' % (y, GOLD if i % 2 else '#C9961A'))
    s.add('<path d="M150 214 L178 238 L150 282 L122 238Z" fill="%s"/><path d="M150 214 L178 238 L122 238Z" fill="#FFFFFF" opacity=".35"/>' % CY)
    s.add('<circle cx="150" cy="248" r="70" fill="%s"/>' % s.glow('dia', CY, .35))


def m_gloire(s, a, r, v):
    top, bot, acc, acc2, light = a
    vinyl(s, 150, 150, 92, GOLD, acc)
    for side in (-1, 1):
        for i in range(8):
            ang = math.radians(110 + i * 17) if side < 0 else math.radians(70 - i * 17)
            x, y = 150 + 118 * math.cos(ang), 160 + 118 * math.sin(ang)
            rot = math.degrees(ang) + (90 if side < 0 else -90)
            s.add('<ellipse cx="%s" cy="%s" rx="6" ry="15" fill="%s" transform="rotate(%s %s %s)"/>' % (f(x), f(y), GOLD, f(rot), f(x), f(y)))


def m_autre(s, a, r, v):
    top, bot, acc, acc2, light = a
    vinyl(s, 150, 160, 100, acc, acc2)
    s.add(mic(232, 120, .8, INK, LINE))


MOTIFS = {'quartier': m_quartier, 'rue': m_rue, 'galere': m_galere, 'ambition': m_ambition, 'amour': m_amour, 'argent': m_argent, 'fete': m_fete,
          'ego': m_ego, 'introspection': m_introspection, 'identite': m_identite, 'trap': m_trap, 'gloire': m_gloire, 'autre': m_autre}


VARIANTS = 6


def single(theme, amb, v):
    """Variantes 0 à 2 : trois mises en page ; 3 à 5 : les mêmes en miroir, accents inversés, autre tirage."""
    top, bot, acc, acc2, light = AMBS[amb]
    a = (top, bot, acc2, acc, light) if v >= 3 else (top, bot, acc, acc2, light)
    lay = v % 3
    r = random.Random('%s|%s|%d' % (theme, amb, v))
    s = Svg('c%s%s%d' % (theme[:3], amb[:2], v))
    background(s, a, r, lay)
    if v >= 3:
        s.add('<g transform="translate(300 0) scale(-1 1)">')
    MOTIFS[theme](s, a, r, lay)
    if v >= 3:
        s.add('</g>')
    finish(s, a, r, lay)
    return s.render()


# ------------------------------------------------------------------------------------------------------------------
# Projets : Djo Kéné (exports de cast.py)
# ------------------------------------------------------------------------------------------------------------------

def character(name, prefix, silhouette=None):
    """Contenu d'un export de personnage, ids préfixés ; silhouette : une seule couleur pour tout le dessin."""
    src = open(os.path.join(CHARS, name)).read()
    vb = [float(x) for x in re.search(r'viewBox="([^"]+)"', src).group(1).split()]
    inner = re.search(r'<svg[^>]*>(.*)</svg>', src, re.S).group(1)
    inner = re.sub(r'<text[^>]*>.*?</text>', '', inner, flags=re.S)
    inner = re.sub(r'id="([^"]+)"', lambda m: 'id="%s%s"' % (prefix, m.group(1)), inner)
    inner = re.sub(r'url\(#([^)]+)\)', lambda m: 'url(#%s%s)' % (prefix, m.group(1)), inner)
    inner = re.sub(r'href="#([^"]+)"', lambda m: 'href="#%s%s"' % (prefix, m.group(1)), inner)
    if silhouette:
        inner = re.sub(r'<defs>.*?</defs>', '', inner, flags=re.S)
        inner = re.sub(r'fill="(?!none)[^"]*"', 'fill="%s"' % silhouette, inner)
        inner = re.sub(r'stroke="(?!none)[^"]*"', 'stroke="%s"' % silhouette, inner)
        inner = re.sub(r'(fill|stroke)-opacity="[^"]*"', '', inner)
        inner = re.sub(r'\bopacity="[^"]*"', '', inner)
    return vb, inner


def place(vb, inner, x, y, h):
    """Place le personnage : bas centré en (x, y), hauteur h."""
    vx, vy, vw, vh = vb
    k = h / vh
    return '<g transform="translate(%s %s) scale(%s) translate(%s %s)">%s</g>' % (f(x - vw * k / 2), f(y - h), ('%.4f' % k), f(-vx), f(-vy), inner)


ALBUMS = [  # (pose, ambiance, décor)
    ('djo_serious_mic_torso.svg', 'sombre', 'ville'),
    ('djo_cool_bust.svg', 'fiere', 'soleil'),
    ('djo_sing_micup_torso.svg', 'legere', 'vinyle'),
    ('djo_smirk_bust.svg', 'sombre', 'cauris'),
    ('djo_poised_deal_torso.svg', 'fiere', 'cadre'),
    ('djo_laugh_up_torso.svg', 'legere', 'ville'),
    ('djo_angry_cross_closed_torso.svg', 'sombre', 'soleil'),
    ('djo_poised_bust.svg', 'fiere', 'vinyle'),
]
EPS = [  # (pose, ambiance, décor) : silhouette d'une couleur
    ('djo_cool_bust.svg', 'sombre', 'cercle'),
    ('djo_sing_micup_dyn_torso.svg', 'legere', 'rayures'),
    ('djo_serious_bust.svg', 'fiere', 'cercle'),
    ('djo_laugh_mic_torso.svg', 'sombre', 'lagune'),
    ('djo_smirk_bust.svg', 'legere', 'cercle'),
    ('djo_angry_cross_closed_torso.svg', 'fiere', 'rayures'),
    ('djo_poised_bust.svg', 'sombre', 'lagune'),
    ('djo_sing_bust.svg', 'fiere', 'cercle'),
]


def decor(s, a, r, kind):
    top, bot, acc, acc2, light = a
    if kind == 'ville':
        skyline(s, r, 300, S2, light, 80, 190, .9)
    elif kind == 'soleil':
        s.add('<circle cx="150" cy="130" r="110" fill="%s"/>' % s.grad('sol', acc, acc2))
        for i in range(6):
            s.add('<rect x="30" y="%d" width="240" height="%d" fill="%s"/>' % (150 + i * 16, 4 + i, top))
    elif kind == 'vinyle':
        vinyl(s, 150, 130, 120, acc, acc2)
    elif kind == 'cauris':
        for _ in range(18):
            s.add(cauri(r.uniform(10, 290), r.uniform(10, 200), r.uniform(.9, 1.8), acc, top).replace('<g ', '<g opacity=".55" ', 1))
    elif kind == 'cadre':
        for k in range(5):
            m = 18 + k * 16
            s.add('<rect x="%d" y="%d" width="%d" height="%d" fill="none" stroke="%s" stroke-opacity="%s" stroke-width="2"/>' % (m, m, 300 - 2 * m, 300 - 2 * m, acc, f(.8 - k * .14)))
    elif kind == 'cercle':
        s.add('<circle cx="150" cy="140" r="104" fill="%s"/>' % acc)
        s.add('<circle cx="150" cy="140" r="116" fill="none" stroke="%s" stroke-width="2"/>' % light)
    elif kind == 'rayures':
        for i in range(12):
            s.add('<rect x="0" y="%d" width="300" height="12" fill="%s"/>' % (i * 25, acc if i % 2 else acc2))
    elif kind == 'lagune':
        s.add('<circle cx="150" cy="120" r="80" fill="%s"/>' % light)
        s.add('<rect x="0" y="170" width="300" height="130" fill="%s"/>' % s.grad('lag', acc2, DEEP))
        for i in range(8):
            s.add('<rect x="%d" y="%d" width="%d" height="2" fill="%s" opacity=".6"/>' % (110 - i * 4, 180 + i * 12, 80 + i * 8, light))


def project(kind, i):
    pose, amb, dec = (ALBUMS if kind == 'al' else EPS)[i]
    a = AMBS[amb]
    top, bot, acc, acc2, light = a
    r = random.Random('%s%d' % (kind, i))
    s = Svg('%s%d' % (kind, i))
    s.add('<rect width="300" height="300" fill="%s"/>' % s.grad('bg', top, bot))
    decor(s, a, r, dec)
    if kind == 'al':
        vb, inner = character(pose, '%s%d_' % (kind, i))
        s.defs.append(re.search(r'<defs>(.*?)</defs>', inner, re.S).group(1) if '<defs>' in inner else '')
        inner = re.sub(r'<defs>.*?</defs>', '', inner, flags=re.S)
        s.add('<ellipse cx="150" cy="300" rx="130" ry="40" fill="%s"/>' % s.glow('fl', acc, .6))
        s.add(place(vb, inner, 150, 304, 250))
        s.add('<rect width="300" height="300" fill="%s"/>' % s.grad('vg', '#000000', '#000000', True, 0, .25))
        s.add('<rect x="0" y="0" width="300" height="10" fill="%s"/>' % acc)
    else:
        vb, inner = character(pose, '%s%d_' % (kind, i), silhouette=DEEP)
        s.add(place(vb, inner, 150, 300, 230))
        s.add('<rect x="22" y="22" width="256" height="256" fill="none" stroke="%s" stroke-width="3"/>' % INK)
    grain(s, r, 70)
    return s.render()


def main():
    os.makedirs(OUT, exist_ok=True)
    n = 0
    for t in THEMES:
        for a in AMBS:
            for v in range(VARIANTS):
                open(os.path.join(OUT, 's_%s_%s_%d.svg' % (t, a, v)), 'w').write(single(t, a, v))
                n += 1
    for k in ('al', 'ep'):
        for i in range(8):
            open(os.path.join(OUT, '%s_%d.svg' % (k, i + 1)), 'w').write(project(k, i))
            n += 1
    print('%d pochettes écrites dans %s' % (n, OUT))


if __name__ == '__main__':
    main()
