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
import 'justice_screens.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';

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
  final String location;
  const Shell21({super.key, required this.shell, required this.location, this.showNav = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pas d'artiste créé : retour au démarrage (splash et création).
    final s = ref.watch(game21Provider).valueOrNull;
    if (s != null && s['created'] != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/demarrer');
      });
    }
    final jailed = s != null && s['jail'] != null;
    if (jailed && location != '/business/justice/prison') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/business/justice/prison');
      });
    }
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 1000;
      final page = jailed ? const PrisonScreen() : shell;
      return GameScaffold(
        hud: const Hud21(),
        body: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!jailed)
                    _DesktopNav21(
                      currentIndex: shell.currentIndex,
                      onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1600),
                        child: page,
                      ),
                    ),
                  ),
                ],
              )
            : page,
        bottomNavigationBar: !desktop && !jailed && showNav
            ? GameNavBar(
                currentIndex: shell.currentIndex,
                onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              )
            : null,
      );
    });
  }
}

/// Cadre des écrans plein écran avec HUD mais sans navigation (journée, bilan, événements, vie perso) : le contenu défile.
class Frame21 extends ConsumerWidget {
  final List<Widget> children;
  /// Écran accessible en prison (bilan de fin de journée) : pas de renvoi vers la cellule.
  final bool allowInJail;
  const Frame21({super.key, required this.children, this.allowInJail = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s != null && s['jail'] != null && !allowInJail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/business/justice/prison');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.sizeOf(context).width >= 1000 ? 32 : 16,
                  8,
                  MediaQuery.sizeOf(context).width >= 1000 ? 32 : 16,
                  0,
                ),
                child: const Hud21(),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: ListView(
                      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width >= 1000 ? 32 : 16),
                      children: children,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
  }
}

/// Valeur de Reg21 lisible depuis un écran sans importer le moteur entier.
int get dayEnd21 => Reg21.dayEnd;

/// Navigation verticale pour PC : les cinq destinations et leurs routes restent identiques.
class _DesktopNav21 extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _DesktopNav21({required this.currentIndex, required this.onTap});

  static const _items = <(String, IconData)>[
    ('QG', Icons.home_rounded),
    ('Studio', Icons.mic_rounded),
    ('Scène', Icons.local_fire_department_rounded),
    ('Business', Icons.business_center_rounded),
    ('Profil', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: 224,
    margin: const EdgeInsets.fromLTRB(16, 12, 0, 16),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    decoration: BoxDecoration(
      color: Tk.s1.withOpacity(.92),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Tk.line),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RAP EMPIRE', style: V20Text.poppins(size: 18, line: 24, weight: FontWeight.w900, color: Tk.ink, spacing: .5)),
          const SizedBox(height: 4),
          Text('TON EMPIRE MUSICAL', style: V20Text.poppins(size: 9, line: 14, weight: FontWeight.w700, color: Tk.cy, spacing: 1.2)),
        ]),
      ),
      for (var i = 0; i < _items.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: i == currentIndex ? Tk.acc.withOpacity(.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(i),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: i == currentIndex ? Tk.acc : Colors.transparent),
                ),
                child: Row(children: [
                  Icon(_items[i].$2, size: 20, color: i == currentIndex ? Tk.ink : V20.ink2),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_items[i].$1, style: V20Text.poppins(
                    size: 13, line: 18, weight: FontWeight.w700,
                    color: i == currentIndex ? Tk.ink : V20.ink2,
                  ))),
                  if (i == currentIndex)
                    Container(width: 5, height: 5, decoration: const BoxDecoration(color: Tk.gold, shape: BoxShape.circle)),
                ]),
              ),
            ),
          ),
        ),
      const Spacer(),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Tk.bg.withOpacity(.65), borderRadius: BorderRadius.circular(14)),
        child: Text('Chaque décision construit ta carrière.', style: V20Text.poppins(
          size: 11, line: 16, weight: FontWeight.w500, color: V20.ink2,
        )),
      ),
    ]),
  );
}
