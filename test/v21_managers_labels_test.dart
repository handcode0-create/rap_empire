import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/features/v21/cast21.dart';

J must(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

J signed(String code, {num? adv}) {
  final s = act21(init21(), 'preset', 'carriere').s;
  s['signed'] = 1;
  s['label'] = code;
  s['lcut'] = 0.35;
  s['lperk'] = 'radio';
  if (adv != null) s['ladv'] = adv;
  return s;
}

void main() {
  test('les six niveaux de manager ont chacun un avatar illustré (dont le manager d\'élite)', () {
    final names = <String>{};
    for (final e in Reg21.managerTiers.entries) {
      final name = e.value['n'] as String;
      names.add(name);
      final id = castId21(name);
      expect(id, isNotNull, reason: '${e.key} $name : personnage absent du registre');
      for (final crop in ['bust', 'head', 'torso']) {
        expect(File('assets/characters/${id}_poised_$crop.svg').existsSync(), isTrue, reason: '${e.key} $id $crop');
      }
    }
    expect(names.length, 6, reason: 'six managers distincts');
    expect(Reg21.managerTiers['m6']!['n'], isNot(contains('à définir')));
  });

  test('rupture de contrat : pénalité = avance × 1,2, relation et popularité en baisse, retour à l\'indépendance', () {
    var s = signed('BLG', adv: 80000);
    s['cash'] = 200000;
    s['pop'] = 20;
    (s['rel'] as Map)['kre'] = 10;
    expect(labelBreakCost21(s), 96000);
    expect(act21(s, 'lbreak').err, 'confirmrupture');
    s = must(s, 'lbreak', 'confirm');
    expect(s['cash'], 104000);
    expect([s['signed'], s['label'], s['lcut'], s['lperk'], s['ladv']], [0, null, null, null, null]);
    expect((s['rel'] as Map)['kre'], -5);
    expect(s['pop'], 17);
    expect(act21(s, 'lbreak', 'confirm').err, 'pascontrat');
  });

  test('rupture : jamais de dette, avance du contrat type pour une ancienne sauvegarde, Bakoma Sound Records', () {
    final poor = signed('BSR', adv: 150000)..['cash'] = 100000;
    expect(act21(poor, 'lbreak', 'confirm').err, 'cash');
    expect(poor['signed'], 1);

    final old = signed('AMG'); // sans clé ladv
    expect(labelBreakCost21(old), 108000); // 90 000 × 1,2
    final bsr = signed('BSR')..['cash'] = 500000;
    expect(labelBreakCost21(bsr), 180000); // 150 000 × 1,2
    final r = must(bsr, 'lbreak', 'confirm');
    expect((r['rel'] as Map)['orage'], -15);
    expect(r['cash'], 320000);
  });

  test('la signature enregistre l\'avance perçue (ladv)', () {
    var s = act21(init21(), 'preset', 'carriere').s;
    s['rep'] = 40;
    s = must(s, 'sign');
    expect(s['ladv'], 150000);
    expect(labelBreakCost21(s), 180000);
  });

  group('merchandising', () {
    test('catalogue : 8 articles, une image chacun, classés du plus accessible au plus exigeant', () {
      expect(Reg21.merch.keys, containsAll(['tshirt', 'hoodie', 'vinyle', 'cd', 'casquette', 'capsule']));
      expect(Reg21.merch.length, 8);
      for (final id in Reg21.merch.keys) {
        expect(File('assets/merch/$id.svg').existsSync(), isTrue, reason: id);
      }
      final fans = Reg21.merch.values.map((m) => m['fans'] as num).toList();
      expect(fans, orderedEquals([...fans]..sort()));
    });

    test('lancement : conditions, une production à la fois, estimation = ventes réelles du premier jour', () {
      var s = act21(init21(), 'preset', 'carriere').s;
      s['fans'] = 4000;
      s['rank'] = 1;
      expect(act21(s, 'merch', 'hoodie').err, 'rang');
      s['rank'] = 2;
      s['cash'] = 200000;
      final est = merchEstimate21(s, Reg21.merch['hoodie']!);
      s = must(s, 'merch', 'hoodie');
      expect(s['cash'], 155000);
      expect(act21(s, 'merch', 'casquette').err, 'merchencours');
      s = must(s, 'endDay');
      expect((s['merch'] as J)['tot'], est.$1);
      expect(est.$2, est.$1 * 16);
    });
  });

  test('création de son label : dès le rang N4, capital payé, pas avec un contrat actif, revenu quotidien', () {
    var s = act21(init21(), 'preset', 'carriere').s;
    s['cash'] = 600000;
    s['rank'] = 3;
    expect(act21(s, 'olabel').err, 'rang');
    s['rank'] = 4;
    s['signed'] = 1;
    expect(act21(s, 'olabel').err, 'contratactif');
    s['signed'] = 0;
    s['cash'] = 100000;
    expect(act21(s, 'olabel').err, 'cash');
    s['cash'] = 600000;
    s = must(s, 'olabel');
    expect(s['cash'], 100000);
    expect(act21(s, 'olabel').err, 'deja');
  });

  group('écurie du label', () {
    J art(String id, String palier, {String statut = 'indépendant', int fans = 4000, int eco = 28000}) =>
        {'id': id, 'nom': 'Artiste $id', 'palier': palier, 'genre': 'Rap', 'ville': 'Ndolo', 'statut': statut, 'fans': fans, 'ecoutes': eco, 'pop': 30, 'talent': 55};

    num eco(J e) => e['eco'] as num;

    J founded({int rank = 4}) {
      var s = act21(init21(), 'preset', 'carriere').s;
      s['rank'] = rank;
      s['cash'] = 2000000;
      s['signed'] = 0;
      return must(s, 'olabel');
    }

    test('conditions : label fondé, rang du palier, statut libre, places, cash, doublon', () {
      var s = act21(init21(), 'preset', 'carriere').s;
      s['cash'] = 2000000;
      expect(act21(s, 'lsignart', art('A', 'Débutant')).err, 'pasdelabel');
      s = founded();
      expect(act21(s, 'lsignart', art('A', 'Confirmé')).err, 'rang');
      expect(act21(s, 'lsignart', art('A', 'Superstar internationale')).err, 'inconnu');
      expect(act21(s, 'lsignart', art('A', 'Débutant', statut: 'signé')).err, 'deja');
      s['cash'] = 1000;
      expect(act21(s, 'lsignart', art('A', 'Débutant')).err, 'cash');
      s['cash'] = 2000000;
      s = must(s, 'lsignart', art('A', 'Débutant'));
      expect(s['cash'], 1985000);
      expect(act21(s, 'lsignart', art('A', 'Débutant')).err, 'deja');
      s = must(s, 'lsignart', art('B', 'Talent émergent'));
      s = must(s, 'lsignart', art('C', 'Débutant'));
      expect(labelSlots21(s), 3);
      expect(act21(s, 'lsignart', art('D', 'Débutant')).err, 'ecurie');
    });

    test('revenus : streams, merch et frais calculés sur la part du label, cumulés par artiste', () {
      var s = founded();
      final a = art('A', 'Talent émergent');
      s = must(s, 'lsignart', a);
      final e = (s['olabel'] as J)['roster'][0] as J;
      final d = labelArtistDay21(e);
      expect(d['s'], jsRound(28000 / 7 * .45));
      expect(d['f'], -jsRound(40000 / 30));
      expect(d['net'], d['s']! + d['c']! + d['m']! + d['f']!);
      s = must(s, 'endDay');
      final t = (((s['olabel'] as J)['roster'][0]) as J)['tot'] as J;
      expect(t['s'], jsRound(28000 / 7 * .45));
      expect(t['m'], jsRound(0.4 * 63.245553203367585 * Reg21.merchScale * .45));
      expect(t['f'], jsRound(40000 / 30));
    });

    test('équipe : conditions, un poste de chaque, frais de 7 jours de salaire, licenciement', () {
      var s = act21(init21(), 'preset', 'carriere').s;
      s['cash'] = 2000000;
      expect(act21(s, 'lhire', 'moussa').err, 'pasdelabel');
      s = founded();
      expect(act21(s, 'lhire', 'nafi').err, 'rang');
      expect(act21(s, 'lhire', 'inconnu').err, 'inconnu');
      s = must(s, 'lhire', 'moussa');
      expect(s['cash'], 2000000 - 500000 - 4200);
      expect(act21(s, 'lhire', 'nafi').err, 'deja');
      s['rank'] = 5;
      expect(act21(s, 'lhire', 'nafi').err, 'deja');
      s = must(s, 'lfire', 'ar');
      expect(s['cash'], 2000000 - 500000 - 8400);
      expect(((s['olabel'] as J)['staff'] as Map), isEmpty);
      expect(act21(s, 'lfire', 'ar').err, 'inconnu');
    });

    test('équipe : remise A&R à la signature, bonus des postes sur les revenus, salaires prélevés', () {
      var s = founded();
      s = must(s, 'lhire', 'moussa');
      final before = s['cash'] as num;
      s = must(s, 'lsignart', art('A', 'Débutant'));
      expect(before - (s['cash'] as num), 13500); // 15 000 − 10 %
      s = must(s, 'lhire', 'prisca');
      s = must(s, 'lhire', 'cedric');
      final k = labelMods21((s['olabel'] as J)['staff']);
      expect([k['adv'], k['s'], k['f'], k['wage']], [0.9, 1.08, 0.85, 600 + 600 + 500]);
      final e = (s['olabel'] as J)['roster'][0] as J;
      final d = labelArtistDay21(e, (s['olabel'] as J)['staff']);
      expect(d['s'], jsRound(eco(e) / 7 * .5 * 1.08));
      expect(d['f'], -jsRound(15000 / 30 * .85));
      s['day'] = 3; // pas de concert ce jour-là (cycle de 8 jours)
      final ev = <String>[];
      final inc = ownLabelTick21(s, ev);
      final m = jsRound(0.4 * 63.245553203367585 * Reg21.merchScale * .5);
      expect(inc, d['s']! + m - jsRound(15000 / 30 * .85) - 1700);
      expect(ev.any((x) => x.contains('équipe')), isTrue);
    });

    test('libérer un artiste : la place se libère, l’avance n’est pas remboursée', () {
      var s = founded();
      s = must(s, 'lsignart', art('A', 'Débutant'));
      final cash = s['cash'];
      s = must(s, 'lrelart', 'A');
      expect(s['cash'], cash);
      expect(((s['olabel'] as J)['roster'] as List), isEmpty);
      expect(act21(s, 'lrelart', 'A').err, 'inconnu');
    });
  });

  group('sorties des artistes signés', () {
    J art(String id) =>
        {'id': id, 'nom': 'Artiste $id', 'palier': 'Talent émergent', 'genre': 'Rap', 'ville': 'Ndolo', 'statut': 'indépendant', 'fans': 4000, 'ecoutes': 28000, 'pop': 30, 'talent': 55};

    J ros(J s) => ((s['olabel'] as J)['roster'] as List)[0] as J;

    /// Label fondé avec un artiste signé, puis avance jusqu'à sa première demande de sortie.
    J withRequest() {
      var s = act21(init21(), 'preset', 'carriere').s;
      s['rank'] = 4;
      s['cash'] = 2000000;
      s['signed'] = 0;
      s = must(s, 'olabel');
      s = must(s, 'lsignart', art('A'));
      for (var i = 0; i < 8 && ros(s)['req'] == null; i++) {
        s = must(s, 'endDay');
      }
      return s;
    }

    test('signature : humeur, historique et première courbe', () {
      var s = act21(init21(), 'preset', 'carriere').s;
      s['rank'] = 4;
      s['cash'] = 2000000;
      s['signed'] = 0;
      s = must(must(s, 'olabel'), 'lsignart', art('A'));
      final a = ros(s);
      expect(a['mood'], Reg21.moodStart);
      expect(a['req'], isNull);
      expect(a['rel'], isEmpty);
      expect((a['ser'] as List).length, 1);
    });

    test('l’artiste demande un single, puis le cycle single, single, EP', () {
      final s = withRequest();
      final req = ros(s)['req'] as J;
      expect(req['kind'], 'single');
      expect(req['titre'], isNotEmpty);
      final a = ros(s);
      (a['rel'] as List).addAll([{'kind': 'single'}, {'kind': 'single'}]);
      expect(labelNextKind21(a), 'ep');
      (a['rel'] as List).addAll([{'kind': 'ep'}, {'kind': 'single'}, {'kind': 'single'}]);
      expect(labelNextKind21(a), 'album');
    });

    test('accepter : budget payé, sortie lancée, écoutes en hausse, humeur +6', () {
      var s = withRequest();
      final cash = s['cash'] as num;
      final fans = ros(s)['fans'] as num;
      final cost = labelRelCost21(ros(s), 'single', (s['olabel'] as J)['staff']);
      expect(cost, jsRound(8000 * .8));
      final base = labelArtistDay21(ros(s))['s']!;
      s = must(s, 'lreply', {'id': 'A', 'ch': 'accept'});
      final a = ros(s);
      expect(s['cash'], cash - cost);
      expect(a['req'], isNull);
      expect((a['rel'] as List).length, 1);
      expect(((a['rel'] as List)[0] as J)['q'], labelRelQuality21(a));
      expect(a['mood'], Reg21.moodStart + Reg21.moodAccept);
      expect(a['boost'], isNotNull);
      expect(a['fans'] as num, greaterThan(fans));
      expect(labelArtistDay21(a)['s']!, greaterThan(base));
      final paid = (a['tot'] as J)['s'] as num;
      s = must(s, 'endDay');
      expect(((ros(s)['tot'] as J)['s'] as num), greaterThan(paid));
      expect((((ros(s)['rel'] as List)[0]) as J)['rev'] as num, greaterThan(0));
    });

    test('la sortie finit après sa durée et libère la demande suivante', () {
      var s = withRequest();
      s = must(s, 'lreply', {'id': 'A', 'ch': 'accept'});
      final days = Reg21.relKinds['single']!['days'] as int;
      for (var i = 0; i < days; i++) {
        expect(ros(s)['boost'], isNotNull);
        s = must(s, 'endDay');
      }
      expect(ros(s)['boost'], isNull);
    });

    test('refuser : humeur −8, nouvelle demande dans 14 jours, rien de payé', () {
      var s = withRequest();
      final cash = s['cash'];
      s = must(s, 'lreply', {'id': 'A', 'ch': 'decline'});
      final a = ros(s);
      expect(s['cash'], cash);
      expect(a['mood'], Reg21.moodStart - Reg21.moodDecline);
      expect(a['req'], isNull);
      expect(a['nxt'], (s['day'] as num) + 14);
      expect(a['rel'], isEmpty);
      expect(act21(s, 'lreply', {'id': 'A', 'ch': 'accept'}).err, 'pasdedemande');
    });

    test('négocier : budget −30 % si l’artiste accepte, sinon demande retirée', () {
      var s = withRequest();
      final cash = s['cash'] as num;
      final costN = labelRelCost21(ros(s), 'single', (s['olabel'] as J)['staff'], true);
      s = must(s, 'lreply', {'id': 'A', 'ch': 'negotiate'});
      final a = ros(s);
      expect(a['req'], isNull);
      if ((a['rel'] as List).isNotEmpty) {
        expect(s['cash'], cash - costN);
        expect(a['mood'], Reg21.moodStart - Reg21.moodNego);
      } else {
        expect(s['cash'], cash);
        expect(a['mood'], Reg21.moodStart - Reg21.moodFail);
      }
      expect(['Faible', 'Moyen', 'Élevé'], contains(labelNegoRisk21(a)));
    });

    test('cash insuffisant bloque l’acceptation', () {
      final s = withRequest();
      s['cash'] = 100;
      expect(act21(s, 'lreply', {'id': 'A', 'ch': 'accept'}).err, 'cash');
    });

    test('sans réponse, la demande expire : humeur −6', () {
      var s = withRequest();
      for (var i = 0; i < Reg21.relExpire + 1 && ros(s)['req'] != null; i++) {
        s = must(s, 'endDay');
      }
      expect(ros(s)['req'], isNull);
      expect(ros(s)['mood'], Reg21.moodStart - Reg21.moodFail);
      expect(ros(s)['note'], contains('remis sa sortie'));
    });

    test('commander une sortie soi-même : coût du palier, une seule à la fois', () {
      var s = act21(init21(), 'preset', 'carriere').s;
      s['rank'] = 4;
      s['cash'] = 2000000;
      s['signed'] = 0;
      s = must(must(s, 'olabel'), 'lsignart', art('A'));
      final cash = s['cash'] as num;
      expect(act21(s, 'lrelease', {'id': 'A', 'kind': 'inconnu'}).err, 'inconnu');
      s = must(s, 'lrelease', {'id': 'A', 'kind': 'album'});
      expect(s['cash'], cash - labelRelCost21(ros(s), 'album', null));
      expect(labelRelCost21(ros(s), 'album', null), jsRound(90000 * .8));
      expect(((ros(s)['rel'] as List)[0] as J)['kind'], 'album');
      expect(act21(s, 'lrelease', {'id': 'A', 'kind': 'single'}).err, 'sortieencours');
    });

    test('un album rapporte plus qu’un single (gain d’écoutes et fans)', () {
      J run(String kind) {
        var s = act21(init21(), 'preset', 'carriere').s;
        s['rank'] = 4;
        s['cash'] = 2000000;
        s['signed'] = 0;
        s = must(must(s, 'olabel'), 'lsignart', art('A'));
        return must(s, 'lrelease', {'id': 'A', 'kind': kind});
      }
      final single = ros(run('single')), album = ros(run('album'));
      expect(((album['boost'] as J)['m'] as num), greaterThan((single['boost'] as J)['m'] as num));
      expect(album['fans'] as num, greaterThan(single['fans'] as num));
    });
  });
}
