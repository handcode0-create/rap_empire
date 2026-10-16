import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
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
    final day = _n(s['day']);
    final cWait = (Reg21.concertEvery - (day - _n(s['lastConcert']))).clamp(0, 999).toInt();
    final tWait = (Reg21.tourEvery - (day - _n(s['lastTour']))).clamp(0, 999).toInt();
    final aud = tourAudience(s);
    final tk = tickets21(s);
    final fee = (Reg21.tour['fee'] as num) + jsRound((Reg21.tour['feeGeo'] as num) * (_n(_m(s['geo'])['portambre']) + _n(_m(s['geo'])['selene'])));
    final cc = s['cc'] as J?;

    Widget row(String title, String sub, {Widget? tag, String? note, VoidCallback? onTap, bool off = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionRow(title: title, subtitle: sub, note: note, disabled: off, trailing: tag ?? ActionRow.arrow(disabled: off), onTap: onTap),
        );
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('SCÈNE', style: V20Text.dm()), GameTag('${s['shows']} date(s)')]),
      const SizedBox(height: 12),
      KpiRow(children: [StatKpi(label: 'Fans', value: fmt21(s['fans'] as num)), StatKpi(label: 'Popularité', value: '${s['pop']}')]),
      const SizedBox(height: 12),
      row('Open mic de Ndolo', '1 h · −${15 - moto} énergie · +150 fans, +3 000, Bakoma +2 si énergie ≥ 40', tag: const GameTag('Ouvert', style: GameTagStyle.ok), onTap: () => doAct(context, ref, 'openmic', null, () => context.go('/scene/resultat'))),
      if (rank < 3)
        row('Concert au Parvis', 'Débloqué au rang N3', off: true, tag: const GameTag('N3', style: GameTagStyle.outline))
      else if (cWait > 0)
        row('Concert au Parvis', 'Une date par semaine : prochaine possible dans $cWait j', off: true, tag: const GameTag('Délai', style: GameTagStyle.outline))
      else
        row('Concert au Parvis (${Reg21.capacity} places)', '4 h · −${35 - moto} énergie · billetterie estimée : $tk billets × ${Reg21.ticketPrice} = ${fmt21(tk * Reg21.ticketPrice)} · Bakoma +4',
            tag: const GameTag('Prêt', style: GameTagStyle.ok), onTap: () => doAct(context, ref, 'concert', null, () => context.go('/scene/resultat'))),
      const Lab21('Tournées'),
      if (rank < 3)
        row('Tournée régionale (Port-Ambre, Sélène)', 'Débloquée au rang N3', off: true, tag: const GameTag('N3', style: GameTagStyle.outline))
      else if (aud < Reg21.tourAudience)
        row('Tournée régionale (Port-Ambre, Sélène)', 'Public régional insuffisant : ${aud.toStringAsFixed(1)} / ${Reg21.tourAudience} de notoriété moyenne à Port-Ambre et Sélène. La promo radio y fait monter ta notoriété.',
            off: true, tag: const GameTag('Public', style: GameTagStyle.outline))
      else if (tWait > 0)
        row('Tournée régionale (Port-Ambre, Sélène)', 'Une tournée toutes les 4 semaines : encore $tWait j', off: true, tag: const GameTag('Délai', style: GameTagStyle.outline))
      else
        row('Tournée régionale (Port-Ambre, Sélène)', '10 h · −${50 - moto} énergie · frais ${fmt21(Reg21.tour['cost'] as num)} · cachets ${fmt21(fee)} · +${Reg21.tour['fans']} fans',
            tag: const GameTag('Prête', style: GameTagStyle.ok), onTap: () => doAct(context, ref, 'tour', null, () => context.go('/scene/resultat'))),
      row('Date à Tamarel Open Air', rank < Reg21.intlRank ? 'Débloquée au rang N5 · festival de 60 000 places (18.3)' : 'Date internationale : à venir', off: true, tag: const GameTag('N${Reg21.intlRank}', style: GameTagStyle.outline)),
      const SizedBox(height: 4),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DERNIERS RÉSULTATS', style: V20Text.lab()),
          const SizedBox(height: 4),
          if (cc == null)
            Text('Aucune date aujourd’hui.', style: V20Text.bs())
          else ...[
            Text(cc['tour'] == 1 ? 'Tournée régionale' : 'Concert au Parvis · note ${cc['g']}', style: V20Text.nm()),
            Text('${fmt21(cc['fans'] as num)} fans · ${fmt21(cc['cash'] as num)} cauris · réputation +${cc['rep']}', style: V20Text.bs()),
          ],
        ]),
      ),
      const SizedBox(height: 8),
      ActionRow(title: 'Voir la popularité par ville', subtitle: 'Effets des dates sur chaque territoire', trailing: ActionRow.arrow(), onTap: () => context.go('/scene/popularite')),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Battle et déroulé du concert : écrans existants 06.3 et 07.1 à 07.3, non refaits. Nouveau : tournée, date internationale et effet de chaque date sur les villes.'),
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
      BackHeader(title: 'Résultat de la date', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      if (cc == null) ...[
        Text('Aucune date jouée', style: V20Text.nm()),
        Text('Lance un concert ou une tournée depuis la Scène.', style: V20Text.bm),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cc['tour'] == 1 ? 'TOURNÉE RÉGIONALE' : 'LE PARVIS · NDOLO', style: V20Text.lab(color: V20.accText)),
            Text(cc['tour'] == 1 ? 'Tournée' : 'Note ${cc['g']}', style: V20Text.dm(size: 30)),
          ]),
        ),
        const SizedBox(height: 12),
        if (cc['tour'] != 1)
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BILLETTERIE', style: V20Text.lab()),
              KeyVal('Billets vendus', '${cc['tk']} / ${Reg21.capacity}'),
              const SizedBox(height: 4),
              MeterBar(value: (_n(cc['tk']) / Reg21.capacity).clamp(0, 1).toDouble()),
              const SizedBox(height: 4),
              Text('${Reg21.ticketPrice} cauris par billet ; note B : 15 % de recette en moins.', style: V20Text.bs()),
            ]),
          ),
        const SizedBox(height: 12),
        KpiRow(children: [StatKpi(label: 'Gain net', value: sg21(_n(cc['cash']))), StatKpi(label: 'Fans', value: sg21(_n(cc['fans']))), StatKpi(label: 'Réputation', value: '+${cc['rep']}')]),
        const SizedBox(height: 8),
        KeyVal('Cash', fmt21(s['cash'] as num), color: Tk.gold),
      ],
      const SizedBox(height: 16),
      PrimaryGlowButton(label: 'Retour à la scène', onPressed: () => context.go('/scene')),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Retour au QG', style: GameButtonStyle.ghost, onPressed: () => context.go('/')),
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
      KpiRow(children: [StatKpi(label: 'Popularité générale', value: '${s['pop']}', big: true), StatKpi(label: 'Fans', value: fmt21(s['fans'] as num), big: true)]),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PAR VILLE · NOTORIÉTÉ 0-100', style: V20Text.lab()),
          for (final c in Reg21.cities.entries) Gauge21(c.value, geoOf(s, c.key), color: Tk.cy),
        ]),
      ),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PAR CONTINENT · MOYENNE DES VILLES', style: V20Text.lab()),
          for (final c in Reg21.conts.entries) Gauge21(c.value['n'] as String, contOf(s, c.key), color: Tk.violet),
        ]),
      ),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Sorties : surtout Bakoma ; promo radio : Port-Ambre et Sélène ; tournée régionale : +8 dans ces deux villes ; dates internationales : rang N5. Les continents regroupent des villes fictives.'),
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
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('BUSINESS', style: V20Text.dm()), GameTag('Patrimoine ${_m(s['own']).length}')]),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Matériel et formation : écrans existants 09.1 et 09.3. Nouveau ici : petits boulots, entreprises, patrimoine, merch. Ces activités rapportent des cauris, pas de fans ni de rang.'),
      const Lab21('Formation'),
      ActionRow(
        title: "Atelier d'écriture",
        subtitle: '2 h · −20 énergie · Écriture +5 · mission 3',
        trailing: Text('6 000', style: V20Text.nm(color: Tk.gold)),
        onTap: () => doAct(context, ref, 'atelier', null, null, 'Écriture +5 · Atelier terminé'),
      ),
      const Lab21('Petits boulots · dès le début'),
      for (final e in Reg21.jobs.entries) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionRow(
            title: e.value['n'] as String,
            subtitle: '${e.value['h']} h · −${(e.value['e'] as num) - moto} énergie · ${e.value['need']}',
            note: e.value['cha'] != null && cha < (e.value['cha'] as num) ? 'Charisme ${e.value['cha']} requis (tu as ${cha.toInt()})' : null,
            disabled: e.value['cha'] != null && cha < (e.value['cha'] as num),
            trailing: Text('+${fmt21(e.value['cash'] as num)}', style: V20Text.nm(color: Tk.gold)),
            onTap: () => doAct(context, ref, 'job', e.key, () => context.go('/business/boulot')),
          ),
        ),
      ],
      const Lab21('Entreprises · selon le rang'),
      for (final e in Reg21.biz.entries) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionRow(
            title: e.value['n'] as String,
            subtitle: _m(s['biz'])[e.key] != null ? 'En activité · cumul ${fmt21(_n(_m(_m(s['biz'])[e.key])['tot']))} cauris' : '${fmt21(e.value['cost'] as num)} cauris · revenu estimé ${fmt21(e.value['lo'] as num)} à ${fmt21(e.value['hi'] as num)} / jour',
            note: _m(s['biz'])[e.key] == null && rank < (e.value['rank'] as num) ? 'Débloqué au rang N${e.value['rank']}' : null,
            disabled: _m(s['biz'])[e.key] == null && rank < (e.value['rank'] as num),
            trailing: _m(s['biz'])[e.key] != null ? const GameTag('Actif', style: GameTagStyle.ok) : ActionRow.arrow(),
            onTap: () => context.go('/business/entreprises'),
          ),
        ),
      ],
      const Lab21('Patrimoine et merchandising'),
      ActionRow(title: 'Patrimoine', subtitle: '${_m(s['own']).length} bien(s) · effets', trailing: ActionRow.arrow(), onTap: () => context.go('/business/patrimoine')),
      const SizedBox(height: 8),
      ActionRow(title: 'Merchandising et label', subtitle: _n(s['fans']) >= 1000 ? 'T-shirts, collection capsule, contrat' : 'Débloqué avec la carrière', trailing: ActionRow.arrow(), onTap: () => context.go('/business/labels')),
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
      BackHeader(title: 'Résultat du boulot', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      if (j == null) ...[
        Text('Aucun boulot fait aujourd’hui', style: V20Text.nm()),
        Text('Choisis un boulot dans Business.', style: V20Text.bm),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BOULOT TERMINÉ', style: V20Text.lab(color: V20.accText)),
            Text(Reg21.jobs[j['id']]!['n'] as String, style: V20Text.nm()),
            const SizedBox(height: 8),
            KeyVal('Gain', '+${fmt21(j['cash'] as num)}', color: Tk.gold),
            KeyVal('Énergie', '−${j['e']}'),
            KeyVal('Durée', '${j['h']} h'),
            KeyVal('Cash', fmt21(s['cash'] as num)),
            const Conseq21(ConsequenceKind.certain, 'Gain fixe, versé tout de suite. Aucun effet sur les fans ni sur le rang.'),
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
      PrimaryGlowButton(label: 'Retour au QG', onPressed: () => context.go('/')),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Autre activité', style: GameButtonStyle.ghost, onPressed: () => context.go('/business')),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(e.value['n'] as String, style: V20Text.nm())),
                owned ? const GameTag('En activité', style: GameTagStyle.ok) : (locked ? GameTag('Verrouillé · N${e.value['rank']}', style: GameTagStyle.outline) : const GameTag('Accessible')),
              ]),
              KeyVal('Investissement', '${fmt21(e.value['cost'] as num)} cauris'),
              Conseq21(ConsequenceKind.estimated, 'Revenu estimé ${fmt21(e.value['lo'] as num)} à ${fmt21(e.value['hi'] as num)} cauris par jour, selon la journée : jamais garanti.'),
              if (owned) KeyVal('Revenus cumulés', '${fmt21(_n(_m(_m(s['biz'])[e.key])['tot']))} cauris'),
              if (locked) Text('Pourquoi verrouillé : rang N${e.value['rank']} requis (tu es N$rank).', style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w600, color: V20.hintGoldText)),
              if (!owned) ...[
                const SizedBox(height: 8),
                PrimaryButton(label: 'Investir', sublabel: '−${fmt21(e.value['cost'] as num)} cauris', compact: true, style: locked ? GameButtonStyle.disabled : GameButtonStyle.secondary, onPressed: () => doAct(context, ref, 'bizBuy', e.key, null, '${e.value['n']} : investissement fait')),
              ],
            ]),
          );
        }),
      ],
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Revenus versés à la fin de chaque journée et listés dans le bilan.'),
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
    final total = _m(s['own']).keys.fold<num>(0, (a, k) => a + (Reg21.assets[k]!['cost'] as num)) + _m(s['biz']).keys.fold<num>(0, (a, k) => a + (Reg21.biz[k]!['cost'] as num));
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Patrimoine', onBack: () => context.go('/business')),
      const SizedBox(height: 8),
      KeyVal('Valeur du patrimoine', '${fmt21(total)} cauris', color: Tk.gold),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Chaque bien a un effet propre sur le jeu : énergie, coût d’une activité, qualité ou revenu. Aucun n’est décoratif.'),
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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.value['n'] as String, style: V20Text.nm()), Text(e.value['eff'] as String, style: V20Text.bs())])),
            _m(s['own'])[e.key] != null ? const GameTag('Possédé', style: GameTagStyle.ok) : Text(fmt21(e.value['cost'] as num), style: V20Text.nm(color: Tk.gold)),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      const Conseq21(ConsequenceKind.certain, 'Achat définitif. L’appartement coûte 2 000 cauris d’entretien par jour.'),
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
      BackHeader(title: 'Confirmation d’achat', onBack: () => context.go('/business/patrimoine')),
      const SizedBox(height: 12),
      if (a == null)
        Text('Aucun bien sélectionné', style: V20Text.nm())
      else ...[
        Text('ACHETER ${(a['n'] as String).toUpperCase()} ?', style: V20Text.dm(size: 26)),
        const SizedBox(height: 12),
        Conseq21(ConsequenceKind.certain, a['eff'] as String),
        const SizedBox(height: 8),
        GlassCard(
          child: Column(children: [
            KeyVal('Prix', '${fmt21(a['cost'] as num)} cauris', color: Tk.gold),
            KeyVal('Cash après achat', '${fmt21(_n(s['cash']) - (a['cost'] as num))} cauris'),
          ]),
        ),
        const SizedBox(height: 16),
        if (_n(s['cash']) >= (a['cost'] as num))
          PrimaryGlowButton(label: 'Acheter', sublabel: 'Achat définitif', onPressed: () => doAct(context, ref, 'assetBuy', null, () => context.go('/business/patrimoine'), '${a['n']} acquis'))
        else
          const GameHint(icon: 'info', warn: true, text: 'Cash insuffisant'),
      ],
      const SizedBox(height: 8),
      PrimaryButton(label: 'Annuler', style: GameButtonStyle.ghost, onPressed: () => context.go('/business/patrimoine')),
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
      BackHeader(title: 'Merchandising', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      for (final e in Reg21.merch.entries) ...[
        Builder(builder: (context) {
          final m = e.value;
          final running = s['merch'] != null && _m(s['merch'])['id'] == e.key;
          final done = _m(s['merchDone'])[e.key];
          final ok = _n(s['fans']) >= (m['fans'] as num) && (m['singles'] == null || (s['disco'] as List).length >= (m['singles'] as num)) && (m['rank'] == null || rankOf(s) >= (m['rank'] as num));
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GameCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: Text(m['n'] as String, style: V20Text.nm())),
                  running ? const GameTag('En vente', style: GameTagStyle.ok) : (done != null ? const GameTag('Écoulé') : (ok ? const GameTag('Accessible') : const GameTag('Verrouillé', style: GameTagStyle.outline))),
                ]),
                Text('Condition : ${m['cl']} · stock ${fmt21(m['cost'] as num)} cauris · ${m['days']} jours', style: V20Text.bs()),
                Conseq21(ConsequenceKind.estimated, 'Ventes estimées : ${m['perFan'].toString().replaceAll('.', ',')} cauris par fan et par jour'),
                if (running) ...[KeyVal('Jours restants', '${_m(s['merch'])['left']}'), KeyVal('Ventes cumulées', fmt21(_n(_m(s['merch'])['tot'])))],
                if (done != null) KeyVal('Total vendu', fmt21(_n(done))),
                if (!running) ...[
                  const SizedBox(height: 8),
                  PrimaryButton(label: 'Lancer', sublabel: '−${fmt21(m['cost'] as num)} cauris', compact: true, style: ok && s['merch'] == null ? GameButtonStyle.secondary : GameButtonStyle.disabled, onPressed: () => doAct(context, ref, 'merch', e.key, null, '${m['n']} lancé')),
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
            Flexible(child: Text('Bakoma Sound Records', style: V20Text.nm())),
            s['signed'] == 1 ? const GameTag('Signé', style: GameTagStyle.ok) : (rep >= Reg21.labelRep ? const GameTag('Offre') : const GameTag('Rép. ${Reg21.labelRep}', style: GameTagStyle.outline)),
          ]),
          Text('Avance ${fmt21(Reg21.labelAdvance)} · 35 % sur les écoutes · 6 mois · 2 sons par trimestre (08.2)', style: V20Text.bs()),
          const SizedBox(height: 8),
          if (s['signed'] != 1)
            PrimaryButton(
              label: 'Signer le contrat',
              sublabel: '+${fmt21(Reg21.labelAdvance)} cauris d’avance',
              compact: true,
              style: rep >= Reg21.labelRep ? GameButtonStyle.secondary : GameButtonStyle.disabled,
              onPressed: () => doAct(context, ref, 'sign', null, null, 'Contrat signé'),
            ),
          if (rep < Reg21.labelRep) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Encore ${(Reg21.labelRep - rep).toInt()} points de réputation.', style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w600, color: V20.hintGoldText))),
        ]),
      ),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text('Créer ton label', style: V20Text.nm())), const GameTag('Verrouillé', style: GameTagStyle.outline)]),
          KeyVal('Réputation ${Reg21.ownLabelRep}', rep >= Reg21.ownLabelRep ? '✓' : '—'),
          KeyVal('Capital ${fmt21(Reg21.ownLabelCash)} cauris', _n(s['cash']) >= Reg21.ownLabelCash ? '✓' : '—'),
          const KeyVal('Manager M3 ou plus', 'non modélisé ici', bold: false),
          Text('Validé (D-05), seuils provisoires.', style: V20Text.bs()),
        ]),
      ),
    ]);
  }
}
