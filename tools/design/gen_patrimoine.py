#!/usr/bin/env python3
"""Illustrations originales des biens du patrimoine sans photo (RAP EMPIRE) : 13 vignettes 320 x 240.
Usage : python3 tools/design/gen_patrimoine.py   (depuis la racine du dépôt)  ->  assets/patrimoine/<id>.svg
SVG pur, sans filtre ni <text>, palette du jeu, aucun lieu ni marque réels."""
import os, math, random

OUT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'assets', 'patrimoine'))
W, H = 320, 240
BG, DEEP, S1, S2, LINE = '#14102B', '#0C0820', '#1F1942', '#2B2459', '#3A3270'
ACC, ACC4, ACC7, VIOLET, GOLD, CY, OK, INK = '#F43F9D', '#FF6BB8', '#C21E78', '#8B5CF6', '#FFC83D', '#3CD6F2', '#3DDC97', '#F8F7FF'


class S:
    def __init__(self, name):
        self.name, self.k, self.defs, self.p = name, 0, [], []

    def g(self, stops, x2=0, y2=1):
        self.k += 1
        i = f'{self.name}{self.k}'
        st = ''.join(f'<stop offset="{o}" stop-color="{c}"{"" if a is None else f" stop-opacity=\"{a}\""}/>' for o, c, a in stops)
        self.defs.append(f'<linearGradient id="{i}" x1="0" y1="0" x2="{x2}" y2="{y2}">{st}</linearGradient>')
        return f'url(#{i})'

    def a(self, s): self.p.append(s)

    def rect(self, x, y, w, h, f, o=1, r=0, st=None, sw=0):
        self.a(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{r}" fill="{f}"' + ('' if o == 1 else f' fill-opacity="{o}"') + (f' stroke="{st}" stroke-width="{sw}"' if st else '') + '/>')

    def circ(self, x, y, r, f, o=1, st=None, sw=0):
        self.a(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r:.1f}" fill="{f}"' + ('' if o == 1 else f' fill-opacity="{o}"') + (f' stroke="{st}" stroke-width="{sw}"' if st else '') + '/>')

    def ell(self, x, y, rx, ry, f, o=1):
        self.a(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{f}"' + ('' if o == 1 else f' fill-opacity="{o}"') + '/>')

    def poly(self, pts, f, o=1, st=None, sw=0):
        self.a('<polygon points="' + ' '.join(f'{x:.1f},{y:.1f}' for x, y in pts) + f'" fill="{f}"' + ('' if o == 1 else f' fill-opacity="{o}"') + (f' stroke="{st}" stroke-width="{sw}" stroke-linejoin="round"' if st else '') + '/>')

    def path(self, d, f='none', st=None, sw=1, o=1):
        self.a(f'<path d="{d}" fill="{f}"' + (f' stroke="{st}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"' if st else '') + ('' if o == 1 else f' fill-opacity="{o}"') + '/>')

    def line(self, x1, y1, x2, y2, c, sw=1, o=1):
        self.a(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{c}" stroke-width="{sw}" stroke-linecap="round"' + ('' if o == 1 else f' stroke-opacity="{o}"') + '/>')

    def backdrop(self, top, bot, ground=None, gy=190):
        self.rect(0, 0, W, H, self.g([(0, top, None), (1, bot, None)]))
        if ground:
            self.rect(0, gy, W, H - gy, self.g([(0, ground[0], None), (1, ground[1], None)]))

    def save(self):
        svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" preserveAspectRatio="xMidYMid slice"><defs>{"".join(self.defs)}</defs>{"".join(self.p)}</svg>'
        open(os.path.join(OUT, f'{self.name}.svg'), 'w', encoding='utf-8').write(svg)


def windows(s, x, y, cols, rows, w, h, gx, gy, lit=.5, seed=1, glass=CY):
    r = random.Random(seed)
    for i in range(cols):
        for j in range(rows):
            on = r.random() < lit
            s.rect(x + i * gx, y + j * gy, w, h, GOLD if on else glass, .95 if on else .45, 2)


def wheel(s, x, y, r, tire='#07041A', rim='#B6B0DD'):
    s.circ(x, y, r, tire)
    s.circ(x, y, r * .62, rim)
    s.circ(x, y, r * .5, '#2B2459')
    for a in range(0, 360, 60):
        s.line(x, y, x + r * .5 * math.cos(math.radians(a)), y + r * .5 * math.sin(math.radians(a)), rim, 1.6)
    s.circ(x, y, r * .12, rim)


def studiomeuble():
    s = S('studiomeuble'); s.backdrop('#3A1B52', '#14102B', ('#2A2040', '#14102B'), 176)
    s.rect(40, 40, 240, 136, '#241B48', 1, 4, LINE, 3)
    s.rect(52, 52, 80, 70, s.g([(0, '#FF8A3D', None), (1, '#C21E78', None)]), 1, 3)
    s.circ(98, 96, 14, '#FFE9A8'); s.rect(52, 112, 80, 10, '#3A1B52')
    s.line(92, 52, 92, 122, '#14102B', 3); s.line(52, 87, 132, 87, '#14102B', 3)
    s.rect(150, 62, 110, 40, '#8B5CF6', 1, 8); s.rect(150, 96, 110, 32, '#6A45C9', 1, 8)
    s.rect(156, 66, 26, 22, ACC4, 1, 6); s.rect(188, 66, 26, 22, GOLD, 1, 6)
    s.rect(160, 128, 6, 14, '#14102B'); s.rect(244, 128, 6, 14, '#14102B')
    s.rect(60, 140, 60, 8, '#4A3A28', 1, 2); s.rect(66, 148, 5, 28, '#4A3A28'); s.rect(109, 148, 5, 28, '#4A3A28')
    s.rect(78, 128, 26, 12, CY, .8, 2)
    s.rect(268, 76, 4, 100, '#14102B'); s.poly([(256, 80), (284, 80), (278, 64), (262, 64)], GOLD, .95)
    s.poly([(256, 80), (284, 80), (310, 176), (230, 176)], GOLD, .08)
    s.rect(200, 150, 50, 26, '#2B2459', 1, 3); s.rect(204, 154, 42, 18, ACC, .7, 2)
    s.save()


def villa():
    s = S('villa'); s.backdrop('#2A1060', '#C21E78'); s.rect(0, 120, W, 120, s.g([(0, '#FF8A3D', None), (.2, '#5A1D5C', None), (1, '#0C0820', None)]))
    s.circ(250, 78, 28, '#FFF1C1'); s.circ(250, 78, 46, GOLD, .2)
    s.rect(0, 170, W, 70, s.g([(0, '#0E6B8A', None), (1, '#07263A', None)]))
    for y in range(176, 236, 9): s.line(10, y, 310, y, INK, 1, .1)
    s.rect(40, 100, 240, 80, '#F8F7FF', 1, 2); s.rect(40, 100, 240, 80, '#241B48', .15)
    s.rect(30, 92, 260, 12, '#2B2459', 1, 3)
    s.rect(130, 56, 100, 48, '#E8E3FF', 1, 2); s.rect(122, 50, 116, 9, '#2B2459', 1, 3)
    s.rect(54, 116, 60, 50, CY, .85, 3); s.rect(134, 70, 80, 28, CY, .8, 3); s.rect(136, 116, 46, 64, '#14102B', 1, 3); s.rect(204, 116, 60, 50, CY, .85, 3)
    s.poly([(54, 116), (114, 116), (54, 166)], INK, .25); s.poly([(204, 116), (264, 116), (204, 166)], INK, .25)
    s.rect(40, 178, 240, 6, '#B6B0DD'); s.rect(60, 184, 200, 8, '#3CD6F2', .6, 2)
    for x, y in [(22, 150), (300, 154)]:
        s.rect(x - 2, y, 4, 40, '#3A2A28'); s.ell(x, y - 4, 20, 9, '#0A4A3A'); s.ell(x - 9, y + 4, 14, 6, '#0F6A4A'); s.ell(x + 9, y + 3, 14, 6, '#0F6A4A')
    s.save()


def penthouse():
    s = S('penthouse'); s.backdrop('#0C0A2E', '#7A1F5A')
    r = random.Random(3)
    for _ in range(40): s.circ(r.uniform(4, 316), r.uniform(4, 110), r.choice([.7, 1, 1.3]), INK, r.choice([.4, .7, .9]))
    s.circ(268, 40, 14, '#F4F0FF')
    for x, h in [(10, 110), (52, 150), (240, 120), (272, 150), (292, 90)]:
        s.rect(x, 228 - h, 34, h, '#1B1538'); windows(s, x + 5, 228 - h + 8, 3, int(h / 18) - 1, 6, 8, 10, 16, .35, x)
    s.rect(100, 56, 120, 172, '#2B2459', 1, 2, LINE, 2)
    s.rect(92, 48, 136, 18, '#3A1B52', 1, 4); s.rect(88, 44, 144, 6, ACC, 1, 3)
    windows(s, 110, 76, 5, 7, 14, 12, 21, 21, .5, 9)
    s.rect(106, 56, 108, 22, CY, .35, 3); s.rect(112, 60, 96, 14, GOLD, .5, 3)
    s.rect(100, 56, 120, 4, GOLD); s.line(160, 44, 160, 22, '#4A4068', 2); s.circ(160, 20, 3, ACC)
    s.rect(0, 226, W, 14, '#07041A')
    s.save()


def local():
    s = S('local'); s.backdrop('#FF8A3D', '#C21E78', ('#4A2A22', '#24120F'), 196)
    s.rect(40, 96, 240, 104, '#3A1B52', 1, 3, '#FFC83D', 3)
    for i in range(8):
        s.poly([(40 + i * 30, 96), (70 + i * 30, 96), (76 + i * 30, 126), (34 + i * 30, 126)], ACC if i % 2 == 0 else INK, .96)
    s.rect(34, 90, 252, 10, '#2A0B23', 1, 3)
    s.rect(54, 138, 120, 62, CY, .5, 3, GOLD, 2); s.line(114, 138, 114, 200, GOLD, 2)
    for i in range(4): s.rect(62 + i * 28, 168, 20, 24, [ACC, GOLD, OK, VIOLET][i], .9, 3)
    s.rect(196, 138, 66, 62, '#14102B', 1, 3); s.circ(250, 170, 3, GOLD)
    s.rect(200, 108, 60, 22, '#14102B', 1, 3); s.rect(206, 114, 48, 10, GOLD, .9, 3)
    s.path('M40 96 Q160 80 280 96', st='#14102B', sw=1)
    for x in (60, 100, 140, 180, 220, 260): s.circ(x, 86 + abs(x - 160) / 40, 3, '#FFE9A8')
    s.save()


def immeuble():
    s = S('immeuble'); s.backdrop('#1A1450', '#5A1D5C', ('#241B48', '#0C0820'), 204)
    r = random.Random(5)
    for _ in range(26): s.circ(r.uniform(4, 316), r.uniform(4, 90), 1, INK, .7)
    s.rect(60, 40, 200, 170, '#3A2A58', 1, 3, LINE, 3)
    s.rect(54, 34, 212, 12, '#2B2459', 1, 3)
    for j in range(5):
        s.rect(60, 54 + j * 30, 200, 4, '#241B48')
        for i in range(6):
            on = r.random() < .6
            s.rect(72 + i * 31, 62 + j * 30, 20, 20, GOLD if on else CY, .95 if on else .4, 2)
            s.rect(70 + i * 31, 82 + j * 30, 24, 3, '#14102B')
    s.rect(140, 170, 40, 40, '#14102B', 1, 3); s.rect(134, 164, 52, 8, ACC)
    s.rect(0, 204, W, 36, '#0C0820'); s.rect(0, 204, W, 3, '#4A4068')
    s.save()


def scooter():
    s = S('scooter'); s.backdrop('#3A1B52', '#14102B', ('#2A2040', '#0C0820'), 190)
    s.ell(160, 196, 110, 8, '#000', .35)
    wheel(s, 78, 172, 24); wheel(s, 244, 172, 24)
    s.path('M78 172 L96 130 L130 130 L136 172 L220 172', st=ACC, sw=9)
    s.path('M96 130 L88 104', st='#B6B0DD', sw=5); s.path('M72 104 L104 104', st='#B6B0DD', sw=6)
    s.path('M206 172 L236 96 L252 96', st='#B6B0DD', sw=7); s.path('M232 100 L266 100', st=INK, sw=6)
    s.rect(120, 108, 74, 20, '#14102B', 1, 10); s.rect(126, 112, 62, 8, '#4A3A28', 1, 4)
    s.rect(136, 134, 70, 26, ACC, 1, 12); s.rect(146, 140, 30, 8, ACC4, 1, 4)
    s.circ(272, 100, 6, GOLD); s.poly([(272, 100), (310, 118), (310, 84)], GOLD, .12)
    s.rect(150, 172, 48, 8, '#B6B0DD', 1, 3)
    s.save()


def car(s, body, roof, wins, x0=30, y0=120, wide=260, tall=False):
    s.ell(160, 200, 130, 9, '#000', .38)
    top = y0 - (46 if tall else 38)
    s.path(f'M{x0} {y0+44} L{x0+4} {y0+20} Q{x0+10} {y0+8} {x0+40} {y0+2} L{x0+78} {top+6} Q{x0+92} {top} {x0+110} {top} L{x0+170} {top} Q{x0+190} {top+2} {x0+204} {y0} L{x0+246} {y0+8} Q{x0+wide-0} {y0+14} {x0+wide-0} {y0+30} L{x0+wide-0} {y0+44}Z', body, st='#07041A', sw=2)
    s.path(f'M{x0+84} {y0-2} L{x0+98} {top+8} L{x0+150} {top+8} L{x0+150} {y0-2}Z', wins, o=.9)
    s.path(f'M{x0+156} {y0-2} L{x0+156} {top+8} L{x0+172} {top+8} Q{x0+188} {top+10} {x0+196} {y0-2}Z', wins, o=.9)
    s.line(x0 + 153, top + 8, x0 + 153, y0 + 30, '#07041A', 2)
    s.rect(x0 + 6, y0 + 20, 22, 8, GOLD, .95, 3); s.rect(x0 + wide - 24, y0 + 18, 20, 8, ACC, .95, 3)
    s.rect(x0 + 100, y0 + 24, 14, 4, '#07041A', 1, 2); s.rect(x0 + 160, y0 + 24, 14, 4, '#07041A', 1, 2)
    s.rect(x0 + 2, y0 + 40, wide - 4, 8, '#14102B')
    wheel(s, x0 + 56, y0 + 52, 24); wheel(s, x0 + wide - 60, y0 + 52, 24)


def suv():
    s = S('suv'); s.backdrop('#1A2A4A', '#0C0820', ('#2A2438', '#0C0820'), 196)
    s.rect(0, 150, W, 2, CY, .15)
    car(s, s.g([(0, '#2B4A8A', None), (1, '#14264A', None)]), '#14264A', CY, tall=True)
    s.rect(110, 78, 100, 5, '#B6B0DD', 1, 2); s.rect(116, 70, 88, 4, '#B6B0DD', 1, 2)
    s.save()


def berline():
    s = S('berline'); s.backdrop('#3A1B52', '#0C0820', ('#241B48', '#07041A'), 196)
    s.circ(250, 60, 30, VIOLET, .15)
    car(s, s.g([(0, '#F43F9D', None), (1, '#7A1060', None)]), '#7A1060', '#2A1060')
    s.path('M70 146 Q160 134 280 146', st=INK, sw=2, o=.35)
    s.save()


def chaine():
    s = S('chaine'); s.backdrop('#2A1060', '#0C0820')
    s.circ(160, 120, 110, VIOLET, .12)
    for i in range(34):
        t = i / 33
        x = 62 + 196 * t
        y = 30 + 150 * (1 - (2 * t - 1) ** 2) * .85 + 0
        y = 30 + 130 * (1 - (2 * t - 1) ** 2)
        s.ell(x, y, 9, 6, 'none'); s.a(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="9" ry="6" fill="none" stroke="#D8D2F5" stroke-width="3.2" transform="rotate({(-60 + 120 * t) * (1 if i % 2 else -1):.0f} {x:.1f} {y:.1f})"/>')
    s.circ(160, 170, 24, '#B6B0DD', 1, '#F8F7FF', 3); s.circ(160, 170, 17, '#2B2459'); s.path('M150 176 L160 160 L170 176Z', CY)
    s.circ(142, 154, 4, INK, .8)
    s.save()


def bracelet():
    s = S('bracelet'); s.backdrop('#1A1450', '#0C0820')
    s.circ(160, 130, 120, CY, .1)
    s.a(f'<ellipse cx="160" cy="130" rx="100" ry="64" fill="none" stroke="#B6B0DD" stroke-width="26"/>')
    s.a(f'<ellipse cx="160" cy="130" rx="100" ry="64" fill="none" stroke="#F8F7FF" stroke-width="3" stroke-dasharray="10 8" opacity=".7"/>')
    s.a(f'<ellipse cx="160" cy="130" rx="113" ry="74" fill="none" stroke="#6A5CA8" stroke-width="3" opacity=".6"/>')
    for a in range(0, 360, 30):
        x, y = 160 + 100 * math.cos(math.radians(a)), 130 + 64 * math.sin(math.radians(a))
        s.circ(x, y, 4, CY if a % 60 == 0 else INK, .95)
    s.poly([(160, 56), (176, 70), (160, 94), (144, 70)], CY, .9, INK, 2); s.line(144, 70, 176, 70, INK, 2)
    s.save()


def diamantrose():
    s = S('diamantrose'); s.backdrop('#3A0B3A', '#0C0820')
    s.circ(160, 130, 120, ACC, .14); s.circ(160, 130, 80, ACC4, .1)
    s.poly([(80, 96), (116, 52), (204, 52), (240, 96), (160, 200)], ACC4, .85, GOLD, 4)
    s.poly([(80, 96), (240, 96), (160, 200)], ACC, .55)
    for pts, o in [([(116, 52), (140, 96), (80, 96)], .18), ([(204, 52), (180, 96), (240, 96)], .1), ([(116, 52), (160, 96), (140, 96)], .3), ([(204, 52), (160, 96), (180, 96)], .22)]: s.poly(pts, INK, o)
    for a, b in [((80, 96), (160, 200)), ((240, 96), (160, 200)), ((140, 96), (160, 200)), ((180, 96), (160, 200)), ((116, 52), (140, 96)), ((204, 52), (180, 96)), ((116, 52), (160, 96)), ((204, 52), (160, 96))]:
        s.line(a[0], a[1], b[0], b[1], INK, 1.6, .75)
    s.line(80, 96, 240, 96, INK, 2, .8)
    for x, y, r in [(66, 60, 5), (260, 44, 4), (250, 170, 6), (60, 170, 4)]:
        s.poly([(x, y - r * 2), (x + r * .6, y - r * .6), (x + r * 2, y), (x + r * .6, y + r * .6), (x, y + r * 2), (x - r * .6, y + r * .6), (x - r * 2, y), (x - r * .6, y - r * .6)], INK, .9)
    s.save()


def cabinepro():
    s = S('cabinepro'); s.backdrop('#241B48', '#0C0820', ('#1A1230', '#07041A'), 200)
    for i in range(8):
        for j in range(4):
            x, y = 14 + i * 38, 14 + j * 44
            s.rect(x, y, 34, 40, '#2A2358', 1, 3); s.poly([(x + 4, y + 36), (x + 17, y + 6), (x + 30, y + 36)], '#1A1438', .9)
    s.rect(96, 52, 128, 150, '#14102B', 1, 6, VIOLET, 4)
    s.rect(106, 62, 108, 100, s.g([(0, '#3A1B52', None), (1, '#1F1942', None)]), 1, 4)
    s.circ(160, 104, 24, 'none', 1, '#B6B0DD', 3); s.rect(158, 80, 4, 30, '#B6B0DD'); s.circ(160, 120, 14, '#14102B', 1, ACC, 3)
    s.rect(110, 168, 100, 16, '#2B2459', 1, 3)
    for k in range(10): s.rect(116 + k * 9, 172, 5, 8, [ACC, CY, GOLD, OK, VIOLET][k % 5], .95, 1)
    s.circ(246, 66, 9, '#FF3B5C'); s.circ(246, 66, 18, '#FF3B5C', .2)
    s.rect(0, 200, W, 40, '#07041A')
    s.save()


def regie():
    s = S('regie'); s.backdrop('#1A1450', '#0C0820', ('#14102B', '#07041A'), 196)
    s.rect(30, 30, 260, 70, '#07041A', 1, 6, VIOLET, 3)
    for i, c in enumerate([CY, ACC, GOLD, OK]):
        s.rect(40 + i * 62, 40, 56, 50, s.g([(0, c, None), (1, '#14102B', None)]), .55, 4)
        for k in range(5): s.rect(46 + i * 62 + k * 10, 82 - ((k * 13 + i * 7) % 34), 6, 8 + ((k * 13 + i * 7) % 34), c, .95, 1)
    s.poly([(20, 200), (300, 200), (284, 120), (36, 120)], '#241B48', 1, LINE, 3)
    s.poly([(36, 120), (284, 120), (280, 132), (40, 132)], '#4A4068')
    for r in range(3):
        y = 140 + r * 18
        for k in range(14):
            x = 54 + k * 16.5 + r * -2
            s.rect(x, y, 6, 12, '#07041A', 1, 2)
            s.rect(x - 1, y + 2 + ((k * 5 + r * 3) % 8), 8, 4, [ACC, CY, GOLD, '#F8F7FF'][k % 4], 1, 1)
    for x in (62, 258): s.circ(x, 112, 8, '#14102B', 1, GOLD, 2); s.rect(x - 1, 104, 2, 8, GOLD)
    s.rect(0, 200, W, 40, '#07041A')
    s.save()


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for f in (studiomeuble, villa, penthouse, local, immeuble, scooter, suv, berline, chaine, bracelet, diamantrose, cabinepro, regie):
        f()
    print('13 illustrations dans', OUT)
