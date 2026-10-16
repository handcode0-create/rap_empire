import 'package:flutter/material.dart';
import '../../domain/rules.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';

/// Nature d'un coût : cauris (or, icône cauri), énergie (cyan, éclair), temps (encre, horloge, en heures).
enum CostKind { cauris, energy, time }

/// Icône cauri : coquille stylisée dessinée en vecteur (la bibliothèque d'icônes n'a pas de symbole pour la monnaie du jeu).
class CauriIcon extends StatelessWidget {
  final double size;
  final Color color;
  const CauriIcon({super.key, this.size = 18, this.color = Tk.gold});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(size: Size(size, size * .8), painter: _CauriPainter(color)));
}

class _CauriPainter extends CustomPainter {
  final Color color;
  _CauriPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawOval(Rect.fromLTWH(0, 0, s.width, s.height), Paint()..color = color);
    final slit = Paint()
      ..color = Tk.bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.height * .14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width * .22, s.height * .5), Offset(s.width * .78, s.height * .5), slit);
    final tooth = Paint()
      ..color = Tk.bg.withValues(alpha: .75)
      ..strokeWidth = s.height * .08
      ..strokeCap = StrokeCap.round;
    for (final x in [.36, .5, .64]) {
      canvas.drawLine(Offset(s.width * x, s.height * .36), Offset(s.width * x, s.height * .64), tooth);
    }
  }

  @override
  bool shouldRepaint(_CauriPainter old) => old.color != color;
}

/// Ligne de coût : « Prix · −8 000 [cauri] ». Tout prix est en or avec l'icône cauri ; [balanceAfter] ajoute « Solde après » avant de confirmer
/// (en rose clair avec « Cash insuffisant » si le solde serait négatif). [gain] affiche « + » au lieu de « − ».
class CostRow extends StatelessWidget {
  final CostKind kind;
  final String label;
  final int amount;
  final bool gain;
  final int? balanceAfter;
  const CostRow({super.key, required this.kind, required this.label, required this.amount, this.gain = false, this.balanceAfter});

  @override
  Widget build(BuildContext context) {
    final sign = gain ? '+' : '−';
    final (color, text, Widget icon) = switch (kind) {
      CostKind.cauris => (Tk.gold, '$sign${fmt(amount)}', const CauriIcon()),
      CostKind.energy => (Tk.cy, '$sign$amount', const GameIcon('zap', size: 16, color: Tk.cy)),
      CostKind.time => (Tk.ink, '$amount h', const GameIcon('clock', size: 16, color: Tk.ink)),
    };
    final short = balanceAfter != null && balanceAfter! < 0;
    return Semantics(
      label: '$label ${kind == CostKind.cauris ? '$text cauris' : text}${balanceAfter == null ? '' : ', solde après ${fmt(balanceAfter!)}'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(label, style: V20Text.bs())),
            const SizedBox(width: 8),
            Text(text, style: V20Text.nm(color: color)),
            const SizedBox(width: 6),
            icon,
          ]),
          if (balanceAfter != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  short ? 'Cash insuffisant · solde ${fmt(balanceAfter!)}' : 'Solde après : ${fmt(balanceAfter!)}',
                  style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w600, color: short ? V20.riskText : V20.ink2),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
