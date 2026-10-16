import 'dart:math';

/// Bibliothèque musicale de RAP EMPIRE : quatre catalogues, séparés comme le recommande la note de conception.
///  - musicThemes          : thèmes, émotions et sujets des morceaux ;
///  - instrumentalLibrary  : noms, genre, ambiance et tempo des instrumentales ;
///  - titleDictionary      : mots, verbes, adjectifs et expressions ;
///  - titleTemplates       : structures qui composent les titres (voir generateTitle).
/// Fiction de Bakoma : les noms réels de la note d'origine (ville, indicatif) sont remplacés par « Bakoma » et « 77 ». Provisoire (D-08).
/// Dart pur : aucune dépendance Flutter ; chaque tirage est déterministe pour une graine donnée.

// ---------------------------------------------------------------------------------------------------------------------
// 1. music_themes
// ---------------------------------------------------------------------------------------------------------------------

class MusicTheme {
  final String id, name, subject;

  /// Titres d'exemple de la note de conception ; ils servent aussi de titres prêts à l'emploi pour ce thème.
  final List<String> examples;

  /// Écart de note du texte (A.write : 72 + ambiance + thème). Provisoire.
  final int offset;

  /// Catégories du dictionnaire qui alimentent les titres de ce thème.
  final List<String> nounCats;
  final String verbGroup, adjCat;
  const MusicTheme(this.id, this.name, this.subject, this.examples, this.offset, this.nounCats, this.verbGroup, this.adjCat);
}

const musicThemes = [
  MusicTheme('rue', 'Rue et survie', 'Difficultés, loyauté, rivalité, respect, débrouillardise.', ['Né dans le béton', "Personne ne m'attendait", 'La rue se souvient'], 0, ['rue', 'emotions', 'temps'], 'resilience', 'urbains'),
  MusicTheme('argent', 'Argent et réussite', 'Richesse, ambition, contrats, luxe, indépendance financière.', ['Premier million', 'Compte à sept chiffres', 'Rien à crédit'], 1, ['argent', 'reussite'], 'reussite', 'luxueux'),
  MusicTheme('ambition', 'Ambition et ascension', 'Rêves, discipline, revanche, détermination, accomplissement.', ["Le sommet m'appelle", 'Parti de zéro', "Jusqu'au trône"], 2, ['reussite', 'pouvoir', 'temps'], 'ascension', 'ambitieux'),
  MusicTheme('amour', 'Amour et relations', 'Séduction, rupture, jalousie, confiance, amour compliqué.', ['Ton nom dans mes notes', "On s'aime mal", 'Dernier message'], -1, ['relations', 'emotions', 'temps'], 'relations', 'emotionnels'),
  MusicTheme('fete', 'Fête et ambiance', "Clubbing, danse, nuits blanches, séduction, énergie collective.", ["Jusqu'à demain", 'Toute la nuit', 'Personne ne rentre'], -1, ['temps', 'celebrite', 'musique'], 'nuit', 'festifs'),
  MusicTheme('ego', 'Ego-trip et compétition', 'Technique, confiance, domination artistique, rivalité, punchlines.', ['Hors catégorie', 'Aucun égal', 'Le niveau supérieur'], 1, ['pouvoir', 'reussite', 'musique'], 'competition', 'ambitieux'),
  MusicTheme('introspection', 'Introspection et mélancolie', 'Solitude, regrets, famille, trahison, résilience, souvenirs.', ['Mes nuits sans sommeil', 'Les cicatrices parlent', 'Lettre à maman'], 1, ['emotions', 'relations', 'temps'], 'introspection', 'emotionnels'),
  MusicTheme('identite', 'Identité et culture', 'Origines, quartier, famille, langues, fierté culturelle et appartenance.', ['Ma terre, mes règles', 'Le quartier en héritage', 'Nos couleurs'], 0, ['culture', 'rue'], 'resilience', 'urbains'),
  MusicTheme('trap', 'Trap sombre et pouvoir', 'Mystère, danger fictif, pouvoir, tension, ascension nocturne.', ['Minuit trente', 'Couronne de fumée', 'Zone interdite'], 0, ['pouvoir', 'temps', 'rue'], 'competition', 'sombres'),
  MusicTheme('gloire', 'Gloire et héritage', 'Célébrité, tournée, succès mondial, transmission, légende.', ["Mon nom dans l'histoire", 'La dernière ovation', "Bien plus qu'un disque"], 1, ['celebrite', 'reussite', 'culture'], 'ascension', 'ambitieux'),
];

/// Thèmes de l'ancienne démo, gardés pour les sauvegardes et les tests existants : leur écart de note ne change pas.
const legacyThemeOffsets = {'quartier': 0, 'galere': 1};
const legacyThemeNames = {'quartier': 'Le quartier', 'galere': 'La galère'};

MusicTheme? themeById(String id) {
  for (final t in musicThemes) {
    if (t.id == id) return t;
  }
  return null;
}

// ---------------------------------------------------------------------------------------------------------------------
// 2. instrumental_library
// ---------------------------------------------------------------------------------------------------------------------

class InstrumentalStyle {
  final String id, name, ambiance, tempo;
  final List<String> names;
  const InstrumentalStyle(this.id, this.name, this.ambiance, this.tempo, this.names);
}

const instrumentalLibrary = [
  InstrumentalStyle('trap', 'Trap · Dark trap', '808 lourdes, hi-hats rapides, ambiance sombre.', '130 à 150 BPM', [
    'Black District', 'Phantom 808', 'Nuit Pourpre', 'Sans Issue', 'Dark Crown', 'Code Fantôme', 'Minuit 77', 'Venom Keys', 'Zone 13', 'No Mercy',
  ]),
  InstrumentalStyle('drill', 'Drill', 'Basses glissantes, percussions sèches, tension rythmique.', '140 BPM', [
    'Concrete Flow', 'Cold Pressure', 'Iron Steps', 'District 9', 'Silent Threat', 'Blackout', 'No Witness', 'Steel Pulse', 'Deep Block', 'Last Warning',
  ]),
  InstrumentalStyle('afro', 'Afro-rap · Rap mélodique', 'Percussions organiques, guitares, mélodies chaleureuses.', '95 à 110 BPM', [
    'Lagune Noire', 'Bakoma Lights', 'Harmattan', 'Soleil Brut', 'Palm Groove', 'Terre Rouge', 'Tropical Soul', "Nuit d'Ébène", 'Baobab Keys', 'Horizon 77',
  ]),
  InstrumentalStyle('boombap', 'Boom bap · Rap technique', 'Samples soul, batterie sèche, basse ronde, ambiance vintage.', '85 à 95 BPM', [
    'Dusty Vinyl', 'Golden Era', 'Basement Tape', 'Raw Session', 'Concrete Poetry', 'Old Soul', "90's Memory", 'Broken Piano', 'Underground 01', 'Cipher Room',
  ]),
  InstrumentalStyle('rnb', 'R&B · Rap mélancolique', 'Pianos doux, nappes atmosphériques, rythmes lents.', '60 à 80 BPM', [
    'After Your Call', 'Velvet Rain', 'Broken Promise', 'Midnight Letters', 'Slow Motion', 'Empty Room', 'Rose Noire', 'Last Message', 'Blue Heart', 'Silent Tears',
  ]),
  InstrumentalStyle('luxury', 'Luxury rap · Rap de star', 'Cordes cinématiques, synthés brillants, grosses basses.', '100 à 130 BPM', [
    'Platinum Room', 'Golden Empire', 'Private Jet', 'Royal Pressure', 'Diamond Season', 'Billionaire Mood', 'Velvet Gold', 'Crown Jewel', 'First Class', 'Legacy Sound',
  ]),
];

/// Noms d'instrumentales en français, ajoutés à chaque style pour que le catalogue ne soit pas exclusivement anglophone.
const frenchInstrumentals = [
  'Le Prix du Silence', 'Couronne Froide', 'Dernier Virage', 'Béton Armé', "L'Heure du Choix", 'Sous Pression', 'Les Murs Écoutent', 'Après la Pluie',
  'Rien à Prouver', "Jusqu'au Bout", 'Au-dessus des Nuages', 'La Nuit Nous Appartient', 'Sans Retour', "L'Envers du Décor", 'Héritage Royal',
];

InstrumentalStyle instrumentalStyleById(String id) => instrumentalLibrary.firstWhere((s) => s.id == id);

/// Les noms d'un style : ses dix noms puis les quinze français. 25 noms, donc 25 jours avant de revoir le même.
List<String> instrumentalNames(String styleId) => [...instrumentalStyleById(styleId).names, ...frenchInstrumentals];

// ---------------------------------------------------------------------------------------------------------------------
// 3. title_dictionary
// ---------------------------------------------------------------------------------------------------------------------

/// Un nom commun avec son genre pour les accords : 'm', 'f', 'p' (pluriel) ou 'x' (sans article : « de béton », « de minuit »).
class Word {
  final String text;
  final String g;
  const Word(this.text, this.g);
}

const titleDictionary = (
  nouns: {
    'argent': [Word('millions', 'p'), Word('billets', 'p'), Word('fortune', 'f'), Word('salaire', 'm'), Word('contrat', 'm'), Word('dette', 'f'), Word('bénéfice', 'm'), Word('capital', 'm')],
    'reussite': [Word('sommet', 'm'), Word('trône', 'm'), Word('victoire', 'f'), Word('empire', 'm'), Word('couronne', 'f'), Word('légende', 'f'), Word('ascension', 'f')],
    'rue': [Word('béton', 'x'), Word('quartier', 'm'), Word('bloc', 'm'), Word('bitume', 'm'), Word('terrain', 'm'), Word('ruelle', 'f'), Word('district', 'm')],
    'temps': [Word('minuit', 'x'), Word('demain', 'x'), Word('hier', 'x'), Word('saison', 'f'), Word('époque', 'f'), Word('seconde', 'f'), Word('dernière nuit', 'f')],
    'relations': [Word('amour', 'm'), Word('cœur', 'm'), Word('regard', 'm'), Word('message', 'm'), Word('promesse', 'f'), Word('absence', 'f'), Word('souvenir', 'm')],
    'pouvoir': [Word('règne', 'm'), Word('contrôle', 'm'), Word('force', 'f'), Word('autorité', 'f'), Word('niveau', 'm'), Word('domination', 'f')],
    'emotions': [Word('douleur', 'f'), Word('rage', 'f'), Word('peur', 'f'), Word('espoir', 'm'), Word('regret', 'm'), Word('fierté', 'f'), Word('silence', 'm')],
    'culture': [Word('racines', 'p'), Word('terre', 'f'), Word('famille', 'f'), Word('origine', 'f'), Word('héritage', 'm'), Word('couleurs', 'p'), Word('mémoire', 'f')],
    'musique': [Word('mélodie', 'f'), Word('fréquence', 'f'), Word('refrain', 'm'), Word('rythme', 'm'), Word('voix', 'f'), Word('disque', 'm'), Word('écho', 'm')],
    'celebrite': [Word('lumière', 'f'), Word('scène', 'f'), Word('foule', 'f'), Word('projecteurs', 'p'), Word('ovation', 'f'), Word('affiche', 'f'), Word('tournée', 'f')],
  },
  verbs: {
    'ascension': ['grimper', 'conquérir', 'bâtir', 'gagner', 'dépasser', 'régner'],
    'resilience': ['survivre', 'tenir', 'revenir', 'résister', 'renaître', 'avancer'],
    'reussite': ['compter', 'investir', 'signer', 'encaisser', 'posséder', 'briller'],
    'relations': ['aimer', 'oublier', 'regretter', 'mentir', 'pardonner', 'quitter'],
    'competition': ['dominer', 'frapper', 'viser', 'dépasser', 'défier', 'imposer'],
    'nuit': ['danser', 'rouler', 'vibrer', 'célébrer', 'brûler', "s'évader"],
    'introspection': ['penser', 'pleurer', 'écrire', 'comprendre', 'se souvenir', 'douter'],
  },
  // Adjectifs au masculin singulier et au féminin singulier (les accords sont gérés par le genre du nom).
  adjectives: {
    'ambitieux': [('immense', 'immense'), ('royal', 'royale'), ('supérieur', 'supérieure'), ('invincible', 'invincible'), ('légendaire', 'légendaire')],
    'sombres': [('froid', 'froide'), ('noir', 'noire'), ('silencieux', 'silencieuse'), ('perdu', 'perdue'), ('interdit', 'interdite'), ('fatal', 'fatale')],
    'emotionnels': [('brisé', 'brisée'), ('sincère', 'sincère'), ('fragile', 'fragile'), ('absent', 'absente'), ('éternel', 'éternelle'), ('amer', 'amère')],
    'urbains': [('brut', 'brute'), ('bétonné', 'bétonnée'), ('sauvage', 'sauvage'), ('réel', 'réelle'), ('underground', 'underground'), ('clandestin', 'clandestine')],
    'luxueux': [('doré', 'dorée'), ('privé', 'privée'), ('précieux', 'précieuse'), ('brillant', 'brillante'), ('exclusif', 'exclusive'), ('rare', 'rare')],
    'festifs': [('chaud', 'chaude'), ('électrique', 'électrique'), ('fou', 'folle'), ('vibrant', 'vibrante'), ('nocturne', 'nocturne'), ('intense', 'intense')],
  },
  expressions: [
    'parti de zéro', 'contre le monde', 'loin des miens', 'sans faire de bruit', 'avant le lever du jour', 'personne ne sait', 'plus rien à perdre',
    "jusqu'à la victoire", 'au prix de tout', 'le dernier appel', 'après minuit', 'jamais assez', 'le monde est à nous', 'seul au sommet', 'né pour gagner',
    'tout ou rien', 'derrière les sourires', 'le poids du succès', 'même dans le noir', "quand tout s'arrête",
  ],
);

// ---------------------------------------------------------------------------------------------------------------------
// 4. title_templates
// ---------------------------------------------------------------------------------------------------------------------

/// Modèle 2 : compléments de chaque verbe d'action (« Conquérir le sommet », « Bâtir ma légende », « Dépasser les limites »).
/// Chaque verbe a ses propres compléments, pour que la phrase reste correcte.
const _verbTargets = {
  'grimper': ['vers le sommet', 'marche après marche'], 'conquérir': ['le sommet', 'le monde'], 'bâtir': ['ma légende', 'mon empire'],
  'gagner': ['ma place', 'le respect'], 'dépasser': ['les limites', 'mes doutes', 'tous les niveaux', 'mes rivaux'], 'régner': ['sur mon empire', 'sans partage'],
  'survivre': ['au béton', 'à tout'], 'tenir': ['debout', 'bon'], 'revenir': ['plus fort', 'dans la lumière'], 'résister': ['à tout', 'contre tous'],
  'renaître': ['de mes cendres', 'chaque matin'], 'avancer': ['sans me retourner', 'malgré tout'],
  'compter': ['mes millions', 'sur moi'], 'investir': ['sur moi', 'dans mes rêves'], 'signer': ['mon contrat', 'à ma façon'],
  'encaisser': ['sans trembler', 'les coups'], 'posséder': ['mon avenir', 'ma liberté'], 'briller': ['sans permission', 'dans le noir'],
  'aimer': ['à découvert', 'sans compter'], 'oublier': ['ton nom', 'sans regret'], 'regretter': ['tes promesses', 'en silence'],
  'mentir': ['sans rougir', 'pour te garder'], 'pardonner': ['sans oublier', 'tout'], 'quitter': ['en silence', 'sans retour'],
  'dominer': ['le game', 'sans pitié'], 'frapper': ['fort', 'sans prévenir'], 'viser': ['plus haut', 'le sommet'], 'défier': ['les règles', 'le monde'], 'imposer': ['mon style', 'le respect'],
  'danser': ['toute la nuit', "jusqu'au matin"], 'rouler': ['toute la nuit', 'sans freiner'], 'vibrer': ['avec la foule', 'comme jamais'],
  'célébrer': ['la nuit', 'sous les lumières'], 'brûler': ['la nuit', 'sans compter'], "s'évader": ["jusqu'au matin", 'avec la foule'],
  'penser': ['à toi', 'à demain'], 'pleurer': ['en silence', 'dans le noir'], 'écrire': ['à ma mère', 'sans filtre'],
  'comprendre': ['mes erreurs', 'qui je suis'], 'se souvenir': ['de tout', 'des nuits blanches'], 'douter': ['sans filtre', 'de tout'],
};

/// Modèle 3 : expressions personnelles à la première personne.
const _personal = [
  "J'ai changé de vie", "Je n'oublie rien", "J'avance seul", 'Je reviens plus fort', 'Je ne lâche rien', 'Je suis encore là', 'Je compte sur moi',
  "J'ai tout donné", 'Je garde le cap', "Je n'ai pas peur", 'Je sais qui je suis', 'Je reste debout',
];

/// Modèle 4 : contrastes (« Riche mais seul », « Lumière dans le noir », « Sourire de façade »).
const _contrasts = [
  'Riche mais seul', 'Lumière dans le noir', 'Sourire de façade', 'Roi sans couronne', 'Fort et fragile', 'Debout malgré tout', 'Silence et fracas',
  'Pauvre de tout, riche de rêves', 'Calme avant le bruit', 'Or et poussière', 'Rire en pleurant', 'Parti pour rester',
];

/// Modèle 5 : titres courts, un ou deux mots marquants.
const _shorts = ['Ascension', 'Sans Visage', 'Hors-jeu', 'Éternel', '77', 'Zone 13', 'Sommet', 'Intouchable', 'Rescapé', 'Vertige', 'Fusion', 'Relève'];

/// Les cinq modèles et la part de tirage de chacun (en %). Le reste des tirages donne une expression courte du dictionnaire ou un exemple du thème.
const titleTemplates = [
  ('Nom + complément', 28), // Couronne de béton, Empire du silence, Mémoire de minuit
  ('Action + objectif', 17), // Conquérir le sommet, Bâtir ma légende
  ('Expression personnelle', 12), // J'ai changé de vie, Je n'oublie rien
  ('Contraste', 12), // Riche mais seul, Lumière dans le noir
  ('Titre court', 8), // Ascension, Sans Visage, Hors-jeu
  ('Expression du dictionnaire', 13), // Parti de zéro, Plus rien à perdre
  ('Exemple du thème', 10), // Né dans le béton, Premier million
];

// ---------------------------------------------------------------------------------------------------------------------
// Génération
// ---------------------------------------------------------------------------------------------------------------------

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
bool _vowel(String s) => 'aeiouyhâàéèêëîïôöûùœAEIOUYHÉÈÊÂÎÔÛ'.contains(s[0]);

/// « de » + nom avec l'article qui convient : du silence, de la rue, des couleurs, de béton, d'amour…
String _of(Word w) => switch (w.g) {
      'p' => 'des ${w.text}',
      'x' => _vowel(w.text) ? "d'${w.text}" : 'de ${w.text}',
      'f' => _vowel(w.text) ? "de l'${w.text}" : 'de la ${w.text}',
      _ => _vowel(w.text) ? "de l'${w.text}" : 'du ${w.text}',
    };

T _pick<T>(Random r, List<T> l) => l[r.nextInt(l.length)];

String _model(Random r, MusicTheme t, int model) {
  final nouns = titleDictionary.nouns;
  Word noun() => _pick(r, nouns[_pick(r, t.nounCats)]!);
  switch (model) {
    case 0: // Nom + complément, avec ou sans adjectif
      var a = noun();
      for (var i = 0; i < 8 && a.g == 'x'; i++) {
        a = noun();
      }
      var b = noun();
      for (var i = 0; i < 6 && b.text == a.text; i++) {
        b = noun();
      }
      if (a.g != 'x' && r.nextBool() && a.g != 'p') {
        final adj = _pick(r, titleDictionary.adjectives[t.adjCat]!);
        return '${_cap(a.text)} ${a.g == 'f' ? adj.$2 : adj.$1}';
      }
      return '${_cap(a.text)} ${_of(b)}';
    case 1: // Action + objectif
      final verb = _pick(r, titleDictionary.verbs[t.verbGroup]!);
      return '${_cap(verb)} ${_pick(r, _verbTargets[verb]!)}';
    case 2:
      return _pick(r, _personal);
    case 3:
      return _pick(r, _contrasts);
    case 4:
      return _pick(r, _shorts);
    case 5:
      return _cap(_pick(r, titleDictionary.expressions));
    default:
      return _pick(r, t.examples);
  }
}

/// Titre de morceau pour une graine et un thème (id de [musicThemes] ; un thème inconnu ou null donne un thème tiré au hasard).
/// Même graine et même thème : même titre. Jamais plus de [maxLength] caractères.
String generateTitle(int seed, {String? themeId, int maxLength = 28}) {
  final r = Random(seed.abs() * 7919 + 13);
  final t = themeById(themeId ?? '') ?? _pick<MusicTheme>(r, musicThemes);
  final total = titleTemplates.fold<int>(0, (a, e) => a + e.$2);
  for (var attempt = 0; attempt < 12; attempt++) {
    var roll = r.nextInt(total);
    var model = 0;
    for (var i = 0; i < titleTemplates.length; i++) {
      if (roll < titleTemplates[i].$2) {
        model = i;
        break;
      }
      roll -= titleTemplates[i].$2;
    }
    final title = _model(r, t, model);
    if (title.length <= maxLength) return title;
  }
  return _pick(r, t.examples);
}
