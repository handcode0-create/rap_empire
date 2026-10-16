import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/action_tile.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/toast.dart';

/// Matériel (09.1), racine de l'onglet Business : tuiles d'accès et équipement, avec la confirmation d'achat (09.2).
/// Seul le micro studio a une règle dans game.js (+8 à la voix) : le casque et la carte son affichent les valeurs de la planche, sans achat.
/// Finances, Réseau et Équipe sont « Bientôt ».
class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  Future<void> _buyMicro(BuildContext context, WidgetRef ref, GameState s) async {
    if (s.micro) return showError(context, const GameError('deja'));
    if (s.cash < Econ.microPrice) return showError(context, const GameError('cash'));
    if (needsConfirm(Econ.microPrice)) {
      final ok = await showGameSheet<bool>(context, builder: (_) => _PurchaseSheet(cash: s.cash));
      if (ok != true) return;
    }
    try {
      await ref.read(gameProvider.notifier).buyMicro();
    } on GameError catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Flexible(child: Text('MATÉRIEL', style: V20Text.baloo(size: 28, line: 28))),
        Text('DÉMO', style: V20Text.poppins(size: 10, line: 12, weight: FontWeight.w700, color: V20.hintGoldText, spacing: .8)),
      ]),
      const SizedBox(height: 8),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: ActionTile(icon: 'trend', title: 'Finances', subtitle: 'Revenus, dépenses', onTap: () => context.go('/business/finances'))),
          const SizedBox(width: 10),
          Expanded(child: ActionTile(icon: 'trophy', title: 'Formation', subtitle: 'Compétences', onTap: () => context.go('/business/formation'))),
        ]),
      ),
      const SizedBox(height: 10),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: ActionTile(icon: 'users', title: 'Réseau', subtitle: 'Label, featuring', onTap: () => showInfo(context, 'Réseau : bientôt'))),
          const SizedBox(width: 10),
          Expanded(child: ActionTile(icon: 'briefcase', title: 'Équipe', subtitle: 'Manager', onTap: () => showInfo(context, 'Équipe : bientôt'))),
        ]),
      ),
      for (final g in gearItems) ...[
        const SizedBox(height: 8),
        ActionRow(
          icon: g.icon,
          title: g.name,
          subtitle: g.effect,
          trailing: g.id == 'micro' && s.micro ? const GameTag('Déjà acheté', style: GameTagStyle.ok) : Text('${fmt(g.price)} cauris', style: V20Text.nm(color: Tk.gold)),
          onTap: g.implemented ? () => _buyMicro(context, ref, s) : () => showInfo(context, '${g.name} : bientôt'),
        ),
      ],
    ]);
  }
}

/// Feuille de confirmation d'achat du micro studio (09.2).
class _PurchaseSheet extends StatelessWidget {
  final int cash;
  const _PurchaseSheet({required this.cash});

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('CONFIRMATION', style: V20Text.lab()),
        const SizedBox(height: 16),
        Text('ACHETER LE MICRO STUDIO ?', style: V20Text.dm(size: 26)),
        const SizedBox(height: 16),
        Text('Qualité enregistrement +$microVoiceBonus sur ta voix.', style: V20Text.bs()),
        const SizedBox(height: 16),
        GameCard(
          child: Column(children: [
            _Line('Prix', '${fmt(Econ.microPrice)} cauris', color: Tk.gold),
            _Line('Cash après achat', '${fmt(cash - Econ.microPrice)} cauris'),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Acheter', sublabel: '− ${fmt(Econ.microPrice)} cauris', onPressed: () => Navigator.of(context).pop(true)),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Annuler', style: GameButtonStyle.ghost, onPressed: () => Navigator.of(context).pop(false)),
      ]);
}

class _Line extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Line(this.label, this.value, {this.color = Tk.ink});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(label, style: V20Text.bs())),
          const SizedBox(width: 8),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: V20Text.nm(color: color))),
        ]),
      );
}
