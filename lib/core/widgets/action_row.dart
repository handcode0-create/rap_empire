import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';

/// Ligne d'action (.act de v20.css) : rayon 16, bordure 2 px, surface dégradée ; icône dégradée facultative à gauche (36 px dans 44),
/// titre Baloo 18, sous-titre 13, élément à droite (prix, flèche, étiquette).
/// [disabled] : état indisponible (.act.ins), texte grisé ; [note] affiche alors le motif sous le sous-titre.
class ActionRow extends StatelessWidget {
  final String? icon;
  final String title, subtitle;
  final String? note;
  final Widget? trailing;
  final bool disabled;
  final VoidCallback? onTap;
  const ActionRow({super.key, this.icon, required this.title, required this.subtitle, this.note, this.trailing, this.disabled = false, this.onTap});

  /// Flèche standard des lignes de formation.
  static Widget arrow({bool disabled = false}) => GameIcon('arrow', color: disabled ? Tk.dis : Tk.ink);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Tk.rCard);
    return Semantics(
      button: true,
      enabled: !disabled && onTap != null,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: V20.cardShadow),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: V20.surface, borderRadius: radius, border: Border.all(color: V20.cardBorder, width: 2)),
            child: InkWell(
              onTap: disabled ? null : onTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  if (icon != null) ...[
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(gradient: disabled ? null : V20.tileIcon, color: disabled ? Tk.s2 : null, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: GameIcon(icon!, color: disabled ? V20.lockedIcon : Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(title, style: V20Text.nm(color: disabled ? Tk.dis : Tk.ink)),
                      Text(subtitle, style: V20Text.bs(color: disabled ? Tk.dis : V20.ink2)),
                      if (note != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(note!, style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w600, color: V20.accText))),
                    ]),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 12), trailing!],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
