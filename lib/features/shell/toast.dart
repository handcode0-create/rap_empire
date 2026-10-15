import 'package:flutter/material.dart';
import '../../core/widgets/game_toast.dart';
import '../../domain/game_state.dart';

/// Messages courts : GameToast en haut de l'écran. Les erreurs métier (GameError) s'affichent avec le texte du prototype.
void showError(BuildContext context, Object error) => showGameToast(context, error is GameError ? error.message : 'Action impossible', kind: ToastKind.error);

void showInfo(BuildContext context, String message) => showGameToast(context, message);

void showSuccess(BuildContext context, String message) => showGameToast(context, message, kind: ToastKind.success);
