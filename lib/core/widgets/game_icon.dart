import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game_icons.dart';

/// Icône du prototype v20 (Lucide, trait de 2) recolorée comme un masque CSS : 24 px par défaut, 16 (petite) ou 32 (grande).
class GameIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  const GameIcon(this.name, {super.key, this.size = 24, required this.color});

  @override
  Widget build(BuildContext context) {
    final svg = gameIconSvgs[name];
    assert(svg != null, 'Icône inconnue : $name');
    return SvgPicture.string(
      svg ?? gameIconSvgs['x']!,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
