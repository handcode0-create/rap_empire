#!/usr/bin/env python3
"""Illustrations originales des articles de merchandising (RAP EMPIRE) : 8 vignettes 320 x 240.
Usage : python3 tools/design/gen_merch.py   (depuis la racine du depot)  ->  assets/merch/<id>.svg
SVG pur, sans filtre ni <text>, palette du jeu, aucun logo ni marque reels (motifs generiques : eclair, cauri, disque)."""
import os, math, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_patrimoine import S, W, H, BG, DEEP, S1, S2, LINE, ACC, ACC4, ACC7, VIOLET, GOLD, CY, OK, INK  # noqa: E402

import gen_patrimoine  # noqa: E402
OUT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'assets', 'merch'))
gen_patrimoine.OUT = OUT  # S.save() ecrit dans le dossier courant de ce module


def stage(s, top, bot, glow):
    """Fond studio photo : degrade, halo derriere le produit, sol sombre."""
    s.rect(0, 0, W, H, s.g([(0, top, None), (1, bot, None)]))
    s.ell(160, 118, 130, 96, glow, .16)
    s.ell(160, 118, 84, 62, glow, .14)
    s.rect(0, 206, W, 34, s.g([(0, '#0C0820', .0), (1, '#07041A', 1)]))


def shadow(s, cx=160, y=210, rx=84):
    s.ell(cx, y, rx, 9, '#000000', .38)


def bolt(s, cx, cy, k, f=ACC):
    s.poly([(cx - 6 * k, cy - 14 * k), (cx + 8 * k, cy - 14 * k), (cx + 1 * k, cy - 2 * k), (cx + 9 * k, cy - 2 * k), (cx - 8 * k, cy + 16 * k), (cx - 3 * k, cy + 3 * k), (cx - 10 * k, cy + 3 * k)], f)


def cowrie(s, cx, cy, rx, ry, f=GOLD, slit='#14102B'):
    s.ell(cx, cy, rx, ry, f)
    s.ell(cx - rx * .25, cy - ry * .3, rx * .55, ry * .28, '#FFFFFF', .28)
    s.path(f'M{cx - rx * .62:.1f},{cy:.1f} Q{cx:.1f},{cy - ry * .28:.1f} {cx + rx * .62:.1f},{cy:.1f}', st=slit, sw=max(2, rx * .09))
    for i in range(-3, 4):
        x = cx + i * rx * .17
        s.line(x, cy - ry * .2, x, cy + ry * .2, slit, max(1.2, rx * .04), .7)


def draw_tshirt(s, body, trim, print_f=GOLD):
    p = 'M108,56 L140,44 Q160,68 180,44 L212,56 L256,92 L230,118 L208,101 L208,198 L112,198 L112,101 L90,118 L64,92 Z'
    s.path(p, s.g([(0, body, None), (1, trim, None)]), '#07041A', 2.5)
    s.path('M140,44 Q160,68 180,44 Q160,80 140,44 Z', trim, '#07041A', 2)
    s.path('M112,101 L112,198 M208,101 L208,198', st='#07041A', sw=1.2, o=1)
    s.path('M92,114 L112,101 M228,114 L208,101', st='#000000', sw=2, o=1)
    s.circ(160, 128, 31, print_f, .95)
    s.circ(160, 128, 31, 'none', st='#14102B', sw=2.5)
    bolt(s, 160, 128, 1.15, ACC7)
    s.path('M118,186 L202,186', st='#000000', sw=1.4, o=1)


def draw_hoodie(s, body, trim):
    s.path('M114,74 L142,60 L178,60 L206,74 L254,160 L228,176 L206,128 L206,204 L114,204 L114,128 L92,176 L66,160 Z', s.g([(0, body, None), (1, trim, None)]), '#07041A', 2.5)
    s.path('M126,66 Q160,16 194,66 Q160,92 126,66 Z', trim, '#07041A', 2.5)
    s.path('M138,66 Q160,36 182,66 Q160,84 138,66 Z', '#0C0820', None, 0)
    s.line(150, 82, 148, 112, INK, 2.6); s.line(170, 82, 172, 112, INK, 2.6)
    s.circ(148, 114, 3, GOLD); s.circ(172, 114, 3, GOLD)
    s.path('M128,164 L192,164 L202,196 L118,196 Z', trim, '#07041A', 2)
    s.line(160, 164, 160, 196, '#07041A', 1.2)
    s.circ(160, 136, 14, GOLD, .95); cowrie(s, 160, 136, 9, 6, '#14102B', GOLD)
    s.path('M92,176 L114,168 M228,176 L206,168', st='#07041A', sw=3, o=1)


def draw_cap(s, body, brim, patch=GOLD):
    s.path('M82,148 Q84,70 160,66 Q238,70 240,148 Q160,160 82,148 Z', s.g([(0, body, None), (1, '#07041A', None)], 0, 1.4), '#07041A', 2.5)
    s.path('M160,66 Q138,106 142,152 M160,66 Q182,106 178,152', st='#07041A', sw=1.6, o=1)
    s.circ(160, 66, 6, brim, 1, '#07041A', 2)
    s.path('M96,150 Q170,164 252,152 Q262,184 190,190 Q124,194 96,150 Z', brim, '#07041A', 2.5)
    s.path('M110,160 Q172,174 244,160', st='#000000', sw=1.4, o=1)
    s.circ(160, 112, 17, patch, .97); s.circ(160, 112, 17, 'none', st='#14102B', sw=2)
    bolt(s, 160, 112, .68, ACC7)


def draw_vinyl_record(s, cx, cy, r, label=ACC):
    s.circ(cx, cy, r, '#07041A', 1, '#2B2459', 2)
    for k in range(1, 7):
        s.circ(cx, cy, r * (.34 + k * .092), 'none', st='#3A3270', sw=1.1)
    s.path(f'M{cx - r * .7:.1f},{cy - r * .5:.1f} Q{cx:.1f},{cy - r * .95:.1f} {cx + r * .7:.1f},{cy - r * .5:.1f}', st='#FFFFFF', sw=3, o=1)
    s.circ(cx, cy, r * .3, label)
    s.circ(cx, cy, r * .3, 'none', st='#14102B', sw=2)
    s.circ(cx, cy, r * .045, '#07041A')


def draw_cd(s, cx, cy, r):
    s.circ(cx, cy, r, '#E9E6FF', 1, '#B6B0DD', 2)
    cols = [CY, VIOLET, ACC, GOLD, OK, CY]
    for i, c in enumerate(cols):
        a0, a1 = math.radians(-70 + i * 52), math.radians(-70 + (i + 1) * 52)
        s.poly([(cx + r * .3 * math.cos(a0), cy + r * .3 * math.sin(a0)), (cx + r * .96 * math.cos(a0), cy + r * .96 * math.sin(a0)),
                (cx + r * .96 * math.cos(a1), cy + r * .96 * math.sin(a1)), (cx + r * .3 * math.cos(a1), cy + r * .3 * math.sin(a1))], c, .32)
    s.circ(cx, cy, r * .3, '#F8F7FF', 1, '#B6B0DD', 1.5)
    s.circ(cx, cy, r * .13, '#14102B')


def vue(name, top, bot, glow, fn, rot=0):
    s = S(name); stage(s, top, bot, glow); shadow(s); fn(s); s.save()


def tshirt():
    vue('tshirt', '#3A1B52', '#14102B', ACC, lambda s: draw_tshirt(s, '#F8F7FF', '#B6B0DD'))


def hoodie():
    vue('hoodie', '#1A1450', '#0C0820', VIOLET, lambda s: draw_hoodie(s, '#8B5CF6', '#4C2FA8'), )


def casquette():
    vue('casquette', '#3A1B52', '#14102B', GOLD, lambda s: draw_cap(s, '#14102B', ACC), )


def cd():
    def f(s):
        s.rect(52, 52, 148, 148, '#241B48', 1, 8, LINE, 3)
        s.rect(60, 60, 132, 132, s.g([(0, ACC, None), (1, VIOLET, None)]), 1, 4)
        s.circ(126, 112, 34, GOLD, .95); cowrie(s, 126, 112, 22, 15, '#14102B', GOLD)
        s.rect(60, 160, 132, 32, '#14102B', .78, 0)
        for k in range(6): s.rect(70 + k * 20, 172 + (k * 5) % 7, 8, 10 - (k * 5) % 7 + 2, CY, .9, 1)
        s.rect(52, 52, 14, 148, '#000000', .28, 8)
        draw_cd(s, 208, 128, 62)
    vue('cd', '#14102B', '#0C0820', CY, f)


def vinyle():
    def f(s):
        draw_vinyl_record(s, 216, 124, 70)
        s.rect(50, 52, 152, 152, s.g([(0, '#FFC83D', None), (1, '#F43F9D', None)], 1, 1), 1, 6, '#07041A', 3)
        s.circ(126, 116, 44, '#14102B', .85)
        s.circ(126, 116, 30, 'none', st=GOLD, sw=3)
        bolt(s, 126, 116, 1.6, GOLD)
        s.rect(50, 168, 152, 36, '#14102B', .85, 0)
        for k in range(8): s.rect(62 + k * 17, 178 + (k * 3) % 5, 9, 18 - (k * 3) % 5, [ACC, CY, GOLD, OK][k % 4], .95, 1)
    vue('vinyle', '#2B1B52', '#0C0820', GOLD, f)


def affiche():
    def f(s):
        s.rect(88, 20, 144, 188, '#F8F7FF', 1, 3, '#07041A', 3)
        s.rect(97, 29, 126, 170, s.g([(0, '#FF8A3D', None), (0.55, ACC, None), (1, '#3A1B52', None)]), 1, 2)
        s.circ(160, 92, 34, '#FFE9A8')
        s.circ(160, 92, 34, 'none', st=GOLD, sw=2)
        for i, (x, w, h) in enumerate([(97, 20, 52), (119, 16, 74), (137, 22, 42), (161, 18, 82), (181, 20, 58), (203, 20, 66)]):
            s.rect(x, 199 - h, w, h, '#14102B', 1, 1)
            for j in range(h // 14): s.rect(x + 4, 199 - h + 6 + j * 14, 4, 6, GOLD, .9, 1)
        s.rect(97, 150, 126, 8, '#14102B', .35)
        s.rect(114, 168, 92, 6, INK, .9, 2); s.rect(130, 180, 60, 5, INK, .6, 2)
        s.poly([(78, 38), (104, 28), (112, 44), (86, 54)], '#FFC83D', .75)
        s.poly([(242, 190), (216, 204), (208, 190), (234, 178)], '#FFC83D', .75)
    vue('affiche', '#1A1450', '#0C0820', ACC, f)


def tote():
    def f(s):
        s.path('M120,62 Q120,16 160,16 Q200,16 200,62', st='#B6B0DD', sw=7, o=1)
        s.path('M120,62 Q120,16 160,16 Q200,16 200,62', st='#07041A', sw=2, o=1)
        s.path('M96,66 L224,66 L238,206 L82,206 Z', s.g([(0, '#F2DDB0', None), (1, '#D9B878', None)]), '#07041A', 2.5)
        s.line(96, 78, 224, 78, '#B89A5C', 2)
        s.circ(160, 134, 38, '#14102B', .95); s.circ(160, 134, 38, 'none', st=ACC, sw=3)
        cowrie(s, 160, 134, 25, 17, GOLD, '#14102B')
        s.path('M91,198 L229,198', st='#B89A5C', sw=1.6, o=1)
    vue('tote', '#3A1B52', '#14102B', GOLD, f)


def capsule():
    def f(s):
        s.g([(0, '#000', None)])
        s.a('<g transform="translate(-14,18) scale(.7)">'); draw_tshirt(s, '#F8F7FF', '#B6B0DD'); s.a('</g>')
        s.a('<g transform="translate(160,14) scale(.56)">'); draw_hoodie(s, '#8B5CF6', '#4C2FA8'); s.a('</g>')
        s.a('<g transform="translate(150,106) scale(.5)">'); draw_cap(s, '#14102B', ACC); s.a('</g>')
        s.a('<g transform="translate(92,150) scale(.3)">'); draw_vinyl_record(s, 160, 120, 68); s.a('</g>')
    vue('capsule', '#3A1B52', '#0C0820', GOLD, f)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for fn in (tshirt, hoodie, casquette, cd, vinyle, affiche, tote, capsule):
        fn()
    print('8 illustrations dans', OUT)
