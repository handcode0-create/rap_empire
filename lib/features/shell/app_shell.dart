import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/game_nav_bar.dart';
import '../../core/widgets/screen_background.dart';
import 'hud.dart';

/// Coque : fond v20, HUD en haut et, sur les écrans racines des cinq onglets (QG, Studio, Scène, Business, Profil),
/// la barre de navigation. Les écrans de détail (planches 04.3 et suivantes) n'ont pas de navigation : bouton retour à la place.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  final bool showNav;
  const AppShell({super.key, required this.shell, this.showNav = true});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Tk.bg,
        body: ScreenBackground(
          child: SafeArea(
            bottom: !showNav,
            child: Column(children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 0), child: Hud()),
              Expanded(child: shell),
            ]),
          ),
        ),
        bottomNavigationBar: showNav ? GameNavBar(currentIndex: shell.currentIndex, onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex)) : null,
      );
}
