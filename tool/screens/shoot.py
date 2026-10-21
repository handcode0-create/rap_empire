# Captures d'écran du build web (CI) : charge un état de partie dans le stockage local, ouvre chaque route à 390 × 844
# et enregistre une image PNG. Usage : python3 tool/screens/shoot.py build/web sortie/ [state.json]
# Sert uniquement à vérifier visuellement les écrans (aucune donnée de jeu n'est modifiée). 
import sys, os, json, threading, functools, http.server
from playwright.sync_api import sync_playwright

WEB, OUT = sys.argv[1], sys.argv[2]
STATE = sys.argv[3] if len(sys.argv) > 3 else os.path.join(os.path.dirname(__file__), 'state_star.json')
ROUTES = [
    ('profil', '/profil'),
    ('classements', '/profil/classements'),
    ('trophees', '/profil/trophees'),
    ('annonce', '/profil/trophees/annonce'),
    ('qg', '/'),
    ('reseau', '/profil/reseau'),
    ('ondea', '/profil/reseau/ondea'),
    ('playlist', '/profil/reseau/ondea/playlist?id=drill'),
    ('pitch', '/profil/reseau/ondea/playlist/pitch?id=drill'),
    ('klipo', '/profil/reseau/klipo'),
    ('klipo-video', '/profil/reseau/klipo/video'),
    ('clips', '/profil/reseau/clips'),
    ('cauri', '/profil/reseau/cauri'),
    ('ondea-titres', '/profil/reseau/ondea/titres'),
    ('ondea-sortie', '/profil/reseau/ondea/sortie?id=P1'),
    ('cauri-sortie', '/profil/reseau/cauri/sortie?id=P1'),
    ('garde-robe', '/profil/garde-robe'),
    ('labels', '/business/labels/tous'),
    ('marketing', '/profil/reseau/marketing'),
    ('scene', '/scene'),
    ('feats', '/studio/feats'),
]
os.makedirs(OUT, exist_ok=True)
LIVE = WEB.startswith('http')  # adresse du site déployé : on le capture tel quel (aucun serveur local)
BASE = WEB.rstrip('/') if LIVE else 'http://127.0.0.1:8765'
if not LIVE:
    handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=WEB)
    srv = http.server.ThreadingHTTPServer(('127.0.0.1', 8765), handler)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
state = json.load(open(STATE))
ENGINE = os.environ.get('SHOT_ENGINE', 'chromium')  # 'webkit' : moteur de Safari (iPhone)
PFX = ('live-' if LIVE else '') + ('' if ENGINE == 'chromium' else ENGINE[:2] + '-')
with sync_playwright() as p:
    b = getattr(p, ENGINE).launch()
    for scroll in ((False, True) if ENGINE == 'chromium' else (False,)):
        pg = b.new_page(viewport={'width': 390, 'height': 844}, device_scale_factor=2)
        pg.goto(BASE + '/')
        pg.wait_for_timeout(4000)
        pg.evaluate('s => localStorage.setItem("flutter.save_v21", JSON.stringify(s))', json.dumps(state))
        pg.reload()
        pg.wait_for_timeout(6000 if LIVE else 3000)
        for name, route in ROUTES:
            pg.goto(BASE + '/#' + route)
            pg.wait_for_timeout(9000 if LIVE else 6000)
            if scroll:
                pg.mouse.move(195, 500)
                pg.mouse.wheel(0, 700)
                pg.wait_for_timeout(1200)
            pg.screenshot(path=os.path.join(OUT, '%s%s%s.png' % (PFX, name, '-bas' if scroll else '')))
            print('ok', name, scroll, flush=True)
        pg.close()
    b.close()
if not LIVE:
    srv.shutdown()
