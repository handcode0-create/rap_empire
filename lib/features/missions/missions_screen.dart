import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/econ.dart';
import '../../domain/missions.dart';
import '../../domain/rules.dart';
import '../shell/toast.dart';

/// Missions (10.1) : les quatre missions du prototype, leur état et leur récompense. « Récupérer » verse la récompense ;
/// si un niveau est gagné, l'écran 10.4 s'ouvre. La mission 3 mène à la formation ; la mission 4 affiche son avancement (m4pct de game.js).
class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  Future<void> _claim(BuildContext context, WidgetRef ref, String id) async {
    final r = missionRewards[id]!;
    try {
      await ref.read(gameProvider.notifier).claimMission(id);
      if (!context.mounted) return;
      showSuccess(context, 'Mission accomplie · +${fmt(r.cash)} cauris · +${r.xp} XP');
      if (ref.read(gameProvider).requireValue.pend != null) context.go('/niveau');
    } on Object catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('MISSIONS', style: V20Text.baloo(size: 28, line: 28)),
      for (final id in missionTitles.keys) ...[
        const SizedBox(height: 8),
        _MissionCard(
          id: id,
          status: s.ms[id] ?? 'todo',
          fans: s.fans,
          onClaim: () => _claim(context, ref, id),
          onGo: () => context.go('/business/formation'),
        ),
      ],
    ]);
  }
}

class _MissionCard extends StatelessWidget {
  final String id, status;
  final int fans;
  final VoidCallback onClaim, onGo;
  const _MissionCard({required this.id, required this.status, required this.fans, required this.onClaim, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final r = missionRewards[id]!;
    final pct = fansMissionPercent(fans);
    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(missionTitles[id]!, style: V20Text.nm())),
          if (status == 'claimed') const GameTag('Terminée', style: GameTagStyle.ok) else if (status == 'done') const GameTag('À récupérer', style: GameTagStyle.accent),
        ]),
        const SizedBox(height: 4),
        Text('+${fmt(r.cash)} cauris · +${r.xp} XP', style: V20Text.bs()),
        if (id == 'm4' && status == 'todo') ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: MeterBar(value: pct / 100, tone: MeterTone.ok)),
            const SizedBox(width: 8),
            Text('$pct %', style: V20Text.poppins(size: 13, line: 18, weight: FontWeight.w700, color: V20.ink2)),
          ]),
        ],
        if (status == 'done') ...[
          const SizedBox(height: 8),
          PrimaryButton(label: 'Récupérer', compact: true, onPressed: onClaim),
        ] else if (id == 'm3' && status == 'todo') ...[
          const SizedBox(height: 8),
          PrimaryButton(label: 'Y aller', style: GameButtonStyle.secondary, compact: true, onPressed: onGo),
        ],
      ]),
    );
  }
}
