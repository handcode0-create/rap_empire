import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/action_tile.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/mission_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/clock.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/missions.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/tired_sheet.dart';
import '../shell/toast.dart';

/// QG (03.1) : bannière, objectif en cours, KPI, tuiles d'accès. Le HUD et la navigation sont dans la coque.
/// Énergie basse (03.2) : bandeau et feuille « Trop fatigué » avec l'action Dormir.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _sheetShown = false;

  Future<void> _claim(String id) async {
    final r = missionRewards[id]!;
    try {
      await ref.read(gameProvider.notifier).claimMission(id);
      if (mounted) showSuccess(context, 'Mission accomplie · +${fmt(r.cash)} cauris · +${r.xp} XP');
    } on Object catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Widget _objective(GameState s, Mission m) {
    final r = missionRewards[m.id]!;
    final done = s.ms[m.id] == 'done';
    final readyToRelease = m.id == 'm2' && studioStep(s) == StudioStep.sortie;
    return MissionCard(
      tag: 'Mission ${m.id.substring(1)}',
      statusTag: done ? 'Terminée' : null,
      title: m.title,
      hint: done ? null : m.hint,
      progress: done ? 1 : 0,
      rewards: done ? [RewardChip(value: '+${fmt(r.cash)}', label: 'cauris'), RewardChip(value: '+${r.xp}', label: 'XP', color: Tk.ok)] : const [],
      actionLabel: done ? 'Récupérer' : (readyToRelease ? 'Préparer la sortie' : 'Aller au studio'),
      onAction: done ? (m.id == 'm2' ? () => context.go('/mission-accomplie') : () => _claim(m.id)) : () => context.go(readyToRelease ? '/studio/sortie' : '/studio'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final tired = isTooTired(s);
    if (tired && !_sheetShown) {
      _sheetShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showTiredSheet(context, ref, s.energy);
      });
    } else if (!tired) {
      _sheetShown = false;
    }
    final objective = currentObjective(s);
    final msOpen = s.ms.values.where((v) => v == 'todo').length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const SceneBanner(kind: 'qg_sky', height: 72, name: 'Salut, Djo', chars: [BannerChar('djo', mood: 'smile', crop: 'torso', width: 64, left: 306)]),
      if (s.pend != null) ...[
        const SizedBox(height: 8),
        GameHint(icon: 'star', text: 'Niveau supérieur à récupérer', onTap: () => context.go('/niveau')),
      ],
      if (tired) ...[
        const SizedBox(height: 8),
        GameHint(icon: 'zap', warn: true, text: 'Énergie basse (${s.energy}) : dors avant d’enchaîner.', onTap: () => showTiredSheet(context, ref, s.energy)),
      ],
      if (objective != null) ...[const SizedBox(height: 8), _objective(s, objective)],
      const SizedBox(height: 8),
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: StatKpi(label: 'Fans', value: fmt(s.fans))),
        const SizedBox(width: 8),
        Expanded(child: StatKpi(label: 'Popularité', value: fmt(s.pop))),
        const SizedBox(width: 8),
        Expanded(child: StatKpi(label: 'Réputation', value: fmt(s.rep))),
      ])),
      const SizedBox(height: 8),
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: ActionTile(icon: 'mic', title: 'Studio', subtitle: 'Créer un son', onTap: () => context.go('/studio'))),
        const SizedBox(width: 10),
        Expanded(child: ActionTile(icon: 'flame', title: 'Scène', subtitle: 'Open mic, battle', onTap: () => context.go('/scene'))),
      ])),
      const SizedBox(height: 10),
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: ActionTile(icon: 'trophy', title: 'Missions', subtitle: 'Objectifs et primes', badge: '$msOpen', onTap: () => context.go('/missions'))),
        const SizedBox(width: 10),
        Expanded(child: ActionTile(icon: 'trend', title: 'Classements', subtitle: 'Rang : Non classé', onTap: () => showInfo(context, 'Classements : bientôt'))),
      ])),
      const SizedBox(height: 12),
      // Passer la journée sans faire de musique : la règle est A.sleep (jour suivant 08:00, énergie 100). Pas de planche pour ce bouton.
      PrimaryButton(label: 'Passer la journée', sublabel: nightLabel, style: GameButtonStyle.secondary, onPressed: () => sleepNow(context, ref)),
    ]);
  }
}
