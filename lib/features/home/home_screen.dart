import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/clock.dart';
import '../../domain/missions.dart';
import '../../domain/rules.dart';
import '../shell/buttons.dart';
import '../shell/tired_sheet.dart';

/// QG (03.1) : objectif en cours, indicateurs, accès au studio. Le HUD est dans la coque.
/// Énergie basse (03.2) : feuille « Trop fatigué » avec l'action Dormir.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _sheetShown = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final tired = isTooTired(s);
    if (tired && !_sheetShown) {
      _sheetShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showTiredSheet(context, ref, s.energy);
      });
    } else if (!tired) {
      _sheetShown = false;
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Salut, Djo', style: Theme.of(context).textTheme.displayMedium),
      const SizedBox(height: 16),
      if (tired) ...[
        _TiredBanner(energy: s.energy, onSleep: () => sleepNow(context, ref)),
        const SizedBox(height: 16)
      ],
      const _ObjectiveCard(mission: mission1),
      const SizedBox(height: 16),
      Row(children: [
        _Indicator(label: 'Fans', value: fmt(s.fans)),
        const SizedBox(width: 8),
        _Indicator(label: 'Popularité', value: fmt(s.pop)),
        const SizedBox(width: 8),
        _Indicator(label: 'Réputation', value: fmt(s.rep)),
      ]),
      const SizedBox(height: 24),
      PrimaryButton(
          label: 'Aller au studio', onPressed: () => context.go('/studio')),
    ]);
  }
}

class _TiredBanner extends StatelessWidget {
  final int energy;
  final VoidCallback onSleep;
  const _TiredBanner({required this.energy, required this.onSleep});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Tk.tint,
            borderRadius: BorderRadius.circular(Tk.rCard),
            border: Border.all(color: Tk.acc7)),
        child: Row(children: [
          const Icon(Icons.bolt_rounded, color: Tk.gold),
          const SizedBox(width: 8),
          Expanded(
              child: Text("Énergie basse ($energy) : dors avant d'enchaîner.",
                  style: const TextStyle(color: Tk.ink))),
          TextButton(
            onPressed: onSleep,
            style: TextButton.styleFrom(
                minimumSize: const Size(Tk.minTap, Tk.minTap),
                foregroundColor: Tk.acc4),
            child: const Text('Dormir'),
          ),
        ]),
      );
}

class _ObjectiveCard extends StatelessWidget {
  final Mission mission;
  const _ObjectiveCard({required this.mission});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Tk.s1,
            borderRadius: BorderRadius.circular(Tk.rCard),
            border: Border.all(color: Tk.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('OBJECTIF EN COURS',
              style: TextStyle(
                  color: Tk.acc4,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Mission 1',
              style: TextStyle(color: Tk.ink2, fontSize: 12)),
          Text(mission.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(mission.hint, style: const TextStyle(color: Tk.ink2)),
        ]),
      );
}

class _Indicator extends StatelessWidget {
  final String label, value;
  const _Indicator({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Tk.s1,
              borderRadius: BorderRadius.circular(Tk.rCard),
              border: Border.all(color: Tk.line)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Tk.ink2, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Tk.ink, fontWeight: FontWeight.w800, fontSize: 20)),
          ]),
        ),
      );
}
