// Données du studio sauvegardées dans l'état de partie (formes de game.js : texte, song, rel).

/// Texte écrit (A.write) : note, thème et ambiance choisis.
class Texte {
  final int note;
  final String theme, amb;
  const Texte(this.note, this.theme, this.amb);

  Map<String, dynamic> toJson() => {'note': note, 'theme': theme, 'amb': amb};
  factory Texte.fromJson(Map<String, dynamic> j) => Texte((j['note'] ?? 60) as int, (j['theme'] ?? 'quartier') as String, (j['amb'] ?? 'sombre') as String);

  @override
  bool operator ==(Object other) => other is Texte && other.note == note && other.theme == theme && other.amb == amb;
  @override
  int get hashCode => Object.hash(note, theme, amb);
}

/// Son enregistré (A.record) : qualité, notes de texte, voix et production. [released] : déjà sorti (écart assumé avec game.js,
/// qui ne vide pas song à la sortie ; voir release).
class Song {
  final String title, inst;

  /// Thème du texte (music_catalog.dart), vide si le son n'a pas de texte.
  final String theme;

  /// Style musical de l'instru (music_catalog.dart) et potentiel viral (0 à 100, indicatif).
  final String style;
  final int viral;
  final int q, texte, voix, prod;
  final bool released;
  const Song({required this.title, required this.q, required this.texte, required this.voix, required this.prod, required this.inst, this.theme = '', this.style = '', this.viral = 0, this.released = false});

  Song copyWith({bool? released}) => Song(title: title, q: q, texte: texte, voix: voix, prod: prod, inst: inst, theme: theme, style: style, viral: viral, released: released ?? this.released);

  Map<String, dynamic> toJson() => {'title': title, 'q': q, 'texte': texte, 'voix': voix, 'prod': prod, 'inst': inst, 'theme': theme, 'style': style, 'viral': viral, 'released': released};
  factory Song.fromJson(Map<String, dynamic> j) => Song(
        title: (j['title'] ?? '') as String, q: (j['q'] ?? 0) as int, texte: (j['texte'] ?? 0) as int, voix: (j['voix'] ?? 0) as int,
        prod: (j['prod'] ?? 0) as int, inst: (j['inst'] ?? '') as String, theme: (j['theme'] ?? '') as String, style: (j['style'] ?? '') as String, viral: (j['viral'] ?? 0) as int, released: (j['released'] ?? false) as bool);

  @override
  bool operator ==(Object other) =>
      other is Song && other.title == title && other.q == q && other.texte == texte && other.voix == voix && other.prod == prod && other.inst == inst && other.theme == theme && other.style == style && other.viral == viral && other.released == released;
  @override
  int get hashCode => Object.hash(title, q, texte, voix, prod, inst, theme, style, viral, released);
}

/// Niveau gagné à récupérer (pend de game.js) : niveau atteint et récompense en cauris.
class Pending {
  final int lvl, reward;
  const Pending(this.lvl, this.reward);

  Map<String, dynamic> toJson() => {'lvl': lvl, 'reward': reward};
  factory Pending.fromJson(Map<String, dynamic> j) => Pending((j['lvl'] ?? 1) as int, (j['reward'] ?? 0) as int);

  @override
  bool operator ==(Object other) => other is Pending && other.lvl == lvl && other.reward == reward;
  @override
  int get hashCode => Object.hash(lvl, reward);
}

/// Résultat de la dernière sortie (rel de game.js) : écoutes, revenus, fans et popularité gagnés.
class Release {
  final String title;
  final int listens, revenue, fans, pop, promo, q;
  const Release({required this.title, required this.listens, required this.revenue, required this.fans, required this.pop, required this.promo, required this.q});

  Map<String, dynamic> toJson() => {'title': title, 'l': listens, 'rev': revenue, 'fans': fans, 'pop': pop, 'promo': promo, 'q': q};
  factory Release.fromJson(Map<String, dynamic> j) => Release(
        title: (j['title'] ?? '') as String, listens: (j['l'] ?? 0) as int, revenue: (j['rev'] ?? 0) as int, fans: (j['fans'] ?? 0) as int,
        pop: (j['pop'] ?? 0) as int, promo: (j['promo'] ?? 0) as int, q: (j['q'] ?? 0) as int);

  @override
  bool operator ==(Object other) =>
      other is Release && other.title == title && other.listens == listens && other.revenue == revenue && other.fans == fans && other.pop == pop && other.promo == promo && other.q == q;
  @override
  int get hashCode => Object.hash(title, listens, revenue, fans, pop, promo, q);
}

/// Ligne de discographie : un son sorti (ajout validé : game.js ne garde que le dernier son et la dernière sortie).
class DiscoEntry {
  final String title;
  final int q, listens;

  /// Premier jour qui suit la sortie (l'âge du son se compte à partir de là). -1 : inconnu (ancienne sauvegarde), daté à la prochaine nuit.
  final int day;
  const DiscoEntry({required this.title, required this.q, required this.listens, this.day = -1});

  DiscoEntry withDay(int d) => DiscoEntry(title: title, q: q, listens: listens, day: d);

  Map<String, dynamic> toJson() => {'title': title, 'q': q, 'l': listens, 'd': day};
  factory DiscoEntry.fromJson(Map<String, dynamic> j) => DiscoEntry(title: (j['title'] ?? '') as String, q: (j['q'] ?? 0) as int, listens: (j['l'] ?? 0) as int, day: (j['d'] ?? -1) as int);

  @override
  bool operator ==(Object other) => other is DiscoEntry && other.title == title && other.q == q && other.listens == listens && other.day == day;
  @override
  int get hashCode => Object.hash(title, q, listens, day);
}

/// Entrée du registre des dépenses et revenus (led de game.js : { l, a, c, d }) : libellé, montant, catégorie, jour. Plus récente d'abord.
class LedgerEntry {
  final String label;
  final int amount, day;
  final String? cat;
  const LedgerEntry({required this.label, required this.amount, required this.cat, required this.day});

  Map<String, dynamic> toJson() => {'l': label, 'a': amount, 'c': cat, 'd': day};
  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(label: (j['l'] ?? '') as String, amount: (j['a'] ?? 0) as int, cat: j['c'] as String?, day: (j['d'] ?? 1) as int);

  @override
  bool operator ==(Object other) => other is LedgerEntry && other.label == label && other.amount == amount && other.cat == cat && other.day == day;
  @override
  int get hashCode => Object.hash(label, amount, cat, day);
}

/// Accord avec DJ Kôrô (kc de game.js) : [st] état ('' aucun, acc, neg, back, assist, ref, decl), [rel] relation cumulée, [cut] part de Kôrô (texte),
/// [cost] cauris payés, [left] titres restants avec le bonus, [bonus] points de production ajoutés à chaque enregistrement tant que [left] > 0.
class KoreDeal {
  final String st, cut;
  final int rel, cost, left, bonus;
  const KoreDeal({this.st = '', this.rel = 0, this.cut = '', this.cost = 0, this.left = 0, this.bonus = 0});

  KoreDeal copyWith({int? left}) => KoreDeal(st: st, rel: rel, cut: cut, cost: cost, left: left ?? this.left, bonus: bonus);

  Map<String, dynamic> toJson() => {'st': st, 'rel': rel, 'cut': cut, 'cost': cost, 'left': left, 'bonus': bonus};
  factory KoreDeal.fromJson(Map<String, dynamic> j) =>
      KoreDeal(st: (j['st'] ?? '') as String, rel: (j['rel'] ?? 0) as int, cut: (j['cut'] ?? '') as String, cost: (j['cost'] ?? 0) as int, left: (j['left'] ?? 0) as int, bonus: (j['bonus'] ?? 0) as int);

  @override
  bool operator ==(Object other) => other is KoreDeal && other.st == st && other.rel == rel && other.cut == cut && other.cost == cost && other.left == left && other.bonus == bonus;
  @override
  int get hashCode => Object.hash(st, rel, cut, cost, left, bonus);
}
