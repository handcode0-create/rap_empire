import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';

/// Variantes du bouton pilule de rap.css : p (principal, dégradé), s (contour), g (fantôme), d (sombre, sur carte objectif), x (indisponible).
enum GameButtonStyle { primary, secondary, ghost, dark, disabled }

/// Bouton pilule 56 px (48 en version compacte), texte Poppins 800 en majuscules, flèche à droite (.btn de rap.css, v20.css).
class PrimaryButton extends StatelessWidget {
  final String label;
  final String? sublabel;
  final VoidCallback? onPressed;
  final GameButtonStyle style;
  final bool arrow, centered, compact;
  const PrimaryButton({
    super.key,
    required this.label,
    this.sublabel,
    required this.onPressed,
    this.style = GameButtonStyle.primary,
    this.arrow = true,
    this.centered = false,
    this.compact = false,
  });

  bool get _off => onPressed == null || style == GameButtonStyle.disabled;

  Color get _fg => switch (style) {
        GameButtonStyle.primary => Tk.bg,
        GameButtonStyle.secondary => Tk.ink,
        GameButtonStyle.ghost => V20.accText,
        GameButtonStyle.dark => Colors.white,
        GameButtonStyle.disabled => Tk.dis,
      };

  @override
  Widget build(BuildContext context) {
    final fg = _off && style != GameButtonStyle.disabled ? Tk.dis : _fg;
    final radius = BorderRadius.circular(999);
    final deco = switch (style) {
      GameButtonStyle.primary => BoxDecoration(
          gradient: V20.pill,
          borderRadius: radius,
          border: Border.all(color: Colors.transparent, width: 2)),
      GameButtonStyle.secondary => BoxDecoration(
          borderRadius: radius, border: Border.all(color: Tk.ink, width: 2)),
      GameButtonStyle.ghost => BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: Colors.transparent, width: 2)),
      GameButtonStyle.dark => BoxDecoration(
          color: Tk.bg,
          borderRadius: radius,
          border: Border.all(color: Tk.bg, width: 2)),
      GameButtonStyle.disabled => BoxDecoration(
          color: Tk.s2,
          borderRadius: radius,
          border: Border.all(color: Colors.transparent, width: 2)),
    };
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style:
                V20Text.btt.copyWith(color: fg, fontSize: compact ? 13 : 15)),
        if (sublabel != null)
          Opacity(
              opacity: .85,
              child:
                  Text(sublabel!.toUpperCase(), style: V20Text.lab(color: fg))),
      ],
    );
    return Semantics(
      button: true,
      enabled: !_off,
      // L'ombre est peinte hors du Material, sinon elle est coupée au rectangle du bouton.
      child: DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: style == GameButtonStyle.primary && !_off
                ? V20.buttonShadow
                : null),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: deco,
            child: InkWell(
              onTap: _off ? null : onPressed,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: compact ? Tk.minTap : Tk.btnH),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20),
                  child: Row(
                    mainAxisAlignment: centered
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      if (centered)
                        Flexible(child: text)
                      else
                        Expanded(child: text),
                      if (arrow && !centered) ...[
                        const SizedBox(width: 8),
                        GameIcon('arrow', color: fg)
                      ],
                    ],
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
