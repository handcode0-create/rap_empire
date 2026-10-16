import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/instru_names.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';

/// Parité A.release : valeurs obtenues en exécutant game.js (v20) avec Node sur les mêmes entrées.
/// Entrée canonique (canon.rec) : instru gbaka, texte 72, son 61 enregistré. Cash 17 000, énergie 55, J1 11:00, 120 fans, popularité 3, XP 30.
void main() {
  final rec = record(write(pick(const GameState(), 'gbaka')));

  GameError? errOf(void Function() f) {
    try {
      f();
    } on GameError catch (e) {
      return e;
    }
    return null;
  }

  Release rel(int l, int rev, int fans, int pop, int promo, int q) => Release(title: 'Gbaka de 6h', listens: l, revenue: rev, fans: fans, pop: pop, promo: promo, q: q);

  group('release : les trois promos depuis le canon', () {
    test('Aucune : 5 418 écoutes, +54 cauris, +371 fans, +6 popularité (planche 05.4)', () {
      final s = release(rec, 0);
      expect([s.cash, s.energy, s.day, s.hour, s.fans, s.pop, s.xp, s.level], [17054, 100, 2, 8, 491, 9, 70, 1]);
      expect(s.rel, rel(5418, 54, 371, 6, 0, 61));
      expect([s.lw, s.lc, s.fgain], [8127, 5418, 371]);
      expect({for (final k in ['m1', 'm2', 'm3', 'm4']) k: s.ms[k]}, {'m1': 'done', 'm2': 'done', 'm3': 'todo', 'm4': 'todo'});
      expect(s.pend, isNull);
    });
    test('Réseaux sociaux (2 000) : 8 667 écoutes, +87, +593 fans, +9', () {
      final s = release(rec, 1);
      expect([s.cash, s.fans, s.pop, s.xp], [15087, 713, 12, 70]);
      expect(s.rel, rel(8667, 87, 593, 9, 1, 61));
      expect([s.lw, s.lc, s.fgain], [13001, 8667, 593]);
      expect(s.ms['m4'], 'todo');
    });
    test('Radio locale (15 000) : 17 324 écoutes, +173, +1 185 fans, +19 ; 1 000 fans atteints : mission 4 terminée', () {
      final s = release(rec, 2);
      expect([s.cash, s.fans, s.pop], [2173, 1305, 22]);
      expect(s.rel, rel(17324, 173, 1185, 19, 2, 61));
      expect([s.lw, s.lc, s.fgain], [25986, 17324, 1185]);
      expect({for (final k in ['m1', 'm2', 'm3', 'm4']) k: s.ms[k]}, {'m1': 'done', 'm2': 'done', 'm3': 'todo', 'm4': 'done'});
    });
  });

  group('release : cash', () {
    test('Radio locale à 14 999 : erreur cash, état inchangé', () {
      final s = rec.copyWith(cash: 14999);
      expect(errOf(() => release(s, 2))!.code, 'cash');
      expect([s.energy, s.day, s.fans, s.rel], [55, 1, 120, null]);
    });
    test('Radio locale à 15 000 : permis, il reste 173 cauris', () {
      final s = release(rec.copyWith(cash: 15000), 2);
      expect([s.cash, s.fans], [173, 1305]);
    });
    test('Réseaux sociaux à 1 999 : erreur cash', () => expect(errOf(() => release(rec.copyWith(cash: 1999), 1))!.code, 'cash'));
    test('Aucune ne coûte rien, même à 0 cauri', () {
      final s = release(rec.copyWith(cash: 0), 0);
      expect(s.cash, 54);
    });
  });

  group('release : audience, qualité, niveau', () {
    test('500 fans, Réseaux sociaux : 10 861 écoutes, +109, +692 fans, +12', () {
      final s = release(rec.copyWith(fans: 500), 1);
      expect([s.cash, s.fans, s.pop], [15109, 1192, 15]);
      expect(s.rel, rel(10861, 109, 692, 12, 1, 61));
      expect(s.ms['m4'], 'done');
    });
    test('5 000 fans, qualité 86, Radio locale : 103 287 écoutes (parité listensFor), +1 033, +3 616 fans, +114', () {
      final loud = rec.copyWith(fans: 5000, cash: 100000, song: const Song(title: 'Gbaka de 6h', q: 86, texte: 72, voix: 90, prod: 86, inst: 'x'));
      final s = release(loud, 2);
      expect([s.cash, s.fans, s.pop], [86033, 8616, 117]);
      expect(s.rel, rel(103287, 1033, 3616, 114, 2, 86));
    });
    test('900 fans, Aucune : passe à 1 389 fans, mission 4 terminée', () {
      final s = release(rec.copyWith(fans: 900), 0);
      expect([s.cash, s.fans, s.pop], [17082, 1389, 12]);
      expect(s.rel, rel(8234, 82, 489, 9, 0, 61));
      expect(s.ms['m4'], 'done');
    });
    test('80 XP : la sortie (+40) passe au niveau 2, 2 000 cauris en attente', () {
      final s = release(rec.copyWith(xp: 80), 0);
      expect([s.xp, s.level, s.pend, s.cash], [120, 2, const Pending(2, 2000), 17054]);
    });
  });

  group('release : erreurs', () {
    test('sans son : erreur son', () => expect(errOf(() => release(const GameState(), 0))!.code, 'son'));
    test('promo inconnue : erreur inconnu', () => expect(errOf(() => release(rec, 9))!.code, 'inconnu'));
  });

  group('release : écart assumé avec game.js (son marqué sorti, discographie)', () {
    final s = release(rec, 0);
    test('le son est marqué sorti', () => expect([s.song!.released, s.song!.title, s.song!.q], [true, 'Gbaka de 6h', 61]));
    test('discographie : titre, qualité, écoutes', () => expect(s.disco, const [DiscoEntry(title: 'Gbaka de 6h', q: 61, listens: 5418, day: 2)]));
    test('le même son ne ressort pas (le prototype le permettait)', () => expect(errOf(() => release(s, 0))!.code, 'son'));
    test('un deuxième son s’ajoute à la discographie', () {
      final second = release(record(write(pick(s, 'nuit'))), 0);
      expect(second.disco.map((d) => d.title), ['Gbaka de 6h', instruName(s, 'nuit')]); // le nom de l'instru gratuite change d'un jour à l'autre
      expect(second.lc, second.disco.fold<int>(0, (a, d) => a + d.listens));
    });
    test('songCount : sons sortis + son à sortir', () {
      expect(songCount(const GameState()), 0);
      expect(songCount(rec), 1);
      expect(songCount(s), 1);
      expect(songCount(record(write(pick(s, 'nuit')))), 2);
    });
  });

  group('releasePreview (planches 05.1, 05.1b, 05.2)', () {
    // Cash 22 000 (planche 05.2) : Radio locale laisse 7 000. Cash 4 200 (planche 05.1b) : -10 800, cash insuffisant.
    final at22000 = rec.copyWith(cash: 22000);
    test('Aucune : 5 418 écoutes estimées, 22 000 cauris après', () {
      final p = releasePreview(at22000, 0);
      expect([p.listens, p.revenue, p.promoCost, p.cashAfter, p.affordable], [5418, 54, 0, 22000, true]);
    });
    test('Radio locale à 22 000 : 17 324 écoutes, 7 000 après', () {
      final p = releasePreview(at22000, 2);
      expect([p.listens, p.cashAfter, p.affordable], [17324, 7000, true]);
    });
    test('Radio locale à 4 200 : 17 324 écoutes, -10 800 après, cash insuffisant', () {
      final p = releasePreview(rec.copyWith(cash: 4200), 2);
      expect([p.listens, p.cashAfter, p.affordable], [17324, -10800, false]);
    });
    test('Réseaux sociaux : 8 667 écoutes, 2 000 de promo', () {
      final p = releasePreview(at22000, 1);
      expect([p.listens, p.promoCost, p.cashAfter], [8667, 2000, 20000]);
    });
    test('aperçu = résultat réel (écoutes et revenus)', () {
      for (final promo in [0, 1, 2]) {
        final p = releasePreview(rec.copyWith(cash: 50000), promo);
        final r = release(rec.copyWith(cash: 50000), promo).rel!;
        expect([p.listens, p.revenue], [r.listens, r.revenue]);
      }
    });
    test('sans son : erreur son', () => expect(errOf(() => releasePreview(const GameState(), 0))!.code, 'son'));
  });

  group('sauvegarde de la sortie', () {
    test('aller-retour JSON : résultat, discographie, compteurs, son sorti', () {
      final s = release(rec, 1);
      final r = GameState.fromJson(s.toJson());
      expect(r.rel, s.rel);
      expect(r.disco, s.disco);
      expect([r.lw, r.lc, r.fgain], [13001, 8667, 593]);
      expect(r.song!.released, isTrue);
      expect([r.cash, r.fans, r.pop, r.day, r.hour, r.energy], [15087, 713, 12, 2, 8, 100]);
      expect(r.ms, s.ms);
    });
    test('ancienne sauvegarde sans sortie : valeurs par défaut', () {
      final s = GameState.fromJson({'v': 1});
      expect([s.rel, s.disco, s.lw, s.lc, s.fgain], [null, <DiscoEntry>[], 0, 0, 0]);
    });
  });
}
