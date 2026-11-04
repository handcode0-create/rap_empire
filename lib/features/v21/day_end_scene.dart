import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../domain/v21/reg21.dart';
import 'widgets21.dart';

num _n(dynamic v) => v is num ? v : 0;

/// Scène de fin de journée : le soleil se couche sur Ndolo, la ville s'allume, la nuit passe, l'aube se lève.
/// La journée est réellement terminée (action `endDay`) à la moitié de la scène, puis le bilan s'ouvre.
class FinJourneeScreen extends ConsumerStatefulWidget {
  const FinJourneeScreen({super.key});
  @override
  ConsumerState<FinJourneeScreen> createState() => _FinJourneeState();
}

class _FinJourneeState extends ConsumerState<FinJourneeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 6200));
  late final int _day0 = _n(ref.read(game21Provider).valueOrNull?['day']).toInt();
  late final int _hour0 = _n(ref.read(game21Provider).valueOrNull?['hour']).toInt();
  Future<String?>? _end;

  /// Part de la scène à laquelle la journée est conclue dans le moteur.
  static const _cut = .55;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (_end == null && _c.value >= _cut) _end = ref.read(game21Provider.notifier).act('endDay');
      setState(() {});
    });
    _c.addStatusListener((st) {
      if (st == AnimationStatus.completed) _finish();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) _c.duration = const Duration(milliseconds: 500);
      _c.forward();
    });
  }

  Future<void> _finish() async {
    _end ??= ref.read(game21Provider.notifier).act('endDay');
    final e = await _end;
    if (!mounted) return;
    if (e != null) {
      toastErr(context, e);
      context.go('/');
    } else {
      context.go('/bilan');
    }
  }

  void _skip() {
    if (_c.isAnimating) _c.animateTo(1, duration: const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _caption(double t) {
    if (t < .2) return 'Le soleil se couche sur Ndolo';
    if (t < .4) return 'Les lumières de la ville s’allument';
    if (t < .6) return 'Tu rentres, la tête pleine de rimes';
    if (t < .8) return 'Nuit calme sur Bakoma…';
    return 'Le quartier se réveille';
  }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    final s = ref.watch(game21Provider).valueOrNull;
    final day = (_end != null && s != null) ? _n(s['day']).toInt() : _day0;
    final String clock;
    if (t < _cut) {
      final h = (_hour0 + (24 - _hour0) * math.min(1, t / .4)).floor().clamp(0, 24);
      clock = 'JOUR $_day0 · ${h.toString().padLeft(2, '0')}:00';
    } else {
      clock = 'JOUR $day · 0${Reg21.dayStart}:00';
    }
    return Scaffold(
      backgroundColor: Tk.deep,
      body: Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _NightPainter(t)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  key: const ValueKey('fin-passer'),
                  style: TextButton.styleFrom(minimumSize: const Size(Tk.minTap + 16, Tk.minTap), foregroundColor: Tk.ink2),
                  onPressed: _skip,
                  child: Text('PASSER', style: V20Text.lab()),
                ),
              ),
              const Spacer(),
              Semantics(
                liveRegion: true,
                child: Column(children: [
                  Text('FIN DE JOURNÉE', style: V20Text.lab(color: Tk.gold)),
                  const SizedBox(height: 4),
                  Text(clock, style: V20Text.baloo(size: 40, line: 42, color: Tk.ink)),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(_caption(t), key: ValueKey(_caption(t)), textAlign: TextAlign.center, style: V20Text.bm),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ]),
    );
  }
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t.clamp(0.0, 1.0))!;

/// Ciel, astres et skyline de Ndolo : du crépuscule à la nuit (0 à 0,6) puis à l'aube (0,6 à 1).
class _NightPainter extends CustomPainter {
  final double t;
  _NightPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // ciel
    final Color top, bottom;
    if (t < .6) {
      final k = t / .6;
      top = _mix(const Color(0xFF3A1B52), Tk.deep, k);
      bottom = _mix(const Color(0xFFF43F9D), Tk.bg, k);
    } else {
      final k = (t - .6) / .4;
      top = _mix(Tk.deep, const Color(0xFF2B2459), k);
      bottom = _mix(Tk.bg, const Color(0xFFFFC83D), k * .75);
    }
    canvas.drawRect(Offset.zero & size,
        Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]).createShader(Offset.zero & size));
    // étoiles
    final rnd = math.Random(41);
    final night = t < .6 ? math.max(0.0, (t - .15) / .45) : math.max(0.0, 1 - (t - .6) / .3);
    for (var i = 0; i < 46; i++) {
      final x = rnd.nextDouble() * w, y = rnd.nextDouble() * h * .5, r = .6 + rnd.nextDouble() * 1.3;
      final tw = .6 + .4 * math.sin(t * 24 + i);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = Tk.ink.withValues(alpha: (night * tw).clamp(0.0, 1.0)));
    }
    // soleil couchant puis aube
    final sunY = t < .6 ? h * (.42 + .38 * (t / .6)) : h * (.8 - .3 * ((t - .6) / .4));
    final sunA = t < .6 ? 1 - t / .6 : (t - .6) / .4;
    canvas.drawCircle(Offset(w * .72, sunY), 34, Paint()..color = Tk.gold.withValues(alpha: (sunA * .9).clamp(0.0, 1.0)));
    // lune
    final moonA = t < .6 ? math.min(1.0, t / .35) : math.max(0.0, 1 - (t - .6) / .25);
    final moonY = h * (.32 - .1 * math.min(1.0, t / .6));
    canvas.drawCircle(Offset(w * .25, moonY), 26, Paint()..color = Tk.ink.withValues(alpha: .92 * moonA));
    canvas.drawCircle(Offset(w * .25 + 10, moonY - 5), 24, Paint()..color = top.withValues(alpha: moonA));
    // skyline
    final base = h * .78;
    final b = math.Random(7);
    var x = -10.0, i = 0;
    final lit = t < .6 ? t / .5 : math.max(0.0, 1 - (t - .6) / .3);
    while (x < w) {
      final bw = 30 + b.nextDouble() * 42, bh = 70 + b.nextDouble() * 150;
      canvas.drawRect(Rect.fromLTWH(x, base - bh, bw, h - base + bh), Paint()..color = const Color(0xFF0C0820));
      for (var wy = base - bh + 10; wy < base - 8; wy += 16) {
        for (var wx = x + 6; wx < x + bw - 8; wx += 12) {
          final on = ((i * 31 + wx.toInt() * 7 + wy.toInt() * 13) % 100) / 100 < lit.clamp(0.0, 1.0) * .7;
          if (on) canvas.drawRect(Rect.fromLTWH(wx, wy, 5, 7), Paint()..color = Tk.gold.withValues(alpha: .85));
        }
      }
      x += bw + 3;
      i++;
    }
    canvas.drawRect(Rect.fromLTWH(0, base + 60, w, h), Paint()..color = const Color(0xFF0C0820));
  }

  @override
  bool shouldRepaint(_NightPainter old) => old.t != t;
}
