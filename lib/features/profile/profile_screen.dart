import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_tile.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../../domain/training.dart';

/// Profil (03.4) : progression, réputation, compétences, accès aux finances et tenue actuellement équipée.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await showGameSheet<bool>(
      context,
      builder: (sheetContext) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('CONFIRMATION', style: V20Text.lab()),
        const SizedBox(height: 16),
        Text('RECOMMENCER LA DÉMO ?', style: V20Text.dm(size: 26)),
        const SizedBox(height: 16),
        Text('Toute la progression sera effacée.', style: V20Text.bs()),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Recommencer', onPressed: () => Navigator.of(sheetContext).pop(true)),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Annuler', style: GameButtonStyle.ghost, onPressed: () => Navigator.of(sheetContext).pop(false)),
      ]),
    );
    if (ok != true) return;
    await ref.read(gameProvider.notifier).resetGame();
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      SceneBanner(
        kind: 'studio',
        height: 150,
        nameSize: 32,
        role: 'N${s.level} · ${s.levelName}',
        name: 'Djo Kéné',
        subtitle: '${s.hood} · ${styleNames[s.style] ?? ''}',
        subtitle: '${s.hood} · ${styleNames[s.style] ?? ''} · ${s.equippedOutfit}',
        chars: [
          BannerChar(
            'Djo Kéné',
            width: 120,
            left: 250,
            asset: 'assets/characters/rapper_001/${s.avatarStage}/v21b_${s.equippedOutfit}.svg',
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text.rich(TextSpan(style: V20Text.bs(), children: [const TextSpan(text: 'Prochain niveau : '), TextSpan(text: nextLevelName(s.xp), style: const TextStyle(fontWeight: FontWeight.w700))]))),
        const SizedBox(width: 8),
        Text.rich(TextSpan(style: V20Text.bs(), children: [TextSpan(text: fmt(xpToNextLevel(s.xp)), style: const TextStyle(fontWeight: FontWeight.w700)), const TextSpan(text: ' XP restants')])),
      ]),
      const SizedBox(height: 8),
      MeterBar(value: xpPercent(s.xp) / 100),
      const SizedBox(height: 8),
      KpiRow(children: [StatKpi(label: 'Fans', value: fmt(s.fans)), StatKpi(label: 'Popularité', value: fmt(s.pop)), StatKpi(label: 'Réputation', value: fmt(s.rep))]),
      const SizedBox(height: 8),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: ActionTile(icon: 'user', title: 'Mes tenues', subtitle: 'Éditeur et garde-robe', onTap: () => context.go('/profil/tenues'))),
          const SizedBox(width: 10),
          Expanded(child: ActionTile(icon: 'trend', title: 'Mes finances', subtitle: 'Cauris, revenus', onTap: () => context.go('/business/finances'))),
        ]),
      ),
      const SizedBox(height: 8),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final k in const ['flow', 'ecr', 'voix', 'cha']) ...[
            if (k != 'flow') const SizedBox(width: 8),
            Expanded(child: _Skill(label: skillNames[k]!, value: s.sk[k] ?? 0)),
          ],
        ]),
      ),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Recommencer la démo', style: GameButtonStyle.ghost, compact: true, onPressed: () => _reset(context, ref)),
    ]);
  }
}

class _Skill extends StatelessWidget {
  final String label;
  final int value;
  const _Skill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(gradient: V20.surface, borderRadius: BorderRadius.circular(Tk.rCard), border: Border.all(color: V20.cardBorder, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
          const SizedBox(height: 4),
          Text('$value', style: V20Text.nm()),
          const SizedBox(height: 4),
          MeterBar(value: value / 100),
        ]),
      );
}
