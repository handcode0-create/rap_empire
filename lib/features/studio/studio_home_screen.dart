import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_tile.dart';
import '../../core/widgets/hero_stat.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/rules.dart';
import '../../domain/studio.dart';
import '../shell/toast.dart';

/// Studio : 04.1 (studio vide) ou 04.2 (un son à sortir), avec reprise de l'étape en cours et discographie · Direction Néon de Bakoma.
/// Intention : l'envie de créer. Studio vide : la bannière de la cabine de Kôrô et UN bouton, « Nouveau son ». Un son à sortir : sa qualité en chiffre
/// héroïque, ses trois notes, puis « Préparer la sortie ». Un seul son à la fois : le bouton « Nouveau son » attend la sortie du son en cours.
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
    final song = s.song;
    final pending = song != null && !song.released;
    final count = songCount(s);
    final resume = _resume(studioStep(s));
    final styleName = styleNames[s.style] ?? '';
    // Première visite au Studio : DJ Kôrô écoute (planche 16-A1). L'écran marque l'introduction comme montrée.
    if (s.koreIntro && s.kc.st.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/dialogue/ecoute-kore');
      });
    }
    // Offre de Kôrô encore ouverte (A2) ou sa relance après un refus (A6) : toujours joignable depuis le Studio.
    final koreRoute = s.koreIntro ? null : (s.kc.st.isEmpty ? '/dialogue/offre-kore' : (s.kc.st == 'ref' ? '/dialogue/retour-kore' : null));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
      if (count == 0) ...[
        LayoutBuilder(
          builder: (context, c) => SceneBanner(
            kind: 'studio',
            height: 190,
            nameSize: 32,
            role: 'Studio Kôrô · ${s.hood}',
            name: 'Aucun son enregistré',
            chars: [BannerChar('kore', mood: 'smile', crop: 'torso', width: 100, left: c.maxWidth - 110)],
          ),
        ),
        const SizedBox(height: 12),
        Text('Choisis une instru, écris ton texte, passe en cabine. Ton premier son ouvre la sortie, les fans et le classement.', style: V20Text.bm),
      ] else ...[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text('STUDIO', style: V20Text.baloo(size: 28, line: 28).copyWith(shadows: const [Shadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 14, offset: Offset(0, 2))]))),
          GameTag('$count son${count > 1 ? 's' : ''}', style: GameTagStyle.accent),
        ]),
      ],
      if (koreRoute != null) ...[
        const SizedBox(height: 12),
        GlassCard(
          onTap: () => context.go(koreRoute),
          semanticLabel: 'DJ Kôrô, ${s.kc.st.isEmpty ? 'une offre t’attend' : 'Kôrô revient'}',
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('DJ Kôrô', style: V20Text.nm()),
                Text(s.kc.st.isEmpty ? 'Une offre t’attend au studio.' : 'Kôrô a gardé un créneau pour toi.', style: V20Text.bs()),
              ]),
            ),
            const SizedBox(width: 8),
            GameTag(s.kc.st.isEmpty ? 'Offre' : 'Retour', style: GameTagStyle.accent),
          ]),
        ),
      ],
      if (pending) ...[
        const SizedBox(height: 12),
        GlassCard(
          accent: GlassAccent.gold,
          halo: false, // le halo fort de l'écran est celui de « Préparer la sortie »
          child: Row(children: [
            const GameCover(size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(song.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
                Text('$styleName · instru ${song.inst}', style: V20Text.bs()),
                if (song.viral > 0) Text('Potentiel viral ${song.viral}', style: V20Text.bs()),
              ]),
            ),
            const SizedBox(width: 8),
            HeroStat(label: 'Qualité', value: song.q, size: 40, color: Tk.gold, align: CrossAxisAlignment.end),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: HeroStat(label: 'Texte', value: song.texte, size: 26)),
              const VerticalDivider(width: 17, thickness: 1, color: Color.fromRGBO(255, 255, 255, .10)),
              Expanded(child: HeroStat(label: 'Voix', value: song.voix, size: 26)),
              const VerticalDivider(width: 17, thickness: 1, color: Color.fromRGBO(255, 255, 255, .10)),
              Expanded(child: HeroStat(label: 'Prod.', value: song.prod, size: 26)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(child: Center(child: Text('Un seul son à la fois : sors celui-ci pour en enregistrer un autre.', textAlign: TextAlign.center, style: V20Text.bs()))),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Préparer la sortie', sublabel: 'Single · promo · mise en ligne', onPressed: () => context.go('/studio/sortie')),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Nouveau son', sublabel: 'Sors ton son d’abord', style: GameButtonStyle.secondary, onPressed: () => showInfo(context, 'Sors ton son en attente avant d’en créer un autre')),
      ] else ...[
        if (resume != null) ...[
          const SizedBox(height: 12),
          GlassCard(
            accent: GlassAccent.magenta,
            halo: false,
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
        PrimaryGlowButton(label: 'Nouveau son', sublabel: '3 étapes : instru · texte · cabine', onPressed: () => context.go('/studio/instru')),
      ],
      if (s.disco.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text('DISCOGRAPHIE', style: V20Text.lab(color: Colors.white)),
        const SizedBox(height: 8),
        for (final d in s.disco.reversed) ...[
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const GameCover(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
                  Text('Qualité ${d.q}', style: V20Text.bs()),
                ]),
              ),
              const SizedBox(width: 8),
              Text('${fmt(d.listens)} écoutes', style: V20Text.nm(color: Tk.cy).copyWith(fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ],
      if (!pending) ...[
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: GlassTile(icon: 'music', title: 'Instrus', subtitle: 'Gratuite ou à acheter', onTap: () => context.go('/studio/instru'))),
            const SizedBox(width: 10),
            Expanded(child: GlassTile(icon: 'briefcase', title: 'Matériel', subtitle: 'Micro, casque', onTap: () => showInfo(context, 'Matériel : bientôt'))),
          ]),
        ),
      ],
    ]);
  }
}
