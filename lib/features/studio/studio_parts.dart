import 'package:flutter/material.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_cover.dart';
import '../../domain/rules.dart';
import '../../domain/studio_models.dart';

/// Carte du son (planches 04.2, 05.1, 05.2) : pochette 64, titre, style et instru, qualité à droite.
class SongHeaderCard extends StatelessWidget {
  final Song song;
  final String styleName;
  const SongHeaderCard({super.key, required this.song, required this.styleName});

  @override
  Widget build(BuildContext context) => GameCard(
        selected: true,
        child: Row(children: [
          const GameCover(size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(song.title, style: V20Text.nm()),
              Text('$styleName · instru ${song.inst}', style: V20Text.bs()),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            Text('QUALITÉ', style: V20Text.lab()),
            Text(fmt(song.q), style: V20Text.baloo(size: 30, line: 30)),
          ]),
        ]),
      );
}
