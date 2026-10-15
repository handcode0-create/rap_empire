import random
from cast import P, CAST

def _svg(inner, defs=''):
    return '<svg class="bg" viewBox="0 0 390 420" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg"><defs>%s</defs>%s</svg>' % (defs, inner)

def bg_studio():
    d = '<linearGradient id="sw" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2B1858"/><stop offset="1" stop-color="#14102B"/></linearGradient>'
    s = '<rect width="390" height="420" fill="url(#sw)"/>'
    for i in range(6):
        s += '<rect x="%d" y="40" width="48" height="150" rx="6" fill="#3A1B52" stroke="#5B2D8F" stroke-width="2" opacity=".85"/>' % (20 + i * 62)
        s += ''.join('<path d="M%d %d H%d" stroke="#14102B" stroke-opacity=".35" stroke-width="2"/>' % (24 + i * 62, 60 + k * 18, 64 + i * 62) for k in range(7))
    s += '<rect x="86" y="14" width="218" height="34" rx="17" fill="none" stroke="#F43F9D" stroke-width="3"/><text x="195" y="38" text-anchor="middle" font-family="Baloo 2" font-weight="800" font-size="20" fill="#FF6BB8" letter-spacing="3">STUDIO KÔRÔ</text>'
    s += '<rect x="0" y="300" width="390" height="120" fill="#0C0820"/><rect x="10" y="296" width="370" height="46" rx="10" fill="#2B2459" stroke="#3A3270" stroke-width="2"/>'
    s += ''.join('<circle cx="%d" cy="319" r="6" fill="%s"/>' % (30 + i * 22, '#FFC83D' if i % 4 == 0 else '#3CD6F2' if i % 3 == 0 else '#B6B0DD') for i in range(16))
    s += '<rect x="8" y="140" width="40" height="70" rx="6" fill="#14102B" stroke="#3A3270" stroke-width="2"/><circle cx="28" cy="190" r="12" fill="#2B2459"/><circle cx="28" cy="162" r="5" fill="#2B2459"/>'
    s += '<rect x="342" y="140" width="40" height="70" rx="6" fill="#14102B" stroke="#3A3270" stroke-width="2"/><circle cx="362" cy="190" r="12" fill="#2B2459"/><circle cx="362" cy="162" r="5" fill="#2B2459"/>'
    return _svg(s, d)

def bg_office():
    d = '<linearGradient id="sk" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#8B5CF6"/><stop offset=".6" stop-color="#F43F9D"/><stop offset="1" stop-color="#FFC83D"/></linearGradient>'
    s = '<rect width="390" height="420" fill="#1F1942"/><rect x="40" y="36" width="310" height="220" rx="10" fill="url(#sk)" stroke="#3A3270" stroke-width="5"/>'
    random.seed(4)
    x = 46
    while x < 340:
        w = random.randint(22, 44); h = random.randint(40, 130)
        s += '<rect x="%d" y="%d" width="%d" height="%d" fill="#14102B" opacity=".92"/>' % (x, 252 - h, w, h)
        s += ''.join('<rect x="%d" y="%d" width="4" height="5" fill="#FFC83D" opacity=".8"/>' % (x + 5 + (k % 3) * 11, 252 - h + 8 + (k // 3) * 14) for k in range(9) if (k * 7 + x) % 3)
        x += w + 2
    s += '<path d="M195 36 V256 M40 146 H350" stroke="#3A3270" stroke-width="5"/>'
    s += '<rect x="300" y="268" width="60" height="42" rx="3" fill="#14102B" stroke="#FFC83D" stroke-width="3"/><circle cx="330" cy="289" r="12" fill="#FFC83D"/><circle cx="330" cy="289" r="4" fill="#14102B"/>'
    s += '<rect x="30" y="268" width="60" height="42" rx="3" fill="#14102B" stroke="#FFC83D" stroke-width="3"/><circle cx="60" cy="289" r="12" fill="#FFC83D"/><circle cx="60" cy="289" r="4" fill="#14102B"/>'
    s += '<rect x="0" y="330" width="390" height="90" fill="#2B2459"/><rect x="0" y="326" width="390" height="10" fill="#3A3270"/><text x="195" y="22" text-anchor="middle" font-family="Baloo 2" font-weight="800" font-size="12" fill="#FFC83D" letter-spacing="2">BAKOMA SOUND RECORDS</text>'
    return _svg(s, d)

def bg_backstage():
    d = '<linearGradient id="cu" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#2B0F3A"/><stop offset=".5" stop-color="#4A1B5E"/><stop offset="1" stop-color="#2B0F3A"/></linearGradient>'
    s = '<rect width="390" height="420" fill="#14102B"/>'
    s += ''.join('<rect x="%d" y="0" width="34" height="360" fill="url(#cu)" opacity="%s"/>' % (i * 33 - 10, '.95' if i % 2 else '.75') for i in range(13))
    s += '<rect x="20" y="22" width="350" height="46" rx="8" fill="#0C0820" stroke="#FFC83D" stroke-width="3"/><text x="195" y="52" text-anchor="middle" font-family="Baloo 2" font-weight="800" font-size="20" fill="#FFC83D" letter-spacing="2">FESTIVAL LAGUNE D\'AMBRE</text>'
    s += '<rect x="0" y="330" width="390" height="90" fill="#0C0820"/><rect x="18" y="290" width="86" height="60" rx="5" fill="#2B2459" stroke="#B6B0DD" stroke-width="2"/><path d="M18 304 H104 M60 290 V350" stroke="#B6B0DD" stroke-opacity=".5"/>'
    s += '<rect x="300" y="300" width="70" height="50" rx="5" fill="#2B2459" stroke="#B6B0DD" stroke-width="2"/><circle cx="60" cy="150" r="5" fill="#FFC83D"/><circle cx="330" cy="130" r="5" fill="#3CD6F2"/>'
    s += '<path d="M0 80 L390 80" stroke="#F43F9D" stroke-width="2" stroke-opacity=".5"/>'
    return _svg(s, d)

def bg_street():
    s = '<rect width="390" height="420" fill="#0C0820"/>'
    random.seed(9)
    for i in range(5):
        x = i * 82 - 10; h = random.randint(180, 300)
        s += '<rect x="%d" y="%d" width="80" height="%d" fill="%s"/>' % (x, 330 - h, h, ['#1F1942', '#2B2459', '#1A1438'][i % 3])
        s += ''.join('<rect x="%d" y="%d" width="9" height="12" fill="%s" opacity=".85"/>' % (x + 10 + (k % 4) * 17, 330 - h + 14 + (k // 4) * 24, '#FFC83D' if (k * 5 + i) % 3 == 0 else '#3A3270') for k in range(24))
    s += '<text x="40" y="236" font-family="Baloo 2" font-weight="800" font-size="38" fill="#F43F9D" transform="rotate(-6 40 236)" opacity=".9">NDOLO</text>'
    s += '<rect x="0" y="330" width="390" height="90" fill="#14102B"/><path d="M0 332 H390" stroke="#3A3270" stroke-width="3"/><rect x="340" y="120" width="5" height="216" fill="#3A3270"/><circle cx="342" cy="116" r="12" fill="#FFC83D"/><circle cx="342" cy="116" r="34" fill="#FFC83D" opacity=".14"/>'
    return _svg(s)

def bg_stage():
    d = '<linearGradient id="bm" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F43F9D" stop-opacity=".55"/><stop offset="1" stop-color="#F43F9D" stop-opacity="0"/></linearGradient>'
    s = '<rect width="390" height="420" fill="#0C0820"/>'
    s += ''.join('<path d="M%d 0 L%d 330 L%d 330Z" fill="url(#bm)" opacity=".6"/>' % (x, x - 70, x + 70) for x in (60, 195, 330))
    s += '<path d="M120 0 L200 330 L260 330Z" fill="#3CD6F2" opacity=".18"/>'
    random.seed(2)
    s += '<rect x="0" y="330" width="390" height="90" fill="#14102B"/>'
    for i in range(34):
        x = i * 12 + random.randint(-3, 3); r = random.randint(11, 15)
        s += '<circle cx="%d" cy="%d" r="%d" fill="#0C0820" stroke="#2B2459" stroke-width="1.5"/>' % (x, 362 + random.randint(-8, 14), r)
        if i % 6 == 0: s += '<path d="M%d %d l-6 -26" stroke="#0C0820" stroke-width="5" stroke-linecap="round"/>' % (x, 360)
    s += ''.join('<circle cx="%d" cy="%d" r="3" fill="%s"/>' % (random.randint(10, 380), random.randint(30, 200), random.choice(['#FFC83D', '#F43F9D', '#3CD6F2', '#3DDC97'])) for _ in range(24))
    return _svg(s, d)

def bg_call():
    d = '<linearGradient id="cl" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3A1B52"/><stop offset="1" stop-color="#14102B"/></linearGradient>'
    return _svg('<rect width="390" height="420" fill="url(#cl)"/><circle cx="330" cy="60" r="90" fill="#F43F9D" opacity=".15"/><circle cx="40" cy="330" r="110" fill="#8B5CF6" opacity=".15"/>', d)

BGS = {'studio': bg_studio, 'office': bg_office, 'backstage': bg_backstage, 'street': bg_street, 'stage': bg_stage, 'call': bg_call}

def scene(kind, h, chars, extra=''):
    """chars: [(who, mood, gesture, width, left, crop)]"""
    out = '<div class="dl-scene" style="height:%dpx;width:390px">%s' % (h, BGS[kind]())
    for ch in chars:
        who, mood, g, w, left = ch[:5]; crop = ch[5] if len(ch) > 5 else 'torso'
        ratio = {'torso': 340 / 260, 'bust': 250 / 220}[crop]
        hh = int(w * ratio)
        out += '<div class="dl-ch" style="left:%dpx;width:%dpx;height:%dpx;bottom:%dpx">%s</div>' % (left, w, hh, 0 if hh <= h else h - hh, P(who, mood, g, crop=crop))
    return out + extra + '</div>'
