import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_icon.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/clock.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/rules.dart';
import 'toast.dart';

/// Dormir puis afficher la fin de journée (03.6).
Future<void> sleepNow(BuildContext context, WidgetRef ref) async {
  await ref.read(gameProvider.notifier).sleep();
  if (context.mounted) context.go('/fin-journee');
}

/// Libellé de la nuit : gratuite en démo (nightCost = 0, D-08), sinon son prix.
String get nightLabel => Econ.nightCost == 0 ? 'Nuit gratuite · démo' : 'Nuit : ${fmt(Econ.nightCost)} cauris';

/// Feuille « Trop fatigué » (03.2) avec l'action Dormir.
void showTiredSheet(BuildContext context, WidgetRef ref, int energy) {
  showGameSheet<void>(
    context,
    builder: (sheetContext) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: Tk.s2, borderRadius: BorderRadius.circular(16), border: Border.all(color: Tk.ink, width: 2)),
          alignment: Alignment.center,
          child: const GameIcon('moon', color: Tk.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ÉNERGIE INSUFFISANTE · $energy', style: V20Text.lab()),
            Text('TROP FATIGUÉ', style: V20Text.dm(size: 26)),
          ]),
        ),
      ]),
      const SizedBox(height: 16),
      const Text('Dors une nuit pour retrouver $maxEnergy énergie. Dans cette démo, la nuit est gratuite : paramètre provisoire (D-08).', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, height: 22 / 15, color: Tk.ink)),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'Dormir',
        sublabel: nightLabel,
        onPressed: () {
          Navigator.of(sheetContext).pop();
          sleepNow(context, ref);
        },
      ),
      const SizedBox(height: 16),
      PrimaryButton(label: 'Pas maintenant', style: GameButtonStyle.ghost, onPressed: () => Navigator.of(sheetContext).pop()),
    ]),
  );
}

/// Erreur d'une action du studio : l'énergie insuffisante ouvre « Trop fatigué » (avec Dormir), les autres un message clair.
void showGameError(BuildContext context, WidgetRef ref, Object error) {
  if (error is GameError && error.code == 'energie') {
    showTiredSheet(context, ref, ref.read(gameProvider).requireValue.energy);
  } else {
    showError(context, error);
  }
}
