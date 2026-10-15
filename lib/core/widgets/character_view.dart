import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Personnage 2D modulaire (illustrations générées par tools/design, style provisoire D-01).
/// who : djo, kore, orage, zaki, nadia (= Maya Tessé), zamba, rosine, anselme, ayana.
/// mood : neutral, cool, smile, laugh, serious, worried, angry, poised, smirk, sing.
/// crop : head, bust, torso. gesture/pose facultatifs (seules les combinaisons de assets/characters/manifest.json existent).
class CharacterView extends StatelessWidget {
  final String who, mood, crop, gesture, pose;
  final double? width, height;
  const CharacterView({super.key, required this.who, this.mood = 'cool', this.crop = 'bust', this.gesture = '', this.pose = '', this.width, this.height});

  String get _path {
    final parts = [who, mood, if (gesture.isNotEmpty) gesture, if (pose.isNotEmpty) pose, crop];
    return 'assets/characters/${parts.join('_')}.svg';
  }

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        _path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticsLabel: who,
        // Combinaison absente du manifest : retombe sur l'humeur sans geste, cadrage identique.
        placeholderBuilder: (_) => SizedBox(width: width, height: height),
      );
}
