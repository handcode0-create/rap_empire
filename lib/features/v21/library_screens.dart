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
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/svg_precache.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';

/// Bibliothèque musicale des plateformes audio Ondéa (21-N1) et Cauri Music (21-N6), façon application de streaming :
/// « Populaires » sans numéro de classement, discographie (albums, EP, singles), tous les titres et fiche d'une sortie.
/// Présentation seulement : les écoutes viennent du moteur (écoutes de sortie + clip) réparties par la part de la plateforme.
/// Aucune écoute ni aucun revenu en plus. Valeurs provisoires (D-08).

num _n(dynamic x) => (x ?? 0) as num;

/// Identité visuelle d'une plateforme (la palette du jeu reste la même, seule l'ambiance change).
class Pf21 {
  final String key, name, unit;
  final Color accent;
  final List<Color> bg;
  const Pf21(this.key, this.name, this.unit, this.accent, this.bg);
  num get share => Reg21.platforms[key]!['share'] as num;
  String get route => '/profil/reseau/$key';
}

const pfOndea = Pf21('ondea', 'Ondéa', 'écoutes', Tk.cy, [Color(0xFF123A55), Color(0xFF1E1650), Color(0xFF0E1230)]);
const pfCauri = Pf21('cauri', 'Cauri Music', 'écoutes premium', Tk.acc4, [Color(0xFF3B1236), Color(0xFF1A0A1F), Color(0xFF12081A)]);
Pf21 pf21(String key) => key == 'cauri' ? pfCauri : pfOndea;

/// Pochette fixe d'un titre ou d'une sortie : toujours la même image pour le même identifiant.
String coverOf21(String id) => 'assets/klipo/mine/M${id.codeUnits.fold<int>(0, (a, c) => a + c) % myThumbs21 + 1}.svg';

/// Un titre tel que l'affiche une plateforme.
class Track21 {
  final String id, title;
  final int? listens; // null : inédit sorti uniquement dans un projet (pas d'écoutes séparées)
  final String? project;
  final bool feat, clip;
  const Track21(this.id, this.title, this.listens, {this.project, this.feat = false, this.clip = false});
}

/// Une sortie : album, EP ou single.
class Release21 {
  final String id, kind, title;
  final int day;
  final List<Track21> tracks;
  final int listens;
  final int? sales;
  const Release21(this.id, this.kind, this.title, this.day, this.tracks, this.listens, this.sales);
  String get cover => coverOf21(id);
}

List<J> _disco(J s) => ((s['disco'] as List?) ?? const []).map((x) => x as J).toList();

Track21 _single(J t, Pf21 pf) => Track21('${t['id']}', '${t['title']}', jsRound(platformListens(t) * pf.share),
    feat: ((t['feats'] as List?) ?? const []).isNotEmpty, clip: t['clip'] is Map && (t['clip'] as Map)['st'] == 'publie');

/// Titres sortis en single, du plus écouté au moins écouté.
List<Track21> popular21(J s, Pf21 pf) => _disco(s).map((t) => _single(t, pf)).toList()..sort((a, b) => (b.listens ?? 0).compareTo(a.listens ?? 0));

/// Toutes les sorties, de la plus récente à la plus ancienne : projets (album, EP) puis singles.
List<Release21> releases21(J s, Pf21 pf) {
  final disco = _disco(s);
  final out = <Release21>[];
  for (final x in ((s['projects'] as List?) ?? const [])) {
    final p = x as J;
    final ined = {for (final i in ((p['inedits'] as List?) ?? const [])) '${(i as Map)['id']}': '${i['title']}'};
    final tr = <Track21>[];
    for (final id in ((p['tracks'] as List?) ?? const [])) {
      final d = disco.where((t) => t['id'] == id).firstOrNull;
      if (d != null) {
        tr.add(_single(d, pf));
      } else {
        tr.add(Track21('$id', ined['$id'] ?? 'Titre $id', null, project: '${p['title']}'));
      }
    }
    out.add(Release21('${p['id']}', p['type'] == 'EP' ? 'EP' : 'Album', '${p['title']}', _n(p['day']).toInt(), tr, jsRound(_n(p['L']) * pf.share), _n(p['sales']).toInt()));
  }
  for (final t in disco) {
    final tr = _single(t, pf);
    out.add(Release21(tr.id, 'Single', tr.title, _n(t['day']).toInt(), [tr], tr.listens ?? 0, null));
  }
  out.sort((a, b) => b.day.compareTo(a.day));
  return out;
}

/// Tous les titres : singles, puis inédits des projets.
List<Track21> allTracks21(J s, Pf21 pf) {
  final singles = popular21(s, pf);
  final seen = singles.map((t) => t.id).toSet();
  final ined = <Track21>[];
  for (final r in releases21(s, pf).where((r) => r.kind != 'Single')) {
    for (final t in r.tracks) {
      if (seen.add(t.id)) ined.add(t);
    }
  }
  return [...singles, ...ined];
}

// ---------------------------------------------------------------------------------------------------------------------
// Briques visuelles
// ---------------------------------------------------------------------------------------------------------------------

class Cover21 extends StatelessWidget {
  final String path;
  final double size, radius;
  const Cover21(this.path, {super.key, this.size = 52, this.radius = 10});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
            width: size,
            height: size,
            child: SvgPicture.asset(path, fit: BoxFit.cover, placeholderBuilder: (_) => const SvgLoadingPlaceholder(), errorBuilder: (_, __, ___) => const SvgLoadingPlaceholder())),
      );
}

class LibSec21 extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const LibSec21(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Row(children: [
          Expanded(child: Text(title, style: V20Text.baloo(size: 20, line: 22))),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: Tk.ink),
              child: Text(action!, style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700, color: V20.ink2)),
            ),
        ]),
      );
}

/// Ligne de titre façon streaming : pochette, titre, auteur et écoutes ; pas de numéro de classement.
class TrackRow21 extends StatelessWidget {
  final J s;
  final Track21 t;
  final Pf21 pf;
  final int? number; // numéro de piste dans un album (pas un rang)
  const TrackRow21(this.s, this.t, this.pf, {super.key, this.number});
  @override
  Widget build(BuildContext context) {
    final sub = t.listens == null ? 'Inédit · ${t.project ?? 'projet'}' : '${fmt21(t.listens!)} ${pf.unit}';
    return Semantics(
      label: '${t.title}, $sub',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Row(children: [
          if (number != null)
            SizedBox(width: 26, child: Text('$number', textAlign: TextAlign.center, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700, color: V20.ink2)))
          else
            Cover21(coverOf21(t.id)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
              Row(children: [
                if (pf.key == 'cauri') ...[const _Badge('Hi-Fi', Tk.gold), const SizedBox(width: 6)],
                if (t.clip) ...[const _Badge('Clip', Tk.gold), const SizedBox(width: 6)],
                Expanded(
                    child: Text('$sub · ${playerName(s)}${t.feat ? ' et invités' : ''}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2))),
              ]),
            ]),
          ),
          Icon(Icons.graphic_eq_rounded, color: pf.accent.withValues(alpha: .8), size: 20),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String txt;
  final Color c;
  const _Badge(this.txt, this.c);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: c.withValues(alpha: .7))),
        child: Text(txt.toUpperCase(), style: V20Text.poppins(size: 9, line: 12, weight: FontWeight.w800, color: c, spacing: .8)),
      );
}

/// Carte de sortie (pochette carrée, titre, type et jour) : ouvre la fiche de la sortie.
class ReleaseCard21 extends StatelessWidget {
  final Release21 r;
  final Pf21 pf;
  final double width;
  const ReleaseCard21(this.r, this.pf, {super.key, this.width = 148});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '${r.kind} ${r.title}',
        child: GestureDetector(
          onTap: () => context.go('${pf.route}/sortie?id=${Uri.encodeComponent(r.id)}'),
          child: SizedBox(
            width: width,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .45), blurRadius: 14, offset: const Offset(0, 6))]),
                child: Cover21(r.cover, size: width, radius: 14),
              ),
              const SizedBox(height: 8),
              Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700)),
              Text('${r.kind} · ${dateLabel21(r.day)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
            ]),
          ),
        ),
      );
}

/// Onglets de discographie : sorties populaires, albums et EP, singles.
class Discography21 extends StatefulWidget {
  final J s;
  final Pf21 pf;
  const Discography21(this.s, this.pf, {super.key});
  @override
  State<Discography21> createState() => _DiscographyState();
}

class _DiscographyState extends State<Discography21> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final all = releases21(widget.s, widget.pf);
    final pop = [...all]..sort((a, b) => b.listens.compareTo(a.listens));
    final lists = [pop, all.where((r) => r.kind != 'Single').toList(), all.where((r) => r.kind == 'Single').toList()];
    const tabs = ['Populaires', 'Albums et EP', 'Singles'];
    final list = lists[_tab];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 48,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (var i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tabs[i], style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: _tab == i ? Tk.bg : Tk.ink)),
                selected: _tab == i,
                selectedColor: widget.pf.accent,
                backgroundColor: Colors.white.withValues(alpha: .06),
                side: BorderSide(color: _tab == i ? widget.pf.accent : Colors.white.withValues(alpha: .14)),
                showCheckmark: false,
                onSelected: (_) => setState(() => _tab = i),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 10),
      if (list.isEmpty)
        GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_tab == 1 ? 'Aucun album ni EP' : 'Aucune sortie', style: V20Text.nm()),
            Text(_tab == 1 ? 'Un EP réunit 3 à 7 titres, un album 8 et plus. Ils se préparent au studio.' : 'Sors un single pour apparaître ici.', style: V20Text.bs()),
            if (_tab == 1) ...[
              const SizedBox(height: 12),
              PrimaryButton(label: 'Préparer un projet', onPressed: () => context.go('/studio/catalogue')),
            ],
          ]),
        )
      else
        SizedBox(
          height: 206,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => ReleaseCard21(list[i], widget.pf),
          ),
        ),
    ]);
  }
}

/// Bloc « Populaires » : 5 titres les plus écoutés, sans numéro de classement, puis accès à tous les titres.
class Popular21 extends StatelessWidget {
  final J s;
  final Pf21 pf;
  const Popular21(this.s, this.pf, {super.key});
  @override
  Widget build(BuildContext context) {
    final pop = popular21(s, pf);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LibSec21('Populaires', action: pop.isEmpty ? null : 'Tous les titres', onAction: () => context.go('${pf.route}/titres')),
      if (pop.isEmpty) const GameCard(child: Text('Aucun titre sorti. Sors un single pour apparaître ici.')),
      for (final t in pop.take(5)) TrackRow21(s, t, pf),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Tous les titres (21-N1b / 21-N6b)
// ---------------------------------------------------------------------------------------------------------------------

class AllTracksScreen extends ConsumerStatefulWidget {
  final String pfKey;
  const AllTracksScreen(this.pfKey, {super.key});
  @override
  ConsumerState<AllTracksScreen> createState() => _AllTracksState();
}

class _AllTracksState extends ConsumerState<AllTracksScreen> {
  int _sort = 0; // 0 : plus écoutés, 1 : A à Z
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final pf = pf21(widget.pfKey);
    final all = allTracks21(s, pf);
    if (_sort == 1) all.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    final tot = all.fold<int>(0, (a, t) => a + (t.listens ?? 0));
    return DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: pf.bg)),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Tous les titres', step: pf.key == 'cauri' ? 'N6b' : 'N1b', onBack: () => context.go(pf.route)),
        const SizedBox(height: 12),
        Text('${all.length} titre(s) · ${fmt21(tot)} ${pf.unit} sur ${pf.name}', style: V20Text.bs()),
        const SizedBox(height: 8),
        Row(children: [
          for (final (i, l) in const [(0, 'Plus écoutés'), (1, 'A à Z')])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(l, style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: _sort == i ? Tk.bg : Tk.ink)),
                selected: _sort == i,
                selectedColor: pf.accent,
                backgroundColor: Colors.white.withValues(alpha: .06),
                side: BorderSide(color: _sort == i ? pf.accent : Colors.white.withValues(alpha: .14)),
                showCheckmark: false,
                onSelected: (_) => setState(() => _sort = i),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        if (all.isEmpty) const GameCard(child: Text('Aucun titre sorti pour l\'instant.')),
        for (final t in all) TrackRow21(s, t, pf),
        const SizedBox(height: 12),
        GameHint(
            icon: 'info',
            text: '${pf.name} reçoit ${(pf.share * 100).round()} % des écoutes audio (règle provisoire). Les inédits n\'existent que dans leur projet : leurs écoutes sont comptées avec le projet.'),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Fiche d'une sortie (21-N1c / 21-N6c) : album, EP ou single
// ---------------------------------------------------------------------------------------------------------------------

class ReleaseScreen extends ConsumerWidget {
  final String pfKey;
  final String? id;
  const ReleaseScreen(this.pfKey, this.id, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final pf = pf21(pfKey);
    final all = releases21(s, pf);
    final r = all.where((x) => x.id == id).firstOrNull ?? all.firstOrNull;
    final step = pf.key == 'cauri' ? 'N6c' : 'N1c';
    if (r == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Sortie', step: step, onBack: () => context.go(pf.route)),
        const SizedBox(height: 12),
        const GameCard(child: Text('Aucune sortie pour l\'instant.')),
      ]);
    }
    final w = MediaQuery.sizeOf(context).width;
    final coverSize = (w - 32).clamp(200, 300).toDouble() * .78;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: pf.bg)),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: pf.name, step: step, onBack: () => context.go(pf.route)),
        const SizedBox(height: 16),
        Center(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: [
              BoxShadow(color: pf.accent.withValues(alpha: .28), blurRadius: 40, spreadRadius: 2),
              BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 24, offset: const Offset(0, 12)),
            ]),
            child: Cover21(r.cover, size: coverSize, radius: 18),
          ),
        ),
        const SizedBox(height: 18),
        Text(r.kind.toUpperCase(), style: V20Text.lab(color: pf.accent)),
        Text(r.title, style: V20Text.baloo(size: 30, line: 32)),
        const SizedBox(height: 2),
        Text('${playerName(s)} · ${dateLabel21(r.day)} · ${r.tracks.length} titre(s)', style: V20Text.poppins(size: 13, line: 18, color: V20.ink2)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _Kpi('Écoutes ${pf.name}', fmt21(r.listens))),
          const SizedBox(width: 8),
          Expanded(child: _Kpi(r.sales == null ? 'Part' : 'Ventes', r.sales == null ? '${(pf.share * 100).round()} %' : fmt21(r.sales!), gold: r.sales != null)),
        ]),
        const SizedBox(height: 8),
        for (var i = 0; i < r.tracks.length; i++) TrackRow21(s, r.tracks[i], pf, number: r.kind == 'Single' ? null : i + 1),
        const SizedBox(height: 12),
        GameHint(
            icon: 'info',
            text: r.kind == 'Single'
                ? 'Écoutes du single sur ${pf.name} : écoutes de sortie et du clip × ${(pf.share * 100).round()} % (règle provisoire).'
                : 'Écoutes du projet sur ${pf.name} : écoutes de sortie du projet × ${(pf.share * 100).round()} %. Ventes : ventes virtuelles du projet.'),
      ]),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String lab, val;
  final bool gold;
  const _Kpi(this.lab, this.val, {this.gold = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .1), width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lab.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(val, style: V20Text.baloo(size: 22, line: 24, color: gold ? Tk.gold : Tk.ink))),
        ]),
      );
}
