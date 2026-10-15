import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/studio.dart';
import '../shell/toast.dart';
import 'studio_widgets.dart';

/// Studio (04.1 : studio vide). Les étapes suivantes enrichissent cet écran.
class StudioHomeScreen extends ConsumerWidget {
  const StudioHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Studio', style: Theme.of(context).textTheme.displayMedium),
      Text('Kôrô · ${s.hood}', style: const TextStyle(color: Tk.ink2)),
      const SizedBox(height: 16),
      TkCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aucun son enregistré', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text('Choisis une instru, écris ton texte, passe en cabine. Ton premier son ouvre la sortie, les fans et le classement.', style: TextStyle(color: Tk.ink2)),
          if (s.inst != null) ...[
            const SizedBox(height: 8),
            Text('Instru choisie : ${instruById(s.inst!).name}', style: const TextStyle(color: Tk.cy, fontWeight: FontWeight.w800)),
          ],
        ]),
      ),
      const SizedBox(height: 12),
      _Tile(icon: Icons.add_circle_rounded, title: 'Nouveau son', subtitle: '3 étapes : instru · texte · cabine', onTap: () => context.go('/studio/instru')),
      const SizedBox(height: 8),
      _Tile(icon: Icons.library_music_rounded, title: 'Instrus', subtitle: 'Gratuite ou à acheter', onTap: () => context.go('/studio/instru')),
      const SizedBox(height: 8),
      _Tile(icon: Icons.mic_rounded, title: 'Matériel', subtitle: 'Micro, casque', onTap: () => showInfo(context, 'Matériel : bientôt')),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => TkCard(
        onTap: onTap,
        child: Row(children: [
          Icon(icon, color: Tk.acc),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
              Text(subtitle, style: const TextStyle(color: Tk.ink2, fontSize: 12)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: Tk.ink2),
        ]),
      );
}
