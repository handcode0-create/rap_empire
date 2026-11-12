// Missions de carrière v21 : six chapitres, 66 missions mesurées sur l'état du jeu.
// Les missions de départ m1 à m4 (Reg21.missions, payées automatiquement) restent inchangées.
// Ces missions-ci se terminent seules (ms2) et se récupèrent (mc2) : la récompense n'est versée qu'à la récupération.
// Récompenses et objectifs : valeurs provisoires (D-08).
import 'reg21.dart';
import 'social21.dart' show followersTotal21;

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map ? x as J : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

class Mission21 {
  final String id, t, metric;
  final num goal;
  final int ch;
  const Mission21(this.id, this.ch, this.t, this.metric, this.goal);
}

/// Chapitres : nom, récompense en cauris et en XP de chaque mission du chapitre.
const missionChapters21 = <(String, int, int)>[
  ('Premiers pas à Ndolo', 2000, 40),
  ('Le quartier écoute', 4000, 90),
  ('Révélation locale', 8000, 160),
  ('Un nom qui circule', 15000, 260),
  ('Star de Bakoma', 30000, 420),
  ('Légende des Rives de Sôlo', 60000, 650),
];

const missions21 = <Mission21>[
  // Chapitre 1
  Mission21('c1_single', 1, 'Sors ton premier single', 'singles', 1),
  Mission21('c1_scene', 1, 'Monte sur scène une première fois', 'shows', 1),
  Mission21('c1_train', 1, 'Suis une formation', 'trained', 1),
  Mission21('c1_fans', 1, 'Atteins 500 fans', 'fans', 500),
  Mission21('c1_post', 1, 'Publie 3 fois sur les réseaux', 'posts', 3),
  Mission21('c1_pop', 1, 'Atteins 5 de popularité', 'pop', 5),
  Mission21('c1_week', 1, 'Tiens une semaine entière', 'day', 8),
  Mission21('c1_two', 1, 'Sors un deuxième single', 'singles', 2),
  Mission21('c1_rep', 1, 'Atteins 8 de réputation', 'rep', 8),
  Mission21('c1_bakoma', 1, 'Atteins 8 de notoriété à Bakoma', 'geo_bakoma', 8),
  // Chapitre 2
  Mission21('c2_singles', 2, 'Sors 3 singles', 'singles', 3),
  Mission21('c2_shows', 2, 'Fais 3 dates sur scène', 'shows', 3),
  Mission21('c2_fans', 2, 'Atteins 2 000 fans', 'fans', 2000),
  Mission21('c2_rep', 2, 'Atteins 15 de réputation', 'rep', 15),
  Mission21('c2_clip', 2, 'Publie ton premier clip', 'clips', 1),
  Mission21('c2_follow', 2, 'Atteins 1 500 abonnés sur les réseaux', 'followers', 1500),
  Mission21('c2_listens', 2, 'Cumule 50 000 écoutes', 'listens', 50000),
  Mission21('c2_train', 2, 'Suis 3 formations', 'trained', 3),
  Mission21('c2_bakoma', 2, 'Atteins 15 de notoriété à Bakoma', 'geo_bakoma', 15),
  Mission21('c2_flow', 2, 'Atteins 20 en flow', 'sk_flow', 20),
  Mission21('c2_outfit', 2, 'Achète une nouvelle tenue', 'outfits', 2),
  // Chapitre 3
  Mission21('c3_singles', 3, 'Sors 5 singles', 'singles', 5),
  Mission21('c3_project', 3, 'Sors un EP ou un album', 'projects', 1),
  Mission21('c3_shows', 3, 'Fais 6 dates sur scène', 'shows', 6),
  Mission21('c3_fans', 3, 'Atteins 5 000 fans', 'fans', 5000),
  Mission21('c3_rep', 3, 'Atteins 25 de réputation', 'rep', 25),
  Mission21('c3_pop', 3, 'Atteins 20 de popularité', 'pop', 20),
  Mission21('c3_listens', 3, 'Cumule 200 000 écoutes', 'listens', 200000),
  Mission21('c3_posts', 3, 'Publie 15 fois sur les réseaux', 'posts', 15),
  Mission21('c3_feat', 3, 'Sors un titre en featuring', 'feats', 1),
  Mission21('c3_ecr', 3, 'Atteins 25 en écriture', 'sk_ecr', 25),
  Mission21('c3_voix', 3, 'Atteins 20 en voix', 'sk_voix', 20),
  Mission21('c3_outfits', 3, 'Possède 3 tenues', 'outfits', 3),
  // Chapitre 4
  Mission21('c4_signed', 4, 'Signe dans un label', 'signed', 1),
  Mission21('c4_singles', 4, 'Sors 8 singles', 'singles', 8),
  Mission21('c4_shows', 4, 'Fais 10 dates sur scène', 'shows', 10),
  Mission21('c4_fans', 4, 'Atteins 15 000 fans', 'fans', 15000),
  Mission21('c4_rep', 4, 'Atteins 35 de réputation', 'rep', 35),
  Mission21('c4_clips', 4, 'Publie 3 clips', 'clips', 3),
  Mission21('c4_listens', 4, 'Cumule 1 million d\'écoutes', 'listens', 1000000),
  Mission21('c4_ambre', 4, 'Atteins 15 de notoriété à Port-Ambre', 'geo_portambre', 15),
  Mission21('c4_selene', 4, 'Atteins 15 de notoriété à Sélène', 'geo_selene', 15),
  Mission21('c4_biz', 4, 'Investis dans une entreprise', 'biz', 1),
  Mission21('c4_cha', 4, 'Atteins 25 en charisme', 'sk_cha', 25),
  Mission21('c4_follow', 4, 'Atteins 10 000 abonnés sur les réseaux', 'followers', 10000),
  // Chapitre 5
  Mission21('c5_album', 5, 'Sors un album', 'albums', 1),
  Mission21('c5_fans', 5, 'Atteins 50 000 fans', 'fans', 50000),
  Mission21('c5_pop', 5, 'Atteins 50 de popularité', 'pop', 50),
  Mission21('c5_rep', 5, 'Atteins 50 de réputation', 'rep', 50),
  Mission21('c5_listens', 5, 'Cumule 5 millions d\'écoutes', 'listens', 5000000),
  Mission21('c5_shows', 5, 'Fais 20 dates sur scène', 'shows', 20),
  Mission21('c5_follow', 5, 'Atteins 50 000 abonnés sur les réseaux', 'followers', 50000),
  Mission21('c5_asset', 5, 'Achète un bien', 'assets', 1),
  Mission21('c5_outfits', 5, 'Possède 10 tenues', 'outfits', 10),
  Mission21('c5_clips', 5, 'Publie 6 clips', 'clips', 6),
  Mission21('c5_flow', 5, 'Atteins 40 en flow', 'sk_flow', 40),
  Mission21('c5_tamarel', 5, 'Atteins 10 de notoriété à Tamarel', 'geo_tamarel', 10),
  // Chapitre 6
  Mission21('c6_fans', 6, 'Atteins 150 000 fans', 'fans', 150000),
  Mission21('c6_listens', 6, 'Cumule 20 millions d\'écoutes', 'listens', 20000000),
  Mission21('c6_projects', 6, 'Sors 4 projets (EP ou albums)', 'projects', 4),
  Mission21('c6_singles', 6, 'Sors 20 singles', 'singles', 20),
  Mission21('c6_shows', 6, 'Fais 40 dates sur scène', 'shows', 40),
  Mission21('c6_pop', 6, 'Atteins 80 de popularité', 'pop', 80),
  Mission21('c6_rep', 6, 'Atteins 75 de réputation', 'rep', 75),
  Mission21('c6_outfits', 6, 'Possède 25 tenues', 'outfits', 25),
  Mission21('c6_biz', 6, 'Investis dans 3 entreprises', 'biz', 3),
  Mission21('c6_korvane', 6, 'Atteins 10 de notoriété à Korvane', 'geo_korvane', 10),
];

/// Valeur actuelle d'un indicateur de mission.
num missionMetric21(J s, String key) {
  if (key.startsWith('geo_')) return _n(_m(s['geo'])[key.substring(4)]);
  if (key.startsWith('sk_')) return _n(_m(s['sk'])[key.substring(3)]);
  final disco = _l(s['disco']).map(_m).toList();
  final projects = _l(s['projects']).map(_m).toList();
  switch (key) {
    case 'singles':
      return disco.length;
    case 'projects':
      return projects.length;
    case 'albums':
      return projects.where((p) => p['type'] != 'EP').length;
    case 'shows':
    case 'fans':
    case 'pop':
    case 'rep':
    case 'day':
      return _n(s[key]);
    case 'trained':
      return _n(s['trained']);
    case 'signed':
      return s['signed'] == 1 || s['signed'] == true ? 1 : 0;
    case 'posts':
      return _n(_m(s['soc'])['tot']);
    case 'followers':
      return followersTotal21(s);
    case 'listens':
      return disco.fold<num>(0, (a, t) => a + _n(t['L']) + _n(t['clipL'])) + projects.fold<num>(0, (a, p) => a + _n(p['L']));
    case 'clips':
      return disco.where((t) => _m(t['clip'])['st'] == 'publie').length;
    case 'feats':
      return disco.where((t) => _l(t['feats']).isNotEmpty).length;
    case 'outfits':
      return _l(_m(s['wd'])['owned']).length;
    case 'biz':
      return _m(s['biz']).length;
    case 'assets':
      return _m(s['own']).length;
  }
  return 0;
}

Mission21? mission21(String id) {
  for (final m in missions21) {
    if (m.id == id) return m;
  }
  return null;
}

/// Récompense (cauris, XP) d'une mission.
(int, int) missionReward21(Mission21 m) => (missionChapters21[m.ch - 1].$2, missionChapters21[m.ch - 1].$3);

/// État d'une mission : 'claimed' (récupérée), 'done' (à récupérer), 'open'.
String missionState21(J s, Mission21 m) {
  if (_m(s['mc2'])[m.id] != null) return 'claimed';
  if (_m(s['ms2'])[m.id] != null) return 'done';
  return 'open';
}

/// Chapitre en cours : le premier dont au moins une mission n'est pas récupérée.
int missionChapter21(J s) {
  for (var c = 1; c <= missionChapters21.length; c++) {
    if (missions21.any((m) => m.ch == c && missionState21(s, m) != 'claimed')) return c;
  }
  return missionChapters21.length;
}

int missionsToClaim21(J s) => missions21.where((m) => missionState21(s, m) == 'done').length;
int missionsClaimed21(J s) => _m(s['mc2']).length;
