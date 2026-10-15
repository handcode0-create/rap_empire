import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Fond d'écran v20 : #14102B avec deux halos (magenta en haut à droite, violet en bas à gauche), comme .scr de v20.css.
class ScreenBackground extends StatelessWidget {
  final Widget child;
  const ScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        const ColoredBox(color: Tk.bg),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(center: Alignment(1.1, -1.1), radius: 1.2, colors: [Color.fromRGBO(244, 63, 157, .20), Color.fromRGBO(244, 63, 157, 0)], stops: [0, .58]),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(center: Alignment(-1.2, 1.1), radius: 1.08, colors: [Color.fromRGBO(139, 92, 246, .22), Color.fromRGBO(139, 92, 246, 0)], stops: [0, .60]),
          ),
        ),
        child,
      ]);
}
