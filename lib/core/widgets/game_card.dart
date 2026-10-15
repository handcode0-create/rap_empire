import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

const _selectedGlow = [
  BoxShadow(color: Color.fromRGBO(255, 107, 184, .5), spreadRadius: 1),
  BoxShadow(color: Color.fromRGBO(244, 63, 157, .28), blurRadius: 28, offset: Offset(0, 10)),
];

/// Trait pointillé autour d'un rectangle arrondi (border-style: dashed).
class _DashedRRect extends CustomPainter {
  final Color color;
  final double radius, stroke;
  _DashedRRect(this.color, this.radius, this.stroke);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(stroke / 2));
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 8) {
        canvas.drawPath(m.extractPath(d, (d + 4).clamp(0, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect old) => old.color != color || old.radius != radius;
}

/// Carte (.card de rap.css et v20.css) : rayon 16, bordure 2 px, surface dégradée ; [selected] : bordure rose, fond teinté, halo ;
/// [dashed] : emplacement libre en pointillés.
class GameCard extends StatelessWidget {
  final Widget child;
  final bool selected, dashed;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const GameCard({super.key, required this.child, this.selected = false, this.dashed = false, this.padding = const EdgeInsets.all(16), this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Tk.rCard);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: selected ? _selectedGlow : V20.cardShadow),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected ? V20.surfaceSelected : V20.surface,
            borderRadius: radius,
            border: dashed ? null : Border.all(color: selected ? Tk.acc4 : V20.cardBorder, width: 2),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: CustomPaint(
              foregroundPainter: dashed ? _DashedRRect(const Color.fromRGBO(255, 255, 255, .3), Tk.rCard, 2) : null,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ligne de choix (.beat de v20.css) : pochette facultative, titre Baloo 18, sous-titre, étiquettes ou prix à droite.
/// [selected] : bordure rose ; [locked] : atténuée (78 %), texte grisé, condition affichée à droite par l'appelant.
class BeatCard extends StatelessWidget {
  final Widget? leading;
  final String title, subtitle;
  final Widget trailing;
  final bool selected, locked;
  final VoidCallback? onTap;
  const BeatCard({super.key, this.leading, required this.title, required this.subtitle, required this.trailing, this.selected = false, this.locked = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Semantics(
      button: true,
      selected: selected,
      child: Opacity(
        opacity: locked ? .78 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: radius, boxShadow: selected ? _selectedGlow : V20.cardShadow),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: selected ? V20.surfaceSelected : V20.surface,
                borderRadius: radius,
                border: Border.all(color: selected ? Tk.acc4 : V20.cardBorder, width: 2),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Tk.minTap),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      if (leading != null) ...[leading!, const SizedBox(width: 12)],
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          Text(title, style: V20Text.nm(color: locked ? Tk.dis : Tk.ink)),
                          Text(subtitle, style: V20Text.bs(color: locked ? Tk.dis : V20.ink2)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      trailing,
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
