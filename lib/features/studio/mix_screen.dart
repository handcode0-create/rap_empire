import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/cascade.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/hero_stat.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/reward_chip.dart';
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
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
      Column(mainAxisSize: MainAxisSize.min, children: [
        const GameCover(size: 110),
        const SizedBox(height: 8),
        Text('MIX TERMINÉ', style: V20Text.lab(color: Colors.white)),
        const SizedBox(height: 8),
        Text(song.title.toUpperCase(), textAlign: TextAlign.center, style: V20Text.baloo(size: 28, line: 28).copyWith(shadows: const [Shadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 14, offset: Offset(0, 2))])),
      ]),
      const SizedBox(height: 16),
      Cascade(children: [
        GlassCard(
          accent: GlassAccent.gold,
          halo: false,
          child: Center(child: HeroStat(label: 'Qualité', value: song.q, suffix: ' / 100', size: 56, color: Tk.gold, align: CrossAxisAlignment.center)),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: HeroStat(label: 'Texte', value: song.texte, size: 26)),
              const VerticalDivider(width: 17, thickness: 1, color: Color.fromRGBO(255, 255, 255, .10)),
              Expanded(child: HeroStat(label: 'Voix', value: song.voix, size: 26)),
              const VerticalDivider(width: 17, thickness: 1, color: Color.fromRGBO(255, 255, 255, .10)),
              Expanded(child: HeroStat(label: 'Production', value: song.prod, size: 26)),
            ]),
          ),
        ),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          RewardChip(value: '+${Econ.xpRecord} XP', color: Tk.ok),
          GameTag('Son ajouté au studio'),
        ]),
        PrimaryGlowButton(label: 'Préparer la sortie', onPressed: () => context.go('/studio/sortie')),
        if (s.ms['m1'] == 'done') PrimaryButton(label: 'Récupérer la mission', sublabel: '+${fmt(m1.cash)} cauris · +${m1.xp} XP', style: GameButtonStyle.secondary, onPressed: () => _claim(context, ref)),
      ]),
    ]);
  }
}
