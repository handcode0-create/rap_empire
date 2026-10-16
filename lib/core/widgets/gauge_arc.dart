import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/neon_tokens.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Jauge en arc (270°) : piste blanche à 10 %, arc de couleur qui se remplit à l'affichage (350 ms), valeur ou texte au centre.
/// [value] entre 0 et 1. Une valeur non nulle laisse toujours un trait visible. Le pourcentage est lu par les lecteurs d'écran.
class GaugeArc extends StatelessWidget {
  final double value;
  final String label;
  final String? centerText;
  final Color color;
  final double size, stroke;
  const GaugeArc({super.key, required this.value, required this.label, this.centerText, this.color = Tk.cy, this.size = 104, this.stroke = 10});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: label,
      value: '${(v * 100).round()} %',
      excludeSemantics: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: still ? v : 0, end: v),
            duration: still ? Duration.zero : t.slow,
            curve: t.enter,
            builder: (_, p, __) => CustomPaint(
              painter: _ArcPainter(p, color, stroke),
              child: Center(child: Text(centerText ?? '${(v * 100).round()} %', maxLines: 1, style: V20Text.baloo(size: size * .22, line: size * .24))),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress, stroke;
  final Color color;
  _ArcPainter(this.progress, this.color, this.stroke);

  static const _start = 3 * pi / 4, _sweep = 3 * pi / 2;

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromCircle(center: s.center(Offset.zero), radius: (min(s.width, s.height) - stroke) / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color.fromRGBO(255, 255, 255, .10);
    canvas.drawArc(rect, _start, _sweep, false, track);
    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, _start, max(.04, _sweep * progress), false, arc);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.color != color || old.stroke != stroke;
}
