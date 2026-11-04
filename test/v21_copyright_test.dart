import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/domain/v21/view21.dart';

J m(dynamic x) => x as J;
List l(dynamic x) => x as List;

J must(J s, String a, [dynamic g]) {
  final r = act21(s, a, g);
  expect(r.err, isNull, reason: '$a $g');
  return r.s;
}

J base() => act21(init21(), 'preset', 'carriere').s;

/// Ajoute un single sorti aujourd'hui avec un statut de droits donné.
J withSong(J s, String st, num listens, {String owner = 'woro', String inst = 'brume', num rev = 400000, String id = 'T90'}) {
  final n = clone21(s);
  l(n['disco']).insert(0, <String, dynamic>{
    'id': id, 'title': 'Titre test', 'day': n['day'], 'L': listens, 'launchL': listens, 'rev': rev, 'inst': inst, 'signed': 0,
    'platforms': <String, dynamic>{}, 'clip': <String, dynamic>{'st': 'aucun'}, 'st': 'sorti',
    'cr': <String, dynamic>{'st': st, 'lic': st, 'owner': owner},
  });
  return n;
}

J song(J s, [String id = 'T90']) => l(s['disco']).map(m).firstWhere((x) => x['id'] == id);

/// Le titre redevient « jeune » : il a encore des écoutes de catalogue (utile une fois la réclamation arrivée).
J fresh(J s, [String id = 'T90']) {
  song(s, id)['day'] = s['day'];
  return s;
}

/// Passe les journées jusqu'à l'avis de réclamation (au plus [max] jours).
J untilClaim(J s, {int max = 60}) {
  var x = s;
  for (var i = 0; i < max; i++) {
    x = must(x, 'endDay');
    final c = x['crc'];
    if (c != null && m(c)['st'] == 'avis') return x;
  }
  fail('aucune réclamation en $max jours');
}

void main() {
  group('instrus et licences', () {
    test('instru libre : enregistrée et sortie sans aucun risque', () {
      var s = must(base(), 'create', ['quartier', 'sombre']);
      s = must(s, 'pick', 'nuit');
      s = must(s, 'record');
      expect(m(m(s['cur'])['cr'])['st'], 'libre');
      s = must(s, 'release');
      final t = m(l(s['disco']).first);
      expect(crRiskLevel21(s, t), 'Aucun');
      t['L'] = 9000000;
      expect(crDailyChance21(s, t), 0);
    });

    test('instru gratuite avec conditions : gratuite, statut « avec conditions », titulaire Tamsir Koffi', () {
      var s = must(base(), 'create', ['quartier', 'sombre']);
      final c0 = s['cash'];
      s = must(s, 'pick', 'minuit');
      expect(s['cash'], c0);
      s = must(s, 'record');
      expect(m(m(s['cur'])['cr']), {'st': 'cond', 'lic': 'cond', 'owner': 'tamsir'});
    });

    test('licence non exclusive limitée, licence exclusive au triple du prix', () {
      var s = must(base(), 'create', ['quartier', 'sombre']);
      final c0 = s['cash'] as num;
      final a = must(s, 'pick', 'gbaka');
      expect(a['cash'], c0 - 8000);
      final ra = must(a, 'record');
      final cr = m(m(ra['cur'])['cr']);
      expect([cr['st'], cr['lic'], cr['cap'], cr['until']], ['lic', 'nonexcl', CrReg21.licCapL, ra['day'] + CrReg21.licDays]);
      final b = must(s, 'pick', ['gbaka', 'excl']);
      expect(b['cash'], c0 - 8000 * CrReg21.exclMult);
      expect(m(m(must(b, 'record')['cur'])['cr'])['st'], 'sec');
    });

    test('licence expirée quand les écoutes couvertes sont dépassées', () {
      var s = withSong(base(), 'lic', CrReg21.licCapL + 1, owner: 'kore', inst: 'gbaka');
      m(song(s)['cr'])['cap'] = CrReg21.licCapL;
      m(song(s)['cr'])['until'] = (s['day'] as num) + 100;
      s = must(s, 'endDay');
      expect(crStatus21(song(s)), 'exp');
    });

    test('régulariser avant toute réclamation : la licence est achetée, plus aucun risque', () {
      var s = withSong(base(), 'cond', 2000000, owner: 'tamsir', inst: 'minuit');
      final price = crRegPrice21(song(s));
      expect(price, CrReg21.licFee['cond']! + (400000 * CrReg21.regPct).round());
      final c0 = s['cash'] as num;
      s = must(s, 'crReg', 'T90');
      expect([s['cash'], crStatus21(song(s)), crRiskLevel21(s, song(s))], [c0 - price, 'sec', 'Aucun']);
    });
  });

  group('déclenchement', () {
    test('un titre viral sur une instru non autorisée finit par recevoir un avis', () {
      final s = untilClaim(withSong(base(), 'nonaut', 3000000));
      final c = m(s['crc']);
      expect([c['id'], c['owner'], c['kind'], c['st'], c['seen']], ['T90', 'woro', 'nonaut', 'avis', 0]);
      expect(c['amt'] as num, greaterThanOrEqualTo(CrReg21.licFee['nonaut']!));
      expect(crStatus21(song(s)), 'litige');
      expect(c['due'], (s['day'] as num) + CrReg21.replyDays);
    });

    test('aucun litige sur un titre autorisé, même très écouté', () {
      for (final st in ['libre', 'sec', 'lic']) {
        var s = withSong(base(), st, 5000000);
        if (st == 'lic') m(song(s)['cr'])..['cap'] = 99000000..['until'] = 9999;
        for (var i = 0; i < 60; i++) {
          s = must(s, 'endDay');
        }
        expect([s['crc'], l(s['crHist']).length], [null, 0], reason: st);
      }
    });

    test('aucun litige sous le seuil d’écoutes (200 écoutes, instru non autorisée)', () {
      var s = withSong(base(), 'nonaut', 200);
      expect(crDailyChance21(s, song(s)), 0);
      for (var i = 0; i < 40; i++) {
        s = must(s, 'endDay');
      }
      expect(s['crc'], isNull);
    });

    test('le risque grandit avec les écoutes', () {
      final s = base();
      final small = withSong(s, 'nonaut', 300000), big = withSong(s, 'nonaut', 1400000);
      expect(crDailyChance21(big, song(big)), greaterThan(crDailyChance21(small, song(small))));
    });
  });

  group('choix du joueur', () {
    test('payer tout de suite : le montant est débité, le titre reste en ligne et continue à être écouté', () {
      var s = fresh(untilClaim(withSong(base(), 'nonaut', 3000000)));
      final amt = m(s['crc'])['amt'] as num, c0 = s['cash'] as num;
      s = must(s, 'crPay');
      expect([s['cash'], s['crc'], crStatus21(song(s)), m(l(s['crHist']).last)['res']], [c0 - amt, null, 'regle', 'paye']);
      final l0 = song(s)['L'] as num;
      s = must(s, 'endDay');
      expect(song(s)['L'] as num, greaterThanOrEqualTo(l0));
    });

    test('négocier sans appui : moitié refusée, tension, puis paiement complet', () {
      var s = untilClaim(withSong(base(), 'nonaut', 3000000));
      s['mgr'] = null;
      s['signed'] = 0;
      final c0 = s['cash'] as num;
      s = must(s, 'crNego');
      expect([m(s['crc'])['st'], s['cash']], ['nego', c0 - CrReg21.negoFee]);
      expect(act21(s, 'crNego').err, 'rien');
      expect(crNegoRisk21(s, 'half'), 'Élevé');
      s = must(s, 'crOffer', 'half');
      expect([m(s['crc'])['node'], m(s['crc'])['tension']], ['refus', 1]);
      final amt = m(s['crc'])['amt'] as num, c1 = s['cash'] as num;
      s = must(s, 'crOffer', 'full');
      expect([s['cash'], s['crc']], [c1 - amt, null]);
    });

    test('négocier avec label, manager et bonne relation : la moitié est acceptée', () {
      var s = withSong(base(), 'cond', 3000000, owner: 'tamsir', inst: 'minuit');
      s['signed'] = 1;
      s['label'] = 'AUB';
      s['mgr'] = 'm2';
      m(s['rel'])['tamsir'] = 20;
      s = untilClaim(s);
      expect(crNegoScore21(s), greaterThanOrEqualTo(3));
      final amt = m(s['crc'])['amt'] as num;
      s = must(s, 'crNego');
      final c1 = s['cash'] as num;
      s = must(s, 'crOffer', 'half');
      expect([s['cash'], s['crc'], m(l(s['crHist']).last)['res']], [c1 - (amt * 0.5).round(), null, 'negocie']);
    });

    test('rétrocession : acompte, puis la moitié des revenus futurs du titre va au titulaire', () {
      var s = withSong(base(), 'cond', 3000000, owner: 'tamsir', inst: 'minuit');
      s['signed'] = 1;
      s['label'] = 'AUB';
      s = fresh(untilClaim(s));
      s = must(s, 'crNego');
      s = must(s, 'crOffer', 'share');
      expect(m(song(s)['cr'])['share'], CrReg21.share);
      s = must(s, 'endDay');
      expect(m(song(s)['cr'])['shared'] as num, greaterThan(0));
    });

    test('ignorer : intervention officielle, titre suspendu sans écoutes, paiement majoré pour le rétablir', () {
      var s = fresh(untilClaim(withSong(base(), 'nonaut', 3000000)));
      s = must(s, 'crIgnore');
      for (var i = 0; i < CrReg21.replyDays + 1 && m(s['crc'])['st'] != 'intervention'; i++) {
        s = must(s, 'endDay');
      }
      expect([m(s['crc'])['st'], crStatus21(song(s)), m(s['crc'])['seen']], ['intervention', 'susp', 0]);
      final l0 = song(s)['L'];
      s = must(s, 'endDay');
      expect([song(s)['L'], song(s)['lastDayL']], [l0, 0]);
      final due = crDue21(s), c0 = s['cash'] as num;
      expect(due, ((m(s['crc'])['amt'] as num) * (1 + CrReg21.latePct)).round());
      s['cash'] = c0 + due;
      s = must(s, 'crPay');
      expect([s['cash'], crStatus21(song(s))], [c0, 'regle']);
    });

    test('retrait : délai final dépassé, titre hors plateformes et hors classement, popularité et réputation en baisse', () {
      var s = untilClaim(withSong(base(), 'nonaut', 3000000));
      s = must(s, 'crIgnore');
      for (var i = 0; i < 20 && s['crc'] != null; i++) {
        s = must(s, 'endDay');
      }
      final t = song(s);
      expect([crStatus21(t), singleRankOf(t), m(s['crOut'])['type'], m(l(s['crHist']).last)['res']], ['retire', 0, 'retrait', 'retire']);
      expect(crStatusLabel21[crStatus21(t)], 'Retiré pour litige de droits d’auteur');
      final l0 = t['L'];
      s = must(s, 'endDay');
      expect(song(s)['L'], l0);
    });

    test('accepter le retrait pendant l’intervention', () {
      var s = untilClaim(withSong(base(), 'nonaut', 3000000));
      s = must(s, 'crIgnore');
      while (m(s['crc'])['st'] != 'intervention') {
        s = must(s, 'endDay');
      }
      final p0 = s['pop'] as num;
      s = must(s, 'crDrop');
      expect([crStatus21(song(s)), s['crc']], ['retire', null]);
      expect(s['pop'] as num, lessThan(p0));
    });

    test('contester : revenus gelés pendant la procédure, rendus en cas de victoire', () {
      var s = fresh(untilClaim(withSong(base(), 'cond', 3000000, owner: 'tamsir', inst: 'minuit')));
      s = must(s, 'crContest', 'conf');
      expect([m(s['crc'])['st'], m(s['crc'])['trial']], ['conteste', (s['day'] as num) + CrReg21.contestDays]);
      m(s['crc'])['chance'] = 100;
      final rev0 = song(s)['rev'] as num;
      s = must(s, 'endDay');
      expect(m(s['crc'])['escrow'] as num, greaterThan(0));
      expect(song(s)['rev'], rev0); // revenus du jour retenus, pas versés
      while (s['crc'] != null) {
        s = must(s, 'endDay');
      }
      expect([crStatus21(song(s)), m(s['crOut'])['win']], ['rejete', 1]);
      expect(song(s)['rev'] as num, greaterThan(rev0));
    });

    test('contester et perdre : le montant majoré est payé, en partie avec les revenus gelés', () {
      var s = untilClaim(withSong(base(), 'cond', 3000000, owner: 'tamsir', inst: 'minuit'));
      s = must(s, 'crContest', 'office');
      m(s['crc'])['chance'] = 0;
      final amt = m(s['crc'])['amt'] as num;
      while (s['crc'] != null) {
        s = must(s, 'endDay');
      }
      final out = m(s['crOut']);
      expect([out['win'], out['owe']], [0, (amt * (1 + CrReg21.contestLossPct)).round()]);
      expect(m(l(s['crHist']).last)['res'], 'contest_perdu');
    });

    test('pas assez de cauris : le paiement est refusé, jamais de dette', () {
      var s = untilClaim(withSong(base(), 'nonaut', 3000000));
      s['cash'] = 10;
      expect(act21(s, 'crPay').err, 'cash');
      expect(s['cash'], 10);
    });
  });

  group('règles générales', () {
    test('le litige survit à une sauvegarde et à la reprise du jeu', () {
      final s = untilClaim(withSong(base(), 'nonaut', 3000000));
      final saved = jsonDecode(jsonEncode(s)) as J;
      final back = act21(saved, 'promo', 0).s;
      expect(m(back['crc'])['id'], 'T90');
      expect(m(back['crc'])['amt'], m(s['crc'])['amt']);
      expect(crStatus21(song(back)), 'litige');
      expect(act21(back, 'crPay').err, isNull);
    });

    test('un seul litige par titre, même après règlement et des semaines de succès', () {
      var s = untilClaim(withSong(base(), 'nonaut', 3000000));
      s = must(s, 'crPay');
      expect(crDailyChance21(s, song(s)), 0);
      for (var i = 0; i < 60; i++) {
        s = must(s, 'endDay');
      }
      expect(l(s['crHist']).length, 1);
    });

    test('un seul litige à la fois et un délai entre deux litiges', () {
      var s = withSong(base(), 'nonaut', 3000000);
      s = withSong(s, 'nonaut', 3000000, id: 'T91');
      s = untilClaim(s);
      final first = m(s['crc'])['id'];
      s = must(s, 'crPay');
      final paidDay = s['day'] as num;
      for (var i = 0; i < CrReg21.gapDays - 1; i++) {
        s = must(s, 'endDay');
        expect(s['crc'], isNull);
      }
      expect((s['day'] as num) - paidDay, CrReg21.gapDays - 1);
      expect(first, anyOf('T90', 'T91'));
    });

    test('anciennes sauvegardes : un titre sans statut est réputé licencié', () {
      expect(crStatus21({'inst': 'gbaka'}), 'sec');
      expect(crStatus21({'inst': 'nuit'}), 'libre');
    });

    test('petites scènes sans cachet : open mic et battle de quartier ne rapportent pas de cauris', () {
      var s = act21(init21(), 'preset', 'debut').s;
      final c0 = s['cash'];
      s = must(s, 'openmic');
      expect([s['cash'], s['om']], [c0, 1]);
      var b = act21(init21(), 'preset', 'debut').s;
      b = must(b, 'evc', 'a');
      final c1 = b['cash'];
      b = must(b, 'battle', 3);
      expect([b['cash'], m(b['btl'])['win']], [c1, 1]);
    });
  });
}
