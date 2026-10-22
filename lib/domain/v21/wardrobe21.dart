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
    {'id': 'OUTFIT_001', 'n': 'Hoodie Néon', 'd': 'Le hoodie rose de tes débuts, patch BKM sur la poitrine.', 'price': 0, 'rank': 1, 'start': true, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_001.svg', 'mature': 'mature/v21b_OUTFIT_001.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_002', 'n': 'Survêt Soleil', 'd': 'Survêtement jaune soleil, zip et bandes magenta.', 'price': 6000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_002.svg', 'mature': 'mature/v21b_OUTFIT_002.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_003', 'n': 'Veste Brume', 'd': 'Veste gris-violet, baskets cyan. Le look des sessions studio.', 'price': 18000, 'rank': 1, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_003.svg', 'mature': 'mature/v21b_OUTFIT_003.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_004', 'n': 'Veste Nuit', 'd': 'Blazer bleu nuit et détails or, pour les grandes scènes.', 'price': 30000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_004.svg', 'mature': 'mature/v21b_OUTFIT_004.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_005', 'n': 'Hoodie Jade', 'd': 'Hoodie vert jade.', 'price': 12000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_005.svg', 'mature': 'mature/v21b_OUTFIT_005.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_006', 'n': 'Hoodie Cobalt', 'd': 'Hoodie bleu cobalt, coutures cyan et sneakers blanches pour les sessions de nuit.', 'price': 14000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_006.svg', 'mature': 'mature/v21b_OUTFIT_006.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_007', 'n': 'Veste Cuivre', 'd': 'Veste courte cuivre et pantalon anthracite, un look affirmé pour les showcases.', 'price': 22000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_007.svg', 'mature': 'mature/v21b_OUTFIT_007.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_008', 'n': 'Ensemble Impérial', 'd': 'Ensemble noir profond, finitions or et chaîne de scène.', 'price': 42000, 'rank': 3, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_008.svg', 'mature': 'mature/v21b_OUTFIT_008.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_009', 'n': 'Néon de Bakoma', 'd': 'Tenue de performance magenta et cyan, conçue pour les grandes scènes.', 'price': 65000, 'rank': 5, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_009.svg', 'mature': 'mature/v21b_OUTFIT_009.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_010', 'n': 'Hoodie Corail', 'd': 'Hoodie corail et jogging nuit, le basique des sessions au quartier.', 'price': 5000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_010.svg', 'mature': 'mature/v21b_OUTFIT_010.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_011', 'n': 'Hoodie Ardoise', 'd': 'Hoodie gris ardoise, sneakers blanches, simple et propre.', 'price': 4500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_011.svg', 'mature': 'mature/v21b_OUTFIT_011.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_012', 'n': 'Hoodie Lagune', 'd': 'Hoodie bleu lagune, rappel cyan sur les chaussures.', 'price': 6000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_012.svg', 'mature': 'mature/v21b_OUTFIT_012.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_013', 'n': 'Hoodie Mangue', 'd': 'Hoodie jaune mangue, pantalon violet, impossible à rater.', 'price': 7000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_013.svg', 'mature': 'mature/v21b_OUTFIT_013.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_014', 'n': 'Tee Blanc Ndolo', 'd': 'T-shirt blanc oversize et pantalon cargo nuit.', 'price': 3500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_014.svg', 'mature': 'mature/v21b_OUTFIT_014.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_015', 'n': 'Tee Prune', 'd': 'T-shirt prune, sneakers or : le look du carrefour.', 'price': 4000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_015.svg', 'mature': 'mature/v21b_OUTFIT_015.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_016', 'n': 'Tee Sable', 'd': 'T-shirt sable et jean foncé, avec casquette.', 'price': 5500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_016.svg', 'mature': 'mature/v21b_OUTFIT_016.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_017', 'n': 'Casquette Gbaka', 'd': 'Hoodie noir, casquette rose : la tenue du gbaka de 6 h.', 'price': 8000, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_017.svg', 'mature': 'mature/v21b_OUTFIT_017.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_018', 'n': 'Hoodie Olive', 'd': 'Hoodie olive, cargo sombre, baskets crème.', 'price': 6500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_018.svg', 'mature': 'mature/v21b_OUTFIT_018.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_019', 'n': 'Tee Rouge Brique', 'd': 'T-shirt rouge brique et jogging gris.', 'price': 4500, 'rank': 1, 'start': false, 'cat': 'Street', 'images': {'young': 'young/v21b_OUTFIT_019.svg', 'mature': 'mature/v21b_OUTFIT_019.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_020', 'n': 'Survêt Menthe', 'd': 'Survêtement menthe à bandes blanches.', 'price': 9000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_020.svg', 'mature': 'mature/v21b_OUTFIT_020.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_021', 'n': 'Survêt Nuit Bleue', 'd': 'Survêtement bleu nuit, zip or.', 'price': 10000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_021.svg', 'mature': 'mature/v21b_OUTFIT_021.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_022', 'n': 'Survêt Braise', 'd': 'Survêtement orange braise, bandes noires.', 'price': 11000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_022.svg', 'mature': 'mature/v21b_OUTFIT_022.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_023', 'n': 'Survêt Lilas', 'd': 'Survêtement lilas et baskets blanches.', 'price': 10000, 'rank': 1, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_023.svg', 'mature': 'mature/v21b_OUTFIT_023.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_024', 'n': 'Survêt Terrain', 'd': 'Survêtement vert terrain, casquette assortie.', 'price': 12000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_024.svg', 'mature': 'mature/v21b_OUTFIT_024.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_025', 'n': 'Survêt Cuivre', 'd': 'Survêtement cuivre, liseré crème.', 'price': 13000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_025.svg', 'mature': 'mature/v21b_OUTFIT_025.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_026', 'n': 'Survêt Glace', 'd': 'Survêtement blanc glacier, détails cyan.', 'price': 14000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_026.svg', 'mature': 'mature/v21b_OUTFIT_026.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_027', 'n': 'Survêt Magenta', 'd': 'Survêtement magenta intégral, pour se faire remarquer.', 'price': 15000, 'rank': 2, 'start': false, 'cat': 'Sport', 'images': {'young': 'young/v21b_OUTFIT_027.svg', 'mature': 'mature/v21b_OUTFIT_027.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_028', 'n': 'Casque et Hoodie', 'd': 'Hoodie violet et casque de studio autour du cou.', 'price': 9000, 'rank': 1, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_028.svg', 'mature': 'mature/v21b_OUTFIT_028.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_029', 'n': 'Nuit de Cabine', 'd': 'Tee noir, casque rose : la tenue des prises de nuit.', 'price': 8500, 'rank': 1, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_029.svg', 'mature': 'mature/v21b_OUTFIT_029.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_030', 'n': 'Producteur Indigo', 'd': 'Bomber indigo, lunettes fumées et casque.', 'price': 16000, 'rank': 2, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_030.svg', 'mature': 'mature/v21b_OUTFIT_030.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_031', 'n': 'Session Crème', 'd': 'Hoodie crème et casque, ambiance session du dimanche.', 'price': 11000, 'rank': 2, 'start': false, 'cat': 'Studio', 'images': {'young': 'young/v21b_OUTFIT_031.svg', 'mature': 'mature/v21b_OUTFIT_031.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_032', 'n': 'Bomber Néon', 'd': 'Bomber magenta brillant, chaussures cyan : fait pour les projecteurs.', 'price': 18000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_032.svg', 'mature': 'mature/v21b_OUTFIT_032.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_033', 'n': 'Bomber Or Noir', 'd': 'Bomber noir à reflets or, chaîne épaisse.', 'price': 24000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_033.svg', 'mature': 'mature/v21b_OUTFIT_033.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_034', 'n': 'Hoodie Électrique', 'd': 'Hoodie bleu électrique, coutures jaunes.', 'price': 17000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_034.svg', 'mature': 'mature/v21b_OUTFIT_034.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_035', 'n': 'Lunettes de Scène', 'd': 'Bomber rouge, lunettes noires : le regard qui ne cligne pas.', 'price': 22000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_035.svg', 'mature': 'mature/v21b_OUTFIT_035.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_036', 'n': 'Parvis Live', 'd': 'Hoodie blanc éclatant sous la lumière du Parvis.', 'price': 19000, 'rank': 2, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_036.svg', 'mature': 'mature/v21b_OUTFIT_036.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_037', 'n': 'Festival Lagune', 'd': 'Tee cyan, lunettes, chaîne : la tenue du festival Lagune d\'Ambre.', 'price': 26000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_037.svg', 'mature': 'mature/v21b_OUTFIT_037.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_038', 'n': 'Bomber Aurore', 'd': 'Bomber dégradé rose et violet, détails or.', 'price': 28000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_038.svg', 'mature': 'mature/v21b_OUTFIT_038.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_039', 'n': 'Rouge Tamarel', 'd': 'Hoodie rouge vif et casquette noire, prêt pour Tamarel Open Air.', 'price': 30000, 'rank': 3, 'start': false, 'cat': 'Scène', 'images': {'young': 'young/v21b_OUTFIT_039.svg', 'mature': 'mature/v21b_OUTFIT_039.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_040', 'n': 'Blazer Ivoire', 'd': 'Blazer ivoire et pantalon nuit, pour les interviews.', 'price': 32000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_040.svg', 'mature': 'mature/v21b_OUTFIT_040.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_041', 'n': 'Blazer Bordeaux', 'd': 'Blazer bordeaux, chaussures or.', 'price': 36000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_041.svg', 'mature': 'mature/v21b_OUTFIT_041.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_042', 'n': 'Blazer Émeraude', 'd': 'Blazer émeraude, lunettes fines.', 'price': 38000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_042.svg', 'mature': 'mature/v21b_OUTFIT_042.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_043', 'n': 'Blazer Ciel', 'd': 'Blazer bleu ciel, sneakers blanches : chic mais rue.', 'price': 34000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_043.svg', 'mature': 'mature/v21b_OUTFIT_043.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_044', 'n': 'Signature Label', 'd': 'Blazer gris anthracite pour signer un contrat.', 'price': 40000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_044.svg', 'mature': 'mature/v21b_OUTFIT_044.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_045', 'n': 'Blazer Terracotta', 'd': 'Blazer terracotta, chemise sombre.', 'price': 37000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_045.svg', 'mature': 'mature/v21b_OUTFIT_045.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_046', 'n': 'Remise de Prix', 'd': 'Blazer noir profond et lunettes, pour la cérémonie.', 'price': 48000, 'rank': 4, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_046.svg', 'mature': 'mature/v21b_OUTFIT_046.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_047', 'n': 'Blazer Lavande', 'd': 'Blazer lavande, chaussures blanches.', 'price': 35000, 'rank': 3, 'start': false, 'cat': 'Chic', 'images': {'young': 'young/v21b_OUTFIT_047.svg', 'mature': 'mature/v21b_OUTFIT_047.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_048', 'n': 'Or de Bakoma', 'd': 'Blazer or massif et chaîne lourde : le trône de Bakoma.', 'price': 120000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_048.svg', 'mature': 'mature/v21b_OUTFIT_048.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_049', 'n': 'Velours Nuit', 'd': 'Blazer velours violet profond, bagues et lunettes.', 'price': 95000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_049.svg', 'mature': 'mature/v21b_OUTFIT_049.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_050', 'n': 'Platine', 'd': 'Ensemble blanc platine, accents argent.', 'price': 150000, 'rank': 5, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_050.svg', 'mature': 'mature/v21b_OUTFIT_050.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_051', 'n': 'Diamant Noir', 'd': 'Bomber noir mat, chaîne et bagues : la tenue des grandes dates.', 'price': 180000, 'rank': 5, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_051.svg', 'mature': 'mature/v21b_OUTFIT_051.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_052', 'n': 'Empereur Cauri', 'd': 'Blazer rouge impérial et or, réservé aux légendes.', 'price': 250000, 'rank': 5, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_052.svg', 'mature': 'mature/v21b_OUTFIT_052.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_053', 'n': 'Saphir', 'd': 'Blazer bleu saphir, chaussures or, lunettes fines.', 'price': 110000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_053.svg', 'mature': 'mature/v21b_OUTFIT_053.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_054', 'n': 'Jade Royal', 'd': 'Bomber jade profond, finitions or.', 'price': 90000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_054.svg', 'mature': 'mature/v21b_OUTFIT_054.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_055', 'n': 'Rose Champagne', 'd': 'Blazer rose champagne pour les soirées de label.', 'price': 100000, 'rank': 4, 'start': false, 'cat': 'Luxe', 'images': {'young': 'young/v21b_OUTFIT_055.svg', 'mature': 'mature/v21b_OUTFIT_055.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_056', 'n': 'Bagues Dorées', 'd': 'Tee noir et bagues or aux deux oreilles : les bijoux parlent.', 'price': 15000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_056.svg', 'mature': 'mature/v21b_OUTFIT_056.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_057', 'n': 'Chaîne et Lunettes', 'd': 'Hoodie blanc, chaîne or et lunettes noires.', 'price': 20000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_057.svg', 'mature': 'mature/v21b_OUTFIT_057.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_058', 'n': 'Parure Complète', 'd': 'Bomber nuit, chaîne, bagues et lunettes.', 'price': 45000, 'rank': 3, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_058.svg', 'mature': 'mature/v21b_OUTFIT_058.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_059', 'n': 'Casquette et Bagues', 'd': 'Tee magenta, casquette noire et bagues or.', 'price': 18000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_059.svg', 'mature': 'mature/v21b_OUTFIT_059.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_060', 'n': 'Lunettes Cyan', 'd': 'Tee cyan et lunettes noires pour le soleil de Sélène.', 'price': 12000, 'rank': 1, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_060.svg', 'mature': 'mature/v21b_OUTFIT_060.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_061', 'n': 'Or et Casque', 'd': 'Hoodie noir, casque rose et bagues or.', 'price': 26000, 'rank': 3, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_061.svg', 'mature': 'mature/v21b_OUTFIT_061.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_062', 'n': 'Collection Cauri', 'd': 'Blazer crème et bijoux or façon cauri.', 'price': 60000, 'rank': 4, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_062.svg', 'mature': 'mature/v21b_OUTFIT_062.svg'}, 'status': 'disponible'},
    {'id': 'OUTFIT_063', 'n': 'Casquette Dorée', 'd': 'Bomber violet et casquette, chaîne or.', 'price': 16000, 'rank': 2, 'start': false, 'cat': 'Bijoux', 'images': {'young': 'young/v21b_OUTFIT_063.svg', 'mature': 'mature/v21b_OUTFIT_063.svg'}, 'status': 'disponible'},
  ];

  /// Catégories de la garde-robe (filtres de l'écran 21-W1).
  static const categories = ['Street', 'Sport', 'Studio', 'Scène', 'Chic', 'Luxe', 'Bijoux'];

  static const startId = 'OUTFIT_001';

  /// Coiffures du joueur (calques assets/characters/rapper_001/layers/hairfront et hairback, générés par tools/design/gen_wardrobe_layers.py).
  /// Prix et rangs : [PROPOSÉ], provisoires comme tout l'équilibrage (D-08). Les trois coiffures du créateur de personnage sont offertes au départ.
  static const hairs = <Map<String, dynamic>>[
    {'id': 'hitwist', 'n': 'Twists hi-top', 'd': 'Ta coiffure de départ : des twists courts, montés haut.', 'price': 0, 'rank': 1},
    {'id': 'bald', 'n': 'Rasé', 'd': 'Crâne net, aucune excuse.', 'price': 1000, 'rank': 1},
    {'id': 'fade', 'n': 'Dégradé', 'd': 'Côtés rasés, dessus ras : propre et sobre.', 'price': 1500, 'rank': 1},
    {'id': 'cornrows', 'n': 'Nattes collées', 'd': 'Cinq nattes plaquées vers l\'arrière.', 'price': 2500, 'rank': 1},
    {'id': 'twists', 'n': 'Twists courts', 'd': 'Petits twists dressés, texture visible.', 'price': 3500, 'rank': 1},
    {'id': 'afro', 'n': 'Afro', 'd': 'Volume naturel, présence immédiate.', 'price': 4000, 'rank': 1},
    {'id': 'hightop', 'n': 'Hi-top fade', 'd': 'Dessus carré, côtés dégradés : la coupe des années rap.', 'price': 5000, 'rank': 2},
    {'id': 'puffs', 'n': 'Afro puffs', 'd': 'Deux touffes rondes de chaque côté.', 'price': 6000, 'rank': 2},
    {'id': 'knots', 'n': 'Bantu knots', 'd': 'Nœuds de cheveux enroulés en couronne.', 'price': 8000, 'rank': 2},
    {'id': 'mohawk', 'n': 'Crête', 'd': 'Une bande centrale, les côtés rasés. Pour les grandes scènes.', 'price': 9000, 'rank': 3},
    {'id': 'braids', 'n': 'Tresses longues', 'd': 'Tresses fines qui tombent sur les épaules.', 'price': 12000, 'rank': 3},
    {'id': 'locks', 'n': 'Locks', 'd': 'Locks longues, des années de patience.', 'price': 20000, 'rank': 4},
  ];

  /// Zones de tatouage : un seul tatouage équipé par zone, retirable à tout moment.
  static const tattooZones = <String, String>{'visage': 'Visage', 'cou': 'Cou', 'mains': 'Mains'};

  /// Tatouages (calques layers/tat). Motifs inspirés du monde du jeu (cauris, soleil de Bakoma) ; aucun symbole réel.
  static const tattoos = <Map<String, dynamic>>[
    {'id': 'main_phalanges', 'zone': 'mains', 'n': 'Phalanges', 'd': 'Quatre points sur chaque main, le signe des débuts.', 'price': 3000, 'rank': 1},
    {'id': 'cou_bande', 'zone': 'cou', 'n': 'Bande en zigzag', 'd': 'Un zigzag fin à la base du cou.', 'price': 4000, 'rank': 1},
    {'id': 'vis_ligne', 'zone': 'visage', 'n': 'Double trait', 'd': 'Deux traits sur la tempe droite.', 'price': 5000, 'rank': 2},
    {'id': 'main_cauri', 'zone': 'mains', 'n': 'Cauri', 'd': 'Un cauri sur le dos de chaque main : la monnaie de Bakoma.', 'price': 6000, 'rank': 2},
    {'id': 'cou_cauris', 'zone': 'cou', 'n': 'Trois cauris', 'd': 'Trois cauris alignés sous la mâchoire.', 'price': 8000, 'rank': 2},
    {'id': 'main_soleil', 'zone': 'mains', 'n': 'Soleil de Bakoma', 'd': 'Un soleil rayonnant sur chaque main.', 'price': 9000, 'rank': 3},
    {'id': 'vis_tempe', 'zone': 'visage', 'n': 'Marques de tempe', 'd': 'Trois traits de chaque côté du visage.', 'price': 12000, 'rank': 3},
    {'id': 'vis_etoile', 'zone': 'visage', 'n': 'Étoile de pommette', 'd': 'Une étoile à quatre branches sous l\'œil gauche.', 'price': 15000, 'rank': 3},
    {'id': 'cou_soleil', 'zone': 'cou', 'n': 'Soleil du cou', 'd': 'Un soleil gravé au creux du cou, pour les légendes.', 'price': 18000, 'rank': 4},
  ];
}

/// État de départ de la garde-robe : Hoodie Néon possédé et équipé.
Map<String, dynamic> initWardrobe21() => {
      'owned': [Wardrobe21.startId],
      'eq': Wardrobe21.startId,
      'sel': Wardrobe21.startId,
      'ask': null,
      'hair': 'hitwist',
      'hairs': ['hitwist'],
      'tat': <String, dynamic>{},
      'tats': <String>[],
      'cask': null,
    };

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

// ---------------------------------------------------------------------------------------------------------------------
// Coiffures et tatouages. Les anciennes sauvegardes n'ont pas ces clés : chaque lecture a une valeur par défaut.
// ---------------------------------------------------------------------------------------------------------------------

/// Coiffure équipée (par défaut celle du créateur de personnage).
String hairOf21(J s) {
  final wd = s['wd'] as J?;
  final h = wd?['hair'];
  if (h is String && hair21(h) != null) return h;
  final ap = (s['ap'] as J?)?['hair'];
  return ap is String && hair21(ap) != null ? ap : 'hitwist';
}

List<String> hairsOwned21(J s) {
  final l = ((s['wd'] as J?)?['hairs'] as List?)?.cast<String>() ?? const <String>[];
  return {'hitwist', hairOf21(s), ...l}.toList();
}

/// Tatouages équipés, par zone.
Map<String, String> tattoosOf21(J s) {
  final m = (s['wd'] as J?)?['tat'];
  if (m is! Map) return const {};
  return {for (final e in m.entries) if (e.value is String && tattoo21(e.value as String) != null) e.key as String: e.value as String};
}

List<String> tattoosOwned21(J s) => (((s['wd'] as J?)?['tats'] as List?) ?? const []).cast<String>();

Map<String, dynamic>? hair21(String? id) {
  for (final h in Wardrobe21.hairs) {
    if (h['id'] == id) return h;
  }
  return null;
}

Map<String, dynamic>? tattoo21(String? id) {
  for (final t in Wardrobe21.tattoos) {
    if (t['id'] == id) return t;
  }
  return null;
}

/// Une coiffure ou un tatouage, par identifiant (les deux catalogues n'ont aucun identifiant commun).
Map<String, dynamic>? cosmetic21(String? id) => hair21(id) ?? tattoo21(id);

bool isHair21(String id) => hair21(id) != null;

bool cosmeticOwned21(J s, String id) => isHair21(id) ? hairsOwned21(s).contains(id) : tattoosOwned21(s).contains(id);

bool cosmeticEquipped21(J s, String id) {
  if (isHair21(id)) return hairOf21(s) == id;
  final t = tattoo21(id);
  return t != null && tattoosOf21(s)[t['zone']] == id;
}

/// Code d'erreur d'un achat de coiffure ou de tatouage, ou null s'il est possible.
String? cosmeticCheck21(J s, String id) {
  final o = cosmetic21(id);
  if (o == null) return 'inconnu';
  if (cosmeticOwned21(s, id)) return 'deja';
  if ((s['rank'] as num) < (o['rank'] as num)) return 'rang';
  if ((s['cash'] as num) < (o['price'] as num)) return 'cash';
  return null;
}

/// Chemins des calques à empiler pour l'apparence demandée, de l'arrière vers l'avant :
/// corps, cheveux arrière, tête, tatouages, cheveux avant, accessoires de tête de la tenue.
/// [variant] : 'young' ou 'mature'. [hair] et [tats] : null = ceux du joueur.
/// Une tenue sans calque de corps (ou sans identifiant) donne null : l'appelant garde l'illustration complète.
List<String>? layerPaths21(J s, {String? outfitId, String? variant, String? hair, Map<String, String>? tats, bool? hasTop}) {
  final o = outfit21(outfitId ?? (s['wd'] as J)['eq'] as String?);
  if (o == null) return null;
  final v = variant ?? ageVariant21(s), h = hair ?? hairOf21(s), tt = tats ?? tattoosOf21(s);
  const base = '${Wardrobe21.base}layers/';
  const noBack = {'hitwist', 'fade', 'cornrows', 'knots', 'bald', 'twists', 'hightop', 'mohawk', 'puffs'};
  return [
    '${base}body/${o['id']}.svg',
    if (!noBack.contains(h)) '${base}hairback/${h}_$v.svg',
    '${base}head/$v.svg',
    for (final id in tt.values) '${base}tat/${id}_$v.svg',
    '${base}hairfront/${h}_$v.svg',
    if (hasTop ?? outfitHasTop21(o['id'] as String)) '${base}top/${o['id']}_$v.svg',
  ];
}

/// Tenues qui portent lunettes, casque, casquette ou boucles d'oreille : elles ont un calque « top » au-dessus de la coiffure.
/// Construit à partir de gen_outfits.py (acc contenant glasses, phones, cap ou ring).
const _topOutfits = {
  'OUTFIT_016', 'OUTFIT_017', 'OUTFIT_024', 'OUTFIT_028', 'OUTFIT_029', 'OUTFIT_030', 'OUTFIT_031', 'OUTFIT_033', 'OUTFIT_035', 'OUTFIT_036',
  'OUTFIT_037', 'OUTFIT_038', 'OUTFIT_039', 'OUTFIT_041', 'OUTFIT_042', 'OUTFIT_044', 'OUTFIT_046', 'OUTFIT_048', 'OUTFIT_049', 'OUTFIT_050',
  'OUTFIT_051', 'OUTFIT_052', 'OUTFIT_053', 'OUTFIT_054', 'OUTFIT_055', 'OUTFIT_056', 'OUTFIT_057', 'OUTFIT_058', 'OUTFIT_059', 'OUTFIT_060',
  'OUTFIT_061', 'OUTFIT_062', 'OUTFIT_063',
};
bool outfitHasTop21(String id) => _topOutfits.contains(id);
