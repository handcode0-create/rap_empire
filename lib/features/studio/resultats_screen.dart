import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/cascade.dart';
import '../../core/widgets/cost_row.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/gauge_arc.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/hero_stat.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/reward_burst.dart';
import '../../core/widgets/choice_card.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';

/// Résultats · 24 h (05.4) · Direction Néon de Bakoma. Intention : la FIERTÉ d'avoir sorti un son ; un chiffre héroïque, puis le détail.
/// Trois temps : le chiffre d'écoutes compte jusqu'à sa valeur, les détails arrivent en cascade (80 ms), puis le bouton de suite.
/// Écoutes, gain, fans, popularité et cash sont lus dans la dernière sortie (rel) ; le rang « Non classé » n'a pas de formule dans game.js ;
/// le seuil d'entrée et la jauge (gapPct) viennent de game.js. L'éclat de victoire ne s'affiche que pour la première sortie ou un niveau gagné.
class ResultatsScreen extends ConsumerWidget {
  const ResultatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final r = s.rel;
    if (r == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 24),
        Center(child: Text('Aucune sortie pour l’instant.', style: V20Text.bs())),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ]);
    }
    final victory = s.disco.length <= 1 || s.pend != null;
    final gap = gapPercent(s.lw);
    return Stack(children: [
      if (victory) const Positioned(top: 0, left: 0, right: 0, child: RewardBurst()),
      ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('RÉSULTATS · 24 H', style: V20Text.lab(color: Colors.white)),
              Text(r.title.toUpperCase(), style: V20Text.dm(size: 26).copyWith(shadows: const [Shadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 14, offset: Offset(0, 2))])),
            ]),
          ),
          const SizedBox(width: 8),
          const GameCover(size: 56),
        ]),
        const SizedBox(height: 16),
        Cascade(children: [
          GlassCard(
            child: HeroStat(label: 'Écoutes', value: r.listens, size: 56, caption: const Align(alignment: Alignment.centerLeft, child: ConsequenceTag(ConsequenceKind.estimated))),
          ),
          IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: HeroStat(
                  label: 'Gain',
                  value: r.revenue,
                  prefix: '+',
                  size: 32,
                  color: Tk.gold,
                  caption: Row(children: [const CauriIcon(size: 14), const SizedBox(width: 6), Text('cauris', style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w700, color: Tk.ok))]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: GlassCard(padding: const EdgeInsets.all(12), child: HeroStat(label: 'Fans', value: r.fans, prefix: '+', size: 32))),
          ])),
          IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: GlassCard(padding: const EdgeInsets.all(12), child: HeroStat(label: 'Popularité', value: r.pop, prefix: '+', size: 32))),
            const SizedBox(width: 8),
            Expanded(child: GlassCard(padding: const EdgeInsets.all(12), child: HeroStat(label: 'Cash', value: s.cash, size: 32, color: Tk.gold))),
          ])),
          GlassCard(
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              GaugeArc(value: gap / 100, label: 'Part du seuil d’entrée du Top 100 Singles', centerText: '${gap.toStringAsFixed(1).replaceAll('.', ',')} %', color: Tk.cy, size: 96),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(child: Text('TOP 100 SINGLES', style: V20Text.lab(color: Tk.ink))),
                    const SizedBox(width: 6),
                    const GameTag('Non classé', style: GameTagStyle.outline, color: Tk.ink),
                  ]),
                  const SizedBox(height: 6),
                  Text('Seuil d’entrée : ≈ ${fmt(Econ.entryListens)} écoutes / 7 j (hypothèse de démo).', style: V20Text.bs()),
                ]),
              ),
            ]),
          ),
          const GameHint(icon: 'info', text: 'Premier single : pas encore classé. Il faudra plus d’écoutes, de fans et de promo.'),
          PrimaryGlowButton(label: 'Retour au QG', onPressed: () => context.go(s.pend != null ? '/niveau' : '/')),
        ]),
      ]),
    ]);
  }
}
