import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../../domain/studio_models.dart';
import 'buttons.dart';
import 'hud.dart';

/// Coque : HUD en haut, cinq onglets en bas (QG, Studio, Scène, Business, Profil).
/// Affiche « Niveau supérieur » (10.4) dès qu'un niveau gagné attend sa récompense, quel que soit l'écran.
class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  static const tabs = [
    ('QG', Icons.home_rounded),
    ('Studio', Icons.graphic_eq_rounded),
    ('Scène', Icons.mic_external_on_rounded),
    ('Business', Icons.business_center_rounded),
    ('Profil', Icons.person_rounded),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _levelSheetOpen = false;

  void _showLevelUp(Pending pend) {
    _levelSheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Tk.s1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tk.rSheet))),
      builder: (sheetContext) => _LevelUpSheet(
        pend: pend,
        onContinue: () async {
          Navigator.of(sheetContext).pop();
          await ref.read(gameProvider.notifier).acknowledgeLevel();
        },
      ),
    ).whenComplete(() => _levelSheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final pend = ref.watch(gameProvider).valueOrNull?.pend;
    if (pend != null && !_levelSheetOpen) {
      _levelSheetOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _levelSheetOpen = false;
          _showLevelUp(pend);
        }
      });
    }
    final shell = widget.shell;
    return Scaffold(
      body: SafeArea(bottom: false, child: Column(children: [const Hud(), Expanded(child: shell)])),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Tk.deep, border: Border(top: BorderSide(color: Tk.line))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(children: [
              for (var i = 0; i < AppShell.tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    label: AppShell.tabs[i].$1,
                    icon: AppShell.tabs[i].$2,
                    active: shell.currentIndex == i,
                    onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _LevelUpSheet extends StatelessWidget {
  final Pending pend;
  final VoidCallback onContinue;
  const _LevelUpSheet({required this.pend, required this.onContinue});

  /// Nouvelles options annoncées par la planche 10.4 (niveau 2).
  static const _unlocks = {2: 'Nouvelles options : open mic, instru Pont des Griots, missions avancées.'};

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Niveau supérieur', style: TextStyle(color: Tk.ink2)),
            Text('N${pend.lvl}', style: const TextStyle(color: Tk.gold, fontWeight: FontWeight.w800, fontSize: 48)),
            Text(Econ.levelNames[pend.lvl - 1], style: Theme.of(context).textTheme.titleLarge),
            if (_unlocks[pend.lvl] case final text?) ...[
              const SizedBox(height: 8),
              Text(text, style: const TextStyle(color: Tk.ink2)),
            ],
            if (pend.reward > 0) ...[
              const SizedBox(height: 16),
              Text('+ ${fmt(pend.reward)} cauris', style: const TextStyle(color: Tk.gold, fontWeight: FontWeight.w800, fontSize: 20)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(label: 'Continuer', onPressed: onContinue),
          ]),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.label, required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = active ? Tk.acc : Tk.ink2;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: Container(height: 3, decoration: BoxDecoration(color: active ? Tk.acc : Colors.transparent, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)))),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
          ]),
        ]),
      ),
    );
  }
}
