import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_toast.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/segmented_choice.dart';
import '../../domain/econ.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/tired_sheet.dart';
import '../shell/toast.dart';
import 'studio_parts.dart';

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
      final ok = await showGameSheet<bool>(context, builder: (_) => _PromoSheet(name: p.name, cost: p.cost, cashAfter: s.cash - p.cost));
      if (ok != true) return;
    }
    try {
      await ref.read(gameProvider.notifier).releaseSingle(_promo);
      if (mounted) context.go('/studio/chargement');
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
        BackHeader(title: 'Sortir le son', onBack: () => context.go('/studio')),
        const SizedBox(height: 24),
        Center(child: Text('Aucun son prêt à sortir.', style: V20Text.bs())),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ]);
    }
    final preview = releasePreview(s, _promo);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Sortir le son', onBack: () => context.go('/studio')),
      const SizedBox(height: 8),
      SongHeaderCard(song: song, styleName: styleNames[s.style] ?? ''),
      const SizedBox(height: 8),
      SegmentedChoice(items: [
        const SegmentItem('Single', on: true),
        SegmentItem('EP · maquette', onTap: () => showInfo(context, 'EP : bientôt')),
      ]),
      const SizedBox(height: 8),
      Text('PROMOTION', style: V20Text.lab()),
      for (var i = 0; i < promos.length; i++) ...[
        const SizedBox(height: 8),
        BeatCard(
          title: promos[i].name,
          subtitle: _reach[i],
          selected: _promo == i,
          onTap: () => setState(() => _promo = i),
          trailing: Text(promos[i].cost == 0 ? 'Gratuit' : '${fmt(promos[i].cost)} cauris', style: V20Text.nm(color: promos[i].cost == 0 ? Tk.ok : Tk.gold)),
        ),
      ],
      const SizedBox(height: 8),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _Line('Écoutes estimées · 24 h', fmt(preview.listens)),
          const SizedBox(height: 4),
          _Line('Cash après promo', fmt(preview.cashAfter), color: Tk.gold),
          if (preview.affordable) ...[
            const SizedBox(height: 4),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: Tk.ink2, width: 1.5)),
              child: Text('ESTIMÉ · VALEURS DE DÉMO', style: V20Text.poppins(size: 10, line: 13, weight: FontWeight.w700, color: V20.ink2, spacing: .3)),
            ),
          ],
        ]),
      ),
      if (!preview.affordable) ...[
        const SizedBox(height: 8),
        GameToast(kind: ToastKind.error, message: 'Cash insuffisant · ${fmt(preview.promoCost)} requis, tu as ${fmt(s.cash)}'),
      ],
      const SizedBox(height: 8),
      PrimaryButton(label: 'Sortir le single', onPressed: _release),
    ]);
  }
}

class _Line extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Line(this.label, this.value, {this.color = Tk.ink});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(flex: 3, child: Text(label, style: V20Text.bs())),
        const SizedBox(width: 8),
        Flexible(flex: 2, child: Text(value, textAlign: TextAlign.end, style: V20Text.nm(color: color))),
      ]);
}

/// Feuille de confirmation de la promo (05.2).
class _PromoSheet extends StatelessWidget {
  final String name;
  final int cost, cashAfter;
  const _PromoSheet({required this.name, required this.cost, required this.cashAfter});

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('CONFIRMATION', style: V20Text.lab()),
        const SizedBox(height: 16),
        Text('LANCER LA PROMO ?', style: V20Text.dm(size: 26)),
        const SizedBox(height: 16),
        Text('Dépense supérieure à ${fmt(Econ.confirmFrom)} cauris.', style: V20Text.bs()),
        const SizedBox(height: 16),
        GameCard(
          child: Column(children: [
            _Line('Promo', name, color: Tk.ink),
            _Line('Prix', '${fmt(cost)} cauris', color: Tk.gold),
            _Line('Cash après', fmt(cashAfter)),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Confirmer et sortir', onPressed: () => Navigator.of(context).pop(true)),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Annuler', style: GameButtonStyle.ghost, onPressed: () => Navigator.of(context).pop(false)),
      ]);
}
