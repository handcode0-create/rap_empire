// RAP EMPIRE v21 : scènes de dialogue (section 16 et 19) et offres des dix labels (18.1).
// Port de DLG, DLG_ORDER, CASTN, LBL, PERK et lblDlg de docs/design-ref/v21/sources/engine21.js.
// Données seulement : les effets sont appliqués par engine21.dart (applyEff21). Valeurs PROVISOIRES.
import 'reg21.dart';

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;
List _l(dynamic x) => x as List;
String _fmt(num n) {
  final r = (n + 0.5).floor();
  final t = r.abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  return r < 0 ? '−$t' : t;
}

/// Un choix de dialogue. `k` = étiquette de certitude : k Certain · e Estimé · i Incertain · r Risque.
/// `go` = nœud suivant ; `end` = intitulé de fin ; `e` = conséquences (voir applyEff21).
class DlgChoice {
  final String id, n, c, k;
  final String? go, end;
  final J? e;
  const DlgChoice(this.id, this.n, this.c, {this.k = 'k', this.go, this.end, this.e});
}

class DlgNode {
  final String mood, q;
  final List<DlgChoice> ch;
  const DlgNode(this.mood, this.q, this.ch);
}

class Dlg {
  final String t, ref, place, who, role, cl;
  final String? lbl;
  final bool Function(J s) cond;
  final Map<String, DlgNode> nodes;
  const Dlg({required this.t, required this.ref, required this.place, required this.who, required this.role,
      required this.cond, required this.cl, required this.nodes, this.lbl});
}

/// Avantage de chaque label, affiché à la signature.
const perk21 = <String, String>{
  'radio': 'promo radio offerte à chaque sortie',
  'export': 'Port-Ambre et Sélène +3 à chaque sortie',
  'scene': '+20 % de billets en concert',
  'dev': 'Flow et Voix +1 à chaque sortie',
  'ecr': 'Écriture +2 à chaque sortie',
  'prod': 'production Kôrô +12 sur 3 nouveaux titres',
  'street': '+50 fans par battle gagnée',
  'indie': 'part la plus basse du marché',
  'none': 'aucun soutien garanti',
};

/// Un label : directeur, conditions, contre-offre et avantage.
class Lbl {
  final String n, who, dn, role, place, dur, perk, cl, q1, q2;
  final int adv;
  final double cut;
  final bool risk;
  final bool Function(J s) cond;
  final ({String n, int adv, double cut, int rel, String? perk}) alt;
  const Lbl({required this.n, required this.who, required this.dn, required this.role, required this.place,
      required this.adv, required this.cut, required this.dur, required this.perk, required this.cond,
      required this.cl, required this.q1, required this.q2, required this.alt, this.risk = false});
}

/// Les offres de label n'arrivent qu'une fois l'intérêt des labels suffisant (D-08).
bool labelReady21(J s) => _n(s['lbz']) >= Reg21.lbzGate;

bool _seen(J s, String k) => _m(s['dseen'])[k] != null && _m(s['dseen'])[k] != 0;
int _disco(J s) => _l(s['disco']).length;

final Map<String, Lbl> lbl21 = {
  'AUB': Lbl(
      n: 'Aube Nouvelle', who: 'awa', dn: 'Awa Liméa', role: 'Découvreuse · Aube Nouvelle (Mabaya)', place: 'office',
      adv: 30000, cut: 0.20, dur: '12 mois', perk: 'dev',
      cond: (s) => _n(s['rep']) >= 12 && _disco(s) >= 1, cl: 'Réputation 12 · 1 single sorti',
      q1: "« On signe ceux que les autres n'ont pas encore vus. 30 000 d'avance, 20 %, et un coach vocal à chaque projet. »",
      q2: "« L'avance, je ne peux pas la bouger. Mais je baisse à 15 % si tu restes 18 mois. »",
      alt: (n: '15 % sur 18 mois', adv: 30000, cut: 0.15, rel: 6, perk: null)),
  'NUG': Lbl(
      n: 'Ndolo Underground', who: 'bakary', dn: 'Bakary Fé', role: 'Fondateur · Ndolo Underground', place: 'street',
      adv: 15000, cut: 0.15, dur: '3 mois', perk: 'street',
      cond: (s) => _n(s['shows']) >= 1 && _n(_m(s['geo'])['bakoma']) >= 8, cl: '1 date sur scène · notoriété 8 à Bakoma',
      q1: '« Ici, pas de costard. 15 000, 15 %, trois mois. Tu gardes ta voix, on te met dans toutes les battles du quartier. »',
      q2: "« T'es dur en affaires, petit. 20 000, mais six mois. »",
      alt: (n: '20 000 sur 6 mois', adv: 20000, cut: 0.15, rel: 4, perk: null)),
  'SIC': Lbl(
      n: 'Sélène Indie Collective', who: 'liv', dn: 'Liv Sélou', role: 'Porte-parole · Sélène Indie Collective', place: 'backstage',
      adv: 25000, cut: 0.10, dur: '6 mois', perk: 'indie',
      cond: (s) => _n(_m(s['geo'])['selene']) >= 5, cl: 'Notoriété 5 à Sélène',
      q1: '« Le collectif ne prend que 10 %. Tout le monde vote, tout le monde partage. 25 000 pour démarrer. »',
      q2: '« On peut ajouter une date à Sélène chaque mois, mais la part monte à 12 %. »',
      alt: (n: '12 % et dates à Sélène', adv: 25000, cut: 0.12, rel: 4, perk: 'export')),
  'VAG': Lbl(
      n: 'Vague Argentée', who: 'marius', dn: 'Marius Argent', role: 'Directeur · Vague Argentée (en difficulté)', place: 'office',
      adv: 60000, cut: 0.30, dur: '12 mois', perk: 'none', risk: true,
      cond: (s) => _n(s['rep']) >= 18, cl: 'Réputation 18',
      q1: "« Vague Argentée a fait les plus grands de Port-Ambre. 60 000 tout de suite, 30 %. On a juste besoin d'un nouveau nom. »",
      q2: "« D'accord, d'accord… 75 000. Mais la part passe à 35 %. »",
      alt: (n: '75 000 et 35 %', adv: 75000, cut: 0.35, rel: 2, perk: null)),
  'BLG': Lbl(
      n: 'Black Lagune', who: 'kre', dn: 'Jonas Kré', role: 'Directeur artistique · Black Lagune (Kôtoro)', place: 'stage',
      adv: 80000, cut: 0.40, dur: '9 mois', perk: 'scene',
      cond: (s) => (_m(s['p'])['main'] == 'drill' || _m(s['p'])['main'] == 'trap') && _n(s['rep']) >= 20,
      cl: 'Style drill ou trap · réputation 20',
      q1: '« La drill, c\'est Kôtoro. 80 000, 40 %, et je remplis tes salles : les gens suivent notre logo. »',
      q2: '« 40 %, c\'est le prix des salles pleines. Je descends à 35 %, mais l\'avance tombe à 60 000. »',
      alt: (n: '60 000 et 35 %', adv: 60000, cut: 0.35, rel: 5, perk: null)),
  'LYR': Lbl(
      n: 'Lyrik Atelier', who: 'maze', dn: 'Prof Mazé', role: 'Fondateur · Lyrik Atelier (Mabaya)', place: 'studio',
      adv: 50000, cut: 0.25, dur: '12 mois', perk: 'ecr',
      cond: (s) => _n(_m(s['sk'])['ecr']) >= 22, cl: 'Écriture 22',
      q1: '« Tes rimes tiennent debout. Chez nous, on travaille le texte avant tout. 50 000, 25 %, un atelier par titre. »',
      q2: '« Un vrai auteur négocie, c\'est bien. 55 000, et on garde 25 %. »',
      alt: (n: '55 000 et 25 %', adv: 55000, cut: 0.25, rel: 6, perk: null)),
  'SKP': Lbl(
      n: 'Studio Kôrô Productions', who: 'kore', dn: 'DJ Kôrô', role: 'Patron · Studio Kôrô Productions', place: 'studio',
      adv: 20000, cut: 0.35, dur: 'par projet', perk: 'prod',
      cond: (s) => _n(_m(s['rel'])['kore']) >= 8 && _disco(s) >= 2, cl: 'Relation Kôrô 8 · 2 singles sortis',
      q1: "« On a fait deux titres ensemble. Je monte mon label : 20 000, 35 % sur la production, et je produis tout ce que tu sors. »",
      q2: '« Pour toi, 30 %. Mais tu enregistres uniquement chez moi. »',
      alt: (n: '30 %, exclusivité studio', adv: 20000, cut: 0.30, rel: 8, perk: null)),
  'AMG': Lbl(
      n: 'Ambre Music Group', who: 'benedicte', dn: 'Bénédicte Kassi', role: 'Présidente · Ambre Music Group (Port-Ambre)', place: 'office',
      adv: 90000, cut: 0.30, dur: '12 mois', perk: 'radio',
      cond: (s) => _n(s['pop']) >= 25 && _n(_m(s['geo'])['portambre']) >= 6, cl: 'Popularité 25 · notoriété 6 à Port-Ambre',
      q1: "« Le grand public t'attend à Port-Ambre. 90 000, 30 %, et nos radios jouent chacun de tes singles. »",
      q2: '« Je peux aller à 110 000 si tu acceptes 18 mois au lieu de 12. »',
      alt: (n: '110 000 sur 18 mois', adv: 110000, cut: 0.30, rel: 4, perk: null)),
  'RCD': Lbl(
      n: 'Rythme Cardinal', who: 'kofi', dn: 'Kofi Ndayé', role: 'Directeur export · Rythme Cardinal (Lumbé)', place: 'call',
      adv: 120000, cut: 0.30, dur: '18 mois', perk: 'export',
      cond: (s) => _n(s['rep']) >= 35 && (_m(s['p'])['main'] == 'coupe' || _seen(s, 'collab')), cl: 'Réputation 35 · coupé-décalé ou un duo',
      q1: "« Ton son voyage. Rythme Cardinal t'ouvre Port-Ambre, Sélène, puis l'étranger : 120 000, 30 %, 18 mois. »",
      q2: "« 18 mois, c'est le temps qu'il faut pour exporter. Je monte à 140 000, la part reste à 30 %. »",
      alt: (n: '140 000 et 30 %', adv: 140000, cut: 0.30, rel: 5, perk: null)),
};

/// Ordre de déclenchement des scènes (le premier déclenchable passe en tête).
const dlgOrder21 = [
  'kore', 'mgr', 'lb_AUB', 'lb_NUG', 'lb_SIC', 'lb_VAG', 'lb_BLG', 'lb_LYR', 'lb_SKP', 'lb_AMG', 'label', 'lb_RCD',
  'rival', 'collab', 'bad', 'success', 'festival', 'crisis', 'kore2'
];

/// Noms affichés des personnages de dialogue (complété par les directeurs de labels).
final Map<String, String> castn21 = {
  'kore': 'DJ Kôrô', 'nadia': 'Maya Tessé', 'orage': 'Madame Orage', 'zaki': 'Zaki Mbela',
  'ayana': 'Ayana Dembé', 'zamba': 'Kouassi Zamba', 'rosine': 'Rosine Adjoua',
  for (final l in lbl21.values) l.who: l.dn,
};

J _lblSet(String code, Lbl L, int adv, double cut, String? perk, String relKey, int rel) => {
      'cash': adv,
      'set': {'signed': 1, 'label': code, 'lcut': cut, 'lperk': perk ?? L.perk},
      'rel': {relKey: rel},
    };

Dlg _lblDlg(String code, Lbl L) {
  String p(double c) => '${(c * 100).round()} %';
  final a = L.alt;
  final e1 = _lblSet(code, L, L.adv, L.cut, null, L.who, 8);
  final e2 = _lblSet(code, L, a.adv, a.cut, a.perk, L.who, a.rel);
  final rk = L.risk ? 'r' : 'k';
  final rt = L.risk ? ' · Risque : label en difficulté, soutien incertain' : '';
  return Dlg(
      t: 'Offre · ${L.n}', ref: '18-1 · $code', place: L.place, who: L.who, role: L.role,
      cond: (s) => !_t(s['signed']) && labelReady21(s) && L.cond(s), cl: '${L.cl} · intérêt des labels ${Reg21.lbzGate}', lbl: code,
      nodes: {
        'n1': DlgNode('poised', L.q1, [
          DlgChoice('a', 'Signer', '+${_fmt(L.adv)} cauris · ${p(L.cut)} des écoutes · ${L.dur} · ${perk21[L.perk]}$rt',
              k: rk, e: e1, end: 'Signé chez ${L.n} (${p(L.cut)})'),
          const DlgChoice('b', 'Négocier', 'réponse incertaine', k: 'i', go: 'n2'),
          DlgChoice('c', 'Décliner', 'tu restes libre · les autres labels peuvent encore appeler',
              e: {'rel': {L.who: -3}}, end: 'Offre déclinée'),
        ]),
        'n2': DlgNode('neutral', L.q2, [
          DlgChoice('a', a.n, '+${_fmt(a.adv)} cauris · ${p(a.cut)} des écoutes · ${perk21[a.perk ?? L.perk]}$rt',
              k: rk, e: e2, end: 'Signé chez ${L.n} (${p(a.cut)})'),
          DlgChoice('b', "Revenir à l'offre de départ", '+${_fmt(L.adv)} cauris · ${p(L.cut)}',
              k: rk, e: e1, end: 'Signé chez ${L.n} (${p(L.cut)})'),
          DlgChoice('c', 'Décliner', 'relation −5', k: 'r', e: {'rel': {L.who: -5}}, end: 'Offre déclinée'),
        ]),
      });
}

bool _t(dynamic x) => x != null && x != 0 && x != false && x != '';

/// Les 19 scènes : 9 scènes narratives, les offres des dix labels (dont Bakoma Sound Records, `label`) et leurs rappels.
final Map<String, Dlg> dlg21 = {
  'kore': Dlg(
    t: 'Premier producteur', ref: '16-A', place: 'studio', who: 'kore', role: 'Producteur · Studio Kôrô',
    cond: (s) => _disco(s) > 0 || (s['cur'] != null && _m(s['cur'])['st'] == 'enregistre'),
    cl: 'Après ton premier enregistrement',
    nodes: {
      'n1': const DlgNode('neutral', '« Pas mal, la prod est brute. Rejoue-moi le refrain, que je sente le grain de ta voix. »', [
        DlgChoice('a', 'Rejouer le refrain', "L'échange continue", go: 'n2'),
      ]),
      'n2': const DlgNode('poised', '« Je te propose un deal simple : je prends 40 % sur tes trois prochains titres, je produis et je mixe. »', [
        DlgChoice('a', 'Accepter à 40 %', '−8 000 cauris · production +12 sur 3 titres · relation +15',
            e: {'cash': -8000, 'kc': {'st': 'Accord à 40 %', 'bonus': 12, 'left': 3}, 'rel': {'kore': 15}}, end: 'Accord à 40 %'),
        DlgChoice('b', 'Négocier', '−5 énergie · il peut se vexer', k: 'i', e: {'en': 5}, go: 'n3'),
        DlgChoice('c', 'Refuser', 'relation −10 · il reviendra dans 3 semaines, plus cher', k: 'r',
            e: {'rel': {'kore': -10}, 'q': ['kore2', 21]}, end: 'Refus'),
      ]),
      'n3': const DlgNode('poised', '« 40 %, c\'est déjà un prix d\'ami. Je descends à 35 % si tu me laisses signer le mix. »', [
        DlgChoice('a', '35 %, mix signé', '−7 000 cauris · production +12 sur 3 titres · relation +8',
            e: {'cash': -7000, 'kc': {'st': 'Accord à 35 %, mix signé', 'bonus': 12, 'left': 3}, 'rel': {'kore': 8}}, end: 'Accord à 35 %'),
        DlgChoice('b', 'Tenter 30 %', 'relation −5 · réponse incertaine', k: 'i', e: {'rel': {'kore': -5}}, go: 'n4'),
        DlgChoice('c', 'Revenir à 40 %', '−8 000 cauris · relation +10',
            e: {'cash': -8000, 'kc': {'st': 'Accord à 40 %', 'bonus': 12, 'left': 3}, 'rel': {'kore': 10}}, end: 'Accord à 40 %'),
      ]),
      'n4': const DlgNode('angry', '« 30 % ? Là tu me vexes. C\'est 35 % ou rien. »', [
        DlgChoice('a', "D'accord pour 35 %", '−7 000 cauris · production +12 sur 3 titres · relation +3',
            e: {'cash': -7000, 'kc': {'st': 'Accord à 35 % (tendu)', 'bonus': 12, 'left': 3}, 'rel': {'kore': 3}}, end: 'Accord à 35 %'),
        DlgChoice('b', 'Refuser', 'relation −10 · il reviendra dans 3 semaines, plus cher', k: 'r',
            e: {'rel': {'kore': -10}, 'q': ['kore2', 21]}, end: 'Refus'),
      ]),
    },
  ),
  'kore2': Dlg(
    t: 'Kôrô revient', ref: '16-A6', place: 'studio', who: 'kore', role: 'Producteur · Studio Kôrô',
    cond: (_) => false, cl: '3 semaines après un refus',
    nodes: {
      'n1': const DlgNode('smirk', '« Tu as refusé la dernière fois. J\'ai gardé un créneau, mais cette fois c\'est 45 %, à prendre ou à laisser. »', [
        DlgChoice('a', 'Accepter à 45 %', '−9 000 cauris · production +12 sur 3 titres · relation +5',
            e: {'cash': -9000, 'kc': {'st': 'Accord à 45 %', 'bonus': 12, 'left': 3}, 'rel': {'kore': 5}}, end: 'Accord à 45 %'),
        DlgChoice('b', 'Refuser pour de bon', "relation −5 · plus d'offre de Kôrô", k: 'r',
            e: {'rel': {'kore': -5}}, end: 'Refus définitif'),
      ]),
    },
  ),
  'mgr': Dlg(
    t: 'Premier rendez-vous avec une manager', ref: '19-6', place: 'call', who: 'nadia', role: 'Manager · M1, débutante',
    cond: (s) => _n(s['day']) >= 3 && !_t(s['mgr']), cl: 'À partir du jour 3',
    nodes: {
      'n1': const DlgNode('smile', "« Je n'ai géré que deux groupes de Ndolo. Mais personne ne travaillera plus dur que moi pour toi. »", [
        DlgChoice('a', "Écouter son offre", "L'échange continue", go: 'n2'),
        DlgChoice('b', 'Pas maintenant', "aucun manager · elle te laisse son numéro", k: 'i',
            e: {'rel': {'nadia': -2}}, end: 'Rendez-vous écourté'),
      ]),
      'n2': const DlgNode('poised', "« 8 % sur tes cachets, pas de fixe tant que tu débutes. Je t'ouvre mes contacts : promoteurs, petites salles, festivals. »", [
        DlgChoice('a', 'Engager Maya', "8 % de chaque cachet · ouvre les invitations et ses conseils",
            e: {'set': {'mgr': 'maya'}, 'rel': {'nadia': 10}}, end: 'Maya Tessé engagée (M1)'),
        DlgChoice('b', 'Demander 6 %', 'réponse incertaine', k: 'i', go: 'n3'),
        DlgChoice('c', 'Refuser', "aucun manager pour l'instant", k: 'r', e: {'rel': {'nadia': -5}}, end: 'Refus'),
      ]),
      'n3': const DlgNode('neutral', "« 6 %, je ne m'en sors pas. 8 %, et je te trouve une date avant la fin du mois. »", [
        DlgChoice('a', 'Va pour 8 %', '8 % de chaque cachet · relation +5',
            e: {'set': {'mgr': 'maya'}, 'rel': {'nadia': 5}}, end: 'Maya Tessé engagée (M1)'),
        DlgChoice('b', 'Refuser', "aucun manager pour l'instant", k: 'r', e: {'rel': {'nadia': -5}}, end: 'Refus'),
      ]),
    },
  ),
  'label': Dlg(
    t: 'Contrat de label', ref: '16-B · 08-2', place: 'office', who: 'orage', role: 'Directrice artistique · Bakoma Sound Records',
    cond: (s) => _n(s['rep']) >= Reg21.labelRep && !_t(s['signed']) && labelReady21(s), cl: 'Réputation 30 · intérêt des labels ${Reg21.lbzGate}',
    nodes: {
      'n1': const DlgNode('poised', '« Bakoma Sound Records te propose six mois, 150 000 d\'avance, 35 % sur tes écoutes et deux sons par trimestre. On signe ? »', [
        DlgChoice('a', 'Signer', '+150 000 cauris · 35 % des écoutes au label · 6 mois',
            e: {'cash': 150000, 'set': {'signed': 1, 'label': 'BSR', 'lcut': 0.35, 'lperk': 'radio'}}, end: 'Contrat signé (35 %)'),
        DlgChoice('b', 'Contre-proposer', 'réponse incertaine', k: 'i', go: 'n2'),
        DlgChoice('c', 'Réfléchir 7 jours', "l'offre revient dans 7 jours", k: 'i', e: {'q': ['label', 7]}, end: 'Réflexion'),
      ]),
      'n2': const DlgNode('neutral', "« Je peux monter l'avance à 180 000, mais la part passe à 40 %. Ou on garde l'offre de départ. »", [
        DlgChoice('a', '180 000 et 40 %', '+180 000 cauris · 40 % des écoutes au label',
            e: {'cash': 180000, 'set': {'signed': 1, 'label': 'BSR', 'lcut': 0.40, 'lperk': 'radio'}}, end: 'Contrat signé (40 %)'),
        DlgChoice('b', '150 000 et 35 %', '+150 000 cauris · 35 % des écoutes au label',
            e: {'cash': 150000, 'set': {'signed': 1, 'label': 'BSR', 'lcut': 0.35, 'lperk': 'radio'}}, end: 'Contrat signé (35 %)'),
        DlgChoice('c', 'Rester indépendant', 'relation −5 · Bakoma Sound Records ne revient pas', k: 'r',
            e: {'rel': {'orage': -5}}, end: 'Indépendant'),
      ]),
    },
  ),
  'rival': Dlg(
    t: 'Rivalité publique', ref: '16-C', place: 'street', who: 'zaki', role: 'Rappeur · rival de Ndolo',
    cond: (s) => _disco(s) >= 2, cl: 'Après ton deuxième single',
    nodes: {
      'n1': const DlgNode('smirk', '« Ton single ? Pas mal pour une pause. Ndolo attend un vrai son, pas une démo. »', [
        DlgChoice('a', 'Ignorer', "aucun effet · la rivalité s'éteint", end: 'Ignoré'),
        DlgChoice('b', 'Répondre avec humour', '+2 popularité · relation Zaki +5', e: {'pop': 2, 'rel': {'zaki': 5}}, end: 'Réponse drôle'),
        DlgChoice('c', 'Préparer un morceau de réponse', 'ton prochain single : +10 % d\'écoutes · relation Zaki −10', k: 'e',
            e: {'set': {'diss': 1}, 'rel': {'zaki': -10}}, end: 'Morceau de réponse annoncé'),
      ]),
    },
  ),
  'collab': Dlg(
    t: 'Proposition de duo', ref: '16-G', place: 'backstage', who: 'ayana', role: 'Chanteuse afro-soul',
    cond: (s) => _n(s['pop']) >= 15, cl: 'Popularité 15',
    nodes: {
      'n1': const DlgNode('smile', "« J'aime ton énergie. Un duo ? Je veux 50 % des revenus et mon style afro-soul sur le refrain. »", [
        DlgChoice('a', 'Accepter à 50 %', 'prochain titre en duo · 50 % de ses revenus d\'écoutes pour elle',
            e: {'set': {'duo': {'share': 50}}, 'rel': {'ayana': 10}}, end: 'Duo à 50 %'),
        DlgChoice('b', 'Proposer 60-40', 'réponse incertaine', k: 'i', go: 'n2'),
        DlgChoice('c', 'Décliner', 'relation −3', k: 'r', e: {'rel': {'ayana': -3}}, end: 'Décliné'),
      ]),
      'n2': const DlgNode('poised', '« Va pour 60-40. Mais le refrain, c\'est moi qui l\'écris. »', [
        DlgChoice('a', 'Marché conclu', 'prochain titre en duo · 40 % de ses revenus d\'écoutes pour elle',
            e: {'set': {'duo': {'share': 40}}, 'rel': {'ayana': 5}}, end: 'Duo à 40 %'),
        DlgChoice('b', 'Finalement, non', 'relation −5', k: 'r', e: {'rel': {'ayana': -5}}, end: 'Décliné'),
      ]),
    },
  ),
  'bad': Dlg(
    t: 'Mauvais résultat', ref: '16-D', place: 'call', who: 'nadia', role: 'Ta manager · M1',
    cond: (s) {
      final d = _l(s['disco']);
      return _t(s['mgr']) && d.isNotEmpty && _m(d.first)['tier'] == 'Discret' && _m(d.first)['day'] == s['day'];
    },
    cl: 'Manager engagé · un single « Discret »',
    nodes: {
      'n1': const DlgNode('worried', '« Les gens ont écouté, mais peu sont restés. Pas de promo, une qualité moyenne : on peut faire mieux. »', [
        DlgChoice('a', 'Revoir la stratégie', '+2 Écriture · conseil de Maya', e: {'set': {'sk.ecr': 2}}, end: 'Stratégie revue'),
        DlgChoice('b', 'Payer une promo de rattrapage', '−3 000 cauris · +300 fans', e: {'cash': -3000, 'fans': 300}, end: 'Promo de rattrapage'),
        DlgChoice('c', 'Préparer vite un autre titre', 'ton prochain single sorti sous 7 jours : +20 % d\'écoutes', k: 'e',
            e: {'hype': 7}, end: 'Nouveau titre en préparation'),
      ]),
    },
  ),
  'success': Dlg(
    t: 'Succès au classement', ref: '16-F', place: 'call', who: 'nadia', role: 'Ta manager · M1',
    cond: (s) => _t(s['mgr']) && _l(s['disco']).any((x) => _n(_m(x)['L']) >= Reg21.entry),
    cl: 'Manager engagé · un titre au Top 100',
    nodes: {
      'n1': const DlgNode('smile', '« Tu as vu ? Ton single entre au Top 100 ! Il faut battre le fer tant qu\'il est chaud. »', [
        DlgChoice('a', 'Sortir un titre sous 7 jours', "+20 % d'écoutes sur ce titre", k: 'e', e: {'hype': 7}, end: 'Titre express'),
        DlgChoice('b', 'Fêter ça au quartier', '+4 réputation · −10 énergie', e: {'rep': 4, 'en': 10}, end: 'Fête à Ndolo'),
      ]),
    },
  ),
  'festival': Dlg(
    t: 'Invitation au festival', ref: '16-E · 18-11', place: 'backstage', who: 'zamba', role: "Promoteur · Festival Lagune d'Ambre",
    cond: (s) => _t(s['mgr']) && _n(s['rank']) >= 3 && _n(s['shows']) >= 2, cl: 'Manager engagé · rang N3 · 2 dates',
    nodes: {
      'n1': const DlgNode('poised', "« Samedi, Festival Lagune d'Ambre. Huit mille personnes, scène Découverte. 12 000 cauris. Tu es partant ? »", [
        DlgChoice('a', 'Accepter', '6 h · −40 énergie · cachet 12 000 · +600 fans · Port-Ambre +6',
            e: {'h': 6, 'en': 40, 'cachet': 12000, 'fans': 600, 'geo': {'portambre': 6}, 'shows': 1, 'xp': 120, 'rel': {'zamba': 8}},
            end: 'Festival joué'),
        DlgChoice('b', 'Proposer dimanche', 'réponse incertaine', k: 'i', go: 'n2'),
        DlgChoice('c', 'Refuser', 'relation Zamba −6', k: 'r', e: {'rel': {'zamba': -6}}, end: 'Refus'),
      ]),
      'n2': const DlgNode('neutral', '« Dimanche, la scène est plus petite. 9 000 cauris, et tu ouvres à 16 h. »', [
        DlgChoice('a', "D'accord", '5 h · −35 énergie · cachet 9 000 · +400 fans · Port-Ambre +4',
            e: {'h': 5, 'en': 35, 'cachet': 9000, 'fans': 400, 'geo': {'portambre': 4}, 'shows': 1, 'xp': 90, 'rel': {'zamba': 4}},
            end: 'Festival joué (dimanche)'),
        DlgChoice('b', 'Laisser tomber', 'relation Zamba −4', k: 'r', e: {'rel': {'zamba': -4}}, end: 'Refus'),
      ]),
    },
  ),
  'crisis': Dlg(
    t: 'Polémique après la battle', ref: '19-8', place: 'call', who: 'rosine', role: 'Manager presse et crise · M3',
    cond: (s) => s['bt'] != null && _t(_m(s['bt'])['win']) && _n(s['pop']) >= 10, cl: 'Une battle gagnée · popularité 10',
    nodes: {
      'n1': const DlgNode('worried', "« Un extrait de ta battle circule sans contexte. Les gens croient que tu insultes Mabaya. Il faut réagir. »", [
        DlgChoice('a', 'Expliquer le contexte', '+3 popularité · +1 réputation', k: 'e', e: {'pop': 3, 'rep': 1}, end: 'Contexte expliqué'),
        DlgChoice('b', 'Laisser Rosine gérer', '−5 000 cauris · +2 réputation · relation Rosine +10',
            e: {'cash': -5000, 'rep': 2, 'rel': {'rosine': 10}}, end: 'Rosine a géré la crise'),
        DlgChoice('c', 'Ne rien dire', '−3 popularité', k: 'r', e: {'pop': -3}, end: 'Silence'),
      ]),
    },
  ),
  for (final e in lbl21.entries) 'lb_${e.key}': _lblDlg(e.key, e.value),
};
