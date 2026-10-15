import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// Feuille basse (.sheet de rap.css) : fond s1 (ou tint avec [flat]), bordure haute ink 2 px, rayon 28, poignée 48 x 4, scrim rgba(12,8,32,.82).
class BottomSheetGame extends StatelessWidget {
  final Widget child;
  final bool flat;
  const BottomSheetGame({super.key, required this.child, this.flat = false});

  @override
  Widget build(BuildContext context) {
    final bottom = max(32.0, MediaQuery.of(context).padding.bottom + 16);
    return Container(
      decoration: BoxDecoration(
        color: flat ? Tk.tint : Tk.s1,
        border: const Border(top: BorderSide(color: Tk.ink, width: 2)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Tk.rSheet)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Tk.line, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          child,
        ]),
      ),
    );
  }
}

/// Ouvre une feuille basse au style v20. [dismissible] : false pour une feuille à acquitter (niveau supérieur).
Future<T?> showGameSheet<T>(BuildContext context, {required WidgetBuilder builder, bool flat = false, bool dismissible = true}) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // le voile couvre tout l'écran, HUD et navigation compris, comme .scrim de rap.css
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: Colors.transparent,
      barrierColor: V20.scrim,
      builder: (c) => BottomSheetGame(flat: flat, child: builder(c)),
    );
