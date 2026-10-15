import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Portrait monogramme : initiales Baloo magenta sur dégradé violet sombre. Pour tout personnage ou artiste sans illustration définitive.
/// Jamais le visage d'un autre personnage.
class Portrait extends StatelessWidget {
  final String initials;
  final double size;
  final double? radius;
  const Portrait(this.initials, {super.key, this.size = 40, this.radius});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Portrait $initials',
        excludeSemantics: true,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Tk.tint, Tk.s2]),
            borderRadius: BorderRadius.circular(radius ?? size * .25),
            border: Border.all(color: V20.bannerBorder, width: 1.5),
          ),
          child: Text(initials.toUpperCase(), style: V20Text.baloo(size: size * .45, line: size * .5, color: Tk.acc)),
        ),
      );
}
