import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';

/// Les identifiants d'écran du prototype (ex. 03-1-QG) deviennent des routes. Cinq onglets : QG, Studio, Scène, Business, Profil (I-07).
final router = GoRouter(routes: [
  GoRoute(path: '/', name: '03-1-QG', builder: (_, __) => const HomeScreen()),
]);
