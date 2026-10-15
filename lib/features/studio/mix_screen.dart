import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../shell/toast.dart';

/// Mix terminé (04.9) : pochette, titre, qualité sur 100, détail texte, voix, production ; pas de navigation, une sortie unique.
/// La mission 1 se récupère ici (« Récupérer la mission ») tant qu'elle est terminée sans être récupérée.
class MixScreen extends ConsumerWidget {
  const MixScreen({super.key});

  Future<void> _claim(BuildContext context, WidgetRef ref) async {
    final r = missionRewards['m1']!;
    try {
      await ref.read(gameProvider.notifier).claimMission('m1');
      if (context.mounted) {
        showSuccess(context, 'Mission accomplie · +${fmt(r.cash)} cauris · +${r.xp} XP');
        context.go('/');
      }
    } on Object catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final song = s.song;
    if (song == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 24),
        Center(child: Text('Aucun son enregistré.', style: V20Text.bs())),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ]);
    }
    final m1 = missionRewards['m1']!;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Column(mainAxisSize: MainAxisSize.min, children: [
        const GameCover(size: 110),
        const SizedBox(height: 8),
        Text('MIX TERMINÉ', style: V20Text.lab()),
        const SizedBox(height: 8),
        Text(song.title.toUpperCase(), textAlign: TextAlign.center, style: V20Text.baloo(size: 28, line: 28)),
        const SizedBox(height: 8),
        Text.rich(TextSpan(children: [
          TextSpan(text: fmt(song.q), style: V20Text.baloo(size: 56, line: 56)),
          TextSpan(text: ' / 100', style: V20Text.bs()),
        ])),
      ]),
      const SizedBox(height: 12),
      KpiRow(children: [StatKpi(label: 'Texte', value: fmt(song.texte)), StatKpi(label: 'Voix', value: fmt(song.voix)), StatKpi(label: 'Production', value: fmt(song.prod))]),
      const SizedBox(height: 12),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        RewardChip(value: '+${Econ.xpRecord} XP', color: Tk.ok),
        GameTag('Son ajouté au studio'),
      ]),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Préparer la sortie', onPressed: () => context.go('/studio/sortie')),
      if (s.ms['m1'] == 'done') ...[
        const SizedBox(height: 12),
        PrimaryButton(label: 'Récupérer la mission', sublabel: '+${fmt(m1.cash)} cauris · +${m1.xp} XP', style: GameButtonStyle.secondary, onPressed: () => _claim(context, ref)),
      ],
    ]);
  }
}
