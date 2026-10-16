import 'package:flutter/material.dart';
import 'v20.dart';

/// Tokens de la direction « Néon de Bakoma » (docs/BRIEF.md) : verre fumé, halos, rayons, durées et courbes.
/// La palette reste celle de tokens.dart et v20.dart : cette extension ne définit aucune nouvelle couleur de marque,
/// seulement des dérivés (opacités) de la palette validée.
@immutable
class NeonTokens extends ThemeExtension<NeonTokens> {
  /// Carte « verre fumé » : #1F1942 à 85 %, bord blanc à 10 %, rayon 20.
  final Color glassFill, glassBorder;

  /// Halos : un seul halo fort par écran (magenta = action, or = ce qui rapporte, cyan = énergie).
  final Color glowMagenta, glowGold, glowCyan;

  /// Voile posé sur le décor illustré (fond flou et assombri).
  final Color sceneScrim;
  final double rGlass, haloBlur, sceneBlur;

  /// Durées (150 à 350 ms), pas de la cascade (80 ms) et durée d'un compteur.
  final Duration fast, base, slow, cascadeStep, count;

  /// easeOutCubic à l'entrée, easeInCubic à la sortie.
  final Curve enter, exit;

  const NeonTokens({
    required this.glassFill,
    required this.glassBorder,
    required this.glowMagenta,
    required this.glowGold,
    required this.glowCyan,
    required this.sceneScrim,
    required this.rGlass,
    required this.haloBlur,
    required this.sceneBlur,
    required this.fast,
    required this.base,
    required this.slow,
    required this.cascadeStep,
    required this.count,
    required this.enter,
    required this.exit,
  });

  static const standard = NeonTokens(
    glassFill: Color.fromRGBO(31, 25, 66, .85),
    glassBorder: Color.fromRGBO(255, 255, 255, .10),
    glowMagenta: Color.fromRGBO(244, 63, 157, .42),
    glowGold: Color.fromRGBO(255, 200, 61, .38),
    glowCyan: Color.fromRGBO(60, 214, 242, .34),
    sceneScrim: Color.fromRGBO(20, 16, 43, .6),
    rGlass: 20,
    haloBlur: 28,
    sceneBlur: 5,
    fast: Duration(milliseconds: 150),
    base: Duration(milliseconds: 250),
    slow: Duration(milliseconds: 350),
    cascadeStep: Duration(milliseconds: 80),
    count: Duration(milliseconds: 700),
    enter: Curves.easeOutCubic,
    exit: Curves.easeInCubic,
  );

  /// Extension du thème courant ; les tests qui utilisent un thème sans extension retombent sur [standard].
  static NeonTokens of(BuildContext context) => Theme.of(context).extension<NeonTokens>() ?? standard;

  /// Halo coloré posé sous un élément.
  List<BoxShadow> halo(Color glow) => [BoxShadow(color: glow, blurRadius: haloBlur, offset: const Offset(0, 10))];

  /// Ombre de carte sans accent.
  List<BoxShadow> get cardShadow => V20.cardShadow;

  @override
  NeonTokens copyWith({Color? glassFill, Color? glassBorder, Color? glowMagenta, Color? glowGold, Color? glowCyan, Color? sceneScrim}) => NeonTokens(
        glassFill: glassFill ?? this.glassFill,
        glassBorder: glassBorder ?? this.glassBorder,
        glowMagenta: glowMagenta ?? this.glowMagenta,
        glowGold: glowGold ?? this.glowGold,
        glowCyan: glowCyan ?? this.glowCyan,
        sceneScrim: sceneScrim ?? this.sceneScrim,
        rGlass: rGlass,
        haloBlur: haloBlur,
        sceneBlur: sceneBlur,
        fast: fast,
        base: base,
        slow: slow,
        cascadeStep: cascadeStep,
        count: count,
        enter: enter,
        exit: exit,
      );

  @override
  NeonTokens lerp(ThemeExtension<NeonTokens>? other, double t) {
    if (other is! NeonTokens) return this;
    return copyWith(
      glassFill: Color.lerp(glassFill, other.glassFill, t),
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t),
      glowMagenta: Color.lerp(glowMagenta, other.glowMagenta, t),
      glowGold: Color.lerp(glowGold, other.glowGold, t),
      glowCyan: Color.lerp(glowCyan, other.glowCyan, t),
      sceneScrim: Color.lerp(sceneScrim, other.sceneScrim, t),
    );
  }
}
