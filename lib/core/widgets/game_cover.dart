import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/v20.dart';

/// Disque vinyle de la pochette (art.vinyl() de tools/design).
const _vinyl = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="46" fill="#14102B" opacity=".55"/><circle cx="50" cy="50" r="34" fill="none" stroke="#fff" stroke-opacity=".18" stroke-width="1"/><circle cx="50" cy="50" r="26" fill="none" stroke="#fff" stroke-opacity=".14" stroke-width="1"/><circle cx="50" cy="50" r="12" fill="#FFC83D" opacity=".85"/><circle cx="50" cy="50" r="2.5" fill="#14102B"/></svg>''';

/// Pochette (.cover de v20.css) : carré dégradé magenta, violet, cyan, vinyle et lettre Baloo 34 (la planche affiche « B » pour tous les sons).
class GameCover extends StatelessWidget {
  final String letter;
  final double size;
  const GameCover({super.key, this.letter = 'B', this.size = 64});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Pochette $letter',
        excludeSemantics: true,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF43F9D), Color(0xFF8B5CF6), Color(0xFF3CD6F2)], stops: [0, .6, 1]),
            boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, .35), blurRadius: 20, offset: Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(child: SvgPicture.string(_vinyl, fit: BoxFit.fill)),
              Text(letter, style: V20Text.baloo(size: 34, line: 34, color: Colors.white).copyWith(shadows: const [Shadow(color: Color.fromRGBO(0, 0, 0, .4), blurRadius: 8, offset: Offset(0, 2))])),
            ]),
          ),
        ),
      );
}
