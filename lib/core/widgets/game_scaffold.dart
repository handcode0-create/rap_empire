import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/neon_tokens.dart';
import '../theme/tokens.dart';
import 'screen_background.dart';

/// Cadre d'écran de la direction Néon de Bakoma : fond v20, décor illustré du lieu (assets/scenes/<scene>.svg) flou et assombri
/// sur le haut de l'écran, HUD, contenu, puis barre de navigation facultative. Sans [scene], rendu identique à l'ancienne coque.
/// scene : studio, office, backstage, street, stage, call, qg_sky.
class GameScaffold extends StatelessWidget {
  final String? scene;
  final Widget? hud;
  final Widget body;
  final Widget? bottomNavigationBar;
  const GameScaffold(
      {super.key,
      this.scene,
      this.hud,
      required this.body,
      this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Scaffold(
      backgroundColor: Tk.bg,
      body: ScreenBackground(
        child: Stack(fit: StackFit.expand, children: [
          if (scene != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 360,
              child: ExcludeSemantics(
                child: ClipRect(
                  child: RepaintBoundary(
                    // le décor s'efface vers le bas (masque alpha) : aucune arête visible, les halos du fond restent intacts
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.transparent
                          ],
                          stops: [
                            0,
                            .45,
                            1
                          ]).createShader(r),
                      child: Stack(fit: StackFit.expand, children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: t.sceneBlur,
                              sigmaY: t.sceneBlur,
                              tileMode: TileMode.clamp),
                          child: SvgPicture.asset('assets/scenes/$scene.svg',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter),
                        ),
                        ColoredBox(color: t.sceneScrim),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            bottom: bottomNavigationBar == null,
            child: Column(children: [
              if (hud != null)
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: hud),
              Expanded(child: body),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
