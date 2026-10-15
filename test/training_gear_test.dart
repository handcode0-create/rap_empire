import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/econ.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/rules.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';
import 'package:rap_empire/domain/training.dart';

/// Parité avec game.js (v20) : A.formation, A.gear, A.claim (missions 3 et 4), registre led et cat, m4pct.
/// Les valeurs attendues viennent de l'exécution de game.js avec Node sur les mêmes entrées.
void main() {
  const base = GameState();
  GameError? errOf(void Function() f) {
    try {
      f();
    } on GameError catch (e) {
      return e;
    }
    return null;
  }

  List<(String, int, String?, int)> led(GameState s) => s.led.map((e) => (e.label, e.amount, e.cat, e.day)).toList();
  Map<String, int> cats(GameState s) => {for (final e in s.cat.entries) if (e.value != 0) e.key: e.value};

  group('table des formations (F de A.formation, planche 09.3)', () {
    test('quatre formations : heures, cauris, énergie, compétence, gain', () {
      expect(formations.map((f) => (f.id, f.name, f.hours, f.cost, f.energy, f.skill, f.gain)).toList(), [
        ('ecr', "Atelier d'écriture", 2, 6000, 20, 'ecr', 5),
        ('flow', 'Freestyle au carrefour', 1, 0, 15, 'flow', 2),
        ('voix', 'Coach vocal', 2, 9000, 20, 'voix', 5),
        ('cha', 'Shooting et réseaux', 2, 7000, 15, 'cha', 4),
      ]);
    });
    test('seul l\'atelier d\'écriture termine la mission 3', () => expect(formations.where((f) => f.unlocksMission3).map((f) => f.id), ['ecr']));
    test('noms des compétences', () => expect(skillNames, {'ecr': 'Écriture', 'flow': 'Flow', 'voix': 'Voix', 'cha': 'Charisme'}));
  });

  group('train : effets', () {
    test('atelier d\'écriture : -6 000, -20 énergie, +2 h, écriture +5, mission 3 terminée, registre', () {
      final s = train(base, 'ecr');
      expect([s.cash, s.energy, s.day, s.hour, s.sk['ecr'], s.ms['m3']], [19000, 80, 1, 10, 19, 'done']);
      expect(cats(s), {'formation': -6000});
      expect(led(s), [('Formation', -6000, 'formation', 1)]);
    });
    test('freestyle (gratuit) : -15 énergie, +1 h, flow +2, rien au registre (if F.c de game.js)', () {
      final s = train(base, 'flow');
      expect([s.cash, s.energy, s.hour, s.sk['flow'], s.ms['m3']], [25000, 85, 9, 19, 'todo']);
      expect(cats(s), isEmpty);
      expect(s.led, isEmpty);
    });
    test('coach vocal : -9 000, -20 énergie, voix +5', () {
      final s = train(base, 'voix');
      expect([s.cash, s.energy, s.hour, s.sk['voix'], s.ms['m3']], [16000, 80, 10, 15, 'todo']);
      expect(led(s), [('Formation', -9000, 'formation', 1)]);
    });
    test('shooting et réseaux : -7 000, -15 énergie, charisme +4', () {
      final s = train(base, 'cha');
      expect([s.cash, s.energy, s.hour, s.sk['cha']], [18000, 85, 10, 12]);
      expect(cats(s), {'formation': -7000});
    });
    test('ne touche pas aux autres compétences ni à l\'XP', () {
      final s = train(base, 'voix');
      expect([s.sk['flow'], s.sk['ecr'], s.sk['cha'], s.xp], [17, 14, 8, 0]);
    });
    test('23:00 : le passage de minuit change le jour, le registre date l\'entrée du lendemain', () {
      final s = train(const GameState(hour: 23), 'ecr');
      expect([s.day, s.hour, s.energy], [2, 1, 80]);
      expect(led(s), [('Formation', -6000, 'formation', 2)]);
      final f = train(const GameState(hour: 23), 'flow');
      expect([f.day, f.hour], [2, 0]);
    });
    test('mission 3 déjà récupérée ou déjà terminée : statut conservé', () {
      expect(train(const GameState(ms: {'m1': 'todo', 'm2': 'todo', 'm3': 'claimed', 'm4': 'todo'}), 'ecr').ms['m3'], 'claimed');
      expect(train(const GameState(ms: {'m1': 'todo', 'm2': 'todo', 'm3': 'done', 'm4': 'todo'}), 'ecr').ms['m3'], 'done');
    });
    test('deux puis trois ateliers de suite', () {
      final two = train(train(base, 'ecr'), 'ecr');
      expect([two.cash, two.energy, two.hour, two.sk['ecr']], [13000, 60, 12, 24]);
      expect(cats(two), {'formation': -12000});
      expect(led(two).length, 2);
      final three = train(two, 'ecr');
      expect([three.cash, three.energy, three.hour, three.sk['ecr']], [7000, 40, 14, 29]);
      expect(cats(three), {'formation': -18000});
    });
  });

  group('train : erreurs (cash d\'abord, puis énergie)', () {
    test('formation inconnue', () => expect(errOf(() => train(base, 'zzz'))!.code, 'inconnu'));
    test('atelier à 5 999 cauris : erreur cash, état inchangé', () {
      const s = GameState(cash: 5999);
      expect(errOf(() => train(s, 'ecr'))!.code, 'cash');
      expect([s.cash, s.energy, s.hour], [5999, 100, 8]);
    });
    test('atelier à 6 000 cauris : permis, 0 cauri', () => expect(train(const GameState(cash: 6000), 'ecr').cash, 0));
    test('atelier à 19 d\'énergie : erreur energie ; à 20 : permis, énergie 0', () {
      expect(errOf(() => train(const GameState(energy: 19), 'ecr'))!.code, 'energie');
      final s = train(const GameState(energy: 20), 'ecr');
      expect([s.energy, s.hour], [0, 10]);
    });
    test('cash ET énergie insuffisants : le cash est signalé en premier', () => expect(errOf(() => train(const GameState(cash: 100, energy: 5), 'ecr'))!.code, 'cash'));
    test('freestyle à 0 cauri : permis ; à 14 d\'énergie : erreur ; à 15 : permis', () {
      expect(train(const GameState(cash: 0), 'flow').sk['flow'], 19);
      expect(errOf(() => train(const GameState(energy: 14), 'flow'))!.code, 'energie');
      expect(train(const GameState(energy: 15), 'flow').energy, 0);
    });
    test('coach à 8 999 cauris : erreur cash', () => expect(errOf(() => train(const GameState(cash: 8999), 'voix'))!.code, 'cash'));
    test('shooting à 7 000 cauris et 15 d\'énergie : permis, tout à 0 ; à 14 d\'énergie : erreur', () {
      final s = train(const GameState(cash: 7000, energy: 15), 'cha');
      expect([s.cash, s.energy, s.hour, s.sk['cha']], [0, 0, 10, 12]);
      expect(errOf(() => train(const GameState(energy: 14), 'cha'))!.code, 'energie');
    });
    test('trainBlocker : même motif que train', () {
      expect(trainBlocker(base, 'ecr'), isNull);
      expect(trainBlocker(const GameState(cash: 5999), 'ecr'), 'cash');
      expect(trainBlocker(const GameState(energy: 19), 'ecr'), 'energie');
      expect(trainBlocker(const GameState(cash: 100, energy: 5), 'ecr'), 'cash');
      expect(trainBlocker(const GameState(cash: 0), 'flow'), isNull);
    });
  });

  group('toast de compétence (planche 09.4)', () {
    test('atelier : « Écriture +5 · Atelier terminé »', () => expect(trainingToast(formationById('ecr')), 'Écriture +5 · Atelier terminé'));
    test('autres formations : « Formation terminée »', () {
      expect(trainingToast(formationById('flow')), 'Flow +2 · Formation terminée');
      expect(trainingToast(formationById('voix')), 'Voix +5 · Formation terminée');
      expect(trainingToast(formationById('cha')), 'Charisme +4 · Formation terminée');
    });
  });

  group('matériel : A.gear (micro studio)', () {
    test('départ : -18 000, micro acheté, registre', () {
      final s = buyMicro(base);
      expect([s.cash, s.micro, s.energy, s.hour], [7000, true, 100, 8]);
      expect(cats(s), {'materiel': -18000});
      expect(led(s), [('Micro studio', -18000, 'materiel', 1)]);
    });
    test('déjà acheté : erreur deja, rien n\'est débité', () {
      const s = GameState(micro: true);
      expect(errOf(() => buyMicro(s))!.code, 'deja');
      expect(errOf(() => buyMicro(s))!.message, 'Déjà acheté');
      expect(s.cash, 25000);
    });
    test('17 999 cauris : erreur cash ; 18 000 : permis, 0 cauri', () {
      expect(errOf(() => buyMicro(const GameState(cash: 17999)))!.code, 'cash');
      expect(buyMicro(const GameState(cash: 18000)).cash, 0);
    });
    test('jour 3 : le registre date l\'achat du jour 3', () => expect(led(buyMicro(const GameState(day: 3))), [('Micro studio', -18000, 'materiel', 3)]));
    test('prix : 18 000, confirmation d\'achat dès 15 000 (I-08)', () {
      expect(Econ.microPrice, 18000);
      expect(needsConfirm(Econ.microPrice), isTrue);
    });
    test('effet branché sur record() : voix +8 (63), qualité 64 au lieu de 61', () {
      const texte = Texte(72, 'quartier', 'sombre');
      final without = record(const GameState(inst: 'gbaka', texte: texte), [74, 48, 43]);
      final withMic = record(buyMicro(const GameState(inst: 'gbaka', texte: texte)), [74, 48, 43]);
      expect([without.song!.voix, without.song!.q], [55, 61]);
      expect([withMic.song!.voix, withMic.song!.q], [63, 64]);
    });
    test('équipement de la planche 09.1 : casque et carte son n\'ont pas de règle dans game.js', () {
      expect(gearItems.map((g) => (g.id, g.name, g.effect, g.price, g.implemented)).toList(), [
        ('micro', 'Micro studio', 'Qualité enregistrement +8', 18000, true),
        ('casque', 'Casque monitoring', 'Qualité mix +4', 12000, false),
        ('carte', 'Carte son', 'Qualité mix +6', 30000, false),
      ]);
    });
  });

  group('missions 3 et 4 : A.claim', () {
    test('mission 3 terminée : +4 000 cauris, +60 XP, statut récupérée, registre', () {
      final s = claim(const GameState(ms: {'m1': 'todo', 'm2': 'todo', 'm3': 'done', 'm4': 'todo'}), 'm3');
      expect([s.cash, s.xp, s.ms['m3'], s.pend], [29000, 60, 'claimed', null]);
      expect(cats(s), {'mission': 4000});
      expect(led(s), [("Mission : Fais un atelier d'écriture", 4000, 'mission', 1)]);
    });
    test('mission 3 à faire : erreur rien', () => expect(errOf(() => claim(base, 'm3'))!.code, 'rien'));
    test('mission 4 terminée : +15 000 cauris, +120 XP, niveau 2 en attente', () {
      final s = claim(const GameState(ms: {'m1': 'todo', 'm2': 'todo', 'm3': 'todo', 'm4': 'done'}), 'm4');
      expect([s.cash, s.xp, s.ms['m4'], s.pend], [40000, 120, 'claimed', const Pending(2, 2000)]);
      expect(led(s), [('Mission : Atteins 1 000 fans', 15000, 'mission', 1)]);
    });
    test('50 XP + mission 3 : niveau 2 en attente (110 XP)', () {
      final s = claim(const GameState(xp: 50, ms: {'m1': 'todo', 'm2': 'todo', 'm3': 'done', 'm4': 'todo'}), 'm3');
      expect([s.xp, s.pend], [110, const Pending(2, 2000)]);
    });
    test('l\'atelier d\'écriture puis sa récompense', () {
      final s = claim(train(base, 'ecr'), 'm3');
      expect([s.cash, s.xp, s.ms['m3']], [23000, 60, 'claimed']);
      expect(led(s), [("Mission : Fais un atelier d'écriture", 4000, 'mission', 1), ('Formation', -6000, 'formation', 1)]);
    });
  });

  group('mission 4 : avancement (m4pct de game.js)', () {
    const cases = {0: 0, 1: 0, 4: 0, 5: 1, 6: 1, 120: 12, 491: 49, 995: 100, 1000: 100, 1005: 100, 5000: 100};
    for (final c in cases.entries) {
      test('${c.key} fans : ${c.value} %', () => expect(fansMissionPercent(c.key), c.value));
    }
  });

  group('registre des dépenses : led et cat (pay de game.js)', () {
    final picked = pick(base, 'gbaka');
    final rec = record(write(picked));
    final m1 = claim(rec, 'm1');
    final released = release(m1, 0);
    final lvl2 = ack(released);
    final m2 = claim(lvl2, 'm2');

    test('parcours canonique : instru', () {
      expect(cats(picked), {'instru': -8000});
      expect(led(picked), [('Instru Gbaka de 6h', -8000, 'instru', 1)]);
      expect(cats(rec), {'instru': -8000}); // écrire et enregistrer ne coûtent pas de cauris
    });
    test('mission 1', () {
      expect(cats(m1), {'mission': 5000, 'instru': -8000});
      expect(led(m1), [('Mission : Enregistre ton premier son', 5000, 'mission', 1), ('Instru Gbaka de 6h', -8000, 'instru', 1)]);
    });
    test('sortie sans promo : seule l\'entrée d\'écoutes, datée du jour de la sortie', () {
      expect(cats(released), {'ecoutes': 54, 'mission': 5000, 'instru': -8000});
      expect(led(released).first, ('Écoutes · Gbaka de 6h', 54, 'ecoutes', 1));
      expect(led(released).length, 3);
    });
    test('niveau 2 : entrée datée du lendemain', () {
      expect(cats(lvl2), {'ecoutes': 54, 'mission': 5000, 'instru': -8000, 'niveau': 2000});
      expect(led(lvl2).first, ('Niveau 2', 2000, 'niveau', 2));
    });
    test('mission 2', () {
      expect(cats(m2), {'ecoutes': 54, 'mission': 15000, 'instru': -8000, 'niveau': 2000});
      expect(led(m2).first, ('Mission : Sors ton premier single', 10000, 'mission', 2));
      expect(led(m2).length, 5);
    });
    test('sortie avec promo payante : la promo précède les écoutes', () {
      for (final c in [(1, 'Promo : Réseaux sociaux', -2000, 87, 'Écoutes · Gbaka de 6h'), (2, 'Promo : Radio locale', -15000, 173, 'Écoutes · Gbaka de 6h')]) {
        final s = release(rec.copyWith(cash: 30000), c.$1);
        expect(led(s).take(2).toList(), [(c.$5, c.$4, 'ecoutes', 1), (c.$2, c.$3, 'promo', 1)]);
        expect(cats(s)['promo'], c.$3);
        expect(cats(s)['ecoutes'], c.$4);
      }
    });
    test('dormir : nuit gratuite, aucune écriture (nightCost = 0)', () {
      expect(Econ.nightCost, 0);
      expect(led(rec.copyWith(energy: 10)).length, 1);
    });
    test('plusieurs entrées : la plus récente d\'abord', () {
      final s = buyMicro(train(train(pick(base, 'nuit'), 'flow'), 'voix').copyWith(cash: 30000));
      expect(led(s).map((e) => e.$1).toList(), ['Micro studio', 'Formation']);
      expect(cats(s), {'formation': -9000, 'materiel': -18000});
    });
    test('un paiement sans libellé n\'écrit rien au registre', () {
      final s = pay(base, -100);
      expect([s.cash, s.led, cats(s)], [24900, <LedgerEntry>[], <String, int>{}]);
    });
    test('toutes les catégories existent dès le départ (cat de game.js)', () {
      expect(base.cat.keys.toSet(), {'manager', 'label', 'ecoutes', 'cachets', 'mission', 'instru', 'promo', 'materiel', 'formation', 'boutique', 'niveau'});
    });
  });

  group('sauvegarde : matériel, compétences, registre', () {
    final s = claim(buyMicro(train(base, 'ecr').copyWith(cash: 30000)), 'm3');
    test('aller-retour JSON', () {
      final r = GameState.fromJson(s.toJson());
      expect([r.micro, r.sk['ecr'], r.ms['m3'], r.cash, r.xp], [true, 19, 'claimed', s.cash, 60]);
      expect(r.led, s.led);
      expect(r.cat, s.cat);
    });
    test('sauvegarde de l\'étape précédente (sans registre) : lisible, registre vide', () {
      final r = GameState.fromJson({'v': 1, 'cash': 777, 'micro': true, 'sk': {'flow': 17, 'ecr': 19, 'voix': 10, 'cha': 8}});
      expect([r.cash, r.micro, r.sk['ecr'], r.led, r.cat], [777, true, 19, <LedgerEntry>[], defaultCat]);
    });
  });
}
