import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens du design system RAP EMPIRE (planche DS-Tokens). Palette unique.
class Tk {
  static const bg = Color(0xFF14102B), deep = Color(0xFF0C0820), s1 = Color(0xFF1F1942), s2 = Color(0xFF2B2459), line = Color(0xFF3A3270);
  static const ink = Color(0xFFF8F7FF), ink2 = Color(0xFFB6B0DD), dis = Color(0xFF6E6896);
  static const acc = Color(0xFFF43F9D), acc4 = Color(0xFFFF6BB8), acc7 = Color(0xFFC21E78), tint = Color(0xFF3A1B52);
  static const ok = Color(0xFF3DDC97), gold = Color(0xFFFFC83D), cy = Color(0xFF3CD6F2), violet = Color(0xFF8B5CF6);
  static const grad = LinearGradient(colors: [acc, violet]);
  static const space = [4.0, 8.0, 12.0, 16.0, 24.0, 32.0, 48.0];
  static const rCard = 16.0, rSheet = 28.0, minTap = 48.0, btnH = 56.0;
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final body = GoogleFonts.poppinsTextTheme(base.textTheme).apply(bodyColor: Tk.ink, displayColor: Tk.ink);
  return base.copyWith(
    scaffoldBackgroundColor: Tk.bg,
    colorScheme: const ColorScheme.dark(primary: Tk.acc, secondary: Tk.cy, surface: Tk.s1, onSurface: Tk.ink),
    textTheme: body.copyWith(
      displayMedium: GoogleFonts.baloo2(fontSize: 32, height: 30 / 32, fontWeight: FontWeight.w800, color: Tk.ink),
      titleLarge: GoogleFonts.baloo2(fontSize: 18, height: 22 / 18, fontWeight: FontWeight.w800, color: Tk.ink),
    ),
  );
}
