# États de partie pour capturer les écrans de droits d'auteur (CI) : avis non vu (animation), avis vu (détail), rendez-vous.
# Usage : python3 tool/screens/make_litige.py dossier/  → litige_avis.json, litige_detail.json, litige_rdv.json
# Part de state_star.json et y ajoute un titre viral sur une instru non autorisée, plus un titre sur une instru à conditions.
import sys, os, json, copy

OUT = sys.argv[1] if len(sys.argv) > 1 else '.'
base = json.load(open(os.path.join(os.path.dirname(__file__), 'state_star.json')))
day = base.get('day', 30)

def song(id_, title, inst, listens, rev, cr):
    s = copy.deepcopy(base['disco'][0])
    s.update({'id': id_, 'title': title, 'inst': inst, 'L': listens, 'launchL': listens, 'rev': rev, 'day': day - 6, 'cr': cr, 'st': 'sorti'})
    return s

def state(claim_patch):
    s = copy.deepcopy(base)
    s['disco'] = [
        song('T90', 'Pluie sur Ndolo', 'brume', 3200000, 1180000, {'st': 'litige', 'lic': 'nonaut', 'owner': 'woro', 'claimed': 1, 'was': 'nonaut'}),
        song('T91', 'Drill du carrefour', 'minuit', 640000, 230000, {'st': 'cond', 'lic': 'cond', 'owner': 'tamsir'}),
    ] + s['disco']
    s['crc'] = {'id': 'T90', 'title': 'Pluie sur Ndolo', 'owner': 'woro', 'kind': 'nonaut', 'L': 3200000, 'rev': 1180000, 'pct': 0.35, 'amt': 413000,
                'found': day - 2, 'at': day, 'st': 'avis', 'tension': 0, 'escrow': 0, 'paid': 0, 'seen': 0, 'due': day + 5}
    s['crc'].update(claim_patch)
    s['crHist'] = []
    s['dlg'] = None
    s['dq'] = []
    s.setdefault('ui', {})['ctk'] = 'T91'
    s['cash'] = max(s.get('cash', 0), 900000)
    return s

os.makedirs(OUT, exist_ok=True)
for name, patch in (('litige_avis', {}), ('litige_detail', {'seen': 1}), ('litige_rdv', {'seen': 1, 'st': 'nego', 'node': 'n1', 'met': 1})):
    json.dump(state(patch), open(os.path.join(OUT, name + '.json'), 'w'), ensure_ascii=False)
    print('ok', name)
