import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/cost_row.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/character_view.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/instru_names.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/toast.dart';

/// Choisis une instru (04.3) avec confirmation d'achat (04.4).
class InstruScreen extends ConsumerWidget {
  const InstruScreen({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref, GameState s, Instru i) async {
    final blocker = pickBlocker(s, i.id);
    if (blocker != null) return showError(context, GameError(blocker));
    if (needsConfirm(i.price)) {
      final ok = await showGameSheet<bool>(context, builder: (_) => _PurchaseSheet(instru: i, cash: s.cash));
      if (ok != true) return;
    }
    try {
      await ref.read(gameProvider.notifier).pickInstru(i.id);
    } on GameError catch (e) {
      if (context.mounted) showError(context, e);
      return;
    }
    if (context.mounted) context.go('/studio/ecriture');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Choisis une instru', step: 'Étape 1 / 3', onBack: () => context.go('/studio')),
      for (final i in instrusFor(s)) ...[
        const SizedBox(height: 12),
        _InstruRow(instru: i, state: s, onTap: () => _choose(context, ref, s, i)),
      ],
      const SizedBox(height: 12),
      GameHint(icon: 'info', text: 'Une instru achetée est facturée tout de suite. Au-delà de ${fmt(Econ.confirmFrom)} cauris, une confirmation est demandée.'),
    ]);
  }
}

/// Visage du beatmaker à la place de la pochette (assets/characters, générés par tools/design). Null pour l'instru gratuite, sans producteur.
class _Producer extends StatelessWidget {
  static const _ids = {'DJ Kôrô': 'kore', 'Sanko Beats': 'sanko', 'Mister Wôrô': 'woro'};
  final String who;
  const _Producer(this.who);

  static Widget? of(Instru i) => _ids.containsKey(i.who) ? _Producer(_ids[i.who]!) : null;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Tk.line, width: 2),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2B2459), Color(0xFF8B5CF6)]),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Padding(padding: const EdgeInsets.only(top: 3), child: CharacterView(who: who, mood: 'cool', crop: 'head', width: 44, height: 44)),
        ),
      );
}

class _InstruRow extends StatelessWidget {
  final Instru instru;
  final GameState state;
  final VoidCallback onTap;
  const _InstruRow({required this.instru, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = state.inst == instru.id;
    final blocker = pickBlocker(state, instru.id);
    // Verrou affiché à la place de la qualité : niveau ou réputation, avec la distance restante (la condition reste visible).
    final lock = blocker == 'niveau' ? 'N${instru.lvl}' : (blocker == 'rep' ? 'Rép. ${instru.rep}' : null);
    final remaining = blocker == 'niveau' ? 'Il te manque ${fmt(Econ.levelXp[instru.lvl - 1] - state.xp)} XP' : (blocker == 'rep' ? 'Il te manque ${instru.rep - state.rep} de réputation' : null);
    return Semantics(
      selected: selected,
      child: Opacity(
        opacity: lock != null ? .78 : 1,
        child: GlassCard(
          accent: selected ? GlassAccent.magenta : GlassAccent.none,
          halo: false,
          padding: const EdgeInsets.all(12),
          onTap: onTap,
          semanticLabel: '${instru.name}, ${instru.who}${lock == null ? '' : ', verrouillé : $lock'}',
          child: ExcludeSemantics(
            child: Row(children: [
              _Producer.of(instru) ?? GameCover(letter: instru.name.characters.first, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(instru.name, style: V20Text.nm(color: lock != null ? V20.ink2 : Tk.ink)),
                  Text(instru.who, style: V20Text.bs()),
                  Text(instruStyle(instru.id).name, style: V20Text.poppins(size: 12, line: 15, weight: FontWeight.w600, color: V20.ink2)),
                  if (remaining != null) Text(remaining, style: V20Text.poppins(size: 12, line: 15, weight: FontWeight.w600, color: V20.hintGoldText)),
                ]),
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                if (lock != null) GameTag(lock, style: GameTagStyle.outline, color: V20.ink2, borderColor: V20.ink2) else GameTag('Q${instru.q}', style: selected ? GameTagStyle.accent : GameTagStyle.normal),
                const SizedBox(height: 4),
                if (instru.price == 0)
                  Text('Gratuit', style: V20Text.nm(color: Tk.ok))
                else
                  Row(mainAxisSize: MainAxisSize.min, children: [Text('${fmt(instru.price)} cauris', style: V20Text.nm(color: Tk.gold)), const SizedBox(width: 6), const CauriIcon(size: 16)]),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Feuille de confirmation d'achat (04.4).
class _PurchaseSheet extends StatelessWidget {
  final Instru instru;
  final int cash;
  const _PurchaseSheet({required this.instru, required this.cash});

  /// Condition d'accès rappelée sous le titre (planche 04.4 : « Réservé au niveau 2 ou plus »).
  String get _condition => instru.rep > 0 ? 'Réservé à la réputation ${instru.rep} ou plus.' : 'Réservé au niveau ${instru.lvl} ou plus.';

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('CONFIRMATION', style: V20Text.lab()),
        const SizedBox(height: 16),
        Text('ACHETER ${instru.name.toUpperCase()} ?', style: V20Text.dm(size: 26)),
        const SizedBox(height: 16),
        Text('Achat supérieur à ${fmt(Econ.confirmFrom)} cauris. $_condition', style: V20Text.bs()),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(children: [
            _Line('Prix', '${fmt(instru.price)} cauris', color: Tk.gold),
            _Line('Cash après achat', '${fmt(cash - instru.price)} cauris'),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryGlowButton(label: 'Acheter', sublabel: '− ${fmt(instru.price)} cauris', onPressed: () => Navigator.of(context).pop(true)),
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
