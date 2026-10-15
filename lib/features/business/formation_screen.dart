import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_toast.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/rules.dart';
import '../../domain/training.dart';
import '../shell/toast.dart';

/// Formation (09.3) et toast de compétence (09.4). Cash ou énergie insuffisant : la ligne est indisponible et affiche le motif
/// (le cash d'abord, comme A.formation). Les règles sont dans lib/domain/training.dart.
class FormationScreen extends ConsumerWidget {
  const FormationScreen({super.key});

  static String _info(Formation f) =>
      '${f.hours} h · ${f.cost == 0 ? 'gratuit' : '${fmt(f.cost)} cauris'} · −${f.energy} énergie · ${skillNames[f.skill]} +${f.gain}';

  Future<void> _train(BuildContext context, WidgetRef ref, Formation f) async {
    try {
      await ref.read(gameProvider.notifier).train(f.id);
      if (context.mounted) showGameToast(context, trainingToast(f), kind: ToastKind.success);
    } on GameError catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Formation', onBack: () => context.go('/business')),
      for (final f in formations) ...[
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final blocker = trainBlocker(s, f.id);
          return ActionRow(
            title: f.name,
            subtitle: _info(f),
            note: blocker == null ? null : GameError(blocker).message,
            disabled: blocker != null,
            trailing: ActionRow.arrow(disabled: blocker != null),
            onTap: () => _train(context, ref, f),
          );
        }),
      ],
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Chaque formation coûte du temps, de l’énergie et parfois des cauris : elle améliore une compétence.'),
    ]);
  }
}
