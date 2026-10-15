import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/data/save_repository.dart';
import 'package:rap_empire/domain/game_state.dart';
import 'package:rap_empire/domain/studio.dart';
import 'package:rap_empire/domain/studio_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sauvegarde locale réelle (SaveRepository + shared_preferences simulé) : toutes les données du studio survivent à un rechargement.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('aucune sauvegarde : état de départ', () async {
    final s = await SaveRepository().loadLocal();
    expect([s.cash, s.energy, s.inst, s.song, s.disco, s.pend], [25000, 100, null, null, <DiscoEntry>[], null]);
  });

  test('instru choisie, texte écrit : retrouvés au rechargement', () async {
    final s = write(pick(const GameState(), 'gbaka'), theme: 'galere', amb: 'fiere');
    await SaveRepository().saveLocal(s);
    final r = await SaveRepository().loadLocal();
    expect([r.inst, r.texte, r.cash, r.energy, r.hour, r.sk['ecr']], ['gbaka', const Texte(75, 'galere', 'fiere'), 17000, 80, 9, 16]);
    expect(studioStep(r), StudioStep.cabine);
  });

  test('son enregistré avec niveau en attente : retrouvés, l’étape à reprendre est la sortie', () async {
    final s = record(write(pick(const GameState(xp: 80), 'gbaka')), [74, 48, 43]);
    await SaveRepository().saveLocal(s);
    final r = await SaveRepository().loadLocal();
    expect(r.song, s.song);
    expect([r.takes, r.xp, r.pend, r.ms['m1']], [[74, 48, 43], 110, const Pending(2, 2000), 'done']);
    expect(studioStep(r), StudioStep.sortie);
  });

  test('sortie, discographie, missions : retrouvées, rien ne ressort', () async {
    var s = record(write(pick(const GameState(), 'gbaka')));
    s = claim(s, 'm1');
    s = release(s, 1);
    await SaveRepository().saveLocal(s);
    final r = await SaveRepository().loadLocal();
    expect(r.rel, s.rel);
    expect(r.disco, s.disco);
    expect([r.lw, r.lc, r.fgain], [s.lw, s.lc, s.fgain]);
    expect([r.cash, r.fans, r.pop, r.day, r.hour, r.energy, r.xp], [s.cash, s.fans, s.pop, 2, 8, 100, s.xp]);
    expect(r.ms, s.ms);
    expect(r.song!.released, isTrue);
    expect(studioStep(r), StudioStep.instru);
  });

  test('sauvegarde de la v1 (sans champs du studio) : lisible', () async {
    SharedPreferences.setMockInitialValues({'save_v1': '{"v":1,"cash":777,"en":55,"day":3,"hour":14,"fans":9,"pop":1,"rep":2,"xp":120,"hood":"Ndolo"}'});
    final r = await SaveRepository().loadLocal();
    expect([r.cash, r.energy, r.day, r.hour, r.xp, r.level], [777, 55, 3, 14, 120, 2]);
    expect([r.inst, r.texte, r.song, r.rel, r.pend, r.takes, r.disco], [null, null, null, null, null, <int>[], <DiscoEntry>[]]);
    expect(r.ms, defaultMissions);
  });
}
