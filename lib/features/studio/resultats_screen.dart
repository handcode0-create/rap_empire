import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/rules.dart';
import '../shell/buttons.dart';
import 'studio_widgets.dart';

/// Résultats · 24 h (05.4) : écoutes, gain, fans, popularité et cash, lus dans la dernière sortie (rel).
/// Le bloc « Top 100 Singles » de la planche est hors périmètre (classements).
class ResultatsScreen extends ConsumerWidget {
  const ResultatsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final r = s.rel;
    if (r == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const StepHeader(title: 'Résultats · 24 h'),
        const SizedBox(height: 24),
        const Center(child: Text('Aucune sortie pour l’instant.', style: TextStyle(color: Tk.ink2))),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ]);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      const StepHeader(title: 'Résultats · 24 h'),
      const SizedBox(height: 8),
      TkCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text('Écoutes · Estimé', style: TextStyle(color: Tk.ink2, fontSize: 12)),
          Text(fmt(r.listens), style: const TextStyle(color: Tk.cy, fontWeight: FontWeight.w800, fontSize: 40)),
          const SizedBox(height: 8),
          KeyValueRow(label: 'Gain', value: '+ ${fmt(r.revenue)} cauris', color: Tk.gold),
          KeyValueRow(label: 'Fans', value: '+ ${fmt(r.fans)}'),
          KeyValueRow(label: 'Popularité', value: '+ ${fmt(r.pop)}'),
          KeyValueRow(label: 'Cash', value: fmt(s.cash), color: Tk.gold),
        ]),
      ),
      const SizedBox(height: 12),
      const Text('Premier single : pas encore classé. Il faudra plus d’écoutes, de fans et de promo.', style: TextStyle(color: Tk.ink2, fontSize: 12)),
      const SizedBox(height: 24),
      PrimaryButton(label: 'Retour au QG', onPressed: () => context.go('/')),
      const SizedBox(height: 8),
      GhostButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
    ]);
  }
}
