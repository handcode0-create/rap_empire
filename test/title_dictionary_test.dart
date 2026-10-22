import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/title_bank.dart';
import 'package:rap_empire/domain/title_dictionary.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart' show J;

/// Dictionnaire de 5 000 titres (singles par thème, EP, albums) : volume, unicité, longueur, déterminisme, non-répétition, moteur.
void main() {
  final all = <String>[
    for (final l in titleBankSingles.values) ...l,
    ...titleBankEp,
    ...titleBankAlbum,
  ];

  group('le dictionnaire', () {
    test('5 000 titres : 4 400 singles (440 par thème), 300 EP, 300 albums', () {
      expect(titleDictionarySize, 5000);
      expect(titleBankSingles.length, 10);
      for (final e in titleBankSingles.entries) {
        expect(e.value.length, 440, reason: e.key);
      }
      expect(titleBankEp.length, 300);
      expect(titleBankAlbum.length, 300);
    });

    test('tous uniques (casse et apostrophes ignorées), de 3 à 30 caractères', () {
      expect({for (final t in all) titleKey(t)}.length, all.length);
      for (final t in all) {
        expect(t.length, inInclusiveRange(3, 30), reason: t);
        expect(t, t.trim());
        expect(t[0], t[0].toUpperCase(), reason: t);
      }
    });

    test('pas de mot collé en double ni de gabarit non résolu', () {
      for (final t in all) {
        expect(RegExp(r'\b(\w+) \1\b', caseSensitive: false).hasMatch(t), isFalse, reason: t);
        expect(t.contains(RegExp(r'[{}$]|  ')), isFalse, reason: t);
        expect(t.contains(' le le ') || t.contains(' de de ') || t.contains('à le ') || t.contains('de le '), isFalse, reason: t);
      }
    });

    test('monde fictif : aucun lieu ni nom réel connu', () {
      const real = ['abidjan', 'paris', 'dakar', 'lagos', 'accra', 'afrique', 'france', 'nike', 'gucci', 'drake', 'rolex', 'kanye'];
      for (final t in all) {
        for (final r in real) {
          expect(t.toLowerCase().contains(r), isFalse, reason: '$t / $r');
        }
      }
    });
  });

  group('pickTitle et titleIdeas', () {
    test('même graine, même titre ; le thème est respecté', () {
      expect(pickTitle(7, theme: 'amour'), pickTitle(7, theme: 'amour'));
      expect(titleBankSingles['amour'], contains(pickTitle(7, theme: 'amour')));
      expect(titleBankEp, contains(pickTitle(3, kind: TitleKind.ep)));
      expect(titleBankAlbum, contains(pickTitle(3, kind: TitleKind.album)));
    });

    test('thème inconnu, null ou ancien thème : jamais vide', () {
      for (final th in [null, 'inconnu', 'quartier', 'galere']) {
        expect(pickTitle(11, theme: th), isNotEmpty);
      }
      expect(titlePool(TitleKind.single, theme: 'quartier').length, 880);
    });

    test('un titre déjà pris n\'est jamais reproposé : 440 tirages dans un thème donnent 440 titres différents', () {
      final used = <String>[];
      for (var i = 0; i < 440; i++) {
        final t = pickTitle(i * 13 + 5, theme: 'trap', used: used);
        expect(used.map(titleKey), isNot(contains(titleKey(t))), reason: t);
        used.add(t);
      }
      expect(used.toSet().length, 440);
      // thème épuisé : le dictionnaire entier prend le relais, toujours sans doublon
      final extra = pickTitle(1, theme: 'trap', used: used);
      expect(used, isNot(contains(extra)));
    });

    test('longueur maximale respectée', () {
      for (var i = 0; i < 300; i++) {
        expect(pickTitle(i, theme: 'ego', maxLength: 14).length, lessThanOrEqualTo(14));
      }
    });

    test('titleIdeas : trois idées différentes, la page suivante en donne d\'autres', () {
      final a = titleIdeas(9, theme: 'rue');
      final b = titleIdeas(9, theme: 'rue', page: 1);
      expect(a.toSet().length, 3);
      expect(a.toSet().intersection(b.toSet()), isEmpty);
      expect(titleIdeas(9, theme: 'rue'), a);
      expect(titleIdeas(9, theme: 'rue', used: [a.first]), isNot(contains(a.first)));
    });
  });

  group('dans le moteur', () {
    J newGame() => init21();

    test('titre automatique : tiré du dictionnaire du thème choisi', () {
      for (final th in ['ambition', 'trap', 'amour', 'quartier']) {
        final r = act21(newGame(), 'create', [th, 'sombre']);
        expect(r.err, isNull, reason: th);
        final t = (r.s['cur'] as J)['title'] as String;
        expect(titlePool(TitleKind.single, theme: th), contains(t), reason: th);
      }
    });

    test('titre automatique : jamais un titre déjà sorti', () {
      final base = newGame();
      final first = (act21(base, 'create', ['gloire', 'sombre']).s['cur'] as J)['title'] as String;
      final s = newGame();
      // le même état de départ redonne le même titre ; le titre pris par un son sorti est écarté
      expect((act21(s, 'create', ['gloire', 'sombre']).s['cur'] as J)['title'], first);
      (s['disco'] as List).add({'id': 'T0', 'title': first, 'Q': 60});
      final again = act21(s, 'create', ['gloire', 'sombre']);
      expect(again.err, isNull);
      expect((again.s['cur'] as J)['title'], isNot(first));
    });

    test('usedTitles21 : son en cours, réserve, sortis et projets', () {
      final s = newGame();
      s['cur'] = {'title': 'A'};
      s['stock'] = [{'title': 'B'}];
      s['disco'] = [{'title': 'C'}];
      s['projects'] = [{'title': 'D', 'inedits': [{'title': 'E'}]}];
      expect(usedTitles21(s), {'A', 'B', 'C', 'D', 'E'});
    });

    test('titleIdeas21 : idées de singles, d\'EP et d\'albums, sans titre déjà pris', () {
      final s = newGame();
      expect(titleIdeas21(s).length, 3);
      for (final t in titleIdeas21(s, kind: 'EP')) {
        expect(titleBankEp, contains(t));
      }
      for (final t in titleIdeas21(s, kind: 'Album', page: 2)) {
        expect(titleBankAlbum, contains(t));
      }
      s['disco'] = [for (final t in titleIdeas21(s)) {'title': t}];
      expect(titleIdeas21(s).toSet().intersection({for (final x in s['disco'] as List) (x as J)['title'] as String}), isEmpty);
    });

    test('rptitle : remplit le nom du prochain EP ou album, différent à chaque appel', () {
      var s = act21(newGame(), 'ptype', 'Album').s;
      final a = act21(s, 'rptitle', '').s;
      final b = act21(a, 'rptitle', '').s;
      final ta = (a['ui'] as J)['ptitle'] as String, tb = (b['ui'] as J)['ptitle'] as String;
      expect(titleBankAlbum, contains(ta));
      expect(titleBankAlbum, contains(tb));
      expect(ta, isNot(tb));
      s = act21(s, 'ptype', 'EP').s;
      expect(titleBankEp, contains((act21(s, 'rptitle', '').s['ui'] as J)['ptitle']));
    });
  });
}
