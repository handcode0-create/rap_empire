import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../shell/game_frame.dart';

/// Nouvelle mission (10.3) : « Fais-toi voir à l'open mic ». « Y aller » ouvre la scène.
/// Cachet et XP : ECON.openMicFee et A.openmic de game.js.
class NewMissionScreen extends StatelessWidget {
  const NewMissionScreen({super.key});

  @override
  Widget build(BuildContext context) => GameFrame(children: [
        const SceneBanner(
          kind: 'street',
          height: 150,
          nameSize: 26,
          nameSingleLine: true,
          role: 'Nouvelle mission',
          name: "Fais-toi voir à l'open mic",
          chars: [BannerChar('djo', mood: 'smile', crop: 'torso', width: 90, left: 280)],
        ),
        const SizedBox(height: 12),
        Text('Monte sur la scène de Ndolo : les fans et la réputation suivent.', style: V20Text.bm),
        const SizedBox(height: 12),
        Row(children: [
          RewardChip(value: '+${fmt(Econ.openMicFee)} cauris', color: Tk.ok),
          const SizedBox(width: 8),
          const RewardChip(value: '+${Econ.xpOpenMic} XP', color: Tk.ink),
        ]),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Y aller', onPressed: () => context.go('/scene/openmic')),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Plus tard', style: GameButtonStyle.ghost, onPressed: () => context.go('/')),
      ]);
}
