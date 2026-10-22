import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/reward_burst.dart';
import '../../core/widgets/svg_precache.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'cast21.dart';
import 'library_screens.dart' show Cover21, coverOf21, projectCover21, trackCover21;
import 'widgets21.dart';

/// Classements officiels (21-R2, refonte façon plateforme de streaming), salle des trophées (certifications et cérémonies).
/// Les lignes des autres artistes sont simulées chaque semaine (charts21.dart) ; les lignes du joueur sont calculées
/// à partir de ses vraies écoutes et ventes. Certifications et cérémonies : propositions 18.4 et 18.5, valeurs provisoires.

num _n(dynamic x) => (x ?? 0) as num;

/// Une ligne de classement : rang, titre, artiste, valeur, évolution connue (null si non documentée).
typedef _Entry = ({String t, String a, String v, String? mv, String? cover});

/// Classement de l'univers de la semaine (charts21.dart : nouveaux titres chaque semaine, montée puis baisse).
List<_Entry> _board(String board, num day) => [
      for (final r in chart21(board, day))
        (t: r.t, a: board == 'global' ? 'Indice d\'artiste' : r.a, v: board == 'global' ? d1(r.value) : chartVal21(r.value), mv: r.mv, cover: null),
    ];

/// Miniature d'un artiste du catalogue : son premier clip Klipo, sinon une pochette fixe.
String _artThumb(String artist) {
  for (final k in klipo21) {
    if (k['a'] == artist) return k['img'] as String;
  }
  return coverOf21(artist);
}

class _Cover extends StatelessWidget {
  final String path;
  final double size;
  const _Cover(this.path, this.size);
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(path, fit: BoxFit.cover, placeholderBuilder: (_) => const SvgLoadingPlaceholder(), errorBuilder: (_, __, ___) => const SvgLoadingPlaceholder()),
        ),
      );
}

Widget _move(String? mv) {
  if (mv == null) return const SizedBox(width: 30);
  final (txt, c) = mv == 'TOI'
      ? ('TOI', Tk.acc4)
      : mv == 'NEW'
      ? ('NEW', Tk.cy)
      : mv == '='
      ? ('=', V20.ink2)
      : mv.startsWith('-')
          ? ('▼${mv.substring(1)}', Tk.acc4)
          : ('▲${mv.replaceAll('+', '')}', Tk.ok);
  return SizedBox(width: 30, child: Text(txt, textAlign: TextAlign.center, style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w800, color: c)));
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-R2 Classements (refonte)
// ---------------------------------------------------------------------------------------------------------------------

class ClassementsScreen extends ConsumerStatefulWidget {
  const ClassementsScreen({super.key});
  @override
  ConsumerState<ClassementsScreen> createState() => _ClassementsState();
}

class _ClassementsState extends ConsumerState<ClassementsScreen> {
  int _tab = 0;
  static const _tabs = ['Top 100 Singles', 'Top 200 Albums', 'Top 50 EPs', 'Top 10 Global'];
  static const _boards = ['singles', 'albums', 'eps', 'global'];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final week = weekOf21(_n(s['day']));
    final (List<_Entry> board, String unit, List<Color> bg, String artistOrGenre) = switch (_tab) {
      0 => (_board('singles', _n(s['day'])), 'écoutes, 7 j', const [Color(0xFF3B1236), Color(0xFF1F1942)], 'artist'),
      1 => (_board('albums', _n(s['day'])), 'ventes, 7 j', const [Color(0xFF12304A), Color(0xFF1F1942)], 'artist'),
      2 => (_board('eps', _n(s['day'])), 'ventes, 7 j', const [Color(0xFF2A1F08), Color(0xFF1F1942)], 'artist'),
      _ => (_board('global', _n(s['day'])), 'indice', const [Color(0xFF2B1659), Color(0xFF1F1942)], 'genre'),
    };
    // la ligne du joueur prend sa place dans le Top 10 quand son rang de la semaine y est
    final mine = myChart21(s, _boards[_tab]);
    final me = mine == null || mine.rank < 1 || mine.rank > 10
        ? null
        : (
            t: mine.title,
            a: _tab == 3 ? 'Toi · indice d\'artiste' : playerName(s),
            v: _tab == 3 ? d1(mine.value) : chartVal21(mine.value),
            mv: 'TOI',
            cover: _tab == 3 ? null : (_tab == 0 ? trackCover21(mine.item!) : projectCover21(mine.item!)),
          );
    final list = me == null ? board : ([...board]..insert(mine!.rank - 1, me)).take(10).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(child: BackHeader(title: 'Classements', step: 'R2', onBack: () => context.go('/profil'))),
        Semantics(
          button: true,
          label: 'Salle des trophées',
          child: GestureDetector(
            onTap: () => context.go('/profil/trophees'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Tk.s1, border: Border.all(color: Tk.gold.withValues(alpha: .6), width: 1.5)),
              padding: const EdgeInsets.all(6),
              child: SvgPicture.asset('assets/awards/trophee_bakoma.svg'),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      SizedBox(
        height: 48,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (var i = 0; i < _tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_tabs[i], style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: _tab == i ? Tk.bg : Tk.ink)),
                selected: _tab == i,
                selectedColor: Tk.gold,
                backgroundColor: Colors.white.withValues(alpha: .06),
                side: BorderSide(color: _tab == i ? Tk.gold : Colors.white.withValues(alpha: .14)),
                showCheckmark: false,
                onSelected: (_) => setState(() => _tab = i),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      // en-tête façon playlist de plateforme
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bg)),
          child: Row(children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(children: [
                for (var i = 2; i >= 0; i--)
                  Positioned(
                    left: i * 12.0,
                    top: i * 6.0,
                    child: _tab == 3
                        ? CastAvatar(list[i].t, size: 72 - i * 8.0, ring: Tk.gold)
                        : _Cover(list[i].cover ?? _artThumb(list[i].a), 72 - i * 8.0),
                  ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CLASSEMENT OFFICIEL', style: V20Text.lab(color: V20.hintGoldText)),
                FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(_tabs[_tab].toUpperCase(), style: V20Text.baloo(size: 26, line: 28))),
                Text('Semaine $week · $unit', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
                const SizedBox(height: 4),
                const GameTag('Données simulées', style: GameTagStyle.outline),
              ]),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      // podium
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final i in const [1, 0, 2])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _Podium(rank: i + 1, e: list[i], artistTab: _tab == 3, tall: i == 0),
            ),
          ),
      ]),
      const SizedBox(height: 12),
      if (list.length > 3)
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(children: [
            for (var i = 3; i < list.length; i++) _ChartRow(rank: i + 1, e: list[i], artistTab: _tab == 3, sub: artistOrGenre),
          ]),
        ),
      const SizedBox(height: 12),
      _MyPosition(s: s, tab: _tab),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Les autres artistes sont simulés semaine après semaine : de nouveaux titres sortent, montent puis redescendent (NEW = nouvelle entrée). '
              'Ta ligne est calculée à partir de tes vraies écoutes et ventes (R18, R10, R25). Quatre classements officiels, aucun autre.'),
    ]);
  }
}

class _Podium extends StatelessWidget {
  final int rank;
  final _Entry e;
  final bool artistTab, tall;
  const _Podium({required this.rank, required this.e, required this.artistTab, required this.tall});
  @override
  Widget build(BuildContext context) {
    final c = rank == 1 ? Tk.gold : (rank == 2 ? const Color(0xFFD9DEEA) : Tk.acc4);
    return Column(children: [
      Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: artistTab ? CastAvatar(e.mv == 'TOI' ? 'Djo Kéné' : e.t, size: tall ? 84 : 68, ring: c) : _Cover(e.cover ?? _artThumb(e.a), tall ? 84 : 68),
        ),
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c, border: Border.all(color: Tk.bg, width: 2)),
          child: Text('$rank', style: V20Text.baloo(size: 14, line: 16, color: Tk.bg)),
        ),
      ]),
      const SizedBox(height: 6),
      Text(e.t, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: V20Text.poppins(size: 13, line: 17, weight: FontWeight.w700)),
      Text(artistTab ? e.a : e.a, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
      const SizedBox(height: 4),
      Container(
        height: tall ? 56 : 40,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.withValues(alpha: .45), c.withValues(alpha: .08)]),
        ),
        alignment: Alignment.center,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(e.v, style: V20Text.baloo(size: 16, line: 18)),
          if (e.mv != null) _move(e.mv),
        ]),
      ),
    ]);
  }
}

class _ChartRow extends StatelessWidget {
  final int rank;
  final _Entry e;
  final bool artistTab;
  final String sub;
  const _ChartRow({required this.rank, required this.e, required this.artistTab, required this.sub});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: e.mv == 'TOI'
            ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: Tk.tint, border: Border.all(color: Tk.acc, width: 1.5))
            : null,
        child: Row(children: [
          SizedBox(width: 30, child: Text('$rank', textAlign: TextAlign.center, style: V20Text.baloo(size: 18, line: 20, color: Tk.gold))),
          _move(e.mv),
          const SizedBox(width: 6),
          artistTab ? CastAvatar(e.mv == 'TOI' ? 'Djo Kéné' : e.t, size: 44, ring: Tk.gold) : _Cover(e.cover ?? _artThumb(e.a), 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.t, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700)),
              Text(e.a, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
            ]),
          ),
          Text(e.v, style: V20Text.poppins(size: 13, line: 17, weight: FontWeight.w700)),
        ]),
      );
}

/// Carte « Ta position » : rang réel du joueur dans le classement affiché, ou distance à l'entrée.
class _MyPosition extends StatelessWidget {
  final J s;
  final int tab;
  const _MyPosition({required this.s, required this.tab});
  @override
  Widget build(BuildContext context) {
    String title, rank, detail;
    double prog = 0;
    String cover = coverOf21(playerName(s));
    final board = const ['singles', 'albums', 'eps', 'global'][tab];
    final m = myChart21(s, board);
    final r = m?.rank ?? 0;
    rank = r == 0 ? 'Non classé' : '#$r';
    switch (tab) {
      case 0:
        title = m == null ? 'Aucun titre sorti' : m.title;
        if (m != null) cover = trackCover21(m.item!);
        final l = m?.value ?? 0;
        detail = r == 0 ? '${fmt21(l)} / ${fmt21(Reg21.entry)} écoutes sur 7 jours pour entrer au Top 100' : '${fmt21(l)} écoutes sur 7 jours';
        prog = r > 0 ? 1 : (l / Reg21.entry).clamp(0, 1).toDouble();
      case 1 || 2:
        final type = tab == 1 ? 'Album' : 'EP';
        final entry = Reg21.proj[type]!['entry'] as num;
        title = m == null ? (type == 'EP' ? 'Aucun EP' : 'Aucun album') : m.title;
        if (m != null) cover = projectCover21(m.item!);
        detail = m == null
            ? (type == 'EP' ? 'Crée un EP de 3 à 7 titres au studio' : 'Crée un album de 8 titres ou plus au studio')
            : '${fmt21(m.value)} ventes cette semaine · ${_n(m.item!['rank']) > 0 ? 'entré à la ${projectRankLabel(m.item!)}' : 'pas entré au classement à sa sortie'}';
        prog = m == null ? 0 : (r > 0 ? 1 : (m.value / entry).clamp(0, 1).toDouble());
      default:
        final ip = idxParts21(s);
        title = playerName(s);
        detail = r == 0 ? 'Indice ${d1(ip.i)} · le #10 est à ${d1(chartValues21('global', _n(s['day']))[9])}' : 'Indice ${d1(ip.i)}';
        prog = r > 0 ? 1 : (ip.i / chartValues21('global', _n(s['day']))[9]).clamp(0, 1).toDouble();
    }
    return GlassCard(
      accent: GlassAccent.magenta,
      halo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('TA POSITION', style: V20Text.lab(color: V20.accText))),
          Text(rank, style: V20Text.baloo(size: 22, line: 24, color: rank.startsWith('#') ? Tk.gold : V20.ink2)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          tab == 3 ? const CastAvatar('Djo Kéné', size: 52) : _Cover(cover, 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
              Text(detail, style: V20Text.bs()),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        MeterBar(value: prog, tone: MeterTone.gold),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Salle des trophées : le hall, avec deux portes (chambre des certifications, salon des awards)
// ---------------------------------------------------------------------------------------------------------------------

/// Pochette de l'œuvre d'une certification (single de la discographie, EP ou album sorti).
String _certCover(J s, Cert21 c) {
  if (c.kind == 'Single') {
    for (final t in _l(s['disco']).map(_m)) {
      if ('${t['id']}' == c.id) return trackCover21(t);
    }
  } else {
    for (final p in _l(s['projects']).map(_m)) {
      if ('${p['id']}' == c.id) return projectCover21(p);
    }
  }
  return coverOf21(c.id);
}

J _m(dynamic x) => x is Map ? x.map((k, v) => MapEntry('$k', v)) : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

/// Porte d'une salle : grande carte illustrée, chiffre clé, et ce qu'on y trouve.
class _Door extends StatelessWidget {
  final String title, kicker, line;
  final Widget art;
  final Widget badge;
  final GlassAccent accent;
  final VoidCallback onTap;
  const _Door({super.key, required this.title, required this.kicker, required this.line, required this.art, required this.badge, required this.accent, required this.onTap});
  @override
  Widget build(BuildContext context) => GlassCard(
        accent: accent,
        halo: false,
        onTap: onTap,
        semanticLabel: title,
        child: Row(children: [
          SizedBox(width: 72, height: 92, child: art),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(kicker, style: V20Text.lab(color: accent == GlassAccent.gold ? V20.hintGoldText : Tk.cy)),
              Text(title, style: V20Text.baloo(size: 22, line: 24)),
              const SizedBox(height: 2),
              Text(line, style: V20Text.bs()),
              const SizedBox(height: 6),
              badge,
            ]),
          ),
        ]),
      );
}

class TropheesScreen extends ConsumerWidget {
  const TropheesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final certs = certs21(s);
    final best = certs.where((c) => c.level >= 0).toList();
    final (next, days) = nextCeremony21(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Salle des trophées', step: 'T1', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1F08), Tk.s1, Tk.deep])),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TA VITRINE', style: V20Text.lab(color: V20.hintGoldText)),
                  Text(playerName(s), style: V20Text.baloo(size: 26, line: 28)),
                ]),
              ),
              SizedBox(width: 64, height: 86, child: SvgPicture.asset('assets/awards/trophee_${awardWins21(s) > 0 ? 'bakoma' : 'vide'}.svg')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _Count('Certifications', '${certCount21(s)}', Tk.cy),
              _Count('Trophées', '${awardWins21(s)}', Tk.gold),
              _Count('Nominations', '${awardNoms21(s)}', Tk.acc4),
            ]),
            const SizedBox(height: 8),
            Container(height: 6, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: LinearGradient(colors: [Tk.gold.withValues(alpha: .1), Tk.gold.withValues(alpha: .6), Tk.gold.withValues(alpha: .1)]))),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      _Door(
        key: const ValueKey('door-certifs'),
        title: 'Chambre des certifications',
        kicker: 'DISQUES D\'OR, PLATINE, DIAMANT',
        line: best.isEmpty ? 'Aucune plaque pour l\'instant. Chaque sortie compte.' : 'Meilleure plaque : ${best.first.name} · ${best.first.title}',
        art: SvgPicture.asset(certs.isEmpty ? 'assets/awards/plaque_vide.svg' : certs.first.plaque),
        badge: GameTag('${certCount21(s)} plaque(s) · ${certs.length} œuvre(s)', style: GameTagStyle.outline),
        accent: GlassAccent.cyan,
        onTap: () => context.go('/profil/trophees/certifications'),
      ),
      const SizedBox(height: 12),
      _Door(
        key: const ValueKey('door-awards'),
        title: 'Salon des awards',
        kicker: 'CÉRÉMONIES ET PALMARÈS',
        line: '${next.n} · ${days == 0 ? "aujourd'hui" : 'dans $days jour(s)'}',
        art: SvgPicture.asset(next.trophy),
        badge: GameTag('${awardWins21(s)} trophée(s) · ${awardNoms21(s)} nomination(s)', style: GameTagStyle.outline),
        accent: GlassAccent.gold,
        onTap: () => context.go('/profil/trophees/awards'),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Chambre des certifications
// Intention de jeu : voir d'un coup d'œil ce que chaque sortie a gagné, et quelle plaque est la plus proche.
// ---------------------------------------------------------------------------------------------------------------------

double _progress(Cert21 c) {
  final next = c.next;
  if (next == null) return 1;
  final prev = c.level < 0 ? 0 : certThresholds21[c.kind]![c.level];
  return ((c.units - prev) / (next - prev)).clamp(0, 1).toDouble();
}

class CertificationsScreen21 extends ConsumerStatefulWidget {
  const CertificationsScreen21({super.key});
  @override
  ConsumerState<CertificationsScreen21> createState() => _CertificationsState();
}

class _CertificationsState extends ConsumerState<CertificationsScreen21> {
  String _kind = 'Tout';

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final all = certs21(s);
    final shown = _kind == 'Tout' ? all : all.where((c) => c.kind == _kind).toList();
    final perLevel = [for (var i = 0; i < certLevels21.length; i++) all.where((c) => c.level == i).length];
    final chasing = all.where((c) => c.next != null && c.units > 0).toList()..sort((a, b) => _progress(b).compareTo(_progress(a)));
    final target = chasing.isEmpty ? null : chasing.first;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Chambre des certifications', step: 'T2', onBack: () => context.go('/profil/trophees')),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0C2A33), Tk.s1, Tk.deep])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PLAQUES OBTENUES', style: V20Text.lab(color: Tk.cy)),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${certCount21(s)}', style: V20Text.baloo(size: 52, line: 54, color: Tk.cy)),
              const SizedBox(width: 8),
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('sur ${all.length} œuvre(s)', style: V20Text.bs(color: Tk.ink))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              for (var i = 0; i < certLevels21.length; i++)
                Expanded(
                  child: Semantics(
                    label: '${certNames21[certLevels21[i]]} : ${perLevel[i]}',
                    excludeSemantics: true,
                    child: Column(children: [
                      SizedBox(height: 44, child: Opacity(opacity: perLevel[i] > 0 ? 1 : .35, child: SvgPicture.asset('assets/awards/plaque_${certLevels21[i]}.svg'))),
                      Text('${perLevel[i]}', style: V20Text.baloo(size: 18, line: 20, color: perLevel[i] > 0 ? Tk.gold : V20.ink2)),
                    ]),
                  ),
                ),
            ]),
          ]),
        ),
      ),
      if (target != null) ...[
        const _Sec('Prochaine plaque', 'la plus proche'),
        GlassCard(
          key: const ValueKey('next-plaque'),
          accent: GlassAccent.gold,
          halo: false,
          child: Row(children: [
            Stack(children: [
              SizedBox(width: 78, height: 98, child: SvgPicture.asset(target.plaque)),
              Positioned(right: 0, bottom: 0, child: Cover21(_certCover(s, target), size: 34, radius: 8)),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(target.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
                Text('${target.kind} · ${target.level < 0 ? 'vers le Disque d\'or' : 'vers ${certNames21[certLevels21[target.level + 1]]}'}', style: V20Text.bs()),
                const SizedBox(height: 6),
                MeterBar(value: _progress(target), tone: MeterTone.gold, thin: true),
                const SizedBox(height: 4),
                Text('Encore ${fmt21(target.next! - target.units)} unités (≈ ${fmt21((target.next! - target.units) * 100)} écoutes)', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              ]),
            ),
          ]),
        ),
      ],
      const _Sec('Tes œuvres', 'plaque par œuvre'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final k in const ['Tout', 'Single', 'EP', 'Album']) Chip21(k == 'Tout' ? 'Tout' : (k == 'Single' ? 'Singles' : (k == 'EP' ? 'EP' : 'Albums')), selected: _kind == k, onTap: () => setState(() => _kind = k)),
      ]),
      const SizedBox(height: 12),
      if (shown.isEmpty)
        const GameCard(child: Text('Aucune œuvre ici. Chaque single, EP ou album peut être certifié : or, platine, double, triple, diamant.'))
      else
        LayoutBuilder(builder: (context, c) {
          final w = (c.maxWidth - 12) / 2;
          return Wrap(spacing: 12, runSpacing: 12, children: [for (final x in shown) SizedBox(width: w, child: _Plaque(x, _certCover(s, x)))]);
        }),
      const _Sec('Échelle des paliers', 'unités'),
      GlassCard(
        child: Column(children: [
          for (var i = 0; i < certLevels21.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(width: 30, height: 38, child: SvgPicture.asset('assets/awards/plaque_${certLevels21[i]}.svg')),
                const SizedBox(width: 12),
                Expanded(child: Text(certNames21[certLevels21[i]]!, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700))),
                Text(fmt21(certThresholds21['Single']![i]), style: V20Text.baloo(size: 18, line: 20, color: Tk.gold)),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Unités = ventes + équivalent streaming : 100 écoutes = 1 unité (single : écoutes affichées sur les plateformes ; EP et album : écoutes du projet). '
              'Les mêmes seuils valent pour single, EP et album. Une certification n\'est jamais retirée. Seuils provisoires (18.4, D-02, D-08).'),
    ]);
  }
}

/// Plaque d'une œuvre : plaque (ou cadre vide), pochette, palier et progression vers le suivant.
class _Plaque extends StatelessWidget {
  final Cert21 c;
  final String cover;
  const _Plaque(this.c, this.cover);
  @override
  Widget build(BuildContext context) {
    final next = c.next;
    return GlassCard(
      padding: const EdgeInsets.all(10),
      accent: c.level >= 0 ? GlassAccent.gold : GlassAccent.none,
      halo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: SizedBox(
            height: 120,
            child: Stack(children: [
              AspectRatio(aspectRatio: 240 / 300, child: SvgPicture.asset(c.plaque)),
              Positioned(right: 0, bottom: 0, child: Cover21(cover, size: 34, radius: 8)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700)),
        Text('${c.kind} · ${c.name}', maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: c.level >= 0 ? V20.hintGoldText : V20.ink2)),
        const SizedBox(height: 6),
        MeterBar(value: _progress(c), tone: MeterTone.gold, thin: true),
        const SizedBox(height: 4),
        Text(next == null ? '${fmt21(c.units)} unités · palier maximal' : '${fmt21(c.units)} / ${fmt21(next)} unités', style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Salon des awards
// Intention de jeu : savoir quelle cérémonie arrive, où l'on en est, et garder la mémoire de ses victoires.
// ---------------------------------------------------------------------------------------------------------------------

class SalonAwardsScreen21 extends ConsumerWidget {
  const SalonAwardsScreen21({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final hist = awardHistory21(s);
    final (next, days) = nextCeremony21(s);
    final week = weekOf21(_n(s['day']));
    final wins = hist.where((h) => h['res'] == 'win').toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Salon des awards', step: 'T3', onBack: () => context.go('/profil/trophees')),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1F08), Tk.s1, Tk.deep])),
          child: Column(children: [
            Row(children: [
              SizedBox(width: 84, height: 112, child: SvgPicture.asset(next.trophy)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(days == 0 ? 'CÉRÉMONIE CE SOIR' : 'PROCHAINE CÉRÉMONIE', style: V20Text.lab(color: V20.hintGoldText)),
                  Text(next.n, style: V20Text.baloo(size: 24, line: 26)),
                  Text('Semaine ${next.week} · ${next.place}', style: V20Text.bs(color: Tk.ink)),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(days == 0 ? '0' : '$days', style: V20Text.baloo(size: 40, line: 40, color: Tk.gold)),
                    const SizedBox(width: 6),
                    Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('jour(s)', style: V20Text.bs())),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _Count('Trophées', '${awardWins21(s)}', Tk.gold),
              _Count('Nominations', '${awardNoms21(s)}', Tk.acc4),
              _Count('Cérémonies', '${hist.map((h) => '${h['y']}-${h['c']}').toSet().length}', Tk.cy),
            ]),
          ]),
        ),
      ),
      const _Sec('Tes catégories', 'score estimé'),
      GlassCard(
        accent: GlassAccent.gold,
        halo: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final cat in next.cats) _CatLine(s: s, c: next, cat: cat)]),
      ),
      const _Sec('Palmarès', 'tes victoires et nominations'),
      if (hist.isEmpty)
        GameCard(
          child: Row(children: [
            SizedBox(width: 44, height: 60, child: SvgPicture.asset('assets/awards/trophee_vide.svg')),
            const SizedBox(width: 12),
            Expanded(child: Text('Pas encore de nomination. Les cérémonies ont lieu en fin d\'année (semaines 43 à 52), nominations à partir de la semaine 41.', style: V20Text.bs())),
          ]),
        )
      else ...[
        if (wins.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${wins.length} victoire(s) au total', style: V20Text.bs(color: Tk.ok))),
        for (final h in hist.reversed) _HistRow(h),
      ],
      _Sec('Calendrier de l\'année', 'semaine $week'),
      for (final c in ceremonies21) _CeremonyRow(c, past: c.week < week, isNext: c.id == next.id),
      const SizedBox(height: 8),
      const GameHint(
          icon: 'info',
          text: 'Cérémonies : score = 0,35 qualité + 0,25 résultats + 0,20 impact + 0,10 popularité + jury ; au plus 3 victoires par cérémonie ; '
              'une nomination rapporte aussi de la réputation. Seuils provisoires (18.5).'),
    ]);
  }
}

class _CeremonyRow extends StatelessWidget {
  final Ceremony21 c;
  final bool past, isNext;
  const _CeremonyRow(this.c, {required this.past, required this.isNext});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GameCard(
          selected: isNext,
          child: Row(children: [
            SizedBox(width: 40, height: 54, child: Opacity(opacity: past ? .45 : 1, child: SvgPicture.asset(c.trophy))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.n, style: V20Text.nm()),
                Text('S${c.week} · ${c.place}', style: V20Text.bs()),
                Text(c.cats.map((x) => x.n).join(' · '), style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              ]),
            ),
            const SizedBox(width: 8),
            GameTag(past ? 'Passée' : (isNext ? 'Prochaine' : 'Prestige ${c.prestige}'), style: isNext ? GameTagStyle.accent : GameTagStyle.outline),
          ]),
        ),
      );
}

class _Count extends StatelessWidget {
  final String lab, v;
  final Color c;
  const _Count(this.lab, this.v, this.c);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(v, style: V20Text.baloo(size: 28, line: 30, color: c)),
          Text(lab.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
        ]),
      );
}

class _Sec extends StatelessWidget {
  final String t, sub;
  const _Sec(this.t, this.sub);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(t, style: V20Text.baloo(size: 20, line: 22))),
          Text(sub, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
        ]),
      );
}

/// Catégorie de la prochaine cérémonie : éligibilité et score estimé face aux seuils (jamais un pourcentage de réussite).
class _CatLine extends StatelessWidget {
  final J s;
  final Ceremony21 c;
  final AwardCat21 cat;
  const _CatLine({required this.s, required this.c, required this.cat});
  @override
  Widget build(BuildContext context) {
    final sc = awardScore21(s, c, cat);
    final frozen = frozenNominations21(s);
    if (frozen != null) {
      final nom = frozen.contains('${c.id}-${cat.id}');
      if (!nom) return Conseq21(ConsequenceKind.certain, '${cat.n} : pas nommé cette année');
      return Conseq21(ConsequenceKind.estimated, '${cat.n} : nommé · score estimé ${(sc ?? 0).round()} · victoire ${c.winAt.round()}');
    }
    if (sc == null) return Conseq21(ConsequenceKind.uncertain, '${cat.n} : pas encore éligible');
    final txt = '${cat.n} : score estimé ${sc.round()} · nomination ${c.nominateAt.round()} · victoire ${c.winAt.round()}';
    return Conseq21(ConsequenceKind.estimated, txt);
  }
}

class _HistRow extends StatelessWidget {
  final J h;
  const _HistRow(this.h);
  @override
  Widget build(BuildContext context) {
    final c = ceremonies21.firstWhere((x) => x.id == h['c'], orElse: () => ceremonies21.first);
    final cat = c.cats.firstWhere((x) => x.id == h['cat'], orElse: () => c.cats.first);
    final win = h['res'] == 'win';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GameCard(
        selected: win,
        child: Row(children: [
          SizedBox(width: 44, height: 60, child: Opacity(opacity: win ? 1 : .45, child: SvgPicture.asset(c.trophy))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.n, style: V20Text.nm()),
              Text('${c.n} · année ${h['y']}', style: V20Text.bs()),
            ]),
          ),
          GameTag(win ? 'Lauréat' : 'Nommé', style: win ? GameTagStyle.ok : GameTagStyle.outline),
        ]),
      ),
    );
  }
}


// ---------------------------------------------------------------------------------------------------------------------
// Annonce : nouvelle certification ou résultat d'une cérémonie (moment de célébration, sortie unique)
// ---------------------------------------------------------------------------------------------------------------------

/// Carte du QG : une annonce de la salle des trophées attend d'être vue.
class AwardNewsCard21 extends StatelessWidget {
  final J s;
  const AwardNewsCard21(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    final news = (s['awNews'] as List?) ?? const [];
    if (news.isEmpty) return _Countdown(s);
    final it = news.first as Map;
    final cert = it['k'] == 'cert', nom = it['k'] == 'nom';
    final nomCats = nom ? ((it['cats'] as List?) ?? const []).cast<Map>() : const <Map>[];
    final c = cert ? null : (nom ? ceremonies21.first : ceremonies21.firstWhere((x) => x.id == it['c'], orElse: () => ceremonies21.first));
    final img = cert ? 'assets/awards/plaque_${certLevels21[(it['lv'] as num).toInt()]}.svg' : (nom && nomCats.isEmpty ? 'assets/awards/trophee_vide.svg' : c!.trophy);
    final title = cert ? certNames21[certLevels21[(it['lv'] as num).toInt()]]! : (nom ? 'Nominations de l\'année' : c!.n);
    final sub = cert ? '${it['t']} · ${it['kind']}' : (nom ? (nomCats.isEmpty ? 'Aucune nomination cette année' : '${nomCats.length} catégorie(s) : ${nomCats.map((x) => x['n']).join(', ')}') : _cerLine(it));
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GlassCard(
        accent: GlassAccent.gold,
        onTap: () => context.go('/profil/trophees/annonce'),
        semanticLabel: '$title, $sub',
        child: Row(children: [
          SizedBox(width: 48, height: 62, child: SvgPicture.asset(img)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cert ? 'NOUVELLE CERTIFICATION' : (nom ? 'NOMINATIONS ANNONCÉES' : 'RÉSULTATS DE LA CÉRÉMONIE'), style: V20Text.lab(color: V20.hintGoldText)),
              Text(title, style: V20Text.nm()),
              Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.bs()),
            ]),
          ),
          if (news.length > 1) GameTag('+${news.length - 1}', style: GameTagStyle.accent),
        ]),
      ),
    );
  }
}

String _cerLine(Map it) {
  final w = (it['wins'] as num?) ?? 0, nm = (it['noms'] as num?) ?? 0;
  if (w > 0) return '$w trophée(s)${nm > 0 ? ' et $nm nomination(s)' : ''}';
  if (nm > 0) return '$nm nomination(s)';
  return 'Pas de nomination cette année';
}

class AnnonceTropheeScreen extends ConsumerWidget {
  const AnnonceTropheeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final news = (s['awNews'] as List?) ?? const [];
    if (news.isEmpty) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Annonce', step: 'T2', onBack: () => context.go('/profil/trophees')),
        const SizedBox(height: 12),
        const GameCard(child: Text('Aucune annonce en attente.')),
      ]);
    }
    final it = news.first as Map;
    if (it['k'] == 'nom') return _NominationsAnnonce(news: news, it: it);
    final cert = it['k'] == 'cert';
    final c = cert ? null : ceremonies21.firstWhere((x) => x.id == it['c'], orElse: () => ceremonies21.first);
    final lv = cert ? certLevels21[(it['lv'] as num).toInt()] : null;
    final won = !cert && ((it['wins'] as num?) ?? 0) > 0;
    final celebrate = cert || won || ((it['noms'] as num?) ?? 0) > 0;
    final cats = cert ? const <Map>[] : ((it['cats'] as List?) ?? const []).cast<Map>();
    return Stack(children: [
      ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), children: [
        Text(cert ? 'NOUVELLE CERTIFICATION' : c!.n.toUpperCase(), textAlign: TextAlign.center, style: V20Text.lab(color: V20.hintGoldText)),
        const SizedBox(height: 8),
        Center(
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Tk.gold.withValues(alpha: celebrate ? .35 : .08), blurRadius: 60, spreadRadius: 6)]),
            child: SizedBox(height: 240, child: AspectRatio(aspectRatio: cert ? 240 / 300 : 220 / 300, child: SvgPicture.asset(cert ? 'assets/awards/plaque_$lv.svg' : (celebrate ? c!.trophy : 'assets/awards/trophee_vide.svg')))),
          ),
        ),
        const SizedBox(height: 16),
        Text(cert ? certNames21[lv]!.toUpperCase() : (won ? 'LAURÉAT' : (celebrate ? 'NOMMÉ' : 'PAS CETTE ANNÉE')),
            textAlign: TextAlign.center, style: V20Text.baloo(size: 34, line: 36, color: celebrate ? Tk.gold : Tk.ink)),
        const SizedBox(height: 4),
        Text(cert ? '« ${it['t']} » · ${it['kind']}' : '${c!.place} · année ${it['y']}', textAlign: TextAlign.center, style: V20Text.poppins(size: 15, line: 20, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (cert)
          GlassCard(
            child: Column(children: [
              Text('${fmt21(it['u'] as num)} unités', style: V20Text.baloo(size: 26, line: 28, color: Tk.gold)),
              Text(it['kind'] == 'Single' ? 'ventes + écoutes cumulées ÷ 10' : 'ventes + écoutes du projet ÷ 100', style: V20Text.bs()),
              const SizedBox(height: 8),
              const Conseq21(ConsequenceKind.certain, 'Une certification n\'est jamais retirée. Elle rejoint ta vitrine.'),
            ]),
          )
        else
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (cats.isEmpty) Text('Ton travail n\'a pas encore été retenu par le jury. Sors des titres, monte sur scène, et reviens l\'an prochain.', style: V20Text.bs()),
              for (final x in cats)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(child: Text('${x['n']}', style: V20Text.nm())),
                    GameTag(x['res'] == 'win' ? 'Lauréat' : 'Nommé', style: x['res'] == 'win' ? GameTagStyle.ok : GameTagStyle.outline),
                  ]),
                ),
              if (celebrate) ...[
                const SizedBox(height: 8),
                Conseq21(ConsequenceKind.certain,
                    'Réputation et fans en hausse : victoire +${2 * c!.prestige} réputation et +${300 * c.prestige} fans, nomination +1 réputation et +80 fans.'),
              ],
            ]),
          ),
        const SizedBox(height: 16),
        PrimaryGlowButton(
          label: news.length > 1 ? 'Annonce suivante' : 'Voir la salle des trophées',
          onPressed: () => doAct(context, ref, 'awseen', null, () => context.go(news.length > 1 ? '/profil/trophees/annonce' : '/profil/trophees')),
        ),
      ]),
      if (celebrate) const IgnorePointer(child: Align(alignment: Alignment.topCenter, child: RewardBurst(height: 320))),
    ]);
  }
}


/// Annonce des nominations (semaine 41) : catégories retenues, dates des cérémonies, rappel que le résultat reste à venir.
class _NominationsAnnonce extends ConsumerWidget {
  final List news;
  final Map it;
  const _NominationsAnnonce({required this.news, required this.it});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ((it['cats'] as List?) ?? const []).cast<Map>();
    final any = cats.isNotEmpty;
    return Stack(children: [
      ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), children: [
        Text('SEMAINE $nominationsWeek21 · ANNÉE ${it['y']}', textAlign: TextAlign.center, style: V20Text.lab(color: V20.hintGoldText)),
        const SizedBox(height: 8),
        Center(child: SizedBox(height: 200, child: AspectRatio(aspectRatio: 220 / 300, child: SvgPicture.asset(any ? 'assets/awards/trophee_grandprix.svg' : 'assets/awards/trophee_vide.svg')))),
        const SizedBox(height: 12),
        Text(any ? 'TU ES NOMMÉ' : 'PAS DE NOMINATION', textAlign: TextAlign.center, style: V20Text.baloo(size: 34, line: 36, color: any ? Tk.gold : Tk.ink)),
        Text(any ? '${cats.length} catégorie(s) cette année' : 'Le jury n\'a pas retenu ton nom cette année.', textAlign: TextAlign.center, style: V20Text.poppins(size: 15, line: 20, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!any) Text('Sors des titres, monte sur scène, gagne en réputation : les nominations reviennent chaque année en semaine $nominationsWeek21.', style: V20Text.bs()),
            for (final x in cats)
              Builder(builder: (context) {
                final c = ceremonies21.firstWhere((e) => e.id == x['c'], orElse: () => ceremonies21.first);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    SizedBox(width: 34, height: 46, child: SvgPicture.asset(c.trophy)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${x['n']}', style: V20Text.nm()),
                        Text('${c.n} · semaine ${c.week}', style: V20Text.bs()),
                      ]),
                    ),
                  ]),
                );
              }),
            if (any) ...[
              const SizedBox(height: 8),
              const Conseq21(ConsequenceKind.certain, 'Être nommé rapporte déjà +1 réputation et +80 fans le jour de la cérémonie.'),
              const Conseq21(ConsequenceKind.uncertain, 'La victoire se décide le jour de la cérémonie : continue à sortir des titres et à monter sur scène.'),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryGlowButton(
          label: news.length > 1 ? 'Annonce suivante' : 'Voir la salle des trophées',
          onPressed: () => doAct(context, ref, 'awseen', null, () => context.go(news.length > 1 ? '/profil/trophees/annonce' : '/profil/trophees')),
        ),
      ]),
      if (any) const IgnorePointer(child: Align(alignment: Alignment.topCenter, child: RewardBurst(height: 280))),
    ]);
  }
}

/// Carte du QG : une cérémonie approche (7 jours ou moins) et le joueur y est nommé.
class _Countdown extends StatelessWidget {
  final J s;
  const _Countdown(this.s);
  @override
  Widget build(BuildContext context) {
    final (c, days) = nextCeremony21(s);
    final frozen = frozenNominations21(s);
    if (days > 7 || frozen == null) return const SizedBox.shrink();
    final mine = c.cats.where((x) => frozen.contains('${c.id}-${x.id}')).toList();
    if (mine.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GlassCard(
        accent: GlassAccent.gold,
        halo: false,
        onTap: () => context.go('/profil/trophees'),
        semanticLabel: '${c.n} dans $days jour(s)',
        child: Row(children: [
          SizedBox(width: 44, height: 58, child: SvgPicture.asset(c.trophy)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(days == 0 ? 'CÉRÉMONIE CE SOIR' : 'CÉRÉMONIE DANS $days JOUR(S)', style: V20Text.lab(color: V20.hintGoldText)),
              Text(c.n, style: V20Text.nm()),
              Text('Nommé : ${mine.map((x) => x.n).join(', ')}', maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.bs()),
            ]),
          ),
        ]),
      ),
    );
  }
}
