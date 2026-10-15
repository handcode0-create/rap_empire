import 'package:flutter/material.dart';
import '../theme/v20.dart';
import 'game_tag.dart';
import 'meter_bar.dart';
import 'primary_button.dart';

/// Carte objectif / mission (.obj de v20.css) : dégradé 135°, pastille décorative, titre Baloo 24 en majuscules, jauge verte et bouton sombre.
/// [statusTag] (ex. « Terminée ») s'affiche à côté de l'étiquette de mission ; [rewards] : puces de récompense (RewardChip).
class MissionCard extends StatelessWidget {
  final String kicker, tag, title, actionLabel;
  final String? hint, statusTag;
  final double? progress;
  final List<Widget> rewards;
  final VoidCallback? onAction;
  const MissionCard({
    super.key,
    this.kicker = 'Objectif en cours',
    required this.tag,
    required this.title,
    required this.actionLabel,
    this.hint,
    this.statusTag,
    this.progress,
    this.rewards = const [],
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(gradient: V20.objective, borderRadius: BorderRadius.circular(24), boxShadow: V20.objectiveShadow),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(children: [
            const Positioned(
              right: -30,
              top: -30,
              child: SizedBox(width: 150, height: 150, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, .12)))),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: Text(kicker.toUpperCase(), style: V20Text.lab(color: Colors.white))),
                  const SizedBox(width: 8),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    if (statusTag != null) ...[GameTag(statusTag!, style: GameTagStyle.ok), const SizedBox(width: 6)],
                    GameTag(tag, style: GameTagStyle.outline, color: Colors.white),
                  ]),
                ]),
                const SizedBox(height: 6),
                Text(title.toUpperCase(), style: V20Text.baloo(size: 24, line: 24, color: Colors.white)),
                if (hint != null) ...[const SizedBox(height: 6), Text(hint!, style: V20Text.bs(color: Colors.white))],
                if (progress != null) ...[const SizedBox(height: 6), MeterBar(value: progress!, tone: MeterTone.ok)],
                if (rewards.isNotEmpty) ...[const SizedBox(height: 6), Wrap(spacing: 8, runSpacing: 4, children: rewards)],
                const SizedBox(height: 6),
                PrimaryButton(label: actionLabel, onPressed: onAction, style: GameButtonStyle.dark),
              ]),
            ),
          ]),
        ),
      );
}
