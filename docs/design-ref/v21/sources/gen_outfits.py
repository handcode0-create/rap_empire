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
 dict(id='OUTFIT_001', cat='Street', n='Hoodie Néon', d='Le hoodie rose de tes débuts, patch BKM sur la poitrine.', price=0, rank=1, start=True, ref='12.5 (équipé)', of=dict(top='#F43F9D', pants='#2B2459', shoe='#F43F9D', accent='#FFC83D', kind='hoodie')),
 dict(id='OUTFIT_002', cat='Sport', n='Survêt Soleil', d='Survêtement jaune soleil, zip et bandes magenta.', price=6000, rank=1, ref='12.5 (6 000)', of=dict(top='#FFC83D', pants='#E0A800', shoe='#F8F7FF', accent='#C21E78', kind='bomber')),
 dict(id='OUTFIT_003', cat='Studio', n='Veste Brume', d='Veste gris-violet, baskets cyan. Le look des sessions studio.', price=18000, rank=1, ref='12.5 / 12.5b (18 000)', of=dict(top='#6E6896', pants='#14102B', shoe='#3CD6F2', accent='#3CD6F2', kind='bomber')),
 dict(id='OUTFIT_004', cat='Chic', n='Veste Nuit', d='Blazer bleu nuit et détails or, pour les grandes scènes.', price=30000, rank=3, ref='12.5 (niveau 3, prix à confirmer)', of=dict(top='#1E2A5A', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_005', cat='Street', n='Hoodie Jade', d='Hoodie vert jade.', price=12000, rank=1, ref='12.5 (acheté dans la maquette)', of=dict(top='#3DDC97', pants='#14102B', shoe='#F8F7FF', accent='#14102B', kind='hoodie')),
 dict(id='OUTFIT_006', cat='Street', n='Hoodie Cobalt', d='Hoodie bleu cobalt, coutures cyan et sneakers blanches pour les sessions de nuit.', price=14000, rank=1, ref='catalogue v21', of=dict(top='#2457D6', pants='#14102B', shoe='#F8F7FF', accent='#3CD6F2', kind='hoodie')),
 dict(id='OUTFIT_007', cat='Scène', n='Veste Cuivre', d='Veste courte cuivre et pantalon anthracite, un look affirmé pour les showcases.', price=22000, rank=2, ref='catalogue v21', of=dict(top='#B86B3D', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_008', cat='Luxe', n='Ensemble Impérial', d='Ensemble noir profond, finitions or et chaîne de scène.', price=42000, rank=3, ref='catalogue v21', of=dict(top='#14102B', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_009', cat='Scène', n='Néon de Bakoma', d='Tenue de performance magenta et cyan, conçue pour les grandes scènes.', price=65000, rank=5, ref='catalogue v21', of=dict(top='#F43F9D', pants='#14102B', shoe='#3CD6F2', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_010', cat='Street', n='Hoodie Corail', d='Hoodie corail et jogging nuit, le basique des sessions au quartier.', price=5000, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#FF6F61', pants='#1F1942', shoe='#F8F7FF', accent='#FFC83D', kind='hoodie')),
 dict(id='OUTFIT_011', cat='Street', n='Hoodie Ardoise', d='Hoodie gris ardoise, sneakers blanches, simple et propre.', price=4500, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#4A4E69', pants='#14102B', shoe='#F8F7FF', accent='#3CD6F2', kind='hoodie')),
 dict(id='OUTFIT_012', cat='Street', n='Hoodie Lagune', d='Hoodie bleu lagune, rappel cyan sur les chaussures.', price=6000, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#1E88A8', pants='#14102B', shoe='#3CD6F2', accent='#3CD6F2', kind='hoodie')),
 dict(id='OUTFIT_013', cat='Street', n='Hoodie Mangue', d='Hoodie jaune mangue, pantalon violet, impossible à rater.', price=7000, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#FFB627', pants='#3A1B52', shoe='#F8F7FF', accent='#F43F9D', kind='hoodie')),
 dict(id='OUTFIT_014', cat='Street', n='Tee Blanc Ndolo', d='T-shirt blanc oversize et pantalon cargo nuit.', price=3500, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#F8F7FF', pants='#2B2459', shoe='#F43F9D', accent='#F43F9D', kind='tee')),
 dict(id='OUTFIT_015', cat='Street', n='Tee Prune', d='T-shirt prune, sneakers or : le look du carrefour.', price=4000, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#6B2D5C', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='tee')),
 dict(id='OUTFIT_016', cat='Street', n='Tee Sable', d='T-shirt sable et jean foncé, avec casquette.', price=5500, rank=1, ref='bibliothèque v21', acc=('chain', 'cap'), of=dict(top='#D9B48F', pants='#1F2A44', shoe='#F8F7FF', accent='#14102B', kind='tee')),
 dict(id='OUTFIT_017', cat='Street', n='Casquette Gbaka', d='Hoodie noir, casquette rose : la tenue du gbaka de 6 h.', price=8000, rank=1, ref='bibliothèque v21', acc=('chain', 'cap'), of=dict(top='#14102B', pants='#2B2459', shoe='#F43F9D', accent='#F43F9D', kind='hoodie')),
 dict(id='OUTFIT_018', cat='Street', n='Hoodie Olive', d='Hoodie olive, cargo sombre, baskets crème.', price=6500, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#6B8F3A', pants='#1C1A14', shoe='#F2E8CF', accent='#FFC83D', kind='hoodie')),
 dict(id='OUTFIT_019', cat='Street', n='Tee Rouge Brique', d='T-shirt rouge brique et jogging gris.', price=4500, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#B33A3A', pants='#3B3B4F', shoe='#F8F7FF', accent='#F8F7FF', kind='tee')),
 dict(id='OUTFIT_020', cat='Sport', n='Survêt Menthe', d='Survêtement menthe à bandes blanches.', price=9000, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#3DDC97', pants='#1F6F54', shoe='#F8F7FF', accent='#F8F7FF', kind='bomber')),
 dict(id='OUTFIT_021', cat='Sport', n='Survêt Nuit Bleue', d='Survêtement bleu nuit, zip or.', price=10000, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#1E2A5A', pants='#141B3C', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_022', cat='Sport', n='Survêt Braise', d='Survêtement orange braise, bandes noires.', price=11000, rank=2, ref='bibliothèque v21', acc=('chain',), of=dict(top='#FF7A1A', pants='#B34F00', shoe='#14102B', accent='#14102B', kind='bomber')),
 dict(id='OUTFIT_023', cat='Sport', n='Survêt Lilas', d='Survêtement lilas et baskets blanches.', price=10000, rank=1, ref='bibliothèque v21', acc=('chain',), of=dict(top='#B9A0FF', pants='#6A55B5', shoe='#F8F7FF', accent='#F8F7FF', kind='bomber')),
 dict(id='OUTFIT_024', cat='Sport', n='Survêt Terrain', d='Survêtement vert terrain, casquette assortie.', price=12000, rank=2, ref='bibliothèque v21', acc=('chain', 'cap'), of=dict(top='#2E7D32', pants='#1B4D20', shoe='#F8F7FF', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_025', cat='Sport', n='Survêt Cuivre', d='Survêtement cuivre, liseré crème.', price=13000, rank=2, ref='bibliothèque v21', acc=('chain',), of=dict(top='#B87333', pants='#6E4421', shoe='#F2E8CF', accent='#F2E8CF', kind='bomber')),
 dict(id='OUTFIT_026', cat='Sport', n='Survêt Glace', d='Survêtement blanc glacier, détails cyan.', price=14000, rank=2, ref='bibliothèque v21', acc=('chain',), of=dict(top='#E8F4FA', pants='#B8CED9', shoe='#3CD6F2', accent='#3CD6F2', kind='bomber')),
 dict(id='OUTFIT_027', cat='Sport', n='Survêt Magenta', d='Survêtement magenta intégral, pour se faire remarquer.', price=15000, rank=2, ref='bibliothèque v21', acc=('chain',), of=dict(top='#F43F9D', pants='#C21E78', shoe='#F8F7FF', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_028', cat='Studio', n='Casque et Hoodie', d='Hoodie violet et casque de studio autour du cou.', price=9000, rank=1, ref='bibliothèque v21', acc=('chain', 'phones'), of=dict(top='#8B5CF6', pants='#14102B', shoe='#F8F7FF', accent='#3CD6F2', kind='hoodie')),
 dict(id='OUTFIT_029', cat='Studio', n='Nuit de Cabine', d='Tee noir, casque rose : la tenue des prises de nuit.', price=8500, rank=1, ref='bibliothèque v21', acc=('chain', 'phones'), of=dict(top='#1A1A24', pants='#2B2459', shoe='#F43F9D', accent='#F43F9D', kind='tee')),
 dict(id='OUTFIT_030', cat='Studio', n='Producteur Indigo', d='Bomber indigo, lunettes fumées et casque.', price=16000, rank=2, ref='bibliothèque v21', acc=('chain', 'phones', 'glasses'), of=dict(top='#3F3D9E', pants='#14102B', shoe='#3CD6F2', accent='#3CD6F2', kind='bomber')),
 dict(id='OUTFIT_031', cat='Studio', n='Session Crème', d='Hoodie crème et casque, ambiance session du dimanche.', price=11000, rank=2, ref='bibliothèque v21', acc=('chain', 'phones'), of=dict(top='#F2E8CF', pants='#4A4E69', shoe='#14102B', accent='#F43F9D', kind='hoodie')),
 dict(id='OUTFIT_032', cat='Scène', n='Bomber Néon', d='Bomber magenta brillant, chaussures cyan : fait pour les projecteurs.', price=18000, rank=2, ref='bibliothèque v21', acc=('chain',), of=dict(top='#FF2E93', pants='#14102B', shoe='#3CD6F2', accent='#3CD6F2', kind='bomber')),
 dict(id='OUTFIT_033', cat='Scène', n='Bomber Or Noir', d='Bomber noir à reflets or, chaîne épaisse.', price=24000, rank=3, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#14102B', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_034', cat='Scène', n='Hoodie Électrique', d='Hoodie bleu électrique, coutures jaunes.', price=17000, rank=2, ref='bibliothèque v21', acc=('chain',), of=dict(top='#2D5BFF', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='hoodie')),
 dict(id='OUTFIT_035', cat='Scène', n='Lunettes de Scène', d='Bomber rouge, lunettes noires : le regard qui ne cligne pas.', price=22000, rank=3, ref='bibliothèque v21', acc=('chain', 'glasses'), of=dict(top='#D7263D', pants='#14102B', shoe='#F8F7FF', accent='#F8F7FF', kind='bomber')),
 dict(id='OUTFIT_036', cat='Scène', n='Parvis Live', d='Hoodie blanc éclatant sous la lumière du Parvis.', price=19000, rank=2, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#F8F7FF', pants='#2B2459', shoe='#F43F9D', accent='#F43F9D', kind='hoodie')),
 dict(id='OUTFIT_037', cat='Scène', n='Festival Lagune', d="Tee cyan, lunettes, chaîne : la tenue du festival Lagune d'Ambre.", price=26000, rank=3, ref='bibliothèque v21', acc=('chain', 'glasses'), of=dict(top='#3CD6F2', pants='#14102B', shoe='#F8F7FF', accent='#FFC83D', kind='tee')),
 dict(id='OUTFIT_038', cat='Scène', n='Bomber Aurore', d='Bomber dégradé rose et violet, détails or.', price=28000, rank=3, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#C94FD1', pants='#3A1B52', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_039', cat='Scène', n='Rouge Tamarel', d='Hoodie rouge vif et casquette noire, prêt pour Tamarel Open Air.', price=30000, rank=3, ref='bibliothèque v21', acc=('chain', 'cap', 'ring'), of=dict(top='#E63946', pants='#14102B', shoe='#F8F7FF', accent='#14102B', kind='hoodie')),
 dict(id='OUTFIT_040', cat='Chic', n='Blazer Ivoire', d='Blazer ivoire et pantalon nuit, pour les interviews.', price=32000, rank=3, ref='bibliothèque v21', acc=('chain',), of=dict(top='#F2E8CF', pants='#14102B', shoe='#14102B', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_041', cat='Chic', n='Blazer Bordeaux', d='Blazer bordeaux, chaussures or.', price=36000, rank=3, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#7B1E3A', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_042', cat='Chic', n='Blazer Émeraude', d='Blazer émeraude, lunettes fines.', price=38000, rank=3, ref='bibliothèque v21', acc=('chain', 'glasses'), of=dict(top='#0F7B5F', pants='#0C0820', shoe='#F8F7FF', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_043', cat='Chic', n='Blazer Ciel', d='Blazer bleu ciel, sneakers blanches : chic mais rue.', price=34000, rank=3, ref='bibliothèque v21', acc=('chain',), of=dict(top='#7FB7E6', pants='#1E2A5A', shoe='#F8F7FF', accent='#F8F7FF', kind='blazer')),
 dict(id='OUTFIT_044', cat='Chic', n='Signature Label', d='Blazer gris anthracite pour signer un contrat.', price=40000, rank=3, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#3B3B4F', pants='#14102B', shoe='#14102B', accent='#3CD6F2', kind='blazer')),
 dict(id='OUTFIT_045', cat='Chic', n='Blazer Terracotta', d='Blazer terracotta, chemise sombre.', price=37000, rank=3, ref='bibliothèque v21', acc=('chain',), of=dict(top='#C0623B', pants='#2B1B14', shoe='#F2E8CF', accent='#F2E8CF', kind='blazer')),
 dict(id='OUTFIT_046', cat='Chic', n='Remise de Prix', d='Blazer noir profond et lunettes, pour la cérémonie.', price=48000, rank=4, ref='bibliothèque v21', acc=('chain', 'ring', 'glasses'), of=dict(top='#0C0820', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_047', cat='Chic', n='Blazer Lavande', d='Blazer lavande, chaussures blanches.', price=35000, rank=3, ref='bibliothèque v21', acc=('chain',), of=dict(top='#A78BFA', pants='#2B2459', shoe='#F8F7FF', accent='#F8F7FF', kind='blazer')),
 dict(id='OUTFIT_048', cat='Luxe', n='Or de Bakoma', d='Blazer or massif et chaîne lourde : le trône de Bakoma.', price=120000, rank=4, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#E0A800', pants='#14102B', shoe='#14102B', accent='#F8F7FF', kind='blazer')),
 dict(id='OUTFIT_049', cat='Luxe', n='Velours Nuit', d='Blazer velours violet profond, bagues et lunettes.', price=95000, rank=4, ref='bibliothèque v21', acc=('chain', 'ring', 'glasses'), of=dict(top='#3A1B52', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_050', cat='Luxe', n='Platine', d='Ensemble blanc platine, accents argent.', price=150000, rank=5, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#E5E4E2', pants='#B8B8C8', shoe='#14102B', accent='#14102B', kind='blazer')),
 dict(id='OUTFIT_051', cat='Luxe', n='Diamant Noir', d='Bomber noir mat, chaîne et bagues : la tenue des grandes dates.', price=180000, rank=5, ref='bibliothèque v21', acc=('chain', 'ring', 'glasses'), of=dict(top='#0A0A12', pants='#0A0A12', shoe='#F8F7FF', accent='#F8F7FF', kind='bomber')),
 dict(id='OUTFIT_052', cat='Luxe', n='Empereur Cauri', d='Blazer rouge impérial et or, réservé aux légendes.', price=250000, rank=5, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#9B111E', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_053', cat='Luxe', n='Saphir', d='Blazer bleu saphir, chaussures or, lunettes fines.', price=110000, rank=4, ref='bibliothèque v21', acc=('chain', 'ring', 'glasses'), of=dict(top='#0F52BA', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_054', cat='Luxe', n='Jade Royal', d='Bomber jade profond, finitions or.', price=90000, rank=4, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#00684A', pants='#003D2B', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_055', cat='Luxe', n='Rose Champagne', d='Blazer rose champagne pour les soirées de label.', price=100000, rank=4, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#E8B4B8', pants='#3A1B52', shoe='#F8F7FF', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_056', cat='Bijoux', n='Bagues Dorées', d='Tee noir et bagues or aux deux oreilles : les bijoux parlent.', price=15000, rank=2, ref='bibliothèque v21', acc=('chain', 'ring'), of=dict(top='#14102B', pants='#2B2459', shoe='#FFC83D', accent='#FFC83D', kind='tee')),
 dict(id='OUTFIT_057', cat='Bijoux', n='Chaîne et Lunettes', d='Hoodie blanc, chaîne or et lunettes noires.', price=20000, rank=2, ref='bibliothèque v21', acc=('chain', 'glasses'), of=dict(top='#F8F7FF', pants='#14102B', shoe='#14102B', accent='#FFC83D', kind='hoodie')),
 dict(id='OUTFIT_058', cat='Bijoux', n='Parure Complète', d='Bomber nuit, chaîne, bagues et lunettes.', price=45000, rank=3, ref='bibliothèque v21', acc=('chain', 'ring', 'glasses'), of=dict(top='#1E2A5A', pants='#0C0820', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
 dict(id='OUTFIT_059', cat='Bijoux', n='Casquette et Bagues', d='Tee magenta, casquette noire et bagues or.', price=18000, rank=2, ref='bibliothèque v21', acc=('chain', 'cap', 'ring'), of=dict(top='#F43F9D', pants='#14102B', shoe='#F8F7FF', accent='#14102B', kind='tee')),
 dict(id='OUTFIT_060', cat='Bijoux', n='Lunettes Cyan', d='Tee cyan et lunettes noires pour le soleil de Sélène.', price=12000, rank=1, ref='bibliothèque v21', acc=('chain', 'glasses'), of=dict(top='#3CD6F2', pants='#1F1942', shoe='#F8F7FF', accent='#14102B', kind='tee')),
 dict(id='OUTFIT_061', cat='Bijoux', n='Or et Casque', d='Hoodie noir, casque rose et bagues or.', price=26000, rank=3, ref='bibliothèque v21', acc=('chain', 'phones', 'ring'), of=dict(top='#14102B', pants='#2B2459', shoe='#F43F9D', accent='#FFC83D', kind='hoodie')),
 dict(id='OUTFIT_062', cat='Bijoux', n='Collection Cauri', d='Blazer crème et bijoux or façon cauri.', price=60000, rank=4, ref='bibliothèque v21', acc=('chain', 'ring', 'glasses'), of=dict(top='#F2E8CF', pants='#3A1B52', shoe='#FFC83D', accent='#FFC83D', kind='blazer')),
 dict(id='OUTFIT_063', cat='Bijoux', n='Casquette Dorée', d='Bomber violet et casquette, chaîne or.', price=16000, rank=2, ref='bibliothèque v21', acc=('chain', 'cap'), of=dict(top='#8B5CF6', pants='#3A1B52', shoe='#FFC83D', accent='#FFC83D', kind='bomber')),
]
VAR = {'young': dict(beard='stubble', mood='smile'), 'mature': dict(beard='full', mood='poised')}
def svg(o, v):
    return chars.figure(style='2d', view='front', skin=D['skin'], hair=D['hair'], hc=D['hc'], acc=o.get('acc', D['acc']), outfit=o['of'], crop='full', **VAR[v])
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
        man['outfits'].append({k: o[k] for k in ('id', 'cat', 'n', 'd', 'price', 'rank', 'ref')} | {'start': bool(o.get('start')), 'images': imgs,
                               'status': 'disponible' if imgs['young'] and imgs['mature'] else 'indisponible'})
    b.close()
json.dump(man, open(os.path.join(OUT, 'manifest.json'), 'w'), ensure_ascii=False, indent=1)
print(json.dumps([(o['id'], o['status']) for o in man['outfits']]))
