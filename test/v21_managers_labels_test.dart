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
}
