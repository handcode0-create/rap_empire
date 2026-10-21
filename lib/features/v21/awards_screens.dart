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
import '../../core/widgets/svg_precache.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'cast21.dart';
import 'library_screens.dart' show coverOf21;
import 'widgets21.dart';

/// Classements officiels (21-R2, refonte façon plateforme de streaming), salle des trophées (certifications et cérémonies).
/// Les lignes des autres artistes reprennent les valeurs existantes de 13.2 à 13.5 ; les lignes du joueur sont calculées
/// à partir de ses vraies écoutes et ventes. Certifications et cérémonies : propositions 18.4 et 18.5, valeurs provisoires.

num _n(dynamic x) => (x ?? 0) as num;

/// Une ligne de classement : rang, titre, artiste, valeur, évolution connue (null si non documentée).
typedef _Entry = ({String t, String a, String v, String? mv});

const _singles = <_Entry>[
  (t: 'Minuit Doré', a: 'Kaïra Nox', v: '12,4 M', mv: '='),
  (t: "Pluie d'Argent", a: 'Zaki Mbela', v: '11,8 M', mv: '+2'),
  (t: 'Tonnerre Doux', a: 'Madame Orage', v: '10,9 M', mv: null),
  (t: 'Brume sur Ndo', a: 'Tito Brume', v: '9,7 M', mv: null),
  (t: 'Verre Bleu', a: 'Lazuli', v: '9,1 M', mv: null),
  (t: 'Rives Lentes', a: 'Sôlo Vance', v: '8,6 M', mv: null),
  (t: 'Douce Lagune', a: 'Nadia Kolo', v: '8,0 M', mv: null),
];
const _albums = <_Entry>[
  (t: "Nuit d'Ambre", a: 'Kaïra Nox', v: '1,9 M', mv: '='),
  (t: 'Rivages', a: 'Zaki Mbela', v: '1,6 M', mv: '+1'),
  (t: 'Orage Intérieur', a: 'Madame Orage', v: '—', mv: null),
];
const _eps = <_Entry>[
  (t: 'Sable Chaud', a: 'Dr. Sable', v: '420 k', mv: '+1'),
  (t: 'Cendres', a: 'Yaya Cendre', v: '388 k', mv: '='),
  (t: 'Ndo Sessions', a: 'Bako Flux', v: '—', mv: null),
];
const _global = <_Entry>[
  (t: 'Kaïra Nox', a: 'Drill', v: '98,4', mv: '='),
  (t: 'Zaki Mbela', a: 'Rap', v: '95,1', mv: '+2'),
  (t: 'Madame Orage', a: 'Rap', v: '93,7', mv: '-1'),
  (t: 'Tito Brume', a: 'Rap conscient', v: '90,2', mv: '-1'),
  (t: 'Lazuli', a: 'Afro-soul', v: '88,9', mv: null),
  (t: 'Sôlo Vance', a: 'Trap', v: '85,0', mv: null),
  (t: 'Nadia Kolo', a: 'Chant', v: '83,4', mv: null),
  (t: 'Bako Flux', a: 'Rap', v: '80,6', mv: null),
  (t: 'Dr. Sable', a: 'Rap', v: '78,8', mv: null),
  (t: 'Yaya Cendre', a: 'Rap', v: '76,3', mv: null),
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
  final (txt, c) = mv == '='
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

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final week = weekOf21(_n(s['day']));
    final (List<_Entry> list, String unit, List<Color> bg, String artistOrGenre) = switch (_tab) {
      0 => (_singles, 'écoutes, 7 j', const [Color(0xFF3B1236), Color(0xFF1F1942)], 'artist'),
      1 => (_albums, 'ventes, 7 j', const [Color(0xFF12304A), Color(0xFF1F1942)], 'artist'),
      2 => (_eps, 'ventes, 7 j', const [Color(0xFF2A1F08), Color(0xFF1F1942)], 'artist'),
      _ => (_global, 'indice', const [Color(0xFF2B1659), Color(0xFF1F1942)], 'genre'),
    };
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
                        : _Cover(_artThumb(list[i].a), 72 - i * 8.0),
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
          text: 'Les autres artistes : valeurs existantes des planches 13.2 à 13.5 (évolution affichée seulement quand elle est documentée). '
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
          child: artistTab ? CastAvatar(e.t, size: tall ? 84 : 68, ring: c) : _Cover(_artThumb(e.a), tall ? 84 : 68),
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(width: 30, child: Text('$rank', textAlign: TextAlign.center, style: V20Text.baloo(size: 18, line: 20, color: Tk.gold))),
          _move(e.mv),
          const SizedBox(width: 6),
          artistTab ? CastAvatar(e.t, size: 44, ring: Tk.gold) : _Cover(_artThumb(e.a), 44),
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
    switch (tab) {
      case 0:
        final b = bestSong(s);
        final l = b == null ? 0 : _n(b['L']);
        final r = singlesRank(s);
        title = b == null ? 'Aucun titre sorti' : '${b['title']}';
        if (b != null) cover = coverOf21('${b['id']}');
        rank = r == 0 ? 'Non classé' : '#$r';
        detail = r == 0 ? '${fmt21(l)} / ${fmt21(Reg21.entry)} écoutes sur 7 jours pour entrer au Top 100' : '${fmt21(l)} écoutes sur 7 jours';
        prog = (l / Reg21.entry).clamp(0, 1).toDouble();
      case 1 || 2:
        final type = tab == 1 ? 'Album' : 'EP';
        final p = bestProject(s, type);
        final entry = Reg21.proj[type]!['entry'] as num;
        title = p == null ? (type == 'EP' ? 'Aucun EP' : 'Aucun album') : '${p['title']}';
        if (p != null) cover = coverOf21('${p['id']}');
        rank = p == null ? '—' : projectRankLabel(p);
        detail = p == null
            ? (type == 'EP' ? 'Crée un EP de 3 à 7 titres au studio' : 'Crée un album de 8 titres ou plus au studio')
            : '${fmt21(_n(p['sales']))} ventes${_n(p['rank']) == 0 ? ' · entrée à ${fmt21(entry)}' : ''}';
        prog = p == null ? 0 : (_n(p['sales']) / entry).clamp(0, 1).toDouble();
      default:
        final ip = idxParts21(s), gr = globalRank(s);
        title = playerName(s);
        rank = gr == 0 ? 'Non classé' : '#$gr';
        detail = gr == 0 ? 'Indice ${d1(ip.i)} · le #10 est à 76,3 (écart ${d1(76.3 - ip.i)})' : 'Indice ${d1(ip.i)}';
        prog = (ip.i / 76.3).clamp(0, 1).toDouble();
    }
    return GlassCard(
      accent: GlassAccent.magenta,
      halo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TA POSITION', style: V20Text.lab(color: V20.accText)),
        const SizedBox(height: 8),
        Row(children: [
          tab == 3 ? CastAvatar('Djo Kéné', size: 52) : _Cover(cover, 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
              Text(detail, style: V20Text.bs()),
            ]),
          ),
          const SizedBox(width: 8),
          Text(rank, style: V20Text.baloo(size: 22, line: 24, color: rank.startsWith('#') ? Tk.gold : V20.ink2)),
        ]),
        const SizedBox(height: 10),
        MeterBar(value: prog, tone: MeterTone.gold),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Salle des trophées : certifications et cérémonies
// ---------------------------------------------------------------------------------------------------------------------

class TropheesScreen extends ConsumerWidget {
  const TropheesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final certs = certs21(s);
    final hist = awardHistory21(s);
    final (next, days) = nextCeremony21(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Salle des trophées', step: 'T1', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      // vitrine
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
      // prochaine cérémonie
      GlassCard(
        accent: GlassAccent.gold,
        halo: false,
        child: Row(children: [
          SizedBox(width: 56, height: 76, child: SvgPicture.asset(next.trophy)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PROCHAINE CÉRÉMONIE', style: V20Text.lab()),
              Text(next.n, style: V20Text.nm()),
              Text('Semaine ${next.week} · ${next.place} · ${days == 0 ? "aujourd'hui" : 'dans $days jour(s)'}', style: V20Text.bs()),
              const SizedBox(height: 4),
              for (final cat in next.cats) _CatLine(s: s, c: next, cat: cat),
            ]),
          ),
        ]),
      ),
      const _Sec('Certifications', 'unités cumulées'),
      if (certs.isEmpty)
        const GameCard(child: Text('Aucune sortie. Chaque single, EP ou album peut être certifié : or, platine, double, triple, diamant.'))
      else
        LayoutBuilder(builder: (context, c) {
          final w = (c.maxWidth - 12) / 2;
          return Wrap(spacing: 12, runSpacing: 12, children: [for (final x in certs) SizedBox(width: w, child: _CertCard(x))]);
        }),
      const _Sec('Palmarès', 'cérémonies'),
      if (hist.isEmpty)
        GameCard(
          child: Row(children: [
            SizedBox(width: 44, height: 60, child: SvgPicture.asset('assets/awards/trophee_vide.svg')),
            const SizedBox(width: 12),
            Expanded(child: Text('Pas encore de nomination. Les cérémonies ont lieu en fin d\'année (semaines 43 à 52), nominations à partir de la semaine 41.', style: V20Text.bs())),
          ]),
        )
      else
        for (final h in hist.reversed) _HistRow(h),
      const _Sec('Calendrier', 'chaque année'),
      for (final c in ceremonies21)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GameCard(
            child: Row(children: [
              SizedBox(width: 40, height: 54, child: SvgPicture.asset(c.trophy)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.n, style: V20Text.nm()),
                  Text('S${c.week} · ${c.place}', style: V20Text.bs()),
                  Text(c.cats.map((x) => x.n).join(' · '), style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
                ]),
              ),
              GameTag('Prestige ${c.prestige}', style: GameTagStyle.outline),
            ]),
          ),
        ),
      const SizedBox(height: 8),
      const GameHint(
          icon: 'info',
          text: 'Certifications : single = ventes + écoutes cumulées ÷ 10 ; EP et album = ventes + écoutes ÷ 100. Une certification n\'est jamais retirée. '
              'Cérémonies : score = 0,35 qualité + 0,25 résultats + 0,20 impact + 0,10 popularité + jury ; au plus 3 victoires par cérémonie ; une nomination rapporte aussi de la réputation. Seuils provisoires (18.4, 18.5).'),
    ]);
  }
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
    if (sc == null) return Conseq21(ConsequenceKind.uncertain, '${cat.n} : pas encore éligible');
    final txt = '${cat.n} : score estimé ${sc.round()} · nomination ${c.nominateAt.round()} · victoire ${c.winAt.round()}';
    return Conseq21(ConsequenceKind.estimated, txt);
  }
}

class _CertCard extends StatelessWidget {
  final Cert21 c;
  const _CertCard(this.c);
  @override
  Widget build(BuildContext context) {
    final next = c.next;
    final prev = c.level < 0 ? 0 : certThresholds21[c.kind]![c.level];
    final prog = next == null ? 1.0 : ((c.units - prev) / (next - prev)).clamp(0, 1).toDouble();
    return GlassCard(
      padding: const EdgeInsets.all(10),
      accent: c.level >= 0 ? GlassAccent.gold : GlassAccent.none,
      halo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: SizedBox(height: 120, child: AspectRatio(aspectRatio: 240 / 300, child: SvgPicture.asset(c.plaque)))),
        const SizedBox(height: 8),
        Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700)),
        Text('${c.kind} · ${c.name}', maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: c.level >= 0 ? V20.hintGoldText : V20.ink2)),
        const SizedBox(height: 6),
        MeterBar(value: prog, tone: MeterTone.gold, thin: true),
        const SizedBox(height: 4),
        Text(next == null ? '${fmt21(c.units)} unités · palier maximal' : '${fmt21(c.units)} / ${fmt21(next)} unités',
            style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
      ]),
    );
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
