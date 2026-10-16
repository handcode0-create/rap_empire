import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/hero_stat.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../domain/instru_names.dart';
import '../../domain/music_catalog.dart';
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

  /// Thème choisi pour le texte (music_catalog.dart) : il donne le sujet du texte et du titre.
  String _theme = 'rue';
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
      await ref.read(gameProvider.notifier).writeText(theme: _theme, amb: amb);
      if (mounted) setState(() => _rewriting = false);
    } on Object catch (e) {
      if (mounted) showGameError(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final instru = s.inst == null ? null : instruChosen(s);
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
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child: Text('« Gbaka de six heures, le quartier se réveille, dans ma tête une mélodie, dans mes poches des étincelles. Ndo city dort encore, moi je… »', style: V20Text.bm.copyWith(fontStyle: FontStyle.italic)),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            HeroStat(label: 'Note texte', value: texte.note, size: 56, caption: const Align(alignment: Alignment.centerLeft, child: ConsequenceTag(ConsequenceKind.estimated))),
            const SizedBox(height: 8),
            const IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: HeroStat(label: 'Rimes', value: 70, size: 26, caption: Align(alignment: Alignment.centerLeft, child: ConsequenceTag(ConsequenceKind.uncertain, label: 'Démo')))),
                VerticalDivider(width: 17, thickness: 1, color: Color.fromRGBO(255, 255, 255, .10)),
                Expanded(child: HeroStat(label: 'Images', value: 74, size: 26, caption: Align(alignment: Alignment.centerLeft, child: ConsequenceTag(ConsequenceKind.uncertain, label: 'Démo')))),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
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
        PrimaryGlowButton(label: 'Passer en cabine', sublabel: 'Étape 3 / 3', onPressed: () => context.go('/studio/cabine')),
      ]);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Écrire le texte', step: 'Étape 2 / 3', onBack: () => context.go('/studio/instru')),
      const SizedBox(height: 8),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('INSTRU', style: V20Text.lab()),
          Text('${instru?.name ?? 'Aucune'} · qualité ${instru?.q ?? noInstruProd}', style: V20Text.nm()),
        ]),
      ),
      const SizedBox(height: 8),
      Text('THÈME', style: V20Text.lab()),
      const SizedBox(height: 6),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        for (final t in musicThemes)
          Semantics(
            button: true,
            selected: t.id == _theme,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _theme = t.id),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(child: GameTag(t.name, style: t.id == _theme ? GameTagStyle.accent : GameTagStyle.outline)),
                ),
              ),
            ),
          ),
      ])),
      const SizedBox(height: 6),
      Text(themeById(_theme)!.subject, style: V20Text.bs()),
      const SizedBox(height: 8),
      Text('AMBIANCE · CHOISIS POUR ÉCRIRE', style: V20Text.lab()),
      for (final a in ambNames.entries) ...[
        const SizedBox(height: 8),
        ChoiceCard(
          title: 'Écrire · ${a.value}',
          onTap: () => _write(a.key),
          consequences: [
            const Consequence(ConsequenceKind.certain, '$writeHours h · −$writeEnergy énergie'),
            Consequence(ConsequenceKind.estimated, 'Note du texte : ${textNote(_theme, a.key)}'),
          ],
        ),
      ],
    ]);
  }
}
