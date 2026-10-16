import 'package:flutter/material.dart';
import '../theme/neon_tokens.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';

/// Bouton principal de la direction Néon de Bakoma : pilule 56 px, dégradé rose → lilas de la v20, encre #14102B (jamais de blanc sur magenta),
/// halo magenta dessous. Un seul par écran. Au toucher, le bouton se comprime (150 ms) : retour immédiat. Désactivé si [onPressed] est null.
class PrimaryGlowButton extends StatefulWidget {
  final String label;
  final String? sublabel;
  final VoidCallback? onPressed;
  final bool arrow;
  const PrimaryGlowButton({super.key, required this.label, this.sublabel, required this.onPressed, this.arrow = true});

  @override
  State<PrimaryGlowButton> createState() => _PrimaryGlowButtonState();
}

class _PrimaryGlowButtonState extends State<PrimaryGlowButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final off = widget.onPressed == null;
    final fg = off ? Tk.dis : Tk.bg;
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final radius = BorderRadius.circular(999);
    return Semantics(
      button: true,
      enabled: !off,
      label: widget.sublabel == null ? widget.label : '${widget.label}, ${widget.sublabel}',
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _down && !still ? .97 : 1,
        duration: t.fast,
        curve: t.enter,
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: radius, boxShadow: off ? null : t.halo(t.glowMagenta)),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(gradient: off ? null : V20.pill, color: off ? Tk.s2 : null, borderRadius: radius),
              child: InkWell(
                onTap: widget.onPressed,
                onHighlightChanged: (v) => setState(() => _down = v),
                borderRadius: radius,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Tk.btnH),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(children: [
                      Expanded(
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.label.toUpperCase(), style: V20Text.btt.copyWith(color: fg)),
                          if (widget.sublabel != null) Text(widget.sublabel!.toUpperCase(), style: V20Text.lab(color: fg)),
                        ]),
                      ),
                      if (widget.arrow) ...[const SizedBox(width: 8), GameIcon('arrow', color: fg)],
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
