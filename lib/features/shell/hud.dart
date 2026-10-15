import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/clock.dart';
import '../../domain/rules.dart';

/// HUD : niveau, cauris, énergie, jour et heure, lus depuis l'état réel.
class Hud extends ConsumerWidget {
  const Hud({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const SizedBox(height: 112);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: Tk.grad, shape: BoxShape.circle),
            child: const Text('DK', style: TextStyle(fontWeight: FontWeight.w800, color: Tk.ink)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Djo Kéné', style: Theme.of(context).textTheme.titleLarge),
              Text('N${s.level} · ${s.levelName.toUpperCase()}', style: const TextStyle(color: Tk.ink2, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _Stat(label: 'Cash · cauris', value: fmt(s.cash), color: Tk.gold),
          const SizedBox(width: 8),
          _Stat(label: 'Énergie', value: '${s.energy}', color: Tk.cy),
          const SizedBox(width: 8),
          _Stat(label: 'Temps', value: formatClock(s), color: Tk.ink),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(12), border: Border.all(color: Tk.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Tk.ink2, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
        ),
      );
}
