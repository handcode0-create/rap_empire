import 'package:flutter/material.dart';
import '../theme/neon_tokens.dart';
import '../theme/tokens.dart';

/// Accent d'une carte de verre : [magenta] (action), [gold] (ce qui rapporte), [cyan] (énergie). Un seul accent fort par écran.
enum GlassAccent { none, magenta, gold, cyan }

/// Carte « verre fumé » de la direction Néon de Bakoma : fond #1F1942 à 85 %, bord 1 px blanc à 10 %, rayon 20.
/// Avec un [accent], le bord prend la couleur de l'accent et un halo est peint dessous. [onTap] : zone touchable d'au moins 48 px.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final GlassAccent accent;
  final VoidCallback? onTap;

  /// Libellé lu par les lecteurs d'écran quand la carte est touchable.
  final String? semanticLabel;

  /// Peint le halo de l'accent (un seul halo fort par écran) ; sans halo, seul le liseré coloré reste.
  final bool halo;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.accent = GlassAccent.none, this.onTap, this.semanticLabel, this.halo = true});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final (glow, rim) = switch (accent) {
      GlassAccent.none => (null, t.glassBorder),
      GlassAccent.magenta => (t.glowMagenta, Tk.acc4),
      GlassAccent.gold => (t.glowGold, Tk.gold),
      GlassAccent.cyan => (t.glowCyan, Tk.cy),
    };
    final radius = BorderRadius.circular(t.rGlass);
    final content = onTap == null
        ? Padding(padding: padding, child: child)
        : InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(constraints: const BoxConstraints(minHeight: Tk.minTap), child: Padding(padding: padding, child: child)),
          );
    final card = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: glow == null || !halo ? t.cardShadow : t.halo(glow)),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(color: t.glassFill, borderRadius: radius, border: Border.all(color: rim, width: glow == null ? 1 : 1.5)),
          child: content,
        ),
      ),
    );
    return onTap == null ? card : Semantics(button: true, label: semanticLabel, child: card);
  }
}
