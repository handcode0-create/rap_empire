import 'game_state.dart';
import 'rules.dart';
import 'studio_models.dart';

/// Scène A : producteur DJ Kôrô. Port de KD et A.kdeal (docs/design-ref/game.js, v20). Fonctions pures, aucune dépendance Flutter ni Supabase.
/// Valeurs de DÉMO (D-08) : la part de Kôrô n'est pas appliquée aux revenus ; seuls le coût en cauris, le bonus de production
/// (record() dans studio.dart) et la relation sont réels. Le calendrier (créneaux, « 3 semaines plus tard ») n'est pas géré.

/// Un choix de la scène (entrée de KD) : [id] est le code de game.js (data-act="kdeal:<id>").
class KoreChoice {
  final String id, cut, st;
  final int cost, rel, bonus, left;
  const KoreChoice(this.id, {required this.cut, required this.cost, required this.rel, required this.bonus, required this.left, required this.st});
}

const koreChoices = {
  'acc': KoreChoice('acc', cut: '40 %', cost: 8000, rel: 15, bonus: 12, left: 3, st: 'acc'),
  'neg': KoreChoice('neg', cut: '35 %', cost: 7000, rel: 8, bonus: 12, left: 3, st: 'neg'),
  'ins': KoreChoice('ins', cut: '30 %', cost: 0, rel: -5, bonus: 0, left: 0, st: 'ref'),
  'ref': KoreChoice('ref', cut: '', cost: 0, rel: -10, bonus: 0, left: 0, st: 'ref'),
  'back': KoreChoice('back', cut: '45 %', cost: 6000, rel: 5, bonus: 12, left: 3, st: 'back'),
  'assist': KoreChoice('assist', cut: 'tarif assistant', cost: 0, rel: 0, bonus: 6, left: 2, st: 'assist'),
  'decl': KoreChoice('decl', cut: '', cost: 0, rel: -15, bonus: 0, left: 0, st: 'decl'),
};

/// États qui valent accord conclu (kcDone de game.js) : aucun nouveau choix n'est possible.
const koreDoneStates = {'acc', 'neg', 'back', 'assist'};

bool koreDone(GameState s) => koreDoneStates.contains(s.kc.st);

/// Motif qui bloquerait le choix (null si possible). Même ordre que A.kdeal : inconnu, accord déjà conclu, cash.
String? koreBlocker(GameState s, String id) {
  final d = koreChoices[id];
  if (d == null) return 'inconnu';
  if (koreDone(s)) return 'accord';
  if (s.cash < d.cost) return 'cash';
  return null;
}

/// A.kdeal : le coût est payé tout de suite (registre : catégorie « instru », « Studio Kôrô : accord »), la relation s'ajoute à la précédente,
/// l'accord remplace le précédent (un refus, 'ref' ou 'decl', n'empêche pas un nouveau choix).
GameState kdeal(GameState s, String id) {
  final code = koreBlocker(s, id);
  if (code != null) throw GameError(code);
  final d = koreChoices[id]!;
  final n = d.cost > 0 ? pay(s, -d.cost, cat: 'instru', label: 'Studio Kôrô : accord') : s;
  return n.copyWith(kc: KoreDeal(st: d.st, rel: s.kc.rel + d.rel, cut: d.cut, cost: d.cost, left: d.left, bonus: d.bonus));
}

/// kcSt de game.js : libellé de l'état de l'accord.
String koreStatusLabel(KoreDeal kc) => switch (kc.st) {
      'acc' => 'Accord à 40 %',
      'neg' => 'Accord à 35 % (mix signé)',
      'ref' => 'Refus : il se souvient',
      'back' => 'Accord à 45 %',
      'assist' => 'Via son assistant',
      'decl' => 'Refus définitif',
      _ => 'Aucun accord',
    };

/// kcBonus de game.js : « +12 production · 3 titres » ou « aucun ».
String koreBonusLabel(KoreDeal kc) => kc.left > 0 ? '+${kc.bonus} production · ${kc.left} titre${kc.left > 1 ? 's' : ''}' : 'aucun';

/// kcRel de game.js : relation signée.
String koreRelLabel(int rel) => '${rel > 0 ? '+' : ''}$rel';

/// Coût d'un choix en texte (« −8 000 cauris »), vide s'il est gratuit.
String koreCostLabel(String id) => koreChoices[id]!.cost == 0 ? '' : '−${fmt(koreChoices[id]!.cost)} cauris';

/// Bonus que donnerait un choix (« +12 production · 3 titres »), avant de le prendre.
String koreChoiceBonusLabel(String id) => koreBonusLabel(KoreDeal(bonus: koreChoices[id]!.bonus, left: koreChoices[id]!.left));
