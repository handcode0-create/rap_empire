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
  static const openMicFee = 3000; // cachet de l'open mic (ECON.openMicFee de game.js) : récompense annoncée par la mission « open mic » (10.3)
  static const xpOpenMic = 60; // XP d'un open mic gagné (A.openmic)
  static const battleFee = 3000; // prime d'une battle gagnée (ECON.battleFee de game.js)
  static const concertFee = 25000; // cachet maximal du concert (ECON.concertFee de game.js)
  static const monetised = 1.0; // part des écoutes monétisées (démo : 100 %)
  static const fanSat = 5000; // saturation de la conversion en fans (évite la croissance exponentielle), test D-08
  static const fanConversion = 0.07; // part des écoutes qui devient fans (avant saturation)
  static const listensPerPop = 900; // écoutes pour 1 point de popularité
  static const catalogDaily = 0.08; // écoutes du 1er jour après la sortie = 8 % des écoutes de la sortie (catalogue : revenus passifs)
  static const catalogDecay = 0.8; // chaque jour, le son est écouté 20 % de moins
  static const catalogDays = 14; // au-delà, le son n'est plus à la mode : plus d'écoutes
  static const weekFactor = 1.5; // écoutes de la semaine = écoutes de la sortie x 1,5 (lw)
  static const microPrice = 18000; // ECON.micro : prix du micro studio (A.gear)
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

/// Récompense d'une mission (cauris et XP), MISSIONS de game.js. Provisoire (D-08).
class MissionReward {
  final int cash, xp;
  const MissionReward(this.cash, this.xp);
}

const missionRewards = {
  'm1': MissionReward(5000, 50),
  'm2': MissionReward(10000, 80),
  'm3': MissionReward(4000, 60),
  'm4': MissionReward(15000, 120),
  'm5': MissionReward(6000, 70),
  'm6': MissionReward(8000, 90),
  'm7': MissionReward(20000, 150),
  'm8': MissionReward(12000, 100),
  'm9': MissionReward(30000, 200),
  'm10': MissionReward(15000, 120),
};

/// Formation (table F de A.formation, game.js) : coût en cauris, énergie, heures, compétence gagnée. [unlocksMission3] : l'atelier d'écriture termine la mission 3.
class Formation {
  final String id, name, skill;
  final int hours, cost, energy, gain;
  final bool unlocksMission3;
  const Formation(this.id, this.name, this.skill, {required this.hours, required this.cost, required this.energy, required this.gain, this.unlocksMission3 = false});
}

const formations = [
  Formation('ecr', "Atelier d'écriture", 'ecr', hours: 2, cost: 6000, energy: 20, gain: 5, unlocksMission3: true),
  Formation('flow', 'Freestyle au carrefour', 'flow', hours: 1, cost: 0, energy: 15, gain: 2),
  Formation('voix', 'Coach vocal', 'voix', hours: 2, cost: 9000, energy: 20, gain: 5),
  Formation('cha', 'Shooting et réseaux', 'cha', hours: 2, cost: 7000, energy: 15, gain: 4),
];

/// Équipement affiché par la planche 09.1. Seul le micro studio a une règle dans game.js (A.gear : +8 à la voix, voir record()) ;
/// le casque (+4 mix) et la carte son (+6 mix) n'ont aucune formule : leurs valeurs sont celles de la planche, sans effet ni achat. [implemented] : règle portée.
class GearItem {
  final String id, name, effect, icon;
  final int price;
  final bool implemented;
  const GearItem(this.id, this.name, this.effect, this.price, this.icon, {this.implemented = false});
}

const gearItems = [
  GearItem('micro', 'Micro studio', 'Qualité enregistrement +8', Econ.microPrice, 'mic', implemented: true),
  GearItem('casque', 'Casque monitoring', 'Qualité mix +4', 12000, 'music'),
  GearItem('carte', 'Carte son', 'Qualité mix +6', 30000, 'briefcase'),
];
