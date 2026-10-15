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
  final int q, texte, voix, prod;
  final bool released;
  const Song({required this.title, required this.q, required this.texte, required this.voix, required this.prod, required this.inst, this.released = false});

  Song copyWith({bool? released}) => Song(title: title, q: q, texte: texte, voix: voix, prod: prod, inst: inst, released: released ?? this.released);

  Map<String, dynamic> toJson() => {'title': title, 'q': q, 'texte': texte, 'voix': voix, 'prod': prod, 'inst': inst, 'released': released};
  factory Song.fromJson(Map<String, dynamic> j) => Song(
        title: (j['title'] ?? '') as String, q: (j['q'] ?? 0) as int, texte: (j['texte'] ?? 0) as int, voix: (j['voix'] ?? 0) as int,
        prod: (j['prod'] ?? 0) as int, inst: (j['inst'] ?? '') as String, released: (j['released'] ?? false) as bool);

  @override
  bool operator ==(Object other) =>
      other is Song && other.title == title && other.q == q && other.texte == texte && other.voix == voix && other.prod == prod && other.inst == inst && other.released == released;
  @override
  int get hashCode => Object.hash(title, q, texte, voix, prod, inst, released);
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
  const DiscoEntry({required this.title, required this.q, required this.listens});

  Map<String, dynamic> toJson() => {'title': title, 'q': q, 'l': listens};
  factory DiscoEntry.fromJson(Map<String, dynamic> j) => DiscoEntry(title: (j['title'] ?? '') as String, q: (j['q'] ?? 0) as int, listens: (j['l'] ?? 0) as int);

  @override
  bool operator ==(Object other) => other is DiscoEntry && other.title == title && other.q == q && other.listens == listens;
  @override
  int get hashCode => Object.hash(title, q, listens);
}
