import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

enum ToastKind { success, error, info }

/// Toast (.toast de rap.css) : bande latérale de 4 px (vert succès, magenta erreur, gris info), texte Poppins 800 en majuscules, fond s2.
class GameToast extends StatelessWidget {
  final String message;
  final ToastKind kind;
  const GameToast({super.key, required this.message, this.kind = ToastKind.info});

  Color get _stripe => switch (kind) {
        ToastKind.success => Tk.ok,
        ToastKind.error => Tk.acc,
        ToastKind.info => V20.ink2,
      };

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        label: message,
        child: Container(
          decoration: BoxDecoration(color: Tk.s2, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, .4), blurRadius: 24, offset: Offset(0, 8))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(width: 4, color: _stripe),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(padding: const EdgeInsets.fromLTRB(0, 12, 16, 12), child: Text(message.toUpperCase(), style: V20Text.btt)),
                ),
              ]),
            ),
          ),
        ),
      );
}

OverlayEntry? _current;

/// Affiche un toast en haut de l'écran (comme .toast.top : sous la barre d'état), 3 s, sans jamais couvrir les boutons du bas.
void showGameToast(BuildContext context, String message, {ToastKind kind = ToastKind.info}) {
  _current?.remove();
  _current = null;
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ToastHost(
      message: message,
      kind: kind,
      onDone: () {
        if (entry.mounted) entry.remove();
        if (identical(_current, entry)) _current = null;
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

class _ToastHost extends StatefulWidget {
  final String message;
  final ToastKind kind;
  final VoidCallback onDone;
  const _ToastHost({required this.message, required this.kind, required this.onDone});
  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost> {
  Timer? _hide, _remove;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _hide = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _visible = false);
    });
    _remove = Timer(const Duration(milliseconds: 3100), widget.onDone);
  }

  @override
  void dispose() {
    _hide?.cancel();
    _remove?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.of(context).disableAnimations;
    return Positioned(
      left: 16,
      right: 16,
      top: MediaQuery.of(context).padding.top + 16,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
          child: GameToast(message: widget.message, kind: widget.kind),
        ),
      ),
    );
  }
}
