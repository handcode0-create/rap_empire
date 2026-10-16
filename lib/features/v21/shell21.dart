import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/widgets/game_nav_bar.dart';
import '../../core/widgets/game_scaffold.dart';
import '../../core/widgets/hud_bar.dart';
import '../../core/widgets/screen_background.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';

/// HUD de la v21 : initiales et nom de l'artiste, rang de carrière, cauris, énergie « x / max » et temps « J1 · 13:00 ».
class Hud21 extends ConsumerWidget {
  const Hud21({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox(height: 120);
    return HudBar(
      initials: initials21(s),
      name: playerName(s),
      levelLabel: rankTag(s),
      xp: xpFraction(s),
      cash: fmt21(s['cash'] as num),
      energy: energyLabel(s),
      time: timeLabel(s),
      bellBadge: s['ev'] != null || (s['fam'] as J)['ev'] != null,
      onBell: () => context.go('/journal'),
    );
  }
}

/// Coque des cinq onglets de la v21 : HUD en haut et, sur les écrans racines, la barre de navigation.
class Shell21 extends ConsumerWidget {
  final StatefulNavigationShell shell;
  final bool showNav;
  const Shell21({super.key, required this.shell, this.showNav = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pas d'artiste créé : retour au démarrage (splash et création).
    final s = ref.watch(game21Provider).valueOrNull;
    if (s != null && s['created'] != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/demarrer');
      });
    }
    return GameScaffold(
        hud: const Hud21(),
        body: shell,
        bottomNavigationBar: showNav ? GameNavBar(currentIndex: shell.currentIndex, onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex)) : null,
    );
  }
}

/// Cadre des écrans plein écran avec HUD mais sans navigation (journée, bilan, événements, vie perso) : le contenu défile.
class Frame21 extends StatelessWidget {
  final List<Widget> children;
  const Frame21({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: Column(children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 0), child: Hud21()),
              Expanded(child: ListView(padding: const EdgeInsets.all(16), children: children)),
            ]),
          ),
        ),
      );
}

/// Valeur de Reg21 lisible depuis un écran sans importer le moteur entier.
int get dayEnd21 => Reg21.dayEnd;
