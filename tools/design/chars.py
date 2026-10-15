"""Personnage de RAP EMPIRE, rendu vectoriel en trois styles et quatre angles. Illustration statique."""
import itertools
_uid = itertools.count(1)

def _rgb(h): h = h.lstrip('#'); return [int(h[i:i + 2], 16) for i in (0, 2, 4)]
def _hex(c): return '#%02X%02X%02X' % tuple(max(0, min(255, int(v))) for v in c)
def lighten(h, a): return _hex([v + (255 - v) * a for v in _rgb(h)])
def darken(h, a): return _hex([v * (1 - a) for v in _rgb(h)])
def warm(h, a): r, g, b = _rgb(h); return _hex([r + (255 - r) * a * .4, g * (1 - a * .35), b * (1 - a * .45)])

SKINS = ['#F6D2B0', '#E3B286', '#C58C5E', '#A5683F', '#855031', '#64391F', '#4B2916', '#35200F']

class C:
    def __init__(s, style):
        s.style = style; s.n = next(_uid); s.defs = []; s.cache = {}; s.k = 0
    def gid(s):
        s.k += 1; return 'g%d_%d' % (s.n, s.k)
    def paint(s, col, vec=(0, 0, 1, 1)):
        key = (col, vec)
        if key in s.cache: return s.cache[key]
        i = s.gid(); x1, y1, x2, y2 = vec
        if s.style == '3d':
            st = [(0, lighten(col, .30)), (.45, col), (1, darken(col, .34))]
        elif s.style == '2d':
            st = [(0, col), (.58, col), (.58, darken(col, .20)), (1, darken(col, .20))]
        else:
            st = [(0, lighten(col, .10)), (.5, col), (1, darken(col, .30))]
        s.defs.append('<linearGradient id="%s" x1="%s" y1="%s" x2="%s" y2="%s">%s</linearGradient>' % (
            i, x1, y1, x2, y2, ''.join('<stop offset="%s" stop-color="%s"/>' % t for t in st)))
        s.cache[key] = 'url(#%s)' % i
        return s.cache[key]
    def radial(s, col, cx='.4', cy='.35'):
        i = s.gid()
        if s.style == '3d': st = [(0, lighten(col, .38)), (.6, col), (1, darken(col, .25))]
        elif s.style == '2d': st = [(0, col), (1, col)]
        else: st = [(0, lighten(col, .14)), (.65, col), (1, darken(col, .22))]
        s.defs.append('<radialGradient id="%s" cx="%s" cy="%s" r=".75">%s</radialGradient>' % (i, cx, cy, ''.join('<stop offset="%s" stop-color="%s"/>' % t for t in st)))
        return 'url(#%s)' % i
    @property
    def ol(s):
        return {'2d': 'stroke="#14102B" stroke-width="3.6" stroke-linejoin="round" stroke-linecap="round"',
                '3d': 'stroke="#000" stroke-opacity=".22" stroke-width="1.4" stroke-linejoin="round"',
                'semi': 'stroke="#000" stroke-opacity=".16" stroke-width="1" stroke-linejoin="round"'}[s.style]
    def sh(s, d, col, vec=(0, 0, 1, 1), extra=''):
        return '<path d="%s" fill="%s" %s %s/>' % (d, s.paint(col, vec), s.ol, extra)
    def flat(s, d, col, op=1, extra=''): return '<path d="%s" fill="%s" fill-opacity="%s" %s/>' % (d, col, op, extra)
    def line(s, d, col, w=2.4, op=.4):
        if s.style == '2d': col, op, w = '#14102B', .9, w * 1.1
        return '<path d="%s" fill="none" stroke="%s" stroke-opacity="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>' % (d, col, op, w)

def mirror(g): return '<g transform="translate(300 0) scale(-1 1)">%s</g>' % g

# ---------- tête et visage ----------
def eyes(c, skin, x1, x2, y=92, far=1.0, look=0, mood='cool'):
    out = []
    if c.style == '2d' and mood == 'sing':
        return ''.join('<path d="M%s %s Q%s %s %s %s" fill="none" stroke="#14102B" stroke-width="5" stroke-linecap="round"/>' % (x - 12, y - 3, x, y + 11, x + 12, y - 3) for x in (x1, x2))
    if c.style == '2d' and mood in ('laugh',):
        # yeux fermés en arcs joyeux (^ ^) : lecture immédiate
        for x in (x1, x2):
            out.append('<path d="M%s %s Q%s %s %s %s" fill="none" stroke="#14102B" stroke-width="5" stroke-linecap="round"/>' % (x - 12, y + 3, x, y - 13, x + 12, y + 3))
        return ''.join(out)
    for i, x in enumerate((x1, x2)):
        k = far if (far != 1 and i == 1) else 1.0
        rx, ry = 11 * k, (9.5 if c.style != 'semi' else 7.5) * k
        if c.style == '2d':
            out.append('<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="#fff" stroke="#14102B" stroke-width="3"/><circle cx="%s" cy="%s" r="%s" fill="#3A2218"/><circle cx="%s" cy="%s" r="%s" fill="#fff"/>' % (x, y, rx, ry, x + look, y, 6 * k, x + look - 2, y - 2, 2 * k))
        else:
            iris = c.radial('#6B3F23', '.4', '.3')
            out.append('<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="#FBF6F2"/><circle cx="%s" cy="%s" r="%s" fill="%s"/><circle cx="%s" cy="%s" r="%s" fill="#140C08"/>' % (x, y, rx, ry, x + look, y + .5, 6.6 * k if c.style == '3d' else 5.2 * k, iris, x + look, y + .5, 3.2 * k if c.style == '3d' else 2.6 * k))
            out.append('<circle cx="%s" cy="%s" r="%s" fill="#fff" opacity=".95"/><circle cx="%s" cy="%s" r="%s" fill="#fff" opacity=".6"/>' % (x + look - 2.2, y - 2.4, 2.2 * k, x + look + 2.4, y + 2.4, 1.2 * k))
            out.append('<path d="M%s %s Q%s %s %s %s" fill="none" stroke="#1A0F0A" stroke-width="%s" stroke-linecap="round"/>' % (x - rx - 1, y - 1, x, y - ry - 4, x + rx + 1, y - 1, 3.2 if c.style == '3d' else 2.2))
            out.append('<path d="M%s %s Q%s %s %s %s" fill="none" stroke="%s" stroke-opacity=".5" stroke-width="1.6" stroke-linecap="round"/>' % (x - rx + 2, y + ry - 1, x, y + ry + 2, x + rx - 2, y + ry - 1, darken(skin, .5)))
    return ''.join(out)

def brows(c, hc, x1, x2, y=76, far=1.0, mood='cool'):
    t = 5 if c.style != 'semi' else 4.4
    col = darken(hc, .15)
    def P(d): return '<path d="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round"/>' % (d, col, t)
    if mood == 'angry':
        if c.style == '2d':  # sourcils épais, très inclinés vers le nez
            return ('<path d="M%s %s L%s %s" stroke="%s" stroke-width="8" stroke-linecap="round"/>' % (x1 - 15, y - 8, x1 + 13, y + 11, col)
                    + '<path d="M%s %s L%s %s" stroke="%s" stroke-width="8" stroke-linecap="round"/>' % (x2 + 15, y - 8, x2 - 13, y + 11, col))
        return P('M%s %s Q%s %s %s %s' % (x1 - 13, y - 4, x1, y - 1, x1 + 12, y + 6)) + P('M%s %s Q%s %s %s %s' % (x2 - 12, y + 6, x2, y - 1, x2 + 13 * far, y - 4))
    if mood == 'poised':  # négociation : un sourcil haut, l'autre posé
        return P('M%s %s Q%s %s %s %s' % (x1 - 13, y + 3, x1, y - 2, x1 + 12, y + 1)) + P('M%s %s Q%s %s %s %s' % (x2 - 12, y - 9, x2, y - 19, x2 + 13 * far, y - 9))
    if mood == 'worried':
        return P('M%s %s Q%s %s %s %s' % (x1 - 13, y + 5, x1, y - 2, x1 + 12, y - 7)) + P('M%s %s Q%s %s %s %s' % (x2 - 12, y - 7, x2, y - 2, x2 + 13 * far, y + 5))
    if mood == 'surprised':
        return P('M%s %s Q%s %s %s %s' % (x1 - 13, y - 6, x1, y - 16, x1 + 12, y - 8)) + P('M%s %s Q%s %s %s %s' % (x2 - 12, y - 8, x2, y - 16, x2 + 13 * far, y - 6))
    if mood == 'smirk':
        return P('M%s %s Q%s %s %s %s' % (x1 - 13, y + 3, x1, y - 2, x1 + 12, y + 1)) + P('M%s %s Q%s %s %s %s' % (x2 - 12, y - 8, x2, y - 15, x2 + 13 * far, y - 6))
    if mood == 'sing':
        return P('M%s %s Q%s %s %s %s' % (x1 - 13, y - 3, x1, y - 13, x1 + 12, y - 6)) + P('M%s %s Q%s %s %s %s' % (x2 - 12, y - 6, x2, y - 13, x2 + 13 * far, y - 3))
    if mood == 'laugh': mood = 'smile'
    if mood == 'neutral': mood = 'cool'
    a = {'cool': 2, 'smile': -1, 'serious': 4}[mood]
    d1 = 'M%s %s Q%s %s %s %s' % (x1 - 13, y + a, x1, y - 5, x1 + 12, y - 1 + a * -.2)
    d2 = 'M%s %s Q%s %s %s %s' % (x2 - 12, y - 1 + a * -.2, x2, y - 5, x2 + 13 * far, y + a)
    return P(d1) + P(d2)

def mouth(c, skin, cx, y, w=16, mood='cool', shift=0):
    lip = darken(warm(skin, .5), .28)
    if mood == 'angry':
        # mâchoire serrée : bouche en trapèze avec dents
        return '<path d="M%s %s Q%s %s %s %s L%s %s Q%s %s %s %s Z" fill="#FBF3EE" stroke="#14102B" stroke-width="3" stroke-linejoin="round"/><path d="M%s %s H%s M%s %s V%s M%s %s V%s" stroke="#14102B" stroke-width="2"/>' % (cx - w, y + 9, cx, y - 5, cx + w, y + 9, cx + w - 4, y + 16, cx, y + 12, cx - w + 4, y + 16, cx - w + 2, y + 10, cx + w - 2, cx, y - 2, y + 14, cx - 7, y + 2, y + 13)
    if mood == 'worried':
        return '<path d="M%s %s Q%s %s %s %s" fill="none" stroke="%s" stroke-width="3.6" stroke-linecap="round"/>' % (cx - w + 2, y + 6, cx, y - 3, cx + w - 2, y + 6, lip)
    if mood == 'surprised':
        return '<ellipse cx="%s" cy="%s" rx="8" ry="11" fill="#2A0F14"/><ellipse cx="%s" cy="%s" rx="5" ry="4" fill="%s" fill-opacity=".8"/>' % (cx, y + 5, cx, y + 11, lip)
    if mood == 'smirk':
        return '<path d="M%s %s Q%s %s %s %s" fill="none" stroke="%s" stroke-width="3.6" stroke-linecap="round"/><path d="M%s %s Q%s %s %s %s" fill="#FBF3EE"/>' % (cx - w, y + 3, cx + 2, y + 6, cx + w + 2, y - 6, lip, cx + 2, y + 4, cx + 8, y + 9, cx + w - 2, y - 3)
    if mood == 'laugh':
        return '<path d="M%s %s Q%s %s %s %s Q%s %s %s %s Z" fill="#3A0F18"/><path d="M%s %s Q%s %s %s %s Q%s %s %s %s Z" fill="#FBF3EE"/>' % (cx - w - 2, y - 3, cx, y + 22, cx + w + 2, y - 3, cx, y + 2, cx - w - 2, y - 3, cx - w, y - 2, cx, y + 3, cx + w, y - 2, cx, y - 1, cx - w, y - 2)
    if mood == 'poised':
        return '<path d="M%s %s Q%s %s %s %s" fill="none" stroke="%s" stroke-width="3.8" stroke-linecap="round"/><path d="M%s %s q4 -2 5 -7" stroke="%s" stroke-width="2.6" fill="none" stroke-linecap="round"/>' % (cx - w + 2, y + 3, cx + 2, y + 6, cx + w, y - 4, lip, cx + w, y - 4, lip)
    if mood == 'sing':
        return '<path d="M%s %s Q%s %s %s %s Q%s %s %s %s Z" fill="#3A0F18" stroke="#14102B" stroke-width="2.5"/><path d="M%s %s Q%s %s %s %s Q%s %s %s %s Z" fill="#F43F9D" fill-opacity=".85"/>' % (cx - 15, y - 4, cx, y + 34, cx + 15, y - 4, cx, y - 8, cx - 15, y - 4, cx - 8, y + 18, cx, y + 10, cx + 8, y + 18, cx, y + 26, cx - 8, y + 18)
    if mood == 'neutral': mood = 'cool'
    if mood == 'smile':
        return '<path d="M%s %s Q%s %s %s %s Q%s %s %s %s Z" fill="#FBF3EE"/><path d="M%s %s Q%s %s %s %s" fill="none" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % (
            cx - w, y - 2, cx, y + 14, cx + w, y - 2, cx, y + 3, cx - w, y - 2, cx - w - 1, y - 3, cx, y + 16, cx + w + 1, y - 3, lip)
    if mood == 'serious':
        return '<path d="M%s %s Q%s %s %s %s" fill="none" stroke="%s" stroke-width="3.6" stroke-linecap="round"/>' % (cx - w, y + 2, cx, y - 1, cx + w, y + 2, lip)
    return ('<path d="M%s %s Q%s %s %s %s Q%s %s %s %s Z" fill="%s" opacity=".95"/><path d="M%s %s Q%s %s %s %s" fill="none" stroke="%s" stroke-width="2.6" stroke-linecap="round"/>' % (
        cx - w, y + 2, cx - 2, y - 3, cx + w, y - 5, cx, y + 9, cx - w, y + 2, lip, cx - w, y + 2, cx + 2, y + 4, cx + w, y - 5, darken(lip, .35)))

def nose_front(c, skin):
    sd = darken(skin, .28)
    s = '<path d="M146 98 Q140 112 144 116 Q150 120 156 116 Q160 112 154 98" fill="%s" fill-opacity=".38"/>' % sd
    s += '<ellipse cx="144" cy="116" rx="2.4" ry="1.7" fill="%s" fill-opacity=".7"/><ellipse cx="156" cy="116" rx="2.4" ry="1.7" fill="%s" fill-opacity=".7"/>' % (darken(skin, .5), darken(skin, .5))
    if c.style != '2d': s += '<path d="M150 90 Q151 104 150 110" stroke="%s" stroke-opacity=".5" stroke-width="3" fill="none" stroke-linecap="round"/>' % lighten(skin, .5)
    else: s = c.line('M144 112 Q150 120 158 112', '#000', 3, 1)
    return s

def head_front(c, skin, hair, hc, beard, mood, acc, face=''):
    o = []
    sk = c.radial(skin, '.45', '.32')
    ears = ''.join('<ellipse cx="%s" cy="94" rx="9" ry="15" fill="%s" %s/><ellipse cx="%s" cy="95" rx="4" ry="8" fill="%s" fill-opacity=".5"/>' % (x, c.paint(skin), c.ol, x + (1.5 if x < 150 else -1.5), darken(skin, .3)) for x in (104, 196))
    back = ''
    if hair == 'afro': back = '<ellipse cx="150" cy="62" rx="76" ry="70" fill="%s" %s/>' % (c.paint(hc), c.ol)
    if hair == 'braids':
        back = ''.join('<path d="M%d 50 Q%d 100 %d 190" stroke="%s" stroke-width="9" stroke-linecap="round" fill="none"/>' % (x, x + (-6 if x < 150 else 6), x + (-8 if x < 150 else 8), hc) for x in (106, 116, 126, 174, 184, 194))
    if hair == 'locks':
        back = ''.join('<path d="M%d 44 Q%d 110 %d %d" stroke="%s" stroke-width="11" stroke-linecap="round" fill="none"/><path d="M%d 44 Q%d 110 %d %d" stroke="%s" stroke-opacity=".25" stroke-width="3" stroke-linecap="round" fill="none"/>' % (x, x + (-10 if x < 150 else 10), x + (-12 if x < 150 else 12), 170 + (i % 3) * 22, hc, x - 2, x + (-12 if x < 150 else 8), x + (-14 if x < 150 else 10), 170 + (i % 3) * 22, lighten(hc, .5)) for i, x in enumerate((104, 114, 124, 176, 186, 196)))
    o.append(back)
    o.append('<path d="M132 138 L168 138 L171 176 Q150 196 129 176Z" fill="%s" %s/><path d="M129 160 Q150 182 171 160 L171 176 Q150 196 129 176Z" fill="%s" fill-opacity=".35"/>' % (c.paint(skin), c.ol, darken(skin, .5)))
    o.append(ears)
    o.append('<path d="M104 84 C104 44 126 34 150 34 C174 34 196 44 196 84 C196 112 180 142 150 150 C120 142 104 112 104 84Z" fill="%s" %s/>' % (sk, c.ol))
    if c.style != '2d': o.append('<path d="M120 126 Q150 160 180 126 Q168 148 150 150 Q132 148 120 126Z" fill="%s" fill-opacity=".22"/>' % darken(skin, .55))
    if c.style == '3d': o.append('<ellipse cx="121" cy="112" rx="11" ry="7" fill="#FF7A8A" fill-opacity=".22"/><ellipse cx="179" cy="112" rx="11" ry="7" fill="#FF7A8A" fill-opacity=".22"/>')
    # barbe
    bc = darken(hc, .05)
    if beard == 'stubble': o.append('<path d="M106 90 Q108 134 150 150 Q192 134 194 90 Q184 124 150 126 Q116 124 106 90Z" fill="%s" fill-opacity=".38"/>' % bc)
    if beard == 'full': o.append('<path d="M104 88 Q104 138 150 152 Q196 138 196 88 Q186 118 168 122 Q150 114 132 122 Q114 118 104 88Z" fill="%s" %s/>' % (c.paint(bc), c.ol))
    if beard == 'goatee': o.append('<path d="M138 128 Q150 118 162 128 Q164 146 150 152 Q136 146 138 128Z" fill="%s" %s/>' % (c.paint(bc), c.ol))
    o.append(brows(c, hc, 130, 170, 76, 1, mood))
    o.append(eyes(c, skin, 130, 170, 92, 1.0, 4 if mood == 'poised' else 0, mood))
    if mood in ('angry', 'smirk', 'serious', 'worried', 'poised') and c.style == '2d':
        # paupières : narquois = mi-clos, colère = froncé, inquiet = tombant
        for x, d in ((130, -1), (170, 1)):
            drop = {'angry': 11, 'smirk': 7, 'serious': 5, 'worried': 3, 'poised': 4}[mood]
            o.append('<path d="M%d 79 L%d 79 L%d %d L%d %d Z" fill="%s"/><path d="M%d %d L%d %d" stroke="#14102B" stroke-width="3.2" stroke-linecap="round"/>' % (x - 13, x + 13, x + 13, 79 + drop + (d * 3 if mood == 'angry' else 0), x - 13, 79 + drop - (d * 3 if mood == 'angry' else 0), skin, x - 13, 79 + drop - (d * 3 if mood == 'angry' else 0), x + 13, 79 + drop + (d * 3 if mood == 'angry' else 0)))
    elif mood in ('angry', 'smirk'):
        for x in (130, 170): o.append('<path d="M%d 80 L%d 80 L%d 90 Q%d 85 %d 90Z" fill="%s"/><path d="M%d 90 Q%d 85 %d 90" stroke="#1A0F0A" stroke-width="3" fill="none" stroke-linecap="round"/>' % (x - 14, x + 14, x + 14, x, x - 14, skin, x - 13, x, x + 13))
    if 'fem' in acc:
        for x, d in ((130, -1), (170, 1)): o.append('<path d="M%d 86 l%d -5 M%d 83 l%d -6 M%d 81 l%d -6" stroke="#1A0F0A" stroke-width="2.6" stroke-linecap="round"/>' % (x + d * 11, d * 5, x + d * 7, d * 4, x + d * 2, d * 2))
    if c.style == '2d' and mood in ('angry', 'worried'):
        o.append('<path d="M136 60 q14 -5 28 0 M139 53 q11 -4 22 0" stroke="%s" stroke-opacity=".55" stroke-width="2.6" fill="none" stroke-linecap="round"/>' % darken(skin, .55))
    o.append(nose_front(c, skin))
    o.append(mouth(c, skin, 150, 130 if beard in ('full',) else 128, 15, mood))
    if beard == 'full': o.append('<path d="M134 124 Q150 118 166 124" stroke="%s" stroke-width="7" fill="none" stroke-linecap="round"/>' % bc)
    if face == 'scar': o.append('<path d="M176 64 L184 96" stroke="#fff" stroke-opacity=".55" stroke-width="2.4" stroke-linecap="round"/>')
    o.append(hair_front(c, hair, hc))
    if 'ring' in acc: o.append('<circle cx="104" cy="108" r="4.5" fill="none" stroke="#FFC83D" stroke-width="2.6"/><circle cx="196" cy="108" r="4.5" fill="none" stroke="#FFC83D" stroke-width="2.6"/>')
    if 'glasses' in acc: o.append('<path d="M108 88 L196 88" stroke="#14102B" stroke-width="3"/><rect x="112" y="80" width="36" height="24" rx="9" fill="#10122A" fill-opacity=".82" stroke="#14102B" stroke-width="3"/><rect x="152" y="80" width="36" height="24" rx="9" fill="#10122A" fill-opacity=".82" stroke="#14102B" stroke-width="3"/><path d="M118 86 L130 98" stroke="#fff" stroke-opacity=".35" stroke-width="3" stroke-linecap="round"/><path d="M158 86 L170 98" stroke="#fff" stroke-opacity=".35" stroke-width="3" stroke-linecap="round"/>')
    if 'glasses' in acc and c.style == '2d' and mood not in ('cool', 'neutral', 'smile'):
        o.append(brows(c, hc, 130, 170, 70, 1, mood))
    if 'phones' in acc: o.append('<path d="M100 92 Q100 22 150 22 Q200 22 200 92" stroke="#2B2459" stroke-width="9" fill="none" stroke-linecap="round"/><path d="M100 92 Q100 22 150 22 Q200 22 200 92" stroke="#F43F9D" stroke-width="3" fill="none"/><rect x="92" y="78" width="16" height="34" rx="8" fill="#F43F9D" %s/><rect x="192" y="78" width="16" height="34" rx="8" fill="#F43F9D" %s/>' % (c.ol, c.ol))
    if 'cap' in acc: o.append('<path d="M100 66 Q100 22 150 20 Q200 22 200 66 Q150 56 100 66Z" fill="%s" %s/><path d="M96 64 Q150 52 204 64 L208 72 Q150 60 92 72Z" fill="%s" %s/><circle cx="150" cy="24" r="4" fill="%s"/>' % (c.paint('#14102B'), c.ol, c.paint('#F43F9D'), c.ol, '#F43F9D'))
    return ''.join(o)

def hair_front(c, hair, hc):
    h = []
    hi = lighten(hc, .45)
    cap = 'M108 80 Q104 36 150 30 Q196 36 192 80 Q186 56 150 52 Q114 56 108 80Z'
    if hair in ('hitwist', 'fade'):
        if hair == 'hitwist':
            h.append('<path d="M112 54 Q108 8 150 6 Q192 8 188 54 Q150 40 112 54Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
            for i in range(26):
                x = 118 + (i * 37) % 64; y = 14 + (i * 17) % 32
                h.append('<circle cx="%d" cy="%d" r="5.2" fill="%s"/><path d="M%d %d l2.6 2.6" stroke="%s" stroke-opacity=".6" stroke-width="1.6" stroke-linecap="round"/>' % (x, y, c.paint(hc), x - 1, y - 2, hi))
            h.append('<path d="M106 80 Q100 56 112 48 L116 70Z M194 80 Q200 56 188 48 L184 70Z" fill="%s" fill-opacity=".45"/>' % hc)
            h.append('<path d="M110 50 Q150 36 190 50" stroke="%s" stroke-opacity=".5" stroke-width="2" fill="none"/>' % hi)
        else:
            h.append('<path d="%s" fill="%s" %s/><path d="M106 80 Q102 58 112 46 L118 76Z M194 80 Q198 58 188 46 L182 76Z" fill="%s" fill-opacity=".4"/>' % (cap, c.paint(hc), c.ol, hc))
            h.append('<path d="M120 46 Q150 34 180 46" stroke="%s" stroke-opacity=".5" stroke-width="3" fill="none" stroke-linecap="round"/>' % hi)
    if hair == 'afro':
        h.append('<path d="M104 84 Q96 36 150 20 Q204 36 196 84 Q190 54 150 48 Q110 54 104 84Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
        for i in range(30): h.append('<circle cx="%d" cy="%d" r="3.4" fill="%s" fill-opacity=".35"/>' % (100 + (i * 29) % 100, 24 + (i * 13) % 26, hi))
    if hair in ('braids', 'locks'):
        h.append('<path d="%s" fill="%s" %s/><path d="M110 70 Q150 40 190 70" stroke="%s" stroke-opacity=".4" stroke-width="2.4" fill="none"/>' % (cap, c.paint(hc), c.ol, hi))
    if hair == 'cornrows':
        h.append('<path d="%s" fill="%s" %s/>' % (cap, c.paint(hc), c.ol))
        for x in (122, 136, 150, 164, 178): h.append('<path d="M%d 46 Q%d 36 %d 72" stroke="%s" stroke-opacity=".55" stroke-width="2.6" fill="none" stroke-linecap="round"/>' % (x, x, x + (x - 150) * .25, lighten(hc, .6)))
    if hair == 'knots':
        h.append('<path d="%s" fill="%s" %s/>' % (cap, c.paint(hc), c.ol))
        for x, y in ((120, 30), (136, 18), (152, 14), (168, 18), (184, 30)): h.append('<circle cx="%d" cy="%d" r="13" fill="%s" %s/><path d="M%d %d q4 -4 8 0" stroke="%s" stroke-opacity=".5" stroke-width="2" fill="none"/>' % (x, y, c.paint(hc), c.ol, x - 4, y - 2, hi))
    if hair == 'bald': h.append('<ellipse cx="136" cy="48" rx="20" ry="8" fill="#fff" fill-opacity=".18"/>')
    return ''.join(h)

# ---------- corps ----------
def torso_front(c, outfit):
    top, accent = outfit['top'], outfit['accent']
    o = []
    kind = outfit.get('kind', 'hoodie')
    long = kind != 'tee'
    arm = 'M72 176 Q42 198 36 266 Q32 318 42 348 L84 352 Q88 300 94 252 Q98 214 88 178Z'
    sleeve_c = top if long else None
    # bras (derrière)
    armg = ''
    if long:
        armg += c.sh(arm, top, (0, 0, 1, 1)) + c.line('M52 250 Q64 262 86 262', darken(top, .6), 2.4, .35) + c.sh('M40 336 Q62 346 86 340 L84 358 Q60 366 40 358Z', darken(top, .12))
        armg += '<path d="M44 358 Q34 390 52 404 Q74 412 86 392 Q94 368 84 358Z" fill="%s" %s/>' % (c.paint(outfit['skin']), c.ol)
        armg += c.line('M58 392 Q66 398 74 394', darken(outfit['skin'], .5), 2, .5)
    else:
        armg += '<path d="M50 220 Q38 280 42 340 L82 346 Q86 290 92 238Z" fill="%s" %s/>' % (c.paint(outfit['skin']), c.ol)
        armg += '<path d="M44 340 Q34 380 52 396 Q74 404 86 384 Q94 360 82 346Z" fill="%s" %s/>' % (c.paint(outfit['skin']), c.ol)
        armg += c.sh('M70 176 Q44 190 40 232 L96 246 Q100 206 88 178Z', top)
    o.append(armg); o.append(mirror(armg))
    # torse
    body = 'M72 176 Q72 166 88 164 L212 164 Q228 166 228 176 L238 328 Q238 342 226 344 L74 344 Q62 342 62 328Z'
    o.append(c.sh(body, top, (0, 0, 1, 1)))
    if kind == 'hoodie':
        o.append(c.sh('M62 326 L238 326 L238 346 Q238 350 228 350 L72 350 Q62 350 62 346Z', darken(top, .14)))
        o.append(c.sh('M98 270 L202 270 L216 322 L84 322Z', darken(top, .12)))
        o.append(c.line('M98 270 L88 322 M202 270 L212 322 M150 270 L150 322', darken(top, .6), 2.2, .35))
        o.append(c.line('M92 236 Q120 252 112 296 M208 236 Q180 252 188 296 M70 300 Q110 310 130 306 M230 300 Q190 310 170 306', darken(top, .6), 2.4, .3))
        o.append(c.sh('M110 164 Q150 226 190 164 Q202 176 196 192 Q150 244 104 192 Q98 176 110 164Z', darken(top, .2)))
        o.append(c.sh('M122 170 Q150 206 178 170 Q184 178 180 186 Q150 216 120 186 Q116 178 122 170Z', outfit['skin'], (0, 0, 0, 1)))
        for x in (134, 166): o.append('<path d="M%d 204 Q%d 232 %d 252" stroke="#F8F7FF" stroke-width="3.4" fill="none" stroke-linecap="round"/><rect x="%d" y="250" width="5" height="12" rx="2.5" fill="%s"/>' % (x, x + (-3 if x < 150 else 3), x + (-3 if x < 150 else 3), x + (-5.5 if x < 150 else -1.5), outfit['accent']))
    if kind == 'bomber':
        o.append(c.sh('M62 322 L238 322 L238 346 Q238 352 228 352 L72 352 Q62 352 62 346Z', darken(top, .25)))
        o.append(c.sh('M110 162 Q150 200 190 162 L196 176 Q150 214 104 176Z', darken(top, .3)))
        o.append(c.sh('M122 168 Q150 198 178 168 L180 180 Q150 206 120 180Z', outfit['skin'], (0, 0, 0, 1)))
        o.append('<path d="M150 200 L150 322" stroke="%s" stroke-width="4"/><circle cx="150" cy="232" r="4" fill="#FFC83D"/>' % darken(top, .5))
        o.append(c.sh('M84 250 L128 250 L128 286 L84 286Z M172 250 L216 250 L216 286 L172 286Z', darken(top, .15)))
        o.append(c.sh('M44 336 Q64 346 86 340 L84 360 Q62 368 42 358Z', darken(top, .25)) if False else '')
    if kind == 'blazer':
        o.append('<path d="M118 164 L182 164 L170 262 L130 262Z" fill="#F8F7FF" %s/>' % c.ol)
        o.append(c.sh('M100 164 L128 164 L146 320 L98 320Z', darken(top, .08)) + c.sh('M200 164 L172 164 L154 320 L202 320Z', darken(top, .08)))
        o.append(c.sh('M100 164 L134 164 L150 236 L116 250Z', darken(top, .22)) + c.sh('M200 164 L166 164 L150 236 L184 250Z', darken(top, .22)))
        o.append('<circle cx="150" cy="288" r="4" fill="#FFC83D"/><rect x="172" y="262" width="22" height="9" rx="2" fill="#F8F7FF" fill-opacity=".9"/>')
    if kind == 'tee':
        o.append('<path d="M118 164 Q150 214 182 164 L190 172 Q150 232 110 172Z" fill="%s" %s/>' % (c.paint(darken(top, .2)), c.ol))
        o.append(c.line('M92 250 Q120 266 112 316', darken(top, .6), 2.4, .3))
        o.append('<path d="M116 170 Q150 206 184 170 L180 178 Q150 214 120 178Z" fill="%s"/>' % outfit['skin'])
    # logo
    if outfit.get('logo', True):
        o.append('<rect x="170" y="206" width="34" height="22" rx="6" fill="%s" %s/><text x="187" y="222" text-anchor="middle" font-family="Baloo 2, Poppins, sans-serif" font-weight="800" font-size="14" fill="#14102B">BKM</text>' % (accent, c.ol))
    return ''.join(o)

def legs_front(c, outfit):
    p, sc = outfit['pants'], outfit['shoe']
    o = []
    leg = 'M90 336 L148 336 L150 556 L98 556 Q86 556 86 546Z'
    o.append('<path d="M88 340 L212 340 L220 548 Q220 560 208 560 L156 560 L150 416 L144 560 L92 560 Q80 560 80 548Z" fill="%s" %s/>' % (c.paint(p), c.ol))
    o.append(c.line('M150 360 L150 416', darken(p, .6), 2.4, .5))
    pk = c.sh('M94 430 L134 430 L136 486 L92 486Z', darken(p, .12)) + c.line('M94 442 L134 442', darken(p, .6), 2, .4) + '<rect x="108" y="438" width="12" height="6" rx="2" fill="%s"/>' % outfit['accent']
    o.append(pk); o.append(mirror(pk))
    o.append(c.line('M92 380 Q110 392 140 388 M208 380 Q190 392 160 388 M96 520 Q116 530 142 524 M204 520 Q184 530 158 524', darken(p, .6), 2.4, .3))
    o.append('<path d="M82 542 Q112 556 150 548 L150 566 Q112 574 80 562Z" fill="%s" fill-opacity=".5"/>' % darken(p, .3) )
    sh = ('<path d="M74 566 Q74 548 94 546 L142 546 Q152 552 154 574 Q158 598 142 604 L86 606 Q70 606 72 590Z" fill="%s" %s/>' % (c.paint(sc), c.ol) +
          '<path d="M72 590 L156 590 L156 606 Q156 614 146 614 L84 614 Q70 614 70 604Z" fill="%s" %s/>' % (c.paint('#F8F7FF'), c.ol) +
          c.line('M96 556 L118 566 M104 550 L126 562 M112 548 L134 558', '#fff', 2.4, .8) +
          '<path d="M82 584 Q108 574 146 580" stroke="%s" stroke-width="5" fill="none" stroke-linecap="round"/>' % outfit['accent'])
    o.append(sh); o.append(mirror(sh))
    return ''.join(o)

def chain_front(c):
    return ('<path d="M120 178 Q150 244 180 178" stroke="#FFC83D" stroke-width="5" fill="none" stroke-linecap="round"/><path d="M120 178 Q150 244 180 178" stroke="#fff" stroke-opacity=".55" stroke-width="1.6" fill="none" stroke-dasharray="3 5"/>'
            '<g %s><circle cx="150" cy="240" r="13" fill="%s"/></g><text x="150" y="245" text-anchor="middle" font-family="Baloo 2, Poppins, sans-serif" font-weight="800" font-size="14" fill="#7A5200">R</text><circle cx="145" cy="234" r="3" fill="#fff" fill-opacity=".7"/>' % (c.ol, c.paint('#FFC83D')))

# ---------- assemblage de face ----------
def figure(style='3d', view='front', skin=SKINS[3], hair='hitwist', hc='#1B1424', beard='stubble', mood='cool',
           outfit=None, acc=('chain',), crop='full', bg=None, face='', mic=False, extra='', pose=''):
    c = C(style)
    of = dict(top='#F43F9D', pants='#2B2459', shoe='#F43F9D', accent='#FFC83D', kind='hoodie', skin=skin)
    if outfit: of.update(outfit)
    of['skin'] = skin
    if view == 'front': g = ''.join([legs_front(c, of), torso_front(c, of), ('' if 'chain' not in acc else chain_front(c))])
    else:
        from chars2 import body_view, head_view
        g = body_view(c, view, of, acc)
    if view == 'front': head = head_front(c, skin, hair, hc, beard, mood, acc, face)
    else:
        from chars2 import head_view
        head = head_view(c, view, skin, hair, hc, beard, mood, acc)
    hs = {'3d': 1.0, '2d': 0.96, 'semi': 0.84}[style]
    tilt = {'angry': 0, 'smirk': 5, 'poised': 3, 'laugh': -6, 'sing': -10, 'worried': 4, 'serious': 0}.get(mood, 0) if style == '2d' else 0
    dy = {'angry': 13, 'worried': 6, 'serious': 2}.get(mood, 0) if style == '2d' else 0
    g += '<g transform="translate(150 150) rotate(%s) translate(0 %s) scale(%s %s) translate(-150 -150)">%s</g>' % (tilt, dy, hs * (.92 if 'fem' in acc else 1), hs, head)
    g += extra
    if mic: g += '<g transform="translate(60 380)">%s</g>' % ('<rect x="-6" y="-10" width="12" height="46" rx="6" fill="#2B2459" %s/><circle cx="0" cy="-18" r="14" fill="#B6B0DD" %s/>' % (c.ol, c.ol))
    if pose == 'closed':   # épaules rentrées, corps resserré
        g = '<g transform="translate(150 330) scale(.9 1.0) translate(-150 -330)">%s</g>' % g
    elif pose == 'dyn':    # appui penché, silhouette en diagonale
        g = '<g transform="translate(150 330) rotate(-9) scale(1.03) translate(-150 -330)">%s</g>' % g
    shadow = '<ellipse cx="150" cy="616" rx="104" ry="11" fill="#000" fill-opacity="%s" %s/>' % ('.38' if style != '2d' else '.28', 'filter="url(#blur%d)"' % c.n)
    defs = '<defs><filter id="blur%d" x="-20%%" y="-100%%" width="140%%" height="300%%"><feGaussianBlur stdDeviation="6"/></filter>%s</defs>' % (c.n, ''.join(c.defs))
    if style == 'semi':
        defs = defs.replace('</defs>', '<filter id="grain%d"><feTurbulence type="fractalNoise" baseFrequency=".9" numOctaves="2" seed="3" result="n"/><feColorMatrix in="n" type="saturate" values="0"/><feComponentTransfer><feFuncA type="linear" slope=".07"/></feComponentTransfer></filter></defs>' % c.n)
    vb = {'full': '0 0 300 640', 'bust': '40 0 220 250', 'head': '84 0 132 170', 'mid': '30 -18 240 462', 'hair': '64 -16 172 190', 'torso': '20 -14 260 340'}[crop]
    grain = ('<rect x="0" y="0" width="300" height="640" fill="#888" filter="url(#grain%d)" style="mix-blend-mode:overlay"/>' % c.n) if style == 'semi' else ''
    return '<svg viewBox="%s" xmlns="http://www.w3.org/2000/svg" style="width:100%%;height:100%%;display:block">%s%s%s%s%s</svg>' % (vb, defs, shadow, g, grain, '')
