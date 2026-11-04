#!/usr/bin/env python3
"""Génère le logo RAP EMPIRE, les icônes de l'application et le favicon (Chromium + Baloo 2 du dépôt).

Usage : python3 tools/design/gen_app_icon.py   (depuis la racine du dépôt Flutter)
Sorties : web/icons/*, web/favicon.png, web/apple-touch-icon.png, assets/logos/rap_empire_logo.png, web/og-image.png
"""
import os
from playwright.sync_api import sync_playwright

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
TMP = '/tmp/_rap_icon.html'
FONT = 'file://' + os.path.join(ROOT, 'assets', 'fonts', 'Baloo2-Variable.ttf')

CROWN = ('<path d="M-150 60 L-185 -70 L-95 -10 L0 -110 L95 -10 L185 -70 L150 60 Z" fill="url(#gold)"/>'
         '<rect x="-150" y="70" width="300" height="30" rx="12" fill="url(#gold)"/>'
         '<circle cx="-185" cy="-80" r="17" fill="#FFC83D"/><circle cx="0" cy="-122" r="19" fill="#FFC83D"/><circle cx="185" cy="-80" r="17" fill="#FFC83D"/>')

DEFS = ('<defs>'
        '<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2B2459"/><stop offset=".55" stop-color="#14102B"/><stop offset="1" stop-color="#0C0820"/></linearGradient>'
        '<radialGradient id="glow" cx=".5" cy=".55" r=".55"><stop offset="0" stop-color="#F43F9D" stop-opacity=".55"/><stop offset="1" stop-color="#F43F9D" stop-opacity="0"/></radialGradient>'
        '<linearGradient id="gold" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFE08A"/><stop offset="1" stop-color="#FFC83D"/></linearGradient>'
        '<linearGradient id="txt" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#FFC1E0"/></linearGradient>'
        '</defs>')

def icon_svg(scale=1.0):
    # scale < 1 : zone de sécurité pour les icônes « maskable » (le contenu reste dans les 80 % centraux)
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">' + DEFS +
            '<rect width="1024" height="1024" fill="url(#bg)"/><circle cx="512" cy="560" r="470" fill="url(#glow)"/>'
            f'<g transform="translate(512 512) scale({scale}) translate(-512 -512)">'
            '<g transform="translate(512 260) scale(1.05)">' + CROWN + '</g>'
            '<text x="512" y="800" text-anchor="middle" font-family="Baloo" font-weight="800" font-size="560" letter-spacing="-14" fill="#F43F9D" transform="translate(0 14)">RE</text>'
            '<text x="512" y="800" text-anchor="middle" font-family="Baloo" font-weight="800" font-size="560" letter-spacing="-14" fill="url(#txt)">RE</text>'
            '<rect x="262" y="838" width="500" height="16" rx="8" fill="url(#gold)"/>'
            '</g></svg>')

def logo_svg():
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630" width="1200" height="630">' + DEFS +
            '<rect width="1200" height="630" fill="url(#bg)"/><ellipse cx="600" cy="330" rx="560" ry="300" fill="url(#glow)"/>'
            '<g transform="translate(600 110) scale(.62)">' + CROWN + '</g>'
            '<text x="600" y="330" text-anchor="middle" font-family="Baloo" font-weight="800" font-size="190" letter-spacing="2" fill="#F43F9D" transform="translate(0 7)">RAP</text>'
            '<text x="600" y="330" text-anchor="middle" font-family="Baloo" font-weight="800" font-size="190" letter-spacing="2" fill="url(#txt)">RAP</text>'
            '<text x="600" y="500" text-anchor="middle" font-family="Baloo" font-weight="800" font-size="190" letter-spacing="2" fill="#F43F9D" transform="translate(0 7)">EMPIRE</text>'
            '<text x="600" y="500" text-anchor="middle" font-family="Baloo" font-weight="800" font-size="190" letter-spacing="2" fill="url(#txt)">EMPIRE</text>'
            '<text x="600" y="570" text-anchor="middle" font-family="Poppins, Arial" font-weight="700" font-size="26" letter-spacing="6" fill="#B6B0DD">DE NDOLO AU MONDE</text>'
            '</svg>')

def page(svg):
    return ('<html><head><style>@font-face{font-family:Baloo;src:url("' + FONT + '");font-weight:100 900}'
            'html,body{margin:0;background:transparent}</style></head><body>' + svg + '</body></html>')

def main():
    out = lambda *p: os.path.join(ROOT, *p)
    os.makedirs(out('web', 'icons'), exist_ok=True)
    os.makedirs(out('assets', 'logos'), exist_ok=True)
    with sync_playwright() as pw:
        b = pw.chromium.launch()
        pg = b.new_page(viewport={'width': 1024, 'height': 1024})
        def shot(svg, path, size, w=None, h=None):
            pg.set_viewport_size({'width': w or 1024, 'height': h or 1024})
            open(TMP,'w').write(page(svg)); pg.goto('file://'+TMP); pg.evaluate("document.fonts.load('800 100px Baloo').then(()=>document.fonts.ready)"); pg.wait_for_timeout(300)
            pg.screenshot(path=path, clip={'x': 0, 'y': 0, 'width': w or 1024, 'height': h or 1024})
            if size:
                from PIL import Image
                im = Image.open(path).convert('RGBA'); im = im.resize((size, size), Image.LANCZOS); im.save(path)
        full, safe = icon_svg(1.0), icon_svg(.78)
        shot(full, out('web', 'icons', 'Icon-512.png'), 512)
        shot(full, out('web', 'icons', 'Icon-192.png'), 192)
        shot(safe, out('web', 'icons', 'Icon-maskable-512.png'), 512)
        shot(safe, out('web', 'icons', 'Icon-maskable-192.png'), 192)
        shot(full, out('web', 'apple-touch-icon.png'), 180)
        shot(full, out('web', 'favicon.png'), 64)
        shot(logo_svg(), out('assets', 'logos', 'rap_empire_logo.png'), None, 1200, 630)
        shot(logo_svg(), out('web', 'og-image.png'), None, 1200, 630)
        b.close()
    from PIL import Image
    Image.open(out('web', 'icons', 'Icon-512.png')).save(out('web', 'favicon.ico'), sizes=[(16, 16), (32, 32), (48, 48)])
    print('ok')

if __name__ == '__main__':
    main()
