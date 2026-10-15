import 'package:flutter/material.dart';
import '../theme/v20.dart';

/// Bandeau d'information (.hint de v20.css) : cyan par défaut, or avec [warn]. 12/16, rayon 14, bordure 1,5 px.
class GameHint extends StatelessWidget {
  final String icon, text;
  final bool warn;
  final VoidCallback? onTap;
  const GameHint({super.key, required this.icon, required this.text, this.warn = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = warn
        ? (const Color.fromRGBO(255, 200, 61, .08), const Color.fromRGBO(255, 200, 61, .3), V20.hintGoldText)
        : (const Color.fromRGBO(60, 214, 242, .08), const Color.fromRGBO(60, 214, 242, .28), V20.hintCyanText);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 1.5)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: onTap == null ? 0 : 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(icon, style: V20Text.poppins(size: 12, line: 16, color: fg)),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: V20Text.poppins(size: 12, line: 16, color: fg))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
