import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/asset_illustration.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/character_view.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'labels_screens.dart';
import 'shell21.dart';
import 'widgets21.dart';

/// Scène (21-C1 à 21-C3) et Business (21-E1 à 21-E5, 21-L1).

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;

// ---------------------------------------------------------------------------------------------------------------------
// 21-C2 Scène
// ---------------------------------------------------------------------------------------------------------------------

class SceneScreen21 extends ConsumerWidget {
  const SceneScreen21({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final rank = rankOf(s);
    final moto = _m(s['own'])['moto'] != null ? 5 : 0;
    final car = _m(s['own'])['voiture'] != null ? 5 : 0;
    final day = _n(s['day']);
    final cWait = (Reg21.concertEvery - (day - _n(s['lastConcert'])))
        .clamp(0, 999)
        .toInt();
    final tWait =
        (Reg21.tourEvery - (day - _n(s['lastTour']))).clamp(0, 999).toInt();
    final aud = tourAudience(s);
    final tk = tickets21(s);
    final mgrTier = managerTier21(s);
    final hasManager = mgrTier != null;
    final fee = (Reg21.tour['fee'] as num) +
        jsRound((Reg21.tour['feeGeo'] as num) *
            (_n(_m(s['geo'])['portambre']) + _n(_m(s['geo'])['selene'])));
    final cc = s['cc'] as J?;

    Widget row(String title, String sub,
            {Widget? tag,
            String? note,
            VoidCallback? onTap,
            bool off = false}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionRow(
              title: title,
              subtitle: sub,
              note: note,
              disabled: off,
              trailing: tag ?? ActionRow.arrow(disabled: off),
              onTap: onTap),
        );
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('SCÈNE', style: V20Text.dm()),
        GameTag('${s['shows']} date(s)')
      ]),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Fans', value: fmt21(s['fans'] as num)),
        StatKpi(label: 'Popularité', value: '${s['pop']}')
      ]),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'Battle : jouable depuis le défi de K-Zer (21.B1). Concert et tournée : billetterie et résultats en 21.C3. Open mic : une fois par jour, effet réduit si tu y retournes souvent.'),
      const SizedBox(height: 12),
      if (s['btq'] != null)
        row("Battle contre K-Zer d'Mabaya", 'Défi accepté · 1 h · −15 énergie · 3 rounds',
            tag: const GameTag('En attente', style: GameTagStyle.ok), onTap: () => context.go('/scene/battle')),
      if (_n(s['omDay']) == day)
        row('Open mic de Ndolo', 'Déjà joué aujourd’hui · reviens demain', off: true, tag: const GameTag('Demain', style: GameTagStyle.outline))
      else
        row('Open mic de Ndolo',
            '1 h · −${15 - moto} énergie · +${hasManager ? '${fmt21(3000 - jsRound(3000 * (mgrTier['rate'] as num)))} net (manager)' : '3 000'} · jusqu’à +${jsRound(Reg21.omFans * openMicEffect(s) / 100)} fans si énergie ≥ 40 · effet actuel ${openMicEffect(s)} % (baisse si tu y retournes souvent)',
            tag: const GameTag('Ouvert', style: GameTagStyle.ok),
            onTap: () => doAct(context, ref, 'openmic', null, () => context.go('/scene/resultat'))),
      row('Rivalités', 'Défie d’autres artistes en battle · 1 h · −15 énergie',
          onTap: () => context.go('/scene/rivalites')),
      if (rank < 3)
        row('Concert au Parvis', 'Débloqué au rang N3',
            off: true, tag: const GameTag('N3', style: GameTagStyle.outline))
      else if (cWait > 0)
        row('Concert au Parvis',
            'Une date par semaine : prochaine possible dans $cWait j',
            off: true, tag: const GameTag('Délai', style: GameTagStyle.outline))
      else
        row('Concert au Parvis (${Reg21.capacity} places)',
            '4 h · −${35 - moto - car} énergie · billetterie estimée : $tk billets × ${Reg21.ticketPrice} = ${fmt21(tk * Reg21.ticketPrice)} · Bakoma +4',
            tag: const GameTag('Prêt', style: GameTagStyle.ok),
            onTap: () => doAct(context, ref, 'concert', null,
                () => context.go('/scene/resultat'))),
      const Lab21('Tournées'),
      if (rank < 3)
        row('Tournée régionale (Port-Ambre, Sélène)', 'Débloquée au rang N3',
            off: true, tag: const GameTag('N3', style: GameTagStyle.outline))
      else if (aud < Reg21.tourAudience)
        row('Tournée régionale (Port-Ambre, Sélène)',
            'Public régional insuffisant : ${aud.toStringAsFixed(1)} / ${Reg21.tourAudience} de notoriété moyenne à Port-Ambre et Sélène. La promo radio y fait monter ta notoriété.',
            off: true,
            tag: const GameTag('Public', style: GameTagStyle.outline))
      else if (tWait > 0)
        row('Tournée régionale (Port-Ambre, Sélène)',
            'Une tournée toutes les 4 semaines : encore $tWait j',
            off: true, tag: const GameTag('Délai', style: GameTagStyle.outline))
      else
        row('Tournée régionale (Port-Ambre, Sélène)',
            '10 h · −${(Reg21.tour['e'] as num) - moto - car} énergie · frais ${fmt21(Reg21.tour['cost'] as num)} · cachets ${fmt21(fee)} · +${Reg21.tour['fans']} fans',
            tag: const GameTag('Prête', style: GameTagStyle.ok),
            onTap: () => doAct(context, ref, 'tour', null,
                () => context.go('/scene/resultat'))),
      row(
          'Date à Tamarel Open Air',
          rank < Reg21.intlRank
              ? 'Débloquée au rang N5 · festival de 60 000 places (18.3)'
              : 'Date internationale : à venir',
          off: true,
          tag:
              const GameTag('N${Reg21.intlRank}', style: GameTagStyle.outline)),
      const SizedBox(height: 4),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DERNIERS RÉSULTATS', style: V20Text.lab()),
          const SizedBox(height: 4),
          if (cc == null)
            Text('Aucune date aujourd’hui.', style: V20Text.bs())
          else ...[
            Text(
                cc['tour'] == 1
                    ? 'Tournée régionale'
                    : 'Concert au Parvis · note ${cc['g']}',
                style: V20Text.nm()),
            Text(
                '${fmt21(cc['fans'] as num)} fans · ${fmt21(cc['cash'] as num)} cauris nets · réputation +${cc['rep']}',
                style: V20Text.bs()),
            if (_n(cc['managerCut']) > 0)
              Text(
                  'Retenue manager : −${fmt21(_n(cc['managerCut']))} cauris sur ${fmt21(_n(cc['gross']))}',
                  style: V20Text.bs()),
          ],
        ]),
      ),
      const SizedBox(height: 8),
      ActionRow(
          title: 'Voir la popularité par ville',
          subtitle: 'Effets des dates sur chaque territoire',
          trailing: ActionRow.arrow(),
          onTap: () => context.go('/scene/popularite')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-C3 Résultat de la date
// ---------------------------------------------------------------------------------------------------------------------

class ConcertResultScreen extends ConsumerWidget {
  const ConcertResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cc = s['cc'] as J?;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Résultat de la date', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      if (cc == null) ...[
        if (s['om'] != null) ...[
          Text(_n(s['om']) == 1 ? 'Open mic réussi' : 'Open mic difficile',
              style: V20Text.nm()),
          Text(
              _n(s['om']) == 1
                  ? '+${jsRound(Reg21.omFans * _n(s['omK'] ?? 1))} fans · +${fmt21(_n(s['omCash']))} cauris nets · réputation +${_n(s['omK'] ?? 1) >= 0.7 ? 6 : 3} · XP +${jsRound(60 * _n(s['omK'] ?? 1))}'
                  : '+12 fans · XP +10',
              style: V20Text.bm),
          Text('Effet de ce passage : ${jsRound(_n(s['omK'] ?? 1) * 100)} % (baisse si tu y retournes souvent)', style: V20Text.bs()),
          if (_n(s['omCut']) > 0)
            Text('Retenue manager : −${fmt21(_n(s['omCut']))} cauris',
                style: V20Text.bs()),
        ] else ...[
          Text('Aucune date jouée', style: V20Text.nm()),
          Text('Lance un concert ou une tournée depuis la Scène.',
              style: V20Text.bm),
        ],
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cc['tour'] == 1 ? 'TOURNÉE RÉGIONALE' : 'LE PARVIS · NDOLO',
                style: V20Text.lab(color: V20.accText)),
            Text(cc['tour'] == 1 ? 'Tournée' : 'Note ${cc['g']}',
                style: V20Text.dm(size: 30)),
          ]),
        ),
        const SizedBox(height: 12),
        if (cc['tour'] != 1)
          GlassCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BILLETTERIE', style: V20Text.lab()),
              KeyVal('Billets vendus', '${cc['tk']} / ${Reg21.capacity}'),
              const SizedBox(height: 4),
              MeterBar(
                  value:
                      (_n(cc['tk']) / Reg21.capacity).clamp(0, 1).toDouble()),
              const SizedBox(height: 4),
              Text(
                  '${Reg21.ticketPrice} cauris par billet ; note B : 15 % de recette en moins.',
                  style: V20Text.bs()),
            ]),
          ),
        const SizedBox(height: 12),
        KpiRow(children: [
          StatKpi(label: 'Gain net', value: sg21(_n(cc['cash']))),
          StatKpi(label: 'Fans', value: sg21(_n(cc['fans']))),
          StatKpi(label: 'Réputation', value: '+${cc['rep']}')
        ]),
        const SizedBox(height: 8),
        KeyVal('Cash', fmt21(s['cash'] as num), color: Tk.gold),
      ],
      const SizedBox(height: 16),
      PrimaryGlowButton(
          label: 'Retour à la scène', onPressed: () => context.go('/scene')),
      const SizedBox(height: 8),
      PrimaryButton(
          label: 'Retour au QG',
          style: GameButtonStyle.ghost,
          onPressed: () => context.go('/')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-C1 Popularité par ville et par continent
// ---------------------------------------------------------------------------------------------------------------------

class PopulariteScreen extends ConsumerWidget {
  const PopulariteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Popularité', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Popularité générale', value: '${s['pop']}', big: true),
        StatKpi(label: 'Fans', value: fmt21(s['fans'] as num), big: true)
      ]),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PAR VILLE · NOTORIÉTÉ 0-100', style: V20Text.lab()),
          for (final c in Reg21.cities.entries)
            Gauge21(c.value, geoOf(s, c.key), color: Tk.cy),
        ]),
      ),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PAR CONTINENT · MOYENNE DES VILLES', style: V20Text.lab()),
          for (final c in Reg21.conts.entries)
            Gauge21(c.value['n'] as String, contOf(s, c.key), color: Tk.violet),
        ]),
      ),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'Sorties : surtout Bakoma ; promo radio : Port-Ambre et Sélène ; tournée régionale : +8 dans ces deux villes ; dates internationales : rang N5. Les continents regroupent des villes fictives.'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-E1 Business
// ---------------------------------------------------------------------------------------------------------------------

class BusinessScreen21 extends ConsumerWidget {
  const BusinessScreen21({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final rank = rankOf(s);
    final moto = _m(s['own'])['moto'] != null ? 5 : 0;
    final cha = _n(_m(s['sk'])['cha']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('BUSINESS', style: V20Text.dm()),
        GameTag('Patrimoine ${_m(s['own']).length}')
      ]),
      const SizedBox(height: 8),
      const GameHint(
          icon: 'info',
          text:
              'Matériel et formation : écrans existants 09.1 et 09.3. Nouveau ici : petits boulots, entreprises, patrimoine, merch. Ces activités rapportent des cauris, pas de fans ni de rang.'),
      const Lab21('Formation'),
      ActionRow(
        title: "Atelier d'écriture",
        subtitle: '2 h · −20 énergie · Écriture +5 · mission 3',
        trailing: Text('6 000', style: V20Text.nm(color: Tk.gold)),
        onTap: () => doAct(context, ref, 'atelier', null, null,
            'Écriture +5 · Atelier terminé'),
      ),
      const Lab21('Petits boulots · dès le début'),
      for (final e in Reg21.jobs.entries) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionRow(
            title: e.value['n'] as String,
            subtitle:
                '${e.value['h']} h · −${(e.value['e'] as num) - moto} énergie · ${e.value['need']}',
            note: e.value['cha'] != null && cha < (e.value['cha'] as num)
                ? 'Charisme ${e.value['cha']} requis (tu as ${cha.toInt()})'
                : null,
            disabled: e.value['cha'] != null && cha < (e.value['cha'] as num),
            trailing: Text('+${fmt21(e.value['cash'] as num)}',
                style: V20Text.nm(color: Tk.gold)),
            onTap: () => doAct(context, ref, 'job', e.key,
                () => context.go('/business/boulot')),
          ),
        ),
      ],
      const Lab21('Entreprises · selon le rang'),
      for (final e in Reg21.biz.entries) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionRow(
            title: e.value['n'] as String,
            subtitle: _m(s['biz'])[e.key] != null
                ? 'En activité · cumul ${fmt21(_n(_m(_m(s['biz'])[e.key])['tot']))} cauris'
                : '${fmt21(e.value['cost'] as num)} cauris · revenu estimé ${fmt21(e.value['lo'] as num)} à ${fmt21(e.value['hi'] as num)} / jour',
            note: _m(s['biz'])[e.key] == null && rank < (e.value['rank'] as num)
                ? 'Débloqué au rang N${e.value['rank']}'
                : null,
            disabled:
                _m(s['biz'])[e.key] == null && rank < (e.value['rank'] as num),
            trailing: _m(s['biz'])[e.key] != null
                ? const GameTag('Actif', style: GameTagStyle.ok)
                : ActionRow.arrow(),
            onTap: () => context.go('/business/entreprises'),
          ),
        ),
      ],
      const Lab21('Patrimoine et merchandising'),
      ActionRow(
          title: 'Patrimoine',
          subtitle: '${_m(s['own']).length} bien(s) · effets',
          trailing: ActionRow.arrow(),
          onTap: () => context.go('/business/patrimoine')),
      const SizedBox(height: 8),
      ActionRow(
          title: 'Merchandising et label',
          subtitle: _n(s['fans']) >= 1000
              ? 'T-shirts, collection capsule, contrat'
              : 'Débloqué avec la carrière',
          trailing: ActionRow.arrow(),
          onTap: () => context.go('/business/labels')),
      const SizedBox(height: 8),
      ActionRow(
          title: 'Équipe et manager',
          subtitle: managerTier21(s) != null
              ? '${managerTier21(s)!['n']} actif · ${((managerTier21(s)!['rate'] as num) * 100).round()} % des cachets'
              : 'Aucun manager · optionnel',
          trailing: ActionRow.arrow(),
          onTap: () => context.go('/business/manager')),
      const SizedBox(height: 8),
      ActionRow(
          title: 'Justice et détention',
          subtitle: s['jail'] != null
              ? 'Détention · ${jailDaysLeft(s)} jour(s) restant(s)'
              : s['cas'] != null ? 'Affaire en cours' : 'Casier, avocat, procès',
          trailing: ActionRow.arrow(),
          onTap: () => context.go('/business/justice')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-E2 Résultat d'un petit boulot
// ---------------------------------------------------------------------------------------------------------------------

class BoulotScreen extends ConsumerWidget {
  const BoulotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final j = s['lastJob'] as J?;
    return Frame21(children: [
      BackHeader(
          title: 'Résultat du boulot', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      if (j == null) ...[
        Text('Aucun boulot fait aujourd’hui', style: V20Text.nm()),
        Text('Choisis un boulot dans Business.', style: V20Text.bm),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BOULOT TERMINÉ', style: V20Text.lab(color: V20.accText)),
            Text(Reg21.jobs[j['id']]!['n'] as String, style: V20Text.nm()),
            const SizedBox(height: 8),
            KeyVal('Gain', '+${fmt21(j['cash'] as num)}', color: Tk.gold),
            KeyVal('Énergie', '−${j['e']}'),
            KeyVal('Durée', '${j['h']} h'),
            KeyVal('Cash', fmt21(s['cash'] as num)),
            const Conseq21(ConsequenceKind.certain,
                'Gain fixe, versé tout de suite. Aucun effet sur les fans ni sur le rang.'),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RESTE DE LA JOURNÉE', style: V20Text.lab()),
          KeyVal('Heures restantes', '${hoursLeft(s)} h'),
          KeyVal('Énergie', energyLabel(s)),
        ]),
      ),
      const SizedBox(height: 16),
      PrimaryGlowButton(
          label: 'Retour au QG', onPressed: () => context.go('/')),
      const SizedBox(height: 8),
      PrimaryButton(
          label: 'Autre activité',
          style: GameButtonStyle.ghost,
          onPressed: () => context.go('/business')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-E3 Entreprises
// ---------------------------------------------------------------------------------------------------------------------

class EntreprisesScreen extends ConsumerWidget {
  const EntreprisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final rank = rankOf(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Entreprises', onBack: () => context.go('/business')),
      const SizedBox(height: 8),
      KeyVal('Cash', fmt21(s['cash'] as num), color: Tk.gold),
      for (final e in Reg21.biz.entries) ...[
        const SizedBox(height: 12),
        Builder(builder: (context) {
          final owned = _m(s['biz'])[e.key] != null;
          final locked = !owned && rank < (e.value['rank'] as num);
          return GameCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                    child: Text(e.value['n'] as String, style: V20Text.nm())),
                owned
                    ? const GameTag('En activité', style: GameTagStyle.ok)
                    : (locked
                        ? GameTag('Verrouillé · N${e.value['rank']}',
                            style: GameTagStyle.outline)
                        : const GameTag('Accessible')),
              ]),
              KeyVal(
                  'Investissement', '${fmt21(e.value['cost'] as num)} cauris'),
              Conseq21(ConsequenceKind.estimated,
                  'Revenu estimé ${fmt21(e.value['lo'] as num)} à ${fmt21(e.value['hi'] as num)} cauris par jour, selon la journée : jamais garanti.'),
              if (owned)
                KeyVal('Revenus cumulés',
                    '${fmt21(_n(_m(_m(s['biz'])[e.key])['tot']))} cauris'),
              if (locked)
                Text(
                    'Pourquoi verrouillé : rang N${e.value['rank']} requis (tu es N$rank).',
                    style: V20Text.poppins(
                        size: 11,
                        line: 14,
                        weight: FontWeight.w600,
                        color: V20.hintGoldText)),
              if (!owned) ...[
                const SizedBox(height: 8),
                PrimaryButton(
                    label: 'Investir',
                    sublabel: '−${fmt21(e.value['cost'] as num)} cauris',
                    compact: true,
                    style: locked
                        ? GameButtonStyle.disabled
                        : GameButtonStyle.secondary,
                    onPressed: () => doAct(context, ref, 'bizBuy', e.key, null,
                        '${e.value['n']} : investissement fait')),
              ],
            ]),
          );
        }),
      ],
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'Revenus versés à la fin de chaque journée et listés dans le bilan.'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-E4 Patrimoine, 21-E5 Confirmation d'achat
// ---------------------------------------------------------------------------------------------------------------------

class PatrimoineScreen extends ConsumerWidget {
  const PatrimoineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final total = _m(s['own'])
            .keys
            .fold<num>(0, (a, k) => a + (Reg21.assets[k]!['cost'] as num)) +
        _m(s['biz'])
            .keys
            .fold<num>(0, (a, k) => a + (Reg21.biz[k]!['cost'] as num));
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Patrimoine', onBack: () => context.go('/business')),
      const SizedBox(height: 8),
      KeyVal('Valeur du patrimoine', '${fmt21(total)} cauris', color: Tk.gold),
      const SizedBox(height: 8),
      const GameHint(
          icon: 'info',
          text:
              'Chaque bien a un effet propre sur le jeu : énergie, coût d’une activité, qualité ou revenu. Aucun n’est décoratif.'),
      for (final e in Reg21.assets.entries) ...[
        const SizedBox(height: 12),
        GameCard(
          selected: _m(s['own'])[e.key] != null,
          onTap: _m(s['own'])[e.key] != null
              ? null
              : () async {
                  await ref.read(game21Provider.notifier).act('ask', e.key);
                  if (context.mounted) context.go('/business/achat');
                },
          child: Row(children: [
            AssetIllustration(e.key, size: 56),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(e.value['n'] as String, style: V20Text.nm()),
                  Text(e.value['eff'] as String, style: V20Text.bs())
                ])),
            _m(s['own'])[e.key] != null
                ? const GameTag('Possédé', style: GameTagStyle.ok)
                : Text(fmt21(e.value['cost'] as num),
                    style: V20Text.nm(color: Tk.gold)),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      const Conseq21(ConsequenceKind.certain,
          'Achat définitif. Appartement : 2 000 cauris/jour d’entretien ; maison : 3 500. Terrain et bateau : loyers journaliers estimés.'),
    ]);
  }
}

class AchatScreen extends ConsumerWidget {
  const AchatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final id = _m(s['ui'])['buy'] as String?;
    final a = id == null ? null : Reg21.assets[id];
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Confirmation d’achat',
          onBack: () => context.go('/business/patrimoine')),
      const SizedBox(height: 12),
      if (a == null)
        Text('Aucun bien sélectionné', style: V20Text.nm())
      else ...[
        Text('ACHETER ${(a['n'] as String).toUpperCase()} ?',
            style: V20Text.dm(size: 26)),
        const SizedBox(height: 12),
        Conseq21(ConsequenceKind.certain, a['eff'] as String),
        const SizedBox(height: 8),
        GlassCard(
          child: Column(children: [
            KeyVal('Prix', '${fmt21(a['cost'] as num)} cauris', color: Tk.gold),
            KeyVal('Cash après achat',
                '${fmt21(_n(s['cash']) - (a['cost'] as num))} cauris'),
          ]),
        ),
        const SizedBox(height: 16),
        if (_n(s['cash']) >= (a['cost'] as num))
          PrimaryGlowButton(
              label: 'Acheter',
              sublabel: 'Achat définitif',
              onPressed: () => doAct(context, ref, 'assetBuy', null,
                  () => context.go('/business/patrimoine'), '${a['n']} acquis'))
        else
          const GameHint(icon: 'info', warn: true, text: 'Cash insuffisant'),
      ],
      const SizedBox(height: 8),
      PrimaryButton(
          label: 'Annuler',
          style: GameButtonStyle.ghost,
          onPressed: () => context.go('/business/patrimoine')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-L1 Merchandising et label
// ---------------------------------------------------------------------------------------------------------------------

class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final rep = _n(s['rep']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Merchandising', step: 'D-G06', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      ActionRow(title: 'Les 10 labels', subtitle: 'Logos, sièges, contrats types (18.1)', trailing: ActionRow.arrow(), onTap: () => context.go('/business/labels/tous')),
      const SizedBox(height: 12),
      for (final e in Reg21.merch.entries) ...[
        Builder(builder: (context) {
          final m = e.value;
          final running = s['merch'] != null && _m(s['merch'])['id'] == e.key;
          final done = _m(s['merchDone'])[e.key];
          final ok = _n(s['fans']) >= (m['fans'] as num) &&
              (m['singles'] == null ||
                  (s['disco'] as List).length >= (m['singles'] as num)) &&
              (m['rank'] == null || rankOf(s) >= (m['rank'] as num));
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GameCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child:
                                  Text(m['n'] as String, style: V20Text.nm())),
                          running
                              ? const GameTag('En vente',
                                  style: GameTagStyle.ok)
                              : (done != null
                                  ? const GameTag('Écoulé')
                                  : (ok
                                      ? const GameTag('Accessible')
                                      : const GameTag('Verrouillé',
                                          style: GameTagStyle.outline))),
                        ]),
                    Text(
                        'Condition : ${m['cl']} · stock ${fmt21(m['cost'] as num)} cauris · ${m['days']} jours',
                        style: V20Text.bs()),
                    Conseq21(ConsequenceKind.estimated,
                        'Ventes estimées : ${m['perFan'].toString().replaceAll('.', ',')} cauris par fan et par jour'),
                    if (running) ...[
                      KeyVal('Jours restants', '${_m(s['merch'])['left']}'),
                      KeyVal(
                          'Ventes cumulées', fmt21(_n(_m(s['merch'])['tot'])))
                    ],
                    if (done != null) KeyVal('Total vendu', fmt21(_n(done))),
                    if (!running) ...[
                      const SizedBox(height: 8),
                      PrimaryButton(
                          label: 'Lancer',
                          sublabel: '−${fmt21(m['cost'] as num)} cauris',
                          compact: true,
                          style: ok && s['merch'] == null
                              ? GameButtonStyle.secondary
                              : GameButtonStyle.disabled,
                          onPressed: () => doAct(context, ref, 'merch', e.key,
                              null, '${m['n']} lancé')),
                    ],
                  ]),
            ),
          );
        }),
      ],
      const Lab21('Labels'),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Row(children: [
              const LabelLogo21('BSR', size: 40),
              const SizedBox(width: 10),
              Flexible(
                  child: Text('Bakoma Sound Records', style: V20Text.nm())),
            ])),
            s['signed'] == 1
                ? const GameTag('Signé', style: GameTagStyle.ok)
                : (rep >= Reg21.labelRep
                    ? const GameTag('Offre')
                    : const GameTag('Rép. ${Reg21.labelRep}',
                        style: GameTagStyle.outline)),
          ]),
          Text(
              'Avance ${fmt21(Reg21.labelAdvance)} · 35 % sur les écoutes · 6 mois · 2 sons par trimestre (08.2)',
              style: V20Text.bs()),
          const SizedBox(height: 8),
          if (s['signed'] != 1)
            PrimaryButton(
              label: 'Signer le contrat',
              sublabel: '+${fmt21(Reg21.labelAdvance)} cauris d’avance',
              compact: true,
              style: rep >= Reg21.labelRep
                  ? GameButtonStyle.secondary
                  : GameButtonStyle.disabled,
              onPressed: () =>
                  doAct(context, ref, 'sign', null, null, 'Contrat signé'),
            ),
          if (rep < Reg21.labelRep)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    'Encore ${(Reg21.labelRep - rep).toInt()} points de réputation.',
                    style: V20Text.poppins(
                        size: 11,
                        line: 14,
                        weight: FontWeight.w600,
                        color: V20.hintGoldText))),
        ]),
      ),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text('Créer ton label', style: V20Text.nm())),
            const GameTag('Verrouillé', style: GameTagStyle.outline)
          ]),
          KeyVal('Réputation ${Reg21.ownLabelRep}',
              rep >= Reg21.ownLabelRep ? '✓' : '—'),
          KeyVal('Capital ${fmt21(Reg21.ownLabelCash)} cauris',
              _n(s['cash']) >= Reg21.ownLabelCash ? '✓' : '—'),
          const KeyVal('Manager M3 ou plus', 'non modélisé ici', bold: false),
          Text('Validé (D-05), seuils provisoires.', style: V20Text.bs()),
        ]),
      ),
    ]);
  }
}

/// Port du système de management actuellement implémenté dans le moteur v20.
class Manager21Screen extends ConsumerWidget {
  const Manager21Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final tierKey = s['mgr'] == 'maya' ? 'm1' : s['mgr'] as String?;
    final tier = Reg21.managerTiers[tierKey ?? 'm1']!;
    final active = tierKey != null;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Mon manager', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      GameCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(
            width: 96,
            height: 120,
            child: CharacterView(who: 'nadia', mood: 'poised', crop: 'bust')),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((tier['n'] as String).toUpperCase(), style: V20Text.lab(color: V20.accText)),
          Text('Niveau ${(tierKey ?? 'm1').toUpperCase()}', style: V20Text.nm()),
          Text('Réseau local · conseils simples · calendrier de base',
              style: V20Text.bs()),
        ])),
      ])),
      const SizedBox(height: 12),
      GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CONTRAT', style: V20Text.lab()),
        KeyVal('Commission', '${((tier['rate'] as num) * 100).round()} % des cachets'),
        KeyVal('Fixe hebdomadaire', tier['fee'] == 0 ? 'Aucun fixe' : '${fmt21(tier['fee'] as num)} cauris'),
        KeyVal('Commissions versées', '${fmt21(_n(s['managerPaid']))} cauris'),
        const SizedBox(height: 6),
        Text(
            'Le forfait est prélevé tous les 7 jours. La commission s’applique aux cachets de scène. Les revenus des écoutes et du merchandising restent intacts.',
            style: V20Text.bs()),
      ])),
      const SizedBox(height: 12),
      for (final tier in Reg21.managerTiers.entries) ...[
        const SizedBox(height: 8),
        ActionRow(
          title: '${tier.key.toUpperCase()} · ${tier.value['n']}',
          subtitle: '${((tier.value['rate'] as num) * 100).round()} % des cachets · ${tier.value['fee'] == 0 ? 'sans fixe' : '${fmt21(tier.value['fee'] as num)}/semaine'} · réputation ${tier.value['rep']} · ${tier.value['xp']} XP requis',
          trailing: tierKey == tier.key ? const GameTag('Actif', style: GameTagStyle.ok) : ActionRow.arrow(),
          disabled: _n(s['rep']) < (tier.value['rep'] as num) || _n(s['xp']) < (tier.value['xp'] as num),
          onTap: () => doAct(context, ref, 'hireManager', tier.key, null, 'Contrat signé avec ${tier.value['n']}'),
        ),
      ],
      if (active) PrimaryButton(label: 'Mettre fin au contrat', style: GameButtonStyle.secondary, onPressed: () => doAct(context, ref, 'mgr', null, null, 'Contrat terminé')),
      const GameHint(icon: 'info', text: 'Barèmes et conditions provisoires issus des planches managers v20. Les bonus de développement commercial des planches ne sont pas chiffrés dans le moteur.'),
    ]);
  }
}

class Justice21Screen extends ConsumerWidget {
  const Justice21Screen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cas = s['cas'] as J?;
    final mature = _n(s['mature']) != 0;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Justice et détention', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      GameHint(icon: 'info', text: s['jail'] != null
          ? "Détention : ${jailDaysLeft(s)} jour(s). Seuls l'écriture, le sport, le procès et la fin de journée sont accessibles."
          : cas != null ? 'Affaire en cours : ${cas['n']} · procès au jour ${cas['trial']}.'
          : mature ? 'Chaleur ${s['heat']} / 100. Les risques et les peines sont affichés avant chaque action.'
          : 'Contenu mature (16+) désactivé : active-le dans le profil pour débloquer cet écran.'),
      if (s['jail'] != null) ...[
        ActionRow(title: 'Écrire en cellule', subtitle: 'Écriture +2 · une fois par jour', trailing: ActionRow.arrow(), onTap: () => doAct(context, ref, 'jw', null, null, 'Textes écrits')),
        ActionRow(title: 'Faire du sport', subtitle: 'Charisme +1, énergie +10 · une fois par jour', trailing: ActionRow.arrow(), onTap: () => doAct(context, ref, 'js', null, null, 'Séance faite')),
      ],
      if (cas != null) ...[
        if (cas['stage'] == 'garde') ...[
          ActionRow(title: 'Payer la caution', subtitle: "${fmt21(_n(cas['bail']))} cauris · libre jusqu'au procès", trailing: ActionRow.arrow(), disabled: _n(s['cash']) < _n(cas['bail']), onTap: () => doAct(context, ref, 'bail', null, null, 'Caution payée')),
          ActionRow(title: 'Rester en détention', subtitle: "Détention provisoire jusqu'au procès", trailing: ActionRow.arrow(), onTap: () => doAct(context, ref, 'detention', null, null, 'Détention provisoire')),
        ],
        for (final lw in Reg21.lawyers.entries)
          ActionRow(title: lw.value['n'] as String, subtitle: "${lw.value['role']} · ${lw.value['cost'] == 0 ? 'gratuit' : '${fmt21(lw.value['cost'] as num)} cauris'}", trailing: cas['lawyer'] == lw.key ? const GameTag('Choisi', style: GameTagStyle.ok) : ActionRow.arrow(), disabled: _n(s['cash']) < (lw.value['cost'] as num), onTap: () => doAct(context, ref, 'lawyer', lw.key, null, 'Avocat choisi')),
        if (cas['stage'] != 'garde') ...[
          ActionRow(title: 'Plaider non coupable', subtitle: _n(s['day']) >= _n(cas['trial']) ? 'Le tribunal est prêt' : 'Procès au jour ${cas['trial']}', trailing: ActionRow.arrow(), disabled: _n(s['day']) < _n(cas['trial']), onTap: () => doAct(context, ref, 'trial', 'nc', null, 'Procès jugé')),
          ActionRow(title: 'Plaider coupable', subtitle: "Peine réduite d'un quart", trailing: ActionRow.arrow(), disabled: _n(s['day']) < _n(cas['trial']), onTap: () => doAct(context, ref, 'trial', 'coupable', null, 'Procès jugé')),
        ],
      ],
      if (s['jail'] == null && cas == null) ...[
        for (final job in Reg21.crimes.entries)
          ActionRow(title: job.value['n'] as String, subtitle: '${job.value['h']} h · −${job.value['e']} énergie · risque ${math.min(85, (job.value['risk'] as num) + jsRound(_n(s['heat']) / 2))} % · ${fmt21(job.value['lo'] as num)} à ${fmt21(job.value['hi'] as num)} cauris', trailing: ActionRow.arrow(), disabled: !mature, onTap: () => doAct(context, ref, 'crime', job.key, null, 'Action terminée')),
      ],
      if (s['verdict'] != null) GameHint(icon: 'info', text: 'Dernier verdict : ${(s['verdict'] as J)['txt']}'),
    ]);
  }
}

/// Battle 21-B1 : 3 rounds, la bonne réplique se lit dans l'attaque de l'adversaire. Les trois réponses partent d'un coup à `battle`
/// (ou `rivalBattle`) ; ensuite le joueur touche « Voir le résultat » : aucune navigation automatique.
class Battle21Screen extends ConsumerStatefulWidget {
  const Battle21Screen({super.key, this.target = 'kzer'});
  final String target;
  @override
  ConsumerState<Battle21Screen> createState() => _Battle21ScreenState();
}

class _Battle21ScreenState extends ConsumerState<Battle21Screen> {
  List<(String, String, String)> get _rounds => Reg21.rivalRounds[widget.target] ?? Reg21.rivalRounds['kzer']!;
  static const _answers = ['Agressif', 'Malin', 'Cool'];
  final List<bool> _won = [];
  bool _busy = false, _done = false;

  int get _score => _won.where((w) => w).length;

  Future<void> _answer(String answer) async {
    if (_busy || _done || _won.length >= 3) return;
    final win = answer == _rounds[_won.length].$3;
    setState(() => _won.add(win));
    if (_won.length < 3) return;
    setState(() => _busy = true);
    final error = widget.target == 'kzer'
        ? await ref.read(game21Provider.notifier).act('battle', _score)
        : await ref.read(game21Provider.notifier).act('rivalBattle', [widget.target, _score]);
    if (!mounted) return;
    if (error != null) {
      toastErr(context, error);
      setState(() {
        _won.clear();
        _busy = false;
      });
      return;
    }
    setState(() {
      _busy = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final kzer = widget.target == 'kzer';
    final pending = !kzer || s['btq'] != null || _done;
    final name = kzer ? "K-Zer d'Mabaya" : (Reg21.rivals[widget.target] ?? 'artiste');
    final round = _rounds[_won.length.clamp(0, 2)];
    final tier = managerTier21(s);
    final prime = tier == null ? '3 000' : '${fmt21(3000 - jsRound(3000 * (tier['rate'] as num)))} net après manager';
    final back = BackHeader(title: 'Battle', step: '1 h · −15 énergie', onBack: () => context.go('/scene'));
    if (!pending) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        back,
        const SizedBox(height: 12),
        const GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aucune battle en attente'),
          SizedBox(height: 4),
          Text('Une battle s’ouvre quand tu acceptes un défi, comme celui de K-Zer au début de ta carrière.'),
        ])),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Retour à la scène', onPressed: () => context.go('/scene')),
      ]);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      back,
      const SizedBox(height: 12),
      LayoutBuilder(
          builder: (context, c) => SceneBanner(
                kind: 'street',
                height: 120,
                role: 'Djo Kéné · $name',
                chars: [
                  const BannerChar('djo', mood: 'serious', gesture: 'mic', crop: 'torso', width: 80, left: 70),
                  if (kzer) const BannerChar("K-Zer d'Mabaya", crop: 'torso', width: 80, left: 236, asset: 'assets/svg/portrait-kzer.svg'),
                ],
              )),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('PUNCHLINE ${(_won.length + (_done ? 0 : 1)).clamp(1, 3)} / 3', style: V20Text.lab()),
        Text('$_score / 3', style: V20Text.baloo(size: 18, line: 20)),
      ]),
      const SizedBox(height: 6),
      MeterBar(value: _score / 3),
      const SizedBox(height: 6),
      Row(children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
              child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: i < _won.length ? (_won[i] ? Tk.ok : Tk.acc) : const Color.fromRGBO(255, 255, 255, .14)))),
        ],
      ]),
      const SizedBox(height: 12),
      if (!_done)
        GameCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ROUND ${_won.length + 1}', style: V20Text.lab()),
          const SizedBox(height: 4),
          Text(round.$1, style: V20Text.nm()),
          Text(round.$2, style: V20Text.bs()),
        ])),
      for (var i = 0; i < _won.length; i++)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('Round ${i + 1} · ${_won[i] ? 'Round gagné' : 'Round perdu'}', style: V20Text.bs(color: _won[i] ? Tk.ok : V20.hintGoldText)),
        ),
      const SizedBox(height: 12),
      if (!_done)
        Row(children: [
          for (var i = 0; i < _answers.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _AnswerPill(_answers[i], _busy ? null : () => _answer(_answers[i]))),
          ],
        ]),
      const SizedBox(height: 12),
      Conseq21(ConsequenceKind.certain, 'Gagne 2 rounds sur 3 : +150 fans, +6 réputation, +$prime cauris. Sinon : +12 fans.'),
      if (_done) ...[
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Voir le résultat', onPressed: () => context.go('/scene/battle-result')),
      ],
    ]);
  }
}

class Rivalites21Screen extends ConsumerWidget {
  const Rivalites21Screen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final links = s['rivals'] is Map ? s['rivals'] as Map : const {};
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Réseau artistique', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Parle avec les artistes, provoque-les ou tente d’apaiser une rivalité. Les interactions et leurs effets chiffrés sont provisoires.'),
      const Lab21('Artistes de Bakoma'),
      for (final rival in Reg21.rivals.entries.where((e) => e.key != 'kzer')) ...[
        const SizedBox(height: 8),
        GameCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.mic_external_on_outlined)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rival.value, style: V20Text.nm()),
              Text(_artistRelation(links[rival.key]), style: V20Text.bs()),
            ])),
          ]),
          const SizedBox(height: 8),
          Text(_artistIntro[rival.key]!, style: V20Text.bm),
          const SizedBox(height: 8),
          ActionRow(title: 'Discuter', subtitle: '1 h · −5 énergie · relation +5 · tension −3', trailing: ActionRow.arrow(), onTap: () => doAct(context, ref, 'artistScene', [rival.key, 'discuter'], null, 'Discussion terminée')),
          ActionRow(title: 'Provoquer', subtitle: '1 h · −10 énergie · relation −5 · tension +15', trailing: ActionRow.arrow(), onTap: () => doAct(context, ref, 'artistScene', [rival.key, 'provoquer'], null, 'La rivalité monte')),
          ActionRow(title: 'Apaiser la rivalité', subtitle: '1 h · −8 énergie · −2 000 cauris · relation +8 · tension −12', trailing: ActionRow.arrow(), disabled: _n(s['cash']) < 2000, onTap: () => doAct(context, ref, 'artistScene', [rival.key, 'apaiser'], null, 'Tension réduite')),
          const SizedBox(height: 6),
          PrimaryButton(label: 'Répondre en freestyle', sublabel: 'Battle · 1 h · −15 énergie', style: GameButtonStyle.secondary, compact: true, onPressed: () => context.go('/scene/rival-battle/${rival.key}')),
        ])),
      ],
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Une battle se joue en trois rounds. À partir de deux bonnes réponses : +150 fans, +3 000 cauris bruts, +6 réputation et +60 XP. La commission du manager est retenue sur le cachet.'),
    ]);
  }

  static const _artistIntro = {
    'zaki': 'Zaki te croise après une sortie et te reproche de viser son public.',
    'orage': 'Madame Orage veut entendre ce que tu as réellement à défendre.',
    'djo': 'Djo Kene te lance un défi pour mesurer ton identité musicale.',
  };

  static String _artistRelation(dynamic raw) {
    if (raw is! Map) return 'Relation neutre · tension 0 / 100';
    final data = Map<String, dynamic>.from(raw);
    final relation = _n(data['relation']).round();
    final tension = _n(data['tension']).round();
    return 'Relation ${relation >= 0 ? '+' : ''}$relation · tension $tension / 100';
  }
}

/// Résultat de battle 21-B2 : victoire ou défaite, puis fans, réputation, prime et énergie dépensée.
class BattleResult21Screen extends ConsumerWidget {
  const BattleResult21Screen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final r = s['btl'] as J?;
    final back = BackHeader(title: 'Résultat de la battle', onBack: () => context.go('/scene'));
    if (r == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        back,
        const SizedBox(height: 12),
        const GlassCard(child: Text('Aucune battle jouée')),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Retour au QG', onPressed: () => context.go('/')),
      ]);
    }
    final win = _n(r['win']) == 1;
    final rival = r['rival'] as String?;
    final isRivalBattle = rival != null;
    return ListView(padding: const EdgeInsets.all(16), children: [
      back,
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: V20.objective, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BATTLE · ${(rival ?? "K-Zer d'Mabaya").toUpperCase()}', style: V20Text.lab(color: Colors.white)),
          Text('${win ? 'BATTLE GAGNÉE' : 'BATTLE PERDUE'} · ${r['score']} / 3', style: V20Text.baloo(size: 26, line: 28)),
          Text(win ? '${rival ?? 'K-Zer'} salue ton flow. Ndolo en parle.' : '${rival ?? 'K-Zer'} a gardé la main. Retravaille tes punchlines.', style: V20Text.bm),
        ]),
      ),
      const SizedBox(height: 8),
      KpiRow(children: [
        StatKpi(label: 'Fans', value: '+${r['fans']}'),
        StatKpi(label: 'Réputation', value: '+${r['rep']}'),
      ]),
      const SizedBox(height: 8),
      KpiRow(children: [
        StatKpi(label: 'Prime', value: win ? '+${fmt21(_n(r['gross']))}' : '0'),
        const StatKpi(label: 'Énergie', value: '−15'),
      ]),
      if (_n(r['managerCut']) > 0) ...[
        const SizedBox(height: 8),
        KeyVal('Commission manager', '−${fmt21(_n(r['managerCut']))} sur ${fmt21(_n(r['gross']))} cauris'),
      ],
      const SizedBox(height: 16),
      PrimaryGlowButton(label: isRivalBattle ? 'Retour aux rivalités' : 'Retour au QG', onPressed: () => context.go(isRivalBattle ? '/scene/rivalites' : '/')),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Journal', style: GameButtonStyle.secondary, onPressed: () => context.go('/journal')),
    ]);
  }
}

/// Réponse de battle (.btn.s de la planche 21-B1) : pilule blanche, texte centré, 56 px.
class _AnswerPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _AnswerPill(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: onTap != null,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: onTap == null ? V20.ink2 : Colors.white, width: 2)),
            child: Text(label.toUpperCase(), style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w800, color: onTap == null ? V20.ink2 : Colors.white, spacing: .5)),
          ),
        ),
      );
}
