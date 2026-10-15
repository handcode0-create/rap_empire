import 'clock.dart';
import 'econ.dart';
import 'game_state.dart';
import 'rules.dart';
import 'studio_models.dart';

/// Actions du studio. Port de A.pick, A.write, A.record et A.release (game.js v20), fonctions pures : aucune dépendance Flutter ni Supabase.

Instru instruById(String id) => instrus.firstWhere((i) => i.id == id, orElse: () => throw const GameError('inconnu'));

/// Code d'erreur qui bloquerait le choix de l'instru (null si possible). Même ordre que A.pick : niveau, réputation, cash.
String? pickBlocker(GameState s, String id) {
  final i = instruById(id);
  if (i.lvl > s.level) return 'niveau';
  if (i.rep > 0 && s.rep < i.rep) return 'rep';
  if (s.cash < i.price) return 'cash';
  return null;
}

/// Une confirmation est demandée à partir de [Econ.confirmFrom] cauris (achat d'instru, promo).
bool needsConfirm(int amount) => amount >= Econ.confirmFrom;

/// A.pick : choisir une instru, payée tout de suite si elle est payante.
GameState pick(GameState s, String id) {
  final code = pickBlocker(s, id);
  if (code != null) throw GameError(code);
  final i = instruById(id);
  return (i.price > 0 ? pay(s, -i.price) : s).copyWith(inst: i.id, texte: null, takes: const [], song: null);
}

/// Écriture : 1 h et 20 énergie (A.write).
const writeHours = 1, writeEnergy = 20;

/// Note de base du texte, puis décalages d'ambiance et de thème (A.write : 72 + ambiance + thème).
const baseNote = 72;
const ambOffsets = {'sombre': 0, 'fiere': 2, 'legere': -2};
const themeOffsets = {'quartier': 0, 'galere': 1, 'ambition': 2, 'amour': -1};
const ambNames = {'sombre': 'Sombre', 'fiere': 'Fière', 'legere': 'Légère'};
const themeNames = {'quartier': 'Le quartier', 'galere': 'La galère', 'ambition': "L'ambition", 'amour': "L'amour"};

/// Gain de compétence d'écriture par texte (sk.ecr += 2).
const writeSkillGain = 2;

/// Note d'un texte pour un thème et une ambiance (sans effet sur l'état).
int textNote(String theme, String amb) {
  final a = ambOffsets[amb], t = themeOffsets[theme];
  if (a == null || t == null) throw const GameError('inconnu');
  return baseNote + a + t;
}

/// A.write : énergie -20, +1 h, note du texte, écriture +2. Erreur 'energie' sous 20.
GameState write(GameState s, {String theme = 'quartier', String amb = 'sombre'}) {
  if (s.energy < writeEnergy) throw const GameError('energie');
  final note = textNote(theme, amb);
  final n = tick(s.copyWith(energy: s.energy - writeEnergy), writeHours);
  return n.copyWith(texte: Texte(note, theme, amb), sk: {...n.sk, 'ecr': n.sk['ecr']! + writeSkillGain});
}

/// XP : A.addXp. Un niveau gagné laisse sa récompense à récupérer (pend) ; un pend existant est écrasé, comme dans le prototype.
GameState addXp(GameState s, int xp) {
  final n = s.copyWith(xp: s.xp + xp);
  return n.level > s.level ? n.copyWith(pend: Pending(n.level, Econ.levelReward[n.level] ?? 0)) : n;
}

/// Cabine : 2 h et 25 énergie (A.record).
const recordHours = 2, recordEnergy = 25;

/// Prises simulées du prototype (mode « Simuler les 3 prises » : le mini-jeu de timing n'est pas porté).
const defaultTakes = [74, 48, 43];

/// Note de texte sans texte écrit, production sans instru, bonus du micro studio, gain de voix (A.record).
const noTextNote = 60, noInstruProd = 32, microVoiceBonus = 8, recordVoiceGain = 1;

/// Style du joueur (STYLES de game.js).
const styleNames = {'drill': 'Drill de Bakoma', 'conscient': 'Rap conscient', 'coupe': 'Coupé-décalé rap', 'trap': 'Trap bakomaise'};

/// A.record : cabine puis mix. Qualité = quality() avec l'énergie à l'entrée en cabine (malus de forme).
/// Ajoute le son, XP, voix +1, mission 1 terminée. Erreur 'energie' sous 25.
GameState record(GameState s, [List<int>? takes]) {
  if (s.energy < recordEnergy) throw const GameError('energie');
  final t = (takes == null || takes.isEmpty) ? defaultTakes : takes;
  final voix = (t.reduce((a, b) => a + b) / t.length).round() + (s.micro ? microVoiceBonus : 0);
  final instru = s.inst == null ? null : instruById(s.inst!);
  final prod = instru?.q ?? noInstruProd;
  final tx = s.texte?.note ?? noTextNote;
  final song = Song(
    title: s.inst == 'nuit' ? 'Nuit à Ndo' : 'Gbaka de 6h', // titre fixe du prototype : « Gbaka de 6h » sauf pour la Nuit
    q: quality(tx, voix, prod, s.energy),
    texte: tx, voix: voix, prod: prod, inst: instru?.name ?? '',
  );
  var n = tick(s.copyWith(energy: s.energy - recordEnergy), recordHours).copyWith(
    takes: t,
    song: song,
    sk: {...s.sk, 'voix': s.sk['voix']! + recordVoiceGain},
    ms: s.ms['m1'] == 'todo' ? {...s.ms, 'm1': 'done'} : s.ms,
  );
  n = addXp(n, Econ.xpRecord);
  return n;
}

/// Étape du parcours « nouveau son » à reprendre, déduite de l'état sauvegardé (restauration de l'écran).
enum StudioStep { instru, ecriture, cabine, sortie }

StudioStep studioStep(GameState s) {
  final song = s.song;
  if (song != null) return song.released ? StudioStep.instru : StudioStep.sortie;
  if (s.inst == null) return StudioStep.instru;
  if (s.texte == null) return StudioStep.ecriture;
  return StudioStep.cabine;
}

/// Nombre de sons du studio : sons sortis plus le son à sortir.
int songCount(GameState s) => s.disco.length + ((s.song != null && !s.song!.released) ? 1 : 0);

/// Aperçu de la sortie (planches 05.1 et 05.1b) : écoutes et revenus estimés, cash après promo.
class ReleasePreview {
  final int listens, revenue, promoCost, cashAfter;
  final bool affordable;
  const ReleasePreview({required this.listens, required this.revenue, required this.promoCost, required this.cashAfter, required this.affordable});
}

ReleasePreview releasePreview(GameState s, int promo) {
  final song = s.song;
  if (song == null) throw const GameError('son');
  if (promo < 0 || promo >= promos.length) throw const GameError('inconnu');
  final listens = listensFor(song.q, s.fans, promo);
  final cost = promos[promo].cost;
  return ReleasePreview(listens: listens, revenue: (listens * Econ.monetised * Econ.listenValue).round(), promoCost: cost, cashAfter: s.cash - cost, affordable: s.cash >= cost);
}

/// A.release : sortie d'un single avec la promo [promo] (index de promos).
/// Promo payée, écoutes (listensFor), revenus (0,01 cauri par écoute monétisée), fans, popularité, résultat, XP, jour suivant 08:00 énergie 100.
/// Écart assumé avec game.js : le son est marqué « sorti » et entre en discographie ; le prototype laissait le même son ressortable.
GameState release(GameState s, int promo) {
  final song = s.song;
  if (song == null || song.released) throw const GameError('son');
  if (promo < 0 || promo >= promos.length) throw const GameError('inconnu');
  final p = promos[promo];
  if (s.cash < p.cost) throw const GameError('cash');
  var n = p.cost > 0 ? pay(s, -p.cost) : s;
  final listens = listensFor(song.q, n.fans, promo);
  final rev = (listens * Econ.monetised * Econ.listenValue).round();
  final fg = (listens * Econ.fanConversion / (1 + n.fans / Econ.fanSat)).ceil();
  final pg = (listens / Econ.listensPerPop).floor();
  n = pay(n, rev);
  n = n.copyWith(
    fans: n.fans + fg, pop: n.pop + pg, fgain: n.fgain + fg,
    lw: (listens * Econ.weekFactor).round(), lc: n.lc + listens,
    rel: Release(title: song.title, listens: listens, revenue: rev, fans: fg, pop: pg, promo: promo, q: song.q),
    song: song.copyWith(released: true),
    disco: [...n.disco, DiscoEntry(title: song.title, q: song.q, listens: listens)],
    day: n.day + 1, hour: wakeHour, energy: maxEnergy,
  );
  n = addXp(n, Econ.xpRelease);
  final ms = {...n.ms};
  if (ms['m2'] == 'todo') ms['m2'] = 'done';
  if (n.fans >= 1000 && ms['m4'] == 'todo') ms['m4'] = 'done';
  return n.copyWith(ms: ms);
}
