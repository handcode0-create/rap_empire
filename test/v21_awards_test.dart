import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Certifications et cérémonies (propositions 18.4 et 18.5, valeurs provisoires).
J _copy(J s) => jsonDecode(jsonEncode(s)) as J;

void main() {
  test('illustrations générées : plaques et trophées présents, sans texte SVG', () {
    for (final f in [
      for (final l in [...certLevels21, 'vide']) 'assets/awards/plaque_$l.svg',
      for (final c in ceremonies21) c.trophy,
      'assets/awards/trophee_vide.svg',
    ]) {
      final file = File(f);
      expect(file.existsSync(), isTrue, reason: f);
      expect(file.readAsStringSync().contains('<text'), isFalse, reason: f);
    }
  });

  test('certification : paliers croissants, unités et palier suivant', () {
    for (final th in certThresholds21.values) {
      for (var i = 1; i < th.length; i++) {
        expect(th[i], greaterThan(th[i - 1]));
      }
    }
    final s = act21(init21(), 'preset', 'star').s;
    final t = (s['disco'] as List).first as J;
    final big = _copy(s);
    ((big['disco'] as List).first as J)['L'] = 3000000;
    final c = certs21(big).firstWhere((x) => x.id == t['id']);
    expect(c.level, greaterThanOrEqualTo(0));
    expect(c.units, singleUnits21(big, (big['disco'] as List).first as J));
    expect(c.plaque, 'assets/awards/plaque_${c.levelId}.svg');
    final none = _copy(s);
    for (final d in (none['disco'] as List)) {
      (d as J)['L'] = 10;
      d['clipL'] = 0;
      d['sales'] = 0;
    }
    expect(certCount21(none), 0);
    expect(certs21(none).first.plaque, 'assets/awards/plaque_vide.svg');
  });

  test('certification annoncée une seule fois et jamais retirée', () {
    var s = act21(init21(), 'preset', 'star').s;
    ((s['disco'] as List).first as J)['L'] = 3000000;
    s = act21(s, 'endDay').s;
    final id = ((s['disco'] as List).first as J)['id'];
    final lv = (s['certSeen'] as Map)[id] as num;
    expect(lv, greaterThanOrEqualTo(0));
    final logs0 = (s['log'] as List).where((l) => '${(l as Map)['t']}'.startsWith('Certification')).length;
    s = act21(s, 'endDay').s;
    expect((s['log'] as List).where((l) => '${(l as Map)['t']}'.startsWith('Certification')).length, logs0);
    expect((s['certSeen'] as Map)[id], lv);
  });

  test('cérémonies : calendrier, éligibilité, au plus 3 victoires, une seule fois par an', () {
    expect(ceremonies21.map((c) => c.week).toList(), [43, 45, 47, 52]);
    expect(weekOf21(1), 1);
    expect(weekOf21(Reg21.daysPerYear), 52);
    expect(yearOf21(Reg21.daysPerYear + 1), 2);
    final debut = act21(init21(), 'preset', 'debut').s;
    expect(awardScore21(debut, ceremonies21[3], ceremonies21[3].cats.first), isNull); // aucun titre : pas éligible
    var s = act21(init21(), 'preset', 'star').s;
    s['day'] = 42 * 7; // fin de semaine 42
    s['hour'] = 8;
    s = act21(s, 'endDay').s; // semaine 43 : Coupe Révélation
    final aw = s['aw'] as Map;
    expect((aw['done'] as Map).keys, contains('1-revelation'));
    final h0 = (aw['hist'] as List).length;
    expect(h0, lessThanOrEqualTo(2));
    s = act21(s, 'endDay').s;
    expect(((s['aw'] as Map)['hist'] as List).length, h0); // pas deux fois la même année
    for (final c in ceremonies21) {
      final r = ceremonyResults21(s, c);
      expect(r.values.where((x) => x == 'win').length, lessThanOrEqualTo(3));
    }
    final (next, days) = nextCeremony21(s);
    expect(next.id, 'rue');
    expect(days, greaterThan(0));
  });

  test('une nomination rapporte de la réputation (une défaite n\'est pas purement négative)', () {
    var s = act21(init21(), 'preset', 'star').s;
    s['rep'] = 90;
    s['pop'] = 80;
    s['day'] = 51 * 7;
    s['hour'] = 8;
    final r0 = s['rep'] as num;
    s = act21(s, 'endDay').s; // semaine 52 : toutes les cérémonies de l'année passent
    final hist = ((s['aw'] as Map)['hist'] as List).cast<Map>();
    expect(hist, isNotEmpty);
    final gain = hist.fold<num>(0, (a, h) => a + (h['res'] == 'win' ? 2 * ceremonies21.firstWhere((c) => c.id == h['c']).prestige : 1));
    expect(s['rep'], r0 + gain);
    expect(awardWins21(s) + awardNoms21(s), hist.length);
  });

  test('annonces : une par certification ou cérémonie, retirées une à une (awseen)', () {
    var s = act21(init21(), 'preset', 'star').s;
    expect(act21(s, 'awseen').err, 'rien');
    ((s['disco'] as List).first as J)['L'] = 3000000;
    s = act21(s, 'endDay').s;
    final news = s['awNews'] as List;
    expect(news, isNotEmpty);
    expect((news.first as Map)['k'], 'cert');
    final n0 = news.length;
    s = act21(s, 'awseen').s;
    expect((s['awNews'] as List).length, n0 - 1);
  });

  test('nominations figées en semaine 41, puis résultats limités aux catégories nommées', () {
    var s = act21(init21(), 'preset', 'star').s;
    s['rep'] = 90;
    s['pop'] = 80;
    s['day'] = 40 * 7; // fin de semaine 40
    s['hour'] = 8;
    s = act21(s, 'endDay').s; // semaine 41
    final frozen = frozenNominations21(s)!;
    expect(((s['awNews'] as List).last as Map)['k'], 'nom');
    expect((((s['awNews'] as List).last as Map)['cats'] as List).length, frozen.length);
    for (final c in ceremonies21) {
      final r = ceremonyResults21(s, c, frozen);
      for (final cat in c.cats) {
        if (!frozen.contains('${c.id}-${cat.id}')) expect(r[cat.id], isNull);
      }
      expect(ceremonyResults21(s, c, const <String>{}).values.every((v) => v == null), isTrue);
    }
    final again = act21(s, 'endDay').s; // pas de seconde annonce la même année
    expect((again['awNews'] as List).where((x) => (x as Map)['k'] == 'nom').length, 1);
  });
}
