import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';

/// En-tête d'une étape du studio : retour, titre, « Étape n / 3 ».
class StepHeader extends StatelessWidget {
  final String title;
  final String? step;
  final String backTo;
  const StepHeader({super.key, required this.title, this.step, this.backTo = '/studio'});
  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(
          onPressed: () => context.go(backTo),
          icon: const Icon(Icons.arrow_back_rounded, color: Tk.ink),
          tooltip: 'Retour',
          constraints: const BoxConstraints(minWidth: Tk.minTap, minHeight: Tk.minTap),
        ),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (step != null) Text(step!, style: const TextStyle(color: Tk.ink2, fontSize: 12)),
      ]);
}

/// Carte standard du design system (surface s1, bordure line, rayon rCard).
class TkCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsets padding;
  const TkCard({super.key, required this.child, this.onTap, this.selected = false, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Material(
        color: Tk.s1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rCard), side: BorderSide(color: selected ? Tk.acc : Tk.line, width: selected ? 2 : 1)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Tk.rCard),
          child: Padding(padding: padding, child: child),
        ),
      );
}

/// Ligne « libellé — valeur » (récapitulatifs, résultats).
class KeyValueRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const KeyValueRow({super.key, required this.label, required this.value, this.color = Tk.ink});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(flex: 3, child: Text(label, style: const TextStyle(color: Tk.ink2))),
          const SizedBox(width: 12),
          Flexible(flex: 2, child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: color, fontWeight: FontWeight.w800))),
        ]),
      );
}
