import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/econ.dart';
import '../shell/buttons.dart';
import 'studio_widgets.dart';

/// Mix terminé (04.9) : qualité du son et détail texte, voix, production.
class MixScreen extends ConsumerWidget {
  const MixScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final song = s.song;
    if (song == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const StepHeader(title: 'Mix'),
        const SizedBox(height: 24),
        const Center(child: Text('Aucun son enregistré.', style: TextStyle(color: Tk.ink2))),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ]);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      const StepHeader(title: 'Mix terminé'),
      const SizedBox(height: 8),
      TkCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(song.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${song.q}', style: const TextStyle(color: Tk.ink, fontWeight: FontWeight.w800, fontSize: 48)),
            const SizedBox(width: 8),
            const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('/ 100', style: TextStyle(color: Tk.ink2))),
          ]),
          const SizedBox(height: 8),
          KeyValueRow(label: 'Texte', value: '${song.texte}'),
          KeyValueRow(label: 'Voix', value: '${song.voix}'),
          KeyValueRow(label: 'Production', value: '${song.prod}'),
          const SizedBox(height: 8),
          const Text('+${Econ.xpRecord} XP · Son ajouté au studio', style: TextStyle(color: Tk.ok, fontWeight: FontWeight.w800)),
        ]),
      ),
      const SizedBox(height: 24),
      PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
    ]);
  }
}
