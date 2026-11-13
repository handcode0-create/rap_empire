// ignore_for_file: avoid_dynamic_calls, prefer_const_declarations, unnecessary_cast
part of 'engine21.dart';

/// V22 · Dynamic Concert Engine : invitations de concert (types, prestige, cachets variables, sponsor, public, déplacements).
/// Fait partie de la bibliothèque du moteur v21 (accès aux outils privés : _cachet, _spend, rng21…). Fonctions pures sur l'état JSON.
/// Rien n'est ajouté à l'état initial : la clé « cv » n'existe qu'après la première invitation acceptée, ce qui laisse intactes
/// les parties existantes et les tests de parité. Le concert v21 « Le Parvis » (action 'concert') reste disponible.
/// TOUTES les valeurs ci-dessous sont PROVISOIRES (à recalibrer avec l'économie, étude D-08).

class CvType21 {
  final String id, label, title, img;
  final int prestige; // 0 : déterminé par le sponsor (concert sponsorisé, 2 à 5)
  final int fam; // 0 petit, 1 intermédiaire, 2 prestige
  final int feeLo, feeHi, capLo, capHi, expLo, expHi;
  final List<String> cities;
  const CvType21(this.id, this.label, this.title, this.img, this.prestige, this.fam, this.feeLo, this.feeHi, this.capLo, this.capHi, this.expLo, this.expHi, this.cities);
}

class Cv21 {
  static const nationales = ['bakoma', 'portambre', 'selene'];
  static const mondiales = ['tamarel', 'korvane', 'aldera'];
  static const cityImages = ['portambre', 'selene', 'tamarel', 'korvane', 'aldera']; // illustrations de villes (assets/cities/<clé>.webp)
  static const toutes = ['bakoma', 'portambre', 'selene', 'tamarel', 'korvane', 'aldera'];

  static const types = <String, CvType21>{
    'underground': CvType21('underground', 'Showcase underground', 'Showcase de la Cave', 'showcase_underground', 1, 0, 500, 3000, 80, 150, 2, 4, nationales),
    'nightclub': CvType21('nightclub', 'Concert en club', 'Soirée Néon Club', 'nightclub_concert', 2, 0, 1500, 6000, 300, 600, 2, 4, nationales),
    'regional_festival': CvType21('regional_festival', 'Festival régional', 'Festival des nouvelles scènes', 'regional_festival', 3, 1, 3500, 12000, 1000, 2500, 3, 6, nationales),
    'sponsored_event': CvType21('sponsored_event', 'Concert sponsorisé', 'Nuit des partenaires', 'sponsored_event', 0, 1, 2000, 18000, 800, 3000, 3, 6, toutes),
    'private_vip': CvType21('private_vip', 'Concert privé VIP', 'Soirée privée du rooftop', 'private_vip', 4, 1, 6000, 25000, 50, 120, 2, 4, toutes),
    'national_arena': CvType21('national_arena', 'Grande scène nationale', 'Grande scène nationale', 'national_arena', 4, 2, 8000, 25000, 5000, 12000, 4, 7, nationales),
    'international_festival': CvType21('international_festival', 'Festival international', 'Festival Horizon', 'international_festival', 5, 2, 15000, 30000, 15000, 40000, 5, 8, mondiales),
  };
  static const order = ['underground', 'nightclub', 'regional_festival', 'sponsored_event', 'private_vip', 'national_arena', 'international_festival'];

  /// Probabilités (petit, intermédiaire, prestige) par rang de carrière.
  static const weights = <int, List<int>>{
    3: [65, 30, 5],
    4: [40, 42, 18],
    5: [18, 40, 42]
  };
  static const rankFactor = <int, double>{3: 0.9, 4: 1.0, 5: 1.15};

  static const offers = 3, maxAccepted = 3;
  static const sponsorLabel = ['Local', 'National', 'Premium'];
  static const sponsorRate = [0.06, 0.14, 0.28];
  static const sponsorRep = [0, 1, 2];

  static const transport = <String, int>{'bakoma': 0, 'portambre': 1500, 'selene': 1500, 'tamarel': 6000, 'korvane': 6500, 'aldera': 7000};
}

int _cvRank(J s) => math.max(3, math.min(5, _n(s['rank']).toInt()));

J _cvOf(J n) {
  n['cv'] ??= <String, dynamic>{'sd': -1, 'sg': -1, 'seq': 0, 'gen': 0, 'list': <dynamic>[]};
  return _m(n['cv']);
}

J? _cvFind(J n, dynamic id) {
  for (final x in _l(_cvOf(n)['list'])) {
    if (_m(x)['id'] == id) return _m(x);
  }
  return null;
}

/// Une invitation. Hasard : rng21 (graine, jour, sel), donc la même liste à chaque ouverture de l'écran.
J _cvGen(J s, int gen, int seq, Set<String> used) {
  final day = _n(s['day']).toInt();
  final base = 7000 + (gen * 61 + seq) * 31;
  double r(int i) => rng21(s, base + i);
  final rank = _cvRank(s);
  final pop = _n(s['pop']), rep = _n(s['rep']);
  // Probabilités de départ, poussées vers le prestige par la popularité et la réputation (jamais une règle stricte).
  final w = List<int>.from(Cv21.weights[rank]!);
  final shift = jsRound(clamp21((pop - 30) / 10, -2, 4) + clamp21(rep / 60, 0, 3));
  final mv = shift >= 0 ? math.min(shift, w[0]) : -math.min(-shift, w[2]);
  w[0] -= mv;
  w[2] += mv;
  final x = r(0) * 100;
  final fam = x < w[0] ? 0 : (x < w[0] + w[1] ? 1 : 2);
  var pool = Cv21.order.where((k) => Cv21.types[k]!.fam == fam && !used.contains(k)).toList();
  if (pool.isEmpty) pool = Cv21.order.where((k) => !used.contains(k)).toList();
  if (pool.isEmpty) pool = List<String>.from(Cv21.order);
  final t = Cv21.types[pool[(r(1) * pool.length).floor()]]!;
  final city = t.cities[(r(2) * t.cities.length).floor()];
  final cap = t.capLo + jsRound((t.capHi - t.capLo) * r(3));
  // Sponsor : indépendant du niveau, plus probable avec la popularité, le prestige et la réputation.
  final basePrestige = t.prestige > 0 ? t.prestige : 3;
  final chance = clamp21(0.10 + 0.04 * basePrestige + pop / 400 + rep / 600, 0, 0.6);
  final hasSponsor = t.id == 'sponsored_event' || r(4) < chance;
  final score = r(5) + 0.05 * basePrestige + pop / 500;
  final tier = score < 0.5 ? 0 : (score < 0.85 ? 1 : 2);
  final prestige = t.prestige > 0 ? t.prestige : math.min(5, 2 + tier + (rank >= 5 ? 1 : 0));
  // Cachet C = B × N × P × R × A, chaque facteur borné, résultat borné par le type. Le sponsor s'ajoute à part (affiché avant acceptation).
  final b = (t.feeLo + t.feeHi) / 2;
  final nF = Cv21.rankFactor[rank]!;
  final pF = 0.9 + 0.3 * clamp21(pop, 0, 100) / 100;
  final rF = 0.9 + 0.2 * clamp21(rep / 120, 0, 1);
  final aF = 0.85 + 0.3 * r(6);
  final fee = jsRound(clamp21(b * nF * pF * rF * aF, t.feeLo, t.feeHi) / 10) * 10;
  final bonus = hasSponsor ? jsRound(fee * Cv21.sponsorRate[tier]) : 0;
  // Public attendu, toujours plafonné par la capacité.
  final demand = (40 + _n(s['fans']) * 0.05 + _n(_m(s['geo'])[city]) * 4) *
      (s['lperk'] == 'scene' ? 1.2 : 1) *
      (0.8 + 0.15 * prestige) *
      (1 + mkBoost21(s) * 0.5);
  final att = math.min(cap, jsRound(demand * (0.9 + 0.2 * r(7))));
  final fill = cap <= 0 ? 0 : jsRound(100 * att / cap);
  final away = city != 'bakoma';
  final hotel = away && prestige >= 3 ? (Cv21.mondiales.contains(city) ? 3000 : 1000 + jsRound(1500 * r(9))) : 0;
  final exp = day + t.expLo + ((t.expHi - t.expLo + 1) * r(8)).floor();
  return {
    'id': 'cv${day}_${gen}_$seq',
    'type': t.id,
    'label': t.label,
    'title': t.title,
    'img': 'assets/events/${t.img}.png',
    'city': city,
    'cityName': Reg21.cities[city] ?? city,
    'prestige': prestige,
    'cap': cap,
    'att': att,
    'fill': fill,
    'base': jsRound(b),
    'fee': fee,
    'sponsor': hasSponsor ? {'tier': tier, 'cat': Cv21.sponsorLabel[tier], 'bonus': bonus, 'rep': Cv21.sponsorRep[tier]} : null,
    'travel': {'transport': Cv21.transport[city] ?? 0, 'hotel': hotel},
    'status': 'available',
    'exp': exp,
    'seq': seq,
    'gen': gen,
    'day': day,
  };
}

/// Met la liste à jour : nouveau jour ou renouvellement après un concert. Garde les concerts acceptés et les invitations non expirées,
/// complète jusqu'à 3 invitations disponibles sans doublon de type. Idempotent : sans changement de jour ni de série, ne fait rien.
void _cvRefresh(J n) {
  final cv = _cvOf(n);
  final day = _n(n['day']).toInt();
  if (_n(cv['sd']) == day && _n(cv['sg']) == _n(cv['gen'])) return;
  final keep = _l(cv['list']).map(_m).where((o) => o['status'] == 'accepted' || (o['status'] == 'available' && _n(o['exp']) >= day)).toList();
  final avail = keep.where((o) => o['status'] == 'available').toList();
  final used = avail.map((o) => o['type'] as String).toSet();
  final gen = _n(cv['gen']).toInt();
  var seq = _n(cv['seq']).toInt();
  while (avail.length < Cv21.offers) {
    final o = _cvGen(n, gen, seq, used);
    seq++;
    used.add(o['type'] as String);
    avail.add(o);
    keep.add(o);
  }
  cv['seq'] = seq;
  cv['list'] = keep;
  cv['sd'] = day;
  cv['sg'] = gen;
}

/// Invitations à afficher (sans modifier l'état). Vide avant le rang 3.
List<J> cvView21(J s) {
  if (_n(s['rank']) < 3) return const [];
  final n = clone21(s);
  _cvRefresh(n);
  return _l(_m(n['cv'])['list']).map(_m).toList();
}

/// Frais de déplacement totaux d'une invitation.
int cvTravel21(J o) => (_n(_m(o['travel'])['transport']) + _n(_m(o['travel'])['hotel'])).toInt();

Res cvAccept21(J s, dynamic a) {
  if (_n(s['rank']) < 3) return _no(s, 'rang');
  final n = clone21(s);
  _cvRefresh(n);
  final o = _cvFind(n, a);
  if (o == null || o['status'] != 'available') return _no(s, 'inconnu');
  if (_n(o['exp']) < _n(n['day'])) return _no(s, 'expire');
  final acc = _l(_m(n['cv'])['list']).where((x) => _m(x)['status'] == 'accepted').length;
  if (acc >= Cv21.maxAccepted) return _no(s, 'plein');
  o['status'] = 'accepted';
  o['accDay'] = n['day'];
  _log(n, 'Invitation acceptée : ${o['title']} à ${o['cityName']} · cachet ${fmt21(_n(o['fee']))}', 'scene');
  return _ok(n);
}

Res cvDecline21(J s, dynamic a) {
  if (_n(s['rank']) < 3) return _no(s, 'rang');
  final n = clone21(s);
  _cvRefresh(n);
  final o = _cvFind(n, a);
  if (o == null || o['status'] != 'available') return _no(s, 'inconnu');
  final cv = _m(n['cv']);
  cv['list'] = _l(cv['list']).where((x) => _m(x)['id'] != a).toList();
  return _ok(n);
}

/// Jouer un concert accepté : cachet figé à l'acceptation, payé une seule fois (sponsor compris), frais de déplacement déduits.
Res cvPlay21(J s, dynamic a) {
  if (_n(s['rank']) < 3) return _no(s, 'rang');
  final n = clone21(s);
  _cvRefresh(n);
  final o = _cvFind(n, a);
  if (o == null || o['status'] != 'accepted') return _no(s, 'inconnu');
  if (_n(s['day']) - _n(s['lastConcert']) < Reg21.concertEvery) return _no(s, 'delai');
  final cost = cvTravel21(o);
  if (_n(n['cash']) < cost) return _no(s, 'cash');
  final own = _m(s['own']);
  final e = _spend(n, 4, 35 - (own['moto'] != null ? 5 : 0) - (own['voiture'] != null ? 5 : 0));
  if (e != null) return _no(s, e);
  final cap = _n(o['cap']).toInt();
  final att = math.min(cap, jsRound(_n(o['att']) * (0.9 + 0.2 * rng21(n, 9100 + _n(o['seq'])))));
  final f = cap <= 0 ? 0.0 : att / cap;
  final fill = jsRound(100 * f);
  final p = _n(o['prestige']).toInt();
  final sp = o['sponsor'] == null ? null : _m(o['sponsor']);
  final bonus = sp == null ? 0 : _n(sp['bonus']).toInt();
  final fee = _n(o['fee']).toInt();
  final fg = jsRound(att * (f >= 0.8 ? 1.6 : (f >= 0.5 ? 1.3 : 1.1)));
  final rp = jsRound(3 + 1.5 * p * (0.5 + 0.5 * f)) + (sp == null ? 0 : _n(sp['rep']).toInt());
  n['shows'] = _n(n['shows']) + 1;
  n['fans'] = _n(n['fans']) + fg;
  n['rep'] = _n(n['rep']) + rp;
  final cut = _cachet(n, fee + bonus, 'concert');
  _pay(n, -cost);
  _geoAdd(n, o['city'] as String, p >= 4 ? 5 : 3);
  n['pop'] = clamp21(_n(n['pop']) + 1, 0, 100);
  _addXp(n, 90);
  n['lastConcert'] = n['day'];
  n['concertDay'] = n['day'];
  n['cc'] = {
    'g': f >= 0.8 ? 'A' : (f >= 0.5 ? 'B' : 'C'),
    'tk': att,
    'gross': fee + bonus - cost,
    'cash': fee + bonus - cut - cost,
    'managerCut': cut,
    'fans': fg,
    'rep': rp,
    'day': n['day'],
    'media': null,
    'spon': bonus,
    'fill': fill,
    'v22': 1,
    'title': o['title'],
    'label': o['label'],
    'city': o['cityName'],
    'cap': cap,
    'travel': cost,
    'cat': sp == null ? null : sp['cat'],
    'prestige': p,
  };
  final cv = _m(n['cv']);
  cv['list'] = _l(cv['list']).where((x) => _m(x)['id'] != a).toList();
  cv['gen'] = _n(cv['gen']) + 1; // renouvellement après un concert terminé
  _log(n, '${o['title']} à ${o['cityName']} : $att spectateurs sur $cap · +${fmt21(fg)} fans · cachet ${fmt21(fee + bonus)}', 'scene');
  return _ok(n);
}
