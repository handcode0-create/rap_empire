import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Parité du moteur Dart avec le moteur de référence engine21.js.
/// Les scénarios sont produits par `node tool/gen_parity21.js` (test/fixtures/parity21.json) : mêmes états de départ,
/// mêmes actions, mêmes codes d'erreur et mêmes valeurs observées après chaque pas.

dynamic at(dynamic o, String path) {
  var v = o;
  for (final k in path.split('.')) {
    if (v == null) return null;
    if (v is List) {
      final i = int.tryParse(k);
      v = (i == null || i >= v.length) ? null : v[i];
    } else if (v is Map) {
      v = v[k];
    } else {
      return null;
    }
  }
  return v;
}

void put(J o, String path, dynamic val) {
  final ks = path.split('.');
  dynamic v = o;
  for (var i = 0; i < ks.length - 1; i++) {
    v[ks[i]] ??= <String, dynamic>{};
    v = v[ks[i]];
  }
  v[ks.last] = jsonDecode(jsonEncode(val));
}

/// Égalité profonde : les nombres se comparent par valeur (12 == 12.0), `null` et `0`/`false` restent distincts.
String? diff(dynamic want, dynamic got, String where) {
  if (want == null || got == null) return want == null && got == null ? null : '$where : attendu $want, obtenu $got';
  if (want is num && got is num) return (want - got).abs() < 1e-9 ? null : '$where : attendu $want, obtenu $got';
  if (want is Map && got is Map) {
    for (final k in {...want.keys, ...got.keys}) {
      final d = diff(want[k], got[k], '$where.$k');
      if (d != null) return d;
    }
    return null;
  }
  if (want is List && got is List) {
    if (want.length != got.length) return '$where : ${want.length} éléments attendus, ${got.length} obtenus ($want / $got)';
    for (var i = 0; i < want.length; i++) {
      final d = diff(want[i], got[i], '$where[$i]');
      if (d != null) return d;
    }
    return null;
  }
  return want == got ? null : '$where : attendu $want, obtenu $got';
}

void main() {
  final fx = jsonDecode(File('test/fixtures/parity21.json').readAsStringSync()) as Map<String, dynamic>;
  final scenarios = (fx['scenarios'] as List).cast<Map<String, dynamic>>();

  for (final sc in scenarios) {
    test('parité · ${sc['name']}', () {
      J s = sc['start'] == 'init' ? init21() : act21(init21(), 'preset', sc['start']).s;
      (sc['patch'] as Map<String, dynamic>).forEach((k, v) => put(s, k, v));
      // Systèmes ajoutés après engine21.js (intérêt des labels, problèmes de début de carrière) : neutralisés ici
      // pour comparer les règles communes. Ils ont leurs propres tests (v21_career_test.dart).
      s['lbz'] = Reg21.lbzMax;
      s['evDone'] = <String, dynamic>{...(s['evDone'] as Map<String, dynamic>? ?? const {}), for (final p in problemOrder21) p: 'parite'};
      final watch = (sc['watch'] as List).cast<String>();
      var i = 0;
      for (final st in (sc['steps'] as List).cast<Map<String, dynamic>>()) {
        i++;
        final a = st['a'] as String;
        final label = 'pas $i ($a ${jsonEncode(st['g'])})';
        if (a == '@patch') {
          (st['g'] as Map<String, dynamic>).forEach((k, v) => put(s, k, v));
        } else if (a != '@init') {
          final r = act21(s, a, st['g']);
          expect(r.err, st['err'], reason: '$label : code d\'erreur');
          s = r.s;
        }
        final out = st['out'] as Map<String, dynamic>;
        for (final w in watch) {
          final d = diff(out[w], at(s, w), w);
          expect(d, isNull, reason: '$label · $d');
        }
      }
    });
  }

  test('plateformes fictives : Ondéa 70 %, Cauri Music 30 %, aucune marque réelle', () {
    final p = platformSplit21(10001);
    expect([p.ondea, p.cauri], [7001, 3000]);
    final names = Reg21.platforms.values.map((e) => e['n']).join(' ');
    expect(names, 'Ondéa Cauri Music Klipo');
  });

  test('anciennes sauvegardes : manager, détention et battle sont migrés', () {
    final old = init21()
      ..['mg'] = 1
      ..['mgLevel'] = 'm2'
      ..['jail'] = 3
      ..['battlePending'] = 1
      ..['charges'] = {'days': 2};
    old['day'] = 10;
    final r = act21(old, 'job', 'livraison');
    expect(r.err, 'prison');
    final s = norm21(old);
    expect([s['mgr'], s.containsKey('mg'), s['btq'], s.containsKey('battlePending'), s.containsKey('charges')], ['m2', false, 'kzer', false, false]);
    expect(s['jail'], {'until': 13, 'days': 3});
  });
}
