import 'dart:convert';
import 'econ.dart';
import 'rules.dart';
import 'studio_models.dart';

const Object _keep = Object();
const defaultSkills = {'flow': 17, 'ecr': 14, 'voix': 10, 'cha': 8};

/// Statut d'une mission : 'todo' (à faire), 'done' (terminée, à récupérer), 'claimed' (récupérée).
const defaultMissions = {'m1': 'todo', 'm2': 'todo', 'm3': 'todo', 'm4': 'todo'};

/// État de partie (version 1 de la sauvegarde). Immuable ; chaque action renvoie un nouvel état.
/// Les champs ajoutés après la v1 ont une valeur par défaut : une ancienne sauvegarde reste lisible.
class GameState {
  final int version, cash, energy, day, hour, fans, pop, rep, xp;
  final String hood;

  /// Identifiant de l'instru choisie (Econ : instrus), null tant qu'aucune n'est choisie.
  final String? inst;

  /// Texte en cours d'écriture pour le son (A.write), null tant qu'aucun texte n'est écrit.
  final Texte? texte;

  /// Compétences (sk de game.js) : flow, ecr (écriture), voix, cha.
  final Map<String, int> sk;

  /// Notes de voix des prises de la dernière session de cabine (A.record).
  final List<int> takes;

  /// Dernier son enregistré (A.record), sorti ou non.
  final Song? song;

  /// Micro studio acheté (+8 à la voix). L'achat n'est pas encore porté.
  final bool micro;

  /// Statut des missions m1..m4.
  final Map<String, String> ms;

  /// Niveau atteint dont la récompense reste à récupérer (pend de game.js).
  final Pending? pend;

  /// Style choisi (STYLES de game.js).
  final String style;
  const GameState({
    this.version = 1, this.cash = 25000, this.energy = 100, this.day = 1, this.hour = 8, this.fans = 120, this.pop = 3, this.rep = 8, this.xp = 0, this.hood = 'Ndolo',
    this.inst, this.texte, this.sk = defaultSkills, this.takes = const [], this.song, this.micro = false, this.ms = defaultMissions, this.pend, this.style = 'drill',
  });

  int get level => levelOf(xp);
  String get levelName => Econ.levelNames[level - 1];

  /// Pour les champs nullables (inst, texte, song, pend), passer null efface la valeur ; ne rien passer la conserve.
  GameState copyWith({
    int? version, int? cash, int? energy, int? day, int? hour, int? fans, int? pop, int? rep, int? xp, String? hood,
    Object? inst = _keep, Object? texte = _keep, Map<String, int>? sk, List<int>? takes, Object? song = _keep, bool? micro, Map<String, String>? ms, Object? pend = _keep, String? style,
  }) =>
      GameState(
        version: version ?? this.version, cash: cash ?? this.cash, energy: energy ?? this.energy, day: day ?? this.day, hour: hour ?? this.hour,
        fans: fans ?? this.fans, pop: pop ?? this.pop, rep: rep ?? this.rep, xp: xp ?? this.xp, hood: hood ?? this.hood,
        inst: identical(inst, _keep) ? this.inst : inst as String?,
        texte: identical(texte, _keep) ? this.texte : texte as Texte?,
        sk: sk ?? this.sk, takes: takes ?? this.takes,
        song: identical(song, _keep) ? this.song : song as Song?,
        micro: micro ?? this.micro, ms: ms ?? this.ms,
        pend: identical(pend, _keep) ? this.pend : pend as Pending?,
        style: style ?? this.style,
      );

  Map<String, dynamic> toJson() => {
        'v': version, 'cash': cash, 'en': energy, 'day': day, 'hour': hour, 'fans': fans, 'pop': pop, 'rep': rep, 'xp': xp, 'hood': hood,
        'inst': inst, 'texte': texte?.toJson(), 'sk': sk, 'takes': takes, 'song': song?.toJson(), 'micro': micro, 'ms': ms, 'pend': pend?.toJson(), 'style': style,
      };
  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        version: (j['v'] ?? 1) as int, cash: (j['cash'] ?? 25000) as int, energy: (j['en'] ?? 100) as int, day: (j['day'] ?? 1) as int,
        hour: (j['hour'] ?? 8) as int, fans: (j['fans'] ?? 120) as int, pop: (j['pop'] ?? 3) as int, rep: (j['rep'] ?? 8) as int,
        xp: (j['xp'] ?? 0) as int, hood: (j['hood'] ?? 'Ndolo') as String, inst: j['inst'] as String?,
        texte: j['texte'] == null ? null : Texte.fromJson(Map<String, dynamic>.from(j['texte'] as Map)),
        sk: j['sk'] == null ? defaultSkills : Map<String, int>.from(j['sk'] as Map),
        takes: j['takes'] == null ? const [] : List<int>.from(j['takes'] as List),
        song: j['song'] == null ? null : Song.fromJson(Map<String, dynamic>.from(j['song'] as Map)),
        micro: (j['micro'] ?? false) as bool,
        ms: j['ms'] == null ? defaultMissions : {...defaultMissions, ...Map<String, String>.from(j['ms'] as Map)},
        pend: j['pend'] == null ? null : Pending.fromJson(Map<String, dynamic>.from(j['pend'] as Map)),
        style: (j['style'] ?? 'drill') as String,
      );
  String encode() => jsonEncode(toJson());
}

/// Erreurs métier affichables (mêmes codes que le prototype : cash, energie, niveau, rep…).
class GameError implements Exception {
  final String code;
  const GameError(this.code);

  /// Messages du prototype (ERR de game.js).
  String get message => switch (code) {
        'cash' => 'Cash insuffisant',
        'energie' => 'Énergie insuffisante : dors ou récupère',
        'niveau' => 'Niveau requis',
        'rep' => 'Réputation requise',
        'son' => 'Aucun son prêt à sortir',
        'rien' => 'Rien à récupérer',
        _ => 'Action impossible',
      };

  @override
  String toString() => 'GameError($code)';
}

/// Exemple d'action pure : payer un montant, jamais de cauris négatifs (invariant I-09).
GameState pay(GameState s, int amount) {
  if (s.cash + amount < 0) throw const GameError('cash');
  return s.copyWith(cash: s.cash + amount);
}
