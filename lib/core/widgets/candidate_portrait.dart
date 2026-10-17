import 'package:flutter/material.dart';
import 'character_view.dart';

/// Portrait généré par tools/design pour un profil de la vie personnelle.
class CandidatePortrait extends StatelessWidget {
  final String id;
  final double size;
  const CandidatePortrait(this.id, {super.key, this.size = 56});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Portrait de ${id[0].toUpperCase()}${id.substring(1)}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * .24),
          child: SizedBox.square(
            dimension: size,
            child: CharacterView(who: id, mood: 'smile', crop: 'bust'),
          ),
        ),
      );
}
