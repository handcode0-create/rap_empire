import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/music_catalog.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/titles.dart';

/// Titres de sons : règle ajoutée (absente de game.js). Le titre fixe du prototype reste le repli de record().
void main() {
  final written = write(pick(const GameState(), 'gbaka'));

  group('titres générés (bibliothèque musicale)', () {
    final sample = [for (var i = 0; i < 3000; i++) titleFor(i)];
    test('des milliers de titres différents', () => expect(sample.toSet().length, greaterThan(500)));
    test('même graine et même thème, même titre', () {
      expect(titleFor(7, theme: 'amour'), titleFor(7, theme: 'amour'));
      expect(titleFor(-3), titleFor(3));
    });
    test('titres courts : jamais plus de la longueur maximale, jamais vides', () {
      expect(sample.every((t) => t.length <= maxTitleLength && t.trim().isNotEmpty), isTrue);
    });
    test('pas de doublon de mot collé (« de de », « la la »)', () {
      for (final t in sample) {
        expect(RegExp(r'\b(\w+) \1\b', caseSensitive: false).hasMatch(t), isFalse, reason: t);
      }
    });
    test('chaque thème donne des titres', () {
      for (final th in musicThemes) {
        final titles = {for (var i = 0; i < 200; i++) titleFor(i, theme: th.id)};
        expect(titles.length, greaterThan(20), reason: th.id);
      }
    });
    test('un thème inconnu ne casse rien', () => expect(titleFor(4, theme: 'inconnu'), isNotEmpty));
  });

  group('ensureTitle, rerollTitle, setTitle', () {
    test('ensureTitle donne un titre généré, déterministe pour une même partie', () {
      final a = ensureTitle(written);
      expect(a.title, isNotEmpty);
      expect(ensureTitle(written).title, a.title);
    });
    test('ensureTitle conserve un titre déjà choisi', () => expect(ensureTitle(written.copyWith(title: 'Mon titre')).title, 'Mon titre'));
    test('ensureTitle remplace un titre vide', () => expect(ensureTitle(written.copyWith(title: '  ')).title, isNotEmpty));
    test('rerollTitle : titre de la graine, jamais le même que l’actuel', () {
      final s = rerollTitle(written, 5);
      expect(s.title, titleFor(5, theme: written.texte!.theme));
      expect(rerollTitle(s, 5).title, isNot(s.title));
    });
    test('setTitle : espaces rognés, tronqué', () {
      expect(setTitle(written, '  Ma chanson  ').title, 'Ma chanson');
      expect(setTitle(written, 'x' * 40).title!.length, maxTitleLength);
      expect(setTitle(written, '').title, '');
    });
    test('currentTitle : le titre saisi, sinon un titre généré', () {
      expect(currentTitle(written.copyWith(title: 'Ma chanson')), 'Ma chanson');
      expect(currentTitle(written), isNotEmpty);
    });
  });

  group('titre et enregistrement', () {
    test('record utilise le titre choisi, puis l’efface', () {
      final s = record(written.copyWith(title: 'Mon titre'), [74, 48, 43]);
      expect(s.song!.title, 'Mon titre');
      expect(s.title, isNull);
    });
    test('sans titre : repli sur le titre du prototype (parité game.js)', () {
      expect(record(written, [74, 48, 43]).song!.title, 'Gbaka de 6h');
      expect(record(write(pick(const GameState(), 'nuit')), [74, 48, 43]).song!.title, 'Nuit à Ndo');
    });
    test('titre vide : repli sur le titre du prototype', () => expect(record(written.copyWith(title: ' '), [74, 48, 43]).song!.title, 'Gbaka de 6h'));
    test('choisir une autre instru efface le titre', () => expect(pick(written.copyWith(title: 'Mon titre'), 'nuit').title, isNull));
    test('sauvegarde : aller-retour du titre', () => expect(GameState.fromJson(written.copyWith(title: 'Mon titre').toJson()).title, 'Mon titre'));
    test('ancienne sauvegarde sans titre : lisible', () => expect(GameState.fromJson({'v': 1}).title, isNull));
  });
}
