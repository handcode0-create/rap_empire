# Génère les illustrations 2D de la garde-robe préfabriquée v21 (rapper_001, variantes jeune et mature).
# Aucune composition en jeu : chaque fichier est une image complète du personnage dans une tenue.
import sys, os, json, io
KIT = sys.argv[1]; OUT = sys.argv[2]
sys.path.insert(0, os.path.join(KIT, 'tools', 'design'))
import chars, cast
from playwright.sync_api import sync_playwright
from PIL import Image
D = cast.CAST['djo']
CAT = [
 dict(id='OUTFIT_001', n='Hoodie Néon', d='Le hoodie rose de tes débuts, patch BKM sur la poitrine.', price=0, rank=1, start=True, ref='12.5 (équipé)', of=dict(top='#F43F9D', pants='#2B2459', shoe='#F43F9D', accent='#FFC83D', kind='hoodie')),
 dict(id='OUTFIT_002', n='Survêt Soleil', d='Survêtement jaune soleil, zip et bandes magenta.', price=6000, rank=1, ref='12.5 (6 000)', of=dict(top='#FFC83D', pants='#E0A800', shoe='#F8F7FF', accent='#C21E78', kind='bomber')),
 dict(id='OUTFIT_003', n='Veste Brume', d='Veste gris-violet, baskets cyan. Le look des sessions studio.', price=18000, rank=1, ref='12.5 / 12.5b (18 000)', of=dict(top='#6E6896', pants='#14102B', shoe='#3CD6F2', accent='#3CD6F2', kind='bomber')),
 dict(id='OUTFIT_004', n='Veste Nuit', d='Blazer bleu nuit et détails or, pour les grandes scènes.', price=30000, rank=3, ref='12.5 (niveau 3, prix à confirmer)', of=dict(top='#1E2A5A', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_005', n='Hoodie Jade', d='Hoodie vert jade.', price=12000, rank=1, ref='12.5 (acheté dans la maquette)', of=dict(top='#3DDC97', pants='#14102B', shoe='#F8F7FF', accent='#14102B', kind='hoodie')),
 dict(id='OUTFIT_006', n='Hoodie Cobalt', d='Hoodie bleu cobalt, coutures cyan et sneakers blanches pour les sessions de nuit.', price=14000, rank=1, ref='catalogue v21', of=dict(top='#2457D6', pants='#14102B', shoe='#F8F7FF', accent='#3CD6F2', kind='hoodie')),
 dict(id='OUTFIT_007', n='Veste Cuivre', d='Veste courte cuivre et pantalon anthracite, un look affirmé pour les showcases.', price=22000, rank=2, ref='catalogue v21', of=dict(top='#B86B3D', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_008', n='Ensemble Impérial', d='Ensemble noir profond, finitions or et chaîne de scène.', price=42000, rank=3, ref='catalogue v21', of=dict(top='#14102B', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_009', n='Néon de Bakoma', d='Tenue de performance magenta et cyan, conçue pour les grandes scènes.', price=65000, rank=5, ref='catalogue v21', of=dict(top='#F43F9D', pants='#14102B', shoe='#3CD6F2', accent='#FFC83D', kind='bomber')),
]
VAR = {'young': dict(beard='stubble', mood='smile'), 'mature': dict(beard='full', mood='poised')}
def svg(o, v):
    return chars.figure(style='2d', view='front', skin=D['skin'], hair=D['hair'], hc=D['hc'], acc=D['acc'], outfit=o['of'], crop='full', **VAR[v])
man = {'character': 'rapper_001', 'name': 'Djo Kéné (look par défaut : teint 3, twists hi-top)', 'status': 'Généré par gen_outfits.py — rendu 2D provisoire à valider',
       'frame': {'w': 512, 'h': 768, 'format': 'webp', 'background': 'transparent', 'anchor': 'pieds en bas, centré'}, 'outfits': []}
with sync_playwright() as p:
    b = p.chromium.launch(); pg = b.new_page(viewport={'width': 512, 'height': 768})
    for o in CAT:
        imgs = {}
        for v in ('young', 'mature'):
            s = svg(o, v).replace('<svg ', '<svg style="width:512px;height:768px;display:block" ', 1)
            pg.set_content('<html><body style="margin:0;background:transparent">%s</body></html>' % s); pg.wait_for_timeout(80)
            png = pg.screenshot(omit_background=True)
            rel = '%s/v21b_%s.webp' % (v, o['id']); os.makedirs(os.path.join(OUT, v), exist_ok=True)
            Image.open(io.BytesIO(png)).convert('RGBA').save(os.path.join(OUT, rel), 'WEBP', quality=88, method=6)
            imgs[v] = rel
        man['outfits'].append({k: o[k] for k in ('id', 'n', 'd', 'price', 'rank', 'ref')} | {'start': bool(o.get('start')), 'images': imgs,
                               'status': 'disponible' if imgs['young'] and imgs['mature'] else 'indisponible'})
    b.close()
json.dump(man, open(os.path.join(OUT, 'manifest.json'), 'w'), ensure_ascii=False, indent=1)
print(json.dumps([(o['id'], o['status']) for o in man['outfits']]))
