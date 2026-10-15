import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';

/// Résultats · 24 h (05.4) : écoutes, gain, fans, popularité et cash lus dans la dernière sortie (rel).
/// Valeur de la planche sans formule dans game.js : le rang « Non classé » (il faudrait les classements, hors périmètre) ;
/// le seuil d'entrée et la jauge (gapPct) viennent de game.js.
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
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('RÉSULTATS · 24 H', style: V20Text.lab()),
            Text(r.title.toUpperCase(), style: V20Text.dm(size: 26)),
          ]),
        ),
        const SizedBox(width: 8),
        const GameCover(size: 56),
      ]),
      const SizedBox(height: 8),
      KpiRow(children: [
        StatKpi(label: 'Écoutes', value: fmt(r.listens), delta: 'Estimé', big: true),
        StatKpi(label: 'Gain', value: '+${fmt(r.revenue)}', delta: 'cauris'),
      ]),
      const SizedBox(height: 8),
      KpiRow(children: [
        StatKpi(label: 'Fans', value: '+${fmt(r.fans)}'),
        StatKpi(label: 'Popularité', value: '+${fmt(r.pop)}'),
        StatKpi(label: 'Cash', value: fmt(s.cash)),
      ]),
      const SizedBox(height: 8),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text('TOP 100 SINGLES', style: V20Text.lab(color: Tk.ink))),
            const GameTag('Non classé', style: GameTagStyle.outline, color: Tk.ink),
          ]),
          const SizedBox(height: 4),
          Text('Seuil d’entrée : ≈ ${fmt(Econ.entryListens)} écoutes / 7 j (hypothèse de démo).', style: V20Text.bs()),
          const SizedBox(height: 4),
          MeterBar(value: gapPercent(s.lw) / 100),
        ]),
      ),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Premier single : pas encore classé. Il faudra plus d’écoutes, de fans et de promo.'),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Retour au QG', onPressed: () => context.go(s.pend != null ? '/niveau' : '/')),
    ]);
  }
}
