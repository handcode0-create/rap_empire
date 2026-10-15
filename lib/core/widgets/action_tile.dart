import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';
import 'game_tag.dart';

/// Tuile d'action (.tile2 de v20.css) : icône dégradée 36 px, titre Baloo 17, sous-titre 12, pastille facultative. [locked] : grise, verrouillée.
class ActionTile extends StatelessWidget {
  final String icon, title, subtitle;
  final String? badge;
  final bool locked;
  final VoidCallback? onTap;
  const ActionTile({super.key, required this.icon, required this.title, required this.subtitle, this.badge, this.locked = false, this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '$title, $subtitle',
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: V20.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: V20.cardBorder, width: 1.5)),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 70),
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(gradient: locked ? null : V20.tileIcon, color: locked ? Tk.s2 : null, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: GameIcon(locked ? 'lock' : icon, color: locked ? V20.lockedIcon : Colors.white),
                      ),
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.baloo(size: 17, line: 18, color: locked ? Tk.dis : Tk.ink)),
                      Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 15, color: locked ? Tk.dis : V20.ink2)),
                    ]),
                  ),
                  if (badge != null) Positioned(top: 10, right: 10, child: GameTag(badge!, style: GameTagStyle.accent)),
                ]),
              ),
            ),
          ),
        ),
      );
}
