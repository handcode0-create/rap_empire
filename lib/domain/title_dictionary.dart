import 'dart:math';

import 'title_bank.dart';

/// Dictionnaire de titres de RAP EMPIRE : 5 000 titres uniques (4 400 singles répartis en 10 thèmes, 300 EP, 300 albums).
/// Les données viennent de title_bank.dart, généré par tools/data/gen_title_bank.py (Dart pur, déterministe, sans dépendance).
/// Règle ajoutée (absente de game.js) : un titre déjà pris par le joueur n'est jamais reproposé tant qu'il en reste d'autres.

enum TitleKind { single, ep, album }

/// Nombre total de titres du dictionnaire.
int get titleDictionarySize => titleBankSingles.values.fold<int>(0, (a, l) => a + l.length) + titleBankEp.length + titleBankAlbum.length;

/// Anciens thèmes de la démo : ils puisent dans plusieurs thèmes du dictionnaire.
const _legacyThemes = <String, List<String>>{
  'quartier': ['rue', 'identite'],
  'galere': ['rue', 'introspection'],
};

List<String>? _allSingles;

/// Tous les singles du dictionnaire, dans un ordre stable.
List<String> get _everySingle => _allSingles ??= [for (final l in titleBankSingles.values) ...l];

/// Titres disponibles pour un genre de sortie et, pour un single, un thème (id de musicThemes ou ancien thème ; inconnu ou null : tous).
List<String> titlePool(TitleKind kind, {String? theme}) {
  switch (kind) {
    case TitleKind.ep:
      return titleBankEp;
    case TitleKind.album:
      return titleBankAlbum;
    case TitleKind.single:
      final direct = titleBankSingles[theme ?? ''];
      if (direct != null) return direct;
      final legacy = _legacyThemes[theme ?? ''];
      if (legacy != null) return [for (final t in legacy) ...titleBankSingles[t]!];
      return _everySingle;
  }
}

/// Forme comparable d'un titre : minuscules, espaces et apostrophes normalisés.
String titleKey(String t) => t.toLowerCase().replaceAll('’', "'").replaceAll(RegExp(r'\s+'), ' ').trim();

/// Un titre pour une graine : même graine, même titre. Il saute les titres de [used] et ceux plus longs que [maxLength].
/// Si tout le thème est déjà pris (plus de 400 titres), le dictionnaire entier sert de réserve ; en dernier recours, un numéro est ajouté.
String pickTitle(int seed, {TitleKind kind = TitleKind.single, String? theme, Iterable<String> used = const [], int maxLength = 30}) {
  final taken = {for (final u in used) titleKey(u)};
  final r = Random(seed.abs() * 7919 + 13);
  for (final pool in [titlePool(kind, theme: theme), if (kind == TitleKind.single) _everySingle]) {
    final start = r.nextInt(pool.length);
    for (var i = 0; i < pool.length; i++) {
      final t = pool[(start + i) % pool.length];
      if (t.length <= maxLength && !taken.contains(titleKey(t))) return t;
    }
  }
  final base = titlePool(kind, theme: theme);
  final t = base[r.nextInt(base.length)];
  for (var n = 2;; n++) {
    final suffix = ' $n';
    final c = (t.length + suffix.length > maxLength ? t.substring(0, maxLength - suffix.length) : t) + suffix;
    if (!taken.contains(titleKey(c))) return c;
  }
}

/// [count] idées de titres différentes pour une page donnée (la page suivante donne d'autres titres).
List<String> titleIdeas(int seed, {TitleKind kind = TitleKind.single, String? theme, int page = 0, int count = 3, Iterable<String> used = const [], int maxLength = 30}) {
  final taken = <String>[...used];
  final out = <String>[];
  for (var i = 0; i < count; i++) {
    final t = pickTitle(seed * 131 + (page * count + i) * 7907 + 1, kind: kind, theme: theme, used: taken, maxLength: maxLength);
    out.add(t);
    taken.add(t);
  }
  return out;
}
