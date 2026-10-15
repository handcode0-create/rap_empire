import 'package:flutter/material.dart';
import 'tokens.dart';

/// Couche visuelle v20 : valeurs littérales de docs/design-ref/rap.css et v20.css (D-14, cible AAA) qui complètent
/// la palette de tokens.dart sans la modifier. Polices embarquées : Poppins et Baloo 2 (assets/fonts, licence OFL).
class V20 {
  // v20.css D-14 : ink2 relevé, accent texte, fonds de boutons et de cellules.
  static const ink2 = Color(0xFFD2CDF2);
  static const accText = Color(0xFFFFA0D2);
  static const pinkBtn = Color(0xFFFF86C6), lilacBtn = Color(0xFFC9B6FF);
  static const hudCellTop = Color(0xFF241D4D), hudCellBottom = Color(0xFF1B1540);
  static const objMid = Color(0xFFB14ADF);
  static const hintCyanText = Color(0xFFBDEFFA), hintGoldText = Color(0xFFFFE3A0);
  static const okText = Color(0xFF8CF0C4), riskText = Color(0xFFFFB0D8);
  static const lockedIcon = Color(0xFF9A94C4);

  /// Dégradé principal des boutons (v20 : 90°, #FF86C6 → #C9B6FF).
  static const pill = LinearGradient(colors: [pinkBtn, lilacBtn]);

  /// Surface des cartes, tuiles et KPI (165°, rgba(43,36,89,.78) → rgba(31,25,66,.92)).
  static const surface = LinearGradient(
    begin: Alignment(-0.26, -0.97),
    end: Alignment(0.26, 0.97),
    colors: [Color.fromRGBO(43, 36, 89, .78), Color.fromRGBO(31, 25, 66, .92)],
  );

  /// Surface sélectionnée (cartes de choix).
  static const surfaceSelected = LinearGradient(
    begin: Alignment(-0.26, -0.97),
    end: Alignment(0.26, 0.97),
    colors: [Color.fromRGBO(94, 34, 104, .9), Color.fromRGBO(58, 27, 82, .95)],
  );

  /// Carte objectif / mission (135°, #F43F9D → #B14ADF 55 % → #8B5CF6).
  static const objective = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Tk.acc, objMid, Tk.violet], stops: [0, .55, 1]);

  /// Cellules du HUD (180°).
  static const hudCell = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [hudCellTop, hudCellBottom]);

  /// Mini-avatar et icône d'action (135°).
  static const avatar = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Tk.acc, Tk.violet]);
  static const tileIcon = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.fromRGBO(244, 63, 157, .9), Color.fromRGBO(139, 92, 246, .9)]);

  static const cardBorder = Color.fromRGBO(255, 255, 255, .09);
  static const kpiBorder = Color.fromRGBO(255, 255, 255, .08);
  static const bannerBorder = Color.fromRGBO(255, 255, 255, .12);
  static const scrim = Color.fromRGBO(12, 8, 32, .82);

  static const cardShadow = [BoxShadow(color: Color.fromRGBO(0, 0, 0, .22), blurRadius: 18, offset: Offset(0, 6))];
  static const hudShadow = [BoxShadow(color: Color.fromRGBO(0, 0, 0, .28), blurRadius: 24, offset: Offset(0, 8))];
  static const bannerShadow = [BoxShadow(color: Color.fromRGBO(0, 0, 0, .4), blurRadius: 34, offset: Offset(0, 14))];
  static const buttonShadow = [BoxShadow(color: Color.fromRGBO(244, 63, 157, .32), blurRadius: 26, offset: Offset(0, 10))];
  static const objectiveShadow = [BoxShadow(color: Color.fromRGBO(244, 63, 157, .3), blurRadius: 36, offset: Offset(0, 16))];
}

/// Styles de texte de rap.css (la hauteur de ligne CSS est convertie en multiplicateur).
class V20Text {
  static TextStyle poppins({double size = 15, double line = 22, FontWeight weight = FontWeight.w400, Color color = Tk.ink, double spacing = 0}) =>
      TextStyle(fontFamily: 'Poppins', fontSize: size, height: line / size, fontWeight: weight, color: color, letterSpacing: spacing);

  static TextStyle baloo({double size = 18, double line = 22, Color color = Tk.ink}) => TextStyle(
        fontFamily: 'Baloo2',
        fontSize: size,
        height: line / size,
        fontWeight: FontWeight.w800,
        fontVariations: const [FontVariation('wght', 800)],
        color: color,
      );

  /// .lab : 11/14 700, +8 %, majuscules (le texte doit être passé en majuscules par l'appelant).
  static TextStyle lab({Color color = V20.ink2}) => poppins(size: 11, line: 14, weight: FontWeight.w700, color: color, spacing: .88);

  /// .bm 15/22 · .bs 13/18 · .btt 15/20 800 +3 %.
  static TextStyle get bm => poppins();
  static TextStyle bs({Color color = V20.ink2}) => poppins(size: 13, line: 18, color: color);
  static TextStyle get btt => poppins(size: 15, line: 20, weight: FontWeight.w800, spacing: .45);

  /// .nm 18/22 · .dm 32/30 · .nxl 44/44 (Baloo 2 800).
  static TextStyle nm({Color color = Tk.ink}) => baloo(size: 18, line: 22, color: color);
  static TextStyle dm({double size = 32, double? line, Color color = Tk.ink}) => baloo(size: size, line: line ?? (size == 32 ? 30 : size), color: color);
}
