import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Puce de récompense (.chip de rap.css) : valeur Baloo 18 + libellé 11, fond s2. Or pour les cauris, vert pour le succès.
class RewardChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const RewardChip({super.key, required this.value, required this.label, this.color = Tk.gold});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Tk.s2, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: V20Text.nm(color: color)),
          const SizedBox(width: 6),
          Text(label.toUpperCase(), style: V20Text.lab()),
        ]),
      );
}
