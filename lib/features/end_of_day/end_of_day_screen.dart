import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/rules.dart';
import '../shell/buttons.dart';
import '../shell/hud.dart';

/// Fin de journée (03.6) : bilan simple après avoir dormi. Sans bilan en mémoire (rechargement), retour au QG.
class EndOfDayScreen extends ConsumerWidget {
  const EndOfDayScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(lastSleepProvider);
    if (report == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const Hud(),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Nuit passée', style: TextStyle(color: Tk.ink2)),
              Text('Nouvelle journée', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 16),
              _Row(label: 'Jour', value: report.newClock, color: Tk.ink),
              const SizedBox(height: 8),
              _Row(label: 'Énergie', value: '${report.energyAfter}  (+${report.energyGained} repos)', color: Tk.cy),
              const SizedBox(height: 8),
              _Row(label: 'Nuit', value: report.cost == 0 ? 'Gratuite · démo' : '${fmt(report.cost)} cauris', color: Tk.gold),
              const SizedBox(height: 16),
              const Text(
                "Dans la version jouable, la nuit pourra coûter des cauris (1 500 dans l'écran d'origine). Le paramètre reste provisoire tant que l'économie (D-08) n'est pas calibrée.",
                style: TextStyle(color: Tk.ink2, fontSize: 12),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Commencer le jour', onPressed: () => context.go('/')),
              const SizedBox(height: 8),
              GhostButton(label: 'Retour au QG', onPressed: () => context.go('/')),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Row({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(Tk.rCard), border: Border.all(color: Tk.line)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Tk.ink2)),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: color, fontWeight: FontWeight.w800))),
        ]),
      );
}
