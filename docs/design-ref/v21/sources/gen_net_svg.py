# Miniatures SVG sans texte (compatibles flutter_svg) : 50 vidéos Klipo, 8 clips du joueur, 4 densités de public.
# Style : gradients profonds, faisceaux, silhouettes à liseré lumineux, vignettage. Déterministe (graine par index).
import sys, os, json, random, math
OUT = sys.argv[1]
W, H = 320, 180
PAL = [  # fond haut, fond bas, accent, accent 2
    ('#1A0B2E', '#05030D', '#F43F9D', '#8B5CF6'), ('#071E2E', '#02080F', '#3CD6F2', '#3DDC97'), ('#2A0E05', '#0A0402', '#FF8A3D', '#FFC83D'),
    ('#1B0B24', '#070210', '#FF6BB8', '#FFC83D'), ('#0B1530', '#03060F', '#5B8CFF', '#3CD6F2'), ('#1E0A0A', '#080202', '#FF3D5A', '#FF9F43'),
    ('#0A2420', '#020A08', '#3DDC97', '#C6FF5C'), ('#22102E', '#0A0412', '#B88CFF', '#F43F9D'), ('#2B1A05', '#0C0702', '#FFC83D', '#FFF1B8'),
    ('#0D0D1F', '#030308', '#E8E6FF', '#8B5CF6'), ('#132A3A', '#040B11', '#7FE7FF', '#F43F9D'), ('#2E0B1D', '#0C020A', '#FF4FB0', '#3CD6F2')]

def defs(uid, p, extra=''):
    a, b, c, d = p
    return ('<defs><linearGradient id="bg%s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient>'
            '<radialGradient id="gl%s" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="%s" stop-opacity=".85"/><stop offset="1" stop-color="%s" stop-opacity="0"/></radialGradient>'
            '<radialGradient id="g2%s" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="%s" stop-opacity=".7"/><stop offset="1" stop-color="%s" stop-opacity="0"/></radialGradient>'
            '<linearGradient id="be%s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="%s" stop-opacity=".55"/><stop offset="1" stop-color="%s" stop-opacity="0"/></linearGradient>'
            '<radialGradient id="vg%s" cx=".5" cy=".45" r=".75"><stop offset=".55" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".7"/></radialGradient>'
            '<linearGradient id="ft%s" x1="0" y1="0" x2="0" y2="1"><stop offset=".55" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".55"/></linearGradient>%s</defs>'
            % (uid, a, b, uid, c, c, uid, d, d, uid, c, c, uid, uid, extra))

def glow(uid, x, y, r, k='gl'): return '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="url(#%s%s)"/>' % (x, y, r, k, uid)
def beam(uid, x, top, spread, h, rot=0, op=1):
    return '<path d="M%.1f %.1f L%.1f %.1f L%.1f %.1f Z" fill="url(#be%s)" opacity="%.2f" transform="rotate(%.1f %.1f %.1f)"/>' % (x - 3, top, x - spread, top + h, x + spread, top + h, uid, op, rot, x, top)

FORCE = {}
def figure(x, y, s, pose, body='#06040C', rim='#F43F9D', hair='twist', hood=True, flip=False):
    if FORCE and s >= 0.7: hair = FORCE.get('hair', hair); rim = FORCE.get('rim', rim); body = FORCE.get('body', body)
    """Silhouette buste/plein pied stylisée ; (x, y) = pieds/bas du cadre ; s = échelle (1 ≈ 120 px de haut)."""
    g = []
    hy = y - 104 * s   # centre de la tête
    head = '<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f"/>' % (x, hy, 11 * s, 13 * s)
    hairp = ''
    if hair == 'twist':
        hairp = ''.join('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="%.1f"/>' % (x - 11 * s + i * 4.4 * s, hy - 22 * s - (i % 2) * 2 * s, 3.4 * s, 12 * s, 1.7 * s) for i in range(6))
    elif hair == 'afro':
        hairp = '<circle cx="%.1f" cy="%.1f" r="%.1f"/>' % (x, hy - 7 * s, 16 * s)
    elif hair == 'braids':
        hairp = '<path d="M%.1f %.1f q%.1f %.1f %.1f %.1f M%.1f %.1f q%.1f %.1f %.1f %.1f" stroke="%s" stroke-width="%.1f" fill="none"/>' % (
            x - 10 * s, hy - 6 * s, -6 * s, 22 * s, -2 * s, 44 * s, x + 10 * s, hy - 6 * s, 6 * s, 22 * s, 2 * s, 44 * s, body, 5 * s) + '<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f"/>' % (x, hy - 8 * s, 12.5 * s, 9 * s)
    elif hair == 'cap':
        hairp = '<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f"/><rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="%.1f"/>' % (x, hy - 5 * s, 12.5 * s, 9 * s, x - 2 * s, hy - 6 * s, 20 * s, 4 * s, 2 * s)
    neck = '<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f"/>' % (x - 5 * s, hy + 10 * s, 10 * s, 10 * s)
    torso = '<path d="M%.1f %.1f C%.1f %.1f %.1f %.1f %.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f C%.1f %.1f %.1f %.1f %.1f %.1f Z"/>' % (
        x - 30 * s, y - 40 * s, x - 31 * s, y - 72 * s, x - 22 * s, y - 82 * s, x - 6 * s, hy + 18 * s, x + 6 * s, hy + 18 * s,
        x + 6 * s, hy + 18 * s, x + 6 * s, hy + 18 * s, x + 22 * s, y - 82 * s, x + 31 * s, y - 72 * s, x + 30 * s, y - 40 * s)
    legs = '<path d="M%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f Z"/>' % (x - 24 * s, y - 42 * s, x - 18 * s, y, x - 6 * s, y, x, y - 22 * s, x + 6 * s, y, x + 22 * s, y - 42 * s)
    legs += '<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f"/>' % (x + 4 * s, y - 24 * s, 14 * s, 24 * s)
    hoodp = '<path d="M%.1f %.1f q%.1f %.1f %.1f 0"/>' % (x - 15 * s, hy + 14 * s, 15 * s, 10 * s, 30 * s) if hood else ''
    if pose == 'mic':      # bras levé, micro devant la bouche
        arm = '<path d="M%.1f %.1f L%.1f %.1f L%.1f %.1f" fill="none" stroke="{S}" stroke-width="%.1f" stroke-linecap="round" stroke-linejoin="round"/>' % (x + 22 * s, y - 78 * s, x + 30 * s, y - 56 * s, x + 12 * s, hy + 16 * s, 8 * s)
        arm += '<path d="M%.1f %.1f L%.1f %.1f" stroke="{S}" stroke-width="%.1f" stroke-linecap="round"/><circle cx="%.1f" cy="%.1f" r="%.1f"/>' % (x + 12 * s, hy + 16 * s, x + 16 * s, hy + 26 * s, 3.2 * s, x + 9.5 * s, hy + 11 * s, 4 * s)
    elif pose == 'up':     # bras tendu vers le ciel
        arm = '<path d="M%.1f %.1f L%.1f %.1f L%.1f %.1f" fill="none" stroke="{S}" stroke-width="%.1f" stroke-linecap="round" stroke-linejoin="round"/><circle cx="%.1f" cy="%.1f" r="%.1f"/>' % (x + 22 * s, y - 80 * s, x + 36 * s, hy - 2 * s, x + 32 * s, hy - 26 * s, 8 * s, x + 32 * s, hy - 29 * s, 5.5 * s)
    elif pose == 'point':
        arm = '<path d="M%.1f %.1f L%.1f %.1f" fill="none" stroke="{S}" stroke-width="%.1f" stroke-linecap="round"/><circle cx="%.1f" cy="%.1f" r="%.1f"/>' % (x + 22 * s, y - 78 * s, x + 56 * s, y - 94 * s, 8 * s, x + 58 * s, y - 95 * s, 5 * s)
    else:
        arm = ''
    shape = head + hairp + neck + torso + legs + arm + hoodp
    tr = ' transform="translate(%.1f 0) scale(-1 1)"' % (2 * x) if flip else ''
    # liseré : même forme décalée, couleur d'accent, puis corps par-dessus
    return ('<g%s><g fill="%s" stroke="%s" stroke-width="%.1f" opacity=".95">%s</g><g fill="%s" transform="translate(%.1f 0)">%s</g></g>'
            % (tr, rim, rim, 2.2 * s, shape.replace('{S}', rim), body, 2.4 * s, shape.replace('{S}', body)))

def crowd(rnd, y0, n, rows, col='#040208', rim=None, hands=0.25, phones=0, pcol='#FFF6D8', w=W):
    g = []
    for r in range(rows):
        yy = y0 + r * 14; sz = 1 + r * 0.25
        for i in range(n + r * 2):
            x = (i + rnd.random() * 0.8) * (w / (n + r * 2)) + rnd.uniform(-4, 4)
            hr = rnd.uniform(6, 8.5) * sz
            g.append('<circle cx="%.1f" cy="%.1f" r="%.1f"/>' % (x, yy - hr, hr))
            g.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="%.1f"/>' % (x - hr * 1.7, yy, hr * 3.4, 60, hr))
            if rnd.random() < hands:
                hx = x + rnd.choice([-1, 1]) * hr * 1.2
                g.append('<path d="M%.1f %.1f L%.1f %.1f" stroke="%s" stroke-width="%.1f" stroke-linecap="round"/>' % (x, yy + 4, hx, yy - hr * 3.6, col, hr * 0.7))
                if rnd.random() < phones:
                    g.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="1" fill="%s"/><circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s" opacity=".25"/>' % (hx - 2.2, yy - hr * 4.6, 4.4, 6.5, pcol, hx, yy - hr * 4.3, 9, pcol))
    st = ' stroke="%s" stroke-width=".8"' % rim if rim else ''
    return '<g fill="%s"%s>%s</g>' % (col, st, ''.join(g))

def skyline(rnd, base, col, win, n=16, maxh=70, w=W):
    g = []; x = -4
    while x < w:
        bw = rnd.uniform(14, 30); bh = rnd.uniform(18, maxh)
        g.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"/>' % (x, base - bh, bw, bh + 1, col))
        for wy in range(int(base - bh + 6), int(base - 4), 7):
            for wx in range(int(x + 3), int(x + bw - 3), 6):
                if rnd.random() < 0.18: g.append('<rect x="%d" y="%d" width="2.4" height="3" fill="%s" opacity="%.2f"/>' % (wx, wy, win, rnd.uniform(.4, .95)))
        x += bw + rnd.uniform(0, 3)
    return ''.join(g)

def waves(y, col, n=5, amp=3, op=.5):
    return ''.join('<path d="M0 %.1f %s" stroke="%s" stroke-width="1.2" fill="none" opacity="%.2f"/>' % (
        y + i * 7, ' '.join('Q%.1f %.1f %.1f %.1f' % (k * 40 + 20, y + i * 7 - amp, k * 40 + 40, y + i * 7) for k in range(9)), col, op * (1 - i / (n + 1))) for i in range(n))

def wrap(uid, p, body, extra='', w=W, h=H):
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d" preserveAspectRatio="xMidYMid slice">%s'
            '<rect width="%d" height="%d" fill="url(#bg%s)"/>%s<rect width="%d" height="%d" fill="url(#vg%s)"/><rect width="%d" height="%d" fill="url(#ft%s)"/></svg>'
            % (w, h, w, h, defs(uid, p, extra), w, h, uid, body, w, h, uid, w, h, uid))

# ---------- compositions ----------
def c_city(rnd, uid, p):
    a, b, c, d = p
    moon = glow(uid, rnd.uniform(60, 260), rnd.uniform(36, 60), 70) + '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s" opacity=".9"/>' % (rnd.uniform(200, 280), 44, rnd.uniform(9, 14), d)
    far = skyline(rnd, 140, '#000', c, maxh=60)
    near = skyline(random.Random(rnd.random()), 168, '#000', d, maxh=95)
    fig = figure(rnd.uniform(110, 210), 180, rnd.uniform(1.1, 1.35), rnd.choice(['mic', 'stand', 'up']), rim=c, hair=rnd.choice(['twist', 'cap', 'afro']))
    return moon + '<g opacity=".55">' + far + '</g>' + glow(uid, 160, 150, 160, 'g2') + '<g opacity=".9">' + near + '</g>' + fig

def c_lagoon(rnd, uid, p):
    a, b, c, d = p; sx = rnd.uniform(90, 230)
    sun = glow(uid, sx, 92, 110) + '<circle cx="%.1f" cy="92" r="26" fill="%s"/>' % (sx, d)
    bands = ''.join('<rect x="%.1f" y="%.1f" width="%.1f" height="2" fill="#000" opacity=".55"/>' % (sx - 30, 96 + i * 5, 60, ) for i in range(4))
    water = '<rect y="104" width="320" height="76" fill="#000" opacity=".45"/>' + waves(110, c, 7, 2.5, .8)
    refl = ''.join('<rect x="%.1f" y="%.1f" width="%.1f" height="1.6" rx=".8" fill="%s" opacity="%.2f"/>' % (sx - 30 + rnd.uniform(-8, 8), 112 + i * 6, rnd.uniform(20, 60), d, .7 - i * .07) for i in range(9))
    palms = ''.join('<path d="M%.1f 106 q%.1f -30 %.1f -60" stroke="#000" stroke-width="3" fill="none"/><g fill="#000">%s</g>' % (
        px, 6, 10, ''.join('<path d="M%.1f 46 q%.1f %.1f %.1f %.1f q%.1f %.1f %.1f %.1f z"/>' % (px + 10, dx * 8, -6, dx * 22, 6, -dx * 10, -4, -dx * 22, -4) for dx in (-1, 1, -0.6, 0.6))) for px in (rnd.uniform(14, 40), rnd.uniform(270, 300)))
    pirogue = '<path d="M%.1f 132 q30 8 60 0 l-6 6 q-24 5 -48 0z" fill="#000"/>' % rnd.uniform(40, 200)
    return sun + bands + water + refl + palms + pirogue

def c_portrait(rnd, uid, p):
    a, b, c, d = p; x = rnd.uniform(130, 190)
    rings = ''.join('<circle cx="%.1f" cy="80" r="%d" fill="none" stroke="%s" stroke-width="1" opacity="%.2f"/>' % (x, r, c, .5 - r / 300) for r in range(30, 150, 18))
    side = glow(uid, x - 70, 70, 110) + glow(uid, x + 90, 120, 90, 'g2')
    smoke = ''.join('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" opacity=".08"/>' % (rnd.uniform(0, 320), rnd.uniform(100, 170), rnd.uniform(40, 90), rnd.uniform(10, 20), d) for _ in range(6))
    return side + rings + smoke + figure(x, 250, 1.8, rnd.choice(['stand', 'mic']), rim=c, hair=rnd.choice(['twist', 'braids', 'afro', 'cap']))

def c_gbaka(rnd, uid, p):
    a, b, c, d = p
    road = '<path d="M0 150 L320 150 L320 180 L0 180Z" fill="#000" opacity=".6"/>' + ''.join('<rect x="%d" y="163" width="18" height="2.5" fill="%s" opacity=".7"/>' % (x, d) for x in range(0, 320, 34))
    bx = rnd.uniform(70, 140)
    bus = ('<g><rect x="%.1f" y="104" width="150" height="44" rx="10" fill="#000"/><rect x="%.1f" y="98" width="120" height="10" rx="5" fill="#000"/>'
           '%s<circle cx="%.1f" cy="150" r="9" fill="#000" stroke="%s" stroke-width="2"/><circle cx="%.1f" cy="150" r="9" fill="#000" stroke="%s" stroke-width="2"/>'
           '<rect x="%.1f" y="124" width="10" height="5" rx="2" fill="%s"/></g>') % (
        bx, bx + 12, ''.join('<rect x="%.1f" y="110" width="20" height="14" rx="3" fill="%s" opacity=".85"/>' % (bx + 10 + k * 26, c if k % 2 else d) for k in range(5)), bx + 30, c, bx + 120, c, bx + 140, d)
    head = beam(uid, bx + 150, 126, 40, 120, -90, .8)
    trails = ''.join('<rect x="0" y="%.1f" width="%.1f" height="1.4" fill="%s" opacity=".6"/>' % (130 + k * 5, bx - 6, c if k % 2 else d) for k in range(4))
    return skyline(rnd, 104, '#000', d, maxh=50) + glow(uid, bx + 75, 120, 140, 'g2') + road + trails + bus + head

def c_live(rnd, uid, p):
    a, b, c, d = p; fx = rnd.uniform(120, 200)
    truss = '<rect x="0" y="10" width="320" height="5" fill="#000"/>' + ''.join('<path d="M%d 10 l6 5 l6 -5" stroke="#222" fill="none"/>' % x for x in range(0, 320, 12))
    beams = ''.join(beam(uid, x, 14, rnd.uniform(26, 44), 160, rnd.uniform(-25, 25), .75) for x in (30, 90, 160, 230, 290))
    stage = '<rect y="128" width="320" height="10" fill="#000"/>' + glow(uid, fx, 100, 90)
    haze = '<rect y="60" width="320" height="70" fill="%s" opacity=".08"/>' % c
    return truss + beams + haze + stage + figure(fx, 130, 0.95, rnd.choice(['mic', 'up']), rim=d, hair=rnd.choice(['twist', 'braids', 'afro'])) + crowd(rnd, 150, 11, 3, hands=.45, phones=.5)

def c_freestyle(rnd, uid, p):
    a, b, c, d = p; lx = rnd.uniform(90, 230)
    lamp = '<rect x="%.1f" y="18" width="3" height="140" fill="#000"/><path d="M%.1f 18 h20 v4 h-20z" fill="#000"/>' % (lx, lx) + beam(uid, lx + 18, 22, 60, 150, 0, .9) + glow(uid, lx + 18, 24, 26)
    wall = ''.join('<rect x="%d" y="%d" width="22" height="9" fill="#000" opacity=".25"/>' % (x + (y // 10 % 2) * 11, y) for y in range(20, 150, 11) for x in range(-11, 320, 24))
    tag = '<path d="M30 60 q20 -30 40 0 t40 0" stroke="%s" stroke-width="5" fill="none" opacity=".35" stroke-linecap="round"/>' % d
    ring = ''.join(figure(x, 180, .62, 'stand', rim=c, hair=rnd.choice(['cap', 'twist', 'afro']), flip=(x > lx)) for x in (lx - 90, lx - 55, lx + 95, lx + 130))
    return wall + tag + lamp + '<rect y="150" width="320" height="30" fill="#000" opacity=".5"/>' + ring + figure(lx + 18, 172, 1.05, 'mic', rim=d, hair='twist')

def c_studio(rnd, uid, p):
    a, b, c, d = p
    glass = '<rect x="40" y="18" width="240" height="78" rx="6" fill="%s" opacity=".12" stroke="%s" stroke-opacity=".4"/>' % (c, c) + glow(uid, 160, 56, 80)
    singer = figure(160, 100, .75, 'mic', rim=c, hair=rnd.choice(['twist', 'braids', 'afro']))
    console = '<path d="M0 120 L320 108 L320 180 L0 180Z" fill="#000"/>' + ''.join(
        '<rect x="%.1f" y="%.1f" width="5" height="%.1f" rx="2" fill="%s" opacity=".9"/>' % (20 + k * 9.5, 150 - h, h, c if h < 22 else d) for k, h in ((k, rnd.uniform(4, 30)) for k in range(30)))
    knobs = ''.join('<circle cx="%.1f" cy="%.1f" r="2.2" fill="%s" opacity=".7"/>' % (24 + k * 9.5, 128 - k * .37, d) for k in range(30))
    mon = '<rect x="6" y="70" width="34" height="50" rx="4" fill="#000"/><circle cx="23" cy="104" r="9" fill="none" stroke="%s"/><rect x="280" y="70" width="34" height="50" rx="4" fill="#000"/><circle cx="297" cy="104" r="9" fill="none" stroke="%s"/>' % (c, c)
    phones = '<path d="M210 168 a22 22 0 0 1 44 0" stroke="%s" stroke-width="4" fill="none"/><rect x="204" y="160" width="10" height="16" rx="4" fill="%s"/><rect x="250" y="160" width="10" height="16" rx="4" fill="%s"/>' % (d, d, d)
    return glass + singer + console + knobs + mon + phones

def c_visual(rnd, uid, p):
    a, b, c, d = p; kind = rnd.randrange(3); cx = rnd.uniform(110, 210)
    if kind == 0:    # spectre radial
        g = glow(uid, cx, 90, 120) + ''.join('<rect x="%.1f" y="%.1f" width="3" height="%.1f" rx="1.5" fill="%s" transform="rotate(%.1f %.1f 90)"/>' % (
            cx - 1.5, 90 - 30 - h, h, c if k % 3 else d, k * 6, cx) for k, h in ((k, 6 + 26 * abs(math.sin(k * .37 + rnd.random()))) for k in range(60)))
        g += '<circle cx="%.1f" cy="90" r="26" fill="#000"/><circle cx="%.1f" cy="90" r="26" fill="none" stroke="%s" stroke-width="2"/>' % (cx, cx, d)
    elif kind == 1:  # onde horizontale
        g = glow(uid, 160, 90, 150) + ''.join('<rect x="%.1f" y="%.1f" width="4" height="%.1f" rx="2" fill="%s" opacity="%.2f"/>' % (
            8 + k * 7.6, 90 - h / 2, h, c if k % 4 else d, .55 + .45 * (h / 110)) for k, h in ((k, 6 + 100 * abs(math.sin(k * .21) * math.cos(k * .07 + rnd.random()))) for k in range(40)))
    else:            # géométrie
        g = glow(uid, cx, 90, 130) + ''.join('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="none" stroke="%s" stroke-width="1.5" opacity="%.2f" transform="rotate(%.1f %.1f 90)"/>' % (
            cx - r, 90 - r, 2 * r, 2 * r, c if r % 2 else d, 1 - r / 110, r * 1.8, cx) for r in range(12, 100, 9))
    return g

def c_battle(rnd, uid, p):
    a, b, c, d = p
    split = '<path d="M0 0 L190 0 L130 180 L0 180Z" fill="%s" opacity=".18"/><path d="M190 0 L320 0 L320 180 L130 180Z" fill="%s" opacity=".18"/>' % (c, d)
    bolt = '<path d="M174 10 L150 84 L170 84 L142 172 L196 74 L174 74 L196 10Z" fill="%s"/>' % '#FFF6D8' + glow(uid, 168, 90, 60)
    return (split + glow(uid, 70, 90, 90) + glow(uid, 250, 90, 90, 'g2') + bolt
            + figure(80, 210, 1.55, 'point', rim=c, hair=rnd.choice(['twist', 'cap'])) + figure(240, 210, 1.55, 'mic', rim=d, hair=rnd.choice(['afro', 'braids']), flip=True)
            + crowd(rnd, 168, 12, 1, hands=.3))

def c_rooftop(rnd, uid, p):
    a, b, c, d = p
    stars = ''.join('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="#FFF" opacity="%.2f"/>' % (rnd.uniform(0, 320), rnd.uniform(0, 90), rnd.uniform(.4, 1.1), rnd.uniform(.3, .9)) for _ in range(60))
    mx = rnd.uniform(60, 260); moon = glow(uid, mx, 50, 90) + '<circle cx="%.1f" cy="50" r="30" fill="%s" opacity=".95"/><circle cx="%.1f" cy="44" r="30" fill="url(#bg%s)" opacity=".35"/>' % (mx, d, mx + 9, uid)
    city = '<g opacity=".8">' + skyline(rnd, 150, '#05030A', c, maxh=34) + '</g>' + glow(uid, 160, 160, 170, 'g2')
    roof = '<path d="M0 150 L320 150 L320 180 L0 180Z" fill="#000"/><rect x="18" y="128" width="26" height="22" fill="#000"/><path d="M24 128 v-14 h4 v14" fill="#000"/><rect x="250" y="134" width="40" height="16" fill="#000"/>'
    return stars + moon + city + roof + figure(rnd.uniform(130, 190), 152, .95, rnd.choice(['up', 'stand']), rim=c, hair=rnd.choice(['twist', 'braids', 'cap']))

def c_neon(rnd, uid, p):
    a, b, c, d = p; cx = rnd.uniform(120, 200); sh = rnd.randrange(3)
    if sh == 0: tube = '<circle cx="%.1f" cy="86" r="62" fill="none" stroke="%s" stroke-width="%s"/>'
    elif sh == 1: tube = '<path d="M%.1f 20 L%%.1f 150 L%%.1f 150 Z" fill="none" stroke="%%s" stroke-width="%%s" stroke-linejoin="round"/>'
    else: tube = '<rect x="%%.1f" y="22" width="120" height="130" rx="14" fill="none" stroke="%%s" stroke-width="%%s"/>'
    def t(col, w):
        if sh == 0: return tube % (cx, col, w)
        if sh == 1: return ('<path d="M%.1f 18 L%.1f 152 L%.1f 152 Z" fill="none" stroke="%s" stroke-width="%s" stroke-linejoin="round"/>' % (cx, cx - 78, cx + 78, col, w))
        return '<rect x="%.1f" y="22" width="120" height="130" rx="14" fill="none" stroke="%s" stroke-width="%s"/>' % (cx - 60, col, w)
    floor = '<rect y="150" width="320" height="30" fill="#000" opacity=".7"/>' + ''.join('<path d="M160 150 L%d 180" stroke="%s" stroke-width=".8" opacity=".35"/>' % (x, c) for x in range(-200, 540, 40))
    return glow(uid, cx, 86, 120) + t(c, 10) + '<g opacity=".5">' + t(c, 18) + '</g>' + t('#FFF6F0', 2.5) + floor + figure(cx, 152, .95, rnd.choice(['mic', 'stand']), rim=d, hair=rnd.choice(['twist', 'afro', 'braids']))

def c_tunnel(rnd, uid, p):
    a, b, c, d = p; vx, vy = 160 + rnd.uniform(-30, 30), 82
    frames = ''.join('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="%.1f" fill="none" stroke="%s" stroke-width="%.1f" opacity="%.2f"/>' % (
        vx - 18 * k, vy - 10 * k, 36 * k, 20 * k, 2 * k, c if k % 2 else d, .3 + k * .12, 1 - k / 12) for k in range(1, 11))
    lines = ''.join('<path d="M%.1f %.1f L%.1f %.1f" stroke="%s" stroke-width=".8" opacity=".4"/>' % (vx, vy, x, y, c) for x, y in ((0, 0), (320, 0), (0, 180), (320, 180), (0, 90), (320, 90), (160, 180), (160, 0)))
    return glow(uid, vx, vy, 60) + lines + frames + figure(vx, 176, 1.0, rnd.choice(['stand', 'up']), rim=d, hair=rnd.choice(['twist', 'cap', 'afro']))

COMP = {'Clip officiel': [c_city, c_lagoon, c_portrait, c_gbaka, c_rooftop, c_neon, c_tunnel], 'Live': [c_live], 'Freestyle': [c_freestyle], 'Coulisses': [c_studio], 'Visualizer': [c_visual], 'Battle': [c_battle]}

def klipo(items):
    os.makedirs(os.path.join(OUT, 'assets/klipo/thumbs'), exist_ok=True)
    seen = {}
    for i, it in enumerate(items):
        rnd = random.Random(1000 + i * 7919); p = PAL[(i * 5) % len(PAL)]
        lst = COMP[it['k']]; k = seen.get(it['k'], 0); seen[it['k']] = k + 1
        body = lst[k % len(lst)](rnd, 'k%d' % i, p)
        open(os.path.join(OUT, it['img']), 'w').write(wrap('k%d' % i, p, body))

def mine():
    # clips du joueur : même rappeur (twists hi-top, sweat rose, chaîne), 8 ambiances
    os.makedirs(os.path.join(OUT, 'assets/klipo/mine'), exist_ok=True)
    comps = [c_city, c_lagoon, c_portrait, c_gbaka, c_live, c_rooftop, c_neon, c_tunnel]
    FORCE.update(hair='twist', rim='#F43F9D', body='#12040E')
    for i, f in enumerate(comps):
        rnd = random.Random(500 + i * 31); p = PAL[[0, 3, 11, 7, 2, 1, 5, 8][i]]; uid = 'm%d' % i
        body = f(rnd, uid, p)
        # signature visuelle de Djo : silhouette rose au premier plan (sauf scènes déjà centrées sur un personnage)
        if f in (c_lagoon, c_gbaka):
            body += figure(160, 196, 1.25, 'mic', body='#1A0614', rim='#F43F9D', hair='twist')
        body += '<circle cx="%.1f" cy="%.1f" r="2.6" fill="#FFC83D"/>' % (12, 12)   # repère discret : pastille or
        open(os.path.join(OUT, 'assets/klipo/mine/M%d.svg' % (i + 1)), 'w').write(wrap(uid, p, body))
    FORCE.clear()

def crowds():
    # vue depuis la fosse : scène, écran LED (zone laissée vide pour le nom du média, posé en texte par l'interface), public selon la densité
    os.makedirs(os.path.join(OUT, 'assets/scene'), exist_ok=True)
    w, h = 390, 220; p = ('#1A0B2E', '#05030D', '#F43F9D', '#3CD6F2')
    for lvl, (n, rows, hands, phones, light) in enumerate([(6, 1, .1, 0, .35), (8, 2, .25, .2, .6), (13, 3, .45, .45, .85), (18, 4, .7, .7, 1)], 1):
        rnd = random.Random(77 + lvl); uid = 'c%d' % lvl
        led = ('<rect x="95" y="22" width="200" height="64" rx="6" fill="#06040C" stroke="#2B2459" stroke-width="3"/>'
               '<rect x="101" y="28" width="188" height="52" rx="3" fill="url(#led%s)"/>' % uid
               + ''.join('<rect x="%d" y="28" width="1" height="52" fill="#000" opacity=".25"/>' % x for x in range(104, 289, 4)))
        extra = '<linearGradient id="led%s" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3A1B52"/><stop offset="1" stop-color="#14102B"/></linearGradient>' % uid
        truss = '<rect width="390" height="8" fill="#000"/>' + ''.join('<circle cx="%d" cy="10" r="4" fill="%s"/>' % (x, '#FFF6D8') for x in range(30, 390, 55))
        beams = ''.join(beam(uid, x, 10, rnd.uniform(26, 40), 200, rnd.uniform(-22, 22), light) for x in range(30, 390, 55))
        stage = '<rect y="112" width="390" height="14" fill="#000"/>' + glow(uid, 195, 100, 120)
        perf = figure(195, 114, .75, 'mic', rim='#F43F9D', hair='twist')
        ppl = crowd(rnd, 140, n, rows, hands=hands, phones=phones, w=w)
        body = beams + truss + led + stage + perf + ppl
        svg = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d" preserveAspectRatio="xMidYMid slice">%s<rect width="%d" height="%d" fill="url(#bg%s)"/>%s<rect width="%d" height="%d" fill="url(#vg%s)"/></svg>'
               % (w, h, w, h, defs(uid, p, extra), w, h, uid, body, w, h, uid))
        open(os.path.join(OUT, 'assets/scene/crowd_%d.svg' % lvl), 'w').write(svg)

if __name__ == '__main__':
    items = json.load(open(sys.argv[2]))
    klipo(items); mine(); crowds(); print('ok', len(items))
