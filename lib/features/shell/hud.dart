import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/widgets/hud_bar.dart';
import '../../core/widgets/xp_progress.dart';
import '../../domain/clock.dart';
import '../../domain/rules.dart';
import 'toast.dart';

/// HUD relié à l'état de partie : niveau, XP, cauris, énergie, jour et heure (HudBar est un widget d'affichage pur).
class Hud extends ConsumerWidget {
  const Hud({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const SizedBox(height: 120);
    return HudBar(
      name: 'Djo Kéné',
      levelLabel: 'N${s.level} · ${s.levelName}',
      xp: xpFraction(s.xp),
      cash: fmt(s.cash),
      energy: '${s.energy}',
      time: formatClock(s),
      onBell: () => showInfo(context, 'Journal : bientôt'),
    );
  }
}
