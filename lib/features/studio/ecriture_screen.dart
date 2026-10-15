import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/studio.dart';
import '../shell/buttons.dart';
import '../shell/tired_sheet.dart';
import 'studio_widgets.dart';

/// Écrire le texte (04.5) puis résultat (04.6). Thème et ambiance passent à write() (lib/domain/studio.dart).
class EcritureScreen extends ConsumerStatefulWidget {
  const EcritureScreen({super.key});
  @override
  ConsumerState<EcritureScreen> createState() => _EcritureScreenState();
}

class _EcritureScreenState extends ConsumerState<EcritureScreen> {
  String _theme = 'quartier';
  bool _rewriting = false;

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
    final instru = s.inst == null ? null : instruById(s.inst!);
    final texte = s.texte;
    return ListView(padding: const EdgeInsets.all(16), children: [
      StepHeader(title: texte != null && !_rewriting ? 'Ton texte' : 'Écrire le texte', step: 'Étape 2 / 3', backTo: '/studio/instru'),
      const SizedBox(height: 8),
      TkCard(
        child: Row(children: [
          const Text('Instru', style: TextStyle(color: Tk.ink2)),
          const SizedBox(width: 12),
          Expanded(child: Text(instru?.name ?? 'Aucune', style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink))),
          Text('· qualité ${instru?.q ?? 32}', style: const TextStyle(color: Tk.ink2)),
        ]),
      ),
      const SizedBox(height: 16),
      if (texte != null && !_rewriting) ...[
        TkCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${themeNames[texte.theme]} · ${ambNames[texte.amb]}', style: const TextStyle(color: Tk.ink2)),
            const SizedBox(height: 8),
            const Text('Note texte', style: TextStyle(color: Tk.ink2, fontSize: 12)),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${texte.note}', style: const TextStyle(color: Tk.ink, fontWeight: FontWeight.w800, fontSize: 40)),
              const SizedBox(width: 8),
              const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Estimé', style: TextStyle(color: Tk.ink2))),
            ]),
            const SizedBox(height: 8),
            const Text('Écriture +$writeSkillGain · −$writeEnergy énergie · $writeHours h', style: TextStyle(color: Tk.cy)),
          ]),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Passer en cabine', onPressed: () => context.go('/studio/cabine')),
        const SizedBox(height: 8),
        GhostButton(label: 'Réécrire', onPressed: () => setState(() => _rewriting = true)),
      ] else ...[
        const Text('Thème', style: TextStyle(color: Tk.ink2)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in themeNames.entries)
            ChoiceChip(
              label: Text(t.value),
              selected: _theme == t.key,
              onSelected: (_) => setState(() => _theme = t.key),
              labelStyle: TextStyle(color: _theme == t.key ? Tk.ink : Tk.ink2, fontWeight: FontWeight.w600),
              selectedColor: Tk.acc7,
              backgroundColor: Tk.s1,
              side: BorderSide(color: _theme == t.key ? Tk.acc : Tk.line),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
        ]),
        const SizedBox(height: 16),
        const Text('Ambiance · choisis pour écrire', style: TextStyle(color: Tk.ink2)),
        const SizedBox(height: 8),
        for (final a in ambNames.entries) ...[
          TkCard(
            onTap: () => _write(a.key),
            child: Row(children: [
              Expanded(child: Text('Écrire · ${a.value}', style: const TextStyle(fontWeight: FontWeight.w800, color: Tk.ink))),
              const Text('$writeHours h · −$writeEnergy énergie', style: TextStyle(color: Tk.ink2, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ]);
  }
}
