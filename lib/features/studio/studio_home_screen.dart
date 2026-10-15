import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/game_state.dart';
import '../../domain/studio.dart';
import '../../domain/studio_models.dart';
import '../shell/toast.dart';
import 'studio_widgets.dart';

/// Studio : 04.1 (studio vide) ou 04.2 (un son enregistré), avec reprise de l'étape en cours.
class StudioHomeScreen extends ConsumerWidget {
  const StudioHomeScreen({super.key});

  /// Étape à reprendre déduite de l'état sauvegardé (restauration de l'écran au rechargement).
  static (String, String)? _resume(GameState s) => switch (studioStep(s)) {
        StudioStep.instru => null,
        StudioStep.ecriture => ('Écrire le texte', '/studio/ecriture'),
        StudioStep.cabine => ('Passer en cabine', '/studio/cabine'),
        StudioStep.sortie => ('Voir le mix', '/studio/mix'),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final resume = _resume(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Studio', style: Theme.of(context).textTheme.displayMedium),
      Text('Kôrô · ${s.hood}${s.song != null ? ' · 1 son' : ''}', style: const TextStyle(color: Tk.ink2)),
      const SizedBox(height: 16),
      if (s.song == null)
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
        )
      else
        _SongCard(song: s.song!, style: styleNames[s.style] ?? ''),
      const SizedBox(height: 12),
      if (resume != null) ...[
        _Tile(icon: Icons.play_circle_rounded, title: 'Reprendre : ${resume.$1}', subtitle: 'Là où tu t’es arrêté', onTap: () => context.go(resume.$2)),
        const SizedBox(height: 8),
      ],
      _Tile(icon: Icons.add_circle_rounded, title: 'Nouveau son', subtitle: '3 étapes : instru · texte · cabine', onTap: () => context.go('/studio/instru')),
      const SizedBox(height: 8),
      _Tile(icon: Icons.library_music_rounded, title: 'Instrus', subtitle: 'Gratuite ou à acheter', onTap: () => context.go('/studio/instru')),
      const SizedBox(height: 8),
      _Tile(icon: Icons.mic_rounded, title: 'Matériel', subtitle: 'Micro, casque', onTap: () => showInfo(context, 'Matériel : bientôt')),
    ]);
  }
}

class _SongCard extends StatelessWidget {
  final Song song;
  final String style;
  const _SongCard({required this.song, required this.style});
  @override
  Widget build(BuildContext context) => TkCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(gradient: Tk.grad, shape: BoxShape.circle),
              child: Text(song.title.characters.first, style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(song.title, style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
                Text('$style · instru ${song.inst}', style: const TextStyle(color: Tk.ink2, fontSize: 12)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _Stat('Qualité', '${song.q}'),
            _Stat('Texte', '${song.texte}'),
            _Stat('Voix', '${song.voix}'),
            _Stat('Prod.', '${song.prod}'),
          ]),
        ]),
      );
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Tk.ink2, fontSize: 11)),
          Text(value, style: const TextStyle(color: Tk.ink, fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
      );
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
