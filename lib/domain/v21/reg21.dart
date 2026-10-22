// ignore_for_file: prefer_const_declarations
// RAP EMPIRE v21 : paramètres de la zone de consolidation (planche 21-00b Réglages).
// Port de REG, CANDS, EVT et FEV de docs/RAP-EMPIRE-v21/sources/engine21.js. Toutes les valeurs sont PROVISOIRES (D-08) et centralisées ici.
// Les structures restent des maps comme dans le moteur d'origine : l'état v21 est un JSON, sauvegardé tel quel.

typedef J = Map<String, dynamic>;

class Reg21 {
  // temps et âge
  static const daysPerYear = 364,
      startAge = 19,
      dayStart = 8,
      dayEnd = 24,
      babyMorning = 5;
  static const enMaxByAge = [(0, 100), (30, 95), (40, 88), (50, 80), (60, 72)];

  // petits boulots
  static const jobs = <String, J>{
    'livraison': {
      'n': 'Livraison à moto · Ndolo',
      'h': 4,
      'e': 25,
      'cash': 3500,
      'need': 'Aucune condition'
    },
    'maquis': {
      'n': 'Service au maquis Le Couplet',
      'h': 5,
      'e': 30,
      'cash': 4500,
      'need': 'Aucune condition'
    },
    'mc': {
      'n': 'Animateur de soirée (MC)',
      'h': 3,
      'e': 20,
      'cash': 6000,
      'cha': 8,
      'rank': 2,
      'need': 'Rang N2 · charisme 8'
    },
    // boulots rentables débloqués avec la carrière (valeurs provisoires, D-08)
    'assistant': {
      'n': 'Assistant au Studio Kôrô',
      'h': 4,
      'e': 20,
      'cash': 8000,
      'rank': 2,
      'need': 'Rang N2'
    },
    'mariage': {
      'n': 'DJ de mariages à Lumbé',
      'h': 4,
      'e': 25,
      'cash': 12000,
      'cha': 12,
      'rank': 3,
      'need': 'Rang N3 · charisme 12'
    },
    'pubradio': {
      'n': 'Voix de pub pour Radio Lagune FM',
      'h': 2,
      'e': 15,
      'cash': 15000,
      'voix': 15,
      'rank': 3,
      'need': 'Rang N3 · voix 15'
    },
    'atelierjeunes': {
      'n': 'Atelier rap pour les jeunes de Mabaya',
      'h': 3,
      'e': 20,
      'cash': 18000,
      'rank': 4,
      'need': 'Rang N4'
    },
    'jury': {
      'n': 'Jury du Tremplin de Lumbé',
      'h': 3,
      'e': 15,
      'cash': 22000,
      'rep': 40,
      'rank': 4,
      'need': 'Rang N4 · réputation 40'
    },
    'plume': {
      'n': "Plume pour un artiste d'Ambre Music Group",
      'h': 4,
      'e': 25,
      'cash': 35000,
      'ecr': 30,
      'rank': 5,
      'need': 'Rang N5 · écriture 30'
    },
  };

  // entreprises (revenus estimés, jamais garantis)
  static const biz = <String, J>{
    'couplet': {
      'n': 'Maquis Le Couplet (parts)',
      'rank': 3,
      'cost': 250000,
      'lo': 3000,
      'hi': 5000
    },
    'agence': {
      'n': 'Agence événementielle',
      'rank': 4,
      'cost': 600000,
      'lo': 7000,
      'hi': 12000
    },
    'studioq': {
      'n': 'Studio de quartier',
      'rank': 5,
      'cost': 1200000,
      'lo': 12000,
      'hi': 20000
    },
  };

  // patrimoine : un effet distinct par bien, rangé par catégorie ; 'rep' = réputation requise (règle validée, valeurs provisoires)
  // Effets : energy (max d'énergie, cumul plafonné à homeEnergyCap), upkeep (entretien par jour), lo/hi (revenu locatif par jour),
  // prestige (+réputation à l'achat), saveAll (énergie économisée par boulot, clip, open mic, concert, tournée ; le meilleur compte),
  // sceneEnergy (énergie économisée en plus sur concert et tournée ; le meilleur compte), recSave / prod / voixB (cabine : le meilleur compte).
  static const assetCats = <String, String>{
    'immo': 'Immobilier',
    'invest': 'Investissements',
    'vehicule': 'Véhicules',
    'bijou': 'Bijoux et montres',
    'studio': 'Matériel de studio',
  };
  static const homeEnergyCap = 30;
  static const assets = <String, J>{
    // ---- Immobilier ----
    'studiomeuble': {'n': 'Studio meublé à Ndolo', 'cat': 'immo', 'rep': 5, 'cost': 120000, 'upkeep': 600, 'energy': 2, 'eff': '+2 énergie max ; entretien 600 / jour'},
    'appart': {'n': 'Appartement à Lumbé', 'cat': 'immo', 'rep': 15, 'cost': 350000, 'upkeep': 2000, 'energy': 5, 'eff': '+5 énergie max ; entretien 2 000 / jour'},
    'maison': {'n': 'Maison à Ndolo', 'cat': 'immo', 'rep': 30, 'cost': 850000, 'upkeep': 3500, 'energy': 10, 'eff': '+10 énergie max ; entretien 3 500 / jour'},
    'villa': {'n': 'Villa à Port-Ambre', 'cat': 'immo', 'rep': 55, 'cost': 2400000, 'upkeep': 6000, 'energy': 15, 'eff': '+15 énergie max ; entretien 6 000 / jour'},
    'penthouse': {'n': 'Penthouse de Lumbé', 'cat': 'immo', 'rep': 75, 'cost': 4800000, 'upkeep': 11000, 'energy': 20, 'eff': '+20 énergie max ; entretien 11 000 / jour'},
    // ---- Investissements ----
    'terrain': {'n': 'Terrain à Sélène', 'cat': 'invest', 'rep': 20, 'cost': 500000, 'lo': 1000, 'hi': 2000, 'eff': 'Loyer estimé 1 000 à 2 000 / jour'},
    'local': {'n': 'Local commercial à Mabaya', 'cat': 'invest', 'rep': 35, 'cost': 900000, 'lo': 1800, 'hi': 3200, 'eff': 'Loyer estimé 1 800 à 3 200 / jour'},
    'bateau': {'n': 'Bateau de plaisance', 'cat': 'invest', 'rep': 50, 'cost': 1800000, 'lo': 2500, 'hi': 5000, 'eff': 'Location estimée 2 500 à 5 000 / jour'},
    'immeuble': {'n': 'Immeuble locatif à Kôtoro', 'cat': 'invest', 'rep': 60, 'cost': 2800000, 'lo': 6000, 'hi': 10000, 'eff': 'Loyers estimés 6 000 à 10 000 / jour'},
    // ---- Véhicules ----
    'scooter': {'n': 'Scooter', 'cat': 'vehicule', 'rep': 0, 'cost': 25000, 'saveAll': 2, 'eff': '−2 énergie sur chaque boulot, concert et tournée'},
    'moto': {'n': 'Moto', 'cat': 'vehicule', 'rep': 5, 'cost': 60000, 'saveAll': 5, 'eff': '−5 énergie sur chaque boulot, concert et tournée'},
    'voiture': {'n': 'Voiture', 'cat': 'vehicule', 'rep': 20, 'cost': 320000, 'sceneEnergy': 5, 'eff': '−5 énergie sur les concerts et tournées'},
    'suv': {'n': 'SUV de tournée', 'cat': 'vehicule', 'rep': 45, 'cost': 950000, 'sceneEnergy': 10, 'eff': '−10 énergie sur les concerts et tournées'},
    'berline': {'n': 'Berline de luxe', 'cat': 'vehicule', 'rep': 70, 'cost': 2600000, 'sceneEnergy': 15, 'prestige': 5, 'eff': '−15 énergie sur les concerts et tournées ; +5 réputation à l’achat'},
    // ---- Bijoux et montres ----
    'chaine': {'n': 'Chaîne en argent', 'cat': 'bijou', 'rep': 0, 'cost': 40000, 'prestige': 1, 'eff': '+1 réputation à l’achat'},
    'bague': {'n': 'Bague en or', 'cat': 'bijou', 'rep': 8, 'cost': 95000, 'prestige': 2, 'eff': '+2 réputation à l’achat'},
    'montre': {'n': 'Montre en or', 'cat': 'bijou', 'rep': 20, 'cost': 220000, 'prestige': 4, 'eff': '+4 réputation à l’achat'},
    'bracelet': {'n': 'Bracelet de platine', 'cat': 'bijou', 'rep': 35, 'cost': 480000, 'prestige': 6, 'eff': '+6 réputation à l’achat'},
    'diamant': {'n': 'Diamant', 'cat': 'bijou', 'rep': 50, 'cost': 1200000, 'prestige': 8, 'eff': '+8 réputation à l’achat'},
    'diamantrose': {'n': 'Diamant rose', 'cat': 'bijou', 'rep': 70, 'cost': 3500000, 'prestige': 14, 'eff': '+14 réputation à l’achat'},
    // ---- Matériel de studio ----
    'homestudio': {'n': 'Home studio', 'cat': 'studio', 'rep': 12, 'cost': 180000, 'recSave': 10, 'prod': 4, 'voixB': 2, 'eff': 'Enregistrement : −10 énergie, +4 production, +2 voix'},
    'cabinepro': {'n': 'Cabine insonorisée pro', 'cat': 'studio', 'rep': 30, 'cost': 450000, 'recSave': 12, 'prod': 6, 'voixB': 3, 'eff': 'Enregistrement : −12 énergie, +6 production, +3 voix'},
    'regie': {'n': 'Régie de studio complète', 'cat': 'studio', 'rep': 55, 'cost': 1400000, 'recSave': 15, 'prod': 9, 'voixB': 4, 'eff': 'Enregistrement : −15 énergie, +9 production, +4 voix'},
  };

  // création musicale
  static const themes = <String, J>{
    'quartier': {'n': 'Le quartier', 'tx': 0, 'vir': 10},
    'galere': {'n': 'La galère', 'tx': 1, 'vir': 6},
    'ambition': {'n': "L'ambition", 'tx': 2, 'vir': 12},
    'amour': {'n': "L'amour", 'tx': -1, 'vir': 14},
    // Dix thèmes de la bibliothèque musicale v20 ; quartier/galere restent pour les anciennes sauvegardes.
    'rue': {'n': 'Rue et survie', 'tx': 0, 'vir': 10},
    'argent': {'n': 'Argent et réussite', 'tx': 1, 'vir': 10},
    'fete': {'n': 'Fête et ambiance', 'tx': -1, 'vir': 8},
    'ego': {'n': 'Ego-trip et compétition', 'tx': 1, 'vir': 12},
    'introspection': {'n': 'Introspection et mélancolie', 'tx': 1, 'vir': 6},
    'identite': {'n': 'Identité et culture', 'tx': 0, 'vir': 10},
    'trap': {'n': 'Trap sombre et pouvoir', 'tx': 0, 'vir': 12},
    'gloire': {'n': 'Gloire et héritage', 'tx': 1, 'vir': 14},
  };
  static const ambs = <String, J>{
    'sombre': {'n': 'Sombre', 'tx': 0, 'vir': 0},
    'fiere': {'n': 'Fière', 'tx': 2, 'vir': 4},
    'legere': {'n': 'Légère', 'tx': -2, 'vir': 8},
  };
  static const virBase = 20, clipVir = 15;
  static const promoVir = [0, 5, 12];
  static const feats = <String, J>{
    'nadia': {
      'n': 'Nadia Kolo',
      'role': 'Refrain chanté',
      'cost': 8000,
      'q': 2,
      'vir': 6,
      'boost': 1.15
    },
    'ayana': {
      'n': 'Ayana Dembé',
      'role': 'Refrain afro-soul',
      'cost': 0,
      'share': 50,
      'q': 4,
      'vir': 8,
      'boost': 1.10,
      'needPop': 8
    },
    'orage': {
      'n': 'Madame Orage',
      'role': 'Couplet invité',
      'cost': 25000,
      'q': 5,
      'vir': 10,
      'boost': 1.25,
      'needPop': 30
    },
    'zaki': {
      'n': 'Zaki Mbela',
      'role': 'Couplet invité',
      'cost': 40000,
      'q': 5,
      'vir': 12,
      'boost': 1.3,
      'needRival': true
    },
    // Artistes invités ajoutés (Top 10 et scène de Bakoma). Cachets, rôles et effets : proposés, provisoires (D-08).
    'naya': {'n': 'Naya Rêve', 'role': 'Refrain mélodique', 'cost': 5000, 'q': 2, 'vir': 5, 'boost': 1.10},
    'tamsir': {'n': 'Tamsir Koffi', 'role': 'Prod et gimmick afro-drill', 'cost': 6000, 'q': 3, 'vir': 5, 'boost': 1.10},
    'kzer': {'n': "K-Zer d'Mabaya", 'role': 'Couplet clash', 'cost': 9000, 'q': 3, 'vir': 10, 'boost': 1.15, 'needPop': 10},
    'yaya': {'n': 'Yaya Cendre', 'role': 'Refrain soul', 'cost': 12000, 'q': 3, 'vir': 6, 'boost': 1.15, 'needPop': 15},
    'bako': {'n': 'Bako Flux', 'role': 'Couplet technique', 'cost': 15000, 'q': 4, 'vir': 7, 'boost': 1.18, 'needPop': 20},
    'lazuli': {'n': 'Lazuli', 'role': 'Refrain afro-soul', 'cost': 30000, 'q': 5, 'vir': 10, 'boost': 1.22, 'needPop': 35},
    'sable': {'n': 'Dr. Sable', 'role': 'Production et couplet', 'cost': 35000, 'q': 6, 'vir': 8, 'boost': 1.22, 'needPop': 40},
    'tito': {'n': 'Tito Brume', 'role': 'Couplet conscient', 'cost': 45000, 'q': 5, 'vir': 12, 'boost': 1.28, 'needPop': 45},
    'solo': {'n': 'Sôlo Vance', 'role': 'Couplet trap', 'cost': 70000, 'q': 6, 'vir': 14, 'boost': 1.35, 'needPop': 60},
    'kaira': {'n': 'Kaïra Nox', 'role': 'Couplet de la n° 1', 'cost': 120000, 'q': 7, 'vir': 18, 'boost': 1.45, 'needPop': 75},
  };
  static const maxFeats = 2;
  static const tiers = [
    (0, 'Discret'),
    (10000, 'Correct'),
    (50000, 'Bon'),
    (252200, 'Hit · entre au Top 100')
  ];

  // clips
  static const directors = <String, J>{
    'sika': {
      'n': 'Sika Nébo',
      'lv': 'Réalisatrice débutante',
      'cost': 15000,
      'vir': 8,
      'rank': 1
    },
    'ombre': {
      'n': 'Collectif Ombre Bleue',
      'lv': 'Collectif confirmé',
      'cost': 40000,
      'vir': 15,
      'rank': 2
    },
    'ilan': {
      'n': 'Ilan Mabé',
      'lv': 'Réalisateur reconnu',
      'cost': 120000,
      'vir': 25,
      'rank': 4
    },
  };
  static const shootE = 30, shootH = 6;
  static const clipBoost = 0.25;

  // rang de carrière : N1 à N6, seuils relevés le 16/10, conditions proposées
  static const ranks = <J>[
    {'n': 'Inconnu', 'xp': 0},
    {'n': 'Espoir du quartier', 'xp': 100},
    {
      'n': 'Révélation locale',
      'xp': 1500,
      'singles': 1,
      'cl': '1 single sorti'
    },
    {
      'n': 'Nom qui circule',
      'xp': 3200,
      'pop': 20,
      'shows': 1,
      'cl': 'popularité 20 et 1 concert'
    },
    {
      'n': 'Star de Bakoma',
      'xp': 6000,
      'fans': 500000,
      'bon': 1,
      'cl': '500 000 fans et 1 titre « Bon »'
    },
    {
      'n': 'Légende',
      'xp': 12000,
      'fans': 2500000,
      'hit': 1,
      'cl': '2 500 000 fans et 1 hit'
    },
  ];

  // labels et merchandising
  /// Catalogue du merchandising (valeurs provisoires, D-08). Une production à la fois ; l'image est `assets/merch/<id>.svg`.
  /// Ventes par jour = perFan × √fans × [merchScale] ; classé du plus accessible au plus exigeant.
  static const merch = <String, J>{
    'affiche': {
      'n': 'Posters Ndo City',
      'kind': 'Poster',
      'cost': 8000,
      'days': 7,
      'perFan': 0.45,
      'fans': 300,
      'singles': 1,
      'cl': '300 fans et 1 single sorti'
    },
    'casquette': {
      'n': 'Casquettes Ndo',
      'kind': 'Casquette',
      'cost': 12000,
      'days': 10,
      'perFan': 0.6,
      'fans': 600,
      'singles': 1,
      'cl': '600 fans et 1 single sorti'
    },
    'cd': {
      'n': 'CD du single',
      'kind': 'CD',
      'cost': 15000,
      'days': 12,
      'perFan': 0.7,
      'fans': 800,
      'singles': 1,
      'cl': '800 fans et 1 single sorti'
    },
    'tshirt': {
      'n': 'T-shirts Ndo City',
      'kind': 'T-shirt',
      'cost': 20000,
      'days': 14,
      'perFan': 0.8,
      'fans': 1000,
      'singles': 1,
      'cl': '1 000 fans et 1 single sorti'
    },
    'tote': {
      'n': 'Tote bags cauri',
      'kind': 'Tote bag',
      'cost': 25000,
      'days': 14,
      'perFan': 0.9,
      'fans': 2000,
      'singles': 1,
      'cl': '2 000 fans et 1 single sorti'
    },
    'hoodie': {
      'n': 'Hoodies Ndo City',
      'kind': 'Hoodie',
      'cost': 45000,
      'days': 16,
      'perFan': 1.1,
      'fans': 3000,
      'rank': 2,
      'cl': '3 000 fans et rang N2'
    },
    'vinyle': {
      'n': 'Vinyle collector',
      'kind': 'Vinyle',
      'cost': 60000,
      'days': 21,
      'perFan': 1.3,
      'fans': 5000,
      'rank': 3,
      'cl': '5 000 fans et rang N3'
    },
    'capsule': {
      'n': 'Collection capsule',
      'kind': 'Capsule',
      'cost': 100000,
      'days': 21,
      'perFan': 1.5,
      'fans': 10000,
      'rank': 4,
      'cl': '10 000 fans et rang N4'
    },
  };
  static const labelRep = 30, labelAdvance = 150000;

  /// Intérêt des labels (0 à 200) : il faut faire ses preuves avant la première offre (valeurs provisoires, D-08).
  /// Gains : single +12 (+6 si qualité 70 ou plus), EP ou album +20, date sur scène +6, publication virale +8.
  static const lbzGate = 100, lbzMax = 200;
  static const lbzSingle = 12, lbzGoodSingle = 6, lbzProject = 20, lbzShow = 6, lbzViral = 8;

  /// Problèmes de début de carrière : un à la fois, au plus un tous les [pbEvery] jours, jusqu'au rang [pbMaxRank].
  static const pbEvery = 3, pbMaxRank = 3;
  /// Création de son label (D-05 révisé à la demande de Smith : dès le rang N4). Capital et revenu par jour provisoires (D-08).
  static const ownLabelRank = 4, ownLabelCash = 500000;
  /// Identité du label du joueur : nom de 2 à [ownNameMax] caractères et un des logos générés (assets/logos/own_<id>.svg).
  static const ownNameMax = 22;
  static const ownLogos = <String>['vinyle', 'micro', 'flamme', 'cauri', 'etoile', 'onde', 'skyline', 'soleil'];

  /// Artistes signés par ton label (provisoire, D-08). Par palier : avance versée à la signature, part du label sur
  /// streams, concerts et merch, rang minimum pour le signer. Superstars non signables.
  static const labelSign = <String, J>{
    'Débutant': {'adv': 15000, 'cut': .50, 'rank': 4},
    'Talent émergent': {'adv': 40000, 'cut': .45, 'rank': 4},
    'Déclin et retour': {'adv': 60000, 'cut': .40, 'rank': 5},
    'Confirmé': {'adv': 120000, 'cut': .40, 'rank': 5},
    'Star nationale': {'adv': 400000, 'cut': .35, 'rank': 6},
  };

  /// Équipe du label : un poste de chaque, deux profils par poste (junior au rang N4, confirmé au rang N5).
  /// Salaire par jour ; embauche et licenciement coûtent 7 jours de salaire. Effets provisoires (D-08) :
  /// `ar` réduit les avances de signature ; `mkt`, `book`, `merch` augmentent les streams, concerts, merch du label ;
  /// `compta` réduit les frais de promotion et de studio.
  static const staffRoles = <String, J>{
    'ar': {'n': 'Découvreur de talents (A&R)', 'eff': 'Avances de signature'},
    'mkt': {'n': 'Marketing et promotion', 'eff': 'Revenus des streams'},
    'book': {'n': 'Booking et tournées', 'eff': 'Revenus des concerts'},
    'merch': {'n': 'Merchandising', 'eff': 'Revenus du merch'},
    'compta': {'n': 'Comptabilité', 'eff': 'Frais de promo et de studio'},
  };
  static const staffProfiles = <String, J>{
    'moussa': {'role': 'ar', 'n': 'Moussa Tiéné', 'lvl': 1, 'sal': 600, 'v': .10, 'rank': 4},
    'nafi': {'role': 'ar', 'n': 'Nafi Gnagne', 'lvl': 2, 'sal': 1800, 'v': .20, 'rank': 5},
    'prisca': {'role': 'mkt', 'n': 'Prisca Yapi', 'lvl': 1, 'sal': 600, 'v': .08, 'rank': 4},
    'herve': {'role': 'mkt', 'n': 'Hervé Dagri', 'lvl': 2, 'sal': 1800, 'v': .18, 'rank': 5},
    'eli': {'role': 'book', 'n': 'Eli Kobenan', 'lvl': 1, 'sal': 600, 'v': .15, 'rank': 4},
    'mariam': {'role': 'book', 'n': 'Mariam Sylla', 'lvl': 2, 'sal': 1800, 'v': .30, 'rank': 5},
    'joel': {'role': 'merch', 'n': 'Joël Atta', 'lvl': 1, 'sal': 600, 'v': .15, 'rank': 4},
    'sonia': {'role': 'merch', 'n': 'Sonia Ahoua', 'lvl': 2, 'sal': 1800, 'v': .30, 'rank': 5},
    'cedric': {'role': 'compta', 'n': 'Cédric Zadi', 'lvl': 1, 'sal': 500, 'v': .15, 'rank': 4},
    'fanta': {'role': 'compta', 'n': 'Fanta Doh', 'lvl': 2, 'sal': 1500, 'v': .30, 'rank': 5},
  };
  static const staffFeeDays = 7;

  /// Places dans l'écurie selon le rang N4, N5, N6 ; statuts d'artistes encore libres.
  static const labelSlots = <int, int>{4: 3, 5: 5, 6: 8};
  static const labelFreeStatuses = <String>['indépendant', 'émergent', 'en déclin', 'en pause'];

  /// Revenus d'un artiste signé, par jour : streams = écoutes sur 7 jours ÷ 7 × [lbStream] cauri ;
  /// concert tous les [lbConcertEvery] jours = √fans × [lbConcertK] × (0,6 + popularité ÷ 100) ;
  /// merch = [lbMerchK] × √fans × [merchScale] ; frais de promotion et de studio = avance ÷ [lbUpkeepDiv] par jour.
  /// Chaque semaine depuis la signature, écoutes et fans progressent de (talent − 45) ÷ 400, borné entre −2 % et +6 %.
  static const lbStream = 1.0, lbConcertEvery = 8, lbConcertK = 120, lbMerchK = 0.4, lbUpkeepDiv = 30;
  static const labelCut = 0.35;

  /// Sorties des artistes signés (provisoire, D-08). Par format : budget de base, délai avant la demande suivante,
  /// gain d'écoutes (part des écoutes 7 j, ajoutée par jour pendant `days` jours), fans gagnés (part des fans) ;
  /// le budget est multiplié par le coefficient du palier. Cycle des demandes : single, single, EP, single, single, album.
  static const relKinds = <String, J>{
    'single': {'n': 'Single', 'cost': 8000, 'every': 10, 'boost': .30, 'days': 14, 'fans': .010},
    'ep': {'n': 'EP', 'cost': 30000, 'every': 21, 'boost': .55, 'days': 24, 'fans': .025},
    'album': {'n': 'Album', 'cost': 90000, 'every': 42, 'boost': .90, 'days': 40, 'fans': .050},
  };
  static const relCycle = <String>['single', 'single', 'ep', 'single', 'single', 'album'];
  static const relPalierK = <String, double>{'Débutant': .6, 'Talent émergent': .8, 'Déclin et retour': .9, 'Confirmé': 1.2, 'Star nationale': 2.0};
  /// Première demande [relFirst] jours après la signature ; une demande sans réponse expire après [relExpire] jours.
  /// Négocier réduit le budget de [relNegoCut] ; humeur de départ [moodStart], accepter +[moodAccept], négocier −[moodNego], refuser −[moodDecline].
  static const relFirst = 3, relExpire = 10, relNegoCut = .30, moodStart = 60, moodAccept = 6, moodNego = 2, moodDecline = 8, moodFail = 6;
  static const relTitles = <String>[
    'Minuit sur Lumbé', 'Cauris dans la poche', 'Nuit de Ndolo', 'Bakoma ne dort pas', 'Lagune rouge', 'Fumée d’ambre',
    'Grand frère', 'Gbaka de nuit', 'Quartier haut', 'Cent pour cent Ndo', 'Toits de Mabaya', 'Sel et soleil',
  ];
  /// Rupture d'un contrat de label (D-08, provisoire) : rachat de l'avance + 20 % (planche 18.1), relation avec le directeur −15, popularité −3.
  static const labelBreakRate = 1.2, labelBreakRel = 15, labelBreakPop = 3;
  static const managerTiers = <String, J>{
    // Maya (M1) : 8 % de chaque cachet, « pas de fixe tant que tu débutes » (dialogue 19-6).
    'm1': {'n': 'Maya Tessé', 'rate': .08, 'fee': 0, 'rep': 0, 'xp': 0},
    'm2': {'n': 'Salif Odjé', 'rate': .10, 'fee': 1500, 'rep': 15, 'xp': 120},
    'm3': {'n': 'Rosine Adjoua', 'rate': .12, 'fee': 4000, 'rep': 25, 'xp': 400},
    'm4': {'n': 'Anselme Bayoko', 'rate': .15, 'fee': 12000, 'rep': 45, 'xp': 1000},
    'm5': {'n': 'Léa Sombré', 'rate': .17, 'fee': 30000, 'rep': 65, 'xp': 2200},
    'm6': {'n': 'Séraphine Aboa', 'rate': .20, 'fee': 80000, 'rep': 80, 'xp': 4500},
  };
  static const rivals = <String, String>{
    'kzer': 'K-Zer', 'zaki': 'Zaki Mbela', 'orage': 'Madame Orage', 'djo': 'Djo Kene'
  };
  static const rivalRounds = <String, List<(String, String, String)>>{
    'kzer': [
      ('« T’as le flow d’un gbaka en panne. »', 'Il ironise : réponds avec malice.', 'Malin'),
      ('« Dans mon quartier, on te connaît pas. »', 'Il attaque de front : réponds fort.', 'Agressif'),
      ('« Ton refrain ? Il est où ? »', 'Il se détend : garde la tête froide.', 'Cool'),
    ],
    'zaki': [
      ('« Tu veux ma place sans avoir fait tes preuves. »', 'Il remet ton parcours en cause.', 'Malin'),
      ('« Tu parles fort, mais tes actes sont où ? »', 'Il provoque devant le public.', 'Agressif'),
      ('« Vas-y, montre ce que tu sais faire. »', 'Il te laisse conclure.', 'Cool'),
    ],
    'orage': [
      ('« Ton texte manque encore de relief. »', 'Elle critique ton écriture.', 'Malin'),
      ('« Tu ne tiendrais pas une scène entière. »', 'Elle attaque ton assurance.', 'Agressif'),
      ('« Fais-moi entendre ta signature. »', 'Elle attend une réponse posée.', 'Cool'),
    ],
    'djo': [
      ('« Tu copies les codes du quartier. »', 'Il cherche une réponse originale.', 'Malin'),
      ('« Ici, le respect se gagne au micro. »', 'Il hausse le ton.', 'Agressif'),
      ('« On règle ça en musique ? »', 'Il te tend le micro.', 'Cool'),
    ],
  };
  // Cycle de catalogue porté du moteur v20 (Econ.catalog*).
  static const catalogDaily = 0.08, catalogDecay = 0.8, catalogDays = 14;

  // scène et géographie
  static const cities = <String, String>{
    'bakoma': 'Bakoma',
    'portambre': 'Port-Ambre',
    'selene': 'Sélène',
    'tamarel': 'Tamarel',
    'korvane': 'Korvane',
    'aldera': 'Aldéra'
  };
  static const conts = <String, J>{
    'solo': {
      'n': 'Rives de Sôlo',
      'c': ['bakoma', 'portambre', 'selene']
    },
    'tam': {
      'n': 'Terres de Tamarel',
      'c': ['tamarel']
    },
    'kor': {
      'n': 'Nord de Korvane',
      'c': ['korvane']
    },
    'ald': {
      'n': "Archipel d'Aldéra",
      'c': ['aldera']
    },
  };
  /// Festivals de l'année (calendrier 18.3) : l'invitation arrive la semaine du festival si le rang et la popularité suffisent ;
  /// le joueur accepte (il joue, touche un cachet fixe selon le niveau, R24) ou refuse. Cachets et effets provisoires (D-08).
  static const festivals = <String, J>{
    'ndolo': {'n': 'Scène Ouverte de Ndolo', 'lvl': 'Local', 'place': 'bakoma', 'city': 'Ndolo', 'weeks': [6, 30], 'cap': 400, 'fee': 3000, 'fans': 60, 'rep': 1, 'geo': 0.5, 'rank': 1, 'pop': 0, 'h': 4, 'e': 20, 'who': 'Bakary Fé'},
    'mabaya': {'n': 'Nuits de Mabaya', 'lvl': 'Local', 'place': 'bakoma', 'city': 'Mabaya', 'weeks': [14], 'cap': 900, 'fee': 5000, 'fans': 120, 'rep': 2, 'geo': 0.8, 'rank': 1, 'pop': 5, 'h': 4, 'e': 20, 'who': 'Awa Liméa'},
    'lumbe': {'n': 'Tremplin de Lumbé', 'lvl': 'Local', 'place': 'bakoma', 'city': 'Lumbé', 'weeks': [22], 'cap': 700, 'fee': 4500, 'fans': 100, 'rep': 2, 'geo': 0.8, 'rank': 2, 'pop': 8, 'h': 4, 'e': 20, 'who': 'Prof Mazé'},
    'lagune': {'n': "Festival Lagune d'Ambre", 'lvl': 'Régional', 'place': 'portambre', 'city': 'Port-Ambre', 'weeks': [12], 'cap': 8000, 'fee': 12000, 'fans': 400, 'rep': 3, 'geo': 2, 'rank': 2, 'pop': 12, 'h': 6, 'e': 30, 'who': 'Kouassi Zamba'},
    'sables': {'n': 'Carnaval des Sables', 'lvl': 'Régional', 'place': 'selene', 'city': 'Sélène', 'weeks': [36], 'cap': 8000, 'fee': 14000, 'fans': 450, 'rep': 3, 'geo': 2, 'rank': 3, 'pop': 15, 'h': 6, 'e': 30, 'who': 'Liv Sélou'},
    'kotoro': {'n': 'Kôtoro Bass Fest', 'lvl': 'National', 'place': 'bakoma', 'city': 'Kôtoro', 'weeks': [20], 'cap': 18000, 'fee': 30000, 'fans': 900, 'rep': 4, 'geo': 1.5, 'rank': 3, 'pop': 25, 'h': 6, 'e': 35, 'who': 'Jonas Kré'},
    'grandbk': {'n': 'Grand Bakoma Festival', 'lvl': 'National', 'place': 'bakoma', 'city': 'Stade de Lumbé', 'weeks': [40], 'cap': 40000, 'fee': 60000, 'fans': 1800, 'rep': 5, 'geo': 2, 'rank': 4, 'pop': 40, 'h': 8, 'e': 40, 'who': 'Kouassi Zamba'},
    'tamarel': {'n': 'Tamarel Open Air', 'lvl': 'International', 'place': 'tamarel', 'city': 'Tamarel', 'weeks': [28], 'cap': 60000, 'fee': 120000, 'fans': 4000, 'rep': 6, 'geo': 4, 'rank': 5, 'pop': 55, 'h': 10, 'e': 45, 'who': 'Kofi Ndayé'},
    'aldera': {'n': "Îles Sonores d'Aldéra", 'lvl': 'International', 'place': 'aldera', 'city': 'Aldéra', 'weeks': [33], 'cap': 25000, 'fee': 90000, 'fans': 2800, 'rep': 5, 'geo': 4, 'rank': 5, 'pop': 50, 'h': 10, 'e': 45, 'who': 'Kofi Ndayé'},
    'korvane': {'n': 'Nuits Polaires de Korvane', 'lvl': 'International', 'place': 'korvane', 'city': 'Korvane', 'weeks': [48], 'cap': 45000, 'fee': 100000, 'fans': 3200, 'rep': 5, 'geo': 4, 'rank': 5, 'pop': 50, 'h': 10, 'e': 45, 'who': 'Kofi Ndayé'},
  };
  static const festivalOrder = ['ndolo', 'lagune', 'mabaya', 'kotoro', 'lumbe', 'tamarel', 'aldera', 'sables', 'grandbk', 'korvane'];

  /// Booking international (agence de Désiré Kpan) : trois marchés étrangers, trois formats. Rang N5 requis ;
  /// cachet par date selon la notoriété locale ; une tournée internationale toutes les 4 semaines. Provisoire (D-08).
  static const intlMarkets = <String, J>{
    'tamarel': {'n': 'Tamarel', 'd': 'Grandes salles, public trap et afro-fusion'},
    'korvane': {'n': 'Korvane', 'd': 'Clubs du nord, scène électro-rap'},
    'aldera': {'n': 'Aldéra', 'd': 'Îles, festivals de plage, public afro-soul'},
  };
  static const intlFormats = <String, J>{
    'showcase': {'n': 'Showcase', 'dates': 3, 'h': 12, 'e': 45, 'cost': 60000, 'perDate': 25000, 'fans': 1500, 'geo': 3, 'needGeo': 0},
    'tournee': {'n': 'Tournée', 'dates': 6, 'h': 14, 'e': 55, 'cost': 150000, 'perDate': 32000, 'fans': 4000, 'geo': 6, 'needGeo': 5},
    'grande': {'n': 'Grande tournée', 'dates': 10, 'h': 16, 'e': 65, 'cost': 300000, 'perDate': 42000, 'fans': 9000, 'geo': 10, 'needGeo': 15},
  };
  static const intlEvery = 28;

  static const tour = <String, dynamic>{
    'n': 'Tournée régionale (Port-Ambre, Sélène)',
    'rank': 3,
    'e': 50,
    'h': 10,
    'cost': 30000,
    'fee': 20000,
    'feeGeo': 2500,
    'fans': 600,
    'geo': 8
  };
  static const intlRank = 5;

  // relations et famille
  static const romPerDay = 2;
  static const romActs = <String, J>{
    'parler': {'n': 'Discuter', 'g': 4, 'h': 1, 'e': 5, 'c': 0},
    'sortie': {'n': 'Sortie au maquis', 'g': 8, 'h': 3, 'e': 10, 'c': 3000},
    'cadeau': {'n': 'Offrir un cadeau', 'g': 6, 'h': 1, 'e': 0, 'c': 5000},
    'scene': {'n': 'Inviter à ton concert', 'g': 7, 'h': 2, 'e': 10, 'c': 0},
  };
  static const likeMul = 1.5, dislikeMul = 0.5;
  static const decayCourt = 1, decayCouple = 2;
  static const officialAt = 60,
      proposeAt = 80,
      proposeMinDays = 14,
      refuseCooldown = 14,
      refuseLoss = 12,
      warnAt = 30,
      leaveAt = 20,
      exBlockDays = 30;
  static const weddings = <String, J>{
    'simple': {'n': 'Cérémonie simple', 'cost': 50000, 'g': 8, 'pop': 0},
    'fete': {'n': 'Grande fête de quartier', 'cost': 150000, 'g': 12, 'pop': 3},
  };
  static const kidChance = 0.25, coupleCost = 1000, kidCost = 1500, maxKids = 2;
  static const stages = [
    (0, 'Bébé'),
    (1, 'Petite enfance'),
    (6, 'Enfant'),
    (12, 'Adolescent'),
    (18, 'Adulte')
  ];
  static const kidActs = <String, J>{
    'jouer': {'n': 'Jouer ensemble', 'l': 6, 'h': 1, 'e': 10, 'min': 0},
    'histoire': {'n': 'Lire une histoire', 'l': 4, 'h': 1, 'e': 5, 'min': 1},
    'devoirs': {'n': 'Aider aux devoirs', 'l': 7, 'h': 2, 'e': 10, 'min': 6},
    'studio': {'n': "L'emmener au studio", 'l': 8, 'h': 2, 'e': 10, 'min': 6},
  };

  /// Espace enfant (provisoire, D-08) : chaque moment partagé développe une facette (0 à 100), la garde coûte par jour
  /// et dépend de l'âge ; l'école fait progresser le savoir de [schoolDaily] point par jour.
  static const kidDev = <String, J>{
    'jouer': {'k': 'eveil', 'v': 4},
    'histoire': {'k': 'savoir', 'v': 3},
    'devoirs': {'k': 'savoir', 'v': 5},
    'studio': {'k': 'musique', 'v': 6},
  };
  static const kidDevNames = <String, String>{'eveil': 'Éveil', 'savoir': 'Savoir', 'musique': 'Oreille musicale'};
  static const kidGardes = <String, J>{
    'Au foyer': {'cost': 0, 'min': 0, 'max': 99},
    'Nounou': {'cost': 800, 'min': 0, 'max': 5},
    'École': {'cost': 500, 'min': 3, 'max': 17},
  };
  static const schoolDaily = 1, kidMemMax = 8;

  // création de l'artiste
  static const nameMin = 2, nameMax = 18, ageMin = 18, ageMax = 30;
  static const origins = <String, String>{
    'bakoma': 'Bakoma',
    'portambre': 'Port-Ambre',
    'selene': 'Sélène',
    'tamarel': 'Tamarel',
    'korvane': 'Korvane',
    'aldera': 'Aldéra'
  };
  static const styles = <String, J>{
    'drill': {
      'n': 'Drill de Bakoma',
      'k': 'flow',
      'kn': 'Flow',
      'd': 'Flow sec, voix grave, ambiance sombre.'
    },
    'conscient': {
      'n': 'Rap conscient',
      'k': 'ecr',
      'kn': 'Écriture',
      'd': 'Textes posés, messages forts.'
    },
    'coupe': {
      'n': 'Coupé-décalé rap',
      'k': 'cha',
      'kn': 'Charisme',
      'd': 'Énergie de fête, refrains qui tournent.'
    },
    'trap': {
      'n': 'Trap bakomaise',
      'k': 'voix',
      'kn': 'Voix',
      'd': 'Mélodies, voix travaillée, basses lourdes.'
    },
  };
  static const mainBonus = 3, secondBonus = 1;
  static const goals = <String, J>{
    'quartier': {
      'n': 'Être connu du quartier',
      'd': 'Premier son, premiers fans, un nom qui circule.'
    },
    'label': {
      'n': 'Signer en label',
      'd': 'Réputation 30 pour ouvrir les portes.'
    },
    'stade': {
      'n': 'Remplir un stade',
      'd': 'Le rêve : une salle pleine à Lumbé.'
    },
  };
  static const skins = <String, String>{
    '3': 'Mate',
    '5': 'Brun foncé',
    '6': 'Ébène'
  };

  // atelier et missions de départ
  /// Formations (en plus de l'atelier d'écriture) : une fois par jour chacune ; les plus poussées s'ouvrent avec le rang.
  /// Coach vocal, freestyle au carrefour et shooting viennent de la planche 09.3 ; les autres sont proposées. Valeurs provisoires (D-08).
  static const trainings = <String, J>{
    'freestyle': {'n': 'Freestyle au carrefour', 'd': 'Improviser devant les passants de Ndolo', 'h': 1, 'e': 15, 'cost': 0, 'gain': {'flow': 2}, 'rank': 1, 'art': 'street'},
    'coach': {'n': 'Coach vocal', 'd': 'Souffle, justesse, placement de la voix', 'h': 2, 'e': 20, 'cost': 9000, 'gain': {'voix': 5}, 'rank': 1, 'art': 'studio'},
    'shooting': {'n': 'Shooting et réseaux', 'd': 'Image, poses, présence en ligne', 'h': 2, 'e': 15, 'cost': 7000, 'gain': {'cha': 4}, 'rank': 1, 'art': 'backstage'},
    'impro': {'n': 'Atelier de scène', 'd': 'Occuper la scène, parler au public', 'h': 3, 'e': 25, 'cost': 15000, 'gain': {'cha': 6}, 'rank': 2, 'art': 'stage'},
    'placement': {'n': 'Cours de rythme et placement', 'd': 'Contretemps, débit, respirations sur la mesure', 'h': 3, 'e': 20, 'cost': 18000, 'gain': {'flow': 5}, 'rank': 2, 'art': 'studio'},
    'masterclass': {'n': "Masterclass d'écriture", 'd': 'Avec Prof Mazé (Lyrik Atelier) : images, rimes, structure', 'h': 4, 'e': 25, 'cost': 40000, 'gain': {'ecr': 9}, 'rank': 3, 'art': 'office'},
    'media': {'n': 'Media training', 'd': 'Interviews, plateaux télé, gestion des questions pièges', 'h': 3, 'e': 20, 'cost': 35000, 'gain': {'cha': 8}, 'rank': 4, 'art': 'call'},
    'stagevocal': {'n': 'Stage vocal intensif', 'd': 'Une journée complète avec une chanteuse de Sélène', 'h': 6, 'e': 35, 'cost': 60000, 'gain': {'voix': 10}, 'rank': 4, 'art': 'studio'},
    'residence': {'n': "Résidence d'écriture à Port-Ambre", 'd': 'Écrire loin du quartier, avec d\'autres plumes', 'h': 8, 'e': 40, 'cost': 120000, 'gain': {'ecr': 12, 'flow': 4}, 'rank': 5, 'art': 'office'},
  };
  static const skillNames = {'flow': 'Flow', 'ecr': 'Écriture', 'voix': 'Voix', 'cha': 'Charisme'};

  static const atelier = <String, dynamic>{
    'n': "Atelier d'écriture",
    'h': 2,
    'e': 20,
    'cost': 6000,
    'sk': 'ecr',
    'gain': 5
  };
  static const missions = <J>[
    {'id': 'm1', 't': 'Enregistre ton premier son', 'cash': 5000, 'xp': 50},
    {'id': 'm2', 't': 'Sors ton premier single', 'cash': 10000, 'xp': 80},
    {'id': 'm3', 't': "Fais un atelier d'écriture", 'cash': 4000, 'xp': 60},
    {'id': 'm4', 't': 'Atteins 1 000 fans', 'cash': 15000, 'xp': 120},
  ];

  // correctifs d'audit du 16/10
  static const concertEvery = 7,
      tourEvery = 28,
      ticketPrice = 80,
      capacity = 300,
      tourAudience = 3,
      merchScale = 30;

  // économie de démonstration
  static const listenValue = 0.01,
      fanSat = 5000,
      listenCap = 15000000,
      entry = 252200;

  // ---------------------------------------------------------------------------------------------------------------------
  // Ajouts de la mise à jour v21 complète (BRIEF-v21-complet.md §1) : tout est PROVISOIRE et regroupé ici.
  // Référence : REG de docs/design-ref/v21/sources/engine21.js.
  // ---------------------------------------------------------------------------------------------------------------------

  // studio : instrus payées une fois, cabine à 3 prises
  static const instrus = <String, J>{
    'nuit': {'n': 'Nuit à Ndo', 'who': 'Gratuite', 'Q': 32, 'cost': 0, 'rank': 1},
    'gbaka': {'n': 'Gbaka de 6h', 'who': 'DJ Kôrô', 'Q': 56, 'cost': 8000, 'rank': 1},
    'pont': {'n': 'Pont des Griots', 'who': 'Sanko Beats', 'Q': 68, 'cost': 15000, 'rank': 2},
    'lagune': {'n': "Lagune d'Ambre", 'who': 'Mister Wôrô', 'Q': 86, 'cost': 40000, 'rank': 1, 'rep': 30},
  };
  static const takesDefault = [74, 48, 43];
  static const qualityWeights = (text: 0.35, voice: 0.30, prod: 0.35);

  // ventes des singles, revenus d'écoute, part du label
  static const singleSales = 0.012, salePrice = 30;

  // plateformes FICTIVES : répartition des écoutes déjà calculées, aucun revenu en plus
  static const platforms = <String, J>{
    'ondea': {'n': 'Ondéa', 'share': 0.7},
    'cauri': {'n': 'Cauri Music', 'share': 0.3},
    'klipo': {'n': 'Klipo', 'viewsPerClipListen': 2},
  };
  static const listenersRatio = 0.35;
  static const mgrCut = 0.08;

  // EP et album (13.3, 13.4, 05-5) : `top` = taille du classement, `k` = pente, `entry` = ventes d'entrée
  /// Réserve de titres enregistrés non sortis, et fenêtre de programmation d'une sortie (jours de jeu). Valeurs provisoires.
  static const stockMax = 20, relMaxDays = 28;

  static const proj = <String, J>{
    'EP': {'min': 3, 'max': 7, 'cost': 15000, 'h': 4, 'e': 20, 'entry': 20000, 'top': 50, 'k': 1.285},
    'Album': {'min': 8, 'max': 20, 'cost': 40000, 'h': 6, 'e': 30, 'entry': 15000, 'top': 200, 'k': 1.095},
  };

  // activités illégales et justice (contenu mature 16+) : aucune méthode réelle, seulement risques et conséquences
  static const crimes = <String, J>{
    'recel': {'n': 'Recel de marchandises', 'h': 2, 'e': 10, 'lo': 5000, 'hi': 12000, 'risk': 8, 'heat': 5, 'ch': 'recel', 'sev': 1},
    'arnaque': {'n': 'Arnaque en ligne', 'h': 2, 'e': 10, 'lo': 8000, 'hi': 30000, 'risk': 12, 'heat': 10, 'ch': 'escroquerie', 'sev': 2},
    'revente': {'n': 'Revente de produits illicites', 'h': 3, 'e': 20, 'lo': 12000, 'hi': 20000, 'risk': 18, 'heat': 12, 'ch': 'trafic de stupéfiants', 'sev': 3},
    'braquage': {'n': 'Braquage', 'h': 4, 'e': 40, 'lo': 40000, 'hi': 90000, 'risk': 35, 'heat': 30, 'ch': 'vol à main armée', 'sev': 4},
  };
  static const heatDecay = 3, bailPer = 10000, trialIn = 3;
  static const lawyers = <String, J>{
    'office': {'n': 'Maître Yao Fofié', 'who': 'fofie', 'role': "Avocat commis d'office", 'cost': 0, 'skill': 10},
    'conf': {'n': 'Maître Sandra Lobé', 'who': 'lobe', 'role': 'Avocate pénaliste confirmée', 'cost': 25000, 'skill': 30},
    'tenor': {'n': 'Maître Ébène Kouamé', 'who': 'kouame', 'role': 'Ténor du barreau de Lumbé', 'cost': 90000, 'skill': 50},
  };
  static const sentences = <int, J>{
    1: {'fine': 15000, 'jail': 0},
    2: {'fine': 40000, 'jail': 0, 'sursis': 1},
    3: {'fine': 20000, 'jail': 7},
    4: {'fine': 0, 'jail': 21},
  };

  // battle de K-Zer : 3 rounds, victoire à 2
  static const battleWin = 2, battleFee = 3000;

  /// Indice de battle gagné au mini-jeu de Flow (règle validée par Smith, valeurs provisoires) : la zone à toucher s'élargit avec le Flow ;
  /// une réussite écarte une mauvaise réponse du round ; dès [flowHintReveal] de Flow, elle annonce le bon style.
  static const flowZoneMin = .14, flowZoneMax = .42, flowHintReveal = 40;
  static double flowZone(num flow) => (.14 + flow * .0025).clamp(flowZoneMin, flowZoneMax).toDouble();
  static int flowHintLevel(num flow) => flow >= flowHintReveal ? 2 : 1;

  // scène : open mic une fois par jour, gains décroissants sur 7 jours glissants
  static const omWindow = 7, omStep = 0.15, omFloor = 0.3, omFans = 150, omCash = 3000;
}

/// Candidat(e)s de la vie perso : profils et préférences visibles.
const cands21 = <String, J>{
  'ines': {
    'n': 'Inès Waly',
    'age': 23,
    'job': 'Styliste',
    'city': 'Lumbé',
    'likes': ['cadeau', 'scene'],
    'dis': ['parler'],
    'comp': 72,
    'bio':
        'Habille la moitié des artistes de Lumbé. Aime les tenues réussies et les grandes scènes.'
  },
  'kadi': {
    'n': 'Kadi Sora',
    'age': 25,
    'job': 'Infirmière',
    'city': 'Mabaya',
    'likes': ['parler', 'sortie'],
    'dis': ['scene'],
    'comp': 64,
    'bio':
        'Travaille de nuit. Préfère une vraie conversation à un concert bruyant.'
  },
  'lina': {
    'n': 'Lina Mbaré',
    'age': 22,
    'job': 'Danseuse',
    'city': 'Kôtoro',
    'likes': ['scene', 'sortie'],
    'dis': ['cadeau'],
    'comp': 80,
    'bio':
        "Danse sur les scènes de Kôtoro. Veut quelqu'un qui bouge autant qu'elle."
  },
  'sefa': {
    'n': 'Sefa Doumbé',
    'age': 27,
    'job': 'Journaliste musique',
    'city': 'Lumbé',
    'likes': ['parler', 'scene'],
    'dis': ['cadeau'],
    'comp': 58,
    'bio': 'Chronique la scène rap. Respecte le travail, se méfie du clinquant.'
  },
  'amara': {
    'n': 'Amara Teki',
    'age': 21,
    'job': 'Étudiante en droit',
    'city': 'Ndolo',
    'likes': ['parler', 'cadeau'],
    'dis': ['sortie'],
    'comp': 69,
    'bio': 'Révise ses examens au maquis du coin. Sincère, curieuse, directe.'
  },
  'yao': {
    'n': 'Yao Bellam',
    'age': 26,
    'job': 'Photographe',
    'city': 'Port-Ambre',
    'likes': ['sortie', 'cadeau'],
    'dis': ['scene'],
    'comp': 61,
    'bio':
        'Photographie les rues de Port-Ambre. Aime les balades et les surprises.'
  },
  'noe': {
    'n': 'Noé Akan',
    'age': 28,
    'job': 'Chef cuisinier',
    'city': 'Sélène',
    'likes': ['sortie', 'parler'],
    'dis': ['cadeau'],
    'comp': 66,
    'bio': 'Tient une cuisine à Sélène. Pense déjà à fonder une famille.'
  },
  'teo': {
    'n': 'Téo Gbéli',
    'age': 24,
    'job': 'Animateur radio',
    'city': 'Kôtoro',
    'likes': ['scene', 'parler'],
    'dis': ['sortie'],
    'comp': 75,
    'bio': 'Passe du rap à la radio de Kôtoro. Fan de musique avant tout.'
  },
};

const kidNames21 = ['Nayla', 'Kenzo'];

/// Promotions de la v20, reprises.
const promos21 = <J>[
  {'n': 'Aucune', 'c': 0, 'm': 1},
  {'n': 'Réseaux sociaux', 'c': 2000, 'm': 1.6},
  {'n': 'Radio locale', 'c': 15000, 'm': 3.2},
];

/// Titres proposés par thème (génération simple de la v21).
const titles21 = <String, List<String>>{
  'quartier': [
    'Gbaka de 6h',
    'Ndolo la nuit',
    'Carrefour Mabaya',
    'Rue des Griots'
  ],
  'galere': [
    'Poches vides',
    'Fin du mois',
    'Ticket de bus',
    'Pluie sur Kôtoro'
  ],
  'ambition': [
    'Monter au sommet',
    'Plus haut que Lumbé',
    'Couronne de cauris',
    'Premier stade'
  ],
  'amour': [
    'Lagune et toi',
    'Message de minuit',
    "Lumière d'Ambre",
    'Toi et Ndolo'
  ],
  'rue': ['Né dans le béton', "Personne ne m'attendait", 'La rue se souvient'],
  'argent': ['Premier million', 'Compte à sept chiffres', 'Rien à crédit'],
  'fete': ["Jusqu'à demain", 'Toute la nuit', 'Personne ne rentre'],
  'ego': ['Hors catégorie', 'Aucun égal', 'Le niveau supérieur'],
  'introspection': [
    'Mes nuits sans sommeil',
    'Les cicatrices parlent',
    'Lettre à maman'
  ],
  'identite': [
    'Ma terre, mes règles',
    'Le quartier en héritage',
    'Nos couleurs'
  ],
  'trap': ['Minuit trente', 'Couronne de fumée', 'Zone interdite'],
  'gloire': [
    "Mon nom dans l'histoire",
    'La dernière ovation',
    "Bien plus qu'un disque"
  ],
};

/// Événements de carrière : défi de K-Zer (03.5), offre de DJ Kôrô (16-A), offre de label (08.2).
const evt21 = <String, J>{
  'kzer': {
    't': "K-Zer d'Mabaya te défie",
    'who': "K-Zer d'Mabaya",
    'q':
        '« Le nouveau de Ndolo ? Viens prouver que tu sais rapper. Ce soir, au carrefour. »',
    'ch': [
      {
        'id': 'a',
        'n': 'Accepter la battle',
        'c':
            '1 h · −15 énergie · 3 rounds : gagne-en 2 pour +6 réputation, +150 fans, +3 000'
      },
      {'id': 'b', 'n': 'Ignorer', 'c': '+2 popularité · le défi est clos'},
    ],
  },
  'kore': {
    't': 'DJ Kôrô a écouté ton son',
    'who': 'DJ Kôrô',
    'q':
        '« La prod est brute, mais ta voix a du grain. Je te propose un deal : je produis tes trois prochains titres. »',
    'ch': [
      {
        'id': 'a',
        'n': 'Accepter à 40 %',
        'c': '−8 000 cauris · production +12 sur 3 titres · relation +15'
      },
      {
        'id': 'b',
        'n': 'Négocier à 35 %, mix signé',
        'c': '−7 000 cauris · production +12 sur 3 titres · relation +8'
      },
      {'id': 'c', 'n': 'Refuser', 'c': "relation −10 · il s'en souviendra"},
    ],
  },
  'label': {
    't': 'Bakoma Sound Records te fait une offre',
    'who': 'Madame Orage',
    'q': "« Six mois, deux sons par trimestre, 150 000 d'avance. On signe ? »",
    'ch': [
      {
        'id': 'a',
        'n': 'Signer le contrat',
        'c':
            "+150 000 cauris d'avance · 35 % de tes revenus d'écoutes au label · 6 mois"
      },
      {'id': 'b', 'n': "Refuser pour l'instant", 'c': "tu restes indépendant"},
    ],
  },
  // Problèmes de début de carrière (effets génériques « e », appliqués par l'action evc). Valeurs provisoires (D-08).
  'pb_faux': {
    't': 'Un « label » trop pressé',
    'who': 'Inconnu au téléphone',
    'q': "« Ici Platine Prod. On a adoré ton single. Envoie 10 000 de frais d'inscription et on te signe demain. »",
    'pb': 1,
    'ch': [
      {'id': 'a', 'n': 'Payer les frais', 'c': '−10 000 cauris · aucun label réel derrière', 'k': 'r', 'e': {'cash': -10000}},
      {'id': 'b', 'n': 'Raccrocher et prévenir le quartier', 'c': '+2 réputation · tu ne perds rien', 'e': {'rep': 2}},
    ],
  },
  'pb_micro': {
    't': 'Le micro de la cabine lâche',
    'who': 'DJ Kôrô',
    'q': '« Le micro grésille depuis ce matin. Je peux le faire réparer, ou on bricole avec le vieux. »',
    'pb': 1,
    'ch': [
      {'id': 'a', 'n': 'Payer la réparation', 'c': '−6 000 cauris · relation Kôrô +2', 'e': {'cash': -6000, 'rel': {'kore': 2}}},
      {'id': 'b', 'n': 'Bricoler une soirée', 'c': '2 h · −15 énergie · +20 XP', 'e': {'h': 2, 'en': 15, 'xp': 20}},
    ],
  },
  'pb_cachet': {
    't': 'Cachet impayé',
    'who': 'Gérant du Parvis',
    'q': "« Ton cachet ? La caisse est vide ce soir, reviens la semaine prochaine… peut-être. »",
    'pb': 1,
    'ch': [
      {'id': 'a', 'n': 'Réclamer devant tout le monde', 'c': '+3 000 cauris · −1 réputation', 'e': {'cash': 3000, 'rep': -1}},
      {'id': 'b', 'n': 'Laisser couler', 'c': '+1 réputation · tu passes pour un pro', 'e': {'rep': 1}},
    ],
  },
  'pb_critique': {
    't': 'Mauvaise critique dans Sôlo Mag',
    'who': 'Sôlo Mag',
    'q': '« Le nouveau de Ndolo ? Des refrains sans idée et un flow qui tourne en rond. Ndolo mérite mieux. »',
    'pb': 1,
    'ch': [
      {'id': 'a', 'n': 'Répondre publiquement', 'c': '+60 fans · −2 réputation · le clash fait parler', 'k': 'i', 'e': {'fans': 60, 'rep': -2, 'lbz': 4}},
      {'id': 'b', 'n': 'Retourner travailler en studio', 'c': '2 h · −10 énergie · +40 XP', 'e': {'h': 2, 'en': 10, 'xp': 40}},
      {'id': 'c', 'n': 'Ignorer', 'c': '−1 popularité', 'e': {'pop': -1}},
    ],
  },
  'pb_fuite': {
    't': 'Une maquette a fuité',
    'who': "K-Zer d'Mabaya",
    'q': "« Il paraît que ton prochain son traîne déjà sur les téléphones de Mabaya. Pas de chance, hein ? »",
    'pb': 1,
    'ch': [
      {'id': 'a', 'n': 'Assumer et en parler', 'c': '+80 fans · +2 popularité', 'k': 'i', 'e': {'fans': 80, 'pop': 2}},
      {'id': 'b', 'n': 'Faire retirer les copies', 'c': '−4 000 cauris · +1 réputation', 'e': {'cash': -4000, 'rep': 1}},
    ],
  },
  'pb_sono': {
    't': 'Panne de sono en pleine date',
    'who': 'Public du Parvis',
    'q': "La sono coupe au deuxième titre. La salle attend de voir ce que tu fais.",
    'pb': 1,
    'ch': [
      {'id': 'a', 'n': 'Finir a cappella', 'c': '−10 énergie · +3 réputation · +100 fans', 'k': 'i', 'e': {'en': 10, 'rep': 3, 'fans': 100}},
      {'id': 'b', 'n': 'Arrêter le concert', 'c': '−2 popularité', 'e': {'pop': -2}},
    ],
  },
};

/// Ordre et conditions des problèmes de début de carrière (voir engine21 `_problems`).
const problemOrder21 = ['pb_micro', 'pb_faux', 'pb_cachet', 'pb_critique', 'pb_fuite', 'pb_sono'];

/// Événements familiaux à deux choix aux conséquences certaines.
const fev21 = <String, J>{
  'anniv': {
    'need': 'couple',
    't': 'Anniversaire de couple',
    'q': "« Ce soir, c'est notre anniversaire. Tu restes avec moi ? »",
    'a': {'n': 'Rester ce soir', 'g': 8, 'cash': -5000, 'h': 2},
    'b': {'n': 'Reporter : tu as du travail', 'g': -6}
  },
  'fievre': {
    'need': 'kid',
    't': "Fièvre la veille d'un concert",
    'q': '« Ton enfant a de la fièvre. Tu restes à la maison ? »',
    'a': {'n': 'Rester à la maison', 'l': 10, 'e': -15},
    'b': {'n': 'Confier à la famille', 'l': -5}
  },
  'dimanche': {
    'need': 'married',
    't': 'Repas de famille du dimanche',
    'q': '« Les deux familles se retrouvent dimanche. On y va ? »',
    'a': {'n': 'Y aller', 'g': 5, 'h': 3},
    'b': {'n': 'Décliner', 'g': -4}
  },
};
