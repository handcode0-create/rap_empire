import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/character_view.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_tile.dart';
import '../../core/widgets/hero_stat.dart';
import '../../core/widgets/locked_tile.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../domain/clock.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/missions.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/tired_sheet.dart';
import '../shell/toast.dart';

/// QG (03.1, proposition 17.5) · Direction Néon de Bakoma. Intention : le joueur choisit CE QU'IL FAIT AUJOURD'HUI ; il doit se sentir attendu, pas submergé.
/// Hiérarchie : 1 carte héroïque « objectif en cours » (Djo en buste qui déborde, seul bouton principal) ; 2 trois chiffres d'appui ;
/// 3 quatre tuiles (Studio et Missions ouvertes, Scène et Classements verrouillées avec leur condition) ; puis « Passer la journée ».
/// Le HUD, le décor du toit de Ndolo et la navigation viennent de la coque. Énergie basse (03.2) : bandeau et feuille « Trop fatigué ».
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

  /// Carte héroïque : l'objectif en cours. Djo (assets/characters) déborde au-dessus de la carte ; expression selon la situation.
  Widget _hero(GameState s, Mission m, {required bool tired}) {
    final r = missionRewards[m.id]!;
    final done = s.ms[m.id] == 'done';
    final readyToRelease = m.id == 'm2' && studioStep(s) == StudioStep.sortie;
    final mood = tired ? 'worried' : (done ? 'laugh' : 'smile');
    final label = done ? 'Récupérer' : (readyToRelease ? 'Préparer la sortie' : 'Aller au studio');
    final VoidCallback onAction = done ? (m.id == 'm2' ? () => context.go('/mission-accomplie') : () => _claim(m.id)) : () => context.go(readyToRelease ? '/studio/sortie' : '/studio');
    return Stack(clipBehavior: Clip.none, children: [
      GlassCard(
        accent: GlassAccent.magenta,
        halo: false, // le halo fort de l'écran est celui du bouton principal
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.only(right: 92),
              child: Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text('OBJECTIF EN COURS', style: V20Text.lab(color: V20.accText)),
                if (done) const GameTag('Terminée', style: GameTagStyle.ok),
                GameTag('Mission ${m.id.substring(1)}', style: GameTagStyle.outline, color: Tk.ink),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          Text(m.title.toUpperCase(), style: V20Text.baloo(size: 22, line: 24)),
          if (!done) ...[const SizedBox(height: 6), Text(m.hint, style: V20Text.bs())],
          if (done) ...[
            const SizedBox(height: 8),
            const MeterBar(value: 1, tone: MeterTone.ok),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: [RewardChip(value: '+${fmt(r.cash)}', label: 'cauris'), RewardChip(value: '+${r.xp}', label: 'XP', color: Tk.ok)]),
          ],
          const SizedBox(height: 10),
          PrimaryGlowButton(label: label, onPressed: onAction),
        ]),
      ),
      Positioned(top: -46, right: 4, child: IgnorePointer(child: CharacterView(who: 'djo', mood: mood, crop: 'torso', width: 82, height: 82 * 340 / 260))),
    ]);
  }

  /// Chiffres d'appui : fans, popularité, réputation (compteurs animés).
  Widget _stats(GameState s) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: HeroStat(label: 'Fans', value: s.fans, size: 26)),
            const VerticalDivider(width: 17, thickness: 1, color: Color.fromRGBO(255, 255, 255, .10)),
            Expanded(child: HeroStat(label: 'Popularité', value: s.pop, size: 26)),
            const VerticalDivider(width: 17, thickness: 1, color: Color.fromRGBO(255, 255, 255, .10)),
            Expanded(child: HeroStat(label: 'Réputation', value: s.rep, size: 26)),
          ]),
        ),
      );

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
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
      Text('SALUT, DJO', style: V20Text.dm(size: 26).copyWith(shadows: const [Shadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 14, offset: Offset(0, 2))])),
      if (s.pend != null) ...[
        const SizedBox(height: 8),
        GameHint(icon: 'star', text: 'Niveau supérieur à récupérer', onTap: () => context.go('/niveau')),
      ],
      if (tired) ...[
        const SizedBox(height: 8),
        GameHint(icon: 'zap', warn: true, text: 'Énergie basse (${s.energy}) : dors avant d’enchaîner.', onTap: () => showTiredSheet(context, ref, s.energy)),
      ],
      if (objective != null) ...[const SizedBox(height: 6), _hero(s, objective, tired: tired)],
      const SizedBox(height: 10),
      _stats(s),
      const SizedBox(height: 10),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: GlassTile(icon: 'mic', title: 'Studio', subtitle: 'Créer un son', cost: '−${writeEnergy + recordEnergy} énergie · ${writeHours + recordHours} h', onTap: () => context.go('/studio'))),
          const SizedBox(width: 10),
          Expanded(child: GlassTile(icon: 'trophy', title: 'Missions', subtitle: 'Objectifs et primes', badge: '$msOpen', onTap: () => context.go('/missions'))),
        ]),
      ),
      const SizedBox(height: 10),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: LockedTile(title: 'Scène', subtitle: 'Open mic, battle', condition: 'Hors démo', onTap: () => context.go('/scene'))),
          const SizedBox(width: 10),
          Expanded(child: LockedTile(title: 'Classements', subtitle: 'Rang : Non classé', condition: 'Hors démo', onTap: () => showInfo(context, 'Classements : bientôt'))),
        ]),
      ),
      const SizedBox(height: 12),
      // Passer la journée sans faire de musique : la règle est A.sleep (jour suivant 08:00, énergie 100). Pas de planche pour ce bouton.
      PrimaryButton(label: 'Passer la journée', sublabel: nightLabel, style: GameButtonStyle.secondary, compact: true, onPressed: () => sleepNow(context, ref)),
    ]);
  }
}
