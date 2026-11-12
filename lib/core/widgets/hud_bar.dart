import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';
import 'meter_bar.dart';

/// HUD (.hud de rap.css) : mini-avatar, nom, niveau, barre d'XP, cloche ; puis trois blocs Cash · cauris (or), Énergie (cyan, éclair), Temps.
/// Widget d'affichage : toutes les valeurs arrivent déjà formatées (le calcul vient du domaine).
class HudBar extends StatelessWidget {
  final String initials, name, levelLabel, cash, energy, time;
  final double xp;
  final VoidCallback? onBell;
  final bool bellBadge;
  const HudBar({
    super.key,
    this.initials = 'DK',
    required this.name,
    required this.levelLabel,
    required this.xp,
    required this.cash,
    required this.energy,
    required this.time,
    this.onBell,
    this.bellBadge = false,
  });

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: V20.avatar, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color.fromRGBO(255, 255, 255, .9), width: 2)),
            child: Text(initials, style: V20Text.baloo(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(name, maxLines: 1, style: V20Text.nm()),
                const SizedBox(width: 8),
                // Le libellé de niveau se réduit au lieu de déborder (noms longs, texte agrandi).
                Expanded(child: Align(alignment: Alignment.centerRight, child: FittedBox(fit: BoxFit.scaleDown, child: Text(levelLabel.toUpperCase(), maxLines: 1, style: V20Text.lab())))),
              ]),
              const SizedBox(height: 4),
              MeterBar(value: xp, thin: true),
            ]),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Journal',
            child: GestureDetector(
              onTap: onBell,
              child: Container(
                width: Tk.minTap,
                height: Tk.minTap,
                decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(16), border: Border.all(color: Tk.line, width: 2)),
                child: Stack(alignment: Alignment.center, children: [
                  const GameIcon('bell', color: Tk.ink),
                  if (bellBadge) Positioned(top: 8, right: 8, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Tk.acc, shape: BoxShape.circle))),
                ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color.fromRGBO(255, 255, 255, .06), borderRadius: BorderRadius.circular(16), boxShadow: V20.hudShadow),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _Cell(label: 'Cash · cauris', child: Text(cash, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm(color: Tk.gold))),
                const SizedBox(width: 2),
                _Cell(
                  label: 'Énergie',
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(energy, maxLines: 1, style: V20Text.nm(color: Tk.cy)))),
                    const SizedBox(width: 4),
                    const GameIcon('zap', size: 16, color: Tk.cy),
                  ]),
                ),
                const SizedBox(width: 2),
                _Cell(label: 'Temps', child: Align(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, child: Text(time, maxLines: 1, style: V20Text.nm())))),
              ]),
            ),
          ),
        ),
      ]);
}

class _Cell extends StatelessWidget {
  final String label;
  final Widget child;
  const _Cell({required this.label, required this.child});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(gradient: V20.hudCell),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Align(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, child: Text(label.toUpperCase(), maxLines: 1, style: V20Text.lab()))),
            const SizedBox(height: 4),
            child,
          ]),
        ),
      );
}
