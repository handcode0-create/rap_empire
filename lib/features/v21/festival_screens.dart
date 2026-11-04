import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_icon.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'cast21.dart';
import 'widgets21.dart';

/// Festivals (21-F1, invitations et calendrier) et booking international (21-F2, agence de Désiré Kpan).
/// Intention : le joueur reçoit des propositions qu'il accepte ou refuse en voyant ce qu'elles coûtent et rapportent ;
/// à l'international, il choisit un marché et un format. Règles dans engine21 (fest, intl) ; valeurs provisoires (D-08).

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic> ? x : (x is Map ? x.map((k, v) => MapEntry('$k', v)) : <String, dynamic>{});

/// Carte d'invitation à un festival : qui invite, ce que ça coûte, ce que ça rapporte, accepter ou refuser.
class FestivalInviteCard21 extends ConsumerWidget {
  final J s;
  final String id;
  const FestivalInviteCard21(this.s, this.id, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = Reg21.festivals[id]!;
    final mgr = managerTier21(s);
    final fee = f['fee'] as num;
    final net = mgr == null ? fee : fee - jsRound(fee * (mgr['rate'] as num));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        accent: GlassAccent.gold,
        halo: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('INVITATION · FESTIVAL ${'${f['lvl']}'.toUpperCase()}', style: V20Text.lab(color: V20.hintGoldText))),
            GameTag('S${weekOf21(_n(s['day']))}', style: GameTagStyle.outline),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            CastAvatar('${f['who']}', size: 48, ring: Tk.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${f['n']}', style: V20Text.baloo(size: 19, line: 22)),
                Text('${f['city']} · ${fmt21(f['cap'] as num)} places · invité par ${f['who']}', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Conseq21(ConsequenceKind.certain, 'Cachet ${fmt21(fee)} cauris${mgr != null ? ' (${fmt21(net)} net après manager)' : ''} · ${f['h']} h · −${f['e']} énergie'),
          Conseq21(ConsequenceKind.estimated, '+${fmt21(f['fans'] as num)} fans · réputation +${f['rep']} · notoriété à ${f['city']} +${f['geo']}'),
          const Conseq21(ConsequenceKind.certain, 'Refuser : aucune pénalité, l’invitation se ferme.'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: PrimaryButton(
                  label: 'Accepter',
                  style: GameButtonStyle.secondary,
                  compact: true,
                  onPressed: () => doAct(context, ref, 'fest', [id, 'oui'], () => context.go('/scene/resultat'))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PrimaryButton(label: 'Refuser', style: GameButtonStyle.ghost, compact: true, onPressed: () => doAct(context, ref, 'fest', [id, 'non'], null, 'Invitation déclinée')),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// Bandeau du QG quand des invitations attendent une réponse.
class FestivalNewsCard21 extends StatelessWidget {
  final J s;
  const FestivalNewsCard21(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    final inv = festivalInvites21(s);
    if (inv.isEmpty) return const SizedBox.shrink();
    final f = Reg21.festivals['${inv.first['id']}']!;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GlassCard(
        accent: GlassAccent.gold,
        halo: false,
        onTap: () => context.go('/scene'),
        semanticLabel: 'Invitation au festival ${f['n']}',
        child: Row(children: [
          Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: Tk.tint, borderRadius: BorderRadius.circular(14)), child: const GameIcon('flame', color: Tk.gold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(inv.length > 1 ? '${inv.length} INVITATIONS DE FESTIVAL' : 'INVITATION DE FESTIVAL', style: V20Text.lab(color: V20.hintGoldText)),
              Text('${f['n']} · cachet ${fmt21(f['fee'] as num)} cauris', style: V20Text.nm()),
              Text('Accepte ou refuse depuis la Scène, avant la fin de la semaine.', style: V20Text.bs()),
            ]),
          ),
          const GameIcon('arrow', color: Tk.ink),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-F1 Calendrier des festivals
// ---------------------------------------------------------------------------------------------------------------------

class FestivalsScreen21 extends ConsumerWidget {
  const FestivalsScreen21({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final day = _n(s['day']), wk = weekOf21(day), yr = yearOf21(day);
    final fi = _m(s['fi']);
    final rows = <(int, String)>[
      for (final id in Reg21.festivalOrder)
        for (final w in (Reg21.festivals[id]!['weeks'] as List)) ((w as num).toInt(), id),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final invites = festivalInvites21(s);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      BackHeader(title: 'Festivals', step: 'An $yr · S$wk', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      for (final i in invites) FestivalInviteCard21(s, '${i['id']}'),
      if (invites.isEmpty) const GameHint(icon: 'info', text: 'Aucune invitation cette semaine. Les promoteurs t’invitent la semaine du festival si ton rang et ta popularité suffisent.'),
      const SizedBox(height: 8),
      Text('CALENDRIER DE L’ANNÉE', style: V20Text.lab()),
      const SizedBox(height: 8),
      for (final r in rows) _FestRow(s, r.$2, r.$1, fi['$yr-${r.$2}-${r.$1}'] as String?, wk),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Calendrier 18.3 ; cachet fixe selon le niveau du festival (R24). Cachets et effets proposés, provisoires.'),
    ]);
  }
}

class _FestRow extends StatelessWidget {
  final J s;
  final String id;
  final int week, now;
  final String? state;
  const _FestRow(this.s, this.id, this.week, this.state, this.now);
  @override
  Widget build(BuildContext context) {
    final f = Reg21.festivals[id]!;
    final rankOk = _n(s['rank']) >= (f['rank'] as num), popOk = _n(s['pop']) >= (f['pop'] as num);
    final (String tag, GameTagStyle st) = switch (state) {
      'joue' => ('Joué', GameTagStyle.ok),
      'refuse' => ('Refusé', GameTagStyle.outline),
      'invite' => (week == now ? 'Invité' : 'Passé', week == now ? GameTagStyle.accent : GameTagStyle.outline),
      _ when week < now => ('Passé', GameTagStyle.outline),
      _ when rankOk && popOk => ('Éligible', GameTagStyle.ok),
      _ => (!rankOk ? 'N${f['rank']}' : 'Pop. ${f['pop']}', GameTagStyle.outline),
    };
    return Opacity(
      opacity: week < now && state == null ? .55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(16), border: Border.all(color: week == now ? Tk.gold : Colors.white.withValues(alpha: .08))),
        child: Row(children: [
          SizedBox(width: 44, child: Column(children: [Text('S$week', style: V20Text.baloo(size: 18, line: 20, color: Tk.gold)), Text('${f['lvl']}'.substring(0, 3).toUpperCase(), style: V20Text.poppins(size: 10, line: 12, color: V20.ink2))])),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${f['n']}', style: V20Text.nm()),
              Text('${f['city']} · ${fmt21(f['cap'] as num)} places · cachet ${fmt21(f['fee'] as num)}', style: V20Text.bs()),
            ]),
          ),
          GameTag(tag, style: st),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-F2 Booking international
// ---------------------------------------------------------------------------------------------------------------------

class BookingScreen21 extends ConsumerStatefulWidget {
  const BookingScreen21({super.key});
  @override
  ConsumerState<BookingScreen21> createState() => _BookingState();
}

class _BookingState extends ConsumerState<BookingScreen21> {
  String _mk = 'tamarel', _fm = 'showcase';

  static const _lockText = {
    'rang': 'Rang N${Reg21.intlRank} requis',
    'delai': 'Une tournée internationale toutes les 4 semaines',
    'audience': 'Notoriété locale insuffisante pour ce format',
    'cash': 'Cash insuffisant pour les frais de voyage',
  };

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final geo = _m(s['geo']);
    final lock = intlLock21(s, _mk, _fm);
    final q = intlQuote21(s, _mk, _fm);
    final f = Reg21.intlFormats[_fm]!;
    final wait = s['intlLast'] == null ? 0 : (Reg21.intlEvery - (_n(s['day']) - _n(s['intlLast']))).clamp(0, 999);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      BackHeader(title: 'Booking international', step: 'N${Reg21.intlRank}', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      const SceneBanner(
        kind: 'call',
        height: 190,
        role: 'AGENCE DE BOOKING · DÉSIRÉ KPAN',
        name: 'Le monde t’attend',
        subtitle: 'Tamarel, Korvane, Aldéra : choisis ton marché et ton format.',
        chars: [BannerChar('desire', mood: 'poised', crop: 'torso', width: 132, left: 214)],
      ),
      const SizedBox(height: 10),
      GlassCard(
        halo: false,
        child: Row(children: [
          const CastAvatar('Désiré Kpan', size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                _n(s['rank']) < Reg21.intlRank
                    ? '« Reviens quand tu seras N${Reg21.intlRank}. À l’étranger, ils veulent des noms qui pèsent. »'
                    : wait > 0
                        ? '« On rentre à peine. Laisse souffler l’équipe : prochain départ dans $wait j. »'
                        : '« Billets, visas, salles : je m’occupe de tout. Toi, tu choisis où tu veux briller. »',
                style: V20Text.poppins(size: 13, line: 18)),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      const Lab21('Marché'),
      for (final e in Reg21.intlMarkets.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            halo: false,
            accent: _mk == e.key ? GlassAccent.magenta : GlassAccent.none,
            onTap: () => setState(() => _mk = e.key),
            semanticLabel: '${e.value['n']}, notoriété ${_n(geo[e.key]).toStringAsFixed(1)}',
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${e.value['n']}', style: V20Text.baloo(size: 18, line: 21)),
                  Text('${e.value['d']}', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
                  const SizedBox(height: 6),
                  MeterBar(value: (_n(geo[e.key]) / 50).clamp(0, 1).toDouble(), tone: MeterTone.cyan, thin: true),
                  const SizedBox(height: 2),
                  Text('Notoriété ${_n(geo[e.key]).toStringAsFixed(1)}', style: V20Text.poppins(size: 11, line: 14, color: Tk.cy)),
                ]),
              ),
              if (_mk == e.key) const GameTag('Choisi', style: GameTagStyle.accent),
            ]),
          ),
        ),
      const SizedBox(height: 6),
      const Lab21('Format'),
      for (final e in Reg21.intlFormats.entries) ...[
        ChoiceCard(
          title: '${e.value['n']} · ${e.value['dates']} dates',
          selected: _fm == e.key,
          locked: _n(geo[_mk]) < (e.value['needGeo'] as num),
          onTap: () => setState(() => _fm = e.key),
          consequences: [
            Consequence(ConsequenceKind.certain, 'Frais de voyage ${fmt21(e.value['cost'] as num)} cauris · ${e.value['h']} h · −${e.value['e']} énergie'),
            Consequence(ConsequenceKind.estimated, 'Cachets ${fmt21(intlQuote21(s, _mk, e.key).fees)} · +${fmt21(intlQuote21(s, _mk, e.key).fans)} fans'),
            if ((e.value['needGeo'] as num) > 0) Consequence(ConsequenceKind.uncertain, 'Notoriété ${e.value['needGeo']} requise sur place'),
          ],
        ),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 8),
      GlassCard(
        halo: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DEVIS', style: V20Text.lab()),
          const SizedBox(height: 6),
          KeyVal('Cachet par date', '${fmt21(q.perDate)} cauris'),
          KeyVal('Cachets (${f['dates']} dates)', '${fmt21(q.fees)} cauris'),
          KeyVal('Frais de voyage', '−${fmt21(f['cost'] as num)} cauris'),
          KeyVal('Solde estimé (avant manager)', '${fmt21(q.fees - (f['cost'] as num))} cauris', color: Tk.gold, bold: true),
        ]),
      ),
      const SizedBox(height: 12),
      if (lock != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: GameHint(icon: 'lock', text: _lockText[lock] ?? 'Indisponible', warn: true)),
      PrimaryGlowButton(
        label: 'Signer le booking',
        sublabel: '${f['n']} à ${Reg21.intlMarkets[_mk]!['n']}',
        onPressed: lock != null ? null : () => doAct(context, ref, 'intl', [_mk, _fm], () => context.go('/scene/resultat')),
      ),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Marchés fictifs (18.0) ; cachet par date selon ta notoriété locale. Formats, frais et effets proposés, provisoires.'),
    ]);
  }
}
