import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/mini_game_parts.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/minigame.dart';
import '../shell/tired_sheet.dart';

/// Mini-jeu des prises (04.8) : port de mini() de game.js. Le curseur va et vient, REC note la prise selon l'écart avec la zone verte ;
/// après trois prises, record() reçoit les trois notes. « Simuler les 3 prises » garde les notes de démo du prototype.
class PrisesScreen extends ConsumerStatefulWidget {
  const PrisesScreen({super.key});
  @override
  ConsumerState<PrisesScreen> createState() => _PrisesScreenState();
}

class _PrisesScreenState extends ConsumerState<PrisesScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _now = Duration.zero, _takeStart = Duration.zero;
  final List<int> _takes = [];
  String _message = 'Appuie sur REC quand le curseur est dans la zone verte.';
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => setState(() => _now = elapsed))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _cursor => cursorAt((_now - _takeStart).inMicroseconds / Duration.microsecondsPerSecond);

  Future<void> _rec() async {
    if (_done) return;
    final score = takeScore(_cursor, _takes.length);
    setState(() {
      _takes.add(score);
      _message = takeMessage(score);
      _takeStart = _now;
    });
    if (_takes.length < takesPerSession) return;
    _done = true;
    try {
      await ref.read(gameProvider.notifier).recordSession(List.of(_takes));
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _done = false;
        _takes.clear();
        _message = 'Appuie sur REC quand le curseur est dans la zone verte.';
      });
      showGameError(context, ref, e);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) context.go('/studio/mix');
  }

  Future<void> _simulate() async {
    try {
      await ref.read(gameProvider.notifier).recordSession();
      if (mounted) context.go('/studio/mix');
    } on Object catch (e) {
      if (mounted) showGameError(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final take = _takes.length.clamp(0, takesPerSession - 1);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Center(child: GameTag('Mini-jeu réel · note de démo', style: GameTagStyle.outline)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Prise en cours', style: V20Text.nm()),
        const GameTag('$takesPerSession prises', style: GameTagStyle.accent),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        for (var i = 0; i < takesPerSession; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: i < _takes.length ? TakeChip('Prise ${i + 1} · ${_takes[i]}', done: true) : TakeChip('Prise ${i + 1}')),
        ],
      ]),
      const SizedBox(height: 14),
      MiniGameTrack(cursor: _done ? 0.5 : _cursor, zone: zoneCenter(take)),
      const SizedBox(height: 14),
      Text(_message, textAlign: TextAlign.center, style: V20Text.bs()),
      const SizedBox(height: 14),
      Center(child: RecButton(onPressed: _done ? null : _rec)),
      const SizedBox(height: 14),
      const GameHint(icon: 'info', text: 'Le mini-jeu fonctionne : ton timing fixe la note de voix. Si le script est indisponible, utilise « Simuler ».'),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Simuler les 3 prises', style: GameButtonStyle.secondary, compact: true, onPressed: _done ? null : _simulate),
    ]);
  }
}
