import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../shell/game_frame.dart';
import '../shell/toast.dart';

/// Mission accomplie (10.2) : « Premier single sorti », la mission 2. « Récupérer » verse la récompense puis propose la suite (10.3).
/// Les textes viennent de la planche (propres à cette mission) ; les montants, de Econ.missionRewards.
class MissionDoneScreen extends ConsumerStatefulWidget {
  const MissionDoneScreen({super.key});
  @override
  ConsumerState<MissionDoneScreen> createState() => _MissionDoneScreenState();
}

class _MissionDoneScreenState extends ConsumerState<MissionDoneScreen> {
  /// Vrai dès que « Récupérer » est touché : la mission récupérée ne doit pas déclencher le retour au QG prévu quand elle n'est pas à récupérer.
  bool _leaving = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s != null && s.ms['m2'] != 'done' && !_leaving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
    }
    final r = missionRewards['m2']!;
    return GameFrame(burst: true, children: [
      const SizedBox(height: 80),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text('MISSION ACCOMPLIE', style: V20Text.lab()),
        const SizedBox(height: 10),
        Text('PREMIER SINGLE SORTI', textAlign: TextAlign.center, style: V20Text.dm()),
        const SizedBox(height: 10),
        Text('Le quartier a entendu ta voix.', textAlign: TextAlign.center, style: V20Text.bm),
      ]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RewardChip(value: '+${fmt(r.cash)} cauris', color: Tk.ok),
        const SizedBox(width: 8),
        RewardChip(value: '+${r.xp} XP', color: Tk.ink),
      ]),
      const SizedBox(height: 12),
      PrimaryButton(
        label: 'Récupérer',
        onPressed: () async {
          _leaving = true;
          try {
            await ref.read(gameProvider.notifier).claimMission('m2');
            if (context.mounted) context.go('/nouvelle-mission');
          } on Object catch (e) {
            _leaving = false;
            if (context.mounted) showError(context, e);
          }
        },
      ),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Fermer', style: GameButtonStyle.ghost, onPressed: () => context.go('/')),
    ]);
  }
}
