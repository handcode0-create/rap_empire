#!/usr/bin/env python3
"""Exporte les illustrations de RAP EMPIRE (personnages 2D modulaires, décors) en SVG pour Flutter.

Usage :  python3 tools/design/export_assets.py            (depuis la racine du dépôt Flutter)
Sortie : assets/characters/<who>_<mood>[_<gesture>][_<pose>]_<crop>.svg  et  assets/scenes/<kind>.svg
         assets/characters/manifest.json  (liste des fichiers pour le code Dart)

Les générateurs (chars.py, chars2.py, cast.py, scenes.py, art.py) sont en Python pur, sans dépendance.
Style de production provisoire : '2d' (D-01). Ne pas modifier l'identité des personnages (voir cast.py).
Les SVG sont nettoyés pour flutter_svg : pas de filtre, pas de mix-blend, pas de classes CSS.
"""
import json, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import art, cast, scenes
from cast import CAST

ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT_C = os.path.join(ROOT, 'assets', 'characters'); OUT_S = os.path.join(ROOT, 'assets', 'scenes')
STYLE = '2d'
MOODS = ['neutral', 'cool', 'smile', 'laugh', 'serious', 'worried', 'angry', 'poised', 'smirk', 'sing']
CROPS = ['head', 'bust', 'torso']
# combinaisons (qui, humeur, geste, pose, cadrage) réellement utilisées dans le prototype v20 (planches 16, 18, 19, 20-10)
USED = json.load(open(os.path.join(HERE, 'used_combos.json'), encoding='utf-8')) if os.path.exists(os.path.join(HERE, 'used_combos.json')) else []

def clean(svg):
    svg = re.sub(r'<filter\b.*?</filter>', '', svg, flags=re.S)
    svg = re.sub(r'\sfilter="[^"]*"', '', svg)
    svg = re.sub(r'mix-blend-mode:[^;"]*;?', '', svg)
    svg = svg.replace('style="width:100%;height:100%;display:block"', '')
    svg = re.sub(r'\sclass="[^"]*"', '', svg)
    return svg

def name(who, mood, g, pose, crop):
    return '_'.join([who, mood] + ([g] if g else []) + ([pose] if pose else []) + [crop]) + '.svg'

def main():
    os.makedirs(OUT_C, exist_ok=True); os.makedirs(OUT_S, exist_ok=True)
    jobs = set()
    for who in CAST:
        for m in CAST[who].get('moods', MOODS):
            for c in CROPS: jobs.add((who, m, '', '', c))
    for who, mood, g, _st, crop, _view, pose in USED: jobs.add((who, mood, g, pose, crop))
    files = []
    for who, mood, g, pose, crop in sorted(jobs):
        svg = clean(cast.P(who, mood, g, STYLE, crop, 'front', pose=pose))
        fn = name(who, mood, g, pose, crop)
        open(os.path.join(OUT_C, fn), 'w', encoding='utf-8').write(svg); files.append(fn)
    # avatar du joueur (v21, créateur d'artiste) : coiffure x haut x teint x humeur x cadrage, sous le nom me_<coiffure>_<haut>_<teint>_<humeur>_<cadrage>.svg
    # (hoodie rose = « Hoodie Néon », bomber violet, t-shirt cyan ; teints 3, 5 et 6 de SKINS ; la chaîne dorée du joueur reste)
    from chars import figure, SKINS
    tops = {'hoodie': dict(top='#F43F9D', kind='hoodie'), 'bomber': dict(top='#3A3270', kind='bomber', logo=False), 'tee': dict(top='#3CD6F2', kind='tee')}
    base = dict(pants='#2B2459', shoe='#F43F9D', accent='#FFC83D')
    for hair in ('hitwist', 'afro', 'cornrows'):
        for tk, tv in tops.items():
            for sk in (3, 5, 6):
                for mood in ('smile', 'cool'):
                    for crop in ('torso', 'bust'):
                        svg = clean(figure(STYLE, 'front', skin=SKINS[sk], hair=hair, hc='#1B1424', beard='stubble', mood=mood, outfit={**base, **tv}, acc=('chain',), crop=crop))
                        fn = 'me_%s_%s_%d_%s_%s.svg' % (hair, tk, sk, mood, crop)
                        open(os.path.join(OUT_C, fn), 'w', encoding='utf-8').write(svg); files.append(fn)
    # portraits uniques des enfants du joueur (v21, espace enfant) : identité fixe par enfant, trois étapes de vie,
    # kid_<enfant>_<étape>_<humeur>_<cadrage>.svg ; étape : bebe (moins de 1 an), enfant (1 à 11 ans), ado (12 ans et plus)
    kids = {
        'nayla': dict(skin=SKINS[4], hair='knots', hc='#1B1424', acc=('fem', 'ring'), outfit=dict(top='#FFC83D', pants='#2B2459', shoe='#F43F9D', accent='#F43F9D', kind='tee', logo=False)),
        'kenzo': dict(skin=SKINS[3], hair='afro', hc='#1B1424', acc=(), outfit=dict(top='#3CD6F2', pants='#2B2459', shoe='#F8F7FF', accent='#14102B', kind='hoodie', logo=False)),
    }
    stages = {'bebe': (.62, 1.22, 1.0, 26), 'enfant': (.78, 1.12, .92, 18), 'ado': (.92, 1.02, .97, 8)}
    for who, kd in kids.items():
        for st, sc in stages.items():
            for mood in ('neutral', 'smile', 'laugh'):
                for crop in ('head', 'bust'):
                    svg = clean(figure(STYLE, 'front', skin=kd['skin'], hair=kd['hair'], hc=kd['hc'], beard='none', mood=mood, outfit={**base, **kd['outfit']}, acc=kd['acc'], crop=crop, kid=sc))
                    fn = 'kid_%s_%s_%s_%s.svg' % (who, st, mood, crop)
                    open(os.path.join(OUT_C, fn), 'w', encoding='utf-8').write(svg); files.append(fn)
    json.dump({'style': STYLE, 'cast': {k: v['name'] for k, v in CAST.items()}, 'files': files}, open(os.path.join(OUT_C, 'manifest.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    for kind, f in scenes.BGS.items():
        open(os.path.join(OUT_S, kind + '.svg'), 'w', encoding='utf-8').write(clean(f()))
    # bannière du QG (03.1) : ciel nocturne 390 x 72, identique à art.skyline(72) de la planche
    open(os.path.join(OUT_S, 'qg_sky.svg'), 'w', encoding='utf-8').write(clean(art.skyline(72, title=False)))
    # rayonnement des écrans de célébration (niveau supérieur, mission accomplie) : art.burst() de la planche 10.4
    open(os.path.join(OUT_S, 'burst.svg'), 'w', encoding='utf-8').write(clean(art.burst()))
    print('%d personnages, %d décors + qg_sky, burst' % (len(files), len(scenes.BGS)))

if __name__ == '__main__': main()
