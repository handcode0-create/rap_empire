import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/rules.dart';

/// Écran témoin : lit l'état réel, affiche cash/énergie/niveau. Remplacé par le QG (03.1) à la phase suivante.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: g.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur : $e')),
            data: (s) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Djo Kéné', style: Theme.of(context).textTheme.displayMedium),
              Text('N${s.level} · ${s.levelName} · ${s.hood}', style: const TextStyle(color: Tk.ink2)),
              const SizedBox(height: 16),
              Text('${fmt(s.cash)} cauris', style: const TextStyle(color: Tk.gold, fontWeight: FontWeight.w800)),
              Text('Énergie ${s.energy}', style: const TextStyle(color: Tk.cy)),
            ]),
          ),
        ),
      ),
    );
  }
}
