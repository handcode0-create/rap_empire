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
