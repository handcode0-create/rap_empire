# v20 : illustrations (SVG générés par script ; style provisoire, aucune direction d'avatar choisie : D-01)
import random, cast, scenes
PROV = '2d'   # rendu provisoire des portraits : n'engage pas le choix D-01

def _wrap(inner, defs='', vb='0 0 390 220'):
    return '<svg class="art" viewBox="%s" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><defs>%s</defs>%s</svg>' % (vb, defs, inner)

def bgscene(kind):
    return scenes.BGS[kind]().replace('class="bg"', 'class="art"').replace('<svg ', '<svg aria-hidden="true" ', 1)

def skyline(h=220, seed=7, title=True):
    rnd = random.Random(seed)
    d = ('<linearGradient id="sk" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1B1043"/><stop offset=".55" stop-color="#7A2A8A"/><stop offset="1" stop-color="#F43F9D"/></linearGradient>'
         '<radialGradient id="sn" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="#FFE08A"/><stop offset=".6" stop-color="#FFC83D"/><stop offset="1" stop-color="#FF6BB8" stop-opacity="0"/></radialGradient>')
    s = '<rect width="390" height="%d" fill="url(#sk)"/>' % h
    s += ''.join('<circle cx="%d" cy="%d" r="%.1f" fill="#fff" opacity="%.2f"/>' % (rnd.randint(8, 382), rnd.randint(6, 90), rnd.choice([.8, 1, 1.4]), rnd.uniform(.3, .9)) for _ in range(34))
    s += '<circle cx="296" cy="%d" r="62" fill="url(#sn)"/><circle cx="296" cy="%d" r="34" fill="#FFD36B" opacity=".95"/>' % (h * .62, h * .62)
    base = h
    for layer, (col, hmin, hmax, wd, op) in enumerate([('#3A1B52', 60, 120, 34, .9), ('#2B1858', 80, 150, 40, 1), ('#14102B', 50, 110, 46, 1)]):
        x = -10 + layer * 12
        while x < 400:
            bh = rnd.randint(hmin, hmax); w = rnd.randint(wd - 8, wd + 12)
            s += '<rect x="%d" y="%d" width="%d" height="%d" fill="%s" opacity="%s"/>' % (x, base - bh, w, bh, col, op)
            if layer == 2:
                for wy in range(base - bh + 8, base - 8, 14):
                    for wx in range(x + 6, x + w - 8, 12):
                        if rnd.random() < .42: s += '<rect x="%d" y="%d" width="5" height="7" rx="1" fill="%s"/>' % (wx, wy, rnd.choice(['#FFC83D', '#FFC83D', '#3CD6F2', '#FF6BB8']))
            x += w + rnd.randint(0, 5)
    # palmiers
    for px, ph in ((22, 70), (352, 84)):
        s += '<path d="M%d %d Q%d %d %d %d" stroke="#0C0820" stroke-width="5" fill="none"/>' % (px, base, px + 6, base - ph / 2, px + 2, base - ph)
        for a in (-60, -25, 15, 50, 90, 130):
            import math
            ex = px + 2 + 30 * math.cos(math.radians(a - 90 + 0)); ey = base - ph + 30 * math.sin(math.radians(a - 90)) + 8
            s += '<path d="M%d %d Q%d %d %d %d" stroke="#0C0820" stroke-width="4" fill="none" stroke-linecap="round"/>' % (px + 2, base - ph, (px + 2 + ex) / 2, base - ph - 10, ex, ey)
    if title:
        s += '<text x="195" y="52" text-anchor="middle" font-family="Baloo 2" font-weight="800" font-size="30" fill="#FF6BB8" stroke="#F43F9D" stroke-width="1" opacity=".95" letter-spacing="6">NDOLO</text>'
    return _wrap(s, d, '0 0 390 %d' % h)

def openmic_bg():
    rnd = random.Random(5)
    d = ('<linearGradient id="om" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2A1245"/><stop offset="1" stop-color="#14102B"/></linearGradient>'
         '<linearGradient id="sp" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFE3A0" stop-opacity=".7"/><stop offset="1" stop-color="#FFE3A0" stop-opacity="0"/></linearGradient>')
    s = '<rect width="390" height="220" fill="url(#om)"/>'
    for r in range(4):
        for c in range(9):
            s += '<rect x="%d" y="%d" width="40" height="18" rx="2" fill="#3A1B52" opacity="%.2f"/>' % (c * 44 - 10 + (r % 2) * 22, 12 + r * 22, .5 + rnd.random() * .3)
    s += '<path d="M0 40 Q195 78 390 40" stroke="#14102B" stroke-width="2" fill="none"/>' + ''.join('<circle cx="%d" cy="%d" r="4.5" fill="%s"/>' % (14 + i * 31, 44 + (14 if i % 2 else 22) * (1 - abs(i - 6) / 7.0) + 18, '#FFC83D') for i in range(13))
    s += '<path d="M195 0 L120 168 L270 168Z" fill="url(#sp)"/><rect x="70" y="150" width="250" height="24" rx="6" fill="#2B2459" stroke="#3A3270" stroke-width="2"/>'
    s += '<rect x="193" y="96" width="4" height="54" fill="#B6B0DD"/><circle cx="195" cy="90" r="8" fill="#14102B" stroke="#B6B0DD" stroke-width="3"/>'
    s += '<rect x="0" y="176" width="390" height="44" fill="#0C0820"/>'
    for i in range(16):
        x = 14 + i * 24 + rnd.randint(-4, 4); y = 196 + rnd.randint(-6, 8)
        s += '<circle cx="%d" cy="%d" r="11" fill="#14102B" stroke="#2B2459" stroke-width="1.5"/><path d="M%d %d q-14 6 -14 30 h28 q0 -24 -14 -30z" fill="#14102B" stroke="#2B2459" stroke-width="1.5"/>' % (x, y, x, y + 10)
    return _wrap(s, d)

def burst():
    s = ''.join('<path d="M195 150 L%d 0 L%d 0Z" fill="#FFC83D" opacity=".%d"/>' % (i * 36 - 40, i * 36 + 4, 10 + (i % 3) * 4) for i in range(12))
    return _wrap(s, '', '0 0 390 300')

def vinyl():
    return ('<svg viewBox="0 0 100 100" aria-hidden="true"><circle cx="50" cy="50" r="46" fill="#14102B" opacity=".55"/><circle cx="50" cy="50" r="34" fill="none" stroke="#fff" stroke-opacity=".18" stroke-width="1"/>'
            '<circle cx="50" cy="50" r="26" fill="none" stroke="#fff" stroke-opacity=".14" stroke-width="1"/><circle cx="50" cy="50" r="12" fill="#FFC83D" opacity=".85"/><circle cx="50" cy="50" r="2.5" fill="#14102B"/></svg>')

def cover(size, letter='B', extra=''):
    return '<div class="cover" style="width:%dpx;height:%dpx;%s">%s<b>%s</b></div>' % (size, size, extra, vinyl(), letter)

def ban(h, art, chars=(), top='', tx='', cls=''):
    """bannière illustrée ; chars : [(who, mood, gesture, w, left, crop)]"""
    ch = ''
    for c in chars:
        who, mood, g, w, left = c[:5]; crop = c[5] if len(c) > 5 else 'torso'; pose = c[6] if len(c) > 6 else ''
        ratio = {'torso': 340 / 260, 'bust': 250 / 220}[crop]; hh = int(w * ratio)
        ch += '<div class="pc" style="left:%dpx;width:%dpx;height:%dpx;bottom:%dpx" role="img" aria-label="%s, aperçu provisoire">%s</div>' % (left, w, hh, 0 if hh <= h else h - hh, cast.CAST[who]['name'], cast.P(who, mood, g, PROV, crop, pose=pose))
    return '<div class="ban %s" style="height:%dpx">%s%s<div class="ov"></div>%s%s</div>' % (cls, h, art, ch, ('<div class="tp">%s</div>' % top) if top else '', ('<div class="tx">%s</div>' % tx) if tx else '')
