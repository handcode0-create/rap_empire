/// Économie de DÉMONSTRATION — paramètres provisoires (D-08), centralisés ici. NON VALIDÉS.
/// Port fidèle de ECON dans le moteur du prototype v20 (game.js ; engine.js n'est pas dans l'archive).
class Econ {
  static const listenValue = 0.01; // cauris par écoute monétisée
  static const labelCut = 0.20; // commission label sur revenus nets du catalogue sous contrat
  static const nightCost = 0;
  static const labelAdvance = 150000;
  static const listenCap = 15000000;
  static const mgrCut = 0.08;
  static const featFee = 8000;
  static const featBoost = 1.15;
  static const levelXp = [0, 100, 250, 500, 900]; // N1..N5
  static const levelNames = ['Inconnu', 'Espoir du quartier', 'Révélation locale', 'Nom qui circule', 'Star de Bakoma'];
  static const entryListens = 252200; // seuil d'entrée Top 100 Singles (R25, proposition)
  static const levelReward = {2: 2000, 3: 4000, 4: 8000, 5: 15000}; // cauris offerts au passage de niveau (ECON.levelReward)
  static const xpRecord = 30; // XP d'un mix terminé (A.record)
  static const xpRelease = 40; // XP d'une sortie (A.release)
  static const monetised = 1.0; // part des écoutes monétisées (démo : 100 %)
  static const fanSat = 5000; // saturation de la conversion en fans (évite la croissance exponentielle), test D-08
  static const fanConversion = 0.07; // part des écoutes qui devient fans (avant saturation)
  static const listensPerPop = 900; // écoutes pour 1 point de popularité
  static const weekFactor = 1.5; // écoutes de la semaine = écoutes de la sortie x 1,5 (lw)
  static const confirmFrom = 15000; // confirmation d'achat ou de promo à partir de ce montant (promoCbig de game.js : >= 15000)
}

class Promo {
  final String name;
  final int cost;
  final double mult;
  const Promo(this.name, this.cost, this.mult);
}

const promos = [Promo('Aucune', 0, 1), Promo('Réseaux sociaux', 2000, 1.6), Promo('Radio locale', 15000, 3.2)];

/// Instrus du studio (INSTRU de game.js). [rep] = 0 : pas de condition de réputation.
class Instru {
  final String id, name, who;
  final int q, price, lvl, rep;
  const Instru(this.id, this.name, this.who, this.q, this.price, this.lvl, [this.rep = 0]);
}

const instrus = [
  Instru('nuit', 'Nuit à Ndo', 'Gratuite', 32, 0, 1),
  Instru('gbaka', 'Gbaka de 6h', 'DJ Kôrô', 56, 8000, 1),
  Instru('pont', 'Pont des Griots', 'Sanko Beats', 68, 15000, 2),
  Instru('lagune', "Lagune d'Ambre", 'Mister Wôrô', 86, 40000, 1, 30),
];
