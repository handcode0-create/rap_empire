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
import '../../core/widgets/character_view.dart';
import 'cast21.dart';
import '../../core/widgets/primary_button.dart';
import 'start_screens.dart' show confirmSheet;
import 'widgets21.dart' show doAct;

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

/// Logo d'un label : emblème et sigle dessinés par tools/design/gen_logos.py (assets/logos).
class LabelLogo21 extends StatelessWidget {
  final String code;
  final double size;
  const LabelLogo21(this.code, {super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Logo $code',
        excludeSemantics: true,
        child: SvgPicture.asset('assets/logos/label_$code.svg', width: size, height: size,
            placeholderBuilder: (_) => SizedBox.square(dimension: size), errorBuilder: (_, __, ___) => SizedBox.square(dimension: size)),
      );
}

/// Rupture du contrat de label : feuille de confirmation avec la pénalité chiffrée, puis action du moteur.
Future<void> breakLabelContract21(BuildContext context, WidgetRef ref, J s) async {
  final cost = labelBreakCost21(s), cash = (s['cash'] as num);
  final name = lblName21(s);
  final yes = await confirmSheet(context,
      title: 'Rompre avec $name ?',
      body: 'Pénalité : ${fmt21(cost)} cauris (rachat de l’avance + 20 %). Cash après : ${cash >= cost ? '${fmt21(cash - cost)} cauris' : 'insuffisant, il te manque ${fmt21(cost - cash)} cauris'}. '
          'Relation avec le directeur −${Reg21.labelBreakRel}, popularité −${Reg21.labelBreakPop}. Tu redeviens indépendant ; l’avance déjà reçue reste acquise.',
      action: 'Payer ${fmt21(cost)} cauris et rompre');
  if (!yes || !context.mounted) return;
  await doAct(context, ref, 'lbreak', 'confirm', null, 'Contrat rompu avec $name');
}

bool _meets(J s, String code) {
  final l = lbl21[code];
  return l == null ? _n(s['rep']) >= Reg21.labelRep : l.cond(s);
}

/// Ordre d'affichage : ton label, offres en attente, conditions remplies, puis le reste dans l'ordre du registre.
List<String> _sorted(J s, String? mine, Set<dynamic> queue, Map? dl) {
  int score(String c) {
    final id = c == 'BSR' ? 'label' : 'lb_$c';
    if (mine == c) return 0;
    if (queue.contains(id) || (dl != null && dl['id'] == id && dl['done'] == null)) return 1;
    if (mine == null && _meets(s, c)) return 2;
    return 3;
  }

  final l = [..._order];
  l.sort((a, b) => score(a) != score(b) ? score(a).compareTo(score(b)) : _order.indexOf(a).compareTo(_order.indexOf(b)));
  return l;
}

/// Condition d'une offre : coche verte si elle est remplie, cadenas sinon.
class _CondLine extends StatelessWidget {
  final String label;
  final bool ok, hide;
  const _CondLine({required this.label, required this.ok, required this.hide});
  @override
  Widget build(BuildContext context) => hide
      ? const SizedBox()
      : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.lock_outline_rounded, size: 16, color: ok ? Tk.ok : V20.lockedIcon),
          const SizedBox(width: 6),
          Expanded(child: Text('Offre si : $label', style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w600, color: ok ? V20.okText : V20.ink2))),
        ]);
}

/// Héros de l'espace label : le contrat en cours (logo, directeur, part, avance, avantage) ou l'indépendance.
class _ContractHero extends StatelessWidget {
  final J s;
  final bool signed;
  final String? mine;
  final VoidCallback onBreak;
  const _ContractHero(this.s, {required this.signed, required this.mine, required this.onBreak});

  @override
  Widget build(BuildContext context) {
    if (!signed) {
      return GameCard(
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: V20.cardBorder, width: 2), color: Tk.s2),
            child: const Icon(Icons.flag_rounded, color: Tk.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TON STATUT', style: V20Text.lab()),
              Text('Artiste indépendant', style: V20Text.dm(size: 24, line: 26)),
              Text('Tu gardes tous tes revenus. Un label apporte une avance et des avantages, contre une part de tes écoutes.', style: V20Text.bs()),
            ]),
          ),
        ]),
      );
    }
    final code = mine ?? 'BSR';
    final l = lbl21[code];
    final who = l?.who ?? 'orage';
    final cut = _n(s['lcut']) == 0 ? Reg21.labelCut : _n(s['lcut']).toDouble();
    final adv = _n(s['ladv']) > 0 ? _n(s['ladv']) : (l?.adv ?? Reg21.labelAdvance);
    Widget kpi(String label, String value, Color c) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(color: Tk.s2, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm(color: c)),
              const SizedBox(height: 2),
              Text(label.toUpperCase(), textAlign: TextAlign.center, style: V20Text.poppins(size: 10, line: 12, weight: FontWeight.w700, color: V20.ink2, spacing: .4)),
            ]),
          ),
        );
    return GameCard(
      selected: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          LabelLogo21(code, size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SOUS CONTRAT', style: V20Text.lab(color: V20.accText)),
              Text(lblName21(s), style: V20Text.dm(size: 22, line: 24)),
              const SizedBox(height: 4),
              Row(children: [
                ClipOval(child: SizedBox.square(dimension: 28, child: castIllustrated21.contains(who) ? CharacterView(who: who, mood: 'poised', crop: 'head') : const SizedBox())),
                const SizedBox(width: 8),
                Expanded(child: Text(castn21[who] ?? who, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.bs(color: Tk.ink))),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          kpi('part du label', _pct(cut), Tk.acc4),
          const SizedBox(width: 8),
          kpi('avance reçue', fmt21(adv), Tk.gold),
          const SizedBox(width: 8),
          kpi('avantage', perk21[s['lperk']] ?? '—', Tk.cy),
        ]),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Rompre le contrat',
          sublabel: 'Pénalité ${fmt21(labelBreakCost21(s))} cauris',
          style: GameButtonStyle.secondary,
          compact: true,
          onPressed: onBreak,
        ),
      ]),
    );
  }
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
      _ContractHero(s, signed: signed, mine: mine, onBreak: () => breakLabelContract21(context, ref, s)),
      if (!signed) ...[
        const SizedBox(height: 12),
        LabelInterestCard(s),
      ],
      if (queue.any((x) => x.toString().startsWith('lb_') || x == 'label')) ...[
        const SizedBox(height: 12),
        GameCard(
          selected: true,
          child: Row(children: [
            const Icon(Icons.mail_rounded, color: Tk.acc4),
            const SizedBox(width: 12),
            Expanded(child: Text('Une offre de label t’attend : elle s’ouvre en dialogue depuis le QG.', style: V20Text.poppins(size: 13, line: 18, weight: FontWeight.w600))),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Chaque label a son directeur, ses conditions, son offre et sa contre-offre, jouées en dialogue au QG (21.X1). Un seul contrat à la fois : '
              'une fois signé, les autres n’appellent plus. Contrats types : existants (18.1) ; directeurs, conditions et avantages : proposés.'),
      for (final code in _sorted(s, mine, queue, dl)) ...[
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
                  Text('Avantage : $perk', style: V20Text.bs()),
                ])),
              ]),
              const SizedBox(height: 8),
              _CondLine(label: d.cl, ok: !isMine && _meets(s, code), hide: isMine),
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

  Widget _director(String who) => castIllustrated21.contains(who)
      ? CharacterView(who: who, mood: 'poised', crop: 'head')
      : SvgPicture.asset('assets/svg/portrait-$who-bust.svg', fit: BoxFit.cover, alignment: Alignment.topCenter);
}


/// Intérêt des labels : la jauge à remplir avant la première offre, et ce qui la fait monter.
class LabelInterestCard extends StatelessWidget {
  final J s;
  const LabelInterestCard(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    final v = _n(s['lbz']).toInt();
    final ready = labelReady21(s);
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('INTÉRÊT DES LABELS', style: V20Text.lab())),
          GameTag(ready ? 'Les offres peuvent arriver' : 'Fais tes preuves', style: ready ? GameTagStyle.ok : GameTagStyle.outline),
        ]),
        const SizedBox(height: 4),
        Text('${v.clamp(0, Reg21.lbzGate)} / ${Reg21.lbzGate}', style: V20Text.baloo(size: 28, line: 30, color: ready ? Tk.ok : Tk.ink)),
        const SizedBox(height: 6),
        MeterBar(value: (v / Reg21.lbzGate).clamp(0, 1).toDouble(), tone: ready ? MeterTone.ok : MeterTone.gold),
        const SizedBox(height: 8),
        Text(
            ready
                ? 'Les labels te suivent. Chaque offre a aussi sa propre condition (réputation, style, ville).'
                : 'Aucun label ne signe un inconnu. Single +${Reg21.lbzSingle} (+${Reg21.lbzGoodSingle} si qualité 70) · EP ou album +${Reg21.lbzProject} · date sur scène +${Reg21.lbzShow} · publication virale +${Reg21.lbzViral}.',
            style: V20Text.bs()),
      ]),
    );
  }
}
