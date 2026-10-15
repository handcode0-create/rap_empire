import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';
import 'game_icon.dart';

class NavEntry {
  final String label, icon;
  const NavEntry(this.label, this.icon);
}

/// Barre de navigation (.nav de rap.css) : 72 px, coins hauts 24, bordure haute 2 px, trait magenta de 3 px sur l'onglet actif.
/// Cinq onglets fixes : QG, Studio, Scène, Business, Profil.
class GameNavBar extends StatelessWidget {
  static const entries = [
    NavEntry('QG', 'home'),
    NavEntry('Studio', 'mic'),
    NavEntry('Scène', 'flame'),
    NavEntry('Business', 'briefcase'),
    NavEntry('Profil', 'user'),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;
  const GameNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Tk.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Tk.line, width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(children: [
              for (var i = 0; i < entries.length; i++)
                Expanded(child: _NavItem(entry: entries[i], active: i == currentIndex, onTap: () => onTap(i))),
            ]),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final NavEntry entry;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.entry, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? Tk.ink : V20.ink2;
    return Semantics(
      button: true,
      selected: active,
      label: entry.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, c) => Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            if (active) Positioned(top: -2, left: c.maxWidth * .22, right: c.maxWidth * .22, child: Container(height: 3, decoration: BoxDecoration(color: Tk.acc, borderRadius: BorderRadius.circular(3)))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              GameIcon(entry.icon, color: color),
              const SizedBox(height: 4),
              Text(entry.label, maxLines: 1, style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w700, color: color, spacing: .88)),
            ]),
          ]),
        ),
      ),
    );
  }
}
