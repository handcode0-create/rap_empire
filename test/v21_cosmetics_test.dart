import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Coiffures et tatouages de la garde-robe : calques présents, achat, équipement, anciennes sauvegardes.
J must(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

J start() {
  final s = act21(init21(), 'preset', 'debut').s;
  s['cash'] = 500000;
  s['rank'] = 1;
  return s;
}

void main() {
  test('tous les calques existent sur disque, pour chaque tenue, coiffure et tatouage', () {
    const layers = 'assets/characters/rapper_001/layers/';
    for (final v in ['young', 'mature']) {
      expect(File('${layers}head/$v.svg').existsSync(), isTrue, reason: 'tête $v');
      for (final h in Wardrobe21.hairs) {
        expect(File('${layers}hairfront/${h['id']}_$v.svg').existsSync(), isTrue, reason: 'coiffure ${h['id']} $v');
      }
      for (final t in Wardrobe21.tattoos) {
        expect(File('${layers}tat/${t['id']}_$v.svg').existsSync(), isTrue, reason: 'tatouage ${t['id']} $v');
      }
      for (final o in Wardrobe21.outfits) {
        final id = o['id'] as String;
        expect(File('${layers}top/${id}_$v.svg').existsSync(), outfitHasTop21(id), reason: 'accessoires de $id $v');
      }
    }
    final s = start();
    for (final o in Wardrobe21.outfits) {
      for (final h in Wardrobe21.hairs) {
        for (final v in ['young', 'mature']) {
          final paths = layerPaths21(s, outfitId: o['id'] as String, variant: v, hair: h['id'] as String)!;
          for (final p in paths) {
            expect(File(p).existsSync(), isTrue, reason: p);
          }
        }
      }
    }
  });

  test('catalogues : identifiants uniques, zones connues, prix et rangs cohérents', () {
    final ids = [...Wardrobe21.hairs, ...Wardrobe21.tattoos].map((e) => e['id']).toList();
    expect(ids.toSet().length, ids.length);
    expect(Wardrobe21.hairs.first['id'], 'hitwist');
    expect(Wardrobe21.hairs.first['price'], 0);
    expect(Wardrobe21.tattoos.every((t) => Wardrobe21.tattooZones.containsKey(t['zone'])), isTrue);
    expect([...Wardrobe21.hairs, ...Wardrobe21.tattoos].every((e) => (e['price'] as num) >= 0 && (e['rank'] as num) >= 1 && (e['rank'] as num) <= 5), isTrue);
  });

  test('coiffure : achat, équipement automatique, refus (rang, cash, déjà possédée), confirmation dès 15 000', () {
    var s = start();
    expect([hairOf21(s), hairsOwned21(s)], ['hitwist', ['hitwist']]);
    final c0 = s['cash'] as num;
    s = must(s, 'cbuy', 'fade');
    expect([hairOf21(s), s['cash']], ['fade', c0 - 1500]);
    expect(hairsOwned21(s), containsAll(['hitwist', 'fade']));
    expect(act21(s, 'cbuy', 'fade').err, 'deja');
    expect(act21(s, 'cbuy', 'hightop').err, 'rang');
    expect(act21(clone21(s)..['cash'] = 100, 'cbuy', 'afro').err, 'cash');
    expect(act21(s, 'cbuy', 'nimporte').err, 'inconnu');
    s = must(s, 'ceq', 'hitwist');
    expect(hairOf21(s), 'hitwist');
    expect(act21(s, 'ceq', 'afro').err, 'pasachete');

    s['rank'] = 4;
    expect(act21(s, 'cbuy', 'locks').err, 'confirm');
    s = must(s, 'cask', 'locks');
    final cash = s['cash'] as num;
    s = must(s, 'cconfirm');
    expect([hairOf21(s), s['cash']], ['locks', cash - 20000]);
    expect((s['wd'] as J)['cask'], isNull);

    final t = must(must(start()..['rank'] = 4, 'cask', 'locks'), 'ccancel');
    expect((t['wd'] as J)['cask'], isNull);
    expect(act21(t, 'cconfirm').err, 'rien');
  });

  test('tatouages : un par zone, remplacement, retrait sans perte, rang et cash', () {
    var s = start();
    expect(tattoosOf21(s), isEmpty);
    s = must(s, 'cbuy', 'main_phalanges');
    expect(tattoosOf21(s), {'mains': 'main_phalanges'});
    s = must(s, 'cbuy', 'cou_bande');
    expect(tattoosOf21(s), {'mains': 'main_phalanges', 'cou': 'cou_bande'});
    expect(act21(s, 'cbuy', 'main_cauri').err, 'rang');

    s['rank'] = 2;
    s = must(s, 'cbuy', 'main_cauri');
    expect(tattoosOf21(s)['mains'], 'main_cauri'); // remplace la zone
    s = must(s, 'ceq', 'main_phalanges');
    expect(tattoosOf21(s)['mains'], 'main_phalanges');
    final cash = s['cash'];
    s = must(s, 'tclear', 'mains');
    expect(tattoosOf21(s).containsKey('mains'), isFalse);
    expect(s['cash'], cash); // pas de remboursement ni de coût
    expect(tattoosOwned21(s), containsAll(['main_phalanges', 'main_cauri', 'cou_bande']));
    expect(act21(s, 'tclear', 'nimporte').err, 'inconnu');
    s = must(s, 'tclear', 'visage'); // zone vide : sans effet

    s['rank'] = 3;
    expect(act21(s, 'cbuy', 'vis_etoile').err, 'confirm'); // 15 000
    s = must(must(s, 'cask', 'vis_etoile'), 'cconfirm');
    expect(tattoosOf21(s)['visage'], 'vis_etoile');
  });

  test('la coiffure choisie à la création est offerte et équipée ; une ancienne sauvegarde sans ces clés fonctionne', () {
    var s = init21();
    s = must(s, 'ap', 'hair=afro');
    expect([hairOf21(s), hairsOwned21(s)], ['afro', containsAll(['hitwist', 'afro'])]);

    final old = clone21(start());
    for (final k in ['hair', 'hairs', 'tat', 'tats', 'cask']) {
      (old['wd'] as J).remove(k);
    }
    expect([hairOf21(old), tattoosOf21(old), tattoosOwned21(old)], ['hitwist', isEmpty, isEmpty]);
    final bought = must(old, 'cbuy', 'fade');
    expect(hairOf21(bought), 'fade');
    expect(tattoosOf21(must(old, 'cbuy', 'cou_bande')), {'cou': 'cou_bande'});
  });

  test('couche d\'affichage : ordre des calques et accessoires de tête', () {
    final s = start();
    final p = layerPaths21(s, outfitId: 'OUTFIT_001', variant: 'young', hair: 'afro', tats: {'cou': 'cou_bande'})!;
    expect(p.map((e) => e.split('layers/').last).toList(), [
      'body/OUTFIT_001.svg',
      'hairback/afro_young.svg',
      'head/young.svg',
      'tat/cou_bande_young.svg',
      'hairfront/afro_young.svg',
    ]);
    final q = layerPaths21(s, outfitId: 'OUTFIT_030', variant: 'mature', hair: 'fade', tats: {})!;
    expect(q.last, endsWith('layers/top/OUTFIT_030_mature.svg'));
    expect(layerPaths21(s, outfitId: 'OUTFIT_INCONNUE'), isNull);
  });

  test('en prison : achat refusé, annulation possible', () {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['jail'] = {'until': (s['day'] as num) + 5, 'days': 5};
    expect(act21(s, 'cbuy', 'fade').err, 'prison');
    expect(act21(s, 'ccancel').err, isNull);
  });
}
