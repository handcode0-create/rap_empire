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
    {'id': 'OUTFIT_001', 'n': 'Hoodie Néon', 'd': 'Le hoodie rose de tes débuts, patch BKM sur la poitrine.', 'price': 0, 'rank': 1, 'start': true, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_001.webp', 'mature': 'mature/v21b_OUTFIT_001.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_002', 'n': 'Survêt Soleil', 'd': 'Survêtement jaune soleil, zip et bandes magenta.', 'price': 6000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_002.webp', 'mature': 'mature/v21b_OUTFIT_002.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_003', 'n': 'Veste Brume', 'd': 'Veste gris-violet, baskets cyan. Le look des sessions studio.', 'price': 18000, 'rank': 1, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_003.webp', 'mature': 'mature/v21b_OUTFIT_003.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_004', 'n': 'Veste Nuit', 'd': 'Blazer bleu nuit et détails or, pour les grandes scènes.', 'price': 30000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_004.webp', 'mature': 'mature/v21b_OUTFIT_004.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_005', 'n': 'Hoodie Jade', 'd': 'Hoodie vert jade.', 'price': 12000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_005.webp', 'mature': 'mature/v21b_OUTFIT_005.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_006', 'n': 'Hoodie Cobalt', 'd': 'Hoodie bleu cobalt, coutures cyan et sneakers blanches pour les sessions de nuit.', 'price': 14000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_006.webp', 'mature': 'mature/v21b_OUTFIT_006.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_007', 'n': 'Veste Cuivre', 'd': 'Veste courte cuivre et pantalon anthracite, un look affirmé pour les showcases.', 'price': 22000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_007.webp', 'mature': 'mature/v21b_OUTFIT_007.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_008', 'n': 'Ensemble Impérial', 'd': 'Ensemble noir profond, finitions or et chaîne de scène.', 'price': 42000, 'rank': 3, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_008.webp', 'mature': 'mature/v21b_OUTFIT_008.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_009', 'n': 'Néon de Bakoma', 'd': 'Tenue de performance magenta et cyan, conçue pour les grandes scènes.', 'price': 65000, 'rank': 5, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_009.webp', 'mature': 'mature/v21b_OUTFIT_009.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_010', 'n': 'Hoodie Corail', 'd': 'Hoodie corail et jogging nuit, le basique des sessions au quartier.', 'price': 5000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_010.webp', 'mature': 'mature/v21b_OUTFIT_010.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_011', 'n': 'Hoodie Ardoise', 'd': 'Hoodie gris ardoise, sneakers blanches, simple et propre.', 'price': 4500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_011.webp', 'mature': 'mature/v21b_OUTFIT_011.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_012', 'n': 'Hoodie Lagune', 'd': 'Hoodie bleu lagune, rappel cyan sur les chaussures.', 'price': 6000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_012.webp', 'mature': 'mature/v21b_OUTFIT_012.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_013', 'n': 'Hoodie Mangue', 'd': 'Hoodie jaune mangue, pantalon violet, impossible à rater.', 'price': 7000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_013.webp', 'mature': 'mature/v21b_OUTFIT_013.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_014', 'n': 'Tee Blanc Ndolo', 'd': 'T-shirt blanc oversize et pantalon cargo nuit.', 'price': 3500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_014.webp', 'mature': 'mature/v21b_OUTFIT_014.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_015', 'n': 'Tee Prune', 'd': 'T-shirt prune, sneakers or : le look du carrefour.', 'price': 4000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_015.webp', 'mature': 'mature/v21b_OUTFIT_015.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_016', 'n': 'Tee Sable', 'd': 'T-shirt sable et jean foncé, avec casquette.', 'price': 5500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_016.webp', 'mature': 'mature/v21b_OUTFIT_016.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_017', 'n': 'Casquette Gbaka', 'd': 'Hoodie noir, casquette rose : la tenue du gbaka de 6 h.', 'price': 8000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_017.webp', 'mature': 'mature/v21b_OUTFIT_017.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_018', 'n': 'Hoodie Olive', 'd': 'Hoodie olive, cargo sombre, baskets crème.', 'price': 6500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_018.webp', 'mature': 'mature/v21b_OUTFIT_018.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_019', 'n': 'Tee Rouge Brique', 'd': 'T-shirt rouge brique et jogging gris.', 'price': 4500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_019.webp', 'mature': 'mature/v21b_OUTFIT_019.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_020', 'n': 'Survêt Menthe', 'd': 'Survêtement menthe à bandes blanches.', 'price': 9000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_020.webp', 'mature': 'mature/v21b_OUTFIT_020.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_021', 'n': 'Survêt Nuit Bleue', 'd': 'Survêtement bleu nuit, zip or.', 'price': 10000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_021.webp', 'mature': 'mature/v21b_OUTFIT_021.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_022', 'n': 'Survêt Braise', 'd': 'Survêtement orange braise, bandes noires.', 'price': 11000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_022.webp', 'mature': 'mature/v21b_OUTFIT_022.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_023', 'n': 'Survêt Lilas', 'd': 'Survêtement lilas et baskets blanches.', 'price': 10000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_023.webp', 'mature': 'mature/v21b_OUTFIT_023.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_024', 'n': 'Survêt Terrain', 'd': 'Survêtement vert terrain, casquette assortie.', 'price': 12000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_024.webp', 'mature': 'mature/v21b_OUTFIT_024.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_025', 'n': 'Survêt Cuivre', 'd': 'Survêtement cuivre, liseré crème.', 'price': 13000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_025.webp', 'mature': 'mature/v21b_OUTFIT_025.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_026', 'n': 'Survêt Glace', 'd': 'Survêtement blanc glacier, détails cyan.', 'price': 14000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_026.webp', 'mature': 'mature/v21b_OUTFIT_026.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_027', 'n': 'Survêt Magenta', 'd': 'Survêtement magenta intégral, pour se faire remarquer.', 'price': 15000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_027.webp', 'mature': 'mature/v21b_OUTFIT_027.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_028', 'n': 'Casque et Hoodie', 'd': 'Hoodie violet et casque de studio autour du cou.', 'price': 9000, 'rank': 1, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_028.webp', 'mature': 'mature/v21b_OUTFIT_028.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_029', 'n': 'Nuit de Cabine', 'd': 'Tee noir, casque rose : la tenue des prises de nuit.', 'price': 8500, 'rank': 1, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_029.webp', 'mature': 'mature/v21b_OUTFIT_029.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_030', 'n': 'Producteur Indigo', 'd': 'Bomber indigo, lunettes fumées et casque.', 'price': 16000, 'rank': 2, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_030.webp', 'mature': 'mature/v21b_OUTFIT_030.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_031', 'n': 'Session Crème', 'd': 'Hoodie crème et casque, ambiance session du dimanche.', 'price': 11000, 'rank': 2, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_031.webp', 'mature': 'mature/v21b_OUTFIT_031.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_032', 'n': 'Bomber Néon', 'd': 'Bomber magenta brillant, chaussures cyan : fait pour les projecteurs.', 'price': 18000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_032.webp', 'mature': 'mature/v21b_OUTFIT_032.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_033', 'n': 'Bomber Or Noir', 'd': 'Bomber noir à reflets or, chaîne épaisse.', 'price': 24000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_033.webp', 'mature': 'mature/v21b_OUTFIT_033.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_034', 'n': 'Hoodie Électrique', 'd': 'Hoodie bleu électrique, coutures jaunes.', 'price': 17000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_034.webp', 'mature': 'mature/v21b_OUTFIT_034.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_035', 'n': 'Lunettes de Scène', 'd': 'Bomber rouge, lunettes noires : le regard qui ne cligne pas.', 'price': 22000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_035.webp', 'mature': 'mature/v21b_OUTFIT_035.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_036', 'n': 'Parvis Live', 'd': 'Hoodie blanc éclatant sous la lumière du Parvis.', 'price': 19000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_036.webp', 'mature': 'mature/v21b_OUTFIT_036.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_037', 'n': 'Festival Lagune', 'd': 'Tee cyan, lunettes, chaîne : la tenue du festival Lagune d\'Ambre.', 'price': 26000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_037.webp', 'mature': 'mature/v21b_OUTFIT_037.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_038', 'n': 'Bomber Aurore', 'd': 'Bomber dégradé rose et violet, détails or.', 'price': 28000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_038.webp', 'mature': 'mature/v21b_OUTFIT_038.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_039', 'n': 'Rouge Tamarel', 'd': 'Hoodie rouge vif et casquette noire, prêt pour Tamarel Open Air.', 'price': 30000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_039.webp', 'mature': 'mature/v21b_OUTFIT_039.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_040', 'n': 'Blazer Ivoire', 'd': 'Blazer ivoire et pantalon nuit, pour les interviews.', 'price': 32000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_040.webp', 'mature': 'mature/v21b_OUTFIT_040.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_041', 'n': 'Blazer Bordeaux', 'd': 'Blazer bordeaux, chaussures or.', 'price': 36000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_041.webp', 'mature': 'mature/v21b_OUTFIT_041.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_042', 'n': 'Blazer Émeraude', 'd': 'Blazer émeraude, lunettes fines.', 'price': 38000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_042.webp', 'mature': 'mature/v21b_OUTFIT_042.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_043', 'n': 'Blazer Ciel', 'd': 'Blazer bleu ciel, sneakers blanches : chic mais rue.', 'price': 34000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_043.webp', 'mature': 'mature/v21b_OUTFIT_043.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_044', 'n': 'Signature Label', 'd': 'Blazer gris anthracite pour signer un contrat.', 'price': 40000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_044.webp', 'mature': 'mature/v21b_OUTFIT_044.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_045', 'n': 'Blazer Terracotta', 'd': 'Blazer terracotta, chemise sombre.', 'price': 37000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_045.webp', 'mature': 'mature/v21b_OUTFIT_045.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_046', 'n': 'Remise de Prix', 'd': 'Blazer noir profond et lunettes, pour la cérémonie.', 'price': 48000, 'rank': 4, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_046.webp', 'mature': 'mature/v21b_OUTFIT_046.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_047', 'n': 'Blazer Lavande', 'd': 'Blazer lavande, chaussures blanches.', 'price': 35000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_047.webp', 'mature': 'mature/v21b_OUTFIT_047.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_048', 'n': 'Or de Bakoma', 'd': 'Blazer or massif et chaîne lourde : le trône de Bakoma.', 'price': 120000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_048.webp', 'mature': 'mature/v21b_OUTFIT_048.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_049', 'n': 'Velours Nuit', 'd': 'Blazer velours violet profond, bagues et lunettes.', 'price': 95000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_049.webp', 'mature': 'mature/v21b_OUTFIT_049.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_050', 'n': 'Platine', 'd': 'Ensemble blanc platine, accents argent.', 'price': 150000, 'rank': 5, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_050.webp', 'mature': 'mature/v21b_OUTFIT_050.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_051', 'n': 'Diamant Noir', 'd': 'Bomber noir mat, chaîne et bagues : la tenue des grandes dates.', 'price': 180000, 'rank': 5, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_051.webp', 'mature': 'mature/v21b_OUTFIT_051.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_052', 'n': 'Empereur Cauri', 'd': 'Blazer rouge impérial et or, réservé aux légendes.', 'price': 250000, 'rank': 5, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_052.webp', 'mature': 'mature/v21b_OUTFIT_052.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_053', 'n': 'Saphir', 'd': 'Blazer bleu saphir, chaussures or, lunettes fines.', 'price': 110000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_053.webp', 'mature': 'mature/v21b_OUTFIT_053.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_054', 'n': 'Jade Royal', 'd': 'Bomber jade profond, finitions or.', 'price': 90000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_054.webp', 'mature': 'mature/v21b_OUTFIT_054.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_055', 'n': 'Rose Champagne', 'd': 'Blazer rose champagne pour les soirées de label.', 'price': 100000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_055.webp', 'mature': 'mature/v21b_OUTFIT_055.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_056', 'n': 'Bagues Dorées', 'd': 'Tee noir et bagues or aux deux oreilles : les bijoux parlent.', 'price': 15000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_056.webp', 'mature': 'mature/v21b_OUTFIT_056.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_057', 'n': 'Chaîne et Lunettes', 'd': 'Hoodie blanc, chaîne or et lunettes noires.', 'price': 20000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_057.webp', 'mature': 'mature/v21b_OUTFIT_057.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_058', 'n': 'Parure Complète', 'd': 'Bomber nuit, chaîne, bagues et lunettes.', 'price': 45000, 'rank': 3, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_058.webp', 'mature': 'mature/v21b_OUTFIT_058.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_059', 'n': 'Casquette et Bagues', 'd': 'Tee magenta, casquette noire et bagues or.', 'price': 18000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_059.webp', 'mature': 'mature/v21b_OUTFIT_059.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_060', 'n': 'Lunettes Cyan', 'd': 'Tee cyan et lunettes noires pour le soleil de Sélène.', 'price': 12000, 'rank': 1, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_060.webp', 'mature': 'mature/v21b_OUTFIT_060.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_061', 'n': 'Or et Casque', 'd': 'Hoodie noir, casque rose et bagues or.', 'price': 26000, 'rank': 3, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_061.webp', 'mature': 'mature/v21b_OUTFIT_061.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_062', 'n': 'Collection Cauri', 'd': 'Blazer crème et bijoux or façon cauri.', 'price': 60000, 'rank': 4, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_062.webp', 'mature': 'mature/v21b_OUTFIT_062.webp'}, 'status': 'disponible'},
    {'id': 'OUTFIT_063', 'n': 'Casquette Dorée', 'd': 'Bomber violet et casquette, chaîne or.', 'price': 16000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_063.webp', 'mature': 'mature/v21b_OUTFIT_063.webp'}, 'status': 'disponible'},
  ];

  /// Catégories de la garde-robe (filtres de l'écran 21-W1).
  static const categories = ['Street', 'Sport', 'Studio', 'Scène', 'Chic', 'Luxe', 'Bijoux'];

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
