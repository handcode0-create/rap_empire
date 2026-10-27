#!/usr/bin/env python3
"""Génère lib/domain/title_bank.dart : le dictionnaire de 5 000 titres de RAP EMPIRE.

    4 400 titres de singles (440 pour chacun des 10 thèmes), 300 noms d'EP, 300 noms d'albums, tous uniques.
Déterministe (graine fixe) : relancer le script redonne exactement le même fichier.
Monde fictif : aucun nom d'artiste, de marque ni de lieu réel (les lieux sont ceux de Bakoma).
Usage : python3 tools/data/gen_title_bank.py
"""
import os, random, re, sys, unicodedata
sys.path.insert(0, os.path.dirname(__file__))
from title_vocab import *

PER_THEME, EP_COUNT, ALBUM_COUNT, MAXLEN = 440, 300, 300, 30
rnd = random.Random(20261022)


def vowel(w):
    return unicodedata.normalize('NFD', w[0].lower())[0] in 'aeiouyh'


PERSON = set("frère soldat voisin rival maître roi public griot ancêtres père mère fantôme famille".split())
PLACE = set("quartier bitume trottoir carrefour bloc ruelle marché toit escalier mur fenêtre chemin club terrasse maquis piste scène stade tunnel étage zone village cour maison rivière fleuve lagune pays ville frontière chambre route villa banque ring loge panthéon rue".split()) | {"coin de rue", "premier rang"}
TIME = set("minuit demain samedi matin aube soirée nuit saison".split())
OBJECT = set("billet liasse coffre chèque montre chaîne bague voiture costume poche ticket gbaka radio lampadaire pavé micro bouteille verre tambour pagne drapeau disque trophée avion écran statue masque phare alarme rideau couronne trône photo lettre message appel numéro parfum miroir palmier sono affiche barrière tremplin boussole compte cauris projecteurs".split())
ENV = set("pluie lune brume fumée lumière néon soleil étoile ciel ombre ténèbres orage".split())
UNCOUNT = set("silence respect faim loyauté survie débrouille fierté confiance jalousie domination contrôle autorité précision vitesse discipline détermination volonté galère tension mystère pouvoir tendresse désir pardon tristesse fatigue solitude mémoire conscience vérité richesse valeur capital crédit concurrence force flow style niveau".split())
POETIC = set("silence cœur voix regard promesse serment couronne nuit ombre rêve flamme étoile parole chaîne".split())
BUREAU = set("coupure commission part pourcentage compte crédit loyer budget bilan affaire prix valeur avance investissement capital rente bénéfice chèque salaire billet liasse coffre classement position titre record coup barre ligue alarme signal code règle ordre décompte plan marche échelon objectif cap programme poids pari entraînement concurrence compétition contrôle technique précision vitesse niveau fin de mois".split()) | {"fin de mois"}
AGAINST = set("galère trahison dette rivalité jalousie mensonge doute silence regret vide fatigue concurrence absence distance tristesse faim danger tension peur rupture dispute blessure insomnie solitude".split()) | {"rival"}
FOR_ = {"quartier", "bloc", "village", "pays", "ville", "famille", "maison", "terre", "frère", "mère", "père", "voisin", "soldat", "public", "griot"}
SOUS = set("pluie lune brume fumée lumière néon soleil étoile ciel ombre ténèbres orage lampadaire projecteurs rideau toit nuit".split())
ALBUM_NOUNS = set("mémoire silence promesse couronne légende héritage voix fierté loyauté ombre regard rêve ascension victoire empire destin avenir chemin histoire souvenir secret cicatrice nuit étoile flamme racines terre famille origine fortune discipline revanche horizon élan défi lumière scène foule tournée trophée renommée nom conscience vérité tendresse blessure enfance absence solitude confiance vérité mémoire couleurs langue tradition culture ancêtres village quartier lagune fleuve soleil sable ville pays".split())
EP_NOUNS = ALBUM_NOUNS | set("bitume ticket gbaka maquis ruelle trottoir carrefour bloc piste club tunnel minuit galère survie débrouille poche radio fenêtre mur ticket bal sono basse rythme groove tempo nuit zone brume fumée néon masque".split())
HUMAN_ADJ = set("loyal fidèle têtu ambitieux jaloux patient obstiné insolent fier seul éveillé humain nu indépendant discret souverain redoutable intouchable imbattable invincible".split())
PHYS_ADJ = set("bétonné usé doré brillant précieux éclatant opaque lourd éteint glacial rapide tranchant".split())
NEUTRAL_ADJ = [adj for adj in "éternel/éternelle, infini/infinie, dernier/dernière, premier/première, ancien/ancienne, secret/secrète, silencieux/silencieuse, interdit/interdite, perdu/perdue, oublié/oubliée, vivant/vivante, immense, libre, brisé/brisée, sincère, fragile, sombre, royal/royale, lointain/lointaine, intérieur/intérieure, ardent/ardente, lent/lente, clair/claire, profond/profonde, nocturne, sauvage, brut/brute".split(", ")]


def klass(n):
    if n.text in PERSON:
        return 'P'
    if n.text in PLACE:
        return 'L'
    if n.text in TIME:
        return 'T'
    if n.text in OBJECT:
        return 'O'
    if n.text in ENV:
        return 'E'
    return 'A'


class Noun:
    def __init__(self, spec):
        spec, _, pl = spec.partition('|')
        text, _, g = spec.rpartition('/')
        self.text, self.g, self._pl = text.strip(), g.strip(), pl.strip()

    @property
    def plural_g(self):
        return self.g in ('mp', 'fp')

    def pl(self):
        if self._pl:
            return self._pl
        if ' ' in self.text or '-' in self.text or self.g not in ('m', 'f'):
            return None
        t = self.text
        if t.endswith(('s', 'x', 'z')):
            return t
        if t.endswith('al'):
            return t[:-2] + 'aux'
        if t.endswith(('eau', 'eu')):
            return t + 'x'
        return t + 's'

    def art(self):  # le / la / l' / les
        if self.g == 'b':
            return None
        if self.plural_g:
            return 'les ' + self.text
        if vowel(self.text):
            return "l'" + self.text
        return ('le ' if self.g == 'm' else 'la ') + self.text

    def de(self):  # du / de la / de l' / des
        if self.g == 'b':
            return None
        if self.plural_g:
            return 'des ' + self.text
        if vowel(self.text):
            return "de l'" + self.text
        return ('du ' if self.g == 'm' else 'de la ') + self.text

    def a(self):  # au / à la / à l' / aux
        if self.g == 'b':
            return None
        if self.plural_g:
            return 'aux ' + self.text
        if vowel(self.text):
            return "à l'" + self.text
        return ('au ' if self.g == 'm' else 'à la ') + self.text

    @property
    def k(self):
        return klass(self)

    def adj_g(self):
        return {'m': 'm', 'f': 'f', 'mp': 'mp', 'fp': 'fp', 'b': 'm'}[self.g]


def adj_forms(spec):
    spec = spec.strip()
    m, _, f = spec.partition('/')
    f = f or m
    def plural(w):
        if w.endswith(('s', 'x')):
            return w
        if w.endswith('al'):
            return w[:-2] + 'aux'
        return w + 's'
    return {'m': m, 'f': f, 'mp': plural(m), 'fp': plural(f), 'kind': 'H' if m in HUMAN_ADJ else ('P' if m in PHYS_ADJ else 'N')}


def adj_fits(a, n):
    """Un adjectif humain ne qualifie qu'une personne ; un adjectif physique, qu'un objet, un lieu ou un élément."""
    if a['kind'] == 'H':
        return n.k == 'P'
    if a['kind'] == 'P':
        return n.k in ('O', 'L', 'E')
    return True


def de_bare(w):
    return ("d'" if vowel(w) else 'de ') + w


def cap(s):
    return s[0].upper() + s[1:]


def split(s, sep):
    return [x.strip() for x in s.split(sep) if x.strip()]


def ok(title, used):
    if len(title) > MAXLEN or len(title) < 3:
        return False
    if title.lower() in used:
        return False
    words = re.findall(r"[\wÀ-ÿ']+", title.lower())
    content = [w for w in words if len(w) > 3]
    if len(content) != len(set(content)):
        return False
    stems = [w[:5] for w in content]
    if len(stems) != len(set(stems)):
        return False
    if re.search(r"\b(\w+) \1\b", title.lower()):
        return False
    return True


def combos(theme):
    """Candidats combinatoires d'un thème, groupés par modèle. Chaque modèle n'accepte que des assemblages cohérents (classes de mots)."""
    nouns = [Noun(x) for x in split(theme['nouns'], ',')]
    arts = [n for n in nouns if n.g != 'b']
    mats = split(theme['mats'], ',')
    adjs = [adj_forms(x) for x in split(theme['adjs'], ',')]
    out = {}

    def add(k, t):
        out.setdefault(k, []).append(cap(t))

    comp_ok = lambda o: o.k in ('L', 'P', 'T') and o.text not in BUREAU
    nouns = [n for n in nouns if n.text not in BUREAU or n.g == 'b'] + [n for n in nouns if False]
    arts = [n for n in nouns if n.g != 'b']
    for n in nouns:
        if n.k == 'A' and len(n.text) >= 6 and n.g != 'b' and n.text not in BUREAU:
            add('seul', n.text)
        for a in adjs:
            if adj_fits(a, n):
                add('n_adj', f"{n.text} {a[n.adj_g()]}")
        if n.g == 'b':
            continue
        for a in adjs:
            if adj_fits(a, n):
                add('art_n_adj', f"{n.art()} {a[n.g]}")
        if n.k in ('O', 'L', 'P') or n.text in POETIC:
            for m in mats:
                if m != n.text:
                    add('n_mat', f"{n.text} {de_bare(m)}")
        for o in arts:
            if o.text != n.text and comp_ok(o) and not (n.k == 'L' and o.k == 'L') and not n.plural_g:
                add('n_de', f"{n.text} {o.de()}")
        if n.k == 'A':
            add('sans', f"sans {n.text}")
            add('pas_de', f"pas {de_bare(n.text)}")
            add('plus_de', f"plus {de_bare(n.text)}")
        if n.k in ('A', 'T', 'O', 'P'):
            for pl in PLACES:
                add('n_place', f"{n.text} à {pl}")
                add('n_place', f"{n.text} de {pl}")
        for o in nouns:
            if o.text != n.text and o.g != 'b' and n.k == o.k and n.k in ('A', 'L', 'O'):
                add('n_et', f"{n.text} et {o.text}")
    for n in arts:
        if n.k in ('A', 'T'):
            add('prep', f"avant {n.art()}")
            add('prep', f"après {n.art()}")
        if n.text in SOUS:
            add('prep', f"sous {n.art()}")
        if n.text in AGAINST:
            add('prep', f"contre {n.art()}")
            add('prep', f"malgré {n.art()}")
        if n.text in FOR_:
            add('prep', f"pour {n.art()}")
    for a in arts:
        for b in arts:
            if a.text != b.text and a.k == 'A' and b.k == 'A' and not a.plural_g and not b.plural_g:
                add('entre', f"entre {a.text} et {b.text}")
    for n in arts:
        pl = n.pl()
        if pl and not n.plural_g and n.text not in UNCOUNT and n.k != 'T':
            for num in NUMBERS:
                add('nombre', f"{num} {pl}")
        if n.k in ('A', 'O', 'L'):
            add('reste', f"que reste-t-il {n.de()} ?")
            add('passe', f"où est passé{'e' if n.g == 'f' else ''}{'s' if n.plural_g else ''} {n.art()} ?")
    for k in ('reste', 'passe'):  # ces deux modèles restent rares
        rnd.shuffle(out.get(k, []))
        out[k] = out.get(k, [])[:8]
    return out


def pick_theme(name, theme, used):
    chosen = []
    for kind, key in (('phrases', 'h'), ('verbs', 'v'), ('personal', 'p')):
        for t in split(theme[kind], '|'):
            if ok(t, used):
                used.add(t.lower())
                chosen.append(t)
    pools = combos(theme)
    for k in pools:
        rnd.shuffle(pools[k])
    # parts relatives des modèles combinatoires (somme arbitraire, normalisée par le tour de rôle)
    order = ['n_adj', 'art_n_adj', 'n_de', 'n_mat', 'n_et', 'prep', 'sans', 'pas_de', 'n_place', 'nombre', 'seul', 'plus_de', 'entre', 'reste', 'passe']
    weights = {'n_adj': 4, 'art_n_adj': 4, 'n_de': 4, 'n_mat': 3, 'n_et': 2, 'prep': 3, 'sans': 1, 'pas_de': 1, 'n_place': 2, 'nombre': 1, 'seul': 2, 'plus_de': 1, 'entre': 1, 'reste': 1, 'passe': 1}
    idx = {k: 0 for k in order}
    guard = 0
    while len(chosen) < PER_THEME and guard < 100000:
        progressed = False
        for k in order:
            for _ in range(weights[k]):
                pool = pools.get(k, [])
                while idx[k] < len(pool) and not ok(pool[idx[k]], used):
                    idx[k] += 1
                if idx[k] < len(pool) and len(chosen) < PER_THEME:
                    t = pool[idx[k]]
                    idx[k] += 1
                    used.add(t.lower())
                    chosen.append(t)
                    progressed = True
        guard += 1
        if not progressed:
            break
    if len(chosen) < PER_THEME:
        raise SystemExit(f"thème {name} : seulement {len(chosen)} titres")
    rnd.shuffle(chosen)
    return chosen


def all_nouns():
    seen, res = set(), []
    for th in THEMES.values():
        for x in split(th['nouns'], ','):
            n = Noun(x)
            if n.text not in seen:
                seen.add(n.text)
                res.append(n)
    return res


def all_adjs():
    seen, res = set(), []
    for th in THEMES.values():
        for x in split(th['adjs'], ','):
            if x not in seen:
                seen.add(x)
                res.append(adj_forms(x))
    return res


def all_mats():
    return sorted({m for th in THEMES.values() for m in split(th['mats'], ',')})


def roman(i):
    return ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'][i]


def class_nouns(allowed):
    return [n for n in all_nouns() if n.g != 'b' and n.text in allowed]


def neutral_adjs():
    return [adj_forms(x) for x in NEUTRAL_ADJ]


def ep_candidates():
    nouns = class_nouns(EP_NOUNS)
    mats = all_mats()
    adjs = neutral_adjs()
    out = {}

    def add(k, t):
        out.setdefault(k, []).append(t)

    for pl in PLACES:
        for form in ("{} Sessions", "Lettres de {}", "Face B de {}", "Carnet de {}", "{} Tape", "{} en poche", "Direction {}"):
            add('sessions', form.format(pl))
    for n in nouns:
        comp = n.k in ('A', 'L', 'T', 'P') and not (n.plural_g and n.k == 'A')
        if comp:
            add('de', f"Sessions {n.de()}")
            for lead in ('Notes', 'Carnet', 'Cahier', 'Brouillons'):
                add('notes', f"{lead} {n.de()}")
        if n.k in ('A', 'L', 'O', 'T') and len(n.text) >= 5:
            add('tape', f"{cap(n.text)} Tape")
            for k in (1, 2, 3):
                add('vol', f"{cap(n.text)} Vol. {k}")
        if n.k in ('A', 'T'):
            add('avant', f"Avant {n.art()}")
            add('avant', f"Prélude {n.a()}")
        if n.k in ('A', 'L', 'T'):
            for a in adjs:
                add('adj', f"{cap(n.text)} {a[n.adj_g()]}")
    for m in mats:
        add('mat', f"Sessions {de_bare(m)}")
        add('mat', f"Notes {de_bare(m)}")
        add('mat', f"Tape {de_bare(m)}")
    for i in range(10):
        add('chap', f"Chapitre {roman(i)}")
        add('chap', f"Acte {roman(i)}")
        add('chap', f"Épisode {i + 1}")
    for h in split(EP_HAND, '|'):
        add('hand', h)
    return out


def album_candidates():
    nouns = class_nouns(ALBUM_NOUNS)
    adjs = neutral_adjs()
    out = {}

    def add(k, t):
        out.setdefault(k, []).append(t)

    for n in nouns:
        if n.k in ('A', 'L', 'T'):
            for a in adjs:
                add('art_adj', f"{cap(n.art())} {a[n.g]}")
        if n.k == 'A' and not n.plural_g:
            for o in nouns:
                if o.k in ('L', 'P', 'T') and not o.plural_g:
                    add('de', f"{cap(n.text)} {o.de()}")
        pl = n.pl()
        if pl and n.k in ('A', 'O', 'P') and n.text not in UNCOUNT:
            for place in PLACES:
                add('place', f"Les {pl} de {place}")
        if n.k in ('A', 'T'):
            add('avant', f"Avant {n.art()}")
            add('avant', f"Après {n.art()}")
        if n.k in ('L', 'E', 'T'):
            add('avant', f"Sous {n.art()}")
        if n.k in ('A', 'L', 'P'):
            for lead in ('Le livre', 'Le chant', 'Éclats', 'Fragments', 'Mémoires', 'Chronique'):
                add('lead', f"{lead} {n.de()}")
        if n.k == 'P':
            add('lead', f"Le testament {n.de()}")
            add('lead', f"Portrait {n.de()}")
    for place in PLACES:
        for lead in ('Chroniques de', 'Histoires de', 'Légendes de', 'Mémoires de', 'Portrait de', 'Nuits de', 'Lumières de', 'Héritage de', 'Rois de', 'Enfants de'):
            add('place', f"{lead} {place}")
    units = [Noun(x) for x in split(UNITS, ',')]
    for num in NUMBERS:
        for u in units:
            add('nombre', f"{cap(num)} {u.pl()}")
    for h in split(ALBUM_HAND, '|'):
        add('hand', h)
    return out


def take(cands, order_weights, count, used):
    for k in cands:
        rnd.shuffle(cands[k])
    idx = {k: 0 for k in cands}
    chosen = []
    guard = 0
    keys = list(order_weights)
    while len(chosen) < count and guard < 10000:
        progressed = False
        for k in keys:
            for _ in range(order_weights[k]):
                pool = cands.get(k, [])
                while idx[k] < len(pool) and not ok(pool[idx[k]], used):
                    idx[k] += 1
                if idx[k] < len(pool) and len(chosen) < count:
                    t = pool[idx[k]]
                    idx[k] += 1
                    used.add(t.lower())
                    chosen.append(t)
                    progressed = True
        guard += 1
        if not progressed:
            break
    if len(chosen) < count:
        raise SystemExit(f"seulement {len(chosen)} / {count}")
    rnd.shuffle(chosen)
    return chosen


def dart_list(items, indent='    '):
    lines = []
    for t in items:
        q = t.replace('\\', '\\\\').replace('"', '\\"').replace('$', '\\$')
        lines.append(f'{indent}"{q}",')
    return '\n'.join(lines)


def main():
    used = set()
    singles = {name: pick_theme(name, th, used) for name, th in THEMES.items()}
    ep = take(ep_candidates(), {'hand': 2, 'sessions': 2, 'de': 2, 'tape': 2, 'vol': 1, 'notes': 2, 'avant': 1, 'adj': 3, 'mat': 1, 'chap': 1}, EP_COUNT, used)
    album = take(album_candidates(), {'hand': 2, 'art_adj': 4, 'de': 3, 'place': 3, 'avant': 2, 'lead': 3, 'nombre': 2}, ALBUM_COUNT, used)
    total = sum(len(v) for v in singles.values()) + len(ep) + len(album)
    out = ['// GÉNÉRÉ par tools/data/gen_title_bank.py : ne pas modifier à la main (relancer le script).',
           f'// Dictionnaire de {total} titres uniques : {sum(len(v) for v in singles.values())} singles (par thème), {len(ep)} EP, {len(album)} albums.',
           "// Monde fictif de Bakoma : aucun artiste, marque ni lieu réel. Les titres communs (« Héritage », « Genèse »…) restent de simples mots.",
           '', '/// Titres de singles par thème (id de musicThemes).', 'const titleBankSingles = <String, List<String>>{']
    for name, items in singles.items():
        out.append(f"  '{name}': [")
        out.append(dart_list(items))
        out.append('  ],')
    out.append('};\n')
    out.append('/// Noms d\'EP.\nconst titleBankEp = <String>[')
    out.append(dart_list(ep))
    out.append('];\n')
    out.append('/// Noms d\'albums.\nconst titleBankAlbum = <String>[')
    out.append(dart_list(album))
    out.append('];\n')
    dest = os.path.join(os.path.dirname(__file__), '..', '..', 'lib', 'domain', 'title_bank.dart')
    with open(dest, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out))
    print('total', total, {k: len(v) for k, v in singles.items()}, len(ep), len(album))


main()
