import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/clock.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/rules.dart';
import 'buttons.dart';
import 'toast.dart';

/// Dormir puis afficher la fin de journée (03.6).
Future<void> sleepNow(BuildContext context, WidgetRef ref) async {
  await ref.read(gameProvider.notifier).sleep();
  if (context.mounted) context.go('/fin-journee');
}

String get _nightLabel => Econ.nightCost == 0 ? 'Nuit gratuite · démo' : 'Nuit : ${fmt(Econ.nightCost)} cauris';

/// Feuille « Trop fatigué » (03.2) avec l'action Dormir.
void showTiredSheet(BuildContext context, WidgetRef ref, int energy) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Tk.s1,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tk.rSheet))),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Énergie insuffisante', style: TextStyle(color: Tk.ink2)),
          Text('$energy', style: const TextStyle(color: Tk.cy, fontWeight: FontWeight.w800, fontSize: 32)),
          const SizedBox(height: 8),
          Text('Trop fatigué', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Dors une nuit pour retrouver $maxEnergy énergie. Dans cette démo, la nuit est gratuite : paramètre provisoire (D-08).',
            style: TextStyle(color: Tk.ink2),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Dormir',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              sleepNow(context, ref);
            },
          ),
          const SizedBox(height: 8),
          Center(child: Text(_nightLabel, style: const TextStyle(color: Tk.ink2, fontSize: 12))),
          const SizedBox(height: 8),
          GhostButton(label: 'Pas maintenant', onPressed: () => Navigator.of(sheetContext).pop()),
        ]),
      ),
    ),
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
