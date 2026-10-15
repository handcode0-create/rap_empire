import 'dart:convert';
import 'econ.dart';
import 'rules.dart';

const Object _keep = Object();

/// État de partie (version 1 de la sauvegarde). Immuable ; chaque action renvoie un nouvel état.
/// Les champs ajoutés après la v1 ont une valeur par défaut : une ancienne sauvegarde reste lisible.
class GameState {
  final int version, cash, energy, day, hour, fans, pop, rep, xp;
  final String hood;

  /// Identifiant de l'instru choisie (Econ : instrus), null tant qu'aucune n'est choisie.
  final String? inst;
  const GameState({this.version = 1, this.cash = 25000, this.energy = 100, this.day = 1, this.hour = 8, this.fans = 120, this.pop = 3, this.rep = 8, this.xp = 0, this.hood = 'Ndolo', this.inst});

  int get level => levelOf(xp);
  String get levelName => Econ.levelNames[level - 1];

  /// Pour les champs nullables (inst), passer null efface la valeur ; ne rien passer la conserve.
  GameState copyWith({int? version, int? cash, int? energy, int? day, int? hour, int? fans, int? pop, int? rep, int? xp, String? hood, Object? inst = _keep}) => GameState(
        version: version ?? this.version, cash: cash ?? this.cash, energy: energy ?? this.energy, day: day ?? this.day, hour: hour ?? this.hour,
        fans: fans ?? this.fans, pop: pop ?? this.pop, rep: rep ?? this.rep, xp: xp ?? this.xp, hood: hood ?? this.hood,
        inst: identical(inst, _keep) ? this.inst : inst as String?);

  Map<String, dynamic> toJson() => {'v': version, 'cash': cash, 'en': energy, 'day': day, 'hour': hour, 'fans': fans, 'pop': pop, 'rep': rep, 'xp': xp, 'hood': hood, 'inst': inst};
  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        version: (j['v'] ?? 1) as int, cash: (j['cash'] ?? 25000) as int, energy: (j['en'] ?? 100) as int, day: (j['day'] ?? 1) as int,
        hour: (j['hour'] ?? 8) as int, fans: (j['fans'] ?? 120) as int, pop: (j['pop'] ?? 3) as int, rep: (j['rep'] ?? 8) as int,
        xp: (j['xp'] ?? 0) as int, hood: (j['hood'] ?? 'Ndolo') as String, inst: j['inst'] as String?);
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
