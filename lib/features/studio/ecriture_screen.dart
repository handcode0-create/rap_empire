import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../../domain/titles.dart';
import '../shell/tired_sheet.dart';

/// Écrire le texte (04.5) puis « Ton texte » (04.6).
/// Valeurs de la planche sans formule dans game.js : thème « Le quartier » seul appliqué (la planche le dit), extrait du texte, Rimes 70 et Images 74.
class EcritureScreen extends ConsumerStatefulWidget {
  const EcritureScreen({super.key});
  @override
  ConsumerState<EcritureScreen> createState() => _EcritureScreenState();
}

class _EcritureScreenState extends ConsumerState<EcritureScreen> {
  bool _rewriting = false;
  final _titleCtl = TextEditingController();
  final _titleFocus = FocusNode();

  @override
  void dispose() {
    _titleCtl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _write(String amb) async {
    try {
      await ref.read(gameProvider.notifier).writeText(theme: 'quartier', amb: amb);
      if (mounted) setState(() => _rewriting = false);
    } on Object catch (e) {
      if (mounted) showGameError(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final instru = s.inst == null ? null : instruById(s.inst!);
    final texte = s.texte;
    if (texte != null && !_rewriting) {
      // le titre est généré dès que le texte s'affiche ; le champ suit l'état sauf pendant la saisie
      if ((s.title ?? '').trim().isEmpty && !_titleFocus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(gameProvider.notifier).ensureTitle();
        });
      }
      if (!_titleFocus.hasFocus && _titleCtl.text != (s.title ?? '')) _titleCtl.text = s.title ?? '';
      return ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Ton texte', onBack: () => setState(() => _rewriting = true)),
        const SizedBox(height: 12),
        GameCard(
          selected: true,
          child: Text('« Gbaka de six heures, le quartier se réveille, dans ma tête une mélodie, dans mes poches des étincelles. Ndo city dort encore, moi je… »', style: V20Text.bm.copyWith(fontStyle: FontStyle.italic)),
        ),
        const SizedBox(height: 12),
        KpiRow(children: [
          StatKpi(label: 'Note texte', value: fmt(texte.note), delta: 'Estimé', big: true),
          const StatKpi(label: 'Rimes', value: '70'),
          const StatKpi(label: 'Images', value: '74'),
        ]),
        const SizedBox(height: 12),
        GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('TITRE DU SON', style: V20Text.lab()),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtl,
              focusNode: _titleFocus,
              inputFormatters: [LengthLimitingTextInputFormatter(maxTitleLength)],
              textCapitalization: TextCapitalization.sentences,
              style: V20Text.nm(),
              cursorColor: Tk.acc,
              onChanged: (v) => ref.read(gameProvider.notifier).setTitle(v),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Tk.s2,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.acc, width: 2)),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Titre aléatoire',
              style: GameButtonStyle.secondary,
              compact: true,
              onPressed: () {
                _titleFocus.unfocus();
                ref.read(gameProvider.notifier).rerollTitle();
              },
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          RewardChip(value: 'Écriture +$writeSkillGain', color: Tk.ok),
          GameTag('−$writeEnergy énergie · $writeHours h'),
        ]),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Passer en cabine', sublabel: 'Étape 3 / 3', onPressed: () => context.go('/studio/cabine')),
      ]);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Écrire le texte', step: 'Étape 2 / 3', onBack: () => context.go('/studio/instru')),
      const SizedBox(height: 8),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('INSTRU', style: V20Text.lab()),
          Text('${instru?.name ?? 'Aucune'} · qualité ${instru?.q ?? noInstruProd}', style: V20Text.nm()),
        ]),
      ),
      const SizedBox(height: 8),
      Text('THÈME', style: V20Text.lab()),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final t in themeNames.entries) GameTag(t.value, style: t.key == 'quartier' ? GameTagStyle.accent : GameTagStyle.outline),
      ]),
      const SizedBox(height: 6),
      Text('Démo : le thème « Le quartier » est appliqué ; l’ambiance modifie la note.', style: V20Text.bs()),
      const SizedBox(height: 8),
      Text('AMBIANCE · CHOISIS POUR ÉCRIRE', style: V20Text.lab()),
      for (final a in ambNames.entries) ...[
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Écrire · ${a.value}',
          sublabel: '$writeHours h · −$writeEnergy énergie',
          style: a.key == 'sombre' ? GameButtonStyle.primary : GameButtonStyle.secondary,
          onPressed: () => _write(a.key),
        ),
      ],
    ]);
  }
}
