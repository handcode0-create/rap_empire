import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart' show J;
import 'package:rap_empire/features/v21/library_screens.dart' show trackCover21;

/// Pochette choisie pour un son : action `setcover` (en cours, réserve, sorti), validation du chemin, repli automatique.
void main() {
  J withSong() {
    var s = act21(init21(), 'preset', 'carriere').s;
    s = act21(s, 'create', ['ambition', 'fiere']).s;
    return act21(s, 'record').s;
  }

  const good = 'assets/covers/s_trap_sombre_4.svg';

  test('chemins valides : 13 motifs x 3 ambiances x 6 variantes seulement', () {
    expect(isCoverPath21(good), isTrue);
    expect(isCoverPath21('assets/covers/s_autre_legere_0.svg'), isTrue);
    for (final bad in ['assets/covers/s_trap_sombre_6.svg', 'assets/covers/s_inconnu_sombre_0.svg', 'assets/covers/al_1.svg', '../secret.svg', '', 'assets/covers/s_trap_sombre_0.png']) {
      expect(isCoverPath21(bad), isFalse, reason: bad);
    }
  });

  test('son en cours : la pochette choisie remplace l\'automatique, vide la rend', () {
    final s = withSong();
    final id = (s['cur'] as J)['id'];
    final auto = trackCover21(s['cur'] as J);
    final r = act21(s, 'setcover', [id, good]);
    expect(r.err, isNull);
    expect((r.s['cur'] as J)['cover'], good);
    expect(trackCover21(r.s['cur'] as J), good);
    final back = act21(r.s, 'setcover', [id, '']);
    expect((back.s['cur'] as J).containsKey('cover'), isFalse);
    expect(trackCover21(back.s['cur'] as J), auto);
  });

  test('chemin invalide ou son inconnu : refusé, rien ne change', () {
    final s = withSong();
    final id = (s['cur'] as J)['id'];
    expect(act21(s, 'setcover', [id, 'assets/covers/nimporte.svg']).err, isNotNull);
    expect(act21(s, 'setcover', ['T999', good]).err, isNotNull);
    expect(act21(s, 'setcover', 'oups').err, isNotNull);
    expect((s['cur'] as J).containsKey('cover'), isFalse);
  });

  test('la pochette suit le son en réserve, puis à la sortie', () {
    var s = withSong();
    final id = (s['cur'] as J)['id'];
    s = act21(s, 'setcover', [id, good]).s;
    s = act21(s, 'shelve').s;
    expect(((s['stock'] as List).first as J)['cover'], good);
    s = act21(s, 'setcover', [id, 'assets/covers/s_gloire_legere_1.svg']).s;
    expect(((s['stock'] as List).first as J)['cover'], 'assets/covers/s_gloire_legere_1.svg');
    final rel = act21(s, 'rnow', id);
    if (rel.err == null) {
      final out = (rel.s['disco'] as List).cast<J>().firstWhere((x) => x['id'] == id);
      expect(out['cover'], 'assets/covers/s_gloire_legere_1.svg');
    }
  });

  test('miniature de clip : setthumb ne vaut que pour un clip publié, 0 à 12, null revient à l\'automatique', () {
    final s = withSong();
    s['disco'] = <dynamic>[
      <String, dynamic>{'id': 'TA', 'title': 'Titre A', 'clip': <String, dynamic>{'st': 'aucun'}},
      <String, dynamic>{'id': 'TB', 'title': 'Titre B', 'clip': <String, dynamic>{'st': 'publie'}},
    ];
    expect(act21(s, 'setthumb', ['TA', 3]).err, 'inconnu'); // clip pas publié
    final song = (s['disco'] as List)[1] as J;
    final r = act21(s, 'setthumb', [song['id'], 12]);
    expect(r.err, isNull);
    expect(clipThumb21((r.s['disco'] as List)[1] as J, 5), 12);
    expect(act21(r.s, 'setthumb', [song['id'], 13]).err, 'inconnu');
    expect(act21(r.s, 'setthumb', [song['id'], 'x']).err, 'inconnu');
    final back = act21(r.s, 'setthumb', [song['id'], null]);
    expect(clipThumb21((back.s['disco'] as List)[1] as J, 5), 5);
    expect(clipThumb21({'clip': {'st': 'publie'}}, 14), 2); // défaut : ordre du clip modulo 12
    for (final n in ['foret', 'savane', 'resto', 'street', 'rue', 'lagune', 'toit', 'studio', 'marche', 'scene', 'club', 'quartier']) {
      final f = File('assets/klipo/mine/scene_$n.svg');
      expect(f.existsSync(), isTrue, reason: n);
      expect(f.readAsStringSync().contains('<text'), isFalse, reason: n);
    }
  });
}
