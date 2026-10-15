import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game_icons.dart';

/// Icônes ajoutées (Lucide, même trait que rap.css) pour les symboles que les planches écrivent en texte (ⓘ, ★) : la police ne les contient pas.
const _extraSvgs = {
  'info': "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='10'/><path d='M12 16v-4'/><path d='M12 8h.01'/></svg>",
  'star': "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><polygon points='12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2'/></svg>",
};

/// Icône du prototype v20 (Lucide, trait de 2) recolorée comme un masque CSS : 24 px par défaut, 16 (petite) ou 32 (grande).
class GameIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  const GameIcon(this.name, {super.key, this.size = 24, required this.color});

  @override
  Widget build(BuildContext context) {
    final svg = gameIconSvgs[name] ?? _extraSvgs[name];
    assert(svg != null, 'Icône inconnue : $name');
    return SvgPicture.string(
      svg ?? gameIconSvgs['x']!,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
