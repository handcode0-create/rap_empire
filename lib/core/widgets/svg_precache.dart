import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/tokens.dart';

/// Précharge des illustrations SVG (pochettes, miniatures) une par une au démarrage, pour qu'elles s'affichent
/// tout de suite dans les listes, y compris sur iPhone où le premier décodage est plus lent.
Future<void> precacheSvgs(Iterable<String> paths) async {
  for (final p in paths) {
    final loader = SvgAssetLoader(p);
    try {
      await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    } on Object {
      // fichier absent : le widget affichera son repli
    }
  }
}

/// Repli pendant le chargement d'une pochette ou d'une miniature : jamais une case vide.
class SvgLoadingPlaceholder extends StatelessWidget {
  final double radius;
  const SvgLoadingPlaceholder({super.key, this.radius = 10});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Tk.tint, Tk.s2, Tk.deep]),
        ),
        child: const Center(child: Icon(Icons.music_note_rounded, color: Color(0x66FFFFFF), size: 20)),
      );
}
