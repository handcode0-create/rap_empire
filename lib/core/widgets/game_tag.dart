import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

enum GameTagStyle { normal, accent, outline, ok }

/// Étiquette pilule (.tag de rap.css) : 11/14 700 majuscules +8 %.
class GameTag extends StatelessWidget {
  final String text;
  final GameTagStyle style;
  final Color? color, borderColor;
  const GameTag(this.text, {super.key, this.style = GameTagStyle.normal, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      GameTagStyle.normal => (Tk.s2, V20.ink2, null),
      GameTagStyle.accent => (V20.pinkBtn, Tk.bg, null),
      GameTagStyle.outline => (null, color ?? V20.ink2, borderColor ?? color ?? V20.ink2),
      GameTagStyle.ok => (Tk.ok, Tk.bg, null),
    };
    final outlined = style == GameTagStyle.outline;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: outlined ? 2 : 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), border: border == null ? null : Border.all(color: border, width: 2)),
      child: Text(text.toUpperCase(), maxLines: 1, style: V20Text.lab(color: fg)),
    );
  }
}
