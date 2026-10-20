import 'reg21.dart' show J;

/// Garde-robe à tenues préfabriquées (planches 21-W0 à 21-W3, engine21.js « WARDROBE »). [VALIDÉ — architecture].
/// Une tenue = deux illustrations complètes du même rappeur (jeune / mature). Les illustrations actuellement référencées sont provisoires, non finales. Aucune composition de vêtements en jeu :
/// le jeu sélectionne une image existante. Les variantes jeune/mature sont générées par docs/design-ref/v21/sources/gen_outfits.py.
class Wardrobe21 {
  static const character = 'rapper_001';
  static const base = 'assets/characters/rapper_001/';
  /// [À CONCEVOIR] aucun seuil n'existe dans les sources : valeur de test, regroupée ici.
  static const matureRank = 4;
  /// I-08 : confirmation d'achat dès 15 000 cauris.
  static const confirmAt = 15000;

  static const outfits = <Map<String, dynamic>>[
    {'id': 'OUTFIT_001', 'n': 'Hoodie Néon', 'd': 'Le hoodie rose de tes débuts, patch BKM sur la poitrine.', 'price': 0, 'rank': 1, 'start': true, 'images': {'young': 'young/OUTFIT_001.webp', 'mature': 'mature/OUTFIT_001.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_002', 'n': 'Survêt Soleil', 'd': 'Survêtement jaune soleil, zip et bandes magenta.', 'price': 6000, 'rank': 1, 'start': false, 'images': {'young': 'young/OUTFIT_002.webp', 'mature': 'mature/OUTFIT_002.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_003', 'n': 'Veste Brume', 'd': 'Veste gris-violet, baskets cyan. Le look des sessions studio.', 'price': 18000, 'rank': 1, 'start': false, 'images': {'young': 'young/OUTFIT_003.webp', 'mature': 'mature/OUTFIT_003.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_004', 'n': 'Veste Nuit', 'd': 'Blazer bleu nuit et détails or, pour les grandes scènes.', 'price': 30000, 'rank': 3, 'start': false, 'images': {'young': 'young/OUTFIT_004.webp', 'mature': 'mature/OUTFIT_004.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_005', 'n': 'Hoodie Jade', 'd': 'Hoodie vert jade. Illustration mature pas encore produite.', 'price': 12000, 'rank': 1, 'start': false, 'images': {'young': 'young/OUTFIT_005.webp', 'mature': 'mature/OUTFIT_005.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_006', 'n': 'Hoodie Cobalt', 'd': 'Hoodie bleu cobalt, coutures cyan et sneakers blanches.', 'price': 14000, 'rank': 1, 'start': false, 'images': {'young': 'young/OUTFIT_006.webp', 'mature': 'mature/OUTFIT_006.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_007', 'n': 'Veste Cuivre', 'd': 'Veste courte cuivre et pantalon anthracite.', 'price': 22000, 'rank': 2, 'start': false, 'images': {'young': 'young/OUTFIT_007.webp', 'mature': 'mature/OUTFIT_007.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_008', 'n': 'Ensemble Impérial', 'd': 'Ensemble noir profond, finitions or et chaîne de scène.', 'price': 42000, 'rank': 3, 'start': false, 'images': {'young': 'young/OUTFIT_008.webp', 'mature': 'mature/OUTFIT_008.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_009', 'n': 'Néon de Bakoma', 'd': 'Tenue de performance magenta et cyan pour les grandes scènes.', 'price': 65000, 'rank': 5, 'start': false, 'images': {'young': 'young/OUTFIT_009.webp', 'mature': 'mature/OUTFIT_009.webp'}, 'status': 'disponible'},
  ];

  static const startId = 'OUTFIT_001';
}

/// État de départ de la garde-robe : Hoodie Néon possédé et équipé.
Map<String, dynamic> initWardrobe21() => {'owned': [Wardrobe21.startId], 'eq': Wardrobe21.startId, 'sel': Wardrobe21.startId, 'ask': null};

Map<String, dynamic>? outfit21(String? id) {
  for (final o in Wardrobe21.outfits) {
    if (o['id'] == id) return o;
  }
  return null;
}

/// Une tenue n'est achetable que si ses deux illustrations existent.
bool outfitComplete21(Map<String, dynamic>? o) {
  final im = o?['images'] as Map?;
  return im != null && im['young'] != null && im['mature'] != null;
}

bool outfitUnavailable21(Map<String, dynamic> o) => o['status'] != 'disponible' || !outfitComplete21(o);

/// Variante d'âge dérivée du rang, jamais stockée.
String ageVariant21(J s) => (s['rank'] as num) >= Wardrobe21.matureRank ? 'mature' : 'young';

/// Résultat du résolveur d'apparence : [path] est null quand [fallback] vaut 'tenue' ou 'image' (avatar provisoire).
class Look21 {
  final String? character, outfit, path, fallback;
  final String variant;
  const Look21(this.character, this.variant, this.outfit, this.path, this.fallback);
}

/// Sélectionne une image existante, ne compose rien. [outfitId] : aperçu d'une autre tenue que l'équipée.
/// Écart assumé avec engine21.js : le look choisi à la création (coiffure, teint) ne bloque plus l'affichage des tenues ;
/// les illustrations de test montrent toujours le même rappeur. À revoir quand il y aura des illustrations par look.
Look21 resolveLook21(J s, [String? outfitId]) {
  final ch = Wardrobe21.character, v = ageVariant21(s);
  final o = outfit21(outfitId ?? (s['wd'] as J)['eq'] as String?);
  final rel = o == null ? null : (o['images'] as Map)[v] as String?;
  final fb = o == null ? 'tenue' : rel == null ? 'image' : null;
  return Look21(ch, v, o?['id'] as String?, fb != null ? null : Wardrobe21.base + rel!, fb);
}

String? _wCheck(J s, Map<String, dynamic>? o) {
  if (o == null) return 'inconnu';
  final wd = s['wd'] as J;
  if ((wd['owned'] as List).contains(o['id'])) return 'deja';
  if (outfitUnavailable21(o)) return 'indispo';
  if ((s['rank'] as num) < (o['rank'] as num)) return 'rang';
  if ((s['cash'] as num) < (o['price'] as num)) return 'cash';
  return null;
}

// Les actions o* (osel, oask, obuy, oeq, …) sont dans engine21.dart ; les règles de contrôle sont ici pour rester testables.
String? outfitCheck21(J s, String id) => _wCheck(s, outfit21(id));
