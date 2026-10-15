import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/buttons.dart';
import '../shell/tired_sheet.dart';
import 'studio_widgets.dart';

/// Sortir le son (05.1, 05.1b) avec confirmation de promo (05.2). Estimations : releasePreview() du domaine.
class SortieScreen extends ConsumerStatefulWidget {
  const SortieScreen({super.key});
  @override
  ConsumerState<SortieScreen> createState() => _SortieScreenState();
}

class _SortieScreenState extends ConsumerState<SortieScreen> {
  int _promo = 0;

  static const _reach = ['Audience du quartier', 'Portée moyenne', 'Portée large'];

  Future<void> _release() async {
    final s = ref.read(gameProvider).requireValue;
    final p = promos[_promo];
    if (s.cash >= p.cost && needsConfirm(p.cost)) {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Tk.s1,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tk.rSheet))),
        builder: (_) => _PromoSheet(name: p.name, cost: p.cost, cashAfter: s.cash - p.cost),
      );
      if (ok != true) return;
    }
    try {
      await ref.read(gameProvider.notifier).releaseSingle(_promo);
      if (mounted) context.go('/studio/resultats');
    } on Object catch (e) {
      if (mounted) showGameError(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final song = s.song;
    if (song == null || song.released) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const StepHeader(title: 'Sortir le son'),
        const SizedBox(height: 24),
        const Center(child: Text('Aucun son prêt à sortir.', style: TextStyle(color: Tk.ink2))),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ]);
    }
    final preview = releasePreview(s, _promo);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const StepHeader(title: 'Sortir le son'),
      const SizedBox(height: 8),
      TkCard(
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(song.title, style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
              Text('${styleNames[s.style]} · instru ${song.inst}', style: const TextStyle(color: Tk.ink2, fontSize: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Qualité', style: TextStyle(color: Tk.ink2, fontSize: 11)),
            Text('${song.q}', style: const TextStyle(color: Tk.ink, fontWeight: FontWeight.w800, fontSize: 20)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      const Text('Single', style: TextStyle(color: Tk.ink2)),
      const SizedBox(height: 16),
      const Text('Promotion', style: TextStyle(color: Tk.ink2)),
      const SizedBox(height: 8),
      for (var i = 0; i < promos.length; i++) ...[
        TkCard(
          selected: _promo == i,
          onTap: () => setState(() => _promo = i),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(promos[i].name, style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
                Text(_reach[i], style: const TextStyle(color: Tk.ink2, fontSize: 12)),
              ]),
            ),
            Text(promos[i].cost == 0 ? 'Gratuit' : '${fmt(promos[i].cost)} cauris', style: const TextStyle(color: Tk.gold, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 8),
      TkCard(
        child: Column(children: [
          KeyValueRow(label: 'Écoutes estimées · 24 h', value: fmt(preview.listens), color: Tk.cy),
          KeyValueRow(label: 'Cash après promo', value: fmt(preview.cashAfter), color: preview.affordable ? Tk.ink : Tk.acc4),
          if (!preview.affordable)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Cash insuffisant · ${fmt(preview.promoCost)} requis, tu as ${fmt(s.cash)}', style: const TextStyle(color: Tk.acc4)),
            ),
        ]),
      ),
      const SizedBox(height: 8),
      const Text('Estimé · valeurs de démo', style: TextStyle(color: Tk.ink2, fontSize: 12)),
      const SizedBox(height: 16),
      PrimaryButton(label: 'Sortir le single', onPressed: _release),
    ]);
  }
}

class _PromoSheet extends StatelessWidget {
  final String name;
  final int cost, cashAfter;
  const _PromoSheet({required this.name, required this.cost, required this.cashAfter});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Confirmation', style: TextStyle(color: Tk.ink2)),
            Text('Lancer la promo ?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Dépense à partir de ${fmt(Econ.confirmFrom)} cauris.', style: const TextStyle(color: Tk.ink2)),
            const SizedBox(height: 16),
            KeyValueRow(label: 'Promo', value: name),
            KeyValueRow(label: 'Prix', value: '${fmt(cost)} cauris', color: Tk.gold),
            KeyValueRow(label: 'Cash après', value: '${fmt(cashAfter)} cauris'),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Confirmer et sortir', onPressed: () => Navigator.of(context).pop(true)),
            const SizedBox(height: 8),
            GhostButton(label: 'Annuler', onPressed: () => Navigator.of(context).pop(false)),
          ]),
        ),
      );
}
