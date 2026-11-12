#!/usr/bin/env python3
"""Calques de la garde-robe de Djo Kéné (RAP EMPIRE) : corps par tenue, tête, coiffures (arrière / avant), tatouages, accessoires de tête.
Usage (racine du dépôt) : python3 tools/design/gen_wardrobe_layers.py
Sortie : assets/characters/rapper_001/layers/{body,head,hairback,hairfront,tat,top}/*.svg, tous en repère 300 x 640, fond transparent.
Ordre d'empilement dans le jeu : body, hairback, head, tat, hairfront, top. Même dessin que gen_outfits.py (chars.py), aucune nouvelle source graphique."""
import os, sys, runpy, tempfile, json

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'tools', 'design'))
import chars, cast

OUT = os.path.join(ROOT, 'assets', 'characters', 'rapper_001', 'layers')
D = cast.CAST['djo']
SKIN, HC = D['skin'], D['hc']
VARIANTS = {'young': dict(beard='stubble', mood='smile', tilt=0), 'mature': dict(beard='full', mood='poised', tilt=3)}
HS = .96   # échelle de la tête dans chars.figure en style 2d

# catalogue des tenues : on réutilise celui de gen_outfits.py sans régénérer ses fichiers
tmp = tempfile.mkdtemp()
_argv = sys.argv; sys.argv = ['gen_outfits.py', ROOT, tmp]
_stdout = sys.stdout; sys.stdout = open(os.devnull, 'w')
try:
    g = runpy.run_path(os.path.join(ROOT, 'docs', 'design-ref', 'v21', 'sources', 'gen_outfits.py'), run_name='gen')
finally:
    sys.stdout = _stdout; sys.argv = _argv
CAT = g['CAT']

def wrap(c, body):
    defs = ''.join(c.defs)
    return '<svg viewBox="0 0 300 640" xmlns="http://www.w3.org/2000/svg" style="width:100%%;height:100%%;display:block"><defs>%s</defs>%s</svg>' % (defs, body)

def head_g(tilt, inner):
    return '<g transform="translate(150 150) rotate(%s) translate(0 0) scale(%s %s) translate(-150 -150)">%s</g>' % (tilt, HS, HS, inner)

def save(sub, name, svg):
    d = os.path.join(OUT, sub); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, name + '.svg'), 'w', encoding='utf-8').write(svg)

# ---------- coiffures ----------
CAP = 'M108 80 Q104 36 150 30 Q196 36 192 80 Q186 56 150 52 Q114 56 108 80Z'

def hair_twists(c):
    hc, hi = HC, chars.lighten(HC, .45)
    h = ['<path d="%s" fill="%s" %s/>' % (CAP, c.paint(hc), c.ol)]
    for r, (y, n, x0, x1) in enumerate(((44, 7, 116, 184), (36, 6, 122, 178), (28, 5, 130, 170))):
        for i in range(n):
            x = x0 + (x1 - x0) * i / (n - 1)
            h.append('<ellipse cx="%.1f" cy="%d" rx="5" ry="9" transform="rotate(%d %.1f %d)" fill="%s" %s/><path d="M%.1f %d l1.6 8" stroke="%s" stroke-opacity=".6" stroke-width="1.6" stroke-linecap="round"/>' % (x, y, (x - 150) * .5, x, y, c.paint(hc), c.ol, x - 2, y - 6, hi))
    return ''.join(h)

def hair_hightop(c):
    hc, hi = HC, chars.lighten(HC, .45)
    h = ['<path d="M106 80 Q100 58 110 48 L120 74Z M194 80 Q200 58 190 48 L180 74Z" fill="%s" fill-opacity=".5"/>' % hc]
    h.append('<path d="M112 60 L108 14 Q150 2 192 14 L188 60 Q150 46 112 60Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
    h.append('<path d="M116 22 Q150 12 184 22" stroke="%s" stroke-opacity=".5" stroke-width="3" fill="none" stroke-linecap="round"/>' % hi)
    for i in range(22): h.append('<circle cx="%d" cy="%d" r="2.2" fill="%s" fill-opacity=".3"/>' % (118 + (i * 31) % 64, 24 + (i * 13) % 26, hi))
    return ''.join(h)

def hair_mohawk(c):
    hc, hi = HC, chars.lighten(HC, .45)
    h = ['<path d="%s" fill="%s" fill-opacity=".38"/>' % (CAP, hc)]
    h.append('<path d="M136 56 Q130 12 142 -4 Q150 -10 158 -4 Q170 12 164 56 Q150 48 136 56Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
    h.append('<path d="M144 40 Q142 10 148 0" stroke="%s" stroke-opacity=".55" stroke-width="2.4" fill="none" stroke-linecap="round"/>' % hi)
    return ''.join(h)

def hair_puffs(c):
    hc, hi = HC, chars.lighten(HC, .45)
    h = ['<path d="%s" fill="%s" %s/>' % (CAP, c.paint(hc), c.ol)]
    for x in (116, 184):
        h.append('<circle cx="%d" cy="22" r="26" fill="%s" %s/>' % (x, c.paint(hc), c.ol))
        for i in range(10): h.append('<circle cx="%d" cy="%d" r="3" fill="%s" fill-opacity=".35"/>' % (x - 16 + (i * 11) % 32, 8 + (i * 7) % 26, hi))
    return ''.join(h)

def hair_bald(c):
    return '<ellipse cx="136" cy="48" rx="20" ry="8" fill="#fff" fill-opacity=".18"/>'

NEW = {'twists': hair_twists, 'hightop': hair_hightop, 'mohawk': hair_mohawk, 'puffs': hair_puffs, 'bald': hair_bald}
OLD = ('hitwist', 'fade', 'afro', 'braids', 'locks', 'cornrows', 'knots')
HAIRS = OLD + tuple(NEW)

def hair_front(c, hair):
    return NEW[hair](c) if hair in NEW else chars.hair_front(c, hair, HC)

def hair_back(c, hair):
    if hair not in ('afro', 'braids', 'locks'): return ''
    full = chars.head_front(c, SKIN, hair, HC, 'stubble', 'smile', (), '')
    return full[:full.index('<path d="M132 138 L168 138')]

# ---------- tatouages ----------
INK = '#14102B'
def ink(d, w=2.4, op=.78, extra=''): return '<path d="%s" fill="none" stroke="%s" stroke-opacity="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round" %s/>' % (d, INK, op, w, extra)
def fill(d, op=.78): return '<path d="%s" fill="%s" fill-opacity="%s"/>' % (d, INK, op)
def cowrie(x, y, s=1.0, rot=0):
    return '<g transform="translate(%s %s) rotate(%s) scale(%s)"><ellipse cx="0" cy="0" rx="6" ry="9" fill="%s" fill-opacity=".78"/><path d="M0 -7 L0 7" stroke="#F8F7FF" stroke-opacity=".7" stroke-width="1.4" stroke-linecap="round"/><path d="M-3 -4 L3 -4 M-3.4 -1 L3.4 -1 M-3.4 2 L3.4 2 M-3 5 L3 5" stroke="#F8F7FF" stroke-opacity=".6" stroke-width="1"/></g>' % (x, y, rot, s, INK)

def tat_vis_tempe():
    out = ''
    for sx in (1, -1):
        def X(x): return 150 + sx * (x - 150) if sx == -1 else x
        out += ''.join(ink('M%s %s L%s %s' % (X(x0), y0, X(x1), y1), 2.6) for x0, y0, x1, y1 in ((111, 60, 117, 74), (116, 56, 122, 70), (121, 54, 127, 66)))
    return out
def tat_vis_etoile():
    cx, cy, r = 121, 104, 7
    return fill('M%s %s L%s %s L%s %s L%s %s L%s %s L%s %s L%s %s L%s %s Z' % (cx, cy - r, cx + 2, cy - 2, cx + r, cy, cx + 2, cy + 2, cx, cy + r, cx - 2, cy + 2, cx - r, cy, cx - 2, cy - 2))
def tat_vis_ligne():
    return ink('M184 58 L190 82', 2.8) + ink('M179 56 L185 78', 2.2, .55)
def tat_cou_cauris():
    return cowrie(138, 164, .72, -12) + cowrie(150, 168, .8, 0) + cowrie(162, 164, .72, 12)
def tat_cou_bande():
    return ink('M134 160 L140 166 L146 160 L152 166 L158 160 L164 166 L168 161', 2.6)
def tat_cou_soleil():
    s = fill('M150 157 m-6 0 a6 6 0 1 0 12 0 a6 6 0 1 0 -12 0')
    for a in range(0, 360, 45):
        import math
        s += ink('M%.1f %.1f L%.1f %.1f' % (150 + 9 * math.cos(math.radians(a)), 163 + 9 * math.sin(math.radians(a)) - 6, 150 + 13 * math.cos(math.radians(a)), 163 + 13 * math.sin(math.radians(a)) - 6), 1.8)
    return s
def hand(g): return g + '<g transform="translate(300 0) scale(-1 1)">%s</g>' % g
def tat_main_cauri(): return hand(cowrie(66, 382, 1.15, 8))
def tat_main_soleil():
    import math
    g = fill('M66 383 m-6.5 0 a6.5 6.5 0 1 0 13 0 a6.5 6.5 0 1 0 -13 0')
    for a in range(0, 360, 60): g += ink('M%.1f %.1f L%.1f %.1f' % (66 + 10 * math.cos(math.radians(a)), 383 + 10 * math.sin(math.radians(a)), 66 + 15 * math.cos(math.radians(a)), 383 + 15 * math.sin(math.radians(a))), 1.8)
    return hand(g)
def tat_main_phalanges():
    return hand(''.join(fill('M%s %s m-2.4 0 a2.4 2.4 0 1 0 4.8 0 a2.4 2.4 0 1 0 -4.8 0' % (x, 398 - abs(x - 66) * .3)) for x in (54, 61, 68, 75)) + ink('M52 378 L80 380', 2.2, .6))

TATS = {  # id : (zone, dessin, dans le repère de la tête ?)
    'vis_tempe': ('visage', tat_vis_tempe, True), 'vis_etoile': ('visage', tat_vis_etoile, True), 'vis_ligne': ('visage', tat_vis_ligne, True),
    'cou_cauris': ('cou', tat_cou_cauris, True), 'cou_bande': ('cou', tat_cou_bande, True), 'cou_soleil': ('cou', tat_cou_soleil, True),
    'main_cauri': ('mains', tat_main_cauri, False), 'main_soleil': ('mains', tat_main_soleil, False), 'main_phalanges': ('mains', tat_main_phalanges, False),
}

def main():
    # corps : jambes, torse, chaîne (comme chars.figure, sans la tête)
    for o in CAT:
        c = chars.C('2d')
        of = dict(top='#F43F9D', pants='#2B2459', shoe='#F43F9D', accent='#FFC83D', kind='hoodie', skin=SKIN); of.update(o['of']); of['skin'] = SKIN
        acc = o.get('acc', D['acc'])
        body = chars.legs_front(c, of) + chars.torso_front(c, of) + ('' if 'chain' not in acc else chars.chain_front(c))
        shadow = '<ellipse cx="150" cy="616" rx="104" ry="11" fill="#000" fill-opacity=".28" %s/>' % ('filter="url(#blur%d)"' % c.n)
        c.defs.insert(0, '<filter id="blur%d" x="-20%%" y="-100%%" width="140%%" height="300%%"><feGaussianBlur stdDeviation="6"/></filter>' % c.n)
        save('body', o['id'], wrap(c, shadow + body))
        for vn, v in VARIANTS.items():
            top = ''
            c2 = chars.C('2d')
            if 'ring' in acc: top += '<circle cx="104" cy="108" r="4.5" fill="none" stroke="#FFC83D" stroke-width="2.6"/><circle cx="196" cy="108" r="4.5" fill="none" stroke="#FFC83D" stroke-width="2.6"/>'
            full = chars.head_front(c2, SKIN, 'none', HC, v['beard'], v['mood'], tuple(a for a in acc if a in ('glasses', 'phones', 'cap')), '')
            # on isole les accessoires de tête : ce qui suit la dernière brique du visage (bouche / barbe)
            marker = '<path d="M100 66 Q100 22 150 20' if 'cap' in acc else None
            glass = full.find('<path d="M108 88 L196 88"') if 'glasses' in acc else -1
            ph = full.find('<path d="M100 92 Q100 22 150 22') if 'phones' in acc else -1
            cp = full.find('<path d="M100 66 Q100 22 150 20') if 'cap' in acc else -1
            starts = [i for i in (glass, ph, cp) if i >= 0]
            acc_svg = full[min(starts):] if starts else ''
            if starts:
                top += acc_svg
            if top:
                save('top', '%s_%s' % (o['id'], vn), wrap(c2, head_g(v['tilt'], top)))
    for vn, v in VARIANTS.items():
        c = chars.C('2d')
        save('head', vn, wrap(c, head_g(v['tilt'], chars.head_front(c, SKIN, 'none', HC, v['beard'], v['mood'], (), ''))))
        for hair in HAIRS:
            c = chars.C('2d'); b = hair_back(c, hair)
            if b: save('hairback', '%s_%s' % (hair, vn), wrap(c, head_g(v['tilt'], b)))
            c = chars.C('2d'); save('hairfront', '%s_%s' % (hair, vn), wrap(c, head_g(v['tilt'], hair_front(c, hair))))
        for tid, (zone, fn, inhead) in TATS.items():
            if inhead:
                c = chars.C('2d'); save('tat', '%s_%s' % (tid, vn), wrap(c, head_g(v['tilt'], fn())))
    for tid, (zone, fn, inhead) in TATS.items():
        if not inhead:
            c = chars.C('2d'); save('tat', '%s_young' % tid, wrap(c, fn())); save('tat', '%s_mature' % tid, wrap(c, fn()))
    json.dump({'hairs': list(HAIRS), 'tattoos': {k: v[0] for k, v in TATS.items()}}, open(os.path.join(OUT, 'manifest.json'), 'w'), indent=1)
    print('calques écrits dans', OUT)

if __name__ == '__main__':
    main()
