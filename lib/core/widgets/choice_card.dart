import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Nature d'une conséquence : Certain (coût ou effet fixe), Estimé (calculé par une règle), Incertain (dépend d'un tiers ou de l'état), Risque.
enum ConsequenceKind { certain, estimated, uncertain, risk }

/// Étiquette de conséquence (.cq de v20.css) : 10/13 700, pilule. Jamais de pourcentage de réussite isolé.
class ConsequenceTag extends StatelessWidget {
  final ConsequenceKind kind;
  final String? label;
  const ConsequenceTag(this.kind, {super.key, this.label});

  String get _label => label ??
      switch (kind) {
        ConsequenceKind.certain => 'Certain',
        ConsequenceKind.estimated => 'Estimé',
        ConsequenceKind.uncertain => 'Incertain',
        ConsequenceKind.risk => 'Risque',
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, dashed) = switch (kind) {
      ConsequenceKind.certain => (const Color.fromRGBO(61, 220, 151, .18), V20.okText, null, false),
      ConsequenceKind.estimated => (null, V20.ink2, Tk.ink2, false),
      ConsequenceKind.uncertain => (null, V20.ink2, Tk.ink2, true),
      ConsequenceKind.risk => (const Color.fromRGBO(244, 63, 157, .22), V20.riskText, null, false),
    };
    final text = Text(_label, textAlign: TextAlign.center, maxLines: 1, style: V20Text.poppins(size: 10, line: 13, weight: FontWeight.w700, color: fg, spacing: .3));
    const pad = EdgeInsets.symmetric(horizontal: 7, vertical: 2);
    if (dashed) {
      return CustomPaint(painter: _DashedPill(Tk.ink2), child: Padding(padding: pad, child: text));
    }
    return Container(
      padding: pad,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99), border: border == null ? null : Border.all(color: border, width: 1.5)),
      child: text,
    );
  }
}

class _DashedPill extends CustomPainter {
  final Color color;
  _DashedPill(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2));
    final path = Path()..addRRect(rrect);
    for (final PathMetric m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 6) {
        canvas.drawPath(m.extractPath(d, (d + 3).clamp(0, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPill old) => old.color != color;
}

/// Une conséquence : étiquette + texte.
class Consequence {
  final ConsequenceKind kind;
  final String text;
  const Consequence(this.kind, this.text);
}

/// Carte de choix à conséquences (a.cx de v20.css) : titre Baloo 15 et lignes Certain / Estimé / Incertain / Risque.
/// [selected] : bordure magenta et fond teinté ; [locked] : grisée avec sa condition.
class ChoiceCard extends StatelessWidget {
  final String title;
  final List<Consequence> consequences;
  final bool selected, locked;
  final VoidCallback? onTap;
  const ChoiceCard({super.key, required this.title, this.consequences = const [], this.selected = false, this.locked = false, this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        enabled: !locked,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: selected ? V20.surfaceSelected : V20.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: selected ? Tk.acc4 : const Color.fromRGBO(255, 255, 255, .12), width: 2),
            ),
            child: InkWell(
              onTap: locked ? null : onTap,
              borderRadius: BorderRadius.circular(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Tk.minTap),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: V20Text.baloo(size: 15, line: 20, color: locked ? Tk.dis : Tk.ink)),
                    for (final c in consequences)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(width: 62, child: Center(child: ConsequenceTag(c.kind))),
                          const SizedBox(width: 6),
                          Expanded(child: Text(c.text, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2))),
                        ]),
                      ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
