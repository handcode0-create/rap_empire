import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';

/// Les 10 labels (21-L2) : logo, siège, influence, contrat type, directeur, conditions et avantage ; l'état de l'offre se lit d'un coup d'œil.
/// Données de présentation (ville, profil, influence) : planche 18.1 ; conditions, avantages et contrats : dialogues21.dart.

num _n(dynamic x) => (x ?? 0) as num;

const _order = ['BSR', 'AMG', 'RCD', 'BLG', 'AUB', 'LYR', 'SKP', 'NUG', 'SIC', 'VAG'];

/// code → (ville · profil, influence, directeur, couleur des lettres du logo)
const _dir = <String, (String, int, String, Color)>{
  'BSR': ('Lumbé · Dominant, catalogue large', 94, 'orage', Color(0xFF14102B)),
  'AMG': ('Port-Ambre · Commercial, grand public', 81, 'benedicte', Color(0xFF2B1A05)),
  'RCD': ('Lumbé · Afro-fusion, export', 76, 'kofi', Color(0xFFFFF1F2)),
  'BLG': ('Kôtoro · Trap et drill', 72, 'kre', Color(0xFF3CD6F2)),
  'AUB': ('Mabaya · Nouveaux talents', 48, 'awa', Color(0xFF3A1B52)),
  'LYR': ('Mabaya · Rap technique', 55, 'maze', Color(0xFF14102B)),
  'SKP': ('Ndolo · Production (DJ Kôrô)', 44, 'kore', Color(0xFFF8F7FF)),
  'NUG': ('Ndolo · Indépendant de la rue', 38, 'bakary', Color(0xFF0C0820)),
  'SIC': ('Sélène · Collectif indépendant', 41, 'liv', Color(0xFF14102B)),
  'VAG': ('Port-Ambre · Ex-influent en difficulté', 30, 'marius', Color(0xFF1F1942)),
};

/// Logo d'un label (SVG extrait de la planche). flutter_svg n'affiche pas le texte SVG : les trois lettres sont posées par-dessus.
class LabelLogo21 extends StatelessWidget {
  final String code;
  final double size;
  const LabelLogo21(this.code, {super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Logo $code',
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: size,
          child: Stack(alignment: Alignment.center, children: [
            SvgPicture.asset('assets/svg/logo-$code.svg', width: size, height: size),
            Align(
                alignment: const Alignment(0, .22),
                child: Text(code, style: V20Text.baloo(size: size * 19 / 64, line: size * 19 / 64, color: _dir[code]!.$4))),
          ]),
        ),
      );
}

String _pct(double c) => '${(c * 100).round()} %';

class LabelsAllScreen extends ConsumerWidget {
  const LabelsAllScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final signed = _n(s['signed']) != 0;
    final mine = signed ? (s['label'] ?? 'BSR') as String : null;
    final seen = s['dseen'] as Map, queue = (s['dq'] as List).map((x) => (x as Map)['id']).toSet();
    final dl = s['dlg'] == null ? null : s['dlg'] as Map;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Les 10 labels', step: 'Existant · 18.1', onBack: () => context.go('/business/labels')),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TON CONTRAT', style: V20Text.lab()),
        Text(signed ? lblName21(s) : 'Aucun', style: V20Text.nm()),
        Text(
            'Part : ${signed ? _pct(_n(s['lcut']) == 0 ? Reg21.labelCut : _n(s['lcut']).toDouble()) : '—'} · avantage : ${signed ? perk21[s['lperk']] ?? '—' : '—'}',
            style: V20Text.bs()),
      ])),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Chaque label a son directeur, ses conditions, son offre et sa contre-offre, jouées en dialogue au QG (21.X1). Un seul contrat à la fois : '
              'une fois signé, les autres n’appellent plus. Contrats types : existants (18.1) ; directeurs, conditions et avantages : proposés.'),
      for (final code in _order) ...[
        const SizedBox(height: 12),
        Builder(builder: (context) {
          final id = code == 'BSR' ? 'label' : 'lb_$code';
          final isMine = mine == code;
          final waiting = !isMine && (queue.contains(id) || (dl != null && dl['id'] == id && dl['done'] == null));
          final vue = !isMine && seen[id] != null && !waiting;
          final (tag, style) = isMine
              ? ('Ton label', GameTagStyle.ok)
              : waiting
                  ? ('Offre en attente', GameTagStyle.accent)
                  : vue
                      ? ('Offre vue', GameTagStyle.normal)
                      : signed
                          ? ('Sous contrat ailleurs', GameTagStyle.outline)
                          : ('À venir', GameTagStyle.outline);
          final d = dlg21[id]!;
          final l = lbl21[code];
          final contract = l == null
              ? '${fmt21(Reg21.labelAdvance)} · ${_pct(Reg21.labelCut)} · 6 mois'
              : '${fmt21(l.adv)} · ${_pct(l.cut)}${code == 'SKP' ? ' production' : ''} · ${l.dur}';
          final perk = perk21[l?.perk ?? 'radio'];
          final (place, influence, who, _) = _dir[code]!;
          return GameCard(
            selected: isMine,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                LabelLogo21(code),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    Text(l?.n ?? 'Bakoma Sound Records', style: V20Text.nm()),
                    GameTag(tag, style: style),
                  ]),
                  Text(place, style: V20Text.bs()),
                ])),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Text('Influence', style: V20Text.bs()),
                const SizedBox(width: 8),
                Expanded(child: MeterBar(value: influence / 100)),
                const SizedBox(width: 8),
                Text('$influence', style: V20Text.baloo(size: 18, line: 20)),
              ]),
              const SizedBox(height: 6),
              Text('Contrat type : $contract', style: V20Text.bs(color: Tk.ink)),
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipOval(child: SizedBox.square(dimension: 40, child: _director(who))),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(castn21[who] ?? who, style: V20Text.nm()),
                  Text('Offre si : ${d.cl} · avantage : $perk', style: V20Text.bs()),
                ])),
              ]),
            ]),
          );
        }),
      ],
      const SizedBox(height: 12),
      GameCard(
          child: Row(children: [
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Studios d’enregistrement', style: V20Text.nm()),
          Text('Studio Brume et Studio Kôrô : des studios, pas des labels (D-04)', style: V20Text.bs()),
        ])),
        const GameTag('Existant'),
      ])),
    ]);
  }

  Widget _director(String who) => SvgPicture.asset('assets/svg/portrait-$who-bust.svg', fit: BoxFit.cover, alignment: Alignment.topCenter);
}
