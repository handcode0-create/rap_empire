import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/game_nav_bar.dart';
import '../../core/widgets/game_scaffold.dart';
import 'hud.dart';

/// Coque : fond v20, HUD en haut et, sur les écrans racines des cinq onglets (QG, Studio, Scène, Business, Profil),
/// la barre de navigation. Les écrans de détail (planches 04.3 et suivantes) n'ont pas de navigation : bouton retour à la place.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  final bool showNav;

  /// Décor illustré du lieu (assets/scenes) : seulement sur les écrans pilotes de la direction Néon de Bakoma ; null = fond v20 habituel.
  final String? scene;
  const AppShell({super.key, required this.shell, this.showNav = true, this.scene});

  @override
  Widget build(BuildContext context) => GameScaffold(
        scene: scene,
        hud: const Hud(),
        body: shell,
        bottomNavigationBar: showNav ? GameNavBar(currentIndex: shell.currentIndex, onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex)) : null,
      );
}
