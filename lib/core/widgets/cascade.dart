import 'package:flutter/material.dart';
import '../theme/neon_tokens.dart';

/// Révélation en cascade : chaque enfant apparaît (fondu + glissement de 12 px) 80 ms après le précédent.
/// Sans animation si le système la désactive. Le contenu est dans l'arbre dès la première image (tests et lecteurs d'écran).
class Cascade extends StatefulWidget {
  final List<Widget> children;
  const Cascade({super.key, required this.children});

  @override
  State<Cascade> createState() => _CascadeState();
}

class _CascadeState extends State<Cascade> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final t = NeonTokens.of(context);
    _c.duration = t.cascadeStep * widget.children.length + t.base;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final total = (t.cascadeStep * widget.children.length + t.base).inMilliseconds.toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < widget.children.length; i++)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              final start = t.cascadeStep.inMilliseconds * i / total, end = (t.cascadeStep.inMilliseconds * i + t.base.inMilliseconds) / total;
              final p = t.enter.transform(Interval(start, end).transform(_c.value));
              return Opacity(opacity: p, child: Transform.translate(offset: Offset(0, 12 * (1 - p)), child: child));
            },
            child: widget.children[i],
          ),
        ),
    ]);
  }
}
