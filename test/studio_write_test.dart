import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

/// Parité A.write : valeurs obtenues en exécutant game.js (v20) avec Node sur les mêmes entrées.
/// Entrée de base : départ + instru gbaka (17 000 cauris), énergie 100, 08:00, écriture 14.
void main() {
  final base = pick(const GameState(), 'gbaka');

  GameError? errOf(void Function() f) {
    try {
      f();
    } on GameError catch (e) {
      return e;
    }
    return null;
  }

  group('write : thème et ambiance', () {
    test('quartier / sombre : note 72', () {
      final s = write(base, theme: 'quartier', amb: 'sombre');
      expect([s.texte!.note, s.energy, s.hour, s.day, s.sk['ecr'], s.cash], [72, 80, 9, 1, 16, 17000]);
    });
    test('quartier / fière : 74', () => expect(write(base, theme: 'quartier', amb: 'fiere').texte!.note, 74));
    test('quartier / légère : 70', () => expect(write(base, theme: 'quartier', amb: 'legere').texte!.note, 70));
    test('galère / sombre : 73', () => expect(write(base, theme: 'galere', amb: 'sombre').texte!.note, 73));
    test('ambition / fière : 76', () => expect(write(base, theme: 'ambition', amb: 'fiere').texte!.note, 76));
    test('amour / légère : 69', () => expect(write(base, theme: 'amour', amb: 'legere').texte!.note, 69));
    test('valeurs par défaut : quartier / sombre', () => expect(write(base).texte, const Texte(72, 'quartier', 'sombre')));
    test('thème et ambiance conservés dans le texte', () {
      final t = write(base, theme: 'galere', amb: 'fiere').texte!;
      expect([t.theme, t.amb], ['galere', 'fiere']);
    });
  });

  group('write : énergie, heure, gain', () {
    test('énergie 19 : erreur energie, état inchangé', () {
      const s = GameState(energy: 19);
      expect(errOf(() => write(s))!.code, 'energie');
      expect(s.texte, isNull);
    });
    test('énergie 20 : permis, énergie 0, 09:00, texte 72, écriture 16', () {
      final s = write(const GameState(energy: 20));
      expect([s.energy, s.hour, s.day, s.texte!.note, s.sk['ecr']], [0, 9, 1, 72, 16]);
    });
    test('23:00 : passe à J2 00:00', () {
      final s = write(const GameState(hour: 23));
      expect([s.day, s.hour, s.energy], [2, 0, 80]);
    });
    test('deuxième écriture : énergie 60, 10:00, écriture 18, texte remplacé (74)', () {
      final s = write(write(base), amb: 'fiere');
      expect([s.energy, s.hour, s.sk['ecr'], s.texte!.note], [60, 10, 18, 74]);
    });
    test('sans instru : permis (A.write ne la vérifie pas)', () {
      final s = write(const GameState());
      expect([s.inst, s.texte!.note, s.energy], [null, 72, 80]);
    });
    test('ne touche pas aux autres compétences ni aux cauris', () {
      final s = write(base);
      expect([s.sk['flow'], s.sk['voix'], s.sk['cha'], s.cash], [17, 10, 8, 17000]);
    });
    test('thème ou ambiance inconnus : erreur inconnu', () {
      expect(errOf(() => write(base, theme: 'zzz'))!.code, 'inconnu');
      expect(errOf(() => write(base, amb: 'zzz'))!.code, 'inconnu');
    });
  });

  group('pick efface le texte (A.pick : texte = null)', () {
    test('changer d\'instru après avoir écrit', () {
      final s = pick(write(base), 'nuit');
      expect([s.inst, s.texte], ['nuit', null]);
    });
  });

  group('textNote', () {
    test('72 + ambiance + thème', () {
      expect(textNote('quartier', 'sombre'), 72);
      expect(textNote('ambition', 'fiere'), 76);
      expect(textNote('amour', 'legere'), 69);
    });
  });

  group('sauvegarde du texte et des compétences', () {
    test('aller-retour JSON', () {
      final s = write(base, theme: 'galere', amb: 'fiere');
      final r = GameState.fromJson(s.toJson());
      expect(r.texte, const Texte(75, 'galere', 'fiere'));
      expect(r.sk['ecr'], 16);
      expect([r.energy, r.hour, r.inst], [80, 9, 'gbaka']);
    });
    test('ancienne sauvegarde sans texte ni compétences : valeurs par défaut', () {
      final s = GameState.fromJson({'v': 1, 'cash': 5});
      expect([s.texte, s.sk['ecr'], s.sk['flow']], [null, 14, 17]);
    });
  });
}
