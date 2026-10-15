import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/celebration.dart';
import '../../core/widgets/screen_background.dart';
import 'hud.dart';

/// Cadre des écrans plein écran sans barre de navigation (résultats, célébrations, fin de journée) :
/// fond v20, HUD en haut, rayonnement doré facultatif. Le contenu défile.
class GameFrame extends StatelessWidget {
  final List<Widget> children;
  final bool burst;
  const GameFrame({super.key, required this.children, this.burst = false});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Tk.bg,
        body: ScreenBackground(
          child: Stack(children: [
            SafeArea(
              child: Column(children: [
                const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 0), child: Hud()),
                Expanded(child: ListView(padding: const EdgeInsets.all(16), children: children)),
              ]),
            ),
            if (burst) const Burst(),
          ]),
        ),
      );
}
