import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/studio.dart';
import '../shell/buttons.dart';
import '../shell/tired_sheet.dart';
import '../shell/toast.dart';
import 'studio_widgets.dart';

/// Session cabine (04.7). Mini-jeu des prises (04.8) : mode simulé du prototype (« Simuler les 3 prises »), le timing n'est pas porté.
class CabineScreen extends ConsumerWidget {
  const CabineScreen({super.key});

  Future<void> _simulate(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(gameProvider.notifier).recordSession();
      if (context.mounted) context.go('/studio/mix');
    } on Object catch (e) {
      if (context.mounted) showGameError(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      const StepHeader(title: 'Session cabine', step: 'Étape 3 / 3', backTo: '/studio/ecriture'),
      const SizedBox(height: 8),
      TkCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cabine · Studio Kôrô', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text('Matériel actif', style: TextStyle(color: Tk.ink2, fontSize: 12)),
          Text(s.micro ? 'Micro studio : +$microVoiceBonus à ta voix' : 'Micro de base', style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
          const SizedBox(height: 4),
          const Text('Un meilleur micro ajoute jusqu’à +$microVoiceBonus à ta voix.', style: TextStyle(color: Tk.ink2, fontSize: 12)),
          const SizedBox(height: 12),
          const Text('$recordHours h · −$recordEnergy énergie · 3 prises', style: TextStyle(color: Tk.cy)),
        ]),
      ),
      const SizedBox(height: 16),
      const Text('Le mini-jeu de timing arrive plus tard : les 3 prises sont simulées avec la note de démo.', style: TextStyle(color: Tk.ink2, fontSize: 12)),
      const SizedBox(height: 16),
      PrimaryButton(label: 'Simuler les 3 prises', onPressed: () => _simulate(context, ref)),
      const SizedBox(height: 8),
      GhostButton(label: 'Acheter du matériel', onPressed: () => showInfo(context, 'Matériel : bientôt')),
    ]);
  }
}
