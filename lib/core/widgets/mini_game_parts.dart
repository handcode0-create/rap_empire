import 'package:flutter/material.dart';
import '../../domain/minigame.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Piste du mini-jeu (.mg-track de v20.css) : zone verte de 16 % centrée sur [zone] (0 à 1) et curseur blanc à la position [cursor] (0 à 1).
class MiniGameTrack extends StatelessWidget {
  final double cursor, zone;
  const MiniGameTrack({super.key, required this.cursor, required this.zone});

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [V20.hudCellBottom, Tk.bg]),
          border: Border.all(color: Tk.line, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              return Stack(children: [
                Positioned(
                  left: (zone - zoneHalfWidth) * w,
                  top: 0,
                  bottom: 0,
                  width: zoneHalfWidth * 2 * w,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromRGBO(61, 220, 151, .55), Color.fromRGBO(61, 220, 151, .25)]),
                      border: Border.symmetric(vertical: BorderSide(color: Tk.ok, width: 2)),
                    ),
                  ),
                ),
                Positioned(
                  left: cursor * w - 3,
                  top: 4,
                  bottom: 4,
                  width: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3), boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 14)]),
                  ),
                ),
              ]);
            },
          ),
        ),
      );
}

/// Bouton REC (.rec2 de v20.css) : disque de 104 px, dégradé rose, bordure blanche 4 px, halo.
class RecButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const RecButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'REC',
        enabled: onPressed != null,
        child: Opacity(
          opacity: onPressed == null ? .5 : 1,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 104,
              height: 104,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(center: Alignment(-.3, -.4), radius: 1, colors: [Tk.acc4, Tk.acc, Tk.acc7], stops: [0, .55, 1]),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(color: Color.fromRGBO(244, 63, 157, .22), spreadRadius: 8),
                  BoxShadow(color: Color.fromRGBO(244, 63, 157, .45), blurRadius: 30, offset: Offset(0, 14)),
                ],
              ),
              child: Text('REC', style: V20Text.baloo(size: 22, line: 22, color: Colors.white)),
            ),
          ),
        ),
      );
}

/// Pastille d'une prise (.mg-takes de v20.css) : « Prise 1 », puis « Prise 1 · 87 » une fois faite (fond vert).
class TakeChip extends StatelessWidget {
  final String text;
  final bool done;
  const TakeChip(this.text, {super.key, this.done = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: done ? const Color.fromRGBO(61, 220, 151, .18) : const Color.fromRGBO(255, 255, 255, .07)),
        child: Text(text.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w800, color: done ? V20.okText : V20.ink2)),
      );
}
