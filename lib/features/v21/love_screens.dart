import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/candidate_portrait.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/portrait.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'shell21.dart';
import 'widgets21.dart';

/// Vie perso : rencontres (21-01 à 21-04), officialisation et couple (21-05, 21-06), mariage (21-07 à 21-09),
/// séparation (21-10, 21-10b) et famille (21-11 à 21-14). Toutes les règles sont dans le moteur v21 (D-G07).

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;
List _l(dynamic x) => x as List;

String _cand(J s) => (_m(s['ui'])['cand'] ?? 'lina') as String;
int _g(J s, String cid) => _n(_m(_m(_m(s['rom'])['c'])[cid])['g']).toInt();
String? _off(J s) => _m(s['rom'])['off'] as String?;
bool _blocked(J s, String cid) {
  final rom = _m(s['rom']);
  final ex = _m(rom['ex'])[cid];
  return (rom['off'] != null && rom['off'] != cid) ||
      (ex != null && _n(s['day']) < _n(ex));
}

int _gain(String cid, String act) {
  final c = cands21[cid]!;
  final mul = _l(c['likes']).contains(act)
      ? Reg21.likeMul
      : (_l(c['dis']).contains(act) ? Reg21.dislikeMul : 1.0);
  return jsRound((Reg21.romActs[act]!['g'] as num) * mul);
}

String _actInfo(J a) =>
    '${a['h']} h${_n(a['e']) != 0 ? ' · −${a['e']} énergie' : ''}${_n(a['c']) != 0 ? ' · −${fmt21(a['c'] as num)} cauris' : ''}';

// ---------------------------------------------------------------------------------------------------------------------
// 21-01 Rencontres
// ---------------------------------------------------------------------------------------------------------------------

class RencontresScreen extends ConsumerWidget {
  const RencontresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final off = _off(s);
    return Frame21(children: [
      BackHeader(
          title: 'Rencontres',
          step:
              '${_n(_m(s['rom'])['used']).toInt()}/${Reg21.romPerDay} aujourd’hui',
          onBack: () => context.go('/')),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'Huit personnes de ton entourage. Profils et préférences visibles. Tu peux en fréquenter plusieurs tant qu’aucune relation n’est officielle.'),
      if (off != null) ...[
        const SizedBox(height: 8),
        GameHint(
            icon: 'info',
            warn: true,
            text:
                'En couple avec ${cands21[off]!['n']} : la relation est exclusive, les autres profils sont en pause.')
      ],
      for (final e in cands21.entries) ...[
        const SizedBox(height: 12),
        Opacity(
          opacity: _blocked(s, e.key) ? .55 : 1,
          child: GameCard(
            selected: off == e.key,
            onTap: () async {
              await ref.read(game21Provider.notifier).act('cand', e.key);
              if (context.mounted) context.go('/perso/profil');
            },
            child: Row(children: [
              CandidatePortrait(e.key, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value['n'] as String, style: V20Text.nm()),
                      Text(
                          '${e.value['age']} ans · ${e.value['job']} · ${e.value['city']}',
                          style: V20Text.bs()),
                      Gauge21('Relation', _g(s, e.key), labelWidth: 60),
                    ]),
              ),
              if (off == e.key)
                const GameTag('En couple', style: GameTagStyle.ok)
              else if (_blocked(s, e.key))
                const GameTag('Indisponible', style: GameTagStyle.outline),
            ]),
          ),
        ),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-02 Profil détaillé et compatibilité
// ---------------------------------------------------------------------------------------------------------------------

class CandProfilScreen extends ConsumerWidget {
  const CandProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cid = _cand(s), c = cands21[cid]!, g = _g(s, cid), off = _off(s);
    final left = Reg21.romPerDay - _n(_m(s['rom'])['used']).toInt();
    final ex = _m(_m(s['rom'])['ex'])[cid];
    return Frame21(children: [
      BackHeader(title: 'Profil', onBack: () => context.go('/perso')),
      const SizedBox(height: 12),
      Row(children: [
        CandidatePortrait(cid, size: 88),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('COMPATIBILITÉ ${c['comp']} %',
                style: V20Text.lab(color: V20.accText)),
            Text(c['n'] as String, style: V20Text.dm(size: 26)),
            Text('${c['age']} ans · ${c['job']} · ${c['city']}',
                style: V20Text.bs()),
          ]),
        ),
      ]),
      const SizedBox(height: 8),
      Text(c['bio'] as String, style: V20Text.bm),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('PRÉFÉRENCES', style: V20Text.lab()),
            const GameTag('Visibles', style: GameTagStyle.ok)
          ]),
          KeyVal('Aime',
              _l(c['likes']).map((a) => Reg21.romActs[a]!['n']).join(' · ')),
          KeyVal("N'aime pas",
              _l(c['dis']).map((a) => Reg21.romActs[a]!['n']).join(' · ')),
          const Conseq21(ConsequenceKind.estimated,
              'Compatibilité calculée sur ses goûts : indicative.'),
        ]),
      ),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Gauge21('Relation', g),
          Text(
              'Seuils : ${Reg21.officialAt} couple officiel · ${Reg21.proposeAt} mariage possible',
              style: V20Text.bs()),
        ]),
      ),
      if (off == cid) ...[
        const SizedBox(height: 8),
        const GameHint(icon: 'info', text: 'C’est ta relation officielle.')
      ],
      if (off != null && off != cid) ...[
        const SizedBox(height: 8),
        const GameHint(
            icon: 'info',
            warn: true,
            text:
                'Tu es en couple avec quelqu’un d’autre : relation exclusive.')
      ],
      if (ex != null && _n(s['day']) < _n(ex)) ...[
        const SizedBox(height: 8),
        const GameHint(
            icon: 'info',
            warn: true,
            text:
                'Relation terminée récemment : pas de nouvelle approche pendant 30 jours.')
      ],
      const SizedBox(height: 12),
      PrimaryGlowButton(
          label: 'Interagir',
          sublabel: '$left action(s) restante(s) aujourd’hui',
          onPressed: () => context.go('/perso/interactions')),
      const SizedBox(height: 8),
      if (off == null && g >= Reg21.officialAt)
        PrimaryButton(
            label: 'Officialiser la relation',
            style: GameButtonStyle.secondary,
            onPressed: () => context.go('/perso/officialiser'))
      else if (off == null)
        Text('Officialisation : encore ${Reg21.officialAt - g} points.',
            style: V20Text.bs(color: Tk.ink)),
      const SizedBox(height: 8),
      ActionRow(
          title: 'Historique de la relation',
          subtitle: 'Jauge, baisse quotidienne, seuils',
          trailing: ActionRow.arrow(),
          onTap: () => context.go('/perso/relation')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-03 Interactions romantiques
// ---------------------------------------------------------------------------------------------------------------------

class InteractionsScreen extends ConsumerWidget {
  const InteractionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cid = _cand(s), c = cands21[cid]!, rom = _m(s['rom']);
    final used = _n(rom['used']).toInt();
    final noMore = used >= Reg21.romPerDay;
    final blocked = _blocked(s, cid);
    final la = rom['lastAct'] as J?;
    return Frame21(children: [
      BackHeader(
          title: 'Interactions',
          step: '$used/${Reg21.romPerDay}',
          onBack: () => context.go('/perso/profil')),
      const SizedBox(height: 12),
      GlassCard(
        child: Row(children: [
          CandidatePortrait(cid, size: 48),
          const SizedBox(width: 12),
          Expanded(child: Text(c['n'] as String, style: V20Text.nm())),
          Text('${_g(s, cid)}/100', style: V20Text.nm(color: Tk.ink)),
        ]),
      ),
      const SizedBox(height: 8),
      const Conseq21(ConsequenceKind.certain,
          'Deux actions romantiques par journée, toutes personnes confondues.'),
      if (noMore)
        const GameHint(
            icon: 'info',
            warn: true,
            text:
                'Tes deux actions du jour sont utilisées. Termine la journée pour en retrouver.'),
      if (blocked)
        const GameHint(
            icon: 'info',
            warn: true,
            text:
                'Relation exclusive en cours ou récente : actions impossibles avec cette personne.'),
      for (final e in Reg21.romActs.entries) ...[
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final mul = _l(c['likes']).contains(e.key)
              ? 'aime : gain ×1,5'
              : (_l(c['dis']).contains(e.key) ? 'n’aime pas : gain ×0,5' : '');
          final off = noMore || blocked;
          return ActionRow(
            title: e.value['n'] as String,
            subtitle:
                '${_actInfo(e.value)}${e.key == 'scene' ? ' · après un concert ou un open mic' : ''}${mul.isEmpty ? '' : '\n${c['n']} $mul'}',
            disabled: off,
            trailing:
                Text('+${_gain(cid, e.key)}', style: V20Text.nm(color: Tk.ok)),
            onTap: () => doAct(context, ref, 'rom', [cid, e.key]),
          );
        }),
      ],
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DERNIÈRE ACTION', style: V20Text.lab()),
          Text(
              la == null
                  ? 'Aucune action aujourd’hui'
                  : '${Reg21.romActs[la['act']]!['n']} avec ${cands21[la['cid']]!['n']} : ${sg21(_n(la['gain']))}${_n(la['mul']) > 1 ? ' (préférence)' : (_n(la['mul']) < 1 ? " (n'aime pas)" : '')}',
              style: V20Text.bs(color: Tk.ink)),
        ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-04 Jauge et historique
// ---------------------------------------------------------------------------------------------------------------------

class RelationScreen extends ConsumerWidget {
  const RelationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cid = _off(s) ?? _cand(s);
    final hist = _l(_m(s['rom'])['hist']).reversed.take(5).toList();
    return Frame21(children: [
      BackHeader(title: 'Relation', onBack: () => context.go('/perso/profil')),
      const SizedBox(height: 12),
      GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(cands21[cid]!['n'] as String, style: V20Text.nm()),
        Gauge21('Relation', _g(s, cid))
      ])),
      const SizedBox(height: 12),
      const GlassCard(
        child: Column(children: [
          KeyVal('Couple officiel', '${Reg21.officialAt}'),
          KeyVal('Mariage possible',
              '${Reg21.proposeAt} et ${Reg21.proposeMinDays} jours de couple'),
          KeyVal('Alerte', 'sous ${Reg21.warnAt}'),
          KeyVal('Rupture par le partenaire', 'sous ${Reg21.leaveAt}'),
        ]),
      ),
      const SizedBox(height: 12),
      const Lab21('Évolution quotidienne'),
      const Conseq21(ConsequenceKind.certain,
          'Sans action ce jour-là : −${Reg21.decayCourt} pendant la phase de rencontre, −${Reg21.decayCouple} en couple.'),
      const Conseq21(ConsequenceKind.certain,
          'Une action positive le même jour annule la baisse.'),
      const Conseq21(ConsequenceKind.risk,
          'Sous ${Reg21.leaveAt}, ton/ta partenaire peut partir : tu es prévenu(e) dès ${Reg21.warnAt}.'),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HISTORIQUE', style: V20Text.lab()),
          if (hist.isEmpty)
            Text('Aucun événement marquant pour l’instant.',
                style: V20Text.bs()),
          for (final h in hist)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${dateLabel21(_m(h)['d'] as num)} · ${_m(h)['t']}',
                    style: V20Text.bs(color: Tk.ink))),
        ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-05 Officialisation
// ---------------------------------------------------------------------------------------------------------------------

class OfficialScreen extends ConsumerWidget {
  const OfficialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cid = _cand(s), c = cands21[cid]!;
    final ok = _off(s) == null && _g(s, cid) >= Reg21.officialAt;
    return Frame21(children: [
      BackHeader(
          title: 'Officialiser', onBack: () => context.go('/perso/profil')),
      const SizedBox(height: 12),
      Text('EN COUPLE AVEC ${(c['n'] as String).toUpperCase()} ?',
          style: V20Text.dm(size: 26)),
      const SizedBox(height: 12),
      const Conseq21(ConsequenceKind.certain,
          'Relation exclusive : les autres profils passent en pause.'),
      Conseq21(ConsequenceKind.certain,
          'Charges du foyer : +${fmt21(Reg21.coupleCost)} cauris par jour.'),
      const Conseq21(ConsequenceKind.certain,
          'Sans entretien : −${Reg21.decayCouple} par jour.'),
      const Conseq21(ConsequenceKind.uncertain,
          'Mariage possible plus tard (jauge ${Reg21.proposeAt} et ${Reg21.proposeMinDays} jours de couple).'),
      const SizedBox(height: 16),
      if (ok)
        PrimaryGlowButton(
            label: 'Officialiser',
            onPressed: () => doAct(context, ref, 'official', cid,
                () => context.go('/perso/couple'), 'Vous êtes en couple'))
      else ...[
        const PrimaryButton(label: 'Conditions non réunies', onPressed: null),
        const SizedBox(height: 4),
        Text(
            'Jauge ${Reg21.officialAt} requise, et aucune autre relation officielle.',
            style: V20Text.bs()),
      ],
      const SizedBox(height: 8),
      PrimaryButton(
          label: 'Pas maintenant',
          style: GameButtonStyle.ghost,
          onPressed: () => context.go('/perso/profil')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-06 Vie de couple
// ---------------------------------------------------------------------------------------------------------------------

class CoupleScreen extends ConsumerWidget {
  const CoupleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final off = _off(s), rom = _m(s['rom']);
    final married = rom['married'] == 1;
    final used = _n(rom['used']).toInt();
    final r = partner(s);
    return Frame21(children: [
      BackHeader(title: 'Vie de couple', onBack: () => context.go('/')),
      const SizedBox(height: 4),
      Align(
          alignment: Alignment.centerRight,
          child: GameTag(
              married ? 'Marié(e)s' : (off != null ? 'En couple' : 'Seul(e)'))),
      const SizedBox(height: 8),
      if (off == null) ...[
        Text('Aucune relation officielle', style: V20Text.nm()),
        Text('Rencontre, puis officialise une relation.', style: V20Text.bm),
        const SizedBox(height: 12),
        PrimaryGlowButton(
            label: 'Rencontres', onPressed: () => context.go('/perso')),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child: Row(children: [
            CandidatePortrait(off, size: 56),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(cands21[off]!['n'] as String, style: V20Text.nm()),
                  Text('${_n(s['day']) - _n(rom['since'])} jours ensemble',
                      style: V20Text.bs()),
                  Gauge21('Relation', _n(r!['g']))
                ])),
          ]),
        ),
        if (_n(r['g']) < Reg21.warnAt) ...[
          const SizedBox(height: 8),
          const GameHint(
              icon: 'info',
              warn: true,
              text:
                  'Relation fragile : sous ${Reg21.leaveAt}, ton/ta partenaire peut partir.')
        ],
        const SizedBox(height: 12),
        Lab21('Moments à deux · $used/${Reg21.romPerDay}'),
        for (final e in Reg21.romActs.entries)
          if (e.key != 'scene')
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActionRow(
                  title: e.value['n'] as String,
                  subtitle: _actInfo(e.value),
                  disabled: used >= Reg21.romPerDay,
                  trailing: ActionRow.arrow(disabled: used >= Reg21.romPerDay),
                  onTap: () => doAct(context, ref, 'romp', e.key)),
            ),
        const SizedBox(height: 4),
        if (canPropose21(s))
          GlassCard(
            accent: GlassAccent.magenta,
            halo: false,
            onTap: () => context.go('/perso/demande'),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MOMENT IMPORTANT', style: V20Text.lab(color: V20.accText)),
              Text('Une demande en mariage t’attend', style: V20Text.nm())
            ]),
          )
        else if (!married)
          ActionRow(
            title: 'Mariage',
            subtitle:
                'Encore ${(Reg21.proposeAt - _n(r['g'])).clamp(0, 100).toInt()} point(s) et ${(Reg21.proposeMinDays - (_n(s['day']) - _n(rom['since']))).clamp(0, 999).toInt()} jour(s).',
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/perso/demande'),
          ),
        const SizedBox(height: 8),
        ActionRow(
            title: 'Famille',
            subtitle: '${_l(_m(s['fam'])['kids']).length} enfant(s)',
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/famille')),
        const SizedBox(height: 8),
        ActionRow(
            title: 'Séparation',
            subtitle: 'Conséquences',
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/perso/separation')),
        const SizedBox(height: 12),
        Conseq21(ConsequenceKind.certain,
            'Charges du foyer : ${fmt21(Reg21.coupleCost)} cauris par jour. La carrière n’est jamais bloquée.'),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-07 Demande en mariage, 21-08 Préparation, 21-09 Confirmation
// ---------------------------------------------------------------------------------------------------------------------

class DemandeScreen extends ConsumerWidget {
  const DemandeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final rom = _m(s['rom']), r = partner(s);
    final can = canPropose21(s);
    return Frame21(children: [
      BackHeader(
          title: 'Moment important', onBack: () => context.go('/perso/couple')),
      const SizedBox(height: 12),
      if (can && r != null) ...[
        Text('${cands21[rom['off']]!['n']} te demande en mariage'.toUpperCase(),
            style: V20Text.dm(size: 24)),
        const SizedBox(height: 12),
        GameCard(
            child: Text(
                '« On a traversé beaucoup de choses. Je veux qu’on se marie. Tu en penses quoi ? »',
                style: V20Text.poppins(size: 16, line: 24))),
        const SizedBox(height: 12),
        GameCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Accepter', style: V20Text.nm()),
            const Conseq21(ConsequenceKind.certain,
                'Préparation du mariage : choix de la cérémonie.'),
            const Conseq21(ConsequenceKind.certain,
                'Coût selon la cérémonie (50 000 ou 150 000 cauris).'),
            const SizedBox(height: 8),
            PrimaryButton(
                label: 'Accepter',
                onPressed: () => doAct(context, ref, 'proposal', 'oui',
                    () => context.go('/perso/mariage'))),
          ]),
        ),
        const SizedBox(height: 12),
        GameCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Refuser pour l’instant', style: V20Text.nm()),
            const Conseq21(
                ConsequenceKind.certain, 'Relation −${Reg21.refuseLoss}.'),
            const Conseq21(ConsequenceKind.uncertain,
                'Nouvelle demande possible dans ${Reg21.refuseCooldown} jours.'),
            const SizedBox(height: 8),
            PrimaryButton(
                label: 'Refuser',
                style: GameButtonStyle.secondary,
                onPressed: () => doAct(context, ref, 'proposal', 'non',
                    () => context.go('/perso/couple'))),
          ]),
        ),
      ] else ...[
        Text('Pas encore', style: V20Text.nm()),
        const SizedBox(height: 4),
        Text(
            'La demande arrive avec une relation officielle à ${Reg21.proposeAt}, après ${Reg21.proposeMinDays} jours de couple.',
            style: V20Text.bm),
        if (r != null) ...[
          const SizedBox(height: 8),
          Text(
              'Il manque ${(Reg21.proposeAt - _n(r['g'])).clamp(0, 100).toInt()} point(s) et ${[
                Reg21.proposeMinDays - (_n(s['day']) - _n(rom['since'])),
                _n(rom['cool']) - _n(s['day'])
              ].reduce((a, b) => a > b ? a : b).clamp(0, 999).toInt()} jour(s).',
              style: V20Text.bs(color: Tk.ink)),
        ],
      ],
      const SizedBox(height: 12),
      PrimaryButton(
          label: 'Retour au couple',
          style: GameButtonStyle.ghost,
          onPressed: () => context.go('/perso/couple')),
    ]);
  }
}

class PreparationScreen extends ConsumerWidget {
  const PreparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final rom = _m(s['rom']);
    final sel = Reg21.weddings[rom['wsel']]!;
    final cash = _n(s['cash']);
    return Frame21(children: [
      BackHeader(
          title: 'Préparer le mariage',
          onBack: () => context.go('/perso/couple')),
      const SizedBox(height: 12),
      if (rom['prop'] != 1)
        const GameHint(
            icon: 'info',
            text:
                'Aucune demande acceptée : la préparation s’ouvre après l’événement de demande.')
      else ...[
        const Lab21('Cérémonie · coûts proposés'),
        for (final e in Reg21.weddings.entries) ...[
          const SizedBox(height: 8),
          GameCard(
            selected: rom['wsel'] == e.key,
            onTap: () => ref.read(game21Provider.notifier).act('wsel', e.key),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value['n'] as String, style: V20Text.nm()),
                      Text(
                          'Relation +${e.value['g']}${_n(e.value['pop']) > 0 ? ' · popularité +${e.value['pop']}, Bakoma +2' : ''}',
                          style: V20Text.bs()),
                    ]),
              ),
              Text(fmt21(e.value['cost'] as num),
                  style: V20Text.nm(color: Tk.gold)),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        GlassCard(
          child: Column(children: [
            KeyVal('Choix', sel['n'] as String),
            KeyVal('Coût', '${fmt21(sel['cost'] as num)} cauris',
                color: Tk.gold),
            KeyVal('Cash après', fmt21(cash - (sel['cost'] as num))),
          ]),
        ),
        const SizedBox(height: 12),
        if (cash >= (sel['cost'] as num))
          PrimaryGlowButton(
              label: 'Continuer',
              onPressed: () => context.go('/perso/confirmation'))
        else
          const GameHint(
              icon: 'info',
              warn: true,
              text:
                  'Cash insuffisant. Choisis la cérémonie simple ou gagne des cauris d’abord.'),
      ],
    ]);
  }
}

class ConfirmationMariageScreen extends ConsumerWidget {
  const ConfirmationMariageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final rom = _m(s['rom']);
    final married = rom['married'] == 1;
    final w = Reg21.weddings[rom['wsel']]!;
    return Frame21(children: [
      BackHeader(
          title: 'Confirmation', onBack: () => context.go('/perso/couple')),
      const SizedBox(height: 12),
      if (married) ...[
        Text('VOUS ÊTES MARIÉ(E)S', style: V20Text.dm(size: 28)),
        const SizedBox(height: 8),
        KeyVal('Avec', cands21[rom['off']]?['n'] as String? ?? '—'),
        KeyVal('Jour du mariage', dateLabel21(rom['wed'] as num)),
        KeyVal('Relation', '${partner(s)?['g'] ?? 0}/100'),
        const SizedBox(height: 16),
        PrimaryGlowButton(
            label: 'Parler de la famille',
            onPressed: () => context.go('/famille')),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Retour au QG',
            style: GameButtonStyle.ghost,
            onPressed: () => context.go('/')),
      ] else if (rom['prop'] == 1) ...[
        Text('DIRE OUI ?', style: V20Text.dm(size: 28)),
        const SizedBox(height: 8),
        KeyVal('Avec', cands21[rom['off']]!['n'] as String),
        KeyVal('Cérémonie', w['n'] as String),
        Conseq21(
            ConsequenceKind.certain, '− ${fmt21(w['cost'] as num)} cauris'),
        const Conseq21(ConsequenceKind.certain,
            'Statut : marié(e)s. Les enfants deviennent possibles, sans être automatiques.'),
        const Conseq21(ConsequenceKind.certain,
            'La séparation reste possible et ne supprime pas l’histoire du couple.'),
        const SizedBox(height: 16),
        PrimaryGlowButton(
            label: 'Confirmer le mariage',
            onPressed: () =>
                doAct(context, ref, 'wed', null, null, 'Mariage célébré')),
      ] else ...[
        Text('Aucune demande acceptée', style: V20Text.nm()),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Retour au QG', onPressed: () => context.go('/')),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-10 Séparation, 21-10b Rupture subie
// ---------------------------------------------------------------------------------------------------------------------

class SeparationScreen extends ConsumerWidget {
  const SeparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final rom = _m(s['rom']), off = _off(s), sep = rom['sep'] as J?;
    final hist = _l(rom['hist']).reversed.take(4).toList();
    return Frame21(children: [
      BackHeader(
          title: 'Séparation',
          onBack: () => context.go(off == null ? '/perso' : '/perso/couple')),
      const SizedBox(height: 12),
      if (off != null) ...[
        Text('TE SÉPARER DE ${(cands21[off]!['n'] as String).toUpperCase()} ?',
            style: V20Text.dm(size: 24)),
        const SizedBox(height: 12),
        const Conseq21(ConsequenceKind.certain,
            'Fin de l’exclusivité : tu peux rencontrer d’autres personnes.'),
        const Conseq21(ConsequenceKind.certain,
            'Relation ramenée à 10 au plus ; pas de nouvelle approche pendant ${Reg21.exBlockDays} jours.'),
        const Conseq21(ConsequenceKind.certain,
            'Mariage : statut « séparé(e) ». Enfants : garde partagée, charges maintenues.'),
        const Conseq21(ConsequenceKind.certain,
            'L’historique du couple et de la famille est conservé.'),
        const SizedBox(height: 16),
        PrimaryButton(
            label: 'Confirmer la séparation',
            onPressed: () => doAct(context, ref, 'separate', null,
                () => context.go('/perso/separation'))),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Annuler',
            style: GameButtonStyle.ghost,
            onPressed: () => context.go('/perso/couple')),
      ] else ...[
        if (sep != null)
          GlassCard(
            accent: GlassAccent.magenta,
            halo: false,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DERNIÈRE SÉPARATION',
                  style: V20Text.lab(color: V20.accText)),
              Text(sep['why'] as String, style: V20Text.nm()),
              KeyVal('Avec', sep['who'] as String),
              KeyVal('Jour', '${sep['d']}'),
            ]),
          )
        else
          Text('Aucune séparation', style: V20Text.nm()),
        const SizedBox(height: 8),
        const GameHint(
            icon: 'info',
            text:
                'Une rupture décidée par ton/ta partenaire n’est jamais tirée au hasard : elle suit une relation tombée sous 20, après une alerte sous 30.'),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HISTOIRE CONSERVÉE', style: V20Text.lab()),
            for (final h in hist)
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${dateLabel21(_m(h)['d'] as num)} · ${_m(h)['t']}',
                      style: V20Text.bs(color: Tk.ink))),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryGlowButton(
            label: 'Rencontres', onPressed: () => context.go('/perso')),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-11 Famille, 21-12 Parent-enfant, 21-13 Événements, 21-14 Bilan familial
// ---------------------------------------------------------------------------------------------------------------------

class FamilleScreen extends ConsumerWidget {
  const FamilleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final fam = _m(s['fam']), rom = _m(s['rom']);
    final kids = _l(fam['kids']);
    final married = rom['married'] == 1;
    return Frame21(children: [
      BackHeader(
          title: 'Famille',
          step: '${kids.length} enfant(s)',
          onBack: () => context.go('/')),
      const SizedBox(height: 12),
      for (final k in kids) ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child: Row(children: [
            Portrait(_m(k)['n'].toString()[0], size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_m(k)['n']}', style: V20Text.nm()),
                    Text(
                        '${kidAge(s, _m(k))} an${kidAge(s, _m(k)) > 1 ? 's' : ''} · ${stageOf(kidAge(s, _m(k)))} · ${_m(k)['garde']}',
                        style: V20Text.bs()),
                    Gauge21('Lien', _n(_m(k)['l'])),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
      ],
      if (kids.isEmpty) ...[
        Text('Pas encore d’enfant', style: V20Text.nm()),
        Text(
            'Les enfants n’arrivent qu’après le mariage, et jamais automatiquement.',
            style: V20Text.bm),
        const SizedBox(height: 12),
      ],
      if (married && fam['projAsked'] != 1 && kids.isEmpty)
        GameCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('« Et si on parlait d’avoir un enfant ? »',
                style: V20Text.poppins(size: 16, line: 24)),
            const SizedBox(height: 8),
            const Text('Essayer d’avoir un enfant'),
            const Conseq21(ConsequenceKind.uncertain,
                'Arrivée possible en fin de journée, sans garantie.'),
            PrimaryButton(
                label: 'Essayer',
                compact: true,
                onPressed: () => doAct(context, ref, 'famProj', 'oui')),
            const SizedBox(height: 8),
            const Text('Pas maintenant'),
            const Conseq21(ConsequenceKind.certain,
                'Aucun enfant tant que vous n’en décidez pas.'),
            PrimaryButton(
                label: 'Pas maintenant',
                compact: true,
                style: GameButtonStyle.secondary,
                onPressed: () => doAct(context, ref, 'famProj', 'non')),
          ]),
        )
      else if (fam['proj'] == 1)
        const GameHint(
            icon: 'info',
            text:
                'Projet d’enfant en cours : une naissance peut être annoncée dans le bilan de fin de journée.')
      else if (!married && kids.isEmpty)
        const GameHint(
            icon: 'info',
            warn: true,
            text: 'Il faut être marié(e) pour envisager un enfant.'),
      if (kids.isNotEmpty) ...[
        const SizedBox(height: 12),
        PrimaryGlowButton(
            label: 'Passer du temps ensemble',
            sublabel: 'Interactions selon l’âge',
            onPressed: () => context.go('/famille/enfant')),
      ],
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('ÉTAPES D’ÂGE', style: V20Text.lab()),
            const GameTag('Proposé',
                style: GameTagStyle.outline, color: Color(0xFFD8C8FF))
          ]),
          for (final (a, n) in Reg21.stages)
            KeyVal(n, '$a an${a > 1 ? 's' : ''} et plus'),
          Text('L’enfant vieillit au passage de chaque année de jeu.',
              style: V20Text.bs()),
        ]),
      ),
    ]);
  }
}

class ParentEnfantScreen extends ConsumerWidget {
  const ParentEnfantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final kids = _l(_m(s['fam'])['kids']);
    return Frame21(children: [
      BackHeader(
          title: kids.isEmpty ? 'Enfant' : 'Avec ${_m(kids.first)['n']}',
          onBack: () => context.go('/famille')),
      const SizedBox(height: 12),
      if (kids.isEmpty)
        const GameHint(icon: 'info', text: 'Aucun enfant au foyer.'),
      for (var i = 0; i < kids.length; i++) ...[
        Builder(builder: (context) {
          final k = _m(kids[i]);
          final age = kidAge(s, k);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  child: Row(children: [
                    Portrait(k['n'].toString()[0], size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('${k['n']}', style: V20Text.nm()),
                          Text(
                              '$age an${age > 1 ? 's' : ''} · ${stageOf(age)} · ${k['garde']}',
                              style: V20Text.bs()),
                          Gauge21('Lien', _n(k['l']))
                        ])),
                  ]),
                ),
                for (final e in Reg21.kidActs.entries) ...[
                  const SizedBox(height: 8),
                  ActionRow(
                    title: e.value['n'] as String,
                    subtitle:
                        '${e.value['h']} h · −${e.value['e']} énergie · +${e.value['l']} lien',
                    note: age < (e.value['min'] as num)
                        ? 'À partir de ${e.value['min']} an${(e.value['min'] as num) > 1 ? 's' : ''}'
                        : null,
                    disabled: age < (e.value['min'] as num),
                    trailing: ActionRow.arrow(
                        disabled: age < (e.value['min'] as num)),
                    onTap: () => doAct(context, ref, 'kid', ['$i', e.key]),
                  ),
                ],
                const SizedBox(height: 12),
              ]);
        }),
      ],
      const Conseq21(ConsequenceKind.certain,
          'Chaque moment coûte du temps et de l’énergie : la carrière reste possible le même jour.'),
    ]);
  }
}

class FamEvenementScreen extends ConsumerWidget {
  const FamEvenementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final fam = _m(s['fam']);
    final id = fam['ev'] as String?;
    final e = id == null ? null : fev21[id];
    String csq(J x) {
      final p = <String>[];
      if (x['g'] != null) p.add('relation ${sg21(x['g'] as num)}');
      if (x['l'] != null) p.add('lien enfant ${sg21(x['l'] as num)}');
      if (x['cash'] != null) p.add('${sg21(x['cash'] as num)} cauris');
      if (x['e'] != null) p.add('énergie ${sg21(x['e'] as num)}');
      if (x['h'] != null) p.add('${x['h']} h');
      return p.join(' · ');
    }

    return Frame21(children: [
      BackHeader(title: 'Événements familiaux', onBack: () => context.go('/')),
      const SizedBox(height: 12),
      if (e == null) ...[
        Text('Aucun événement en attente', style: V20Text.nm()),
        Text(
            'Les événements familiaux arrivent au fil des jours, selon le couple, le mariage et les enfants.',
            style: V20Text.bm),
        if (fam['evDone'] != null) ...[
          const SizedBox(height: 8),
          GameHint(
              icon: 'info',
              text:
                  'Choix enregistré : ${_m(fam['evDone'])['t']} : ${_m(fam['evDone'])['ch']}. Il figurera dans le bilan de fin de journée.')
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'Retour au QG', onPressed: () => context.go('/')),
      ] else ...[
        Text('À DÉCIDER AUJOURD’HUI', style: V20Text.lab(color: V20.accText)),
        Text((e['t'] as String).toUpperCase(), style: V20Text.dm(size: 24)),
        const SizedBox(height: 8),
        GameCard(
            child: Text(e['q'] as String,
                style: V20Text.poppins(size: 16, line: 24))),
        for (final k in ['a', 'b']) ...[
          const SizedBox(height: 12),
          GameCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_m(e[k])['n'] as String, style: V20Text.nm()),
              Conseq21(ConsequenceKind.certain, csq(_m(e[k]))),
              const SizedBox(height: 8),
              PrimaryButton(
                  label: 'Choisir',
                  style: k == 'a'
                      ? GameButtonStyle.primary
                      : GameButtonStyle.secondary,
                  onPressed: () =>
                      doAct(context, ref, 'fev', k, () => context.go('/'))),
            ]),
          ),
        ],
      ],
    ]);
  }
}

class BilanFamilialScreen extends ConsumerWidget {
  const BilanFamilialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final b = s['bil'] as J?;
    final kids = _l(_m(s['fam'])['kids']).length;
    final charges = (_m(s['rom'])['off'] != null ? Reg21.coupleCost : 0) +
        kids * Reg21.kidCost;
    return Frame21(children: [
      BackHeader(title: 'Bilan familial', onBack: () => context.go('/bilan')),
      const SizedBox(height: 12),
      if (b == null) ...[
        Text('Pas encore de bilan', style: V20Text.nm()),
        Text('Il s’affiche après « Terminer la journée ».', style: V20Text.bm),
      ] else ...[
        Text('FIN DU JOUR ${b['day']}', style: V20Text.lab()),
        GlassCard(
          child: Column(children: [
            KeyVal(
                'Relation',
                b['rel'] == null
                    ? (b['rel0'] != null
                        ? 'Séparation : relation terminée'
                        : 'Aucune relation officielle')
                    : '${b['who']} : ${b['rel']}/100 (${sg21(_n(b['rel']) - _n(b['rel0'] ?? b['rel']))})'),
            KeyVal(
                'Enfants',
                _n(b['kids']) == 0
                    ? 'Aucun enfant'
                    : '${b['kids']} enfant${_n(b['kids']) > 1 ? 's' : ''}'),
            KeyVal('Charges du foyer', '${fmt21(charges)} / jour'),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ÉVÉNEMENTS DU FOYER', style: V20Text.lab()),
            if (_l(b['fam']).isEmpty)
              Text('Rien de particulier.', style: V20Text.bs()),
            for (final f in _l(b['fam']))
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('$f', style: V20Text.bs(color: Tk.ink))),
          ]),
        ),
      ],
      const SizedBox(height: 16),
      PrimaryGlowButton(
          label: 'Commencer la journée', onPressed: () => context.go('/')),
    ]);
  }
}

/// KPI rapide réutilisable : popularité d'une relation.
Widget relationKpi(J s) => StatKpi(
    label: 'Relation', value: partner(s) == null ? '—' : '${partner(s)!['g']}');
