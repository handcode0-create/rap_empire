import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';
import 'package:rap_empire/domain/v21/reg21.dart' show J;
import 'package:rap_empire/features/v21/library_screens.dart';

/// Bibliothèque Ondéa et Cauri Music : populaires, discographie, tous les titres, fiche de sortie (présentation seulement).
void main() {
  J star() {
    final s = act21(init21(), 'preset', 'star').s;
    final disco = (s['disco'] as List).cast<J>();
    s['projects'] = [
      {
        'id': 'P1', 'type': 'EP', 'title': 'Ndo City', 'day': 28, 'Q': 66, 'L': 50000, 'sales': 3100,
        'tracks': [disco.first['id'], 'X9'],
        'inedits': [{'id': 'X9', 'title': 'Inédit de nuit', 'Q': 60}],
      },
    ];
    return s;
  }

  test('populaires : du plus écouté au moins écouté, part de la plateforme appliquée', () {
    final s = star();
    final pop = popular21(s, pfOndea);
    expect(pop.length, (s['disco'] as List).length);
    for (var i = 1; i < pop.length; i++) {
      expect(pop[i - 1].listens!, greaterThanOrEqualTo(pop[i].listens!));
    }
    final ond = popular21(s, pfOndea).first.listens!, cau = popular21(s, pfCauri).first.listens!;
    expect(ond, greaterThan(cau)); // 70 % contre 30 %
  });

  test('discographie : projet et singles, inédits sans écoutes séparées, pochettes stables', () {
    final s = star();
    final rel = releases21(s, pfCauri);
    final ep = rel.firstWhere((r) => r.id == 'P1');
    expect(ep.kind, 'EP');
    expect(ep.tracks.length, 2);
    expect(ep.tracks.last.listens, isNull);
    expect(ep.tracks.last.title, 'Inédit de nuit');
    expect(ep.listens, (50000 * 0.3).round());
    expect(rel.where((r) => r.kind == 'Single').length, (s['disco'] as List).length);
    final all = allTracks21(s, pfOndea);
    expect(all.map((t) => t.id).toSet().length, all.length);
    expect(all.last.title, 'Inédit de nuit');
    for (final r in rel) {
      expect(coverOf21(r.id), coverOf21(r.id));
      expect(File(r.cover).existsSync(), isTrue, reason: r.cover);
    }
  });

  test('aucune sortie : listes vides sans erreur', () {
    final s = act21(init21(), 'preset', 'debut').s;
    expect(releases21(s, pfOndea), isEmpty);
    expect(allTracks21(s, pfCauri), isEmpty);
  });

  test('anciennes sauvegardes : les inédits d\'un projet reçoivent leurs écoutes et leurs ventes', () {
    final s = norm21(star());
    final x9 = (s['disco'] as List).cast<Map>().firstWhere((t) => t['id'] == 'X9');
    expect(x9['L'] as num, greaterThan(0));
    expect(x9['sales'] as num, greaterThan(0));
    expect(x9['st'], 'sorti');
    // une seule fois
    expect((norm21(s)['disco'] as List).cast<Map>().where((t) => t['id'] == 'X9').length, 1);
    // dans les plateformes : écoutes propres, étiqueté inédit, absent des singles de la discographie
    final ep = releases21(s, pfOndea).firstWhere((r) => r.id == 'P1');
    expect(ep.tracks.last.listens, isNotNull);
    expect(ep.tracks.last.project, 'Ndo City');
    expect(releases21(s, pfOndea).where((r) => r.kind == 'Single' && r.id == 'X9'), isEmpty);
  });

  test('pochettes : une par thème et ambiance, projets avec leur propre pochette, fichiers présents', () {
    for (final th in coverThemes21) {
      for (final amb in coverAmbs21) {
        for (var i = 0; i < 40; i++) {
          final path = trackCover21({'id': 'T$i', 'theme': th, 'amb': amb});
          expect(path, startsWith('assets/covers/s_${th}_$amb'));
          expect(File(path).existsSync(), isTrue, reason: path);
        }
      }
    }
    expect(File(trackCover21({'id': 'sans-theme'})).existsSync(), isTrue);
    expect(File(coverOf21('Kaïra Nox')).existsSync(), isTrue);
    for (var i = 0; i < 30; i++) {
      final al = projectCover21({'id': 'P$i', 'type': 'Album', 'title': 'Projet $i'});
      final ep = projectCover21({'id': 'P$i', 'type': 'EP', 'title': 'Projet $i'});
      expect(al, contains('/al_'));
      expect(ep, contains('/ep_'));
      expect(File(al).existsSync() && File(ep).existsSync(), isTrue);
    }
    // variété : plusieurs sons d'un même thème n'ont pas tous la même pochette
    expect({for (var i = 0; i < 20; i++) trackCover21({'id': 'S$i', 'theme': 'amour', 'amb': 'fiere'})}.length, greaterThan(1));
    final s = star();
    final ep = releases21(s, pfOndea).firstWhere((r) => r.kind == 'EP');
    expect(ep.cover, contains('/ep_'));
    expect(ep.tracks.last.cover, ep.cover); // l'inédit garde la pochette de son projet
    final single = releases21(s, pfOndea).firstWhere((r) => r.kind == 'Single');
    expect(single.cover, startsWith('assets/covers/s_'));
  });
}
