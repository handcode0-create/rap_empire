import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/domain/v21/view21.dart';

/// Classements simulés semaine après semaine et playlists Ondéa avec leurs curateurs (valeurs provisoires).
J _copy(J s) => jsonDecode(jsonEncode(s)) as J;

void main() {
  test('classements : dix lignes, ordre décroissant, et ils changent d\'une semaine à l\'autre', () {
    for (final b in chartBoards()) {
      final w1 = chart21(b, 100), w2 = chart21(b, 107), w9 = chart21(b, 160);
      expect(w1.length, 10, reason: b);
      for (var i = 1; i < w1.length; i++) {
        expect(w1[i - 1].value, greaterThanOrEqualTo(w1[i].value), reason: b);
      }
      expect(chart21(b, 100).map((r) => r.t).toList(), w1.map((r) => r.t).toList(), reason: 'déterministe');
      final same = [for (var i = 0; i < 10; i++) w1[i].t == w9[i].t && w1[i].a == w9[i].a].where((x) => x).length;
      expect(same, lessThan(10), reason: '$b : la tête change');
      if (b == 'singles' || b == 'global') expect(w2.any((r) => r.mv != '='), isTrue, reason: '$b : des mouvements chaque semaine');
    }
    // un titre de la semaine 2 était-il déjà là ? sinon NEW
    final rows = chart21('singles', 200);
    expect(rows.where((r) => r.mv == 'NEW' || r.prev != null).length, rows.length);
  });

  test('curateurs : identité fixe (personnage illustré) pour chaque playlist', () {
    for (final p in playlists21) {
      for (final crop in ['head', 'bust', 'torso']) {
        expect(File('assets/characters/${p.curator}_poised_$crop.svg').existsSync(), isTrue, reason: '${p.curator} $crop');
      }
    }
    expect(playlists21.map((p) => p.curator).toSet().length, playlists21.length);
  });

  test('proposer un titre : coût, verdict selon le score, placement ou attente', () {
    var s = act21(init21(), 'preset', 'star').s;
    s['hour'] = 8;
    s['en'] = 100;
    final t = (s['disco'] as List).first as J;
    expect(act21(s, 'plpitch', ['zzz', t['id'], 'son']).err, 'inconnu');
    expect(act21(s, 'plpitch', ['drill', 'T999', 'son']).err, 'pasdetitre');
    final poor = _copy(s)..['cash'] = 100;
    expect(act21(poor, 'plpitch', ['drill', t['id'], 'promo']).err, 'cash');
    final p = playlist21('talents')!;
    final sc = pitchScore21(s, p, t, 'promo');
    final c0 = s['cash'] as num;
    s = act21(s, 'plpitch', ['talents', t['id'], 'promo']).s;
    expect(s['cash'], c0 - 5000);
    final last = (s['pl'] as Map)['last'] as Map;
    expect(last['ok'], sc.total >= p.threshold ? 1 : 0);
    if (last['ok'] == 1) {
      expect(placement21(s, 'talents'), isNotNull);
      expect(act21(s, 'plpitch', ['talents', t['id'], 'son']).err, 'deja');
      s = act21(s, 'endDay').s;
      final t2 = (s['disco'] as List).firstWhere((x) => (x as Map)['id'] == t['id']) as J;
      expect(t2['plL'], playlistDaily21(p, t)); // écoutes de playlist du premier jour
      expect(platformListens(t2), greaterThanOrEqualTo(platformListens(t) + playlistDaily21(p, t)));
      for (var i = 0; i < playlistDays21; i++) {
        s = act21(s, 'endDay').s;
      }
      expect(placement21(s, 'talents'), isNull);
    } else {
      expect(cooldown21(s, 'talents'), isNotNull);
      expect(act21(s, 'plpitch', ['talents', t['id'], 'son']).err, 'delai');
    }
  });

  test('score : style attendu, qualité et présentation comptent', () {
    final s = act21(init21(), 'preset', 'star').s;
    final t = (s['disco'] as List).first as J;
    final drill = playlist21('drill')!, afro = playlist21('afro')!;
    (s['p'] as Map)['main'] = 'drill';
    expect(pitchScore21(s, drill, t, 'son').fit, 15);
    expect(pitchScore21(s, afro, t, 'son').fit, 0);
    expect(pitchScore21(s, drill, t, 'promo').approach, 12);
    final better = _copy(t)..['Q'] = (t['Q'] as num) + 20;
    expect(pitchScore21(s, drill, better, 'son').q, greaterThan(pitchScore21(s, drill, t, 'son').q));
    expect(Reg21.styles.keys, containsAll(drill.styles));
  });
}

List<String> chartBoards() => const ['singles', 'albums', 'eps', 'global'];
