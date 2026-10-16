import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';
import 'game_tag.dart';
import 'glass_card.dart';

/// Tuile d'action de la direction Néon de Bakoma : icône dégradée 32 px + titre sur une ligne, sous-titre, coût en énergie facultatif (cyan, éclair)
/// et pastille facultative. Le titre se réduit au lieu d'être tronqué. Cible ≥ 48 px. Pour une tuile verrouillée, voir [LockedTile].
class GlassTile extends StatelessWidget {
  final String icon, title, subtitle;
  final String? cost, badge;
  final VoidCallback onTap;
  const GlassTile({super.key, required this.icon, required this.title, required this.subtitle, this.cost, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        semanticLabel: '$title, $subtitle${cost == null ? '' : ', $cost'}',
        child: ExcludeSemantics(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(gradient: V20.tileIcon, borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: GameIcon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(title, maxLines: 1, style: V20Text.baloo(size: 17, line: 18)))),
              if (badge != null) GameTag(badge!, style: GameTagStyle.accent),
            ]),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 15, color: V20.ink2)),
            if (cost != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const GameIcon('zap', size: 14, color: Tk.cy),
                const SizedBox(width: 4),
                Expanded(child: Text(cost!, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 15, weight: FontWeight.w600, color: Tk.cy))),
              ]),
            ],
          ]),
        ),
      );
}
