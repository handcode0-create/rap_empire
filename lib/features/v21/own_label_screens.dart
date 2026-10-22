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
import '../../core/widgets/primary_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'cast21.dart';
import 'start_screens.dart' show confirmSheet;
import 'widgets21.dart';

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;

String _signed(int v) => '${v >= 0 ? '+' : '−'}${fmt21(v.abs())}';

/// Ton label : écurie d'artistes signés, revenus par source (streams, concerts, merch, frais), libération d'un artiste.
/// Fondation dès le rang N4 ; signature depuis l'annuaire des artistes. Valeurs provisoires (D-08).
class OwnLabelScreen extends ConsumerWidget {
  const OwnLabelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final ol = s['olabel'] == null ? null : _m(s['olabel']);
    if (ol == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Ton label', onBack: () => context.go('/business/labels')),
        const SizedBox(height: 16),
        const GameHint(icon: 'lock', text: 'Fonde ton label dès le rang N4 depuis « Merchandising et label ».'),
      ]);
    }
    final roster = (ol['roster'] as List).map((x) => x as J).toList();
    final slots = labelSlots21(s);
    final staff = ol['staff'];
    final days = [for (final a in roster) labelArtistDay21(a, staff)];
    int sum(String k) => days.fold<int>(0, (t, d) => t + d[k]!);
    final wage = labelMods21(staff)['wage']!.toInt();
    final net = sum('net') - wage;
    final tot = _m(ol['tot']);
    final earned = (_n(tot['s']) + _n(tot['c']) + _n(tot['m']) - _n(tot['f'])).toInt();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Ton label', onBack: () => context.go('/business/labels')),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          key: const ValueKey('own-label-hero'),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A1B52), Tk.s1, Tk.deep])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('REVENU NET ESTIMÉ PAR JOUR', style: V20Text.lab()),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(_signed(net), style: V20Text.baloo(size: 40, line: 42, color: net >= 0 ? Tk.gold : Tk.acc4)))),
              const SizedBox(width: 8),
              Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('cauris', style: V20Text.bs())),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _Kpi('Écurie', '${roster.length} / $slots', Tk.cy),
              const SizedBox(width: 8),
              _Kpi('Encaissé', _signed(earned), earned >= 0 ? Tk.ok : Tk.acc4),
            ]),
          ]),
        ),
      ),
      if (roster.isNotEmpty || wage > 0) ...[
        const SizedBox(height: 16),
        Text('SOURCES DE REVENUS · PAR JOUR', style: V20Text.lab()),
        const SizedBox(height: 8),
        GameCard(
          child: Column(children: [
            KeyVal('Streams', _signed(sum('s')), color: Tk.cy),
            KeyVal('Concerts', _signed(sum('c')), color: Tk.gold),
            KeyVal('Merch', _signed(sum('m')), color: Tk.ok),
            KeyVal('Frais de promo et de studio', _signed(sum('f')), color: Tk.acc4),
            if (wage > 0) KeyVal('Salaires de l’équipe', _signed(-wage), color: Tk.acc4),
            const Conseq21(ConsequenceKind.estimated, 'Part du label sur chaque revenu ; le concert est lissé sur ${Reg21.lbConcertEvery} jours. Les ventes réelles tombent chaque fin de journée.'),
          ]),
        ),
      ],
      const SizedBox(height: 16),
      Text('ÉCURIE', style: V20Text.lab()),
      const SizedBox(height: 8),
      if (roster.isEmpty)
        const GameHint(icon: 'info', text: 'Aucun artiste signé : ton label ne rapporte rien. Choisis un talent dans l’annuaire et signe-le.')
      else
        for (var i = 0; i < roster.length; i++) ...[_ArtistCard(roster[i], days[i]), const SizedBox(height: 10)],
      const SizedBox(height: 4),
      PrimaryButton(
        label: 'Signer un artiste',
        sublabel: slots - roster.length > 0 ? '${slots - roster.length} place(s) libre(s)' : 'Écurie pleine',
        style: slots - roster.length > 0 ? GameButtonStyle.primary : GameButtonStyle.disabled,
        onPressed: () => slots - roster.length > 0 ? context.go('/scene/rivalites') : toastErr(context, 'ecurie'),
      ),
      const SizedBox(height: 20),
      Text('ÉQUIPE', style: V20Text.lab()),
      const SizedBox(height: 8),
      for (final role in Reg21.staffRoles.keys) ...[_RoleCard(s, role, roster), const SizedBox(height: 10)],
      const SizedBox(height: 2),
      const GameHint(icon: 'info', text: 'Un poste de chaque. Embauche et licenciement coûtent ${Reg21.staffFeeDays} jours de salaire ; les profils confirmés demandent le rang N5. Valeurs provisoires.'),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Les places montent avec ton rang (N4 : 3, N5 : 5, N6 : 8). Les talents plus établis demandent un rang plus haut. Valeurs provisoires.'),
    ]);
  }
}

class _Kpi extends StatelessWidget {
  final String lab, v;
  final Color c;
  const _Kpi(this.lab, this.v, this.c);
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

class _ArtistCard extends ConsumerWidget {
  final J a;
  final Map<String, int> day;
  const _ArtistCard(this.a, this.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tot = _m(a['tot']);
    final earned = (_n(tot['s']) + _n(tot['c']) + _n(tot['m']) - _n(tot['f'])).toInt();
    return GameCard(
      key: ValueKey('ecurie-${a['id']}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CastAvatar(a['nom'] as String, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a['nom'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
              Text('${a['genre']} · ${a['ville']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.bs()),
            ]),
          ),
          GameTag(a['palier'] as String),
        ]),
        const SizedBox(height: 8),
        KeyVal('Fans · écoutes 7 j', '${fmt21(_n(a['fans']))} · ${fmt21(_n(a['eco']))}'),
        KeyVal('Part de ton label', '${(_n(a['cut']) * 100).round()} %'),
        KeyVal('Net par jour (estimé)', _signed(day['net']!), color: day['net']! >= 0 ? Tk.ok : Tk.acc4),
        KeyVal('Encaissé depuis la signature', _signed(earned)),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Libérer l’artiste',
          compact: true,
          style: GameButtonStyle.secondary,
          onPressed: () async {
            final yes = await confirmSheet(context,
                title: 'Libérer ${a['nom']} ?',
                body: 'Il quitte ton label tout de suite. L’avance de ${fmt21(_n(a['adv']))} cauris n’est pas remboursée et la place se libère.',
                action: 'Libérer');
            if (yes && context.mounted) await doAct(context, ref, 'lrelart', a['id'], null, '${a['nom']} a quitté ton label');
          },
        ),
      ]),
    );
  }
}

String _effect(J p) {
  final v = ((p['v'] as num) * 100).round();
  return switch (p['role']) {
    'ar' => '−$v % sur les avances de signature',
    'mkt' => '+$v % sur les streams',
    'book' => '+$v % sur les concerts',
    'merch' => '+$v % sur le merch',
    _ => '−$v % sur les frais de promo et de studio',
  };
}

/// Un poste de l'équipe : le profil embauché (licenciable) ou les deux candidats, avec le gain net estimé salaire compris.
class _RoleCard extends ConsumerWidget {
  final J s;
  final String role;
  final List<J> roster;
  const _RoleCard(this.s, this.role, this.roster);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Reg21.staffRoles[role]!;
    final staff = (s['olabel'] as J)['staff'] is Map ? Map<String, dynamic>.from((s['olabel'] as J)['staff'] as Map) : <String, dynamic>{};
    final hiredId = staff[role] as String?;
    int netWith(Map<String, dynamic> st) => roster.fold<int>(0, (t, a) => t + labelArtistDay21(a, st)['net']!) - labelMods21(st)['wage']!.toInt();
    final now = netWith(staff);
    final rank = _n(s['rank']);
    final candidates = Reg21.staffProfiles.entries.where((e) => e.value['role'] == role).toList();
    return GameCard(
      key: ValueKey('poste-$role'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(r['n'] as String, style: V20Text.nm())),
          hiredId != null ? const GameTag('Pourvu', style: GameTagStyle.ok) : const GameTag('Vacant', style: GameTagStyle.outline),
        ]),
        Text('Agit sur : ${(r['eff'] as String).toLowerCase()}', style: V20Text.bs()),
        const SizedBox(height: 8),
        for (final e in candidates)
          if (hiredId == null || hiredId == e.key) ...[
            Builder(builder: (context) {
              final p = e.value;
              final hired = hiredId == e.key;
              final fee = ((p['sal'] as num) * Reg21.staffFeeDays).toInt();
              final locked = rank < (p['rank'] as num);
              final gain = netWith({...staff, role: e.key}) - now;
              final canPay = _n(s['cash']) >= fee;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  key: ValueKey('profil-${e.key}'),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Tk.s2, borderRadius: BorderRadius.circular(14)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CastAvatar(p['n'] as String, size: 48),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p['n'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm().copyWith(fontSize: 16)),
                          Text('${p['lvl'] == 1 ? 'Junior' : 'Confirmé'} · ${fmt21(p['sal'] as num)} cauris par jour', style: V20Text.bs().copyWith(fontSize: 12)),
                        ]),
                      ),
                      if (locked) const GameTag('N5', style: GameTagStyle.outline),
                    ]),
                    const SizedBox(height: 6),
                    Text(_effect(p), style: V20Text.poppins(size: 13, line: 18, weight: FontWeight.w600, color: Tk.ink)),
                    if (role != 'ar')
                      Conseq21(ConsequenceKind.estimated, hired
                          ? 'Net actuel de ton label : ${_signed(now)} par jour, salaire compris.'
                          : 'Net estimé avec lui : ${_signed(now + gain)} par jour (${gain >= 0 ? '+' : '−'}${fmt21(gain.abs())}), salaire compris.')
                    else
                      const Conseq21(ConsequenceKind.certain, 'La remise s’applique à chaque nouvelle signature.'),
                    const SizedBox(height: 6),
                    PrimaryButton(
                      label: hired ? 'Licencier' : 'Embaucher',
                      sublabel: '−${fmt21(fee)} cauris',
                      compact: true,
                      style: hired ? GameButtonStyle.secondary : (!locked && canPay ? GameButtonStyle.primary : GameButtonStyle.disabled),
                      onPressed: () async {
                        if (!hired && locked) return toastErr(context, 'rang');
                        final yes = await confirmSheet(context,
                            title: hired ? 'Licencier ${p['n']} ?' : 'Embaucher ${p['n']} ?',
                            body: hired
                                ? 'Il quitte ton label. Indemnité : ${fmt21(fee)} cauris (${Reg21.staffFeeDays} jours de salaire). Le poste redevient vacant.'
                                : 'Frais d’embauche : ${fmt21(fee)} cauris (${Reg21.staffFeeDays} jours de salaire), puis ${fmt21(p['sal'] as num)} cauris par jour. ${_effect(p)}.',
                            action: hired ? 'Licencier' : 'Embaucher');
                        if (!yes || !context.mounted) return;
                        await (hired ? doAct(context, ref, 'lfire', role, null, '${p['n']} a quitté ton label') : doAct(context, ref, 'lhire', e.key, null, '${p['n']} rejoint ton label'));
                      },
                    ),
                  ]),
                ),
              );
            }),
          ],
      ]),
    );
  }
}
