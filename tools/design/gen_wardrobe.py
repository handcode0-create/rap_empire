# Bibliothèque de tenues préfabriquées de Djo (rapper_001) : même système que OUTFIT_001 à 005.
# Chaque tenue = deux illustrations complètes générées par chars.figure (jeune : barbe courte, sourire ; mature : barbe pleine, posé),
# rendues en WebP 512 × 768, fond transparent, pieds en bas. Les tenues existantes ne sont pas regénérées.
# Usage : python3 tools/design/gen_wardrobe.py   (depuis la racine du dépôt ; nécessite Playwright + Chromium et Pillow)
import os, io, json, sys, re
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import chars, cast
from playwright.sync_api import sync_playwright
from PIL import Image

BASE = os.path.join(ROOT, 'assets/characters/rapper_001')
D = cast.CAST['djo']
VAR = {'young': dict(beard='stubble', mood='smile'), 'mature': dict(beard='full', mood='poised')}

# (catégorie, nom, description, prix, rang, coupe, haut, pantalon, chaussures, accent, accessoires)
LIB = [
 # Street
 ('Street', 'Hoodie Corail', 'Hoodie corail et jogging nuit, le basique des sessions au quartier.', 5000, 1, 'hoodie', '#FF6F61', '#1F1942', '#F8F7FF', '#FFC83D', ('chain',)),
 ('Street', 'Hoodie Ardoise', 'Hoodie gris ardoise, sneakers blanches, simple et propre.', 4500, 1, 'hoodie', '#4A4E69', '#14102B', '#F8F7FF', '#3CD6F2', ('chain',)),
 ('Street', 'Hoodie Lagune', 'Hoodie bleu lagune, rappel cyan sur les chaussures.', 6000, 1, 'hoodie', '#1E88A8', '#14102B', '#3CD6F2', '#3CD6F2', ('chain',)),
 ('Street', 'Hoodie Mangue', 'Hoodie jaune mangue, pantalon violet, impossible à rater.', 7000, 1, 'hoodie', '#FFB627', '#3A1B52', '#F8F7FF', '#F43F9D', ('chain',)),
 ('Street', 'Tee Blanc Ndolo', 'T-shirt blanc oversize et pantalon cargo nuit.', 3500, 1, 'tee', '#F8F7FF', '#2B2459', '#F43F9D', '#F43F9D', ('chain',)),
 ('Street', 'Tee Prune', 'T-shirt prune, sneakers or : le look du carrefour.', 4000, 1, 'tee', '#6B2D5C', '#14102B', '#FFC83D', '#FFC83D', ('chain',)),
 ('Street', 'Tee Sable', 'T-shirt sable et jean foncé, avec casquette.', 5500, 1, 'tee', '#D9B48F', '#1F2A44', '#F8F7FF', '#14102B', ('chain', 'cap')),
 ('Street', 'Casquette Gbaka', 'Hoodie noir, casquette rose : la tenue du gbaka de 6 h.', 8000, 1, 'hoodie', '#14102B', '#2B2459', '#F43F9D', '#F43F9D', ('chain', 'cap')),
 ('Street', 'Hoodie Olive', 'Hoodie olive, cargo sombre, baskets crème.', 6500, 1, 'hoodie', '#6B8F3A', '#1C1A14', '#F2E8CF', '#FFC83D', ('chain',)),
 ('Street', 'Tee Rouge Brique', 'T-shirt rouge brique et jogging gris.', 4500, 1, 'tee', '#B33A3A', '#3B3B4F', '#F8F7FF', '#F8F7FF', ('chain',)),
 # Sport
 ('Sport', 'Survêt Menthe', 'Survêtement menthe à bandes blanches.', 9000, 1, 'bomber', '#3DDC97', '#1F6F54', '#F8F7FF', '#F8F7FF', ('chain',)),
 ('Sport', 'Survêt Nuit Bleue', 'Survêtement bleu nuit, zip or.', 10000, 1, 'bomber', '#1E2A5A', '#141B3C', '#FFC83D', '#FFC83D', ('chain',)),
 ('Sport', 'Survêt Braise', 'Survêtement orange braise, bandes noires.', 11000, 2, 'bomber', '#FF7A1A', '#B34F00', '#14102B', '#14102B', ('chain',)),
 ('Sport', 'Survêt Lilas', 'Survêtement lilas et baskets blanches.', 10000, 1, 'bomber', '#B9A0FF', '#6A55B5', '#F8F7FF', '#F8F7FF', ('chain',)),
 ('Sport', 'Survêt Terrain', 'Survêtement vert terrain, casquette assortie.', 12000, 2, 'bomber', '#2E7D32', '#1B4D20', '#F8F7FF', '#FFC83D', ('chain', 'cap')),
 ('Sport', 'Survêt Cuivre', 'Survêtement cuivre, liseré crème.', 13000, 2, 'bomber', '#B87333', '#6E4421', '#F2E8CF', '#F2E8CF', ('chain',)),
 ('Sport', 'Survêt Glace', 'Survêtement blanc glacier, détails cyan.', 14000, 2, 'bomber', '#E8F4FA', '#B8CED9', '#3CD6F2', '#3CD6F2', ('chain',)),
 ('Sport', 'Survêt Magenta', 'Survêtement magenta intégral, pour se faire remarquer.', 15000, 2, 'bomber', '#F43F9D', '#C21E78', '#F8F7FF', '#FFC83D', ('chain',)),
 # Studio
 ('Studio', 'Casque et Hoodie', 'Hoodie violet et casque de studio autour du cou.', 9000, 1, 'hoodie', '#8B5CF6', '#14102B', '#F8F7FF', '#3CD6F2', ('chain', 'phones')),
 ('Studio', 'Nuit de Cabine', 'Tee noir, casque rose : la tenue des prises de nuit.', 8500, 1, 'tee', '#1A1A24', '#2B2459', '#F43F9D', '#F43F9D', ('chain', 'phones')),
 ('Studio', 'Producteur Indigo', 'Bomber indigo, lunettes fumées et casque.', 16000, 2, 'bomber', '#3F3D9E', '#14102B', '#3CD6F2', '#3CD6F2', ('chain', 'phones', 'glasses')),
 ('Studio', 'Session Crème', 'Hoodie crème et casque, ambiance session du dimanche.', 11000, 2, 'hoodie', '#F2E8CF', '#4A4E69', '#14102B', '#F43F9D', ('chain', 'phones')),
 # Scène
 ('Scène', 'Bomber Néon', 'Bomber magenta brillant, chaussures cyan : fait pour les projecteurs.', 18000, 2, 'bomber', '#FF2E93', '#14102B', '#3CD6F2', '#3CD6F2', ('chain',)),
 ('Scène', 'Bomber Or Noir', 'Bomber noir à reflets or, chaîne épaisse.', 24000, 3, 'bomber', '#14102B', '#0C0820', '#FFC83D', '#FFC83D', ('chain', 'ring')),
 ('Scène', 'Hoodie Électrique', 'Hoodie bleu électrique, coutures jaunes.', 17000, 2, 'hoodie', '#2D5BFF', '#14102B', '#FFC83D', '#FFC83D', ('chain',)),
 ('Scène', 'Lunettes de Scène', 'Bomber rouge, lunettes noires : le regard qui ne cligne pas.', 22000, 3, 'bomber', '#D7263D', '#14102B', '#F8F7FF', '#F8F7FF', ('chain', 'glasses')),
 ('Scène', 'Parvis Live', 'Hoodie blanc éclatant sous la lumière du Parvis.', 19000, 2, 'hoodie', '#F8F7FF', '#2B2459', '#F43F9D', '#F43F9D', ('chain', 'ring')),
 ('Scène', 'Festival Lagune', "Tee cyan, lunettes, chaîne : la tenue du festival Lagune d'Ambre.", 26000, 3, 'tee', '#3CD6F2', '#14102B', '#F8F7FF', '#FFC83D', ('chain', 'glasses')),
 ('Scène', 'Bomber Aurore', 'Bomber dégradé rose et violet, détails or.', 28000, 3, 'bomber', '#C94FD1', '#3A1B52', '#FFC83D', '#FFC83D', ('chain', 'ring')),
 ('Scène', 'Rouge Tamarel', 'Hoodie rouge vif et casquette noire, prêt pour Tamarel Open Air.', 30000, 3, 'hoodie', '#E63946', '#14102B', '#F8F7FF', '#14102B', ('chain', 'cap', 'ring')),
 # Chic
 ('Chic', 'Blazer Ivoire', 'Blazer ivoire et pantalon nuit, pour les interviews.', 32000, 3, 'blazer', '#F2E8CF', '#14102B', '#14102B', '#FFC83D', ('chain',)),
 ('Chic', 'Blazer Bordeaux', 'Blazer bordeaux, chaussures or.', 36000, 3, 'blazer', '#7B1E3A', '#14102B', '#FFC83D', '#FFC83D', ('chain', 'ring')),
 ('Chic', 'Blazer Émeraude', 'Blazer émeraude, lunettes fines.', 38000, 3, 'blazer', '#0F7B5F', '#0C0820', '#F8F7FF', '#FFC83D', ('chain', 'glasses')),
 ('Chic', 'Blazer Ciel', 'Blazer bleu ciel, sneakers blanches : chic mais rue.', 34000, 3, 'blazer', '#7FB7E6', '#1E2A5A', '#F8F7FF', '#F8F7FF', ('chain',)),
 ('Chic', 'Signature Label', 'Blazer gris anthracite pour signer un contrat.', 40000, 3, 'blazer', '#3B3B4F', '#14102B', '#14102B', '#3CD6F2', ('chain', 'ring')),
 ('Chic', 'Blazer Terracotta', 'Blazer terracotta, chemise sombre.', 37000, 3, 'blazer', '#C0623B', '#2B1B14', '#F2E8CF', '#F2E8CF', ('chain',)),
 ('Chic', 'Remise de Prix', 'Blazer noir profond et lunettes, pour la cérémonie.', 48000, 4, 'blazer', '#0C0820', '#0C0820', '#FFC83D', '#FFC83D', ('chain', 'ring', 'glasses')),
 ('Chic', 'Blazer Lavande', 'Blazer lavande, chaussures blanches.', 35000, 3, 'blazer', '#A78BFA', '#2B2459', '#F8F7FF', '#F8F7FF', ('chain',)),
 # Luxe
 ('Luxe', 'Or de Bakoma', 'Blazer or massif et chaîne lourde : le trône de Bakoma.', 120000, 4, 'blazer', '#E0A800', '#14102B', '#14102B', '#F8F7FF', ('chain', 'ring')),
 ('Luxe', 'Velours Nuit', 'Blazer velours violet profond, bagues et lunettes.', 95000, 4, 'blazer', '#3A1B52', '#0C0820', '#FFC83D', '#FFC83D', ('chain', 'ring', 'glasses')),
 ('Luxe', 'Platine', 'Ensemble blanc platine, accents argent.', 150000, 5, 'blazer', '#E5E4E2', '#B8B8C8', '#14102B', '#14102B', ('chain', 'ring')),
 ('Luxe', 'Diamant Noir', 'Bomber noir mat, chaîne et bagues : la tenue des grandes dates.', 180000, 5, 'bomber', '#0A0A12', '#0A0A12', '#F8F7FF', '#F8F7FF', ('chain', 'ring', 'glasses')),
 ('Luxe', 'Empereur Cauri', 'Blazer rouge impérial et or, réservé aux légendes.', 250000, 5, 'blazer', '#9B111E', '#14102B', '#FFC83D', '#FFC83D', ('chain', 'ring')),
 ('Luxe', 'Saphir', 'Blazer bleu saphir, chaussures or, lunettes fines.', 110000, 4, 'blazer', '#0F52BA', '#0C0820', '#FFC83D', '#FFC83D', ('chain', 'ring', 'glasses')),
 ('Luxe', 'Jade Royal', 'Bomber jade profond, finitions or.', 90000, 4, 'bomber', '#00684A', '#003D2B', '#FFC83D', '#FFC83D', ('chain', 'ring')),
 ('Luxe', 'Rose Champagne', 'Blazer rose champagne pour les soirées de label.', 100000, 4, 'blazer', '#E8B4B8', '#3A1B52', '#F8F7FF', '#FFC83D', ('chain', 'ring')),
 # Bijoux et accessoires (tenues complètes mettant en avant un accessoire)
 ('Bijoux', 'Bagues Dorées', 'Tee noir et bagues or aux deux oreilles : les bijoux parlent.', 15000, 2, 'tee', '#14102B', '#2B2459', '#FFC83D', '#FFC83D', ('chain', 'ring')),
 ('Bijoux', 'Chaîne et Lunettes', 'Hoodie blanc, chaîne or et lunettes noires.', 20000, 2, 'hoodie', '#F8F7FF', '#14102B', '#14102B', '#FFC83D', ('chain', 'glasses')),
 ('Bijoux', 'Parure Complète', 'Bomber nuit, chaîne, bagues et lunettes.', 45000, 3, 'bomber', '#1E2A5A', '#0C0820', '#FFC83D', '#FFC83D', ('chain', 'ring', 'glasses')),
 ('Bijoux', 'Casquette et Bagues', 'Tee magenta, casquette noire et bagues or.', 18000, 2, 'tee', '#F43F9D', '#14102B', '#F8F7FF', '#14102B', ('chain', 'cap', 'ring')),
 ('Bijoux', 'Lunettes Cyan', 'Tee cyan et lunettes noires pour le soleil de Sélène.', 12000, 1, 'tee', '#3CD6F2', '#1F1942', '#F8F7FF', '#14102B', ('chain', 'glasses')),
 ('Bijoux', 'Or et Casque', 'Hoodie noir, casque rose et bagues or.', 26000, 3, 'hoodie', '#14102B', '#2B2459', '#F43F9D', '#FFC83D', ('chain', 'phones', 'ring')),
 ('Bijoux', 'Collection Cauri', 'Blazer crème et bijoux or façon cauri.', 60000, 4, 'blazer', '#F2E8CF', '#3A1B52', '#FFC83D', '#FFC83D', ('chain', 'ring', 'glasses')),
 ('Bijoux', 'Casquette Dorée', 'Bomber violet et casquette, chaîne or.', 16000, 2, 'bomber', '#8B5CF6', '#3A1B52', '#FFC83D', '#FFC83D', ('chain', 'cap')),
]

SLUG = {'Street': 'street', 'Sport': 'sport', 'Studio': 'studio', 'Scène': 'scene', 'Chic': 'chic', 'Luxe': 'luxe', 'Bijoux': 'bijoux'}
OLD_CAT = {'OUTFIT_001': 'Street', 'OUTFIT_002': 'Sport', 'OUTFIT_003': 'Studio', 'OUTFIT_004': 'Chic', 'OUTFIT_005': 'Street',
           'OUTFIT_006': 'Street', 'OUTFIT_007': 'Scène', 'OUTFIT_008': 'Luxe', 'OUTFIT_009': 'Scène'}

def main():
    mp = os.path.join(BASE, 'manifest.json'); man = json.load(open(mp))
    old = [o for o in man['outfits'] if int(o['id'][-3:]) <= 9]
    for o in old: o['cat'] = OLD_CAT.get(o['id'], 'Street')
    new = []
    with sync_playwright() as p:
        b = p.chromium.launch(); pg = b.new_page(viewport={'width': 512, 'height': 768})
        for i, (cat, n, d, price, rank, kind, top, pants, shoe, acc_col, acc) in enumerate(LIB):
            oid = 'OUTFIT_%03d' % (10 + i); imgs = {}
            for v in ('young', 'mature'):
                rel = '%s/%s.webp' % (v, oid); dst = os.path.join(BASE, rel)
                if not os.path.exists(dst):
                    s = chars.figure(style='2d', view='front', skin=D['skin'], hair=D['hair'], hc=D['hc'], acc=acc,
                                     outfit=dict(top=top, pants=pants, shoe=shoe, accent=acc_col, kind=kind), crop='full', **VAR[v])
                    s = s.replace('<svg ', '<svg style="width:512px;height:768px;display:block" ', 1)
                    pg.set_content('<html><body style="margin:0;background:transparent">%s</body></html>' % s); pg.wait_for_timeout(60)
                    png = pg.screenshot(omit_background=True)
                    Image.open(io.BytesIO(png)).convert('RGBA').save(dst, 'WEBP', quality=86, method=6)
                imgs[v] = rel
            new.append({'id': oid, 'n': n, 'd': d, 'price': price, 'rank': rank, 'ref': 'bibliothèque v21 · %s' % cat, 'start': False,
                        'images': imgs, 'status': 'disponible', 'cat': cat})
        b.close()
    man['outfits'] = old + new
    man['status'] = 'Illustrations générées par tools/design (chars.figure), provisoires'
    json.dump(man, open(mp, 'w'), ensure_ascii=False, indent=2)
    # catalogue Dart (wardrobe21.dart) : même contenu que le manifest
    def dq(x): return "'" + str(x).replace('\\', '\\\\').replace("'", "\\'") + "'"
    def img(v): return 'null' if v is None else dq(v)
    lines = ["    {'id': %s, 'n': %s, 'd': %s, 'price': %d, 'rank': %d, 'start': %s, 'cat': %s, 'images': {'young': %s, 'mature': %s}, 'status': %s}," % (
        dq(o['id']), dq(o['n']), dq(o['d']), o['price'], o['rank'], 'true' if o.get('start') else 'false', dq(o['cat']),
        img(o['images']['young']), img(o['images']['mature']), dq(o['status'])) for o in man['outfits']]
    wp = os.path.join(ROOT, 'lib/domain/v21/wardrobe21.dart'); w = open(wp).read()
    w = re.sub(r"(  static const outfits = <Map<String, dynamic>>\[\n).*?(\n  \];)", lambda m: m.group(1) + '\n'.join(lines) + m.group(2), w, flags=re.S)
    if 'static const categories' not in w:
        w = w.replace("  static const startId", "  /// Catégories de la garde-robe (filtres de l'écran 21-W1).\n  static const categories = ['Street', 'Sport', 'Studio', 'Scène', 'Chic', 'Luxe', 'Bijoux'];\n\n  static const startId")
    open(wp, 'w').write(w)
    print(len(man['outfits']), 'tenues')

if __name__ == '__main__':
    main()
