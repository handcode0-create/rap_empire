import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../domain/missions.dart';
import '../../domain/rules.dart';

/// Journal (03.3). Aucun événement n'est défini dans game.js : le journal liste ce que la partie sait vraiment (niveau à récupérer,
/// missions terminées, nouvelle mission, dernière sortie) plus l'entrée d'accueil de la planche. Le défi de K-Zer d'Mabaya (03.5) n'est pas porté.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final day = 'Jour ${s.day}';
    final entries = <Widget>[];
    void add(String icon, String title, String subtitle, {String? tag, required String route}) {
      entries
        ..add(const SizedBox(height: 12))
        ..add(ActionRow(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: () => context.go(route),
          trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            Text(day.toUpperCase(), style: V20Text.lab()),
            if (tag != null) ...[const SizedBox(height: 4), GameTag(tag, style: GameTagStyle.accent)],
          ]),
        ));
    }

    if (s.pend != null) add('trophy', 'Niveau supérieur', 'Niveau ${s.pend!.lvl} à récupérer', tag: 'Nouveau', route: '/niveau');
    for (final id in missionTitles.keys) {
      if (s.ms[id] == 'done') add('trophy', 'Mission terminée', missionTitles[id]!, tag: 'À récupérer', route: '/missions');
    }
    final next = currentObjective(s);
    if (next != null && s.ms[next.id] == 'todo') add('trophy', 'Nouvelle mission', next.title, tag: 'Nouveau', route: '/missions');
    if (s.rel != null) add('music', 'Sortie', '${s.rel!.title} · ${fmt(s.rel!.listens)} écoutes', route: '/studio/resultats');
    add('users', 'Bienvenue dans la street', 'Ton aventure commence', route: '/');
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Journal', onBack: () => context.go('/')),
      ...entries,
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Le journal liste les événements de la démo. Les notifications de sortie, de concert ou de classement s’y ajouteront avec les règles de la version jouable.'),
    ]);
  }
}
