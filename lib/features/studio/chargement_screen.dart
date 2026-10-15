import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';

/// Mise en ligne (05.3) : écran de chargement SIMULÉ (la planche l'indique : « Chargement simulé »). La sortie est déjà enregistrée ;
/// la jauge avance en 1,8 s puis ouvre les résultats, comme data-auto="1800|05-4-Resultats" dans la planche. « Voir les résultats » passe tout de suite.
class ChargementScreen extends ConsumerStatefulWidget {
  const ChargementScreen({super.key});
  @override
  ConsumerState<ChargementScreen> createState() => _ChargementScreenState();
}

class _ChargementScreenState extends ConsumerState<ChargementScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) context.go('/studio/resultats');
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    final title = s?.rel?.title ?? s?.song?.title ?? '';
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Center(child: GameTag('Chargement simulé', style: GameTagStyle.outline)),
      const SizedBox(height: 56),
      Column(mainAxisSize: MainAxisSize.min, children: [
        const GameCover(size: 150),
        const SizedBox(height: 14),
        Text('MISE EN LIGNE', style: V20Text.dm(size: 26)),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: title, style: V20Text.bs().copyWith(fontWeight: FontWeight.w700)),
            const TextSpan(text: ' arrive sur les plateformes.'),
          ]),
          textAlign: TextAlign.center,
          style: V20Text.bs(),
        ),
      ]),
      const SizedBox(height: 12),
      AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Column(children: [
          MeterBar(value: _c.value, tone: MeterTone.cyan, animate: false),
          const SizedBox(height: 12),
          Text('${(_c.value * 100).round()} %', textAlign: TextAlign.center, style: V20Text.baloo(size: 44, line: 44)),
        ]),
      ),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Voir les résultats', onPressed: () => context.go('/studio/resultats')),
    ]);
  }
}
