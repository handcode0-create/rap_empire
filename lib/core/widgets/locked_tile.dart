import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';
import 'glass_card.dart';

/// Tuile verrouillée : cadenas, titre, sous-titre, CONDITION EXACTE du verrou et, si connue, la distance restante.
/// L'information ne passe pas par la couleur seule (cadenas + texte). Reste touchable (≥ 48 px) pour expliquer le verrou.
class LockedTile extends StatelessWidget {
  final String title, subtitle, condition;
  final String? remaining;
  final VoidCallback? onTap;
  const LockedTile({super.key, required this.title, required this.subtitle, required this.condition, this.remaining, this.onTap});

  @override
  Widget build(BuildContext context) => GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        semanticLabel: '$title, verrouillé. $condition${remaining == null ? '' : '. $remaining'}',
        child: ExcludeSemantics(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Tk.s2, borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: const GameIcon('lock', size: 20, color: V20.lockedIcon),
              ),
              const SizedBox(width: 8),
              Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(title, maxLines: 1, style: V20Text.baloo(size: 17, line: 18, color: V20.ink2)))),
            ]),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 15, color: V20.ink2)),
            const SizedBox(height: 4),
            Text(condition.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab(color: V20.hintGoldText)),
            if (remaining != null) Text(remaining!, style: V20Text.poppins(size: 12, line: 15, weight: FontWeight.w600, color: Tk.ink)),
          ]),
        ),
      );
}
