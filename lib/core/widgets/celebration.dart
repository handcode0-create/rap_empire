import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Rayonnement doré des écrans de célébration (.burst de v20.css, assets/scenes/burst.svg), ancré en haut de l'écran.
class Burst extends StatelessWidget {
  const Burst({super.key});
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(height: 300, width: double.infinity, child: SvgPicture.asset('assets/scenes/burst.svg', fit: BoxFit.cover, alignment: Alignment.topCenter)),
        ),
      );
}

/// Badge de niveau (.lvbadge de v20.css) : disque doré de 132 px, « N2 » en Baloo 64, halo.
class LevelBadge extends StatelessWidget {
  final String text;
  const LevelBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 132,
        height: 132,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: Alignment(-.3, -.4), radius: 1, colors: [Color(0xFFFFE08A), Tk.gold, Color(0xFFC98F00)], stops: [0, .55, 1]),
          boxShadow: [
            BoxShadow(color: Color.fromRGBO(255, 200, 61, .18), spreadRadius: 10),
            BoxShadow(color: Color.fromRGBO(255, 200, 61, .45), blurRadius: 60),
          ],
        ),
        child: Text(text, style: V20Text.baloo(size: 64, line: 64, color: Tk.bg)),
      );
}
