import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_nav_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/screen_background.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../../domain/studio_models.dart';
import 'hud.dart';

/// Coque : fond v20, HUD en haut, cinq onglets en bas (QG, Studio, Scène, Business, Profil).
/// Affiche « Niveau supérieur » (10.4) dès qu'un niveau gagné attend sa récompense, quel que soit l'écran.
class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _levelSheetOpen = false;

  void _showLevelUp(Pending pend) {
    _levelSheetOpen = true;
    showGameSheet<void>(
      context,
      dismissible: false,
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
      backgroundColor: Tk.bg,
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 0), child: Hud()),
            Expanded(child: shell),
          ]),
        ),
      ),
      bottomNavigationBar: GameNavBar(currentIndex: shell.currentIndex, onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex)),
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
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NIVEAU SUPÉRIEUR', style: V20Text.lab()),
        Text('N${pend.lvl}', style: V20Text.baloo(size: 48, line: 44, color: Tk.gold)),
        Text(Econ.levelNames[pend.lvl - 1].toUpperCase(), style: V20Text.dm(size: 26)),
        if (_unlocks[pend.lvl] case final text?) ...[
          const SizedBox(height: 8),
          Text(text, style: V20Text.bm),
        ],
        if (pend.reward > 0) ...[
          const SizedBox(height: 16),
          Text('+ ${fmt(pend.reward)} cauris', style: V20Text.nm(color: Tk.gold)),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'Continuer', onPressed: onContinue),
      ]);
}
