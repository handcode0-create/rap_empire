import 'package:flutter/material.dart';

/// Entrée animée d'un bloc : fondu + glissement, décalé par [index] (90 ms par rang). Animation finie, jamais en boucle.
/// Le contenu est dans l'arbre dès la première image (tests, lecteurs d'écran). Sans animation si le système la désactive.
class EnterAnim extends StatelessWidget {
  final Widget child;
  final int index;
  final Offset from;
  final int baseMs;
  const EnterAnim({super.key, required this.child, this.index = 0, this.from = const Offset(0, 16), this.baseMs = 320});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: baseMs + 90 * index),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) {
        // Le décalage par rang : les premiers blocs finissent avant les suivants.
        final p = index == 0 ? v : Curves.easeOutCubic.transform(((v * (baseMs + 90 * index) - 90 * index) / baseMs).clamp(0.0, 1.0));
        return Opacity(opacity: p, child: Transform.translate(offset: Offset(from.dx * (1 - p), from.dy * (1 - p)), child: c));
      },
      child: child,
    );
  }
}
