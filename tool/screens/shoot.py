# Captures d'écran du build web (CI) : charge un état de partie dans le stockage local, ouvre chaque route à 390 × 844
# et enregistre une image PNG. Usage : python3 tool/screens/shoot.py build/web sortie/ [state.json]
# Sert uniquement à vérifier visuellement les écrans (aucune donnée de jeu n'est modifiée).
import sys, os, json, threading, functools, http.server
from playwright.sync_api import sync_playwright

WEB, OUT = sys.argv[1], sys.argv[2]
STATE = sys.argv[3] if len(sys.argv) > 3 else os.path.join(os.path.dirname(__file__), 'state_star.json')
ROUTES = [
    ('reseau', '/profil/reseau'),
    ('ondea', '/profil/reseau/ondea'),
    ('klipo', '/profil/reseau/klipo'),
    ('klipo-video', '/profil/reseau/klipo/video'),
    ('clips', '/profil/reseau/clips'),
    ('cauri', '/profil/reseau/cauri'),
    ('ondea-titres', '/profil/reseau/ondea/titres'),
    ('ondea-sortie', '/profil/reseau/ondea/sortie?id=P1'),
    ('cauri-sortie', '/profil/reseau/cauri/sortie?id=P1'),
    ('garde-robe', '/profil/garde-robe'),
]
os.makedirs(OUT, exist_ok=True)
handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=WEB)
srv = http.server.ThreadingHTTPServer(('127.0.0.1', 8765), handler)
threading.Thread(target=srv.serve_forever, daemon=True).start()
state = json.load(open(STATE))
with sync_playwright() as p:
    b = p.chromium.launch()
    for scroll in (False, True):
        pg = b.new_page(viewport={'width': 390, 'height': 844}, device_scale_factor=2)
        pg.goto('http://127.0.0.1:8765/')
        pg.evaluate('s => localStorage.setItem("flutter.save_v21", JSON.stringify(s))', json.dumps(state))
        for name, route in ROUTES:
            pg.goto('http://127.0.0.1:8765/#' + route)
            pg.wait_for_timeout(6000)
            if scroll:
                pg.mouse.move(195, 500)
                pg.mouse.wheel(0, 700)
                pg.wait_for_timeout(1200)
            pg.screenshot(path=os.path.join(OUT, '%s%s.png' % (name, '-bas' if scroll else '')))
            print('ok', name, scroll, flush=True)
        pg.close()
    b.close()
srv.shutdown()
