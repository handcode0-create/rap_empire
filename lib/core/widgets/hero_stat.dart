import 'package:flutter/material.dart';
import '../../domain/rules.dart';
import '../theme/neon_tokens.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Chiffre héroïque : libellé en majuscules (Poppins 700, 11 px) et valeur Baloo 2 qui COMPTE de 0 à [value] à l'affichage
/// (700 ms, easeOutCubic). Sans animation si le système la désactive. [size] : 30 (appui) à 56 (héros).
/// La valeur est formatée par fmt() du domaine (espaces de milliers). Le texte se réduit au lieu de déborder.
class HeroStat extends StatelessWidget {
  final String label;
  final int value;
  final String prefix, suffix;
  final double size;
  final Color color;

  /// Ligne sous le chiffre (ex. étiquette « Estimé »).
  final Widget? caption;
  final CrossAxisAlignment align;
  const HeroStat({super.key, required this.label, required this.value, this.prefix = '', this.suffix = '', this.size = 48, this.color = Tk.ink, this.caption, this.align = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final alignment = align == CrossAxisAlignment.center ? Alignment.center : Alignment.centerLeft;
    return Semantics(
      label: '$label $prefix${fmt(value)}$suffix',
      excludeSemantics: true,
      child: Column(crossAxisAlignment: align, mainAxisSize: MainAxisSize.min, children: [
        Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
        const SizedBox(height: 2),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: still ? value.toDouble() : 0, end: value.toDouble()),
          duration: still ? Duration.zero : t.count,
          curve: t.enter,
          builder: (_, v, __) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: Text('$prefix${fmt(v.round())}$suffix', maxLines: 1, style: V20Text.baloo(size: size, line: size * 1.02, color: color)),
          ),
        ),
        if (caption != null) ...[const SizedBox(height: 2), caption!],
      ]),
    );
  }
}
