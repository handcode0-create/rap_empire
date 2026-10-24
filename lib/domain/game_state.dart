import 'dart:convert';
import 'econ.dart';
import 'rules.dart';
import 'studio_models.dart';

const Object _keep = Object();
const defaultSkills = {'flow': 17, 'ecr': 14, 'voix': 10, 'cha': 8};

/// Totaux par catégorie du registre (cat de game.js).
const defaultCat = {'manager': 0, 'label': 0, 'ecoutes': 0, 'cachets': 0, 'mission': 0, 'instru': 0, 'promo': 0, 'materiel': 0, 'formation': 0, 'boutique': 0, 'niveau': 0};

/// Statut d'une mission : 'todo' (à faire), 'done' (terminée, à récupérer), 'claimed' (récupérée).
const defaultMissions = {'m1': 'todo', 'm2': 'todo', 'm3': 'todo', 'm4': 'todo', 'm5': 'todo', 'm6': 'todo', 'm7': 'todo', 'm8': 'todo', 'm9': 'todo', 'm10': 'todo'};

/// État de partie (version 1 de la sauvegarde). Immuable ; chaque action renvoie un nouvel état.
/// Les champs ajoutés après la v1 ont une valeur par défaut : une ancienne sauvegarde reste lisible.
class GameState {
  final int version, cash, energy, day, hour, fans, pop, rep, xp;
  final String hood;

  /// Identifiant de l'instru choisie (Econ : instrus), null tant qu'aucune n'est choisie.
  final String? inst;

  /// Nom de l'instru au moment où elle a été choisie : il ne change pas si le jour change avant la fin du morceau.
  final String? instName;

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

  /// Titre du son en cours (généré à l'écriture, relançable ou saisi), null tant qu'aucun texte n'est écrit.
  final String? title;

  /// Dernière sortie (rel de game.js), null avant la première.
  final Release? rel;

  /// Sons sortis, du plus ancien au plus récent.
  final List<DiscoEntry> disco;

  /// Écoutes de la semaine (lw), écoutes cumulées (lc) et fans gagnés par les sorties (fgain) de game.js.
  final int lw, lc, fgain;

  /// Registre des mouvements de cauris (led de game.js), le plus récent d'abord, et totaux par catégorie (cat).
  final List<LedgerEntry> led;
  final Map<String, int> cat;

  /// Accord avec DJ Kôrô (kc de game.js).
  final KoreDeal kc;

  /// Vrai tant que le dialogue d'introduction de Kôrô (planche 16-A1) n'a pas été montré : il s'ouvre à la première visite au Studio.
  /// Faux par défaut (anciennes sauvegardes, tests) ; vrai pour une nouvelle partie.
  final bool koreIntro;

  /// Graine de la partie : fait varier les noms des instrus (instru_names.dart). 0 pour une ancienne sauvegarde : noms d'origine.
  final int seed;

  /// Garde-robe v21 : tenues achetées, tenue équipée et variante visuelle du personnage.
  final List<String> outfitOwned;
  final String equippedOutfit;
  final String avatarStage;
  const GameState({
    this.version = 1, this.cash = 25000, this.energy = 100, this.day = 1, this.hour = 8, this.fans = 120, this.pop = 3, this.rep = 8, this.xp = 0, this.hood = 'Ndolo',
    this.inst, this.instName, this.texte, this.sk = defaultSkills, this.takes = const [], this.song, this.micro = false, this.ms = defaultMissions, this.pend, this.style = 'drill',
    this.rel, this.disco = const [], this.lw = 0, this.lc = 0, this.fgain = 0, this.led = const [], this.cat = defaultCat, this.title, this.kc = const KoreDeal(), this.koreIntro = false, this.seed = 0,
    this.outfitOwned = const ['OUTFIT_001'], this.equippedOutfit = 'OUTFIT_001', this.avatarStage = 'young',
  });

  int get level => levelOf(xp);
  String get levelName => Econ.levelNames[level - 1];

  /// Pour les champs nullables (inst, texte, song, pend), passer null efface la valeur ; ne rien passer la conserve.
  GameState copyWith({
    int? version, int? cash, int? energy, int? day, int? hour, int? fans, int? pop, int? rep, int? xp, String? hood,
    Object? inst = _keep, Object? instName = _keep, Object? texte = _keep, Map<String, int>? sk, List<int>? takes, Object? song = _keep, bool? micro, Map<String, String>? ms, Object? pend = _keep, String? style,
    Object? rel = _keep, List<DiscoEntry>? disco, int? lw, int? lc, int? fgain, List<LedgerEntry>? led, Map<String, int>? cat, Object? title = _keep, KoreDeal? kc, bool? koreIntro, int? seed,
    List<String>? outfitOwned, String? equippedOutfit, String? avatarStage,
  }) =>
      GameState(
        version: version ?? this.version, cash: cash ?? this.cash, energy: energy ?? this.energy, day: day ?? this.day, hour: hour ?? this.hour,
        fans: fans ?? this.fans, pop: pop ?? this.pop, rep: rep ?? this.rep, xp: xp ?? this.xp, hood: hood ?? this.hood,
        inst: identical(inst, _keep) ? this.inst : inst as String?,
        instName: identical(instName, _keep) ? this.instName : instName as String?,
        texte: identical(texte, _keep) ? this.texte : texte as Texte?,
        sk: sk ?? this.sk, takes: takes ?? this.takes,
        song: identical(song, _keep) ? this.song : song as Song?,
        micro: micro ?? this.micro, ms: ms ?? this.ms,
        pend: identical(pend, _keep) ? this.pend : pend as Pending?,
        style: style ?? this.style,
        rel: identical(rel, _keep) ? this.rel : rel as Release?,
        disco: disco ?? this.disco, lw: lw ?? this.lw, lc: lc ?? this.lc, fgain: fgain ?? this.fgain,
        led: led ?? this.led, cat: cat ?? this.cat,
        title: identical(title, _keep) ? this.title : title as String?,
        kc: kc ?? this.kc, koreIntro: koreIntro ?? this.koreIntro, seed: seed ?? this.seed,
        outfitOwned: outfitOwned ?? this.outfitOwned, equippedOutfit: equippedOutfit ?? this.equippedOutfit, avatarStage: avatarStage ?? this.avatarStage,
      );

  Map<String, dynamic> toJson() => {
        'v': version, 'cash': cash, 'en': energy, 'day': day, 'hour': hour, 'fans': fans, 'pop': pop, 'rep': rep, 'xp': xp, 'hood': hood,
        'inst': inst, 'in': instName, 'texte': texte?.toJson(), 'sk': sk, 'takes': takes, 'song': song?.toJson(), 'micro': micro, 'ms': ms, 'pend': pend?.toJson(), 'style': style,
        'rel': rel?.toJson(), 'disco': disco.map((d) => d.toJson()).toList(), 'lw': lw, 'lc': lc, 'fgain': fgain,
        'led': led.map((e) => e.toJson()).toList(), 'cat': cat, 'title': title, 'kc': kc.toJson(), 'ki': koreIntro, 'sd': seed,
        'outfitOwned': outfitOwned, 'equippedOutfit': equippedOutfit, 'avatarStage': avatarStage,
      };
  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        version: (j['v'] ?? 1) as int, cash: (j['cash'] ?? 25000) as int, energy: (j['en'] ?? 100) as int, day: (j['day'] ?? 1) as int,
        hour: (j['hour'] ?? 8) as int, fans: (j['fans'] ?? 120) as int, pop: (j['pop'] ?? 3) as int, rep: (j['rep'] ?? 8) as int,
        xp: (j['xp'] ?? 0) as int, hood: (j['hood'] ?? 'Ndolo') as String, inst: j['inst'] as String?, instName: j['in'] as String?,
        texte: j['texte'] == null ? null : Texte.fromJson(Map<String, dynamic>.from(j['texte'] as Map)),
        sk: j['sk'] == null ? defaultSkills : Map<String, int>.from(j['sk'] as Map),
        takes: j['takes'] == null ? const [] : List<int>.from(j['takes'] as List),
        song: j['song'] == null ? null : Song.fromJson(Map<String, dynamic>.from(j['song'] as Map)),
        micro: (j['micro'] ?? false) as bool,
        ms: j['ms'] == null ? defaultMissions : {...defaultMissions, ...Map<String, String>.from(j['ms'] as Map)},
        pend: j['pend'] == null ? null : Pending.fromJson(Map<String, dynamic>.from(j['pend'] as Map)),
        style: (j['style'] ?? 'drill') as String,
        rel: j['rel'] == null ? null : Release.fromJson(Map<String, dynamic>.from(j['rel'] as Map)),
        disco: j['disco'] == null ? const [] : [for (final d in j['disco'] as List) DiscoEntry.fromJson(Map<String, dynamic>.from(d as Map))],
        lw: (j['lw'] ?? 0) as int, lc: (j['lc'] ?? 0) as int, fgain: (j['fgain'] ?? 0) as int,
        led: j['led'] == null ? const [] : [for (final e in j['led'] as List) LedgerEntry.fromJson(Map<String, dynamic>.from(e as Map))],
        cat: j['cat'] == null ? defaultCat : {...defaultCat, ...Map<String, int>.from(j['cat'] as Map)},
        title: j['title'] as String?,
        kc: j['kc'] == null ? const KoreDeal() : KoreDeal.fromJson(Map<String, dynamic>.from(j['kc'] as Map)),
        koreIntro: (j['ki'] ?? false) as bool,
        seed: (j['sd'] ?? 0) as int,
        outfitOwned: j['outfitOwned'] == null ? const ['OUTFIT_001'] : List<String>.from(j['outfitOwned'] as List),
        equippedOutfit: (j['equippedOutfit'] ?? 'OUTFIT_001') as String,
        avatarStage: (j['avatarStage'] ?? 'young') as String,
      );
  String encode() => jsonEncode(toJson());
}

/// État d'une NOUVELLE partie : celui de départ, avec le dialogue d'introduction de Kôrô (16-A1) à montrer à la première visite au Studio.
const newGameState = GameState(koreIntro: true);

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
        'deja' => 'Déjà acheté',
        'accord' => 'Accord déjà conclu avec Kôrô',
        'attente' => 'Sors ton son en attente avant d’en créer un autre',
        _ => 'Action impossible',
      };

  @override
  String toString() => 'GameError($code)';
}

/// Payer ou encaisser un montant, jamais de cauris négatifs (invariant I-09). Avec [label], l'opération est inscrite au registre
/// (pay de game.js : led en tête de liste, total de la catégorie [cat] mis à jour).
GameState pay(GameState s, int amount, {String? cat, String? label}) {
  if (s.cash + amount < 0) throw const GameError('cash');
  return s.copyWith(
    cash: s.cash + amount,
    led: label == null ? null : [LedgerEntry(label: label, amount: amount, cat: cat, day: s.day), ...s.led],
    cat: cat == null ? null : {...s.cat, cat: (s.cat[cat] ?? 0) + amount},
  );
}
