import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/v20.dart';
import 'character_view.dart';

/// Personnage posé dans une bannière : [left] et [width] en px comme dans les planches ; le bas est calculé comme art.ban() de tools/design.
class BannerChar {
  final String who, mood, gesture, crop, pose;
  final double width, left;
  const BannerChar(this.who, {this.mood = 'cool', this.gesture = '', this.crop = 'torso', this.pose = '', required this.width, required this.left});
}

/// Bannière de scène illustrée (.ban de v20.css) : rayon 24, bordure blanche 12 %, décor SVG (assets/scenes/<kind>.svg), personnages,
/// voile dégradé sur 70 % de la hauteur, rôle (11 px) et NOM (Baloo 24 en majuscules) à gauche. Ne masque jamais une information de décision.
/// kind : studio, office, backstage, street, stage, call, qg_sky.
class SceneBanner extends StatelessWidget {
  final String kind;
  final String? role, name;
  final double height;
  final List<BannerChar> chars;
  final Widget? top;
  const SceneBanner({super.key, required this.kind, this.role, this.name, this.height = 190, this.chars = const [], this.top});

  /// Rapport hauteur / largeur des personnages (viewBox torse 260 x 340, buste 220 x 250).
  static double _ratio(String crop) => crop == 'torso' ? 340 / 260 : 250 / 220;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: V20.bannerBorder, width: 1.5), boxShadow: V20.bannerShadow),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.5),
          child: Stack(fit: StackFit.expand, children: [
            SvgPicture.asset('assets/scenes/$kind.svg', fit: BoxFit.cover, alignment: Alignment.center),
            for (final c in chars) _placed(c),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * .7,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromRGBO(20, 16, 43, 0), Color.fromRGBO(20, 16, 43, .88)])),
              ),
            ),
            if (top != null) Positioned(left: 12, right: 12, top: 12, child: top!),
            if (role != null || name != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  if (role != null) Text(role!.toUpperCase(), style: V20Text.lab(color: Colors.white)),
                  if (role != null && name != null) const SizedBox(height: 4),
                  if (name != null)
                    Text(
                      name!.toUpperCase(),
                      style: V20Text.baloo(size: 24, line: 24, color: Colors.white).copyWith(shadows: const [Shadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 14, offset: Offset(0, 2))]),
                    ),
                ]),
              ),
          ]),
        ),
      );

  Widget _placed(BannerChar c) {
    final h = c.width * _ratio(c.crop);
    final bottom = h <= height ? 0.0 : height - h;
    return Positioned(
      left: c.left,
      bottom: bottom,
      width: c.width,
      height: h,
      child: CharacterView(who: c.who, mood: c.mood, gesture: c.gesture, crop: c.crop, pose: c.pose, width: c.width, height: h),
    );
  }
}
