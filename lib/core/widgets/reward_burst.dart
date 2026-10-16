import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neon_tokens.dart';
import '../theme/tokens.dart';

/// Éclat de victoire : filigrane de vinyle (toujours présent, discret) et particules qui jaillissent une fois (1,6 s).
/// À n'utiliser que sur de vraies victoires (première sortie, niveau gagné). [haptic] déclenche un retour léger à l'ouverture.
/// Sans animation si le système la désactive : seul le filigrane reste. Ne capte aucun toucher.
class RewardBurst extends StatefulWidget {
  final bool haptic;
  final double height;
  const RewardBurst({super.key, this.haptic = true, this.height = 260});

  @override
  State<RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<RewardBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.value = 1;
      return;
    }
    if (widget.haptic) HapticFeedback.lightImpact();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(painter: _BurstPainter(_c.value, t.enter.transform(_c.value)))),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double raw, eased;
  _BurstPainter(this.raw, this.eased);

  static const _colors = [Tk.gold, Tk.acc4, Tk.cy, Tk.gold];

  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height * .36);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color.fromRGBO(255, 255, 255, .06);
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(c, 26.0 * i + 10, ring);
    }
    canvas.drawCircle(c, 12, Paint()..color = const Color.fromRGBO(255, 200, 61, .10));
    if (raw >= 1) return;
    final rnd = Random(7);
    final fade = (1 - raw).clamp(0.0, 1.0);
    for (var i = 0; i < 36; i++) {
      final a = rnd.nextDouble() * 2 * pi;
      final speed = 70 + rnd.nextDouble() * 120;
      final p = c + Offset(cos(a), sin(a)) * speed * eased + Offset(0, 40 * raw * raw);
      final paint = Paint()..color = _colors[i % _colors.length].withValues(alpha: .9 * fade);
      if (i.isEven) {
        canvas.drawCircle(p, 2 + rnd.nextDouble() * 2.5, paint);
      } else {
        final d = Offset(cos(a), sin(a)) * 7;
        canvas.drawLine(p, p + d, paint
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round);
      }
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.raw != raw;
}
