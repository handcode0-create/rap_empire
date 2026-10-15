from chars import *
import chars as K

def _twist_block(c, hc, x0, x1, y0, y1, n=30, seed=3):
    hi = lighten(hc, .45); o = []
    for i in range(n):
        x = x0 + (i * 37 + seed) % int(x1 - x0); y = y0 + (i * 17 + seed) % int(y1 - y0)
        o.append('<circle cx="%d" cy="%d" r="5.2" fill="%s"/><path d="M%d %d l2.6 2.6" stroke="%s" stroke-opacity=".6" stroke-width="1.6" stroke-linecap="round"/>' % (x, y, c.paint(hc), x - 1, y - 2, hi))
    return ''.join(o)

def head_view(c, view, skin, hair, hc, beard, mood, acc):
    o = []
    sk = c.radial(skin, '.45', '.32')
    hi = lighten(hc, .45)
    if view == 'side':
        o.append('<path d="M126 140 L170 140 L174 178 L122 178Z" fill="%s" %s/><path d="M122 164 Q148 184 174 164 L174 178 L122 178Z" fill="%s" fill-opacity=".3"/>' % (c.paint(skin), c.ol, darken(skin, .5)))
        head = 'M102 82 C100 40 124 30 152 30 C182 30 198 50 198 74 Q200 86 204 94 Q214 102 216 108 Q210 112 208 116 Q211 121 208 125 Q211 131 202 135 Q200 144 188 150 Q166 154 146 148 Q116 138 108 112 Q102 98 102 82Z'
        o.append('<path d="%s" fill="%s" %s/>' % (head, sk, c.ol))
        if c.style != '2d': o.append('<path d="M120 126 Q150 156 190 146 Q172 140 150 138 Q132 134 120 126Z" fill="%s" fill-opacity=".22"/>' % darken(skin, .55))
        if beard == 'stubble': o.append('<path d="M126 114 Q146 150 186 148 Q200 142 202 134 Q190 138 172 132 Q152 126 142 110Z" fill="%s" fill-opacity=".4"/>' % hc)
        if beard == 'full': o.append('<path d="M120 100 Q130 150 186 150 Q200 142 202 134 Q186 132 176 122 Q150 124 138 104Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
        o.append('<path d="M174 74 Q188 66 204 74" fill="none" stroke="%s" stroke-width="5" stroke-linecap="round"/>' % darken(hc, .15))
        o.append('<path d="M176 86 Q190 76 204 86 Q190 94 176 86Z" fill="#FBF6F2"/><circle cx="194" cy="85" r="6" fill="%s"/><circle cx="195" cy="85" r="3" fill="#140C08"/><circle cx="192" cy="82.6" r="2" fill="#fff"/><path d="M174 85 Q190 72 206 85" fill="none" stroke="#1A0F0A" stroke-width="3" stroke-linecap="round"/>' % c.radial('#6B3F23'))
        o.append('<path d="M204 98 Q212 106 214 108 Q208 112 202 112" fill="%s" fill-opacity=".3"/>' % darken(skin, .5))
        o.append('<path d="M198 124 Q206 124 210 122" stroke="%s" stroke-width="3" fill="none" stroke-linecap="round"/>' % darken(warm(skin, .5), .4))
        o.append('<ellipse cx="138" cy="98" rx="12" ry="18" fill="%s" %s/><path d="M134 90 Q142 96 136 108" stroke="%s" stroke-width="3" fill="none" stroke-opacity=".5" stroke-linecap="round"/>' % (c.paint(skin), c.ol, darken(skin, .5)))
        o.append('<path d="M102 82 Q96 38 128 28 Q150 22 156 36 Q124 44 122 80 Q124 100 134 112 Q110 108 102 82Z" fill="%s" fill-opacity=".92" %s/>' % (hc, c.ol))
        if hair in ('hitwist', 'fade'):
            o.append('<path d="M104 60 Q100 8 150 6 Q196 8 194 54 Q150 38 116 56Z" fill="%s" %s/>' % (c.paint(hc), c.ol) + _twist_block(c, hc, 112, 176, 12, 40))
        else:
            o.append('<path d="M104 60 Q100 8 150 6 Q196 8 194 54 Q150 38 116 56Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
        if 'ring' in acc: o.append('<circle cx="138" cy="116" r="4.5" fill="none" stroke="#FFC83D" stroke-width="2.6"/>')
        if 'glasses' in acc: o.append('<rect x="176" y="74" width="30" height="22" rx="8" fill="#10122A" fill-opacity=".85" stroke="#14102B" stroke-width="3"/><path d="M176 84 L146 90" stroke="#14102B" stroke-width="3"/>')
        if 'phones' in acc: o.append('<path d="M110 70 Q112 20 156 20 Q190 22 196 56" stroke="#2B2459" stroke-width="8" fill="none"/><rect x="128" y="82" width="20" height="34" rx="10" fill="#F43F9D" %s/>' % c.ol)
        if 'cap' in acc: o.append('<path d="M102 62 Q104 22 152 20 Q196 22 198 60 Q150 52 102 62Z" fill="%s" %s/><path d="M190 58 Q222 56 236 64 Q214 70 190 66Z" fill="%s" %s/>' % (c.paint('#14102B'), c.ol, c.paint('#F43F9D'), c.ol))
    elif view == 'back':
        o.append('<path d="M128 138 L172 138 L174 176 L126 176Z" fill="%s" %s/>' % (c.paint(darken(skin, .1)), c.ol))
        for x in (104, 196): o.append('<ellipse cx="%d" cy="96" rx="9" ry="15" fill="%s" %s/>' % (x, c.paint(skin), c.ol))
        o.append('<path d="M104 84 C104 44 126 34 150 34 C174 34 196 44 196 84 C196 112 180 140 150 148 C120 140 104 112 104 84Z" fill="%s" %s/>' % (sk, c.ol))
        o.append('<path d="M104 90 Q100 40 150 24 Q200 40 196 90 Q192 112 176 124 Q150 108 124 124 Q108 112 104 90Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
        o.append('<path d="M104 90 Q108 112 124 124 Q150 108 176 124 Q192 112 196 90 Q190 118 150 134 Q110 118 104 90Z" fill="%s" fill-opacity=".35"/>' % lighten(hc, .1))
        o.append('<path d="M112 12 Q150 2 188 12 Q196 40 190 58 Q150 44 110 58 Q104 40 112 12Z" fill="%s" %s/>' % (c.paint(hc), c.ol) + _twist_block(c, hc, 114, 178, 14, 44, 34, 5))
        for x in (126, 142, 158, 174): o.append('<path d="M%d 96 L%d 124" stroke="%s" stroke-opacity=".35" stroke-width="2" stroke-linecap="round"/>' % (x, x, lighten(hc, .6)))
        if 'ring' in acc: o.append('<circle cx="104" cy="108" r="4.5" fill="none" stroke="#FFC83D" stroke-width="2.6"/>')
        if 'cap' in acc: o.append('<path d="M100 66 Q100 22 150 20 Q200 22 200 66 Q150 76 100 66Z" fill="%s" %s/>' % (c.paint('#14102B'), c.ol))
        if 'phones' in acc: o.append('<path d="M100 92 Q100 22 150 22 Q200 22 200 92" stroke="#2B2459" stroke-width="9" fill="none" stroke-linecap="round"/><rect x="92" y="78" width="16" height="34" rx="8" fill="#F43F9D" %s/><rect x="192" y="78" width="16" height="34" rx="8" fill="#F43F9D" %s/>' % (c.ol, c.ol))
    else:  # three-quarter, tourné vers la droite
        o.append('<path d="M132 138 L172 138 L174 178 Q152 196 130 178Z" fill="%s" %s/><path d="M130 164 Q152 184 174 164 L174 178 Q152 196 130 178Z" fill="%s" fill-opacity=".33"/>' % (c.paint(skin), c.ol, darken(skin, .5)))
        o.append('<ellipse cx="110" cy="96" rx="9" ry="16" fill="%s" %s/><ellipse cx="112" cy="97" rx="4" ry="8" fill="%s" fill-opacity=".5"/>' % (c.paint(skin), c.ol, darken(skin, .3)))
        o.append('<path d="M106 84 C104 44 128 34 154 34 C182 34 202 48 202 78 C204 104 192 134 160 148 C130 146 108 124 106 84Z" fill="%s" %s/>' % (sk, c.ol))
        if c.style != '2d': o.append('<path d="M122 126 Q152 160 184 128 Q172 148 154 150 Q134 148 122 126Z" fill="%s" fill-opacity=".22"/>' % darken(skin, .55))
        if c.style == '3d': o.append('<ellipse cx="124" cy="112" rx="10" ry="7" fill="#FF7A8A" fill-opacity=".22"/><ellipse cx="184" cy="112" rx="8" ry="6" fill="#FF7A8A" fill-opacity=".18"/>')
        if beard == 'stubble': o.append('<path d="M108 92 Q112 136 156 150 Q196 136 200 92 Q188 124 158 126 Q122 124 108 92Z" fill="%s" fill-opacity=".38"/>' % hc)
        if beard == 'full': o.append('<path d="M106 90 Q108 140 156 152 Q200 138 202 90 Q190 118 172 122 Q154 114 136 122 Q116 118 106 90Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
        o.append('<path d="M122 76 Q136 70 148 76 M164 76 Q176 70 190 74" fill="none" stroke="%s" stroke-width="5" stroke-linecap="round"/>' % darken(hc, .15))
        o.append(K.eyes(c, skin, 136, 174, 92, far=.82, look=2))
        o.append('<path d="M162 98 Q170 110 178 116 Q172 122 162 119" fill="%s" fill-opacity=".38"/><ellipse cx="166" cy="118" rx="2.4" ry="1.7" fill="%s" fill-opacity=".7"/><path d="M160 90 Q164 104 170 112" stroke="%s" stroke-opacity=".5" stroke-width="3" fill="none" stroke-linecap="round"/>' % (darken(skin, .28), darken(skin, .5), lighten(skin, .5)))
        o.append(K.mouth(c, skin, 162, 130, 12, mood))
        if hair in ('hitwist', 'fade'):
            o.append('<path d="M112 54 Q108 8 154 6 Q196 8 196 54 Q154 40 112 54Z" fill="%s" %s/>' % (c.paint(hc), c.ol) + _twist_block(c, hc, 120, 182, 12, 42, 28, 7))
            o.append('<path d="M106 82 Q100 56 114 48 L118 72Z" fill="%s" fill-opacity=".5"/>' % hc)
        else:
            o.append('<path d="M112 54 Q108 8 154 6 Q196 8 196 54 Q154 40 112 54Z" fill="%s" %s/>' % (c.paint(hc), c.ol))
        if 'ring' in acc: o.append('<circle cx="110" cy="110" r="4.5" fill="none" stroke="#FFC83D" stroke-width="2.6"/>')
        if 'glasses' in acc: o.append('<rect x="118" y="80" width="34" height="24" rx="9" fill="#10122A" fill-opacity=".85" stroke="#14102B" stroke-width="3"/><rect x="156" y="80" width="30" height="24" rx="9" fill="#10122A" fill-opacity=".85" stroke="#14102B" stroke-width="3"/><path d="M152 90 L156 90 M118 90 L108 92" stroke="#14102B" stroke-width="3"/>')
        if 'cap' in acc: o.append('<path d="M102 66 Q104 22 154 20 Q202 22 204 66 Q154 56 102 66Z" fill="%s" %s/><path d="M150 62 Q200 56 236 68 Q200 76 150 70Z" fill="%s" %s/>' % (c.paint('#14102B'), c.ol, c.paint('#F43F9D'), c.ol))
        if 'phones' in acc: o.append('<path d="M102 94 Q102 22 152 22 Q202 22 204 90" stroke="#2B2459" stroke-width="9" fill="none" stroke-linecap="round"/><rect x="96" y="80" width="16" height="34" rx="8" fill="#F43F9D" %s/>' % c.ol)
    return ''.join(o)

def _legs_basic(c, of, back=False):
    p = of['pants']
    o = ['<path d="M88 340 L212 340 L220 548 Q220 560 208 560 L156 560 L150 416 L144 560 L92 560 Q80 560 80 548Z" fill="%s" %s/>' % (c.paint(p), c.ol)]
    o.append(c.line('M150 360 L150 416 M92 380 Q110 392 140 388 M208 380 Q190 392 160 388 M96 520 Q116 530 142 524 M204 520 Q184 530 158 524', darken(p, .6), 2.4, .35))
    return ''.join(o)

def body_view(c, view, of, acc):
    top, sk, sc = of['top'], of['skin'], of['shoe']
    if view == 'side':
        o = []
        # jambes
        o.append('<path d="M112 336 L196 336 L192 548 Q192 560 180 560 L124 560 Q112 560 112 548Z" fill="%s" %s/>' % (c.paint(of['pants']), c.ol))
        o.append(c.line('M152 340 L156 556 M118 380 Q150 396 190 384 M118 520 Q150 530 190 524', darken(of['pants'], .6), 2.4, .35))
        o.append(c.sh('M118 430 L170 430 L172 486 L116 486Z', darken(of['pants'], .12)))
        # chaussure
        o.append('<path d="M112 556 L186 552 Q206 560 224 580 Q244 594 238 606 L108 606 Q100 600 106 576Z" fill="%s" %s/>' % (c.paint(sc), c.ol))
        o.append('<path d="M104 596 L242 596 L244 608 Q244 616 234 616 L110 616 Q100 616 102 606Z" fill="%s" %s/>' % (c.paint('#F8F7FF'), c.ol))
        o.append(c.line('M170 560 L188 570 M180 556 L198 568 M190 556 L208 570', '#fff', 2.4, .85))
        # torse
        o.append(c.sh('M112 172 Q104 176 104 200 L108 330 Q108 346 124 346 L192 346 Q206 346 206 330 L204 200 Q204 176 196 170 Q152 156 112 172Z', top))
        if of.get('kind', 'hoodie') == 'hoodie':
            o.append(c.sh('M104 322 L206 322 L206 348 L106 348Z', darken(top, .14)))
            o.append(c.sh('M118 160 Q86 168 84 214 Q92 250 120 250 Q146 220 146 176Z', darken(top, .2)))
        else:
            o.append(c.sh('M112 160 L196 160 L196 176 L112 176Z', darken(top, .3)))
        o.append('<path d="M104 270 L84 296 L90 322 L108 318Z" fill="%s" %s/>' % (c.paint(darken(top, .1)), c.ol))
        # bras (devant)
        o.append(c.sh('M126 178 Q108 196 112 262 Q116 318 128 350 L172 354 Q176 296 170 240 Q166 200 156 176Z', top, (0, 0, 1, 1)))
        o.append(c.line('M128 262 Q142 274 168 270', darken(top, .6), 2.4, .35))
        o.append(c.sh('M128 338 Q150 350 172 344 L172 362 Q150 372 128 362Z', darken(top, .18)))
        o.append('<path d="M130 362 Q122 396 146 406 Q172 408 176 384 Q176 368 172 362Z" fill="%s" %s/>' % (c.paint(sk), c.ol))
        if 'chain' in acc: o.append('<path d="M146 176 Q168 214 196 190" stroke="#FFC83D" stroke-width="5" fill="none" stroke-linecap="round"/>')
        return ''.join(o)
    if view == 'back':
        o = [_legs_basic(c, of, True)]
        shoe = ('<path d="M76 566 Q74 548 94 546 L142 546 Q152 552 154 574 L154 600 Q156 612 142 614 L86 614 Q70 614 72 596Z" fill="%s" %s/><path d="M72 596 L156 596 L156 610 Q156 618 146 618 L84 618 Q70 618 70 606Z" fill="%s" %s/><rect x="104" y="552" width="30" height="8" rx="4" fill="%s"/>' % (c.paint(sc), c.ol, c.paint('#F8F7FF'), c.ol, of['accent']))
        o.append(shoe); o.append(mirror(shoe))
        arm = 'M72 176 Q42 198 36 266 Q32 318 42 348 L84 352 Q88 300 94 252 Q98 214 88 178Z'
        armg = c.sh(arm, top) + c.line('M52 250 Q64 262 86 262', darken(top, .6), 2.4, .35) + c.sh('M40 336 Q62 346 86 340 L84 358 Q60 366 40 358Z', darken(top, .12)) + '<path d="M44 358 Q34 390 52 404 Q74 412 86 392 Q94 368 84 358Z" fill="%s" %s/>' % (c.paint(sk), c.ol)
        o.append(armg); o.append(mirror(armg))
        o.append(c.sh('M72 176 Q72 166 88 164 L212 164 Q228 166 228 176 L238 328 Q238 342 226 344 L74 344 Q62 342 62 328Z', top))
        o.append(c.sh('M62 326 L238 326 L238 346 Q238 350 228 350 L72 350 Q62 350 62 346Z', darken(top, .14)))
        o.append(c.sh('M96 164 Q150 140 204 164 Q222 226 196 264 Q150 282 104 264 Q78 226 96 164Z', darken(top, .18)))
        o.append(c.line('M112 190 Q150 206 188 190 M118 230 Q150 250 182 230', darken(top, .6), 2.4, .3))
        o.append('<text x="150" y="312" text-anchor="middle" font-family="Baloo 2, Poppins, sans-serif" font-weight="800" font-size="40" fill="%s">BKM</text>' % of['accent'])
        return ''.join(o)
    # trois-quarts : corps de face rétréci et incliné
    inner = K.legs_front(c, of) + K.torso_front(c, of) + (K.chain_front(c) if 'chain' in acc else '')
    return '<g transform="translate(150 0) scale(.86 1) skewX(-4) translate(-150 0) translate(14 0)">%s</g>' % inner
