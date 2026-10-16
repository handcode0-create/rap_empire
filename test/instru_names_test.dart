import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/instru_names.dart';
import 'package:rap_empire/domain/music_catalog.dart';
import 'package:rap_empire/domain/clock.dart';
import 'package:rap_empire/domain/studio.dart';

void main() {
  const ids = ['nuit', 'gbaka', 'pont', 'lagune'];

  test('partie de départ : les noms d’origine du prototype', () {
    expect([for (final i in instrusFor(const GameState())) i.name], ['Nuit à Ndo', 'Gbaka de 6h', 'Pont des Griots', "Lagune d'Ambre"]);
  });

  test('les noms changent chaque jour pendant 25 jours', () {
    for (final id in ids) {
      final names = {for (var d = 2; d <= 26; d++) instruName(GameState(day: d), id)};
      expect(names.length, 25, reason: id);
    }
  });

  test('une autre partie, d’autres noms ; même partie et même jour, mêmes noms', () {
    expect(instruName(const GameState(seed: 5), 'gbaka'), isNot('Gbaka de 6h'));
    expect(instruName(const GameState(seed: 5, day: 3), 'pont'), instruName(const GameState(seed: 5, day: 3), 'pont'));
  });

  test('hors partie de départ, les noms viennent uniquement de la bibliothèque d’instrumentales', () {
    const styles = {'nuit': 'boombap', 'gbaka': 'afro', 'pont': 'trap', 'lagune': 'luxury'};
    for (var seed = 0; seed < 40; seed++) {
      for (var day = 1; day < 8; day++) {
        if (seed == 0 && day == 1) continue;
        for (final id in ids) {
          final n = instruName(GameState(seed: seed, day: day), id);
          expect(instrumentalNames(styles[id]!), contains(n), reason: '$id : $n');
        }
      }
    }
  });

  test('chaque style a 10 noms et les 15 noms français sont ajoutés', () {
    for (final s in instrumentalLibrary) {
      expect(s.names.length, 10, reason: s.id);
      expect(instrumentalNames(s.id).length, 25);
    }
    expect(frenchInstrumentals.length, 15);
  });

  test('qualité, prix, producteur et niveau ne changent pas', () {
    final a = instrusFor(const GameState()), b = instrusFor(const GameState(seed: 9, day: 4));
    for (var i = 0; i < a.length; i++) {
      expect([b[i].id, b[i].q, b[i].price, b[i].who, b[i].lvl, b[i].rep], [a[i].id, a[i].q, a[i].price, a[i].who, a[i].lvl, a[i].rep]);
    }
  });

  test('aucun nom réel : ni ville ni indicatif de la note d’origine', () {
    final all = [for (final s in instrumentalLibrary) ...s.names, ...frenchInstrumentals];
    expect(all.any((n) => n.contains('Abidjan') || n.contains('225')), isFalse);
  });

  test('dix thèmes, dont les trois exemples chacun', () {
    expect(musicThemes.length, 10);
    for (final t in musicThemes) {
      expect(t.examples.length, 3, reason: t.id);
    }
  });

  group('morceau en cours', () {
    test('le nom de l’instru choisie ne change pas quand le jour change', () {
      final picked = pick(const GameState(seed: 7, day: 3), 'gbaka');
      final name = picked.instName!;
      final later = sleep(picked);
      expect(instruName(later, 'gbaka'), isNot(name));
      expect(instruChosen(later).name, name);
      expect(record(write(later), [74, 48, 43]).song!.inst, name);
    });
    test('le son garde son thème, son style et son potentiel viral', () {
      final s = record(write(pick(const GameState(), 'lagune'.replaceAll('lagune', 'nuit')), theme: 'ego'), [74, 48, 43]).song!;
      expect([s.theme, s.style], ['ego', 'boombap']);
      expect(s.viral, (s.q * 0.9 + 10).round());
    });
    test('thème qui ne va pas avec le style : pas de bonus', () {
      final s = record(write(pick(const GameState(), 'nuit'), theme: 'fete'), [74, 48, 43]).song!;
      expect(s.viral, (s.q * 0.9).round());
    });
    test('sauvegarde : aller-retour du nom choisi et du son', () {
      final s = record(write(pick(const GameState(), 'nuit'), theme: 'ego'), [74, 48, 43]);
      final back = GameState.fromJson(s.toJson());
      expect([back.instName, back.song!.style, back.song!.viral], [s.instName, 'boombap', s.song!.viral]);
    });
  });
}
