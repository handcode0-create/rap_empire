import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'library_screens.dart' show Cover21, projectCover21, trackCover21;
import 'wardrobe_screens.dart' show EquippedAvatar;

/// Bakopédia (21-W1) : l'article encyclopédique de l'artiste, écrit automatiquement à partir de sa carrière :
/// infobox, résumé, biographie, discographie, distinctions, classements, scène, finances, collaborations.
/// Présentation seulement : chaque chiffre vient de l'état du jeu (aucune donnée inventée). Monde fictif.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic> ? x : (x is Map ? x.map((k, v) => MapEntry('$k', v)) : <String, dynamic>{});
List _l(dynamic x) => x is List ? x : const [];

class WikiScreen21 extends ConsumerWidget {
  const WikiScreen21({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final p = _m(s['p']);
    final name = playerName(s);
    final day = _n(s['day']);
    final style = '${Reg21.styles[p['main']]?['n'] ?? p['main']}';
    final origin = Reg21.origins[p['origin']] ?? 'Bakoma';
    final disco = _l(s['disco']).map(_m).toList()..sort((a, b) => _n(a['day']).compareTo(_n(b['day'])));
    final projects = _l(s['projects']).map(_m).toList()..sort((a, b) => _n(a['day']).compareTo(_n(b['day'])));
    final albums = projects.where((x) => x['type'] == 'Album').toList(), eps = projects.where((x) => x['type'] == 'EP').toList();
    final inedits = {for (final x in projects) for (final i in _l(x['inedits'])) '${_m(i)['id']}'};
    final singles = disco.where((t) => !inedits.contains('${t['id']}')).toList();
    final signed = _n(s['signed']) != 0;
    final label = signed ? lblName21(s) : 'Indépendant';
    final mgr = managerTier21(s);
    final certs = certs21(s).where((c) => c.level >= 0).toList();
    final awards = awardHistory21(s);
    final certOf = {for (final c in certs21(s)) c.id: c};
    final yearsActive = yearOf21(day) == 1 ? 'An 1' : 'An 1 à An ${yearOf21(day)}';
    final music = disco.fold<num>(0, (a, t) => a + _n(t['rev'])) + projects.fold<num>(0, (a, x) => a + _n(x['rev']));
    final bizTot = _m(s['biz']).values.fold<num>(0, (a, b) => a + _n(_m(b)['tot']));
    final feats = <String, int>{};
    for (final t in disco) {
      for (final f in _l(t['feats'])) {
        final n = '${Reg21.feats['$f']?['n'] ?? f}';
        feats[n] = (feats[n] ?? 0) + 1;
      }
    }
    final best = myChart21(s, 'singles'), bestAlbum = myChart21(s, 'albums'), bestEp = myChart21(s, 'eps'), global = myChart21(s, 'global');

    // biographie : les faits marquants dans l'ordre
    final bio = <(num, String)>[
      (1, '$name commence sa carrière à $origin, avec un premier objectif : ${'${Reg21.goals[p['goal']]?['n'] ?? 'se faire un nom'}'.toLowerCase()}.'),
      if (singles.isNotEmpty) (_n(singles.first['day']), 'Premier single : « ${singles.first['title']} ».'),
      for (final x in projects) (_n(x['day']), 'Sortie ${x['type'] == 'EP' ? 'de l’EP' : 'de l’album'} « ${x['title']} » (${fmt21(_n(x['sales']))} ventes à la sortie${_n(x['rank']) > 0 ? ', entrée à la #${x['rank']}' : ''}).'),
      for (final c in certs) (1e9, '« ${c.title} » est certifié ${c.name.toLowerCase()}.'),
      for (final a in awards.where((a) => a['res'] == 'win')) (_n(a['d']), 'Lauréat : ${_awardName(a)}.'),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    final summary = '$name est un artiste de rap ${style.toLowerCase().startsWith('drill') ? 'drill' : 'de Bakoma'} originaire de $origin. '
        '${signed ? 'Signé chez $label' : 'Artiste indépendant'}, il compte ${fmt21(_n(s['fans']))} fans, ${disco.length} titre(s) sorti(s)'
        '${projects.isEmpty ? '' : ', ${albums.length} album(s) et ${eps.length} EP'}'
        '${certs.isEmpty ? '' : ' et ${certs.length} certification(s)'}. Il est classé ${rankName(s).toLowerCase()} (N${rankOf(s)}).';

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      BackHeader(title: 'Bakopédia', step: 'Article', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      // bandeau de l'encyclopédie (fictive)
      Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Tk.ink.withValues(alpha: .7), width: 1.5)),
          child: Text('B', style: V20Text.baloo(size: 24, line: 26)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BAKOPÉDIA', style: V20Text.baloo(size: 16, line: 18)),
            Text('L’encyclopédie libre de Bakoma', style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
          ]),
        ),
        const GameTag('Monde fictif', style: GameTagStyle.outline),
      ]),
      const SizedBox(height: 16),
      Text(name, style: V20Text.baloo(size: 32, line: 34)),
      Text('Rappeur de Bakoma · $style', style: V20Text.poppins(size: 13, line: 18, color: V20.ink2)),
      const Divider(color: Tk.line, height: 24),
      // infobox
      GlassCard(
        halo: false,
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Tk.s2, Tk.deep])),
            alignment: Alignment.bottomCenter,
            child: EquippedAvatar(s, width: 130, height: 196),
          ),
          const SizedBox(height: 6),
          Text('$name en ${yearsActive.toLowerCase()}', style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
          const SizedBox(height: 8),
          _Info('Nom de scène', name),
          _Info('Origine', origin),
          _Info('Âge', '${_n(s['age']).toInt()} ans'),
          _Info('Genre', '$style${p['second'] != null ? ' · ${Reg21.styles[p['second']]?['n'] ?? ''}' : ''}'),
          _Info('Années d’activité', yearsActive),
          _Info('Label', label),
          _Info('Manager', mgr == null ? 'Aucun' : '${mgr['n']}'),
          _Info('Rang', 'N${rankOf(s)} · ${rankName(s)}'),
          _Info('Fans', fmt21(_n(s['fans']))),
          _Info('Popularité', '${_n(s['pop']).toInt()} / 100'),
        ]),
      ),
      const SizedBox(height: 16),
      Text(summary, style: V20Text.poppins(size: 14, line: 21)),
      const _H('Biographie'),
      for (final b in bio) _Line(b.$1 >= 1e9 ? 'Certifié' : dateLabel21(b.$1), b.$2),
      const _H('Discographie'),
      _Sub('Albums studio', albums.isEmpty ? 'Aucun album pour l’instant.' : null),
      for (final x in albums) _Disc(projectCover21(x), '${x['title']}', '${dateLabel21(_n(x['day']))} · ${_l(x['tracks']).length} titres', '${fmt21(_n(x['sales']))} ventes', certOf['${x['id']}']?.level, certOf['${x['id']}']?.name),
      _Sub('EP', eps.isEmpty ? 'Aucun EP pour l’instant.' : null),
      for (final x in eps) _Disc(projectCover21(x), '${x['title']}', '${dateLabel21(_n(x['day']))} · ${_l(x['tracks']).length} titres', '${fmt21(_n(x['sales']))} ventes', certOf['${x['id']}']?.level, certOf['${x['id']}']?.name),
      _Sub('Singles', singles.isEmpty ? 'Aucun single pour l’instant.' : null),
      for (final t in singles.reversed) _Disc(trackCover21(t), '${t['title']}', dateLabel21(_n(t['day'])), '${fmt21(platformListens(t))} écoutes', certOf['${t['id']}']?.level, certOf['${t['id']}']?.name),
      const _H('Distinctions'),
      _Sub('Certifications', certs.isEmpty ? 'Aucune certification pour l’instant (Disque d’or à ${fmt21(certThresholds21['Single']!.first)} unités).' : null),
      for (final c in certs) _Line(c.kind, '${c.name} · « ${c.title} » · ${fmt21(c.units)} unités'),
      _Sub('Récompenses', awards.isEmpty ? 'Aucune nomination pour l’instant.' : null),
      for (final a in awards) _Line('An ${a['y']}', '${a['res'] == 'win' ? 'Lauréat' : 'Nommé'} · ${_awardName(a)}'),
      const _H('Classements de la semaine'),
      _Info('Top 100 Singles', _rk(best)),
      _Info('Top 200 Albums', _rk(bestAlbum)),
      _Info('Top 50 EPs', _rk(bestEp)),
      _Info('Top 10 Global Artists', _rk(global)),
      const _H('Carrière scénique'),
      _Info('Dates jouées', '${_n(s['shows']).toInt()}'),
      _Info('Popularité à Bakoma', '${_n(_m(s['geo'])['bakoma']).toStringAsFixed(1)}'),
      _Info('Port-Ambre · Sélène', '${_n(_m(s['geo'])['portambre']).toStringAsFixed(1)} · ${_n(_m(s['geo'])['selene']).toStringAsFixed(1)}'),
      const _H('Finances'),
      _Info('En caisse', '${fmt21(_n(s['cash']))} cauris'),
      _Info('Revenus de la musique', '${fmt21(music)} cauris'),
      _Info('Revenus des entreprises', '${fmt21(bizTot)} cauris'),
      _Info('Patrimoine', '${_m(s['own']).length} bien(s)'),
      _Info('Entreprises actives', '${_m(s['biz']).length}'),
      const _H('Collaborations'),
      if (feats.isEmpty) Text('Aucun featuring pour l’instant.', style: V20Text.bs()),
      for (final e in feats.entries) _Line('Feat.', '${e.key} · ${e.value} titre(s)'),
      const SizedBox(height: 20),
      Text('Dernière modification : ${dateLabel21(day)}. Article écrit automatiquement à partir de ta carrière ; données simulées de l’univers du jeu.',
          style: V20Text.poppins(size: 11, line: 15, color: V20.ink2)),
    ]);
  }
}

String _awardName(J a) {
  for (final c in ceremonies21) {
    if (c.id == a['c']) {
      final cat = c.cats.where((x) => x.id == a['cat']).firstOrNull;
      return '${c.n}${cat == null ? '' : ' · ${cat.n}'} (An ${a['y']})';
    }
  }
  return '${a['c']}';
}

String _rk(({String title, num value, int rank, J? item})? m) => m == null ? '—' : (m.rank == 0 ? 'Non classé' : '#${m.rank} · ${m.title}');

class _H extends StatelessWidget {
  final String t;
  const _H(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: V20Text.baloo(size: 22, line: 26)),
          const SizedBox(height: 4),
          Container(height: 1, color: Tk.line),
        ]),
      );
}

class _Sub extends StatelessWidget {
  final String t;
  final String? empty;
  const _Sub(this.t, this.empty);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.toUpperCase(), style: V20Text.lab(color: V20.accText)),
          if (empty != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(empty!, style: V20Text.bs())),
        ]),
      );
}

class _Info extends StatelessWidget {
  final String k, v;
  const _Info(this.k, this.v);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: .07)))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 132, child: Text(k, style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700, color: V20.ink2))),
          Expanded(child: Text(v, style: V20Text.poppins(size: 13, line: 17))),
        ]),
      );
}

class _Line extends StatelessWidget {
  final String k, v;
  const _Line(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(k, style: V20Text.poppins(size: 11, line: 16, weight: FontWeight.w700, color: Tk.gold))),
          Expanded(child: Text(v, style: V20Text.poppins(size: 13, line: 18))),
        ]),
      );
}

class _Disc extends StatelessWidget {
  final String cover, title, sub, figure;
  final int? certLevel;
  final String? certName;
  const _Disc(this.cover, this.title, this.sub, this.figure, this.certLevel, this.certName);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Cover21(cover, size: 48, radius: 8),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700)),
              Text('$sub · $figure', maxLines: 2, style: V20Text.poppins(size: 11, line: 15, color: V20.ink2)),
            ]),
          ),
          if (certLevel != null && certLevel! >= 0) ...[const SizedBox(width: 6), GameTag(certName!.replaceAll('Disque ', ''), style: GameTagStyle.outline, color: Tk.gold)],
        ]),
      );
}
