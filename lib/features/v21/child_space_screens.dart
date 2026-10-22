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
import '../../core/widgets/portrait.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'shell21.dart';
import 'widgets21.dart';

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;

String _lien(num l) => l >= 85 ? 'Inséparables' : (l >= 60 ? 'Complices' : (l >= 30 ? 'Proches' : 'Distants'));

/// Espace de l'enfant : lien, moments partagés selon l'âge, développement, garde et souvenirs.
/// Un onglet par enfant si le foyer en compte deux. Valeurs provisoires (D-08).
class ParentEnfantScreen extends ConsumerStatefulWidget {
  final int index;
  const ParentEnfantScreen({super.key, this.index = 0});
  @override
  ConsumerState<ParentEnfantScreen> createState() => _ParentEnfantState();
}

class _ParentEnfantState extends ConsumerState<ParentEnfantScreen> {
  late int _i = widget.index;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final kids = (_m(s['fam'])['kids'] as List).map(_m).toList();
    if (kids.isEmpty) {
      return Frame21(children: [
        BackHeader(title: 'Enfant', onBack: () => context.go('/famille')),
        const SizedBox(height: 12),
        const GameHint(icon: 'info', text: 'Aucun enfant au foyer. Les enfants arrivent après le mariage, jamais automatiquement.'),
      ]);
    }
    final i = _i.clamp(0, kids.length - 1);
    final k = kids[i];
    final age = kidAge(s, k);
    final l = _n(k['l']);
    final dev = k['dev'] is Map ? _m(k['dev']) : <String, dynamic>{};
    final mem = k['mem'] is List ? (k['mem'] as List).map(_m).toList() : <J>[];
    final next = (_n(k['born']) + (age + 1) * Reg21.daysPerYear - _n(s['day'])).toInt();
    final gardeCost = kidGardeCost21(k);
    return Frame21(children: [
      BackHeader(title: 'Avec ${k['n']}', onBack: () => context.go('/famille')),
      if (kids.length > 1) ...[
        const SizedBox(height: 12),
        Row(children: [
          for (var j = 0; j < kids.length; j++) ...[
            if (j > 0) const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                key: ValueKey('enfant-onglet-$j'),
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _i = j),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: j == i ? Tk.tint : Tk.s1,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: j == i ? Tk.acc : Tk.line, width: 2),
                  ),
                  child: Text('${kids[j]['n']}', style: V20Text.btt),
                ),
              ),
            ),
          ],
        ]),
      ],
      const SizedBox(height: 12),
      GlassCard(
        key: const ValueKey('enfant-hero'),
        accent: GlassAccent.magenta,
        halo: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Portrait('${k['n']}'[0], size: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${k['n']}'.toUpperCase(), style: V20Text.dm(size: 26)),
                Text('$age an${age > 1 ? 's' : ''} · ${stageOf(age)}', style: V20Text.bs()),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  GameTag(_lien(l)),
                  GameTag(k['garde'] as String, style: GameTagStyle.outline),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Gauge21('Lien', l),
          const SizedBox(height: 8),
          KeyVal('Prochain anniversaire', next <= 1 ? 'demain' : 'dans $next jours'),
          KeyVal('Aujourd’hui', _n(k['today']) == 1 ? 'Moment partagé' : 'Pas encore de moment ensemble',
              color: _n(k['today']) == 1 ? Tk.ok : null),
        ]),
      ),
      const SizedBox(height: 16),
      Text('MOMENTS ENSEMBLE', style: V20Text.lab()),
      const SizedBox(height: 8),
      for (final e in Reg21.kidActs.entries) ...[
        ActionRow(
          title: e.value['n'] as String,
          subtitle: '${e.value['h']} h · −${e.value['e']} énergie · +${e.value['l']} lien'
              '${Reg21.kidDev[e.key] == null ? '' : ' · ${Reg21.kidDevNames[Reg21.kidDev[e.key]!['k']]} +${Reg21.kidDev[e.key]!['v']}'}',
          note: age < (e.value['min'] as num) ? 'À partir de ${e.value['min']} an${(e.value['min'] as num) > 1 ? 's' : ''}' : null,
          disabled: age < (e.value['min'] as num),
          trailing: ActionRow.arrow(disabled: age < (e.value['min'] as num)),
          onTap: () => doAct(context, ref, 'kid', ['$i', e.key]),
        ),
        const SizedBox(height: 8),
      ],
      const Conseq21(ConsequenceKind.certain, 'Chaque moment coûte du temps et de l’énergie : la carrière reste possible le même jour.'),
      const SizedBox(height: 16),
      Text('DÉVELOPPEMENT', style: V20Text.lab()),
      const SizedBox(height: 8),
      GameCard(
        key: const ValueKey('enfant-dev'),
        child: Column(children: [
          for (final d in Reg21.kidDevNames.entries) Gauge21(d.value, _n(dev[d.key])),
          const SizedBox(height: 4),
          const Conseq21(ConsequenceKind.estimated, 'Chaque moment fait progresser une facette ; l’école fait avancer le savoir chaque jour.'),
        ]),
      ),
      const SizedBox(height: 16),
      Text('GARDE', style: V20Text.lab()),
      const SizedBox(height: 8),
      for (final g in Reg21.kidGardes.entries) ...[
        _GardeRow(i, g.key, g.value, k, age),
        const SizedBox(height: 8),
      ],
      Conseq21(ConsequenceKind.certain, 'Charges de ${k['n']} : ${fmt21(Reg21.kidCost + gardeCost)} cauris par jour (foyer ${fmt21(Reg21.kidCost)}${gardeCost > 0 ? ' + garde ${fmt21(gardeCost)}' : ''}).'),
      if (age < 1 && k['garde'] == 'Au foyer')
        const Conseq21(ConsequenceKind.certain, 'Bébé au foyer : −${Reg21.babyMorning} énergie chaque matin. Une nounou t’évite cette fatigue.'),
      const SizedBox(height: 16),
      Text('SOUVENIRS', style: V20Text.lab()),
      const SizedBox(height: 8),
      if (mem.isEmpty)
        const GameHint(icon: 'info', text: 'Aucun souvenir pour l’instant. Les moments partagés et les grandes étapes s’y inscrivent.')
      else
        GameCard(
          key: const ValueKey('enfant-souvenirs'),
          child: Column(children: [for (final m in mem) KeyVal('Jour ${m['d']}', '${m['t']}', bold: false)]),
        ),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Garde, développement et coûts sont des valeurs provisoires (D-08). Portrait provisoire : initiale de l’enfant.'),
    ]);
  }
}

class _GardeRow extends ConsumerWidget {
  final int i, age;
  final String name;
  final J g, k;
  const _GardeRow(this.i, this.name, this.g, this.k, this.age);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = k['garde'] == name;
    final ok = age >= (g['min'] as num) && age <= (g['max'] as num);
    final cost = (g['cost'] as num).toInt();
    return ActionRow(
      key: ValueKey('garde-$name'),
      title: name,
      subtitle: '${cost == 0 ? 'Gratuit' : '${fmt21(cost)} cauris par jour'} · ${g['min']} à ${(g['max'] as num) >= 99 ? '…' : g['max']} ans',
      note: on ? 'Garde actuelle' : (ok ? null : 'Pas pour cet âge'),
      disabled: !ok && !on,
      trailing: on ? const GameTag('Actuelle') : ActionRow.arrow(disabled: !ok),
      onTap: on ? null : () => doAct(context, ref, 'kgarde', ['$i', name], null, 'Garde : $name'),
    );
  }
}
