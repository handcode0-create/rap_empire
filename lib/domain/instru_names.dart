import 'econ.dart';
import 'game_state.dart';
import 'music_catalog.dart';

/// Noms des instrus. Les quatre instrus gardent leur identité (qualité, prix, producteur) ; leur nom change d'un jour à l'autre
/// et d'une partie à l'autre, tiré de la bibliothèque d'instrumentales (music_catalog.dart) : un style par instru, plus les noms français.
/// Déterministe : même partie et même jour, mêmes noms. Partie de départ (graine 0, jour 1) : les noms d'origine du prototype.

/// Style musical de chaque instru : la gratuite est du boom bap brut, Kôrô fait de l'afro-rap, Sanko de la trap, Wôrô du luxury rap.
const _styles = {'nuit': 'boombap', 'gbaka': 'afro', 'pont': 'trap', 'lagune': 'luxury'};

/// Pas de parcours premiers avec 25 (la taille d'un style) : un nom différent chaque jour pendant 25 jours.
const _steps = {'nuit': 3, 'gbaka': 7, 'pont': 11, 'lagune': 13};

InstrumentalStyle instruStyle(String id) => instrumentalStyleById(_styles[id]!);

/// Nom de l'instru [id] pour cette partie et ce jour.
String instruName(GameState s, String id) {
  if (s.seed == 0 && s.day == 1) return instrus.firstWhere((i) => i.id == id).name;
  final pool = instrumentalNames(_styles[id]!);
  return pool[((s.seed.abs() + s.day) * _steps[id]!) % pool.length];
}

/// L'instru [base] avec son nom du jour.
Instru named(GameState s, Instru base) => Instru(base.id, instruName(s, base.id), base.who, base.q, base.price, base.lvl, base.rep);

/// L'instru choisie, avec le nom qu'elle avait quand elle a été choisie (sinon son nom du jour).
Instru instruChosen(GameState s) {
  final base = instrus.firstWhere((i) => i.id == s.inst);
  final n = s.instName;
  return n == null ? named(s, base) : Instru(base.id, n, base.who, base.q, base.price, base.lvl, base.rep);
}

/// Thèmes qui vont bien avec chaque style d'instru.
const _fits = {
  'boombap': ['ego', 'introspection', 'rue'],
  'afro': ['identite', 'fete', 'amour'],
  'trap': ['trap', 'rue', 'ego'],
  'luxury': ['argent', 'gloire', 'ambition'],
};

/// Potentiel viral (0 à 100) : la qualité du son, plus 10 si le thème va avec le style de l'instru. Indicatif : il n'agit pas encore sur les écoutes.
int viralPotential(int q, String instruId, String theme) {
  final fit = (_fits[_styles[instruId]] ?? const []).contains(theme) ? 10 : 0;
  return (q * 0.9 + fit).round().clamp(0, 100);
}

/// Les quatre instrus avec leurs noms du jour.
List<Instru> instrusFor(GameState s) => [for (final i in instrus) named(s, i)];
