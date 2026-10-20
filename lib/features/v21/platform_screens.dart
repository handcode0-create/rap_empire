import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'widgets21.dart';

/// Plateformes fictives : liste (21-D1), Ondéa (21-D2), Klipo (21-D3), Cauri Music (21-D4).
/// Intention de jeu : lire d'où viennent ses écoutes. Aucune de ces pages ne crée de revenu : elles répartissent des écoutes déjà comptées.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic> ? x : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

class _Logo extends StatelessWidget {
  final String name;
  final double size;
  const _Logo(this.name, this.size);
  @override
  Widget build(BuildContext context) => SvgPicture.asset('assets/svg/logo-$name.svg', width: size, height: size);
}

/// En-tête commun des pages d'une plateforme : retour, nom, logo à droite.
class _PfHeader extends StatelessWidget {
  final String title, logo;
  const _PfHeader(this.title, this.logo);
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: BackHeader(title: title, onBack: () => context.go('/profil/plateformes'))),
        _Logo(logo, 40),
      ]);
}

List<J> _disco(J s) => _l(s['disco']).map(_m).toList();

/// Cartouche de marque : chaque plateforme possède sa propre palette et sa hiérarchie visuelle.
class _PlatformHero extends StatelessWidget {
  final String logo, eyebrow, value, detail;
  final Color start, end, accent;
  final int? thumbnailIndex;
  const _PlatformHero({required this.logo, required this.eyebrow, required this.value, required this.detail, required this.start, required this.end, required this.accent, this.thumbnailIndex});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [start, end]),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: accent.withValues(alpha: .55)),
      boxShadow: [BoxShadow(color: accent.withValues(alpha: .12), blurRadius: 22, offset: const Offset(0, 8))],
    ),
    child: Row(children: [
      _Logo(logo, 58),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow, style: V20Text.lab(color: accent)),
        const SizedBox(height: 5),
        Text(value, style: V20Text.baloo(size: 27, line: 30)),
        const SizedBox(height: 3),
        Text(detail, style: V20Text.bs(color: Tk.ink)),
      ])),
      if (thumbnailIndex != null) ...[
        const SizedBox(width: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 88,
            height: 66,
            child: Stack(fit: StackFit.expand, children: [
              SvgPicture.asset(
                'assets/klipo/thumbs/T${(thumbnailIndex! % 50 + 1).toString().padLeft(3, '0')}.svg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF171323)),
              ),
              const ColoredBox(color: Color.fromRGBO(12, 8, 32, .28)),
              const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 30)),
            ]),
          ),
        ),
      ],
    ]),
  );
}


class _Row extends StatelessWidget {
  final Widget lead;
  final String title, sub;
  final String? note;
  const _Row({required this.lead, required this.title, required this.sub, this.note});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: V20Text.nm()),
            Text(sub, style: V20Text.bs()),
          ])),
          if (note != null) Text(note!, style: V20Text.bs(color: Tk.ink)),
        ]),
      );
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-D1 Plateformes
// ---------------------------------------------------------------------------------------------------------------------

class PlateformesScreen extends ConsumerWidget {
  const PlateformesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final none = _disco(s).isEmpty;
    Widget card(String logo, String name, String sub, int value, String route) {
      final accent = logo == 'ondea' ? const Color(0xFF3CD6F2) : logo == 'klipo' ? const Color(0xFFFF4DA6) : const Color(0xFFFFC83D);
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: accent.withValues(alpha: .65))),
          child: GameCard(
            onTap: () => context.go(route),
            child: Row(children: [
              _Logo(logo, 56),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: V20Text.nm()), Text(sub, style: V20Text.bs())])),
              const SizedBox(width: 8),
              Text(fmt21(value), style: V20Text.baloo(size: 20, line: 22, color: accent)),
            ]),
          ),
        ),
      );
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Plateformes', step: 'Proposé · à valider', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Plateformes fictives de l’univers de Bakoma. Elles répartissent les écoutes déjà calculées par le jeu : aucun revenu ni aucune écoute en plus.'),
      if (none)
        const Padding(
            padding: EdgeInsets.only(top: 12),
            child: GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Aucun titre sorti'),
              SizedBox(height: 4),
              Text('Sors un single pour apparaître sur les plateformes.'),
            ]))),
      card('ondea', 'Ondéa', 'Streaming audio · ${fmt21(t.listeners)} auditeurs estimés', t.ondea, '/profil/plateformes/ondea'),
      card('klipo', 'Klipo', 'Vidéos et clips · ${t.clips} clip(s)', t.klipoViews, '/profil/plateformes/klipo'),
      card('cauri', 'Cauri Music', 'Écoute premium et téléchargements', t.cauri, '/profil/plateformes/cauri'),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('RÉPARTITION PROVISOIRE', style: V20Text.lab()), const GameTag('Proposé')]),
        KeyVal('Ondéa', '${((Reg21.platforms['ondea']!['share'] as num) * 100).round()} % des écoutes audio'),
        KeyVal('Cauri Music', '${((Reg21.platforms['cauri']!['share'] as num) * 100).round()} % des écoutes audio'),
        KeyVal('Klipo', 'vues des clips publiés (${Reg21.platforms['klipo']!['viewsPerClipListen']} vues par écoute apportée par le clip)'),
      ])),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-D2 Ondéa
// ---------------------------------------------------------------------------------------------------------------------

class OndeaScreen extends ConsumerWidget {
  const OndeaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final disco = _disco(s);
    final share = Reg21.platforms['ondea']!['share'] as num;
    final rank = singlesRank(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const _PfHeader('Ondéa', 'ondea'),
      const SizedBox(height: 12),
      Column(children: [
        _PlatformHero(logo: 'ondea', eyebrow: 'ONDEA ORIGINAL · STREAMING AUDIO', value: '${fmt21(t.listeners)} auditeurs', detail: '${fmt21(t.followers)} abonnés · artiste : ${playerName(s)}', start: const Color(0xFF102B48), end: const Color(0xFF29245B), accent: const Color(0xFF3CD6F2)),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight, child: Text('Profil artiste vérifié · univers fictif', style: V20Text.bs())),
      ]),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TITRES POPULAIRES', style: V20Text.lab()), Text('écoutes Ondéa', style: V20Text.bs())]),
        if (disco.isEmpty) Text('Aucun titre sorti.', style: V20Text.bs()),
        for (var i = 0; i < disco.length && i < 5; i++)
          _Row(
              lead: Text('${i + 1}'),
              title: '${i + 1}  ${disco[i]['title']}',
              sub: '${disco[i]['tier']}',
              note: fmt21(jsRound(platformListens(disco[i]) * share))),
      ])),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PLAYLISTS', style: V20Text.lab()),
        KeyVal('Top 100 Singles (13.2)', rank == 0 ? 'Non classé' : '#$rank'),
        KeyVal('Revenus Ondéa (${Reg21.listenValue.toString().replaceAll('.', ',')} cauri / écoute)', '${fmt21(t.revOndea)} cauris'),
      ])),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Auditeurs estimés : 35 % des écoutes cumulées ; abonnés : 60 % des fans. Valeurs provisoires.'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-D3 Klipo
// ---------------------------------------------------------------------------------------------------------------------

/// Vignette d'un clip Klipo : pochette du titre en 16:9 avec un bouton lecture (SVG extraits des planches : assets/svg/pochette-*).
class _ClipThumb extends StatelessWidget {
  final int index;
  const _ClipThumb({required this.index});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Vignette du clip',
        excludeSemantics: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 112,
            height: 63,
            child: Stack(fit: StackFit.expand, children: [
              SvgPicture.asset(
                'assets/klipo/thumbs/T${(index % 50 + 1).toString().padLeft(3, '0')}.svg',
                fit: BoxFit.cover,
                semanticsLabel: 'Vignette du clip',
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF171323)),
              ),
              const ColoredBox(color: Color.fromRGBO(12, 8, 32, .35)),
              const Center(child: Icon(Icons.play_circle_fill_rounded, color: Tk.ink, size: 30)),
            ]),
          ),
        ),
      );
}

class KlipoScreen extends ConsumerWidget {
  const KlipoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final vpl = Reg21.platforms['klipo']!['viewsPerClipListen'] as num;
    final clips = _disco(s).where((x) => x['clip'] is Map && (x['clip'] as Map)['st'] == 'publie').toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      const _PfHeader('Klipo', 'klipo'),
      const SizedBox(height: 12),
      _PlatformHero(logo: 'klipo', eyebrow: 'KLIPO · VIDÉO / CLIPS', value: '${fmt21(t.klipoViews)} vues', detail: 'Chaîne de ${playerName(s)} · ${t.clips} clip(s) publié(s)', start: const Color(0xFF351029), end: const Color(0xFF701B50), accent: const Color(0xFFFF4DA6), thumbnailIndex: clips.isEmpty ? 0 : _disco(s).indexOf(clips.last)),
      const SizedBox(height: 12),
      if (clips.isEmpty) ...[
        const GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aucun clip publié'),
          SizedBox(height: 4),
          Text('Un clip se prépare avant la sortie et se publie après (21.M4).'),
        ])),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Préparer un clip', onPressed: () => context.go('/studio/clip')),
      ],
      for (final c in clips) ...[
        GameCard(
            child: Row(children: [
          _ClipThumb(index: _disco(s).indexOf(c)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${c['title']}', style: V20Text.nm()),
            Text('${fmt21(jsRound(_n(c['clipL']) * vpl))} vues', style: V20Text.bs()),
            Text('Réalisé par ${Reg21.directors[(c['clip'] as Map)['dir']]?['n'] ?? 'un réalisateur'}', style: V20Text.bs()),
          ])),
        ])),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 4),
      const GameHint(icon: 'info', text: 'Les vues Klipo viennent uniquement des clips publiés. Elles ne comptent pas dans le Top 100 Singles.'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-D4 Cauri Music
// ---------------------------------------------------------------------------------------------------------------------

class CauriMusicScreen extends ConsumerWidget {
  const CauriMusicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final disco = _disco(s);
    final share = Reg21.platforms['cauri']!['share'] as num;
    final ep = bestProject(s, 'EP'), al = bestProject(s, 'Album');
    return ListView(padding: const EdgeInsets.all(16), children: [
      const _PfHeader('Cauri Music', 'cauri'),
      const SizedBox(height: 12),
      _PlatformHero(logo: 'cauri', eyebrow: 'CAURI MUSIC · PREMIUM', value: '${fmt21(t.cauri)} écoutes', detail: 'Revenus estimés : ${fmt21(t.revCauri)} cauris', start: const Color(0xFF352016), end: const Color(0xFF69402D), accent: const Color(0xFFFFC83D)),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PAR TITRE', style: V20Text.lab()),
        if (disco.isEmpty) Text('Aucun titre sorti.', style: V20Text.bs()),
        for (var i = 0; i < disco.length && i < 5; i++) KeyVal('${disco[i]['title']}', '${fmt21(jsRound(platformListens(disco[i]) * share))} écoutes'),
      ])),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ALBUMS ET EP', style: V20Text.lab()),
        KeyVal('Meilleur EP', ep == null ? 'Crée un EP de 3 à 7 titres' : '${ep['title']} · ${fmt21(_n(ep['sales']))} ventes'),
        KeyVal('Meilleur album', al == null ? 'Crée un album de 8 titres ou plus' : '${al['title']} · ${fmt21(_n(al['sales']))} ventes'),
      ])),
    ]);
  }
}
