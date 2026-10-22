import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../domain/v21/reg21.dart';

/// Écrans où le temps s'arrête : création du personnage, scènes à choix, cabine, battles, fin de journée et bilan.
bool clockPaused21(String path) =>
    const ['/demarrer', '/nouvelle-partie', '/univers', '/artiste', '/demo', '/fin-journee', '/bilan', '/dialogue', '/evenement', '/famille/evenement', 'cabine', 'battle']
        .any(path.contains);

/// Horloge en temps réel (une journée ≈ 45 s) : l'heure avance toute seule ; à minuit, la scène de fin de journée s'ouvre.
class DayClock21 extends ConsumerStatefulWidget {
  final GoRouter router;
  final Widget child;
  final Duration tick;
  const DayClock21({super.key, required this.router, required this.child, this.tick = const Duration(milliseconds: Reg21.tickMs)});
  @override
  ConsumerState<DayClock21> createState() => _DayClock21State();
}

class _DayClock21State extends ConsumerState<DayClock21> with WidgetsBindingObserver {
  Timer? _timer;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(widget.tick, (_) => _step());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _active = state == AppLifecycleState.resumed;

  void _step() {
    if (!_active || !mounted) return;
    final s = ref.read(game21Provider).valueOrNull;
    if (s == null || s['created'] != 1) return;
    final path = widget.router.routerDelegate.currentConfiguration.uri.path;
    if (clockPaused21(path)) return;
    final hour = (s['hour'] is num ? s['hour'] as num : 0);
    if (hour >= Reg21.dayEnd) {
      widget.router.go('/fin-journee');
    } else {
      ref.read(game21Provider.notifier).act('tick');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
