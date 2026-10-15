import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/rules.dart';
import '../shell/game_frame.dart';

/// Fin de journée (03.6) : bilan après avoir dormi. Sans bilan en mémoire (rechargement), retour au QG.
class EndOfDayScreen extends ConsumerWidget {
  const EndOfDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(lastSleepProvider);
    if (report == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const GameFrame(children: []);
    }
    return GameFrame(children: [
      const SceneBanner(
        kind: 'studio',
        height: 200,
        nameSize: 32,
        role: 'Nuit passée',
        name: 'Nouvelle journée',
        chars: [BannerChar('djo', mood: 'smile', crop: 'torso', width: 110, left: 250)],
      ),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Énergie', value: '${report.energyAfter}', delta: '+ repos', big: true),
        StatKpi(label: 'Nuit', value: report.cost == 0 ? 'Gratuite' : fmt(report.cost), delta: 'démo'),
      ]),
      const SizedBox(height: 12),
      const GameHint(
        icon: 'info',
        warn: true,
        text: 'Dans la version jouable, la nuit pourra coûter des cauris (1 500 dans l’écran d’origine). Le paramètre reste provisoire tant que l’économie (D-08) n’est pas calibrée.',
      ),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Commencer le jour', sublabel: 'Retour au QG', onPressed: () => context.go('/')),
    ]);
  }
}
