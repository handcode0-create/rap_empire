import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/primary_button.dart';

/// Mini-jeu de Flow d'une battle : un curseur va et vient sur la mesure, le joueur le fige dans la zone verte.
/// La zone s'élargit avec le Flow ([zone], part de la piste). Aucune animation ne tourne tant que le jeu n'est pas lancé.
class FlowMiniGame21 extends StatefulWidget {
  /// Largeur de la zone, part de la piste (0 à 1) ; [center] : milieu de la zone (0 à 1).
  final double zone, center;
  final void Function(bool hit) onDone;
  const FlowMiniGame21({super.key, required this.zone, required this.center, required this.onDone});
  @override
  State<FlowMiniGame21> createState() => _FlowMiniGame21State();
}

class _FlowMiniGame21State extends State<FlowMiniGame21> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  bool _running = false;
  bool? _hit;
  double? _stopped;

  double get _lo => (widget.center - widget.zone / 2).clamp(0.0, 1.0 - widget.zone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _hit = null;
    });
    _c.repeat(reverse: true);
  }

  void _stop() {
    final v = _c.value;
    _c.stop();
    final hit = v >= _lo && v <= _lo + widget.zone;
    setState(() {
      _running = false;
      _hit = hit;
      _stopped = v;
    });
    widget.onDone(hit);
  }

  @override
  Widget build(BuildContext context) {
    final played = _hit != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final pos = _running ? _c.value : (_stopped ?? 0);
            return SizedBox(
              height: 44,
              child: Stack(clipBehavior: Clip.none, children: [
                Positioned.fill(
                  child: DecoratedBox(decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(14), border: Border.all(color: Tk.line, width: 2))),
                ),
                Positioned(
                  left: _lo * w,
                  width: widget.zone * w,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(decoration: BoxDecoration(color: const Color(0x553DDC97), borderRadius: BorderRadius.circular(12), border: Border.all(color: Tk.ok, width: 2))),
                ),
                if (_running || played)
                  Positioned(
                    left: (pos * (w - 6)),
                    top: -4,
                    bottom: -4,
                    width: 6,
                    child: DecoratedBox(decoration: BoxDecoration(color: played ? (_hit! ? Tk.ok : Tk.acc) : Colors.white, borderRadius: BorderRadius.circular(99))),
                  ),
              ]),
            );
          },
        );
      }),
      const SizedBox(height: 10),
      if (!played)
        PrimaryButton(
          label: _running ? 'Fige le flow' : 'Écouter le flow',
          sublabel: _running ? 'Touche quand le curseur est dans la zone verte' : 'Mini-jeu · une tentative par round',
          compact: true,
          style: _running ? GameButtonStyle.primary : GameButtonStyle.secondary,
          onPressed: _running ? _stop : _start,
        ),
    ]);
  }
}
