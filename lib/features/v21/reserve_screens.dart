import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'widgets21.dart';

/// Réserve de titres enregistrés et sorties programmées. Un titre peut attendre sa sortie (date de jeu), rejoindre un EP ou
/// un album sans être sorti en single, ou sortir tout de suite. Aucune règle ici : tout passe par les actions du moteur.

num _n(dynamic x) => (x ?? 0) as num;

/// Délais proposés pour programmer une sortie (jours de jeu), tous dans la fenêtre 1 à Reg21.relMaxDays.
const releaseDelays21 = [1, 3, 7, 14, 28];

String _delayLabel(int d) => d == 1 ? 'Demain' : '+$d jours';

/// Choix d'un délai : une pastille par durée, avec la date de jeu correspondante. [onPick] reçoit le nombre de jours.
class DelayPicker21 extends StatelessWidget {
  final num today;
  final int? selected;
  final ValueChanged<int> onPick;
  const DelayPicker21({super.key, required this.today, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final d in releaseDelays21) Chip21(_delayLabel(d), selected: selected == d, onTap: () => onPick(d)),
        ]),
        if (selected != null) ...[
          const SizedBox(height: 8),
          Text('Sortie le ${dateLabel21(today + selected!)}', style: V20Text.bs(color: Tk.ink)),
        ],
      ]);
}

/// Feuille de choix de la date de sortie d'un titre de la réserve.
Future<void> pickReleaseDate(BuildContext context, WidgetRef ref, J song) async {
  final today = _n(ref.read(game21Provider).requireValue['day']);
  final days = await showGameSheet<int>(
    context,
    builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('DATE DE SORTIE', style: V20Text.lab()),
      const SizedBox(height: 8),
      Text((song['title'] as String).toUpperCase(), style: V20Text.dm(size: 24)),
      const SizedBox(height: 4),
      Text('Aujourd\'hui : ${dateLabel21(today)}', style: V20Text.bs()),
      const SizedBox(height: 12),
      DelayPicker21(today: today, selected: null, onPick: (d) => Navigator.of(ctx).pop(d)),
    ]),
  );
  if (days == null || !context.mounted) return;
  await doAct(context, ref, 'schedule', [song['id'], days], null, 'Sortie programmée : ${dateLabel21(today + days)}');
}

class ReserveScreen extends ConsumerWidget {
  const ReserveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final today = _n(s['day']);
    final stock = stockSongs21(s);
    final dated = stock.where((x) => x['relDay'] != null).toList();
    final free = stock.where((x) => x['relDay'] == null).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Sorties à venir', step: 'Réserve', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("AUJOURD'HUI", style: V20Text.lab()),
        Text(dateLabel21(today), style: V20Text.baloo(size: 30, line: 32)),
        Text('${stock.length} / ${Reg21.stockMax} titres enregistrés, pas encore sortis', style: V20Text.bs(color: Tk.ink)),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Terminer la journée',
            sublabel: 'Avance la date d\'un jour : les sorties du jour partent',
            style: GameButtonStyle.secondary,
            onPressed: () => doAct(context, ref, 'endDay', null, () => context.go('/bilan'))),
      ])),
      const SizedBox(height: 12),
      if (stock.isEmpty) ...[
        const GameHint(
            icon: 'info',
            text: 'Aucun titre en attente. Enregistre un titre au studio, puis programme sa sortie ou garde-le en réserve pour un EP ou un album.'),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Aller au studio', onPressed: () => context.go('/studio')),
      ],
      if (dated.isNotEmpty) ...[
        const Lab21('Sorties programmées'),
        for (final c in dated) ...[
          const SizedBox(height: 8),
          _SongCard(c, today, scheduled: true),
        ],
        const SizedBox(height: 12),
      ],
      if (free.isNotEmpty) ...[
        const Lab21('En réserve, sans date'),
        for (final c in free) ...[
          const SizedBox(height: 8),
          _SongCard(c, today, scheduled: false),
        ],
        const SizedBox(height: 12),
      ],
      if (stock.isNotEmpty)
        PrimaryGlowButton(
            label: 'Créer un EP ou un album',
            sublabel: 'Les titres en réserve y entrent sans sortir en single',
            onPressed: () => context.go('/studio/catalogue/projet')),
    ]);
  }
}

class _SongCard extends ConsumerWidget {
  final J c;
  final num today;
  final bool scheduled;
  const _SongCard(this.c, this.today, {required this.scheduled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = c['id'] as String;
    final due = scheduled ? _n(c['relDay']) : null;
    final promo = _n(c['promoSel']).toInt();
    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pochette21(int.tryParse(id.replaceAll(RegExp('[^0-9]'), '')) ?? 0, size: 48),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['title'] as String, style: V20Text.nm()),
            Text('Qualité ${c['Q']}${scheduled ? ' · promo ${promos21[promo]['n']}' : ''}', style: V20Text.bs()),
            if (scheduled) Text('Sort le ${dateLabel21(due!)} · ${dueIn21(due, today)}', style: V20Text.bs(color: Tk.ink)),
          ])),
          GameTag(scheduled ? 'Programmé' : 'En réserve', style: scheduled ? GameTagStyle.accent : GameTagStyle.outline),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Chip21(scheduled ? 'Changer la date' : 'Programmer', onTap: () => pickReleaseDate(context, ref, c)),
          Chip21('Sortir maintenant', onTap: () => doAct(context, ref, 'rnow', id, () => context.go('/studio/resultats'))),
          if (scheduled) Chip21('Annuler la date', onTap: () => doAct(context, ref, 'unschedule', id, null, 'Titre remis en réserve')),
        ]),
      ]),
    );
  }
}

/// Bloc « Programmer la sortie » de l'écran de sortie (21-M3) : délai, puis programmation ou mise en réserve du titre en cours.
class ScheduleBlock21 extends ConsumerStatefulWidget {
  const ScheduleBlock21({super.key});
  @override
  ConsumerState<ScheduleBlock21> createState() => _ScheduleBlockState();
}

class _ScheduleBlockState extends ConsumerState<ScheduleBlock21> {
  int? _days;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final today = _n(s['day']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Lab21('Ou programmer la sortie'),
      Text('Le titre attend sa date, tu peux d\'ici là en enregistrer d\'autres ou le mettre dans un EP ou un album. La promotion choisie est payée maintenant.', style: V20Text.bs()),
      const SizedBox(height: 8),
      DelayPicker21(today: today, selected: _days, onPick: (d) => setState(() => _days = d)),
      const SizedBox(height: 8),
      PrimaryButton(
          label: _days == null ? 'Choisis une date' : 'Programmer pour ${dateLabel21(today + _days!)}',
          style: GameButtonStyle.secondary,
          onPressed: _days == null ? null : () => doAct(context, ref, 'schedule', _days, () => context.go('/studio/reserve')),
          ),
      const SizedBox(height: 8),
      PrimaryButton(
          label: 'Garder en réserve',
          sublabel: 'Sans date · pour un EP ou un album',
          style: GameButtonStyle.ghost,
          onPressed: () => doAct(context, ref, 'shelve', null, () => context.go('/studio/reserve')),
          ),
    ]);
  }
}
