import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import 'hud.dart';

/// Coque : HUD en haut, cinq onglets en bas (QG, Studio, Scène, Business, Profil).
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  static const tabs = [
    ('QG', Icons.home_rounded),
    ('Studio', Icons.graphic_eq_rounded),
    ('Scène', Icons.mic_external_on_rounded),
    ('Business', Icons.business_center_rounded),
    ('Profil', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(bottom: false, child: Column(children: [const Hud(), Expanded(child: shell)])),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Tk.deep, border: Border(top: BorderSide(color: Tk.line))),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      label: tabs[i].$1,
                      icon: tabs[i].$2,
                      active: shell.currentIndex == i,
                      onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.label, required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = active ? Tk.acc : Tk.ink2;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: Container(height: 3, decoration: BoxDecoration(color: active ? Tk.acc : Colors.transparent, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)))),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
          ]),
        ]),
      ),
    );
  }
}
