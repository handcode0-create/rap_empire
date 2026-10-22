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
}
