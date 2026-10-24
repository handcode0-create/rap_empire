#!/usr/bin/env python3
"""Génère les décors de miniatures de clips et de publications de RAP EMPIRE : douze petites scènes de Bakoma.

Usage :  python3 tools/design/gen_scenes.py        (depuis la racine du dépôt)
Sortie : assets/klipo/mine/scene_<nom>.svg   (16:9, viewBox 320 x 180)
Mêmes règles que gen_covers.py : SVG pur, pas de filtre, pas de <text>, aucune marque ni lieu réel.
Le centre de chaque décor reste dégagé : le joueur y est posé par l'application (avatar équipé).
"""
import os, random

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(HERE, '..', '..', 'assets', 'klipo', 'mine'))
W, H = 320, 180
BG, DEEP, S1, S2 = '#14102B', '#0C0820', '#1F1942', '#2B2459'
ACC, ACC4, VIOLET, GOLD, CY, OK, INK = '#F43F9D', '#FF6BB8', '#8B5CF6', '#FFC83D', '#3CD6F2', '#3DDC97', '#F8F7FF'

NAMES = ['foret', 'savane', 'resto', 'street', 'rue', 'lagune', 'toit', 'studio', 'marche', 'scene', 'club', 'quartier']


class S:
    def __init__(self, name):
        self.name, self.id, self.parts, self.defs = name, 0, [], []

    def grad(self, stops, x2=0, y2=1, kind='linear', extra=''):
        self.id += 1
        gid = f'{self.name}{self.id}'
        st = ''.join(f'<stop offset="{o}" stop-color="{c}"{"" if a is None else f" stop-opacity=\"{a}\""}/>' for o, c, a in stops)
        if kind == 'linear':
            self.defs.append(f'<linearGradient id="{gid}" x1="0" y1="0" x2="{x2}" y2="{y2}">{st}</linearGradient>')
        else:
            self.defs.append(f'<radialGradient id="{gid}" {extra}>{st}</radialGradient>')
        return f'url(#{gid})'

    def add(self, s):
        self.parts.append(s)

    def rect(self, x, y, w, h, f, o=1, r=0):
        self.add(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{r}" fill="{f}"{"" if o == 1 else f" fill-opacity=\"{o}\""}/>')

    def circ(self, x, y, r, f, o=1):
        self.add(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r:.1f}" fill="{f}"{"" if o == 1 else f" fill-opacity=\"{o}\""}/>')

    def ell(self, x, y, rx, ry, f, o=1):
        self.add(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{f}"{"" if o == 1 else f" fill-opacity=\"{o}\""}/>')

    def poly(self, pts, f, o=1):
        p = ' '.join(f'{x:.1f},{y:.1f}' for x, y in pts)
        self.add(f'<polygon points="{p}" fill="{f}"{"" if o == 1 else f" fill-opacity=\"{o}\""}/>')

    def path(self, d, f='none', stroke=None, sw=1, o=1):
        s = f' stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round"' if stroke else ''
        self.add(f'<path d="{d}" fill="{f}"{s}{"" if o == 1 else f" fill-opacity=\"{o}\""}/>')

    def line(self, x1, y1, x2, y2, c, sw=1, o=1):
        self.add(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{c}" stroke-width="{sw}" stroke-linecap="round"{"" if o == 1 else f" stroke-opacity=\"{o}\""}/>')

    def sky(self, stops):
        self.rect(0, 0, W, H, self.grad(stops))

    def save(self):
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" preserveAspectRatio="xMidYMid slice">'
               f'<defs>{"".join(self.defs)}</defs>{"".join(self.parts)}</svg>')
        with open(os.path.join(OUT, f'scene_{self.name}.svg'), 'w', encoding='utf-8') as f:
            f.write(svg)


def stars(s, rnd, n, ymax, c=INK):
    for _ in range(n):
        s.circ(rnd.uniform(4, W - 4), rnd.uniform(3, ymax), rnd.choice([.6, .8, 1.1]), c, rnd.choice([.5, .7, .9]))


def forest():
    s, r = S('foret'), random.Random(11)
    s.sky([(0, '#0B2A33', None), (.6, '#123A3A', None), (1, '#0C0820', None)])
    stars(s, r, 22, 60)
    s.circ(250, 38, 17, '#DFFCEF', .95)
    s.circ(250, 38, 30, '#7FE3C0', .12)
    for layer, (col, base, hmin, hmax, step) in enumerate([('#0F4A44', 128, 38, 62, 22), ('#0A3636', 140, 46, 74, 26), ('#07262A', 156, 56, 92, 30)]):
        x = -10 + layer * 9
        while x < W + 20:
            h = r.uniform(hmin, hmax)
            s.rect(x - 2.5, base - h * .35, 5, h * .35 + 30, col)
            s.ell(x, base - h * .55, h * .27, h * .5, col)
            s.ell(x - h * .14, base - h * .42, h * .2, h * .3, col)
            x += step + r.uniform(-4, 6)
    s.rect(0, 150, W, 30, s.grad([(0, '#0A3030', None), (1, '#07161C', None)]))
    for _ in range(26):
        s.circ(r.uniform(6, W - 6), r.uniform(70, 150), 1.4, GOLD, .95)
    s.rect(0, 138, W, 20, s.grad([(0, '#9FFFE0', 0), (1, '#9FFFE0', .22)]))
    s.save()


def savane():
    s, r = S('savane'), random.Random(12)
    s.sky([(0, '#3A1B52', None), (.45, '#C21E78', None), (.75, '#FF8A3D', None), (1, '#FFC83D', None)])
    s.circ(160, 112, 40, '#FFE9A8', .95)
    s.circ(160, 112, 62, '#FFC83D', .22)
    s.path('M0 126 C60 108 110 118 160 122 C220 108 270 116 320 112 L320 180 L0 180Z', '#8A3A2A')
    for _ in range(6):
        x = r.uniform(18, W - 18)
        s.path(f'M{x-12:.1f} 96 q4-7 10 0 q4-7 10 0', stroke='#2A0B23', sw=1.4, o=.8)
    for x, y, k in [(36, 130, 1.0), (276, 128, .85), (104, 134, .6), (222, 136, .55)]:
        s.rect(x - 2 * k, y - 34 * k, 4 * k, 36 * k, '#2A0B23')
        s.ell(x, y - 38 * k, 34 * k, 8 * k, '#2A0B23')
        s.ell(x - 14 * k, y - 32 * k, 16 * k, 5 * k, '#2A0B23')
    s.rect(0, 140, W, 40, s.grad([(0, '#5A2230', None), (1, '#2A0B23', None)]))
    for _ in range(90):
        x, y = r.uniform(0, W), r.uniform(146, 180)
        s.line(x, y, x + r.uniform(-3, 3), y - r.uniform(5, 13), '#3A1230', 1.1)
    s.save()


def resto():
    s, r = S('resto'), random.Random(13)
    s.rect(0, 0, W, H, s.grad([(0, '#3A1B30', None), (1, '#1A0B1F', None)]))
    s.rect(0, 118, W, 62, s.grad([(0, '#4A2A22', None), (1, '#24120F', None)]))
    for i in range(0, W, 22):
        s.line(i, 118, i - 14, 180, '#2A1612', 1.2, .8)
    s.rect(14, 36, 92, 6, '#5A3A2A')
    s.rect(214, 36, 92, 6, '#5A3A2A')
    s.rect(14, 62, 92, 6, '#5A3A2A')
    s.rect(214, 62, 92, 6, '#5A3A2A')
    for base, xs in [(36, (14, 214)), (62, (14, 214))]:
        for x0 in xs:
            for k in range(7):
                c = r.choice([ACC, GOLD, CY, OK, VIOLET, '#FF8A3D'])
                h = r.uniform(14, 24)
                s.rect(x0 + 5 + k * 12.5, base - h, 7, h, c, .85, 2)
                s.rect(x0 + 7.5 + k * 12.5, base - h - 5, 2, 5, c, .85)
    s.path('M0 22 Q80 44 160 24 T320 24', stroke='#2A1612', sw=1.4)
    for k in range(14):
        x = k * 24.6 + 4
        y = 22 + 11 * (1 - abs((k / 13) * 2 - 1)) * .0 + 8 * (1 - ((k / 6.5 - 1) ** 2))
        s.circ(x, y + 4, 8, GOLD, .16)
        s.circ(x, y + 4, 3.2, '#FFE9A8')
    for x in (30, 266):
        s.line(x, 0, x, 88, '#2A1612', 1.2)
        s.add(f'<polygon points="{x-14},96 {x+14},96 {x+7},84 {x-7},84" fill="{GOLD}" fill-opacity=".95"/>')
        s.poly([(x - 14, 96), (x + 14, 96), (x + 40, 180), (x - 40, 180)], GOLD, .06)
    for x in (30, 96, 224, 290):
        s.rect(x - 22, 136, 44, 5, '#7A4A2A', 1, 2)
        s.rect(x - 2, 141, 4, 28, '#5A3A2A')
        s.ell(x, 172, 14, 3, '#000', .3)
    for x in (62, 258):
        s.rect(x - 8, 150, 16, 4, '#4A2A22', 1, 2)
        s.rect(x - 1.5, 154, 3, 18, '#3A1F18')
    s.save()


def street():
    s, r = S('street'), random.Random(14)
    s.rect(0, 0, W, H, s.grad([(0, '#2A2342', None), (1, '#14102B', None)]))
    for yy in range(0, 140, 14):
        off = 0 if (yy // 14) % 2 == 0 else 15
        for xx in range(-off, W, 30):
            s.rect(xx + 1, yy + 1, 28, 12, '#3A3050', .55, 1)
    # graffiti : formes libres sans lettres
    cols = [ACC, CY, GOLD, OK, VIOLET, ACC4]
    for _ in range(9):
        x, y = r.choice([r.uniform(8, 110), r.uniform(210, 312)]), r.uniform(20, 112)
        c = r.choice(cols)
        s.path(f'M{x:.0f} {y:.0f} q{r.uniform(10,30):.0f} {-r.uniform(14,34):.0f} {r.uniform(30,50):.0f} {r.uniform(-6,6):.0f} t{r.uniform(-14,26):.0f} {r.uniform(14,26):.0f}', stroke=c, sw=r.uniform(4, 8), o=.9)
        s.circ(x + r.uniform(-8, 40), y + r.uniform(-10, 26), r.uniform(5, 11), r.choice(cols), .85)
    s.poly([(18, 24), (36, 10), (52, 24), (44, 44), (26, 44)], GOLD, .85)
    s.poly([(268, 28), (292, 14), (306, 36), (284, 52)], CY, .85)
    s.rect(0, 140, W, 40, s.grad([(0, '#2A2540', None), (1, '#0C0820', None)]))
    s.rect(0, 140, W, 3, '#4A4068')
    s.line(10, 52, 310, 52, ACC, 2.4, .9)
    s.line(10, 52, 310, 52, ACC, 7, .18)
    s.line(40, 134, 40, 118, '#14102B', 3)
    s.rect(30, 108, 20, 14, '#14102B')
    s.rect(33, 112, 14, 7, ACC4, .8)
    s.save()


def rue():
    s, r = S('rue'), random.Random(15)
    s.sky([(0, '#1A1450', None), (.7, '#3A1B52', None), (1, '#5A1D5C', None)])
    stars(s, r, 16, 50)
    for side in (0, 1):
        x = 0 if side == 0 else W
        d = 1 if side == 0 else -1
        for i, (bw, bh, col) in enumerate([(54, 150, '#1B1538'), (40, 120, '#241B48'), (34, 96, '#2E2358')]):
            bx = x + d * (i * 38) - (bw if side else 0)
            by = 150 - bh
            s.rect(bx, by, bw, bh + 30, col)
            for wy in range(int(by) + 8, 146, 15):
                for wx in range(int(bx) + 6, int(bx + bw) - 8, 13):
                    on = r.random() < .45
                    s.rect(wx, wy, 7, 9, GOLD if on else '#150F2E', .9 if on else 1, 1)
    s.poly([(0, 180), (320, 180), (230, 118), (90, 118)], '#1A1432')
    s.poly([(120, 180), (200, 180), (172, 118), (148, 118)], '#241C42', .6)
    for y, w in [(126, 2), (138, 3), (156, 5), (176, 7)]:
        s.rect(160 - w / 2, y, w, y / 16, '#FFC83D', .8)
    for x, y in [(58, 120), (262, 120)]:
        s.rect(x - 1.5, y - 38, 3, 52, '#0C0820')
        s.circ(x, y - 40, 5, '#FFE9A8')
        s.circ(x, y - 40, 16, GOLD, .18)
        s.poly([(x - 5, y - 36), (x + 5, y - 36), (x + 22, y + 56), (x - 22, y + 56)], GOLD, .07)
    s.save()


def lagune():
    s, r = S('lagune'), random.Random(16)
    s.sky([(0, '#2A1060', None), (.4, '#C21E78', None), (.62, '#FF8A3D', None), (1, '#FFC83D', None)])
    s.circ(160, 104, 30, '#FFF1C1')
    s.circ(160, 104, 52, '#FFC83D', .22)
    s.rect(0, 104, W, 76, s.grad([(0, '#FF9A4D', None), (.25, '#5A1D5C', None), (1, '#0C0820', None)]))
    for i, y in enumerate(range(110, 176, 6)):
        w = 12 + i * 5
        s.rect(160 - w / 2, y, w, 1.6, '#FFE9A8', .7 - i * .045)
    for y in range(118, 176, 9):
        for _ in range(4):
            x = r.uniform(0, W)
            s.line(x, y, x + r.uniform(10, 24), y, '#FFFFFF', 1, .14)
    for x, y, k, lean in [(36, 128, 1.1, 1), (286, 126, 1.0, -1), (74, 130, .7, 1)]:
        s.path(f'M{x} {y+40} Q{x+lean*6*k} {y} {x+lean*14*k} {y-34*k}', stroke='#1A0B23', sw=3.4 * k)
        tx, ty = x + lean * 14 * k, y - 34 * k
        for a in (-70, -35, 0, 35, 70):
            import math
            ex, ey = tx + 26 * k * math.cos(math.radians(a - 90 + lean * 8)), ty + 20 * k * math.sin(math.radians(a - 90 + lean * 8)) + 12 * k
            s.path(f'M{tx:.1f} {ty:.1f} Q{(tx+ex)/2:.1f} {ty-14*k:.1f} {ex:.1f} {ey:.1f}', stroke='#1A0B23', sw=2.4 * k)
    s.path('M230 148 Q262 160 292 148 L286 156 Q262 164 236 156Z', '#1A0B23')
    s.line(262, 148, 262, 130, '#1A0B23', 1.6)
    s.poly([(262, 131), (276, 144), (262, 144)], '#1A0B23')
    s.save()


def toit():
    s, r = S('toit'), random.Random(17)
    s.sky([(0, '#0C0A2E', None), (.7, '#2A1060', None), (1, '#7A1F5A', None)])
    stars(s, r, 40, 90)
    s.circ(58, 34, 13, '#F4F0FF', .95)
    s.circ(53, 31, 11, '#2A1060')
    x = -6
    while x < W + 10:
        bw, bh = r.uniform(18, 38), r.uniform(40, 96)
        col = r.choice(['#1B1538', '#1F1942', '#241B48'])
        s.rect(x, 150 - bh, bw, bh + 30, col)
        for wy in range(int(150 - bh) + 6, 144, 11):
            for wx in range(int(x) + 4, int(x + bw) - 6, 9):
                if r.random() < .35:
                    s.rect(wx, wy, 4, 5, r.choice([GOLD, CY, ACC4]), .9)
        if r.random() < .3:
            s.line(x + bw / 2, 150 - bh, x + bw / 2, 150 - bh - 16, '#3A3270', 1.2)
            s.circ(x + bw / 2, 150 - bh - 16, 1.6, ACC)
        x += bw + r.uniform(1, 5)
    s.rect(0, 146, W, 34, s.grad([(0, '#2A2448', None), (1, '#0C0820', None)]))
    s.rect(0, 146, W, 4, '#4A4068')
    s.rect(14, 118, 26, 26, '#241B48')
    s.poly([(10, 118), (44, 118), (27, 104)], '#1A1432')
    s.rect(18, 144, 3, 6, '#14102B')
    s.rect(33, 144, 3, 6, '#14102B')
    s.path('M270 146 L270 120 M290 146 L290 120', stroke='#4A4068', sw=2)
    s.path('M268 124 L292 124', stroke='#4A4068', sw=2)
    for i in range(9):
        x = 258 + i * 6
        s.circ(x, 118 + 3 * (1 - ((i - 4) / 4) ** 2), 1.8, GOLD)
    s.save()


def studio():
    s = S('studio')
    s.rect(0, 0, W, H, s.grad([(0, '#241B48', None), (1, '#0C0820', None)]))
    for i in range(8):
        for j in range(3):
            x, y = 8 + i * 40, 12 + j * 34
            s.rect(x, y, 34, 28, '#2A2358', 1, 3)
            s.poly([(x + 4, y + 24), (x + 17, y + 4), (x + 30, y + 24)], '#1A1438', .9)
    s.rect(0, 118, W, 62, s.grad([(0, '#1A1230', None), (1, '#07041A', None)]))
    s.circ(160, 58, 30, ACC, .22)
    s.circ(160, 58, 24, 'none')
    s.path('M160 34 a24 24 0 1 0 .01 0Z', stroke=ACC, sw=4, o=1)
    s.path('M160 34 a24 24 0 1 0 .01 0Z', stroke=ACC, sw=11, o=.16)
    s.circ(160, 58, 8, '#FF3B5C')
    s.circ(160, 58, 18, '#FF3B5C', .16)
    s.rect(14, 136, 292, 16, '#2A2448', 1, 4)
    for k in range(30):
        s.rect(22 + k * 9.4, 139, 4, 8, r_c(k), .95, 1)
    s.rect(30, 108, 40, 28, '#14102B', 1, 3)
    s.rect(34, 112, 32, 20, CY, .35, 2)
    s.rect(250, 108, 40, 28, '#14102B', 1, 3)
    s.rect(254, 112, 32, 20, ACC4, .35, 2)
    s.line(24, 20, 24, 100, '#3A3270', 2)
    s.circ(24, 104, 6, '#3A3270')
    s.save()


def r_c(k):
    return [ACC, CY, GOLD, OK, VIOLET][k % 5]


def marche():
    s, r = S('marche'), random.Random(19)
    s.sky([(0, '#FF8A3D', None), (1, '#C21E78', None)])
    s.rect(0, 120, W, 60, s.grad([(0, '#6A3A22', None), (1, '#2A140F', None)]))
    cols = [ACC, GOLD, CY, OK, VIOLET, '#FF8A3D']
    for x0, y0 in [(-6, 56), (232, 56)]:
        w = 98
        n = 7
        for i in range(n):
            s.poly([(x0 + i * w / n, y0), (x0 + (i + 1) * w / n, y0), (x0 + (i + 1) * w / n + 2, y0 + 20), (x0 + i * w / n - 2, y0 + 20)], cols[i % len(cols)] if i % 2 == 0 else INK, .95)
        s.rect(x0 + 4, y0 + 20, 3, 62, '#2A140F')
        s.rect(x0 + w - 6, y0 + 20, 3, 62, '#2A140F')
        s.rect(x0, y0 + 64, w, 8, '#4A2A1A')
        for k in range(8):
            s.circ(x0 + 12 + k * 11, y0 + 58, 6, r.choice([GOLD, OK, ACC, '#FF8A3D']), .95)
    for x in (112, 160, 208):
        s.line(x, 0, x, 30, '#2A140F', 1)
        s.add(f'<polygon points="{x-7},30 {x+7},30 {x+10},48 {x-10},48" fill="{r.choice([ACC, GOLD, CY])}" fill-opacity=".95"/>')
        s.circ(x, 42, 14, GOLD, .18)
    for i in range(10):
        x = 120 + i * 8
        s.rect(x, 124, 5, 3, r.choice(cols), .8)
    s.save()


def scene():
    s, r = S('scene'), random.Random(20)
    s.rect(0, 0, W, H, s.grad([(0, '#1A0B2E', None), (1, '#07041A', None)]))
    for x, col in [(50, ACC), (110, CY), (210, GOLD), (270, VIOLET)]:
        s.poly([(x - 4, 0), (x + 4, 0), (x + 54, 142), (x - 54, 142)], col, .18)
        s.circ(x, 4, 7, col)
    s.rect(80, 26, 160, 70, '#0C0820', 1, 4)
    s.rect(84, 30, 152, 62, s.grad([(0, '#3A1B52', None), (1, '#C21E78', None)]), 1, 2)
    for k in range(10):
        s.rect(90 + k * 14.4, 76 - (k * 37 % 40), 9, 14 + (k * 37 % 40), r_c(k), .8, 1)
    s.rect(0, 118, W, 14, '#241B48')
    s.rect(0, 118, W, 3, ACC4, .8)
    s.rect(0, 132, W, 48, '#07041A')
    for i in range(34):
        x = i * 10 + r.uniform(-2, 2)
        y = 150 + r.uniform(-8, 6)
        s.circ(x, y, r.uniform(7, 10), '#14102B')
        s.rect(x - 8, y + 6, 16, 30, '#14102B')
        if r.random() < .35:
            s.line(x + 5, y + 4, x + 9, y - 16, '#14102B', 3)
            s.circ(x + 9, y - 19, 3, '#14102B')
    for k in range(18):
        s.circ(r.uniform(4, W - 4), r.uniform(130, 170), 1.2, INK, .35)
    s.save()


def club():
    s, r = S('club'), random.Random(21)
    s.rect(0, 0, W, H, s.grad([(0, '#1A0B2E', None), (1, '#0C0820', None)]))
    s.line(160, 0, 160, 24, '#4A4068', 1.4)
    s.circ(160, 38, 16, '#CFC8F0')
    for a in range(0, 360, 30):
        s.line(160, 38, 160 + 16 * __import__('math').cos(__import__('math').radians(a)), 38 + 16 * __import__('math').sin(__import__('math').radians(a)), '#6A5CA8', .8)
    for a in range(-80, 90, 20):
        import math
        c = r_c(a // 20)
        x2 = 160 + 230 * math.sin(math.radians(a))
        s.poly([(160, 40), (x2 - 10, 190), (x2 + 10, 190)], c, .11)
    for k in range(12):
        s.circ(r.uniform(6, W - 6), r.uniform(10, 120), r.uniform(1, 2.4), r_c(k), .8)
    s.rect(0, 132, W, 48, s.grad([(0, '#2A1060', None), (1, '#0C0820', None)]))
    for i in range(12):
        for j in range(3):
            c = r_c(i + j)
            s.rect(i * 27 + 2, 136 + j * 15, 24, 11, c, .35 + .08 * ((i + j) % 3), 2)
    for x in (16, 304):
        s.rect(x - 14, 64, 28, 66, '#14102B', 1, 3)
        s.circ(x, 84, 8, '#2A2448')
        s.circ(x, 110, 11, '#2A2448')
    s.save()


def quartier():
    s, r = S('quartier'), random.Random(22)
    s.sky([(0, '#5A1D5C', None), (.5, '#FF6B6B', None), (.8, '#FFC83D', None), (1, '#FFE9A8', None)])
    s.circ(64, 98, 26, '#FFF1C1', .9)
    x = -4
    cols = ['#7A2A3A', '#5A2238', '#8A3A2A', '#3A1B52', '#6A2A4A']
    while x < W:
        w, h = r.uniform(26, 44), r.uniform(34, 62)
        c = r.choice(cols)
        s.rect(x, 140 - h, w, h + 10, c)
        s.poly([(x - 3, 140 - h), (x + w + 3, 140 - h), (x + w, 134 - h), (x, 134 - h)], '#B07A5A')
        for k in range(int(w // 8)):
            s.line(x + 4 + k * 8, 134 - h, x + 4 + k * 8, 140 - h, '#8A5A3A', 1)
        s.rect(x + w * .35, 140 - h * .55, w * .3, h * .55, '#2A0B23')
        if r.random() < .6:
            s.rect(x + 4, 140 - h * .8, 7, 8, GOLD, .9)
        x += w + r.uniform(0, 3)
    s.path('M0 40 Q80 60 160 44 T320 48', stroke='#2A0B23', sw=1)
    s.path('M0 50 Q90 72 170 52 T320 58', stroke='#2A0B23', sw=1)
    s.rect(0, 140, W, 40, s.grad([(0, '#6A3A22', None), (1, '#2A140F', None)]))
    for i in range(9):
        s.rect(i * 38 + 4, 160, 20, 3, '#B07A5A', .55, 1)
    s.rect(224, 118, 54, 22, '#14102B', 1, 5)
    s.rect(230, 108, 38, 14, '#14102B', 1, 4)
    for k in range(4):
        s.rect(234 + k * 8.5, 111, 6, 8, GOLD, .8, 1)
    s.circ(236, 142, 6, '#07041A')
    s.circ(264, 142, 6, '#07041A')
    s.save()


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for f in (forest, savane, resto, street, rue, lagune, toit, studio, marche, scene, club, quartier):
        f()
    print('12 décors dans', OUT)
