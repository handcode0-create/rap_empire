// ignore_for_file: avoid_dynamic_calls
part of 'engine21.dart';

// RAP EMPIRE v21 · droits d'auteur des instrumentales (demande de Smith du 04/11/2026).
// Chaque titre porte `cr` : la licence de son instru et son statut. Un litige actif vit dans `crc` (un seul à la fois),
// les litiges clos dans `crHist`, le dernier retrait dans `crOut`. Tout est dans l'état sauvegardé : quitter le jeu ou
// passer une journée ne perd rien. Valeurs provisoires : CrReg21 (reg21.dart). Le hasard vient de la graine et du jour.
//
// Statuts d'un titre (`cr.st`) :
//   libre   instru libre de droits                         sec     droits sécurisés (licence exclusive, producteur du jeu)
//   lic     licence commerciale valide (limitée)           exp     licence expirée (écoutes ou durée dépassées)
//   cond    gratuite pour un usage non commercial          nonaut  mise en ligne sans l'accord de son auteur
//   litige  réclamation en cours                           susp    suspendu des plateformes (intervention officielle)
//   regle   litige réglé (paiement, accord, partage)       rejete  réclamation rejetée après contestation
//   retire  retiré des plateformes pour litige de droits d'auteur

/// Statuts qui peuvent déclencher une réclamation.
const crRisky21 = {'cond', 'exp', 'nonaut'};

/// Intitulés affichés des statuts.
const crStatusLabel21 = <String, String>{
  'libre': 'Instru libre de droits',
  'sec': 'Droits sécurisés',
  'lic': 'Licence commerciale valide',
  'exp': 'Licence expirée',
  'cond': 'Instru gratuite avec conditions',
  'nonaut': 'Instru non autorisée',
  'litige': 'Litige en cours',
  'susp': 'Suspendu des plateformes',
  'regle': 'Litige réglé',
  'rejete': 'Réclamation rejetée',
  'retire': 'Retiré pour litige de droits d’auteur',
};

/// Droits d'un titre. Les titres d'avant ce système n'ont pas de `cr` : leur instru est réputée licenciée sans limite.
J crOf21(J song) {
  final c = song['cr'];
  if (c is Map) return Map<String, dynamic>.from(c);
  final inst = Reg21.instrus[song['inst']];
  final lic = inst?['lic'] as String?;
  return {'st': lic == 'libre' ? 'libre' : 'sec', 'legacy': 1};
}

String crStatus21(J song) => crOf21(song)['st'] as String;

/// Le titre ne rapporte plus d'écoutes (suspendu ou retiré).
bool crOff21(J song) => const {'susp', 'retire'}.contains(crStatus21(song));

/// Licence choisie au studio, d'après l'instru et l'option (`excl` pour une licence exclusive), au moment de l'enregistrement.
J crForRecord21(J n, String iid, bool kore) {
  final inst = Reg21.instrus[iid]!;
  if (kore) return {'st': 'sec', 'lic': 'prod', 'owner': 'kore'};
  final lic = inst['lic'] as String? ?? 'lic';
  final owner = inst['owner'];
  switch (lic) {
    case 'libre':
      return {'st': 'libre', 'lic': 'libre'};
    case 'cond':
      return {'st': 'cond', 'lic': 'cond', 'owner': owner};
    case 'nonaut':
      return {'st': 'nonaut', 'lic': 'nonaut', 'owner': owner};
  }
  if (_m(n['ui'])['instLic'] == 'excl') return {'st': 'sec', 'lic': 'excl', 'owner': owner};
  return {'st': 'lic', 'lic': 'nonexcl', 'owner': owner, 'cap': CrReg21.licCapL, 'until': _n(n['day']) + CrReg21.licDays};
}

/// Prix d'une instru selon la licence : non exclusive au prix affiché, exclusive × CrReg21.exclMult.
num instruPrice21(String iid, String? lic) {
  final c = _n(Reg21.instrus[iid]?['cost']);
  return lic == 'excl' ? c * CrReg21.exclMult : c;
}

/// Prix d'une licence commerciale pour régulariser un titre (avant toute réclamation), ou plancher d'une réclamation.
num crLicenceFee21(J song) {
  final cr = crOf21(song);
  final kind = cr['st'] == 'litige' || cr['st'] == 'susp' ? cr['was'] : cr['st'];
  if (kind == 'exp') return _n(Reg21.instrus[song['inst']]?['cost']);
  return CrReg21.licFee[kind] ?? 0;
}

/// Régularisation spontanée : licence + part des revenus déjà touchés.
num crRegPrice21(J song) => crLicenceFee21(song) + jsRound(_n(song['rev']) * CrReg21.regPct);

/// Niveau de risque affiché (jamais de pourcentage) : Aucun, Faible, Moyen ou Élevé.
String crRiskLevel21(J n, J song) {
  final st = crStatus21(song);
  if (!crRisky21.contains(st)) return 'Aucun';
  final p = crDailyChance21(n, song);
  if (p <= 0) return st == 'nonaut' ? 'Moyen' : 'Faible';
  if (p < 0.02) return 'Faible';
  if (p < 0.06) return 'Moyen';
  return 'Élevé';
}

/// Probabilité journalière qu'un titre fasse l'objet d'une réclamation (0 pour une instru autorisée ou un titre peu écouté).
double crDailyChance21(J n, J song) {
  final cr = crOf21(song);
  final st = cr['st'] as String;
  if (!crRisky21.contains(st) || _t(cr['claimed'])) return 0;
  final l = _n(song['L']);
  if (l < CrReg21.riskMinL) return 0;
  final age = _n(n['day']) - _n(song['day']);
  if (age > CrReg21.riskDays) return 0;
  final pop = math.min(1, (l - CrReg21.riskMinL) / (CrReg21.riskFullL - CrReg21.riskMinL));
  final ageF = 0.5 + 0.5 * math.min(1, math.max(0, age) / 14);
  final chart = l >= Reg21.entry ? CrReg21.chartBoost : 1.0; // titre entré au Top 100 Singles
  final hist = 1 + CrReg21.histBoost * _l(n['crHist']).length;
  return math.min(CrReg21.pMax, CrReg21.base[st]! * pop * ageF * chart * hist).toDouble();
}

/// Montant réclamé : part des revenus du titre selon le dossier et l'historique, jamais sous le prix de la licence.
({double pct, int amt}) crClaimAmount21(J n, J song, String kind) {
  final pct = math.min(CrReg21.pctMax, CrReg21.pct[kind]! + CrReg21.histPct * _l(n['crHist']).length).toDouble();
  final floor = kind == 'exp' ? _n(Reg21.instrus[song['inst']]?['cost']) : (CrReg21.licFee[kind] ?? 0);
  return (pct: pct, amt: math.max(floor, jsRound(_n(song['rev']) * pct)).toInt());
}

J? _crSong(J n, dynamic id) => _l(n['disco']).map(_m).where((x) => x['id'] == id).firstOrNull;

void _crSet(J song, J cr) => song['cr'] = cr;

/// Litige actif sur ce titre ?
J? crClaim21(J n) => n['crc'] == null ? null : _m(n['crc']);

String crOwnerName21(dynamic who) => castn21[who] ?? (who == 'tamsir' ? 'Tamsir Koffi' : who == 'woro' ? 'Mister Wôrô' : '$who');

/// Score de négociation (0 à 5) : dossier, label, manager, relation avec le titulaire, tension et historique.
int crNegoScore21(J n) {
  final c = crClaim21(n);
  if (c == null) return 0;
  var sc = c['kind'] == 'nonaut' ? 1 : 2;
  if (_t(n['signed'])) sc++;
  if (managerTier21(n) != null) sc++;
  if (_n(_m(n['rel'])[c['owner']]) >= 10) sc++;
  sc -= _n(c['tension']).toInt();
  sc -= _l(n['crHist']).length >= 2 ? 1 : 0;
  return sc.clamp(0, 5);
}

/// Risque affiché d'un refus en négociation pour une proposition (moitié : seuil 3 ; partage : seuil 2).
String crNegoRisk21(J n, String offer) {
  final need = offer == 'half' ? 3 : 2, sc = crNegoScore21(n);
  if (sc >= need + 1) return 'Faible';
  if (sc >= need) return 'Moyen';
  return 'Élevé';
}

/// Chances (sur 100) de gagner une contestation avec cet avocat. Affichées en niveau de risque, jamais en pourcentage.
int crContestChance21(J n, String lawyer) {
  final c = crClaim21(n);
  if (c == null) return 0;
  final lw = Reg21.lawyers[lawyer];
  return clamp21((CrReg21.contestBase[c['kind']] ?? 0) + _n(lw?['skill']) / 2 + (_t(n['signed']) ? CrReg21.labelHelp : 0), 0, 85).toInt();
}

String crContestRisk21(J n, String lawyer) {
  final p = crContestChance21(n, lawyer);
  if (p >= 55) return 'Faible';
  if (p >= 35) return 'Moyen';
  return 'Élevé';
}

/// Coût d'avocat à la charge du joueur (le label en paie une part).
num crLawyerCost21(J n, String lawyer) {
  final c = _n(Reg21.lawyers[lawyer]?['cost']);
  return _t(n['signed']) ? jsRound(c * (1 - CrReg21.labelLegal)) : c;
}

num crNegoFee21(J n) => _t(n['signed']) ? jsRound(CrReg21.negoFee * (1 - CrReg21.labelLegal)) : CrReg21.negoFee;

/// Montant dû aujourd'hui pour régler le litige (majoré après l'intervention officielle).
num crDue21(J n) {
  final c = crClaim21(n);
  if (c == null) return 0;
  return c['st'] == 'intervention' ? jsRound(_n(c['amt']) * (1 + CrReg21.latePct)) : _n(c['amt']);
}

void _crClose(J n, String res, num paid, {String st = 'regle'}) {
  final c = crClaim21(n)!;
  final song = _crSong(n, c['id']);
  if (song != null) {
    final cr = crOf21(song);
    cr['st'] = st;
    cr['res'] = res;
    if (st == 'regle' || st == 'rejete') cr.remove('until');
    _crSet(song, cr);
  }
  // Revenus gelés pendant une contestation : rendus au joueur s'il gagne, versés au titulaire sinon.
  final esc = _n(c['escrow']);
  if (esc > 0 && st == 'rejete') {
    _pay(n, esc);
    if (song != null) song['rev'] = _n(song['rev']) + esc;
  }
  _l(n['crHist']).add({'id': c['id'], 'title': c['title'], 'owner': c['owner'], 'kind': c['kind'], 'res': res, 'paid': paid, 'day': n['day'], 'esc': esc});
  n['crc'] = null;
  n['crAt'] = n['day'];
}

/// Paiement d'un montant lié au litige : impossible sans les cauris (jamais de dette cachée).
String? _crPay(J n, num amt) {
  if (_n(n['cash']) < amt) return 'cash';
  _pay(n, -amt);
  final c = crClaim21(n);
  if (c != null) c['paid'] = _n(c['paid']) + amt;
  return null;
}

/// Une journée de droits d'auteur : expirations, découvertes, avis, échéances, décisions de contestation.
List<String> _crDay(J n) {
  final ev = <String>[];
  final day = _n(n['day']);
  // licences non exclusives : écoutes ou durée dépassées
  for (final song in _l(n['disco']).map(_m)) {
    final cr = crOf21(song);
    if (cr['st'] == 'lic' && (_n(song['L']) > _n(cr['cap']) || day > _n(cr['until']))) {
      cr['st'] = 'exp';
      _crSet(song, cr);
      ev.add('Licence expirée : « ${song['title']} » · renouvelle-la au catalogue');
      _log(n, 'Licence expirée : ${song['title']} (${_n(song['L']) > _n(cr['cap']) ? 'écoutes couvertes dépassées' : 'durée dépassée'})', 'musique');
    }
  }
  final c = crClaim21(n);
  if (c != null) {
    final song = _crSong(n, c['id']);
    if (c['st'] == 'decouvert' && day >= _n(c['at'])) {
      c['st'] = 'avis';
      c['seen'] = 0;
      c['due'] = day + CrReg21.replyDays;
      if (song != null) {
        final cr = crOf21(song)..['st'] = 'litige';
        _crSet(song, cr);
      }
      ev.add('Avis de réclamation : « ${c['title']} » · ${fmt21(_n(c['amt']))} cauris réclamés');
      _log(n, 'Réclamation de droits d’auteur sur ${c['title']} : ${fmt21(_n(c['amt']))} cauris (${crOwnerName21(c['owner'])})', 'justice');
    } else if (c['st'] == 'conteste' && day >= _n(c['trial'])) {
      final win = rng21(n, 401 + _l(n['crHist']).length) * 100 < _n(c['chance']);
      if (win) {
        c['verdict'] = 'gagne';
        n['rep'] = _n(n['rep']) + 1;
        _crClose(n, 'rejete', 0, st: 'rejete');
        n['crOut'] = {'type': 'contest', 'win': 1, 'title': c['title'], 'esc': _n(c['escrow']), 'seen': 0, 'day': day};
        ev.add('Contestation gagnée : la réclamation sur « ${c['title']} » est rejetée');
        _log(n, 'Contestation gagnée : réclamation rejetée (${c['title']})', 'justice');
      } else {
        final owe = jsRound(_n(c['amt']) * (1 + CrReg21.contestLossPct));
        final esc = _n(c['escrow']);
        final left = math.max(0, owe - esc);
        n['rep'] = math.max(0, _n(n['rep']) - 2);
        if (_n(n['cash']) >= left) {
          _pay(n, -left);
          _crClose(n, 'contest_perdu', owe);
          n['crOut'] = {'type': 'contest', 'win': 0, 'title': c['title'], 'owe': owe, 'esc': esc, 'seen': 0, 'day': day};
          ev.add('Contestation perdue : ${fmt21(owe)} cauris versés au titulaire (dont ${fmt21(esc)} gelés)');
          _log(n, 'Contestation perdue : ${fmt21(owe)} cauris pour ${c['title']}', 'justice');
        } else {
          _crRemove(n, ev, 'Contestation perdue sans les cauris pour payer');
        }
      }
    } else if ((c['st'] == 'avis' || c['st'] == 'ignore' || c['st'] == 'nego') && day > _n(c['due'])) {
      // Intervention officielle : le titre est suspendu, ses revenus partent au titulaire jusqu'au règlement.
      c['st'] = 'intervention';
      c['seen'] = 0;
      c['due2'] = day + CrReg21.finalDays;
      if (song != null) {
        final cr = crOf21(song)..['st'] = 'susp';
        _crSet(song, cr);
      }
      n['rep'] = math.max(0, _n(n['rep']) - 1);
      ev.add('Intervention officielle : « ${c['title']} » est suspendu des plateformes');
      _log(n, 'Intervention officielle : ${c['title']} suspendu (délai de ${CrReg21.finalDays} jours)', 'justice');
    } else if (c['st'] == 'intervention' && day > _n(c['due2'])) {
      _crRemove(n, ev, 'Délai final dépassé');
    }
    return ev;
  }
  // Découverte : un seul titre à la fois, au moins CrReg21.gapDays jours après le dernier litige.
  if (n['crAt'] != null && day - _n(n['crAt']) < CrReg21.gapDays) return ev;
  var i = 0;
  for (final song in _l(n['disco']).map(_m)) {
    i++;
    final p = crDailyChance21(n, song);
    if (p <= 0) continue;
    if (rng21(n, 307 + i * 13) >= p) continue;
    final cr = crOf21(song);
    final kind = cr['st'] as String;
    final a = crClaimAmount21(n, song, kind);
    final delay = CrReg21.discoverMin + (rng21(n, 331 + i) * (CrReg21.discoverMax - CrReg21.discoverMin + 1)).floor();
    cr['claimed'] = 1;
    cr['was'] = kind;
    _crSet(song, cr);
    n['crc'] = {
      'id': song['id'], 'title': song['title'], 'owner': cr['owner'] ?? 'woro', 'kind': kind, 'L': _n(song['L']), 'rev': _n(song['rev']),
      'pct': a.pct, 'amt': a.amt, 'found': day, 'at': day + delay, 'st': 'decouvert', 'tension': 0, 'escrow': 0, 'paid': 0, 'seen': 0,
    };
    n['crAt'] = day;
    break;
  }
  return ev;
}

void _crRemove(J n, List<String> ev, String why) {
  final c = crClaim21(n)!;
  final song = _crSong(n, c['id']);
  n['pop'] = clamp21(_n(n['pop']) - CrReg21.popLoss, 0, 100);
  n['rep'] = math.max(0, _n(n['rep']) - CrReg21.repLoss);
  final lost = jsRound(_n(n['fans']) * CrReg21.fansLoss);
  n['fans'] = math.max(0, _n(n['fans']) - lost);
  n['crOut'] = {'type': 'retrait', 'title': c['title'], 'fans': lost, 'pop': CrReg21.popLoss, 'rep': CrReg21.repLoss, 'why': why, 'seen': 0, 'day': n['day']};
  _crClose(n, 'retire', _n(c['paid']), st: 'retire');
  if (song != null) {
    song['lastDayL'] = 0;
    song['lastDayRev'] = 0;
  }
  ev.add('Retrait : « ${c['title']} » n’est plus sur les plateformes ($why)');
  _log(n, 'Retiré des plateformes pour litige de droits d’auteur : ${c['title']}', 'justice');
}

/// Revenus du jour d'un titre en litige : gelés pendant une contestation, versés au titulaire pendant la suspension,
/// partagés après un accord de rétrocession. Renvoie la part retenue (à retirer du revenu du joueur).
num _crHold(J n, J song, num net) {
  final cr = crOf21(song);
  final c = crClaim21(n);
  if (c != null && c['id'] == song['id'] && c['st'] == 'conteste') {
    c['escrow'] = _n(c['escrow']) + net;
    return net;
  }
  final share = _n(cr['share']);
  if (share > 0) {
    final h = jsRound(net * share);
    cr['shared'] = _n(cr['shared']) + h;
    _crSet(song, cr);
    return h;
  }
  return 0;
}

/// Actions du joueur sur les droits d'auteur. Chacune renvoie un code d'erreur explicite quand elle est impossible.
final Map<String, Action> crActions21 = {
  // Licence choisie pour une instru payante avant de la prendre : 'nonexcl' (défaut) ou 'excl'.
  'instLic': (s, lic) {
    if (lic != 'excl' && lic != 'nonexcl') return _no(s, 'inconnu');
    final n = clone21(s);
    _m(n['ui'])['instLic'] = lic;
    return _ok(n);
  },
  // L'animation d'avis (ou d'intervention, de verdict, de retrait) a été vue.
  'crSeen': (s, a) {
    final n = clone21(s);
    if (n['crc'] != null) _m(n['crc'])['seen'] = 1;
    if (n['crOut'] != null && a == 'out') _m(n['crOut'])['seen'] = 1;
    return _ok(n);
  },
  // Régulariser un titre avant toute réclamation : acheter la licence (ou la renouveler).
  'crReg': (s, id) {
    final song = _crSong(s, id);
    if (song == null) return _no(s, 'inconnu');
    final cr = crOf21(song);
    if (!crRisky21.contains(cr['st']) || _t(cr['claimed'])) return _no(s, 'rien');
    final price = crRegPrice21(song);
    if (_n(s['cash']) < price) return _no(s, 'cash');
    final n = clone21(s);
    final x = _crSong(n, id)!;
    _pay(n, -price);
    final c2 = crOf21(x)
      ..['st'] = 'sec'
      ..['res'] = 'licence'
      ..['regPaid'] = price;
    c2.remove('until');
    _crSet(x, c2);
    _log(n, 'Licence achetée pour ${x['title']} : −${fmt21(price)} cauris (${crOwnerName21(c2['owner'])})', 'musique');
    return _ok(n);
  },
  // Payer tout de suite le montant réclamé (majoré après l'intervention) : le titre revient ou reste en ligne.
  'crPay': (s, a) {
    final c = crClaim21(s);
    if (c == null || !const {'avis', 'ignore', 'nego', 'intervention'}.contains(c['st'])) return _no(s, 'rien');
    final n = clone21(s);
    final amt = crDue21(n);
    final e = _crPay(n, amt);
    if (e != null) return _no(s, e);
    final title = c['title'];
    _crClose(n, 'paye', _n(crClaim21(n)!['paid']));
    _log(n, 'Litige réglé : ${fmt21(amt)} cauris versés pour $title', 'justice');
    return _ok(n);
  },
  // Rendez-vous avec le producteur (une seule fois par litige).
  'crNego': (s, a) {
    final c = crClaim21(s);
    if (c == null || !const {'avis', 'ignore'}.contains(c['st'])) return _no(s, 'rien');
    if (_t(c['met'])) return _no(s, 'deja');
    final fee = crNegoFee21(s);
    if (_n(s['cash']) < fee) return _no(s, 'cash');
    final n = clone21(s);
    final e = _spend(n, CrReg21.negoH, CrReg21.negoEn);
    if (e != null) return _no(s, e);
    _pay(n, -fee);
    final cc = _m(n['crc']);
    cc['st'] = 'nego';
    cc['node'] = 'n1';
    cc['met'] = 1;
    _log(n, 'Rendez-vous avec ${crOwnerName21(cc['owner'])} pour ${cc['title']}${fee > 0 ? ' (−${fmt21(fee)} cauris)' : ''}', 'justice');
    return _ok(n);
  },
  // Choix pendant le rendez-vous : 'half' (moitié), 'share' (rétrocession), 'counter' (accepter la contre-offre), 'full', 'leave'.
  'crOffer': (s, o) {
    final c = crClaim21(s);
    if (c == null || c['st'] != 'nego') return _no(s, 'rien');
    final n = clone21(s);
    final cc = _m(n['crc']);
    final amt = _n(cc['amt']);
    switch (o) {
      case 'half':
        if (cc['node'] != 'n1') return _no(s, 'inconnu');
        final sc = crNegoScore21(n);
        if (sc >= 3) {
          final pay = jsRound(amt * 0.5);
          final e = _crPay(n, pay);
          if (e != null) return _no(s, e);
          cc['deal'] = 'moitié acceptée';
          _crClose(n, 'negocie', pay);
          _log(n, 'Accord : ${fmt21(pay)} cauris au lieu de ${fmt21(amt)} (${c['title']})', 'justice');
        } else {
          cc['tension'] = _n(cc['tension']) + 1;
          cc['node'] = sc == 2 ? 'counter' : 'refus';
          cc['counter'] = jsRound(amt * 0.75);
          _m(n['rel'])[cc['owner']] = clamp21(_n(_m(n['rel'])[cc['owner']]) - 3, -100, 100);
        }
      case 'counter':
        if (cc['node'] != 'counter') return _no(s, 'inconnu');
        final pay = _n(cc['counter']);
        final e = _crPay(n, pay);
        if (e != null) return _no(s, e);
        _crClose(n, 'negocie', pay);
        _log(n, 'Accord : ${fmt21(pay)} cauris (contre-offre) pour ${c['title']}', 'justice');
      case 'share':
        final sc = crNegoScore21(n);
        if (sc >= 2) {
          final pay = jsRound(crLicenceFee21(_crSong(n, cc['id']) ?? const <String, dynamic>{}) / 2);
          final e = _crPay(n, pay);
          if (e != null) return _no(s, e);
          final song = _crSong(n, cc['id']);
          _crClose(n, 'partage', pay);
          if (song != null) _crSet(song, crOf21(song)..['share'] = CrReg21.share);
          _log(n, 'Accord de rétrocession : ${(CrReg21.share * 100).round()} % des revenus futurs de ${c['title']} au titulaire', 'justice');
        } else {
          cc['tension'] = _n(cc['tension']) + 1;
          cc['node'] = 'refus';
          _m(n['rel'])[cc['owner']] = clamp21(_n(_m(n['rel'])[cc['owner']]) - 3, -100, 100);
        }
      case 'full':
        final e = _crPay(n, amt);
        if (e != null) return _no(s, e);
        _crClose(n, 'paye', amt);
        _log(n, 'Litige réglé au rendez-vous : ${fmt21(amt)} cauris (${c['title']})', 'justice');
      case 'leave':
        cc['st'] = 'avis';
        cc['node'] = null;
        _m(n['rel'])[cc['owner']] = clamp21(_n(_m(n['rel'])[cc['owner']]) - 10, -100, 100);
        _log(n, 'Rendez-vous quitté sans accord (${c['title']})', 'justice');
      default:
        return _no(s, 'inconnu');
    }
    return _ok(n);
  },
  // Contester la réclamation avec un avocat : revenus du titre gelés, décision après CrReg21.contestDays jours.
  'crContest': (s, lawyer) {
    final c = crClaim21(s);
    if (c == null || !const {'avis', 'ignore', 'intervention'}.contains(c['st'])) return _no(s, 'rien');
    if (_t(c['contested'])) return _no(s, 'deja');
    if (Reg21.lawyers[lawyer] == null) return _no(s, 'inconnu');
    final cost = crLawyerCost21(s, '$lawyer');
    if (_n(s['cash']) < cost) return _no(s, 'cash');
    final n = clone21(s);
    _pay(n, -cost);
    final cc = _m(n['crc']);
    cc['chance'] = crContestChance21(n, '$lawyer');
    cc['st'] = 'conteste';
    cc['contested'] = 1;
    cc['lawyer'] = lawyer;
    cc['trial'] = _n(n['day']) + CrReg21.contestDays;
    final song = _crSong(n, cc['id']);
    if (song != null) _crSet(song, crOf21(song)..['st'] = 'litige');
    _log(n, 'Contestation déposée avec ${Reg21.lawyers[lawyer]!['n']}${cost > 0 ? ' (−${fmt21(cost)} cauris)' : ''} · décision le jour ${cc['trial']}', 'justice');
    return _ok(n);
  },
  // Ignorer l'avis : rien ne se passe tout de suite ; à l'échéance, une intervention officielle suspend le titre.
  'crIgnore': (s, a) {
    final c = crClaim21(s);
    if (c == null || c['st'] != 'avis') return _no(s, 'rien');
    final n = clone21(s);
    _m(n['crc'])['st'] = 'ignore';
    _log(n, 'Avis de réclamation ignoré (${c['title']})', 'justice');
    return _ok(n);
  },
  // Après l'intervention : accepter le retrait du titre plutôt que payer.
  'crDrop': (s, a) {
    final c = crClaim21(s);
    if (c == null || c['st'] != 'intervention') return _no(s, 'rien');
    final n = clone21(s);
    _crRemove(n, <String>[], 'Retrait accepté');
    return _ok(n);
  },
};
