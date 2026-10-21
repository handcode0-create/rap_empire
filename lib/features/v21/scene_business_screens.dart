import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../core/widgets/game_icon.dart';
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
import 'festival_screens.dart';
import 'labels_screens.dart';
import 'network_screens.dart';
import 'shell21.dart';
import 'cast21.dart';
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
    final cWait = (Reg21.concertEvery - (day - _n(s['lastConcert']))).clamp(0, 999).toInt();
    final tWait = (Reg21.tourEvery - (day - _n(s['lastTour']))).clamp(0, 999).toInt();
    final aud = tourAudience(s);
    final tk = tickets21(s);
    final mgrTier = managerTier21(s);
    final hasManager = mgrTier != null;
    final fee = (Reg21.tour['fee'] as num) + jsRound((Reg21.tour['feeGeo'] as num) * (_n(_m(s['geo'])['portambre']) + _n(_m(s['geo'])['selene'])));
    final cc = s['cc'] as J?;
    final sponsor = mkSponsor21(s) == null ? null : media21[mkSponsor21(s)];

    // --- les lieux (règles inchangées : mêmes conditions, mêmes actions, mêmes textes de coût) ---
    final battle = s['btq'] == null
        ? null
        : _Venue("Battle contre K-Zer d'Mabaya", 'Défi accepté · 3 rounds face au rival de Mabaya', 'assets/scenes/street.svg',
            meta: const [('clock', '1 h'), ('zap', '−15')], status: ('En attente', GameTagStyle.ok), verb: 'Entrer dans la battle', onTap: () => context.go('/scene/battle'));
    final omPlayed = _n(s['omDay']) == day;
    final omNet = hasManager ? '+${fmt21(3000 - jsRound(3000 * (mgrTier['rate'] as num)))} cauris net' : '+3 000 cauris';
    final openMic = omPlayed
        ? const _Venue('Open mic de Ndolo', 'Déjà joué aujourd’hui · reviens demain', 'assets/scenes/street.svg', status: ('Demain', GameTagStyle.outline), off: true)
        : _Venue('Open mic de Ndolo',
            'Jusqu’à +${jsRound(Reg21.omFans * openMicEffect(s) / 100)} fans si énergie ≥ 40 · effet actuel ${openMicEffect(s)} % (baisse si tu y retournes souvent)', 'assets/scenes/street.svg',
            meta: [('clock', '1 h'), ('zap', '−${15 - moto}'), ('cash', omNet)],
            status: ('Ouvert', GameTagStyle.ok),
            verb: 'Monter sur scène',
            onTap: () => doAct(context, ref, 'openmic', null, () => context.go('/scene/resultat')));
    final rivals = _Venue('Rivalités', 'Défie d’autres artistes de Bakoma en battle', 'assets/scenes/backstage.svg',
        meta: const [('clock', '1 h'), ('zap', '−15')], onTap: () => context.go('/scene/rivalites'));
    final concert = rank < 3
        ? const _Venue('Concert au Parvis', 'Salle de Ndolo · billetterie à ton nom', 'assets/scenes/stage.svg', lock: 'Débloqué au rang N3', off: true)
        : cWait > 0
            ? _Venue('Concert au Parvis', 'Une date par semaine : prochaine possible dans $cWait j', 'assets/scenes/stage.svg', status: ('Dans $cWait j', GameTagStyle.outline), off: true)
            : _Venue('Concert au Parvis', '${Reg21.capacity} places · billetterie estimée : $tk billets × ${Reg21.ticketPrice} = ${fmt21(tk * Reg21.ticketPrice)} · Bakoma +4', 'assets/scenes/stage.svg',
                meta: [('clock', '4 h'), ('zap', '−${35 - moto - car}'), ('cash', '≈ ${fmt21(tk * Reg21.ticketPrice)} cauris brut')],
                status: ('Prêt', GameTagStyle.ok),
                verb: 'Jouer le concert',
                onTap: () => doAct(context, ref, 'concert', null, () => context.go('/scene/resultat')));
    const tourName = 'Tournée régionale (Port-Ambre, Sélène)';
    final tour = rank < 3
        ? const _Venue(tourName, 'Trois dates hors de Bakoma', 'assets/scenes/call.svg', lock: 'Débloquée au rang N3', off: true)
        : aud < Reg21.tourAudience
            ? _Venue(tourName, 'La promo radio y fait monter ta notoriété.', 'assets/scenes/call.svg',
                lock: 'Public régional ${aud.toStringAsFixed(1)} / ${Reg21.tourAudience} de notoriété moyenne', progress: (aud / Reg21.tourAudience).clamp(0, 1).toDouble(), off: true)
            : tWait > 0
                ? _Venue(tourName, 'Une tournée toutes les 4 semaines : encore $tWait j', 'assets/scenes/call.svg', status: ('Dans $tWait j', GameTagStyle.outline), off: true)
                : _Venue(tourName, 'Frais ${fmt21(Reg21.tour['cost'] as num)} · cachets ${fmt21(fee)} · +${Reg21.tour['fans']} fans', 'assets/scenes/call.svg',
                    meta: [('clock', '10 h'), ('zap', '−${(Reg21.tour['e'] as num) - moto - car}'), ('cash', '${fmt21(fee)} cauris de cachets')],
                    status: ('Prête', GameTagStyle.ok),
                    verb: 'Partir en tournée',
                    onTap: () => doAct(context, ref, 'tour', null, () => context.go('/scene/resultat')));
    final booking = _Venue('Booking international', 'Tamarel, Korvane, Aldéra : showcase, tournée ou grande tournée', 'assets/scenes/call.svg',
        lock: rank < Reg21.intlRank ? 'Débloqué au rang N${Reg21.intlRank}' : null,
        status: rank < Reg21.intlRank ? null : ('Agence', GameTagStyle.accent),
        onTap: () => context.go('/scene/booking'));
    final invites = festivalInvites21(s);
    final festivals = _Venue('Calendrier des festivals', '${Reg21.festivals.length} festivals par an, du quartier à l’international', 'assets/scenes/burst.svg',
        status: invites.isEmpty ? null : ('${invites.length} invitation(s)', GameTagStyle.ok), onTap: () => context.go('/scene/festivals'));

    // À l'affiche : la meilleure date jouable maintenant (une seule action principale à l'écran).
    final featured = [battle, concert, tour, openMic].whereType<_Venue>().where((v) => v.onTap != null).firstOrNull;

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      SceneBanner(
        kind: 'stage',
        height: 216,
        role: 'SCÈNE · ${rankName(s).toUpperCase()}',
        name: 'Le live',
        subtitle: '${s['shows']} date(s) jouée(s) · ${fmt21(s['fans'] as num)} fans',
        chars: const [BannerChar('djo', mood: 'sing', gesture: 'micup', crop: 'torso', width: 150, left: 196)],
        top: Wrap(spacing: 6, runSpacing: 6, children: [
          GameTag('N$rank', style: GameTagStyle.accent),
          if (sponsor != null) GameTag('Partenaire ${sponsor.n}', style: GameTagStyle.outline),
        ]),
      ),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Fans', value: fmt21(s['fans'] as num)),
        StatKpi(label: 'Popularité', value: '${s['pop']}'),
        StatKpi(label: 'Billets', value: rank < 3 ? '—' : '$tk', valueColor: Tk.gold),
      ]),
      const SizedBox(height: 16),
      if (featured != null) ...[
        _Featured(featured),
        const SizedBox(height: 8),
      ] else
        const GameHint(icon: 'moon', text: 'Aucune date jouable maintenant : repose-toi, prépare un son ou reviens demain pour l’open mic.'),
      const _SceneSection('Petites scènes', 'Le quartier te jauge : open mic et battles.'),
      if (battle != null) _VenueCard(battle),
      _VenueCard(openMic),
      _VenueCard(rivals),
      const _SceneSection('Concerts', 'Le Parvis de Ndolo, ${Reg21.capacity} places.'),
      if (rank >= 3) ...[
        CrowdStage(fill: (tk / Reg21.capacity).clamp(0, 1), media: sponsor?.n, fillLabel: 'Remplissage estimé'),
        const SizedBox(height: 10),
      ],
      _VenueCard(concert),
      const _SceneSection('Festivals', 'Les promoteurs t’invitent : accepte ou refuse.'),
      for (final i in invites) FestivalInviteCard21(s, '${i['id']}'),
      _VenueCard(festivals),
      const _SceneSection('Tournées', 'Sortir de Bakoma : Port-Ambre, Sélène, puis l’international.'),
      _VenueCard(tour),
      _VenueCard(booking),
      const SizedBox(height: 8),
      _LastShow(cc),
      const SizedBox(height: 12),
      ActionRow(title: 'Voir la popularité par ville', subtitle: 'Effets des dates sur chaque territoire', trailing: ActionRow.arrow(), onTap: () => context.go('/scene/popularite')),
    ]);
  }
}

/// Un lieu de la scène : décor, coûts, état, action. Présentation seulement.
class _Venue {
  final String title, sub, art;
  final List<(String, String)> meta; // (icône clock|zap|cash, valeur)
  final (String, GameTagStyle)? status;
  final String? lock, verb;
  final double? progress;
  final bool off;
  final VoidCallback? onTap;
  const _Venue(this.title, this.sub, this.art, {this.meta = const [], this.status, this.lock, this.verb, this.progress, this.off = false, this.onTap});
}

class _SceneSection extends StatelessWidget {
  final String title, sub;
  const _SceneSection(this.title, this.sub);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 16, 2, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: V20Text.baloo(size: 18, line: 22)),
          Text(sub, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
        ]),
      );
}

Widget _metaChip((String, String) m) {
  final (icon, v) = m;
  final col = icon == 'zap' ? Tk.cy : icon == 'cash' ? Tk.gold : Tk.ink;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: col.withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: col.withValues(alpha: .35))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != 'cash') ...[GameIcon(icon, size: 12, color: col), const SizedBox(width: 4)],
      Text(v, style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w700, color: col)),
    ]),
  );
}

Widget _art(String asset, double size, {bool dim = false}) => ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox.square(
        dimension: size,
        child: Stack(fit: StackFit.expand, children: [
          SvgPicture.asset(asset, fit: BoxFit.cover, placeholderBuilder: (_) => const ColoredBox(color: Tk.deep)),
          if (dim) const ColoredBox(color: Color(0x990C0820)),
        ]),
      ),
    );

/// Carte « À l'affiche » : la date jouable maintenant, avec le seul bouton principal de l'écran.
class _Featured extends StatelessWidget {
  final _Venue v;
  const _Featured(this.v);
  @override
  Widget build(BuildContext context) => GlassCard(
        accent: GlassAccent.magenta,
        semanticLabel: '${v.title}, ${v.sub}',
        onTap: v.onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('À L’AFFICHE MAINTENANT', style: V20Text.lab(color: Tk.acc4)),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _art(v.art, 84),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.title, style: V20Text.baloo(size: 20, line: 23)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final m in v.meta) _metaChip(m)]),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Text(v.sub, style: V20Text.poppins(size: 12, line: 17, color: V20.ink2)),
          const SizedBox(height: 12),
          PrimaryGlowButton(label: v.verb ?? 'Y aller', onPressed: v.onTap),
        ]),
      );
}

class _VenueCard extends StatelessWidget {
  final _Venue v;
  const _VenueCard(this.v);
  @override
  Widget build(BuildContext context) {
    final locked = v.lock != null;
    final ready = v.onTap != null && v.status?.$2 == GameTagStyle.ok;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: v.onTap != null,
        label: '${v.title}. ${v.lock ?? v.sub}',
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: v.onTap,
            child: Ink(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Tk.s1.withValues(alpha: v.off ? .6 : .9),
                border: Border.all(color: ready ? Tk.ok.withValues(alpha: .7) : Colors.white.withValues(alpha: .10), width: ready ? 1.5 : 1),
              ),
              child: Row(children: [
                Stack(children: [
                  _art(v.art, 72, dim: v.off),
                  if (locked) const Positioned.fill(child: Center(child: GameIcon('lock', size: 22, color: V20.lockedIcon))),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.baloo(size: 16, line: 19, color: v.off ? V20.ink2 : Tk.ink)),
                    const SizedBox(height: 2),
                    if (locked)
                      Text(v.lock!, style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w600, color: V20.hintGoldText))
                    else
                      Text(v.sub, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
                    if (v.progress != null) ...[const SizedBox(height: 6), MeterBar(value: v.progress!, tone: MeterTone.gold)],
                    if (v.meta.isNotEmpty) ...[const SizedBox(height: 6), Wrap(spacing: 6, runSpacing: 6, children: [for (final m in v.meta) _metaChip(m)])],
                  ]),
                ),
                const SizedBox(width: 8),
                if (v.status != null) GameTag(v.status!.$1, style: v.status!.$2) else if (v.onTap != null) ActionRow.arrow(),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dernière date jouée, avec sa note.
class _LastShow extends StatelessWidget {
  final J? cc;
  const _LastShow(this.cc);
  @override
  Widget build(BuildContext context) {
    final c = cc;
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DERNIERS RÉSULTATS', style: V20Text.lab()),
        const SizedBox(height: 8),
        if (c == null)
          Text('Aucune date aujourd’hui.', style: V20Text.bs())
        else
          Row(children: [
            if (c['tour'] != 1)
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Tk.acc, Tk.violet])),
                child: Text('${c['g']}', style: V20Text.baloo(size: 24, line: 24, color: Tk.bg)),
              ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c['lbl'] != null ? '${c['lbl']}' : c['tour'] == 1 ? 'Tournée régionale' : 'Concert au Parvis · note ${c['g']}', style: V20Text.nm()),
                Text('${fmt21(c['fans'] as num)} fans · ${fmt21(c['cash'] as num)} cauris nets · réputation +${c['rep']}', style: V20Text.bs()),
                if (_n(c['managerCut']) > 0) Text('Retenue manager : −${fmt21(_n(c['managerCut']))} cauris sur ${fmt21(_n(c['gross']))}', style: V20Text.bs()),
              ]),
            ),
          ]),
      ]),
    );
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
            Text(cc['lbl'] != null ? '${cc['lbl']}'.toUpperCase() : cc['tour'] == 1 ? 'TOURNÉE RÉGIONALE' : 'LE PARVIS · NDOLO',
                style: V20Text.lab(color: V20.accText)),
            Text(cc['tour'] == 1 ? 'Tournée' : 'Note ${cc['g']}',
                style: V20Text.dm(size: 30)),
          ]),
        ),
        const SizedBox(height: 12),
        CrowdStage(
            fill: cc['tour'] == 1 ? 0.9 : (_n(cc['fill'] ?? jsRound(100 * _n(cc['tk']) / Reg21.capacity)) / 100).clamp(0, 1),
            media: cc['media'] == null ? null : media21[cc['media']]?.n),
        if (_n(cc['spon']) > 0) ...[
          const SizedBox(height: 8),
          Conseq21(ConsequenceKind.certain, 'Partenaire ${media21[cc['media']]?.n ?? ''} : bonus de cachet +${fmt21(_n(cc['spon']))} (inclus dans le gain)'),
        ],
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

  static const _jobArt = {
    'livraison': 'street', 'maquis': 'street', 'mc': 'stage', 'assistant': 'studio', 'mariage': 'backstage',
    'pubradio': 'call', 'atelierjeunes': 'office', 'jury': 'stage', 'plume': 'studio',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final rank = rankOf(s);
    final moto = _m(s['own'])['moto'] != null ? 5 : 0;
    final biz = _m(s['biz']);
    final active = Reg21.biz.keys.where((k) => biz[k] != null).toList();
    final bizTotal = active.fold<num>(0, (a, k) => a + _n(_m(biz[k])['tot']));
    final mgr = managerTier21(s);
    final signed = _n(s['signed']) != 0;
    final label = signed ? '${s['label'] ?? 'BSR'}' : null;

    final jobs = [
      for (final e in Reg21.jobs.entries)
        () {
          final lock = jobLock21(s, e.key) != null ? jobLockText21(s, e.key) ?? 'Indisponible' : null;
          return _Venue(e.value['n'] as String, '${e.value['need']}', 'assets/scenes/${_jobArt[e.key] ?? 'street'}.svg',
              meta: [('clock', '${e.value['h']} h'), ('zap', '−${(e.value['e'] as num) - moto}'), ('cash', '+${fmt21(e.value['cash'] as num)} cauris')],
              lock: lock,
              off: lock != null,
              onTap: lock != null ? null : () => doAct(context, ref, 'job', e.key, () => context.go('/business/boulot')));
        }(),
    ];
    // les boulots ouverts d'abord, puis les verrouillés (du plus proche au plus lointain)
    jobs.sort((a, b) => (a.lock == null ? 0 : 1).compareTo(b.lock == null ? 0 : 1));

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      SceneBanner(
        kind: 'office',
        height: 200,
        role: 'BUSINESS · ${rankName(s).toUpperCase()}',
        name: 'Ton empire',
        subtitle: '${fmt21(_n(s['cash']))} cauris en caisse',
        chars: const [BannerChar('djo', mood: 'poised', gesture: 'deal', crop: 'torso', width: 140, left: 206)],
        top: Wrap(spacing: 6, runSpacing: 6, children: [
          GameTag(signed ? 'Signé · $label' : 'Indépendant', style: GameTagStyle.accent),
          if (mgr != null) GameTag('Manager ${mgr['n']}', style: GameTagStyle.outline),
        ]),
      ),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Boulots', value: '${jobs.where((j) => j.lock == null).length}/${jobs.length}', valueColor: Tk.gold),
        StatKpi(label: 'Entreprises', value: '${active.length}/${Reg21.biz.length}'),
        StatKpi(label: 'Patrimoine', value: '${_m(s['own']).length}'),
      ]),
      const SizedBox(height: 10),
      GlassCard(
        halo: false,
        onTap: () => context.go('/business/labels'),
        semanticLabel: 'Merchandising et label',
        child: Row(children: [
          if (label != null) LabelLogo21(label, size: 52) else Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: Tk.tint, borderRadius: BorderRadius.circular(16)), child: const GameIcon('briefcase', color: Tk.acc4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Merchandising et label', style: V20Text.baloo(size: 17, line: 20)),
              Text(signed ? 'Sous contrat · merch, collection capsule' : (_n(s['fans']) >= 1000 ? 'T-shirts, collection capsule, contrat' : 'Débloqué avec la carrière'), style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              const SizedBox(height: 6),
              MeterBar(value: (_n(s['lbz']) / Reg21.lbzGate).clamp(0, 1).toDouble(), tone: MeterTone.gold, thin: true),
              const SizedBox(height: 2),
              Text(labelReady21(s) ? 'Les labels s’intéressent à toi' : 'Intérêt des labels ${_n(s['lbz']).toInt()} / ${Reg21.lbzGate}', style: V20Text.poppins(size: 11, line: 14, color: V20.hintGoldText)),
            ]),
          ),
          ActionRow.arrow(),
        ]),
      ),
      const _SceneSection('Petits boulots', 'Des cauris vite gagnés. Les plus rentables s’ouvrent avec le rang et les compétences.'),
      for (final j in jobs) _VenueCard(j),
      const _SceneSection('Formation', 'Progresser : flow, écriture, voix, charisme.'),
      _SkillsCard(s, onTap: () => context.go('/business/formation')),
      const SizedBox(height: 10),
      for (final v in _trainingVenues(context, ref, s).where((v) => v.onTap != null).take(2)) _VenueCard(v),
      ActionRow(title: 'Toutes les formations', subtitle: '${Reg21.trainings.length + 1} formations · les plus poussées s’ouvrent avec le rang', trailing: ActionRow.arrow(), onTap: () => context.go('/business/formation')),
      _SceneSection('Entreprises', active.isEmpty ? 'Des revenus chaque jour, selon le rang.' : 'Cumul de tes entreprises : ${fmt21(bizTotal)} cauris.'),
      for (final e in Reg21.biz.entries)
        _VenueCard(biz[e.key] != null
            ? _Venue(e.value['n'] as String, 'En activité · cumul ${fmt21(_n(_m(biz[e.key])['tot']))} cauris', 'assets/scenes/office.svg',
                status: ('Actif', GameTagStyle.ok), onTap: () => context.go('/business/entreprises'))
            : rank < (e.value['rank'] as num)
                ? _Venue(e.value['n'] as String, '${fmt21(e.value['cost'] as num)} cauris', 'assets/scenes/office.svg', lock: 'Débloqué au rang N${e.value['rank']}', off: true)
                : _Venue(e.value['n'] as String, 'Revenu estimé ${fmt21(e.value['lo'] as num)} à ${fmt21(e.value['hi'] as num)} / jour', 'assets/scenes/office.svg',
                    meta: [('cash', '${fmt21(e.value['cost'] as num)} cauris')], onTap: () => context.go('/business/entreprises'))),
      const _SceneSection('Gestion', 'Biens, équipe et affaires.'),
      Row(children: [
        _BizTile('home', 'Patrimoine', '${_m(s['own']).length} bien(s) · effets', () => context.go('/business/patrimoine')),
        const SizedBox(width: 10),
        _BizTile('users', 'Équipe et manager', mgr != null ? '${mgr['n']} · ${((mgr['rate'] as num) * 100).round()} % des cachets' : 'Aucun manager · optionnel', () => context.go('/business/manager')),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _BizTile('lock', 'Justice et détention', s['jail'] != null ? 'Détention · ${jailDaysLeft(s)} jour(s) restant(s)' : s['cas'] != null ? 'Affaire en cours' : 'Casier, avocat, procès', () => context.go('/business/justice'),
            alert: s['jail'] != null || s['cas'] != null),
        const SizedBox(width: 10),
        _BizTile('trend', 'Marketing et médias', 'Campagnes, partenaires de concert', () => context.go('/profil/reseau/marketing')),
      ]),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Boulots, entreprises, patrimoine et merch rapportent des cauris, pas de fans ni de rang.'),
    ]);
  }
}

/// Formations sous forme de lieux (atelier d'écriture puis Reg21.trainings), disponibles d'abord.
List<_Venue> _trainingVenues(BuildContext context, WidgetRef ref, J s) {
  final moto = _m(s['own'])['moto'] != null ? 5 : 0;
  String gains(Map g) => g.entries.map((e) => '${Reg21.skillNames[e.key]} +${e.value}').join(' · ');
  final out = <_Venue>[
    _Venue("Atelier d'écriture", 'Écriture +5 · mission 3', 'assets/scenes/office.svg',
        meta: const [('clock', '2 h'), ('zap', '−20'), ('cash', '−6 000 cauris')],
        onTap: () => doAct(context, ref, 'atelier', null, null, 'Écriture +5 · Atelier terminé')),
    for (final e in Reg21.trainings.entries)
      () {
        final t = e.value;
        final lock = trainLock21(s, e.key);
        final meta = [('clock', '${t['h']} h'), ('zap', '−${math.max(0, (t['e'] as num) - moto)}'), ('cash', _n(t['cost']) == 0 ? 'Gratuit' : '−${fmt21(t['cost'] as num)} cauris')];
        if (lock == 'rang') return _Venue('${t['n']}', '${t['d']} · ${gains(t['gain'] as Map)}', 'assets/scenes/${t['art']}.svg', lock: 'Débloquée au rang N${t['rank']} · ${gains(t['gain'] as Map)}', off: true);
        if (lock == 'aujourdhui') return _Venue('${t['n']}', 'Déjà suivie aujourd’hui · reviens demain', 'assets/scenes/${t['art']}.svg', status: ('Demain', GameTagStyle.outline), off: true);
        return _Venue('${t['n']}', '${t['d']} · ${gains(t['gain'] as Map)}', 'assets/scenes/${t['art']}.svg',
            meta: meta, status: (gains(t['gain'] as Map), GameTagStyle.ok), onTap: () => doAct(context, ref, 'train', e.key, null, '${t['n']} · ${gains(t['gain'] as Map)}'));
      }(),
  ];
  out.sort((a, b) => (a.onTap != null ? 0 : 1).compareTo(b.onTap != null ? 0 : 1));
  return out;
}

/// Les quatre compétences du joueur.
class _SkillsCard extends StatelessWidget {
  final J s;
  final VoidCallback? onTap;
  const _SkillsCard(this.s, {this.onTap});
  @override
  Widget build(BuildContext context) {
    final sk = _m(s['sk']);
    return GlassCard(
      halo: false,
      onTap: onTap,
      semanticLabel: 'Compétences : ${Reg21.skillNames.entries.map((e) => '${e.value} ${_n(sk[e.key])}').join(', ')}',
      child: Row(children: [
        for (final e in Reg21.skillNames.entries)
          Expanded(
            child: Column(children: [
              Text('${_n(sk[e.key])}', style: V20Text.baloo(size: 24, line: 28, color: Tk.ink)),
              const SizedBox(height: 4),
              MeterBar(value: (_n(sk[e.key]) / 100).clamp(0, 1).toDouble(), tone: MeterTone.cyan, thin: true),
              const SizedBox(height: 4),
              Text(e.value.toUpperCase(), style: V20Text.poppins(size: 10, line: 12, weight: FontWeight.w700, color: V20.ink2, spacing: .4)),
            ]),
          ),
      ].expand((w) => [w, const SizedBox(width: 8)]).toList()..removeLast()),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-E6 Formation
// ---------------------------------------------------------------------------------------------------------------------

class FormationScreen21 extends ConsumerWidget {
  const FormationScreen21({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final venues = _trainingVenues(context, ref, s);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      BackHeader(title: 'Formation', step: '${venues.where((v) => v.onTap != null).length} dispo', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      _SkillsCard(s),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Chaque formation se suit une fois par jour. Coach vocal, freestyle et shooting : planche 09.3 ; les autres formations et leurs effets sont proposés, valeurs provisoires.'),
      const SizedBox(height: 12),
      for (final v in venues) _VenueCard(v),
    ]);
  }
}

class _BizTile extends StatelessWidget {
  final String icon, title, sub;
  final VoidCallback onTap;
  final bool alert;
  const _BizTile(this.icon, this.title, this.sub, this.onTap, {this.alert = false});
  @override
  Widget build(BuildContext context) => Expanded(
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          halo: false,
          accent: alert ? GlassAccent.gold : GlassAccent.none,
          onTap: onTap,
          semanticLabel: '$title, $sub',
          child: SizedBox(
            height: 108,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: Tk.tint, borderRadius: BorderRadius.circular(12)), child: GameIcon(icon, size: 18, color: alert ? Tk.gold : Tk.acc4)),
              const Spacer(),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.baloo(size: 15, line: 18)),
              Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
            ]),
          ),
        ),
      );
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
      if (s['signed'] != 1) ...[LabelInterestCard(s), const SizedBox(height: 12)],
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
                : (rep >= Reg21.labelRep && labelReady21(s)
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
        // Le manager affiché est celui de ton niveau (illustration si le personnage existe, sinon monogramme).
        SizedBox(
            width: 96,
            height: 120,
            child: castId21(tier['n'] as String) != null
                ? CharacterView(who: castId21(tier['n'] as String)!, mood: 'poised', crop: 'bust')
                : Center(child: CastAvatar(tier['n'] as String, size: 80))),
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
            CastAvatar(rival.key, size: 48, mood: 'smirk'),
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


/// Condition manquante d'un boulot, en clair (null s'il est accessible).
String? jobLockText21(J s, String id) {
  final j = Reg21.jobs[id]!;
  final sk = _m(s['sk']);
  return switch (jobLock21(s, id)) {
    'rang' => 'Rang N${j['rank']} requis (tu es N${_n(s['rank']).toInt()})',
    'charisme' => 'Charisme ${j['cha']} requis (tu as ${_n(sk['cha']).toInt()})',
    'voix' => 'Voix ${j['voix']} requise (tu as ${_n(sk['voix']).toInt()})',
    'ecriture' => 'Écriture ${j['ecr']} requise (tu as ${_n(sk['ecr']).toInt()})',
    'rep' => 'Réputation ${j['rep']} requise (tu as ${_n(s['rep']).toInt()})',
    _ => null,
  };
}
