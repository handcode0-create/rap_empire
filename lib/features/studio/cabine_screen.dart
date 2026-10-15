import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/minigame.dart';
import '../../domain/studio.dart';
import '../shell/toast.dart';

/// Session cabine (04.7). « Entrer en cabine » ouvre le mini-jeu des prises (04.8).
/// Valeurs de la planche sans formule dans game.js : « Micro de base · qualité 40 » et « Micro studio · qualité 48 » (le bonus +8 sur la voix, lui, est dans record()).
class CabineScreen extends ConsumerWidget {
  const CabineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Session cabine', step: 'Étape 3 / 3', onBack: () => context.go('/studio/ecriture')),
      const SizedBox(height: 12),
      const SceneBanner(
        kind: 'studio',
        height: 170,
        role: 'Cabine · Studio Kôrô',
        chars: [
          BannerChar('djo', mood: 'serious', gesture: 'mic', crop: 'torso', width: 100, left: 20),
          BannerChar('kore', mood: 'cool', crop: 'torso', width: 90, left: 280),
        ],
      ),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MATÉRIEL ACTIF', style: V20Text.lab()),
          Text(s.micro ? 'Micro studio · qualité 48' : 'Micro de base · qualité 40', style: V20Text.nm()),
          Text('Un meilleur micro ajoute jusqu’à +$microVoiceBonus à ta voix.', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GameTag('$recordHours h · −$recordEnergy énergie'),
        GameTag('$takesPerSession prises', style: GameTagStyle.outline),
      ]),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Entrer en cabine', onPressed: () => context.go('/studio/prises')),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Acheter du matériel', style: GameButtonStyle.ghost, onPressed: () => showInfo(context, 'Matériel : bientôt')),
    ]);
  }
}
