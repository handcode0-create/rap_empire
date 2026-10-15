import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/titles.dart';

/// Titres de sons : règle ajoutée (absente de game.js). Le titre fixe du prototype reste le repli de record().
void main() {
  final written = write(pick(const GameState(), 'gbaka'));

  group('titres générés', () {
    test('64 titres, tous différents', () {
      expect(generatedTitles.length, 64);
      expect(generatedTitles.toSet().length, 64);
    });
    test('« Gbaka de 6h », le titre du prototype, en fait partie', () => expect(generatedTitles, contains('Gbaka de 6h')));
    test('même graine, même titre ; la graine boucle sur la liste', () {
      expect(titleFor(7), titleFor(7));
      expect(titleFor(0), titleFor(64));
      expect(titleFor(-3), titleFor(3));
    });
    test('titres courts : jamais plus de la longueur maximale', () => expect(generatedTitles.every((t) => t.length <= maxTitleLength), isTrue));
  });

  group('ensureTitle, rerollTitle, setTitle', () {
    test('ensureTitle donne un titre généré, déterministe pour une même partie', () {
      final a = ensureTitle(written);
      expect(generatedTitles, contains(a.title));
      expect(ensureTitle(written).title, a.title);
    });
    test('ensureTitle conserve un titre déjà choisi', () => expect(ensureTitle(written.copyWith(title: 'Mon titre')).title, 'Mon titre'));
    test('ensureTitle remplace un titre vide', () => expect(generatedTitles, contains(ensureTitle(written.copyWith(title: '  ')).title)));
    test('rerollTitle : titre de la graine, jamais le même que l’actuel', () {
      final s = rerollTitle(written, 5);
      expect(s.title, titleFor(5));
      expect(rerollTitle(s, 5).title, titleFor(6));
    });
    test('setTitle : espaces rognés, tronqué', () {
      expect(setTitle(written, '  Ma chanson  ').title, 'Ma chanson');
      expect(setTitle(written, 'x' * 40).title!.length, maxTitleLength);
      expect(setTitle(written, '').title, '');
    });
    test('currentTitle : le titre saisi, sinon un titre généré', () {
      expect(currentTitle(written.copyWith(title: 'Ma chanson')), 'Ma chanson');
      expect(generatedTitles, contains(currentTitle(written)));
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
