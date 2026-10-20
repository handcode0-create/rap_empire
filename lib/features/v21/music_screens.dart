import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../core/widgets/portrait.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'reserve_screens.dart';
import 'widgets21.dart';

/// Studio v21 : création v21 complétée par les instrus, prises et mix du studio v20.

num _n(dynamic x) => (x ?? 0) as num;
// Les anciennes sauvegardes et les fixtures de démo peuvent contenir des
// ImmutableMap<dynamic, dynamic>; les vues ne modifient jamais ces maps.
J _m(dynamic x) => x is Map<String, dynamic>
    ? x
    : x is Map
        ? x.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
List _l(dynamic x) => x as List;

String _feats(J song) {
  final f = _l(song['feats']).cast<String>();
  return f.isEmpty
      ? 'Aucun'
      : f
          .map((k) => '${Reg21.feats[k]!['n']} (${Reg21.feats[k]!['role']})')
          .join(' · ');
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M2 Featurings
// ---------------------------------------------------------------------------------------------------------------------

class FeatsScreen extends ConsumerWidget {
  const FeatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final on = cur == null ? <String>[] : _l(cur['feats']).cast<String>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Featurings',
          step: '${on.length} /${Reg21.maxFeats}',
          onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (cur == null || cur['st'] == 'sorti')
        const GameHint(
            icon: 'info',
            text:
                'Écris d’abord un titre : un featuring s’ajoute à un titre en cours, jamais à un titre déjà sorti.'),
      for (final e in Reg21.feats.entries) ...[
        const SizedBox(height: 12),
        _FeatCard(id: e.key, f: e.value, s: s, added: on.contains(e.key)),
      ],
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'Artistes et conditions existants (08.3, 16-G). Rôles et effets chiffrés : proposés.'),
    ]);
  }
}

class _FeatCard extends ConsumerWidget {
  final String id;
  final J f, s;
  final bool added;
  const _FeatCard(
      {required this.id,
      required this.f,
      required this.s,
      required this.added});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rival = f['needRival'] == true;
    final popLock =
        f['needPop'] != null && _n(s['pop']) < (f['needPop'] as num);
    final locked = rival || popLock;
    final cost = _n(f['cost']);
    final initials =
        (f['n'] as String).split(' ').map((w) => w[0]).take(2).join();
    return GameCard(
      selected: added,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Portrait(initials, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f['n'] as String, style: V20Text.nm()),
              Text(
                  '${f['role']} · ${cost == 0 ? 'Sans cachet · ${f['share']} % des revenus du titre' : '${fmt21(cost)} cauris'}',
                  style: V20Text.bs()),
            ]),
          ),
          if (added)
            const GameTag('Ajouté', style: GameTagStyle.ok)
          else if (locked)
            const GameTag('Verrou', style: GameTagStyle.outline)
          else
            const GameTag('Dispo'),
        ]),
        const SizedBox(height: 8),
        Conseq21(ConsequenceKind.estimated,
            'Qualité +${f['q']} · viralité +${f['vir']} · écoutes ×${(f['boost'] as num).toString().replaceAll('.', ',')}'),
        if (popLock)
          Text('Popularité ${f['needPop']} requise',
              style: V20Text.poppins(
                  size: 11,
                  line: 14,
                  weight: FontWeight.w600,
                  color: V20.hintGoldText)),
        if (rival)
          Text('Rivalité en cours : indisponible',
              style: V20Text.poppins(
                  size: 11,
                  line: 14,
                  weight: FontWeight.w600,
                  color: V20.hintGoldText)),
        const SizedBox(height: 8),
        if (added)
          PrimaryButton(
              label: 'Retirer',
              style: GameButtonStyle.ghost,
              compact: true,
              onPressed: () => doAct(context, ref, 'unfeat', id))
        else
          PrimaryButton(
              label: 'Ajouter au titre',
              style:
                  locked ? GameButtonStyle.disabled : GameButtonStyle.secondary,
              compact: true,
              onPressed: () =>
                  doAct(context, ref, 'feat', id, null, '${f['n']} ajouté')),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M3 Préparer la sortie
// ---------------------------------------------------------------------------------------------------------------------

class SortieScreen extends ConsumerWidget {
  const SortieScreen({super.key});
  static const _promoNotes = [
    'Aucun effet',
    'Viralité +5 · portée ×1,6',
    'Viralité +12 · portée ×3,2 · Port-Ambre et Sélène +2'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final promo = _n(_m(s['ui'])['promo']).toInt();
    final ready = cur != null && cur['st'] == 'enregistre';
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Préparer la sortie', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (cur != null)
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                  child: Text(cur['title'] as String, style: V20Text.nm())),
              const GameTag('Single')
            ]),
            const SizedBox(height: 4),
            KeyVal('Qualité', ready ? '${cur['Q']}' : '—'),
            KeyVal('Viralité estimée', '${virOf21(cur, promo)}'),
            KeyVal('Featurings', _feats(cur)),
          ]),
        ),
      const SizedBox(height: 12),
      const Lab21('Promotion'),
      for (var i = 0; i < promos21.length; i++) ...[
        const SizedBox(height: 8),
        GameCard(
          selected: promo == i,
          onTap: () => ref.read(game21Provider.notifier).act('promo', i),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(promos21[i]['n'] as String, style: V20Text.nm()),
                  Text(_promoNotes[i], style: V20Text.bs())
                ])),
            Text(
                (promos21[i]['c'] as num) == 0
                    ? 'Gratuit'
                    : fmt21(promos21[i]['c'] as num),
                style: V20Text.nm(color: Tk.gold)),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      const Lab21('Avant de sortir'),
      if (cur != null) ...[
        Conseq21(ConsequenceKind.estimated, 'Viralité estimée : ${virOf21(cur, promo)}'),
        Conseq21(ConsequenceKind.estimated, 'Écoutes prévues sur 7 jours : ${fmt21(predictedListens21(s))}'),
        const Conseq21(ConsequenceKind.estimated, 'Ventes : environ 1,2 % des écoutes, à 30 cauris pièce, ajoutées aux revenus.'),
        if (_n(s['signed']) != 0) Conseq21(ConsequenceKind.certain, 'Le label garde ${((_n(s['lcut']) == 0 ? Reg21.labelCut : _n(s['lcut'])) * 100).round()} % des écoutes et des ventes.'),
      ],
      const Conseq21(ConsequenceKind.uncertain,
          'Le succès dépend aussi des fans du moment.'),
      const SizedBox(height: 8),
      const GameHint(
          icon: 'info',
          text:
              'Un clip se prépare maintenant, avant la sortie. Il ne pourra être publié qu’après.'),
      const SizedBox(height: 12),
      PrimaryGlowButton(
        label: ready ? 'Sortir le titre' : 'Enregistre d’abord le titre',
        sublabel: ready
            ? 'Promo ${promos21[promo]['n']}${(promos21[promo]['c'] as num) > 0 ? ' · −${fmt21(promos21[promo]['c'] as num)}' : ''}'
            : null,
        onPressed: ready
            ? () => doAct(context, ref, 'release', null,
                () => context.go('/studio/resultats'))
            : null,
      ),
      if (ready) ...[
        const SizedBox(height: 16),
        const ScheduleBlock21(),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M3b Résultats de la sortie
// ---------------------------------------------------------------------------------------------------------------------

class ResultatsScreen extends ConsumerWidget {
  const ResultatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final d = _l(s['disco']).isEmpty ? null : _m(_l(s['disco']).first);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Résultats de la sortie', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (d == null) ...[
        Text('Aucun titre sorti', style: V20Text.nm()),
        const SizedBox(height: 12),
        PrimaryButton(
            label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ] else ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: V20.objective, borderRadius: BorderRadius.circular(24)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SORTIE · 7 PREMIERS JOURS',
                style: V20Text.lab(color: Colors.white)),
            Text((d['title'] as String).toUpperCase(),
                style: V20Text.baloo(size: 26, line: 28)),
            Text('${fmt21(d['L'] as num)} écoutes · ${d['tier']}',
                style: V20Text.bm),
          ]),
        ),
        const SizedBox(height: 12),
        const Lab21('Quatre indicateurs'),
        KpiRow(children: [
          StatKpi(
              label: 'Qualité du titre',
              value: '${d['Q']}',
              delta: 'note 0-100'),
          StatKpi(
              label: 'Viralité',
              value: '${d['vir']}',
              delta: 'potentiel de partage')
        ]),
        const SizedBox(height: 8),
        KpiRow(children: [
          StatKpi(
              label: 'Succès',
              value: '${d['tier']}',
              delta: 'selon les écoutes'),
          StatKpi(
              label: 'Ta popularité',
              value: '${s['pop']}',
              delta: '+${d['pg']} avec ce titre')
        ]),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(children: [
            KeyVal('Nouveaux fans', '+${fmt21(d['fg'] as num)}'),
            KeyVal('Revenus des écoutes', '${fmt21(_n(d['streamRev'] ?? d['rev']))} cauris'),
            KeyVal('Ventes du single', '${fmt21(_n(d['sales']))} ventes · +${fmt21(_n(d['salesRev']))} cauris'),
            if (_n(d['cut']) > 0) KeyVal('Part du label : ${d['labelAt'] ?? ''}', '−${fmt21(d['cut'] as num)} cauris'),
            KeyVal('Total encaissé', '${fmt21(d['rev'] as num)} cauris', color: Tk.gold),
            KeyVal(
                'Featurings',
                _l(d['feats']).isEmpty
                    ? 'Aucun'
                    : _l(d['feats'])
                        .map((k) => Reg21.feats[k]!['n'])
                        .join(', ')),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CLASSEMENT', style: V20Text.lab()),
            const SizedBox(height: 4),
            Text(
                _n(d['L']) >= Reg21.entry
                    ? 'Entré au Top 100 Singles'
                    : 'Non classé · il manque ${fmt21(Reg21.entry - _n(d['L']))} écoutes (seuil ${fmt21(Reg21.entry)})',
                style: V20Text.bm),
            const SizedBox(height: 8),
            MeterBar(value: (_n(d['L']) / Reg21.entry).clamp(0, 1).toDouble()),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CARRIÈRE', style: V20Text.lab()),
            KeyVal('Rang', 'N${rankOf(s)} · ${_n(s['xp']).toInt()} XP'),
            KeyVal(
                'Prochain rang',
                rankOf(s) < Reg21.ranks.length
                    ? '${Reg21.ranks[rankOf(s)]['xp']} XP${Reg21.ranks[rankOf(s)]['cl'] != null ? ' · ${Reg21.ranks[rankOf(s)]['cl']}' : ''}'
                    : 'Rang maximal'),
          ]),
        ),
        const SizedBox(height: 8),
        const GameHint(
            icon: 'info',
            text:
                'Quatre notions distinctes : la qualité (le titre), la viralité (son potentiel de partage), le succès (ce qu’il a réellement fait) et la popularité (toi). Joueur non classé au départ (D-16).'),
        const SizedBox(height: 12),
        GameCard(
            onTap: () => context.go('/studio/clip'),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Clip', style: V20Text.nm()),
                    Text(clipLabel(_m(d['clip'])['st'] as String),
                        style: V20Text.bs())
                  ])),
              const Icon(Icons.arrow_forward_rounded, color: Tk.ink)
            ])),
        const SizedBox(height: 8),
        GameCard(
            onTap: () => context.go('/profil/classements'),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Classements', style: V20Text.nm()),
                    Text(
                        'Singles · ${singlesRank(s) == 0 ? 'Non classé' : '#${singlesRank(s)}'}',
                        style: V20Text.bs())
                  ])),
              const Icon(Icons.arrow_forward_rounded, color: Tk.ink)
            ])),
        const SizedBox(height: 16),
        PrimaryGlowButton(
            label: 'Retour au QG', onPressed: () => context.go('/')),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M4 Clip : préparer, tourner, publier
// ---------------------------------------------------------------------------------------------------------------------

class ClipScreen extends ConsumerWidget {
  const ClipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final t = clipSong21(s);
    final cs = t == null ? 'none' : _m(t['clip'])['st'] as String;
    final sold = t != null && t['st'] == 'sorti';
    final rank = rankOf(s);
    final dir = _m(s['ui'])['dir'] as String?;
    final moto = _m(s['own'])['moto'] != null;
    final canPrep = t != null && !sold && cs == 'aucun';
    Widget step(String label, bool done) => Expanded(
          child: Column(children: [
            Container(
                height: 6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: done
                        ? Tk.ok
                        : const Color.fromRGBO(255, 255, 255, .14))),
            const SizedBox(height: 4),
            Text(label.toUpperCase(),
                style: V20Text.poppins(
                    size: 10,
                    line: 12,
                    weight: FontWeight.w700,
                    color: V20.ink2)),
          ]),
        );
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Clip', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
                child: Text(t == null ? 'Aucun titre' : t['title'] as String,
                    style: V20Text.nm())),
            GameTag(
                t == null ? '—' : (sold ? 'Titre sorti' : 'Titre non sorti'))
          ]),
          const SizedBox(height: 8),
          Row(children: [
            step('Préparé', cs != 'aucun' && cs != 'none'),
            const SizedBox(width: 6),
            step('Tourné', cs == 'produit' || cs == 'publie'),
            const SizedBox(width: 6),
            step('Titre sorti', sold),
            const SizedBox(width: 6),
            step('Publié', cs == 'publie')
          ]),
          const SizedBox(height: 8),
          KeyVal(
              'Réalisation',
              t != null && _m(t['clip'])['dir'] != null
                  ? Reg21.directors[_m(t['clip'])['dir']]!['n'] as String
                  : '—'),
        ]),
      ),
      if (t == null) ...[
        const SizedBox(height: 12),
        const GameHint(
            icon: 'info',
            text: 'Aucun titre : écris d’abord un titre au studio.'),
      ],
      if (t != null && cs == 'aucun') ...[
        const SizedBox(height: 12),
        const Lab21('1 · Préparer (avant la sortie)'),
        for (final e in Reg21.directors.entries) ...[
          const SizedBox(height: 8),
          GameCard(
            selected: dir == e.key,
            onTap: rank < (e.value['rank'] as num)
                ? null
                : () => ref.read(game21Provider.notifier).act('dir', e.key),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(e.value['n'] as String,
                        style: V20Text.nm(
                            color: rank < (e.value['rank'] as num)
                                ? Tk.dis
                                : Tk.ink)),
                    Text(
                        rank < (e.value['rank'] as num)
                            ? '${e.value['lv']} · rang N${e.value['rank']} requis'
                            : '${e.value['lv']} · viralité +${e.value['vir']}',
                        style: V20Text.bs())
                  ])),
              rank < (e.value['rank'] as num)
                  ? GameTag('N${e.value['rank']}', style: GameTagStyle.outline)
                  : Text(fmt21(e.value['cost'] as num),
                      style: V20Text.nm(color: Tk.gold)),
            ]),
          ),
        ],
        const SizedBox(height: 8),
        if (sold)
          const GameHint(
              icon: 'info',
              warn: true,
              text:
                  'Trop tard pour ce titre : un clip se prépare avant la sortie. Prépare-le pour ton prochain titre.'),
        if (canPrep)
          PrimaryButton(
              label: 'Préparer avec ce réalisateur',
              sublabel: 'Paiement à la préparation',
              onPressed: dir == null
                  ? null
                  : () => doAct(
                      context, ref, 'clipPrep', dir, null, 'Clip préparé')),
      ],
      if (t != null && cs == 'prepare') ...[
        const SizedBox(height: 12),
        const Lab21('2 · Tourner'),
        Conseq21(ConsequenceKind.certain,
            '${Reg21.shootH} h · −${Reg21.shootE - (moto ? 5 : 0)} énergie${moto ? '' : ' (−5 avec la moto)'}'),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Tourner le clip',
            onPressed: () => doAct(
                context, ref, 'clipShoot', null, null, 'Tournage terminé')),
      ],
      if (t != null && (cs == 'prepare' || cs == 'produit') && !sold) ...[
        const SizedBox(height: 12),
        const Lab21('3 · Sortie du titre'),
        const Text('Publication possible après la sortie'),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Préparer la sortie du titre',
            style: GameButtonStyle.secondary,
            onPressed: () => context.go('/studio/sortie')),
      ],
      if (t != null && sold && cs == 'produit') ...[
        const SizedBox(height: 12),
        const Lab21('4 · Publier'),
        const Conseq21(ConsequenceKind.estimated,
            'Viralité du titre en hausse, écoutes supplémentaires, popularité +2.'),
        const SizedBox(height: 8),
        PrimaryGlowButton(
            label: 'Publier le clip',
            onPressed: () => doAct(context, ref, 'clipPub', null,
                () => context.go('/studio/clip-publie'))),
      ],
      if (cs == 'publie') ...[
        const SizedBox(height: 12),
        PrimaryButton(
            label: 'Voir les effets',
            onPressed: () => context.go('/studio/clip-publie')),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M5 Résultats du clip
// ---------------------------------------------------------------------------------------------------------------------

class ClipPubScreen extends ConsumerWidget {
  const ClipPubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final d = _l(s['disco']).isEmpty ? null : _m(_l(s['disco']).first);
    final pub = d != null && _m(d['clip'])['st'] == 'publie';
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Clip publié', onBack: () => context.go('/studio/clip')),
      const SizedBox(height: 12),
      if (!pub) ...[
        Text('Aucun clip publié', style: V20Text.nm()),
        const SizedBox(height: 12),
        PrimaryButton(
            label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CLIP PUBLIÉ', style: V20Text.lab(color: V20.accText)),
            Text(d['title'] as String,
                style: V20Text.baloo(size: 24, line: 26)),
            Conseq21(ConsequenceKind.estimated,
                '+${fmt21(_n(d['clipL']))} écoutes · +${fmt21(_n(d['clipF']))} fans · viralité ${d['vir0'] ?? d['vir']} → ${d['vir']}'),
          ]),
        ),
        const SizedBox(height: 12),
        KpiRow(children: [
          StatKpi(label: 'Écoutes du titre', value: fmt21(d['L'] as num)),
          StatKpi(label: 'Succès', value: '${d['tier']}')
        ]),
        const SizedBox(height: 8),
        KpiRow(children: [
          StatKpi(label: 'Viralité', value: '${d['vir']}'),
          StatKpi(label: 'Popularité', value: '${s['pop']}')
        ]),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('POPULARITÉ PAR VILLE', style: V20Text.lab()),
            const SizedBox(height: 4),
            for (final c in Reg21.cities.entries)
              Gauge21(c.value, geoOf(s, c.key), color: Tk.cy),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryGlowButton(
            label: 'Voir mes clips', onPressed: () => context.go('/profil/reseau/clips')),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Retour au studio', style: GameButtonStyle.ghost, onPressed: () => context.go('/studio')),
      ],
    ]);
  }
}
