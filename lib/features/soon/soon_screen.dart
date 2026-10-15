import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Écran provisoire des onglets pas encore portés.
class SoonScreen extends StatelessWidget {
  final String title;
  const SoonScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.hourglass_empty_rounded, color: Tk.ink2, size: 40),
            const SizedBox(height: 16),
            Text('Bientôt', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('$title arrive dans une prochaine étape.', textAlign: TextAlign.center, style: const TextStyle(color: Tk.ink2)),
          ]),
        ),
      );
}
