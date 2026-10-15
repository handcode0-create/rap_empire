import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../domain/game_state.dart';

/// Messages courts (SnackBar). Les erreurs métier (GameError) s'affichent avec le texte du prototype.
void showError(BuildContext context, Object error) => showInfo(context, error is GameError ? error.message : 'Action impossible');

void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Tk.ink)),
      backgroundColor: Tk.s2,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
}
