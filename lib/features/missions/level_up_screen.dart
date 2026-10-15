import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/celebration.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../shell/game_frame.dart';

/// Niveau supérieur (10.4) : badge doré, nom du niveau, récompense en cauris. « Continuer » récupère la récompense (ack),
/// puis ouvre « Mission accomplie » (10.2) si la mission 2 est terminée, sinon le QG (data-hr de la planche).
class LevelUpScreen extends ConsumerStatefulWidget {
  const LevelUpScreen({super.key});
  @override
  ConsumerState<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends ConsumerState<LevelUpScreen> {
  /// Vrai dès que « Continuer » est touché : le niveau acquitté ne doit pas déclencher le retour au QG prévu quand il n'y a rien à récupérer.
  bool _leaving = false;

  /// Nouvelles options annoncées par la planche 10.4 (niveau 2) ; les autres niveaux n'ont pas de texte dans les planches.
  static const _unlocks = {2: 'Nouvelles options : open mic, instru Pont des Griots, missions avancées.'};

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    final pend = s?.pend;
    if (s != null && pend == null && !_leaving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
    }
    if (pend == null) return const GameFrame(children: []);
    return GameFrame(burst: true, children: [
      const SizedBox(height: 70),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text('NIVEAU SUPÉRIEUR', style: V20Text.lab()),
        const SizedBox(height: 12),
        LevelBadge('N${pend.lvl}'),
        const SizedBox(height: 12),
        Text(Econ.levelNames[pend.lvl - 1].toUpperCase(), textAlign: TextAlign.center, style: V20Text.dm()),
        if (_unlocks[pend.lvl] case final text?) ...[
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: V20Text.bm),
        ],
        if (pend.reward > 0) ...[
          const SizedBox(height: 12),
          RewardChip(value: '+ ${fmt(pend.reward)} cauris', color: Tk.ok),
        ],
      ]),
      const SizedBox(height: 12),
      PrimaryButton(
        label: 'Continuer',
        onPressed: () async {
          _leaving = true;
          await ref.read(gameProvider.notifier).acknowledgeLevel();
          if (context.mounted) context.go(ref.read(gameProvider).requireValue.ms['m2'] == 'done' ? '/mission-accomplie' : '/');
        },
      ),
    ]);
  }
}
