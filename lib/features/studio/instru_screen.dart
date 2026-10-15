import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/buttons.dart';
import '../shell/toast.dart';
import 'studio_widgets.dart';

/// Choisis une instru (04.3) avec confirmation d'achat (04.4).
class InstruScreen extends ConsumerWidget {
  const InstruScreen({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref, GameState s, Instru i) async {
    final blocker = pickBlocker(s, i.id);
    if (blocker != null) return showError(context, GameError(blocker));
    if (needsConfirm(i.price)) {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Tk.s1,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tk.rSheet))),
        builder: (_) => _PurchaseSheet(instru: i, cash: s.cash),
      );
      if (ok != true) return;
    }
    try {
      await ref.read(gameProvider.notifier).pickInstru(i.id);
    } on GameError catch (e) {
      if (context.mounted) showError(context, e);
      return;
    }
    if (context.mounted) {
      showInfo(context, '${i.name} : instru choisie');
      context.go('/studio');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      const StepHeader(title: 'Choisis une instru', step: 'Étape 1 / 3'),
      const SizedBox(height: 8),
      for (final i in instrus) ...[
        _InstruCard(instru: i, selected: s.inst == i.id, onTap: () => _choose(context, ref, s, i)),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 8),
      Text(
        'Une instru achetée est facturée tout de suite. À partir de ${fmt(Econ.confirmFrom)} cauris, une confirmation est demandée.',
        style: const TextStyle(color: Tk.ink2, fontSize: 12),
      ),
    ]);
  }
}

class _InstruCard extends StatelessWidget {
  final Instru instru;
  final bool selected;
  final VoidCallback onTap;
  const _InstruCard({required this.instru, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final lock = instru.lvl > 1 ? 'N${instru.lvl}' : (instru.rep > 0 ? 'Rép. ${instru.rep}' : null);
    return TkCard(
      onTap: onTap,
      selected: selected,
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(gradient: Tk.grad, shape: BoxShape.circle),
          child: Text(instru.name.characters.first, style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(instru.name, style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
            Text('${instru.who} · Q${instru.q}', style: const TextStyle(color: Tk.ink2, fontSize: 12)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(instru.price == 0 ? 'Gratuit' : '${fmt(instru.price)} cauris', style: const TextStyle(color: Tk.gold, fontWeight: FontWeight.w800)),
          if (lock != null) Text(lock, style: const TextStyle(color: Tk.ink2, fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _PurchaseSheet extends StatelessWidget {
  final Instru instru;
  final int cash;
  const _PurchaseSheet({required this.instru, required this.cash});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Confirmation', style: TextStyle(color: Tk.ink2)),
            Text('Acheter ${instru.name} ?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Achat à partir de ${fmt(Econ.confirmFrom)} cauris.', style: const TextStyle(color: Tk.ink2)),
            const SizedBox(height: 16),
            KeyValueRow(label: 'Prix', value: '${fmt(instru.price)} cauris', color: Tk.gold),
            KeyValueRow(label: 'Cash après achat', value: '${fmt(cash - instru.price)} cauris'),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Acheter  − ${fmt(instru.price)} cauris', onPressed: () => Navigator.of(context).pop(true)),
            const SizedBox(height: 8),
            GhostButton(label: 'Annuler', onPressed: () => Navigator.of(context).pop(false)),
          ]),
        ),
      );
}
