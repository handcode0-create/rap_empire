import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/v20.dart';
import 'character_view.dart';

/// Personnage posé dans une bannière : [left] et [width] en px comme dans les planches ; le bas est calculé comme art.ban() de tools/design.
class BannerChar {
  final String who, mood, gesture, crop, pose;
  final double width, left;

  /// SVG de assets/svg/ pour un personnage absent de assets/characters (ex. K-Zer d'Mabaya, planche 21-B1).
  final String? asset;
  const BannerChar(this.who, {this.mood = 'cool', this.gesture = '', this.crop = 'torso', this.pose = '', required this.width, required this.left, this.asset});
}

/// Bannière de scène illustrée (.ban de v20.css) : rayon 24, bordure blanche 12 %, décor SVG (assets/scenes/<kind>.svg), personnages,
/// voile dégradé sur 70 % de la hauteur, rôle (11 px) et NOM (Baloo 24 en majuscules) à gauche. Ne masque jamais une information de décision.
/// kind : studio, office, backstage, street, stage, call, qg_sky.
class SceneBanner extends StatelessWidget {
  final String kind;
  final String? role, name, subtitle;
  final double height, nameSize;
  final List<BannerChar> chars;
  final Widget? top;

  /// Décor SVG de assets/svg/ (commissariat, tribunal, cellule…) à la place de assets/scenes/<kind>.svg.
  final String? sceneAsset;

  /// Garde le nom sur une ligne en le réduisant au besoin (planche 10.3) ; sinon il passe à la ligne (planche 04.1).
  final bool nameSingleLine;

  /// Entrée animée (décor qui se pose, personnages qui glissent, changement d'humeur en fondu). Finie, jamais en boucle.
  final bool animate;
  const SceneBanner({super.key, required this.kind, this.role, this.name, this.subtitle, this.height = 190, this.nameSize = 24, this.nameSingleLine = false, this.chars = const [], this.top, this.sceneAsset, this.animate = false});

  /// Rapport hauteur / largeur des personnages (viewBox torse 260 x 340, buste 220 x 250).
  static double _ratio(String crop) => crop == 'torso' ? 340 / 260 : 250 / 220;

  @override
  Widget build(BuildContext context) {
    final anim = animate && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    return _frame(anim);
  }

  Widget _frame(bool anim) => Container(
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: V20.bannerBorder, width: 1.5), boxShadow: V20.bannerShadow),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.5),
          child: Stack(fit: StackFit.expand, children: [
            _decor(anim),
            for (var i = 0; i < chars.length; i++) _placed(chars[i], anim, i),
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
            if (role != null || name != null || subtitle != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  if (role != null) Text(role!.toUpperCase(), style: V20Text.lab(color: Colors.white)),
                  if (role != null && name != null) const SizedBox(height: 4),
                  if (name != null) _name(),
                  if (subtitle != null) Text(subtitle!, style: V20Text.bs(color: Colors.white)),
                ]),
              ),
          ]),
        ),
      );

  Widget _name() {
    final text = Text(
      name!.toUpperCase(),
      style: V20Text.baloo(size: nameSize, line: nameSize == 32 ? 30 : nameSize, color: Colors.white).copyWith(shadows: const [Shadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 14, offset: Offset(0, 2))]),
    );
    return nameSingleLine ? FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: text) : text;
  }

  Widget _decor(bool anim) {
    final svg = SvgPicture.asset(sceneAsset ?? 'assets/scenes/$kind.svg', fit: BoxFit.cover, alignment: Alignment.center);
    if (!anim) return svg;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.1, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: svg,
    );
  }

  Widget _placed(BannerChar c, bool anim, int index) {
    final h = c.width * _ratio(c.crop);
    final bottom = h <= height ? 0.0 : height - h;
    Widget view = c.asset != null
        ? SvgPicture.asset(c.asset!, width: c.width, height: h, fit: BoxFit.contain, semanticsLabel: c.who)
        : CharacterView(who: c.who, mood: c.mood, gesture: c.gesture, crop: c.crop, pose: c.pose, width: c.width, height: h);
    if (anim) {
      // Humeur qui change : fondu croisé ; première apparition : glissement depuis le bord le plus proche, décalé par personnage.
      view = AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: KeyedSubtree(key: ValueKey('${c.who}-${c.mood}-${c.gesture}'), child: view));
      final fromLeft = c.left + c.width / 2 < 195;
      view = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 520 + 160 * index),
        curve: Curves.easeOutCubic,
        builder: (_, v, child) => Opacity(opacity: v.clamp(0, 1), child: Transform.translate(offset: Offset((fromLeft ? -36 : 36) * (1 - v), 12 * (1 - v)), child: child)),
        child: view,
      );
    }
    return Positioned(left: c.left, bottom: bottom, width: c.width, height: h, child: view);
  }
}
