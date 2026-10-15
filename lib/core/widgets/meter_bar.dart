import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Teintes de .meter (v20.css) : brand (défaut), ok, cy, gd.
enum MeterTone { brand, ok, cyan, gold }

/// Jauge .meter de 10 px (fond blanc 10 %, remplissage dégradé) ou, avec [thin], barre .bar de 6 px (fond line, remplissage accent) du HUD.
class MeterBar extends StatelessWidget {
  final double value;
  final MeterTone tone;
  final bool thin;
  const MeterBar({super.key, required this.value, this.tone = MeterTone.brand, this.thin = false});

  LinearGradient get _fill => switch (tone) {
        MeterTone.brand => const LinearGradient(colors: [Tk.acc, Tk.violet]),
        MeterTone.ok => const LinearGradient(colors: [Tk.ok, Tk.cy]),
        MeterTone.cyan => const LinearGradient(colors: [Tk.cy, Tk.violet]),
        MeterTone.gold => const LinearGradient(colors: [Tk.gold, Tk.acc4]),
      };

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final animate = !MediaQuery.of(context).disableAnimations;
    return Semantics(
      value: '${(v * 100).round()} %',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: thin ? 6 : 10,
          color: thin ? Tk.line : const Color.fromRGBO(255, 255, 255, .1),
          alignment: Alignment.centerLeft,
          child: LayoutBuilder(
            builder: (context, c) => AnimatedContainer(
              duration: animate ? const Duration(milliseconds: 500) : Duration.zero,
              width: c.maxWidth * v,
              decoration: BoxDecoration(color: thin ? Tk.acc : null, gradient: thin ? null : _fill, borderRadius: BorderRadius.circular(999)),
            ),
          ),
        ),
      ),
    );
  }
}
