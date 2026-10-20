import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Port des tests de garde-robe de docs/design-ref/v21/sources/test21.js (tests d'acceptation 3 à 11, côté moteur).
J must(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

J start() => act21(init21(), 'preset', 'debut').s;

void main() {
  test('catalogue du moteur identique à manifest.json et fichiers présents sur disque', () {
    final man = jsonDecode(File('assets/characters/rapper_001/manifest.json').readAsStringSync()) as Map;
    const keys = ['id', 'n', 'd', 'price', 'rank', 'start', 'images', 'status'];
    Map pick(Map o) => {for (final k in keys) k: o[k]};
    expect(jsonEncode([for (final o in man['outfits'] as List) pick(o as Map)]), jsonEncode([for (final o in Wardrobe21.outfits) pick(o)]));
    for (final o in Wardrobe21.outfits.where((o) => o['status'] == 'disponible')) {
      for (final v in ['young', 'mature']) {
        expect(File(Wardrobe21.base + (o['images'] as Map)[v]).existsSync(), isTrue, reason: '${o['id']} $v');
      }
    }
    // une tenue sans ses deux variantes est indisponible
    expect(Wardrobe21.outfits.every((o) => outfitComplete21(o) && o['status'] == 'disponible'), isTrue);
  });

  test('achat, équipement, variante mature et sauvegarde', () {
    var s = start();
    final c0 = s['cash'] as num;
    var wd = s['wd'] as J;
    expect([wd['eq'], (wd['owned'] as List).length], ['OUTFIT_001', 1]);

    s = must(s, 'obuy', 'OUTFIT_002');
    expect(((s['wd'] as J)['owned'] as List).contains('OUTFIT_002'), isTrue);
    expect(s['cash'], c0 - 6000);
    expect((s['wd'] as J)['eq'], 'OUTFIT_001'); // l'achat n'équipe pas

    var r = act21(s, 'obuy', 'OUTFIT_002');
    expect([r.err, r.s['cash']], ['deja', c0 - 6000]);
    expect(act21(s, 'obuy', 'OUTFIT_003').err, 'confirm'); // I-08 : 18 000 sans confirmation
    expect(Wardrobe21.outfits.firstWhere((o) => o['id'] == 'OUTFIT_005')['status'], 'disponible'); // variante mature générée
    expect(act21(s, 'obuy', 'OUTFIT_004').err, 'rang');
    final poor = clone21(s)..['cash'] = 100;
    expect(act21(poor, 'oask', 'OUTFIT_003').err, 'cash');
    expect(act21(s, 'oeq', 'OUTFIT_003').err, 'pasachete');

    s = must(s, 'oeq', 'OUTFIT_002');
    var look = resolveLook21(s);
    expect([look.path, look.variant], ['${Wardrobe21.base}young/OUTFIT_002.webp', 'young']);

    s['rank'] = Wardrobe21.matureRank;
    s = must(s, 'endDay');
    look = resolveLook21(s);
    expect([look.variant, look.outfit, look.path], ['mature', 'OUTFIT_002', '${Wardrobe21.base}mature/OUTFIT_002.webp']);
    expect(((s['wd'] as J)['owned'] as List).length, 2);

    final saved = jsonDecode(jsonEncode(s)) as J;
    expect(resolveLook21(saved).path, look.path);
    expect((saved['wd'] as J)['eq'], 'OUTFIT_002');
    expect(ageVariant21({...s, 'rank': Wardrobe21.matureRank - 1}), 'young');
  });

  test('achat confirmé dès 15 000 cauris, annulation, look différent', () {
    var s = start()..['cash'] = 50000;
    s = must(s, 'oask', 'OUTFIT_003');
    expect((s['wd'] as J)['ask'], 'OUTFIT_003');
    s = must(s, 'ocancel');
    expect((s['wd'] as J)['ask'], isNull);
    expect(act21(s, 'oconfirm').err, 'rien');
    s = must(s, 'oask', 'OUTFIT_003');
    s = must(s, 'oconfirm');
    expect(s['cash'], 32000);
    expect(((s['wd'] as J)['owned'] as List).contains('OUTFIT_003'), isTrue);

    // le look choisi à la création ne bloque pas l'affichage des tenues
    final other = must(start(), 'ap', 'hair=afro');
    final look = resolveLook21(other);
    expect([look.path, look.fallback], ['${Wardrobe21.base}young/OUTFIT_001.webp', null]);
  });

  test('en prison : sélection et annulation restent possibles, pas l\'achat', () {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['jail'] = {'until': (s['day'] as num) + 5, 'days': 5};
    expect(act21(s, 'osel', 'OUTFIT_002').err, isNull);
    expect(act21(s, 'ocancel').err, isNull);
    expect(act21(s, 'obuy', 'OUTFIT_002').err, 'prison');
  });
}
