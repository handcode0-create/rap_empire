import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_tile.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/toast.dart';
import 'studio_parts.dart';

/// Studio : 04.1 (studio vide) ou 04.2 (un son à sortir), avec reprise de l'étape en cours et discographie.
class StudioHomeScreen extends ConsumerWidget {
  const StudioHomeScreen({super.key});

  /// Étape à reprendre déduite de l'état sauvegardé (restauration de l'écran au rechargement) : titre, étiquette d'étape, route.
  static (String, String, String)? _resume(StudioStep step) => switch (step) {
        StudioStep.instru || StudioStep.sortie => null,
        StudioStep.ecriture => ('Écrire le texte', 'Étape 2 / 3', '/studio/ecriture'),
        StudioStep.cabine => ('Session cabine', 'Étape 3 / 3', '/studio/cabine'),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final pending = s.song != null && !s.song!.released;
    final count = songCount(s);
    final resume = _resume(studioStep(s));
    final styleName = styleNames[s.style] ?? '';
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (count == 0) ...[
        SceneBanner(
          kind: 'studio',
          height: 190,
          nameSize: 32,
          role: 'Studio Kôrô · ${s.hood}',
          name: 'Aucun son enregistré',
          chars: const [BannerChar('kore', mood: 'smile', crop: 'torso', width: 100, left: 280)],
        ),
        const SizedBox(height: 12),
        Text('Choisis une instru, écris ton texte, passe en cabine. Ton premier son ouvre la sortie, les fans et le classement.', style: V20Text.bm),
      ] else ...[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text('STUDIO', style: V20Text.baloo(size: 28, line: 28))),
          GameTag('$count son${count > 1 ? 's' : ''}', style: GameTagStyle.accent),
        ]),
      ],
      if (pending) ...[
        const SizedBox(height: 12),
        SongHeaderCard(song: s.song!, styleName: styleName),
        const SizedBox(height: 12),
        KpiRow(children: [StatKpi(label: 'Texte', value: fmt(s.song!.texte)), StatKpi(label: 'Voix', value: fmt(s.song!.voix)), StatKpi(label: 'Prod.', value: fmt(s.song!.prod))]),
        if (count == 1) ...[
          const SizedBox(height: 12),
          GameCard(dashed: true, child: Center(child: Text('Emplacement libre. Enregistre un deuxième son.', textAlign: TextAlign.center, style: V20Text.bs()))),
        ],
        const SizedBox(height: 12),
        PrimaryButton(label: 'Préparer la sortie', sublabel: 'Single · promo · mise en ligne', onPressed: () => context.go('/studio/sortie')),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Nouveau son', style: GameButtonStyle.secondary, onPressed: () => context.go('/studio/instru')),
      ] else ...[
        if (resume != null) ...[
          const SizedBox(height: 12),
          GameCard(
            selected: true,
            onTap: () => context.go(resume.$3),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text('Reprendre', style: V20Text.nm())),
                GameTag(resume.$2, style: GameTagStyle.ok),
              ]),
              Text(resume.$1, style: V20Text.bs()),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        PrimaryButton(label: 'Nouveau son', sublabel: '3 étapes : instru · texte · cabine', onPressed: () => context.go('/studio/instru')),
      ],
      if (s.disco.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text('DISCOGRAPHIE', style: V20Text.lab()),
        const SizedBox(height: 8),
        for (final d in s.disco.reversed) ...[
          BeatCard(
            leading: const GameCover(size: 48),
            title: d.title,
            subtitle: 'Qualité ${d.q}',
            trailing: Text('${fmt(d.listens)} écoutes', style: V20Text.nm(color: Tk.cy).copyWith(fontSize: 14)),
          ),
          const SizedBox(height: 8),
        ],
      ],
      if (!pending) ...[
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: ActionTile(icon: 'music', title: 'Instrus', subtitle: 'Gratuite ou à acheter', onTap: () => context.go('/studio/instru'))),
            const SizedBox(width: 10),
            Expanded(child: ActionTile(icon: 'briefcase', title: 'Matériel', subtitle: 'Micro, casque', onTap: () => showInfo(context, 'Matériel : bientôt'))),
          ]),
        ),
      ],
    ]);
  }
}
