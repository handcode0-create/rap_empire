import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart';
import 'package:rap_empire/features/v21/child_space_screens.dart';

J must(J s, String name, [dynamic arg]) {
  final r = act21(s, name, arg);
  expect(r.err, isNull, reason: '$name $arg');
  return r.s;
}

J kid(J s) => ((s['fam'] as J)['kids'] as List)[0] as J;

void main() {
  J parent() => act21(init21(), 'preset', 'parent').s;

  test('un moment ensemble développe une facette et laisse un souvenir', () {
    var s = parent();
    s = must(s, 'kid', ['0', 'jouer']);
    final k = kid(s);
    expect((k['dev'] as J)['eveil'], 4);
    expect((k['mem'] as List).length, 1);
    expect(((k['mem'] as List)[0] as J)['t'], contains('Jouer ensemble'));
    expect(k['l'], 61);
  });

  test('les souvenirs sont plafonnés', () {
    var s = parent();
    s['hour'] = 8;
    final k = kid(s);
    for (var i = 0; i < Reg21.kidMemMax + 3; i++) {
      (k['mem'] ??= <dynamic>[]);
      s['en'] = 100;
      s['hour'] = 8;
      s = must(s, 'kid', ['0', 'jouer']);
    }
    expect((kid(s)['mem'] as List).length, Reg21.kidMemMax);
    expect((kid(s)['dev'] as J)['eveil'], 4 * (Reg21.kidMemMax + 3));
  });

  test('garde : nounou pour un bébé, école interdite avant 3 ans, pas deux fois la même', () {
    var s = parent();
    expect(act21(s, 'kgarde', ['0', 'École']).err, 'age');
    expect(act21(s, 'kgarde', ['0', 'Au foyer']).err, 'deja');
    expect(act21(s, 'kgarde', ['0', 'Crèche']).err, 'inconnu');
    expect(kidGardeCost21(kid(s)), 0);
    s = must(s, 'kgarde', ['0', 'Nounou']);
    expect(kid(s)['garde'], 'Nounou');
    expect(kidGardeCost21(kid(s)), 800);
    expect(((kid(s)['mem'] as List)[0] as J)['t'], 'Garde : Nounou');
  });

  test('la garde est facturée chaque jour et supprime la fatigue du bébé', () {
    final a = must(parent(), 'endDay');
    var b = must(parent(), 'kgarde', ['0', 'Nounou']);
    b = must(b, 'endDay');
    expect((a['cash'] as num) - (b['cash'] as num), 800);
    expect((b['en'] as num) - (a['en'] as num), Reg21.babyMorning);
  });

  test('l’école fait progresser le savoir chaque jour', () {
    var s = parent();
    kid(s)['born'] = 400 - 4 * Reg21.daysPerYear;
    s = must(s, 'kgarde', ['0', 'École']);
    s = must(s, 'endDay');
    s = must(s, 'endDay');
    expect((kid(s)['dev'] as J)['savoir'], 2 * Reg21.schoolDaily);
  });

  test('portraits uniques : chaque enfant a ses fichiers pour les trois étapes, trois humeurs, deux cadrages', () {
    for (final id in KidPortrait21.known) {
      for (final st in ['bebe', 'enfant', 'ado']) {
        for (final m in ['neutral', 'smile', 'laugh']) {
          for (final c in ['head', 'bust']) {
            expect(File('assets/characters/kid_${id}_${st}_${m}_$c.svg').existsSync(), isTrue, reason: '$id $st $m $c');
          }
        }
      }
    }
    expect(File('assets/characters/kid_nayla_enfant_smile_bust.svg').readAsStringSync(), isNot(File('assets/characters/kid_kenzo_enfant_smile_bust.svg').readAsStringSync()));
    expect(KidPortrait21.stage(0), 'bebe');
    expect(KidPortrait21.stage(6), 'enfant');
    expect(KidPortrait21.stage(12), 'ado');
    expect(KidPortrait21.mood(80, false), 'laugh');
    expect(KidPortrait21.mood(50, false), 'smile');
    expect(KidPortrait21.mood(10, true), 'laugh');
    expect(KidPortrait21.mood(10, false), 'neutral');
  });

  group('identité du label', () {
    J rich() {
      final s = act21(init21(), 'preset', 'carriere').s;
      s['rank'] = 4;
      s['cash'] = 2000000;
      s['signed'] = 0;
      return s;
    }

    test('nom et logo choisis à la fondation', () {
      final s = must(rich(), 'olabel', {'name': '  Ndo   Records ', 'logo': 'flamme'});
      final ol = s['olabel'] as J;
      expect(ol['name'], 'Ndo Records');
      expect(ol['logo'], 'flamme');
      expect(ownLabelName21(s), 'Ndo Records');
    });

    test('nom invalide ou logo inconnu refusés, sans rien payer', () {
      final s = rich();
      expect(act21(s, 'olabel', {'name': 'X', 'logo': 'flamme'}).err, 'nomlabel');
      expect(act21(s, 'olabel', {'name': 'Ndo <b>', 'logo': 'flamme'}).err, 'nomlabel');
      expect(act21(s, 'olabel', {'name': 'Ndo Records', 'logo': 'dragon'}).err, 'inconnu');
      expect(s['cash'], 2000000);
    });

    test('sans arguments : nom par défaut et premier logo', () {
      final s = must(rich(), 'olabel');
      expect((s['olabel'] as J)['logo'], Reg21.ownLogos.first);
      expect(ownLabelNameOk21((s['olabel'] as J)['name']), isTrue);
    });

    test('renommer et changer de logo, gratuitement', () {
      var s = must(rich(), 'olabel');
      final cash = s['cash'];
      expect(act21(rich(), 'lbrand', {'name': 'Ndo Records', 'logo': 'onde'}).err, 'pasdelabel');
      expect(act21(s, 'lbrand', {'name': '', 'logo': 'onde'}).err, 'nomlabel');
      s = must(s, 'lbrand', {'name': 'Lagune Sons', 'logo': 'onde'});
      expect(ownLabelName21(s), 'Lagune Sons');
      expect((s['olabel'] as J)['logo'], 'onde');
      expect(s['cash'], cash);
    });

    test('les huit logos existent', () {
      expect(Reg21.ownLogos.length, 8);
      for (final id in Reg21.ownLogos) {
        expect(File('assets/logos/own_$id.svg').existsSync(), isTrue, reason: id);
      }
    });
  });
}
