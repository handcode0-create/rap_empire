from chars import figure, SKINS, darken

CAST = {
 'djo':   dict(name='Djo Kéné', role='Toi, rappeur', skin=SKINS[3], hair='hitwist', hc='#1B1424', beard='stubble', acc=('chain',), outfit=dict(top='#F43F9D', pants='#2B2459', shoe='#F43F9D', accent='#FFC83D', kind='hoodie')),
 'kore':  dict(name='DJ Kôrô', role='Producteur · Studio Kôrô', skin=SKINS[5], hair='fade', hc='#1A1A1A', beard='full', acc=('glasses', 'phones'), outfit=dict(top='#3A3270', pants='#14102B', shoe='#8B5CF6', accent='#3CD6F2', kind='bomber', logo=False)),
 'orage': dict(name='Madame Orage', role='Directrice artistique · Bakoma Sound Records', skin=SKINS[2], hair='braids', hc='#14102B', beard='none', acc=('ring', 'fem'), outfit=dict(top='#2B2459', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='blazer', logo=False)),
 'zaki':  dict(name='Zaki Mbela', role='Rappeur · rival de Ndolo', skin=SKINS[4], hair='cornrows', hc='#14102B', beard='goatee', acc=('ring',), outfit=dict(top='#0C0820', pants='#1F1942', shoe='#3CD6F2', accent='#3CD6F2', kind='bomber', logo=False)),
 'nadia': dict(name='Maya Tessé', role='Manager', skin=SKINS[5], hair='knots', hc='#14102B', beard='none', acc=('fem', 'glasses'), outfit=dict(top='#F43F9D', pants='#14102B', shoe='#F8F7FF', accent='#F8F7FF', kind='blazer', logo=False)),
 'zamba': dict(name='Kouassi Zamba', role='Promoteur · Festival Lagune d\'Ambre', skin=SKINS[6], hair='bald', hc='#14102B', beard='goatee', acc=(), outfit=dict(top='#B8860B', pants='#14102B', shoe='#14102B', accent='#FFC83D', kind='blazer', logo=False)),
 'rosine': dict(name='Rosine Adjoua', role='Manager · presse et crise', skin=SKINS[4], hair='locks', hc='#7A7A8C', beard='none', acc=('fem', 'ring'), outfit=dict(top='#0E7C86', pants='#14102B', shoe='#F8F7FF', accent='#FFC83D', kind='blazer', logo=False)),
 'anselme': dict(name='Anselme Bayoko', role='Manager · négociation de contrats', skin=SKINS[6], hair='fade', hc='#14102B', beard='stubble', acc=('glasses',), outfit=dict(top='#1B2A5C', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='blazer', logo=False)),
 'ayana': dict(name='Ayana Dembé', role='Artiste · chanteuse afro-soul', skin=SKINS[3], hair='afro', hc='#1B1424', beard='none', acc=('fem', 'ring'), outfit=dict(top='#3CD6F2', pants='#2B2459', shoe='#F8F7FF', accent='#FFC83D', kind='hoodie', logo=False)),
 'kzer':  dict(name="K-Zer d'Mabaya", role='Rappeur · adversaire de battle', skin=SKINS[5], hair='hitwist', hc='#14102B', beard='goatee', acc=('ring',), outfit=dict(top='#8B5CF6', pants='#14102B', shoe='#F8F7FF', accent='#3CD6F2', kind='hoodie', logo=False)),
 'woro':  dict(name='Mister Wôrô', role="Beatmaker · instru Lagune d'Ambre", skin=SKINS[4], hair='bald', hc='#14102B', beard='full', acc=('glasses', 'phones'), outfit=dict(top='#F8F7FF', pants='#2B2459', shoe='#FFC83D', accent='#FFC83D', kind='tee', logo=False)),
 'sanko': dict(name='Sanko Beats', role='Beatmaker · instru Pont des Griots', skin=SKINS[3], hair='fade', hc='#14102B', beard='stubble', acc=('cap',), outfit=dict(top='#3DDC97', pants='#14102B', shoe='#F43F9D', accent='#14102B', kind='tee', logo=False)),
 # Profils de rencontres v21 : personnages dessinés par le générateur, sans lien avec les artistes du même nom.
 'ines':  dict(name='Inès Waly', role='Styliste', skin=SKINS[3], hair='braids', hc='#14102B', beard='none', acc=('fem', 'ring'), outfit=dict(top='#8B5CF6', pants='#14102B', shoe='#FFC83D', accent='#3CD6F2', kind='blazer', logo=False)),
 'kadi':  dict(name='Kadi Sora', role='Infirmière', skin=SKINS[4], hair='afro', hc='#21162D', beard='none', acc=('fem',), outfit=dict(top='#3CD6F2', pants='#2B2459', shoe='#F8F7FF', accent='#FFC83D', kind='tee', logo=False)),
 'lina':  dict(name='Lina Mbaré', role='Danseuse', skin=SKINS[2], hair='knots', hc='#14102B', beard='none', acc=('fem',), outfit=dict(top='#F43F9D', pants='#14102B', shoe='#F8F7FF', accent='#FFC83D', kind='hoodie', logo=False)),
 'sefa':  dict(name='Sefa Doumbé', role='Journaliste musique', skin=SKINS[5], hair='locks', hc='#14102B', beard='none', acc=('fem', 'glasses'), outfit=dict(top='#3A3270', pants='#14102B', shoe='#3CD6F2', accent='#FFC83D', kind='blazer', logo=False)),
 'amara': dict(name='Amara Teki', role='Étudiante en droit', skin=SKINS[1], hair='cornrows', hc='#14102B', beard='none', acc=('fem',), outfit=dict(top='#3DDC97', pants='#2B2459', shoe='#F8F7FF', accent='#FFC83D', kind='bomber', logo=False)),
 'yao':   dict(name='Yao Bellam', role='Photographe', skin=SKINS[6], hair='fade', hc='#14102B', beard='goatee', acc=('glasses',), outfit=dict(top='#2B2459', pants='#14102B', shoe='#FFC83D', accent='#3CD6F2', kind='bomber', logo=False)),
 'noe':   dict(name='Noé Akan', role='Chef cuisinier', skin=SKINS[3], hair='bald', hc='#14102B', beard='full', acc=(), outfit=dict(top='#F8F7FF', pants='#2B2459', shoe='#FFC83D', accent='#F43F9D', kind='tee', logo=False)),
 'teo':   dict(name='Téo Gbéli', role='Animateur radio', skin=SKINS[5], hair='hitwist', hc='#14102B', beard='stubble', acc=('phones',), outfit=dict(top='#8B5CF6', pants='#14102B', shoe='#3CD6F2', accent='#FFC83D', kind='hoodie', logo=False)),

 'awa': dict(name='Awa Liméa', role='Découvreuse de talents · Aube Nouvelle', skin=SKINS[2], hair='afro', hc='#21162D', beard='none', acc=('fem', 'ring'), outfit=dict(top='#FFC83D', pants='#14102B', shoe='#F43F9D', accent='#3CD6F2', kind='blazer', logo=False)),
 'bakary': dict(name='Bakary Fé', role='Fondateur · Ndolo Underground', skin=SKINS[6], hair='fade', hc='#14102B', beard='full', acc=('ring',), outfit=dict(top='#14102B', pants='#2B2459', shoe='#FFC83D', accent='#F43F9D', kind='bomber', logo=False)),
 'liv': dict(name='Liv Sélou', role='Porte-parole · Sélène Indie Collective', skin=SKINS[1], hair='knots', hc='#3A2040', beard='none', acc=('fem', 'glasses'), outfit=dict(top='#3CD6F2', pants='#14102B', shoe='#F8F7FF', accent='#FFC83D', kind='blazer', logo=False)),
 'marius': dict(name='Marius Argent', role='Directeur · Vague Argentée', skin=SKINS[5], hair='bald', hc='#14102B', beard='goatee', acc=('glasses',), outfit=dict(top='#F8F7FF', pants='#14102B', shoe='#3CD6F2', accent='#FFC83D', kind='blazer', logo=False)),
 'kre': dict(name='Jonas Kré', role='Directeur artistique · Black Lagune', skin=SKINS[4], hair='cornrows', hc='#14102B', beard='stubble', acc=('ring',), outfit=dict(top='#0C0820', pants='#1F1942', shoe='#F43F9D', accent='#3CD6F2', kind='hoodie', logo=False)),
 'maze': dict(name='Prof Mazé', role='Fondateur · Lyrik Atelier', skin=SKINS[3], hair='fade', hc='#21162D', beard='full', acc=('glasses',), outfit=dict(top='#3A3270', pants='#14102B', shoe='#FFC83D', accent='#3CD6F2', kind='blazer', logo=False)),
 'benedicte': dict(name='Bénédicte Kassi', role='Présidente · Ambre Music Group', skin=SKINS[2], hair='braids', hc='#14102B', beard='none', acc=('fem', 'ring'), outfit=dict(top='#FFC83D', pants='#14102B', shoe='#F8F7FF', accent='#F43F9D', kind='blazer', logo=False)),
 'kofi': dict(name='Kofi Ndayé', role='Directeur export · Rythme Cardinal', skin=SKINS[6], hair='hitwist', hc='#14102B', beard='stubble', acc=('glasses',), outfit=dict(top='#3CD6F2', pants='#14102B', shoe='#FFC83D', accent='#F43F9D', kind='bomber', logo=False)),
 'kaira': dict(name='Kaïra Nox', role='Artiste · drill', skin=SKINS[5], hair='cornrows', hc='#14102B', beard='none', acc=('fem',), outfit=dict(top='#F43F9D', pants='#0C0820', shoe='#3CD6F2', accent='#FFC83D', kind='hoodie', logo=False)),
 'tito': dict(name='Tito Brume', role='Artiste · rap conscient', skin=SKINS[3], hair='afro', hc='#21162D', beard='goatee', acc=('chain',), outfit=dict(top='#3DDC97', pants='#14102B', shoe='#F8F7FF', accent='#FFC83D', kind='tee', logo=False)),
 'lazuli': dict(name='Lazuli', role='Artiste · afro-soul', skin=SKINS[2], hair='locks', hc='#14102B', beard='none', acc=('fem', 'ring'), outfit=dict(top='#3CD6F2', pants='#2B2459', shoe='#FFC83D', accent='#F43F9D', kind='blazer', logo=False)),
 'nadia-kolo': dict(name='Nadia Kolo', role='Chanteuse · featuring', skin=SKINS[4], hair='knots', hc='#14102B', beard='none', acc=('fem', 'glasses'), outfit=dict(top='#8B5CF6', pants='#14102B', shoe='#F8F7FF', accent='#FFC83D', kind='bomber', logo=False)),
 'solo': dict(name='Sôlo Vance', role='Artiste · trap', skin=SKINS[6], hair='hitwist', hc='#14102B', beard='goatee', acc=('chain',), outfit=dict(top='#14102B', pants='#2B2459', shoe='#F43F9D', accent='#3CD6F2', kind='hoodie', logo=False)),
 'mika': dict(name='Mika Soro', role='Manager · développement et image', skin=SKINS[5], hair='fade', hc='#14102B', beard='stubble', acc=('glasses',), outfit=dict(top='#1B2A5C', pants='#14102B', shoe='#FFC83D', accent='#3CD6F2', kind='blazer', logo=False)),
 'tamsir': dict(name='Tamsir Koffi', role='Beatmaker · sonorités afro-drill', skin=SKINS[4], hair='cornrows', hc='#14102B', beard='goatee', acc=('phones',), outfit=dict(top='#F43F9D', pants='#14102B', shoe='#3CD6F2', accent='#FFC83D', kind='tee', logo=False)),
 'desire': dict(name='Désiré Kpan', role='Road manager · logistique de tournée', skin=SKINS[6], hair='bald', hc='#14102B', beard='full', acc=('glasses',), outfit=dict(top='#3DDC97', pants='#14102B', shoe='#FFC83D', accent='#F43F9D', kind='bomber', logo=False)),
 'naya': dict(name='Naya Rêve', role='Artiste · rap mélodique et R&B', skin=SKINS[1], hair='afro', hc='#21162D', beard='none', acc=('fem', 'ring'), outfit=dict(top='#F43F9D', pants='#2B2459', shoe='#F8F7FF', accent='#3CD6F2', kind='hoodie', logo=False)),
 # curateurs des playlists éditoriales d'Ondéa (identité fixe, comme tout le cast)
 'sadia': dict(name='Sadia Kouamé', role='Curatrice Ondéa · Drill de Bakoma', skin=SKINS[4], hair='cornrows', hc='#14102B', beard='none', acc=('fem', 'phones'), outfit=dict(top='#14102B', pants='#2B2459', shoe='#F43F9D', accent='#F43F9D', kind='bomber', logo=False)),
 'malik': dict(name='Malik Ebo', role='Curateur Ondéa · Nuits de Lumbé', skin=SKINS[6], hair='locks', hc='#21162D', beard='full', acc=('ring',), outfit=dict(top='#8B5CF6', pants='#14102B', shoe='#F8F7FF', accent='#FFC83D', kind='blazer', logo=False)),
 'yele': dict(name='Yélé Dossou', role='Curatrice Ondéa · Afro-soul Sélène', skin=SKINS[2], hair='knots', hc='#3A1B52', beard='none', acc=('fem', 'ring'), outfit=dict(top='#3DDC97', pants='#14102B', shoe='#FFC83D', accent='#FFC83D', kind='tee', logo=False)),
 'tidjane': dict(name='Tidjane Bah', role='Curateur Ondéa · Nouveaux talents', skin=SKINS[3], hair='fade', hc='#14102B', beard='goatee', acc=('glasses', 'cap'), outfit=dict(top='#3CD6F2', pants='#2B2459', shoe='#F8F7FF', accent='#14102B', kind='hoodie', logo=False)),
}

def _arm(x1, y1, x2, y2, top, skin, w=22):
    return ('<path d="M%s %s L%s %s" stroke="%s" stroke-width="%s" stroke-linecap="round"/><circle cx="%s" cy="%s" r="%s" fill="%s" stroke="#000" stroke-opacity=".2" stroke-width="1.4"/>'
            % (x1, y1, x2, y2, top, w, x2, y2, w * .55, skin))

def gesture(g, top, skin):
    if g == 'open':   # négociation : mains ouvertes
        return _arm(70, 300, 36, 238, top, skin) + _arm(230, 300, 264, 238, top, skin)
    if g == 'fist':   # colère
        return _arm(230, 300, 244, 214, top, skin, 24) + '<rect x="233" y="196" width="22" height="20" rx="7" fill="%s" stroke="#000" stroke-opacity=".2"/>' % skin
    if g == 'cross':  # bras croisés, défi
        return ('<path d="M66 296 L234 262" stroke="%s" stroke-width="26" stroke-linecap="round"/><path d="M234 300 L66 264" stroke="%s" stroke-width="26" stroke-linecap="round"/>' % (darken(top, .1), top)
                + '<circle cx="62" cy="298" r="13" fill="%s"/><circle cx="238" cy="298" r="13" fill="%s"/>' % (skin, skin))
    if g == 'contract':
        return (_arm(228, 306, 214, 250, top, skin) + '<g transform="rotate(-8 190 236)"><rect x="168" y="196" width="62" height="78" rx="5" fill="#F8F7FF" stroke="#14102B" stroke-opacity=".5"/>'
                '<path d="M178 212 H220 M178 224 H220 M178 236 H212 M178 248 H206" stroke="#14102B" stroke-opacity=".45" stroke-width="3"/><path d="M180 262 q8 -10 16 0 t16 0" stroke="#F43F9D" stroke-width="3" fill="none"/></g>'
                '<circle cx="224" cy="252" r="11" fill="%s"/>' % skin)
    if g == 'phone':
        return _arm(232, 300, 236, 196, top, skin) + '<rect x="224" y="150" width="30" height="52" rx="7" fill="#14102B" stroke="#3A3270" stroke-width="2"/><rect x="228" y="156" width="22" height="38" rx="3" fill="#3CD6F2" fill-opacity=".8"/><circle cx="236" cy="200" r="11" fill="%s"/>' % skin
    if g == 'mic':
        return _arm(218, 306, 204, 224, top, skin) + '<rect x="196" y="150" width="14" height="76" rx="7" fill="#2B2459" stroke="#000" stroke-opacity=".3"/><circle cx="203" cy="142" r="15" fill="#B6B0DD" stroke="#000" stroke-opacity=".3"/><circle cx="204" cy="226" r="11" fill="%s"/>' % skin
    if g == 'micup':  # concert : micro tenu près de la bouche, autre bras levé
        return (_arm(66, 292, 30, 104, top, skin) + _arm(236, 312, 208, 216, top, skin)
                + '<path d="M208 216 L191 152" stroke="#2B2459" stroke-width="13" stroke-linecap="round"/><path d="M208 216 L191 152" stroke="#B6B0DD" stroke-width="3" stroke-linecap="round" stroke-opacity=".6"/>'
                + '<circle cx="187" cy="141" r="15" fill="#B6B0DD" stroke="#14102B" stroke-width="2.5"/><path d="M175 136 H199 M176 144 H198" stroke="#14102B" stroke-opacity=".35" stroke-width="2"/>'
                + '<circle cx="208" cy="216" r="12" fill="%s" stroke="#000" stroke-opacity=".2"/>' % skin)
    if g == 'fistup':  # tension : poing serré levé à hauteur d'épaule
        return _arm(70, 300, 64, 226, top, skin, 24) + '<rect x="52" y="204" width="24" height="24" rx="8" fill="%s" stroke="#14102B" stroke-opacity=".5" stroke-width="2"/><path d="M58 214 H70 M58 220 H70" stroke="#14102B" stroke-opacity=".4" stroke-width="2"/>' % skin
    if g == 'deal':   # négociation : contrat tenu d'un côté, paume ouverte offerte de l'autre
        return ('<g transform="rotate(-6 80 250)"><rect x="46" y="206" width="58" height="74" rx="5" fill="#F8F7FF" stroke="#14102B" stroke-opacity=".5"/><path d="M55 222 H96 M55 234 H96 M55 246 H88" stroke="#14102B" stroke-opacity=".45" stroke-width="3"/><path d="M58 266 q8 -9 16 0 t14 0" stroke="#3CD6F2" stroke-width="3" fill="none"/></g>'
                + _arm(72, 306, 76, 262, top, skin) + '<circle cx="80" cy="262" r="11" fill="%s" stroke="#000" stroke-opacity=".2"/>' % skin
                + _arm(232, 306, 262, 252, top, skin) + '<g transform="rotate(-24 270 240)"><rect x="256" y="226" width="28" height="16" rx="8" fill="%s" stroke="#000" stroke-opacity=".2"/><path d="M262 226 v-8 M270 225 v-10 M278 226 v-8" stroke="%s" stroke-width="5" stroke-linecap="round"/></g>' % (skin, skin))
    if g == 'fistsky':  # concert : bras levé droit, poing vers le ciel
        return _arm(236, 300, 262, 92, top, skin, 24) + '<rect x="250" y="66" width="26" height="28" rx="9" fill="%s" stroke="#14102B" stroke-opacity=".5" stroke-width="2"/>' % skin + _arm(66, 306, 52, 262, top, skin)
    if g == 'point':
        return _arm(230, 304, 252, 230, top, skin) + '<path d="M252 226 L280 212" stroke="%s" stroke-width="9" stroke-linecap="round"/>' % skin
    if g == 'up':     # célébration
        return _arm(66, 292, 36, 150, top, skin) + _arm(234, 292, 264, 150, top, skin)
    if g == 'shrug':
        return _arm(74, 300, 52, 262, top, skin) + _arm(226, 300, 248, 262, top, skin)
    return ''

DEFAULT_STYLE = '3d'
def P(who, mood='neutral', g='', style=None, crop='torso', view='front', **kw):
    c = CAST[who]
    style = style or DEFAULT_STYLE
    return figure(style, view, skin=c['skin'], hair=c['hair'], hc=c['hc'], beard=c['beard'], mood=mood, outfit=c['outfit'],
                  acc=c['acc'], crop=crop, extra=gesture(g, c['outfit']['top'], c['skin']), **kw)
