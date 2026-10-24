import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_icon.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'widgets21.dart';

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;

String merchImage21(String id) => 'assets/merch/$id.svg';

/// Condition d'accès d'un article (fans, single sorti, rang), vraie si tout est réuni.
bool merchOpen21(J s, J m) =>
    _n(s['fans']) >= (m['fans'] as num) &&
    (m['singles'] == null || (s['disco'] as List).length >= (m['singles'] as num)) &&
    (m['rank'] == null || rankOf(s) >= (m['rank'] as num));

/// Visuel d'un article : illustration 4:3 qui remplit son cadre.
class MerchPicture21 extends StatelessWidget {
  final String id;
  final bool dim;
  const MerchPicture21(this.id, {super.key, this.dim = false});
  @override
  Widget build(BuildContext context) {
    final img = SvgPicture.asset(merchImage21(id), fit: BoxFit.cover, placeholderBuilder: (_) => const ColoredBox(color: Tk.deep));
    return Semantics(
      label: (Reg21.merch[id]?['n'] as String?) ?? 'Article',
      image: true,
      child: dim ? ColorFiltered(colorFilter: const ColorFilter.mode(Color(0x99140E2B), BlendMode.srcATop), child: img) : img,
    );
  }
}

/// Espace merchandising : production en cours, puis le catalogue en grille (une production à la fois).
class MerchSection21 extends ConsumerWidget {
  final J s;
  const MerchSection21(this.s, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = Reg21.merch.entries.toList();
    final open = items.where((e) => merchOpen21(s, e.value)).length;
    final done = _m(s['merchDone']);
    final running = s['merch'] != null ? _m(s['merch']) : null;
    final sold = done.values.fold<num>(0, (a, b) => a + _n(b)) + (running == null ? 0 : _n(running['tot']));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _MerchHero(s, running, sold, open, items.length, done.length),
      const SizedBox(height: 16),
      Text('CATALOGUE', style: V20Text.lab()),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, c) {
        const gap = 12.0;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(spacing: gap, runSpacing: gap, children: [
          for (final e in items) SizedBox(width: w, child: _MerchTile(s, e.key, e.value, running != null && running['id'] == e.key, done[e.key])),
        ]);
      }),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Une seule production à la fois. Les ventes tombent chaque fin de journée et grimpent avec tes fans (valeurs provisoires).'),
    ]);
  }
}

class _MerchHero extends StatelessWidget {
  final J s;
  final J? running;
  final num sold;
  final int open, total, launched;
  const _MerchHero(this.s, this.running, this.sold, this.open, this.total, this.launched);

  @override
  Widget build(BuildContext context) {
    final r = running;
    final m = r == null ? null : Reg21.merch[r['id']]!;
    // Prochain article à débloquer (le premier encore verrouillé du catalogue).
    final next = Reg21.merch.entries.where((e) => !merchOpen21(s, e.value)).map((e) => e.value).firstOrNull;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        key: const ValueKey('merch-hero'),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A1B52), Tk.s1, Tk.deep])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(r == null ? 'AUCUNE PRODUCTION EN VENTE' : 'EN VENTE MAINTENANT', style: V20Text.lab()),
          const SizedBox(height: 10),
          if (r != null && m != null) ...[
            Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 96, height: 72, child: MerchPicture21(r['id'] as String))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m['n'] as String, style: V20Text.baloo(size: 20, line: 22)),
                  const SizedBox(height: 2),
                  Text('${_n(r['left']).toInt()} jour(s) restant(s)', style: V20Text.bs()),
                  const SizedBox(height: 8),
                  MeterBar(value: 1 - _n(r['left']) / (m['days'] as num), tone: MeterTone.gold),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
          ] else ...[
            Text(
              open == 0 ? 'Sors un single et rassemble tes premiers fans pour lancer ton premier article.' : 'Choisis un article ci-dessous : les ventes arrivent chaque fin de journée.',
              style: V20Text.bs(),
            ),
            const SizedBox(height: 12),
          ],
          Row(children: [
            _MStat('Vendu au total', fmt21(sold), Tk.gold),
            const SizedBox(width: 8),
            _MStat('Productions', '$launched', Tk.ok),
            const SizedBox(width: 8),
            _MStat('Débloqués', '$open / $total', Tk.cy),
          ]),
          if (next != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              const GameIcon('lock', size: 14, color: V20.hintGoldText),
              const SizedBox(width: 6),
              Expanded(child: Text('Prochain : ${next['n']} · ${next['cl']}', style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w600, color: V20.hintGoldText))),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _MStat extends StatelessWidget {
  final String lab, v;
  final Color c;
  const _MStat(this.lab, this.v, this.c);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x1AFFFFFF))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(v, maxLines: 1, style: V20Text.baloo(size: 20, line: 22, color: c))),
            const SizedBox(height: 2),
            Text(lab.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
          ]),
        ),
      );
}

class _MerchTile extends ConsumerWidget {
  final J s;
  final String id;
  final J m;
  final bool running;
  final dynamic done;
  const _MerchTile(this.s, this.id, this.m, this.running, this.done);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = merchOpen21(s, m);
    return Semantics(
      button: true,
      label: '${m['n']}, ${fmt21(m['cost'] as num)} cauris',
      child: GestureDetector(
        key: ValueKey('merch-$id'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _showMerchSheet(context, ref, s, id, m, running, done),
        child: Container(
          decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(18), border: Border.all(color: running ? Tk.ok : Tk.line, width: 2)),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Stack(children: [
              AspectRatio(aspectRatio: 4 / 3, child: MerchPicture21(id, dim: !open && !running)),
              Positioned(
                left: 8,
                top: 8,
                child: running
                    ? const GameTag('En vente', style: GameTagStyle.ok)
                    : done != null
                        ? const GameTag('Écoulé')
                        : (open ? const SizedBox.shrink() : const GameTag('Verrouillé', style: GameTagStyle.outline)),
              ),
              if (!open && !running) const Positioned(right: 8, top: 8, child: GameIcon('lock', size: 18, color: V20.ink2)),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m['n'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.baloo(size: 16, line: 18)),
                const SizedBox(height: 4),
                Text('${fmt21(m['cost'] as num)} cauris', style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700, color: Tk.gold)),
                Text(open ? '${m['days']} jours de vente' : m['cl'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.bs()),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

Future<void> _showMerchSheet(BuildContext context, WidgetRef ref, J s, String id, J m, bool running, dynamic done) async {
  final open = merchOpen21(s, m);
  final (perDay, total) = merchEstimate21(s, m);
  final cost = (m['cost'] as num).toInt();
  final profit = total - cost;
  final busy = s['merch'] != null;
  final cash = _n(s['cash']) >= cost;
  final yes = await showGameSheet<bool>(
    context,
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .82),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(height: 150, child: MerchPicture21(id))),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Text((m['n'] as String).toUpperCase(), style: V20Text.dm(size: 22))),
        GameTag(m['kind'] as String),
      ]),
      const SizedBox(height: 8),
      KeyVal('Stock à produire', '${fmt21(cost)} cauris', color: Tk.gold),
      KeyVal('Durée de vente', '${m['days']} jours'),
      if (open) ...[
        KeyVal('Ventes estimées par jour', '≈ ${fmt21(perDay)} cauris'),
        KeyVal('Total estimé', '≈ ${fmt21(total)} cauris'),
        KeyVal(profit >= 0 ? 'Bénéfice estimé' : 'Perte estimée', '${profit >= 0 ? '+' : '−'}${fmt21(profit.abs())} cauris', color: profit >= 0 ? Tk.ok : Tk.acc4),
        Conseq21(ConsequenceKind.estimated, 'Calculé avec tes ${fmt21(_n(s['fans']))} fans actuels : ${m['perFan'].toString().replaceAll('.', ',')} × √fans × ${Reg21.merchScale} par jour. Plus tu as de fans, plus ça vend.'),
      ] else
        GameHint(icon: 'lock', text: 'Condition : ${m['cl']}.'),
      if (done != null) KeyVal('Déjà vendu (dernière fois)', '${fmt21(_n(done))} cauris'),
      if (open && busy && !running) const Padding(padding: EdgeInsets.only(top: 6), child: GameHint(icon: 'info', text: 'Attends la fin de la production en cours.')),
      if (open && !busy && !cash) Padding(padding: const EdgeInsets.only(top: 6), child: GameHint(icon: 'info', text: 'Il te manque ${fmt21(cost - _n(s['cash']).toInt())} cauris.')),
      const SizedBox(height: 14),
      PrimaryButton(
        label: running ? 'En vente' : 'Lancer la production',
        sublabel: running ? null : '−${fmt21(cost)} cauris',
        style: open && !busy && cash ? GameButtonStyle.primary : GameButtonStyle.disabled,
        onPressed: () => Navigator.of(ctx).pop(open && !busy && cash),
      ),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Fermer', style: GameButtonStyle.ghost, onPressed: () => Navigator.of(ctx).pop(false)),
    ]))),
  );
  if (yes == true && context.mounted) await doAct(context, ref, 'merch', id, null, '${m['n']} en vente');
}
