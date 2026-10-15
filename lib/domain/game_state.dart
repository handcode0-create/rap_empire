import 'dart:convert';
import 'econ.dart';
import 'rules.dart';

/// État de partie (version 1 de la sauvegarde). Immuable ; chaque action renvoie un nouvel état.
class GameState {
  final int version, cash, energy, day, hour, fans, pop, rep, xp;
  final String hood;
  const GameState({this.version = 1, this.cash = 25000, this.energy = 100, this.day = 1, this.hour = 8, this.fans = 120, this.pop = 3, this.rep = 8, this.xp = 0, this.hood = 'Ndolo'});

  int get level => levelOf(xp);
  String get levelName => Econ.levelNames[level - 1];

  GameState copyWith({int? version, int? cash, int? energy, int? day, int? hour, int? fans, int? pop, int? rep, int? xp, String? hood}) => GameState(
        version: version ?? this.version, cash: cash ?? this.cash, energy: energy ?? this.energy, day: day ?? this.day, hour: hour ?? this.hour,
        fans: fans ?? this.fans, pop: pop ?? this.pop, rep: rep ?? this.rep, xp: xp ?? this.xp, hood: hood ?? this.hood);

  Map<String, dynamic> toJson() => {'v': version, 'cash': cash, 'en': energy, 'day': day, 'hour': hour, 'fans': fans, 'pop': pop, 'rep': rep, 'xp': xp, 'hood': hood};
  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        version: (j['v'] ?? 1) as int, cash: (j['cash'] ?? 25000) as int, energy: (j['en'] ?? 100) as int, day: (j['day'] ?? 1) as int,
        hour: (j['hour'] ?? 8) as int, fans: (j['fans'] ?? 120) as int, pop: (j['pop'] ?? 3) as int, rep: (j['rep'] ?? 8) as int,
        xp: (j['xp'] ?? 0) as int, hood: (j['hood'] ?? 'Ndolo') as String);
  String encode() => jsonEncode(toJson());
}

/// Erreurs métier affichables (mêmes codes que le prototype : cash, energie, niveau, rep…).
class GameError implements Exception {
  final String code;
  const GameError(this.code);
}

/// Exemple d'action pure : payer un montant, jamais de cauris négatifs (invariant I-09).
GameState pay(GameState s, int amount) {
  if (s.cash + amount < 0) throw const GameError('cash');
  return s.copyWith(cash: s.cash + amount);
}
