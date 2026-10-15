/// Économie de DÉMONSTRATION — paramètres provisoires (D-08), centralisés ici. NON VALIDÉS.
/// Port fidèle de ECON dans le moteur du prototype v20 (engine.js).
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
}

class Promo {
  final String name;
  final int cost;
  final double mult;
  const Promo(this.name, this.cost, this.mult);
}

const promos = [Promo('Aucune', 0, 1), Promo('Réseaux sociaux', 2000, 1.6), Promo('Radio locale', 15000, 3.2)];
