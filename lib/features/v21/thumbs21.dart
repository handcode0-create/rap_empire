import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_icon.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart' show J;
import 'library_screens.dart' show trackCover21;
import 'wardrobe_screens.dart' show PlayerBust21;
import 'widgets21.dart';

/// Miniatures des clips et décors des publications : le joueur y apparaît toujours dans sa tenue du moment.
/// Neuf choix par clip : huit ambiances de scène (n = 0 à 7) et la pochette du titre (n = 8). Purement visuel.

const sceneGrads21 = <List<Color>>[
  [Color(0xFF2A1060), Color(0xFF0B0620)],
  [Color(0xFF5A1D5C), Color(0xFF1A0B2E)],
  [Color(0xFF7A1F5A), Color(0xFF14102B)],
  [Color(0xFF3A1B52), Color(0xFF0C0820)],
  [Color(0xFF8A4A12), Color(0xFF1A0B0B)],
  [Color(0xFF0E6B6B), Color(0xFF0C0820)],
  [Color(0xFF8A1030), Color(0xFF14102B)],
  [Color(0xFF6B5A12), Color(0xFF14102B)],
];
const sceneNames21 = ['Néon violet', 'Soir rose', 'Magenta', 'Nuit de Ndolo', 'Ambre', 'Lagune', 'Rouge scène', 'Or'];

/// Décor d'une publication ou d'un clip : dégradé de scène et le joueur au centre, large de [scale] de l'espace.
class SceneBackdrop21 extends StatelessWidget {
  final J s;
  final int n;
  final double scale;
  const SceneBackdrop21(this.s, this.n, {super.key, this.scale = .42});
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: sceneGrads21[n % sceneGrads21.length]))),
        Align(alignment: Alignment.center, child: FractionallySizedBox(widthFactor: scale, heightFactor: 1, child: PlayerBust21(s))),
      ]);
}

/// Image d'un clip : l'une des huit scènes avec le joueur, ou la pochette du titre.
class ClipArt21 extends StatelessWidget {
  final J s, song;
  final int n;
  const ClipArt21(this.s, this.song, this.n, {super.key});
  @override
  Widget build(BuildContext context) {
    if (n < 8) return SceneBackdrop21(s, n);
    return Stack(fit: StackFit.expand, children: [
      DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: sceneGrads21[3]))),
      Padding(padding: const EdgeInsets.all(6), child: Center(child: AspectRatio(aspectRatio: 1, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: SvgPicture.asset(trackCover21(song), fit: BoxFit.cover))))),
    ]);
  }
}

/// Ouvre le choix de la miniature d'un clip publié puis enregistre le choix. [auto] : miniature d'office (ambiance de l'ordre du clip).
Future<void> pickClipThumb(BuildContext context, WidgetRef ref, J s, J song, int auto) async {
  final picked = await showGameSheet<int>(context, builder: (ctx) => _ThumbSheet(s, song, auto));
  if (picked == null || !context.mounted) return;
  await doAct(context, ref, 'setthumb', [song['id'], picked < 0 ? null : picked], null, picked < 0 ? 'Miniature automatique' : 'Miniature changée');
}

class _ThumbSheet extends StatelessWidget {
  final J s, song;
  final int auto;
  const _ThumbSheet(this.s, this.song, this.auto);
  @override
  Widget build(BuildContext context) {
    final cur = clipThumb21(song, auto);
    final custom = _clip(song)['thumb'] is int;
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('MINIATURE DU CLIP', style: V20Text.lab()),
      const SizedBox(height: 4),
      Text('${song['title']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
      if (custom) ...[
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: Chip21('Miniature automatique', onTap: () => Navigator.of(context).pop(-1))),
      ],
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (var n = 0; n < 9; n++)
            SizedBox(
              width: w,
              child: Semantics(
                button: true,
                selected: n == cur,
                label: 'Miniature ${n < 8 ? sceneNames21[n] : 'pochette du titre'}',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(n),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: n == cur ? Tk.acc : Colors.transparent, width: 2)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(fit: StackFit.expand, children: [
                          ClipArt21(s, song, n),
                          Positioned(left: 6, bottom: 4, child: Text(n < 8 ? sceneNames21[n] : 'Pochette', style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w700))),
                          if (n == cur) const Positioned(right: 4, top: 4, child: DecoratedBox(decoration: BoxDecoration(color: Tk.acc, shape: BoxShape.circle), child: Padding(padding: EdgeInsets.all(2), child: GameIcon('check', size: 12, color: Tk.bg)))),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ]);
      }),
    ]);
  }
}

Map _clip(J song) => song['clip'] is Map ? song['clip'] as Map : const {};
