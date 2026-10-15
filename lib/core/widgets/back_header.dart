import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';
import 'game_tag.dart';

/// En-tête des écrans de détail : bouton retour 48 x 48 (.ib), titre Baloo 18, étiquette d'étape facultative (« Étape 1 / 3 »).
class BackHeader extends StatelessWidget {
  final String title;
  final String? step;
  final VoidCallback onBack;
  const BackHeader({super.key, required this.title, this.step, required this.onBack});

  @override
  Widget build(BuildContext context) => Row(children: [
        Semantics(
          button: true,
          label: 'Retour',
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              width: Tk.minTap,
              height: Tk.minTap,
              decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(16), border: Border.all(color: Tk.line, width: 2)),
              child: const Center(child: GameIcon('back', color: Tk.ink)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm())),
        if (step != null) ...[const SizedBox(width: 8), GameTag(step!)],
      ]);
}
