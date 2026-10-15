import 'package:flutter/material.dart';
import 'tokens.dart';
import 'v20.dart';

/// Thème de l'application : palette de tokens.dart, polices embarquées (Poppins, Baloo 2). Aucune police téléchargée.
ThemeData buildGameTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final body = base.textTheme.apply(fontFamily: 'Poppins', bodyColor: Tk.ink, displayColor: Tk.ink);
  return base.copyWith(
    scaffoldBackgroundColor: Tk.bg,
    colorScheme: const ColorScheme.dark(primary: Tk.acc, secondary: Tk.cy, surface: Tk.s1, onSurface: Tk.ink),
    textTheme: body.copyWith(
      displayMedium: V20Text.dm().copyWith(letterSpacing: 0),
      titleLarge: V20Text.nm(),
    ),
    splashFactory: InkRipple.splashFactory,
    focusColor: Tk.gold,
  );
}
