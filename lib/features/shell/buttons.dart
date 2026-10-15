import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Bouton principal (56 px, magenta) et bouton secondaire. Cibles tactiles >= 48 px.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Tk.acc,
          foregroundColor: Tk.ink,
          minimumSize: const Size.fromHeight(Tk.btnH),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rCard)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        child: Text(label),
      );
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const GhostButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Tk.ink,
          side: const BorderSide(color: Tk.line),
          minimumSize: const Size.fromHeight(Tk.minTap),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rCard)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        child: Text(label),
      );
}
