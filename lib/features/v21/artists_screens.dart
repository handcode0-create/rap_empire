import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/v21/artists21.dart';
import '../../domain/v21/engine21.dart' show fmt21;
import '../../domain/v21/reg21.dart';
import 'cast21.dart';
import 'labels_screens.dart' show LabelLogo21;
import 'widgets21.dart';

/// Réseau artistique (21-C4) : les trois rivalités jouables, puis l'annuaire des 1 000 artistes de Bakoma (lecture seule).

final directory21Provider = FutureProvider<Directory21>((ref) async => parseDirectory21(await rootBundle.loadString('assets/data/artistes-demo.json')));

num _n(dynamic x) => (x ?? 0) as num;

String _initials(String n) => n.split(RegExp(r"[\s'’.-]+")).where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase();

String _trend(Artist21 a) => switch (a.tendance) { 'en hausse' => '▲', 'en baisse' => '▼', _ => '–' };
Color _trendColor(Artist21 a) => switch (a.tendance) { 'en hausse' => Tk.ok, 'en baisse' => Tk.acc4, _ => V20.ink2 };

class Rivalites21Screen extends ConsumerStatefulWidget {
  const Rivalites21Screen({super.key});
  @override
  ConsumerState<Rivalites21Screen> createState() => _Rivalites21ScreenState();
}

class _Rivalites21ScreenState extends ConsumerState<Rivalites21Screen> {
  final _search = TextEditingController();
  String _statut = 'tous', _tri = 'rang';
  String? _genre;
  int _limit = 25;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset(VoidCallback f) => setState(() {
        f();
        _limit = 25;
      });

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final dir = ref.watch(directory21Provider);
    final links = s['rivals'] is Map ? s['rivals'] as Map : const {};
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Réseau artistique', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      dir.when(
        loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Chargement du réseau…'))),
        error: (e, _) => const GameHint(icon: 'info', warn: true, text: 'Annuaire indisponible pour le moment.'),
        data: (d) => _Hero(d),
      ),
      const SizedBox(height: 16),
      Text('TES RIVALITÉS', style: V20Text.lab()),
      const SizedBox(height: 8),
      for (final rival in Reg21.rivals.entries.where((e) => e.key != 'kzer')) ...[
        _RivalCard(rival.key, rival.value, links[rival.key], s),
        const SizedBox(height: 12),
      ],
      const GameHint(icon: 'info', text: 'Une battle se joue en trois rounds. À partir de deux bonnes réponses : +150 fans, +3 000 cauris bruts, +6 réputation et +60 XP. La commission du manager est retenue sur le cachet.'),
      const SizedBox(height: 20),
      Text('ANNUAIRE DES ARTISTES', style: V20Text.lab()),
      const SizedBox(height: 8),
      TextField(
        key: const ValueKey('annuaire-recherche'),
        controller: _search,
        onChanged: (_) => _reset(() {}),
        style: V20Text.poppins(size: 15, line: 22, color: Tk.ink),
        decoration: InputDecoration(
          hintText: 'Rechercher un nom, un genre, une ville, un label',
          hintStyle: V20Text.bs(color: Tk.dis),
          filled: true,
          fillColor: Tk.s1,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: _search.text.isEmpty ? null : IconButton(tooltip: 'Effacer', icon: const Icon(Icons.close, color: Tk.ink2), onPressed: () => _reset(_search.clear)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.acc, width: 2)),
        ),
      ),
      const SizedBox(height: 4),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final e in directoryStatuses21.entries) ...[
            if (e.key != 'tous') const SizedBox(width: 8),
            Chip21(e.value, selected: _statut == e.key, onTap: () => _reset(() => _statut = e.key)),
          ],
        ]),
      ),
      dir.maybeWhen(
        data: (d) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            Chip21('Tous les genres', selected: _genre == null, onTap: () => _reset(() => _genre = null)),
            for (final g in d.genres) ...[
              const SizedBox(width: 8),
              Chip21(g, selected: _genre == g, onTap: () => _reset(() => _genre = g)),
            ],
          ]),
        ),
        orElse: () => const SizedBox(),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Padding(padding: const EdgeInsets.only(right: 12), child: Text('TRI', style: V20Text.lab())),
          for (final e in directorySorts21.entries) ...[
            const SizedBox(width: 8),
            Chip21(e.value, selected: _tri == e.key, onTap: () => _reset(() => _tri = e.key)),
          ],
        ]),
      ),
      const SizedBox(height: 8),
      ...dir.maybeWhen(
        data: (d) {
          final res = filterArtists21(d, q: _search.text, statut: _statut, genre: _genre, tri: _tri);
          final shown = res.take(_limit).toList();
          return [
            Text('${fmt21(res.length)} artiste(s)', key: const ValueKey('annuaire-compte'), style: V20Text.bs()),
            const SizedBox(height: 8),
            if (res.isEmpty) const GameHint(icon: 'info', text: 'Aucun artiste ne correspond à ces filtres.'),
            for (final a in shown) _ArtistRow(a, d, () => _openArtist(context, d, a)),
            if (res.length > shown.length) ...[
              const SizedBox(height: 8),
              PrimaryButton(label: 'Voir 25 de plus', sublabel: '${shown.length} sur ${fmt21(res.length)}', style: GameButtonStyle.secondary, compact: true, onPressed: () => setState(() => _limit += 25)),
            ],
          ];
        },
        orElse: () => const <Widget>[],
      ),
      const SizedBox(height: 16),
    ]);
  }

  void _openArtist(BuildContext context, Directory21 d, Artist21 a) => showGameSheet<void>(context, builder: (ctx) => _ArtistSheet(a, d));
}

class _Hero extends StatelessWidget {
  final Directory21 d;
  const _Hero(this.d);
  @override
  Widget build(BuildContext context) {
    final signed = d.artists.where((a) => a.statut == 'signé').length;
    final up = d.artists.where((a) => a.tendance == 'en hausse').length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        key: const ValueKey('reseau-hero'),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A1B52), Tk.s1, Tk.deep])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('LA SCÈNE DE BAKOMA', style: V20Text.lab()),
          const SizedBox(height: 4),
          Text('${fmt21(d.artists.length)} artistes', style: V20Text.baloo(size: 36, line: 38, color: Tk.gold)),
          const SizedBox(height: 4),
          Text('Rivaux, alliés et futurs partenaires : tous fictifs, simulés pour l’univers du jeu.', style: V20Text.bs()),
          const SizedBox(height: 14),
          Row(children: [
            _Stat('Signés', fmt21(signed), Tk.cy),
            const SizedBox(width: 8),
            _Stat('En hausse', fmt21(up), Tk.ok),
            const SizedBox(width: 8),
            _Stat('Labels', '${d.labels.length}', Tk.acc4),
          ]),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String lab, v;
  final Color c;
  const _Stat(this.lab, this.v, this.c);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x1AFFFFFF))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(v, maxLines: 1, style: V20Text.baloo(size: 22, line: 24, color: c))),
            const SizedBox(height: 2),
            Text(lab.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
          ]),
        ),
      );
}

class _ArtistRow extends StatelessWidget {
  final Artist21 a;
  final Directory21 d;
  final VoidCallback onTap;
  const _ArtistRow(this.a, this.d, this.onTap);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Semantics(
          button: true,
          label: '${a.nom}, rang ${a.rang}, ${a.genre}, ${a.ville}',
          child: GestureDetector(
            key: ValueKey('artiste-${a.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x1FFFFFFF))),
              child: Row(children: [
                CastAvatar(a.nom, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a.nom, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm().copyWith(fontSize: 16)),
                    Text('${a.genre} · ${a.ville}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.bs().copyWith(fontSize: 12)),
                  ]),
                ),
                const SizedBox(width: 8),
                if (a.label != null) ...[LabelLogo21(a.label!, size: 28), const SizedBox(width: 10)],
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('#${a.rang}', style: V20Text.nm(color: Tk.gold)),
                  Text(_trend(a), semanticsLabel: a.tendance, style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w800, color: _trendColor(a))),
                ]),
              ]),
            ),
          ),
        ),
      );
}

class _ArtistSheet extends StatelessWidget {
  final Artist21 a;
  final Directory21 d;
  const _ArtistSheet(this.a, this.d);
  @override
  Widget build(BuildContext context) {
    final lab = a.label == null ? null : d.labels[a.label];
    Widget kpi(String l, String v, [Color c = Tk.ink]) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Tk.s2, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(v, maxLines: 1, style: V20Text.baloo(size: 18, line: 20, color: c))),
              Text(l.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
            ]),
          ),
        );
    List<Widget> rels(String title, List<String> ids) {
      final people = ids.map(d.byId).whereType<Artist21>().toList();
      if (people.isEmpty) return const [];
      return [
        const SizedBox(height: 12),
        Text(title, style: V20Text.lab()),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in people)
            Chip21('${p.nom} · #${p.rang}', onTap: () {
              Navigator.of(context).pop();
              showGameSheet<void>(context, builder: (ctx) => _ArtistSheet(p, d));
            }),
        ]),
      ];
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        a.nom.isEmpty ? const SizedBox() : CastAvatar(a.nom, size: 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.nom, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.dm(size: 24)),
            Text('${a.genre}${a.sousGenre.isEmpty ? '' : ' · ${a.sousGenre}'}', style: V20Text.bs()),
            Text('${a.ville} · ${a.id}', style: V20Text.bs().copyWith(fontSize: 12)),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        GameTag(a.palier, style: GameTagStyle.normal),
        GameTag(a.statut, style: GameTagStyle.outline),
        GameTag('${_trend(a)} ${a.tendance}', style: GameTagStyle.outline),
        if (a.certif != null) GameTag('Certif. ${a.certif}', style: GameTagStyle.ok),
      ]),
      const SizedBox(height: 12),
      Row(children: [kpi('Rang', '#${a.rang}', Tk.gold), const SizedBox(width: 8), kpi('Fans', fmt21(a.fans), Tk.cy), const SizedBox(width: 8), kpi('Écoutes 7 j', fmt21(a.ecoutes7j))]),
      const SizedBox(height: 8),
      Row(children: [
        kpi('Popularité', '${a.popularite}'),
        const SizedBox(width: 8),
        kpi('Titres', '${a.titres}'),
        const SizedBox(width: 8),
        kpi('Albums', '${a.albums}'),
      ]),
      const SizedBox(height: 10),
      MeterBar(value: (a.popularite / 100).clamp(0, 1).toDouble()),
      if (lab != null) ...[
        const SizedBox(height: 12),
        Row(children: [
          LabelLogo21(a.label!, size: 36),
          const SizedBox(width: 10),
          Expanded(child: Text('Signé chez $lab', style: V20Text.bs(color: Tk.ink))),
        ]),
      ] else ...[
        const SizedBox(height: 12),
        Text(a.labelDirige != null ? 'Dirige ${d.labels[a.labelDirige] ?? a.labelDirige}' : 'Sans label', style: V20Text.bs(color: Tk.ink)),
      ],
      if (a.managerNiveau != null) Text('Manager de niveau M${a.managerNiveau}', style: V20Text.bs()),
      ...rels('ALLIÉS', a.allies),
      ...rels('RIVAUX', a.rivaux),
      if (rivalKeyOf21(a.nom) != null) ...[
        const SizedBox(height: 12),
        const GameHint(icon: 'info', text: 'Rivalité jouable : discussion, provocation et battle sont dans « Tes rivalités ».'),
      ],
      const SizedBox(height: 4),
    ]);
  }
}

const _artistIntro = {
  'zaki': 'Zaki te croise après une sortie et te reproche de viser son public.',
  'orage': 'Madame Orage veut entendre ce que tu as réellement à défendre.',
  'djo': 'Djo Kene te lance un défi pour mesurer ton identité musicale.',
};

class _RivalCard extends ConsumerWidget {
  final String id, name;
  final dynamic link;
  final Map<String, dynamic> s;
  const _RivalCard(this.id, this.name, this.link, this.s);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = link is Map ? Map<String, dynamic>.from(link as Map) : const <String, dynamic>{};
    final relation = _n(data['relation']).round();
    final tension = _n(data['tension']).round();
    final cash = _n(s['cash']);
    return GlassCard(
      accent: tension >= 50 ? GlassAccent.magenta : GlassAccent.none,
      halo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CastAvatar(id == 'djo' ? 'Djo Kene' : name, size: 52, mood: 'smirk'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: V20Text.nm()),
              Text('Relation ${relation >= 0 ? '+' : ''}$relation · tension $tension / 100', style: V20Text.bs()),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        MeterBar(value: (tension / 100).clamp(0, 1).toDouble()),
        const SizedBox(height: 8),
        Text(_artistIntro[id]!, style: V20Text.bm),
        const SizedBox(height: 4),
        Wrap(spacing: 8, children: [
          Chip21('Discuter', onTap: () => doAct(context, ref, 'artistScene', [id, 'discuter'], null, 'Discussion terminée')),
          Chip21('Provoquer', onTap: () => doAct(context, ref, 'artistScene', [id, 'provoquer'], null, 'La rivalité monte')),
          Chip21('Apaiser', onTap: cash < 2000 ? null : () => doAct(context, ref, 'artistScene', [id, 'apaiser'], null, 'Tension réduite')),
        ]),
        Text('Discuter : 1 h · −5 énergie · relation +5. Provoquer : −10 énergie · tension +15. Apaiser : −2 000 cauris · tension −12.', style: V20Text.bs().copyWith(fontSize: 11)),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Répondre en freestyle', sublabel: 'Battle · 1 h · −15 énergie', style: GameButtonStyle.secondary, compact: true, onPressed: () => context.go('/scene/rival-battle/$id')),
      ]),
    );
  }
}
