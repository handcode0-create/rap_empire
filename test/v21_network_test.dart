import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart' show J;

/// Espace Réseau v21 (21-N0 à 21-N8) : mêmes règles que le bloc « Réseau, marketing, médias en concert, public » de
/// docs/design-ref/v21/sources/test21.js. Valeurs provisoires (D-08).
J _ok(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

J _copy(J s) => jsonDecode(jsonEncode(s)) as J;

void main() {
  test('Klipo : 50 vidéos, identifiants uniques, miniatures présentes et sans texte SVG', () {
    expect(klipo21.length, 50);
    expect(klipo21.map((k) => k['id']).toSet().length, 50);
    for (final k in klipo21) {
      final f = File(k['img'] as String);
      expect(f.existsSync(), isTrue, reason: '${k['img']}');
      expect(f.readAsStringSync().contains('<text'), isFalse, reason: '${k['img']}');
    }
    for (var i = 1; i <= myThumbs21; i++) {
      expect(File('assets/klipo/mine/M$i.svg').existsSync(), isTrue);
    }
    for (var i = 1; i <= 4; i++) {
      expect(File('assets/klipo/crowd/crowd_$i.svg').existsSync(), isTrue);
    }
  });

  test('campagnes : verrous de rang, achat local direct, doublon refusé, effets quotidiens puis fin', () {
    final s = act21(init21(), 'preset', 'debut').s;
    expect(act21(s, 'mkbuy', 'bktv').err, 'rang');
    expect(act21(s, 'mkbuy', 'tamtv').err, 'rang');
    final c0 = s['cash'] as num;
    final a = _ok(s, 'mkbuy', 'lagune');
    expect(a['cash'], c0 - 5000);
    expect(act21(a, 'mkbuy', 'lagune').err, 'campagne');
    final b0 = (a['geo'] as Map)['bakoma'] as num, f0 = a['fans'] as num;
    var d = _ok(a, 'endDay');
    expect((d['geo'] as Map)['bakoma'] as num, greaterThan(b0));
    expect(d['fans'] as num, greaterThanOrEqualTo(f0 + 15));
    for (var i = 0; i < 7; i++) {
      d = _ok(d, 'endDay');
    }
    expect((d['mk'] as Map)['on'], isEmpty);
  });

  test('achat de 15 000 et plus : confirmation obligatoire (I-08), puis sponsor visible', () {
    var st = act21(init21(), 'preset', 'star').s;
    expect(act21(st, 'mkbuy', 'bktv').err, 'confirm');
    final c0 = st['cash'] as num;
    st = _ok(_ok(st, 'mkask', 'bktv'), 'mkconfirm');
    expect(st['cash'], c0 - 40000);
    expect(mkSponsor21(st), 'bktv');
    expect(act21(_ok(st, 'mkcancel'), 'mkconfirm').err, 'rien');
  });

  test('concert : média partenaire et bonus de cachet, image du public selon le remplissage', () {
    var st = act21(init21(), 'preset', 'star').s;
    st = _ok(_ok(st, 'mkask', 'bktv'), 'mkconfirm');
    final cs = _copy(st)
      ..['hour'] = 10
      ..['en'] = 100;
    final r = _ok(cs, 'concert');
    final cc = r['cc'] as Map;
    expect(cc['media'], 'bktv');
    expect(cc['spon'] as num, greaterThan(0));
    expect(crowdAsset21((cc['fill'] as num) / 100), matches(RegExp(r'crowd_[1-4]\.svg$')));
    expect(crowdLevel21(0.1), 1);
    expect(crowdLevel21(0.3), 2);
    expect(crowdLevel21(0.6), 3);
    expect(crowdLevel21(0.9), 4);
  });

  test('notoriété Local, National, Global ; sélection de clip et de vidéo ; index hors limites', () {
    final st = act21(init21(), 'preset', 'star').s;
    final nt = notoriety21(st);
    expect(nt.global, lessThan(nt.national));
    expect(nt.national, lessThan(nt.local));
    expect(myClips21(st), isNotEmpty);
    expect(clipStats21(myClips21(st).first, 0).img, 'assets/klipo/mine/M1.svg');
    expect(clipStats21(myClips21(st).first, 1).img, 'assets/klipo/mine/M2.svg');
    expect(_ok(st, 'kv', 4)['kv'], 4);
    expect(klipo21[4]['t'], 'Verre Bleu');
    expect(act21(st, 'kv', 50).err, 'inconnu');
    expect(act21(st, 'mcl', 9).err, 'inconnu');
    expect(_ok(st, 'mcl', 0)['mcl'], 0);
  });

  test('bonus d\'écoutes : une sortie pendant une campagne gagne le bonus annoncé', () {
    final st = act21(init21(), 'preset', 'star').s;
    expect(mkBoost21(st), 0);
    final b = _ok(_ok(st, 'mkask', 'bktv'), 'mkconfirm');
    expect(mkBoost21(b), closeTo(0.15, 1e-9));
  });

  test('anciennes sauvegardes : l\'état Réseau est ajouté sans erreur', () {
    final old = act21(init21(), 'preset', 'debut').s..remove('mk');
    final n = norm21(_copy(old));
    expect(n['mk'], isA<Map>());
    expect(mkActive21(n), isEmpty);
    expect(fmtK21(41200000), '41,2 M');
    expect(fmtK21(12000000), '12 M');
    expect(fmtK21(960000), '960 k');
  });

  test('réseaux sociaux : trois réseaux fictifs, publication, limite de trois par jour, conditions', () {
    expect(socialOrder21, ['lueur', 'bakoz', 'griot']);
    var s = act21(init21(), 'preset', 'debut').s;
    expect(followers21(s, 'lueur'), ((s['fans'] as num) * 0.5 + 0.5).floor());
    expect(act21(s, 'post', 'extrait').err, 'single');
    expect(act21(s, 'post', 'coulisses').err, 'pasdeconcert');
    expect(act21(s, 'post', 'inconnu').err, 'inconnu');
    final f0 = s['fans'] as num, l0 = followers21(s, 'lueur');
    s = _ok(s, 'post', 'photo');
    final p = postsOf21(s, 'lueur').first;
    expect(p['reach'] as num, greaterThan(0));
    expect(s['fans'] as num, f0 + (p['fg'] as num));
    expect(followers21(s, 'lueur'), l0 + (p['nf'] as num));
    expect(postsLeft21(s), 2);
    s = _ok(s, 'post', 'merci');
    s = _ok(s, 'post', 'look');
    expect(postsLeft21(s), 0);
    expect(act21(s, 'post', 'photo').err, 'postjour');
    final d = _ok(s, 'endDay');
    expect(postsLeft21(d), 3);
    expect(buzz21(d), lessThan(buzz21(s)));
  });

  test('réseaux sociaux : l\'annonce prépare une sortie (bonus existant de 20 %), le clash touche la réputation', () {
    var s = act21(init21(), 'preset', 'star').s;
    final withCur = _copy(s)..['cur'] = {'title': 'Nouveau son', 'st': 'ecrit', 'feats': []};
    final a = _ok(withCur, 'post', 'annonce');
    expect(a['hype'], (a['day'] as num) + 3);
    final r0 = s['rep'] as num;
    s = _ok(s, 'post', 'clash');
    final c = postsOf21(s, 'griot').first;
    expect(s['rep'], (c['polem'] as num) == 1 ? r0 - 2 : r0 + 1);
    expect((c['c'] as List).length, 2);
  });
}
