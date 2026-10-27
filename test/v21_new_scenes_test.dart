import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';

/// Une partie avancée : assez de jours, de réputation, de sorties et de cauris pour déclencher chaque scène.
J rich() {
  final s = init21();
  s['day'] = 40;
  s['cash'] = 500000;
  s['fans'] = 2000;
  s['rep'] = 30;
  s['pop'] = 30;
  s['shows'] = 5;
  s['disco'] = [
    {'id': 'a', 'n': 'A'},
    {'id': 'b', 'n': 'B'},
    {'id': 'c', 'n': 'C'},
  ];
  (s['sk'] as Map<String, dynamic>)['ecr'] = 25;
  return s;
}

void main() {
  test('chaque nouvelle scène existe, a un nœud n1 et des suites valides', () {
    for (final id in newSceneOrder21) {
      final d = dlg21[id];
      expect(d, isNotNull, reason: id);
      expect(d!.nodes.containsKey('n1'), isTrue, reason: id);
      expect(dlgOrder21.contains(id), isTrue, reason: id);
      expect(castn21.containsKey(d.who), isTrue, reason: '$id : nom de ${d.who}');
      for (final n in d.nodes.values) {
        expect(n.ch.length, inInclusiveRange(2, 4), reason: id);
        for (final c in n.ch) {
          expect(c.go != null || c.end != null, isTrue, reason: '$id/${c.id}');
          if (c.go != null) expect(d.nodes.containsKey(c.go), isTrue, reason: '$id → ${c.go}');
        }
      }
    }
  });

  test('chaque scène se joue jusqu’au bout par tous ses chemins', () {
    for (final id in newSceneOrder21) {
      void walk(J s, String node, int depth) {
        expect(depth, lessThan(6), reason: id);
        for (final c in dlg21[id]!.nodes[node]!.ch) {
          final r = act21(s, 'dch', c.id);
          expect(r.err, isNull, reason: '$id/$node/${c.id}');
          if (c.go != null) {
            walk(r.s, c.go!, depth + 1);
          } else {
            expect((r.s['dlg'] as Map)['done'], 1, reason: id);
            expect((r.s['dseen'] as Map)[id], c.end, reason: id);
          }
        }
      }

      final s = act21(rich(), 'dstart', id).s;
      walk(s, 'n1', 0);
    }
  });

  test('les scènes arrivent échelonnées : rien au jour 1, toutes en partie avancée', () {
    final early = init21();
    for (final id in newSceneOrder21) {
      expect(dlg21[id]!.cond(early), isFalse, reason: id);
      expect(dlg21[id]!.cond(rich()), isTrue, reason: id);
    }
    final days = newSceneOrder21.map((id) {
      var d = 1;
      while (!dlg21[id]!.cond({...rich(), 'day': d}) && d < 60) {
        d++;
      }
      return d;
    }).toList();
    expect(days.toSet().length, greaterThan(8), reason: 'jours distincts : $days');
  });

  test('un coût annoncé est bien prélevé (séance photo complète)', () {
    var s = act21(rich(), 'dstart', 'photo').s;
    final cash = s['cash'] as num;
    s = act21(s, 'dch', 'a').s;
    expect(s['cash'], cash - 3000);
    expect((s['rel'] as Map)['yao'], 8);
  });

  test('un bonus de compétence « sk.* » s’ajoute à la compétence', () {
    var s = act21(rich(), 'dstart', 'stylist').s;
    final before = (s['sk'] as Map)['cha'] as num;
    s = act21(s, 'dch', 'a').s;
    expect((s['sk'] as Map)['cha'], before + 2);
  });

  test('cash insuffisant : le choix payant est refusé', () {
    final s0 = rich();
    s0['cash'] = 100;
    final r = act21(act21(s0, 'dstart', 'photo').s, 'dch', 'a');
    expect(r.err, isNotNull);
  });
}
