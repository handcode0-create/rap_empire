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
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'cast21.dart';
import 'start_screens.dart' show confirmSheet;
import 'widgets21.dart';

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;
String _signed(int v) => '${v >= 0 ? '+' : '−'}${fmt21(v.abs())}';

/// Espace d'un artiste signé : demande de sortie à trancher, sortie en cours, statistiques complètes
/// (fans, écoutes, revenus par source, évolution), discographie et contrat. Valeurs provisoires (D-08).
class ArtistSpaceScreen extends ConsumerWidget {
  final String id;
  const ArtistSpaceScreen(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final ol = s['olabel'] is Map ? _m(s['olabel']) : null;
    final found = ol == null ? <dynamic>[] : (ol['roster'] as List).where((x) => (x as Map)['id'] == id).toList();
    if (found.isEmpty) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Artiste', onBack: () => context.go('/business/mon-label')),
        const SizedBox(height: 16),
        const GameHint(icon: 'info', text: 'Cet artiste ne fait plus partie de ton label.'),
      ]);
    }
    final a = _m(found.first);
    final staff = ol!['staff'];
    final day = labelArtistDay21(a, staff);
    final tot = _m(a['tot']);
    final earned = (_n(tot['s']) + _n(tot['c']) + _n(tot['m']) - _n(tot['f'])).toInt();
    final rel = a['rel'] is List ? (a['rel'] as List).map((x) => x as J).toList() : <J>[];
    final ser = a['ser'] is List ? (a['ser'] as List).map((x) => x as J).toList() : <J>[];
    final boost = a['boost'] is Map ? _m(a['boost']) : null;
    final mood = labelMood21(a).toDouble();
    final age = (_n(s['day']) - _n(a['since'])).toInt();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Espace artiste', onBack: () => context.go('/business/mon-label')),
      const SizedBox(height: 12),
      _Hero(a, mood),
      if (a['note'] is String) ...[const SizedBox(height: 10), GameHint(icon: 'info', text: a['note'] as String)],
      const SizedBox(height: 16),
      if (a['req'] is Map) ...[
        Text('DEMANDE DE SORTIE', style: V20Text.lab()),
        const SizedBox(height: 8),
        _RequestCard(s, a, _m(a['req'])),
      ] else if (boost != null) ...[
        Text('SORTIE EN COURS', style: V20Text.lab()),
        const SizedBox(height: 8),
        _BoostCard(a, boost, rel.isEmpty ? null : rel.first),
      ] else ...[
        Text('COMMANDER UNE SORTIE', style: V20Text.lab()),
        const SizedBox(height: 8),
        _OrderCard(s, a),
      ],
      const SizedBox(height: 16),
      Text('STATISTIQUES', style: V20Text.lab()),
      const SizedBox(height: 8),
      Row(children: [
        _Kpi('Fans', fmt21(_n(a['fans'])), Tk.cy),
        const SizedBox(width: 8),
        _Kpi('Écoutes 7 j', fmt21(_n(a['eco'])), Tk.gold),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        _Kpi('Net par jour', _signed(day['net']!), day['net']! >= 0 ? Tk.ok : Tk.acc4),
        const SizedBox(width: 8),
        _Kpi('Encaissé', _signed(earned), earned >= 0 ? Tk.ok : Tk.acc4),
      ]),
      const SizedBox(height: 12),
      GameCard(
        key: const ValueKey('artiste-sources'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('REVENUS PAR SOURCE · DEPUIS LA SIGNATURE', style: V20Text.lab()),
          const SizedBox(height: 8),
          _Source('Streams', _n(tot['s']), _n(tot['s']) + _n(tot['c']) + _n(tot['m']), Tk.cy, MeterTone.cyan),
          _Source('Concerts', _n(tot['c']), _n(tot['s']) + _n(tot['c']) + _n(tot['m']), Tk.gold, MeterTone.gold),
          _Source('Merch', _n(tot['m']), _n(tot['s']) + _n(tot['c']) + _n(tot['m']), Tk.ok, MeterTone.ok),
          KeyVal('Frais de promo et de studio', _signed(-_n(tot['f']).toInt()), color: Tk.acc4),
          const SizedBox(height: 4),
          const Conseq21(ConsequenceKind.estimated, 'Part de ton label sur chaque revenu ; le net par jour est une moyenne, les ventes réelles tombent chaque fin de journée.'),
        ]),
      ),
      const SizedBox(height: 12),
      GameCard(
        key: const ValueKey('artiste-evolution'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ÉVOLUTION · ÉCOUTES 7 J', style: V20Text.lab()),
          const SizedBox(height: 8),
          SizedBox(height: 70, width: double.infinity, child: CustomPaint(painter: _SparkPainter([for (final p in ser) _n(p['e']).toDouble()]))),
          const SizedBox(height: 6),
          if (ser.length >= 2)
            KeyVal('Depuis la signature', '${_pct(_n(ser.first['e']), _n(a['eco']))} écoutes · ${_pct(_n(ser.first['f']), _n(a['fans']))} fans',
                color: _n(a['eco']) >= _n(ser.first['e']) ? Tk.ok : Tk.acc4)
          else
            Text('Le premier point de la courbe arrive après une semaine au label.', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 16),
      Text('DISCOGRAPHIE · ${rel.length} SORTIE${rel.length > 1 ? 'S' : ''}', style: V20Text.lab()),
      const SizedBox(height: 8),
      if (rel.isEmpty)
        const GameHint(icon: 'info', text: 'Aucune sortie avec ton label pour l’instant. L’artiste fera sa première demande bientôt.')
      else
        for (final r in rel) ...[_ReleaseRow(r), const SizedBox(height: 8)],
      const SizedBox(height: 8),
      Text('CONTRAT', style: V20Text.lab()),
      const SizedBox(height: 8),
      GameCard(
        child: Column(children: [
          KeyVal('Palier', a['palier'] as String),
          KeyVal('Part de ton label', '${(_n(a['cut']) * 100).round()} %'),
          KeyVal('Avance versée', '${fmt21(_n(a['adv']))} cauris'),
          KeyVal('Frais par jour', _signed(day['f']!), color: Tk.acc4),
          KeyVal('Au label depuis', '$age jour${age > 1 ? 's' : ''}'),
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
              if (yes && context.mounted) await doAct(context, ref, 'lrelart', a['id'], () => context.go('/business/mon-label'), '${a['nom']} a quitté ton label');
            },
          ),
        ]),
      ),
      const SizedBox(height: 8),
      const GameHint(icon: 'info', text: 'Budgets, gains d’écoutes et humeur de l’artiste sont des valeurs provisoires (D-08).'),
    ]);
  }
}

String _pct(num from, num to) {
  if (from <= 0) return '—';
  final p = ((to - from) / from * 100).round();
  return '${p >= 0 ? '+' : '−'}${p.abs()} %';
}

class _Hero extends StatelessWidget {
  final J a;
  final double mood;
  const _Hero(this.a, this.mood);
  @override
  Widget build(BuildContext context) {
    final label = mood >= 75 ? 'Très motivé' : (mood >= 45 ? 'Confiant' : (mood >= 25 ? 'Tendu' : 'Prêt à partir'));
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        key: const ValueKey('artiste-hero'),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A1B52), Tk.s1, Tk.deep])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            CastAvatar(a['nom'] as String, size: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((a['nom'] as String).toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.dm(size: 26)),
                Text('${a['genre']} · ${a['ville']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.bs()),
                const SizedBox(height: 6),
                GameTag(a['palier'] as String),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Text('HUMEUR', style: V20Text.lab()),
            const Spacer(),
            Text('$label · ${mood.round()} / 100', style: V20Text.bs(color: Tk.ink)),
          ]),
          const SizedBox(height: 6),
          MeterBar(value: mood / 100, tone: mood >= 45 ? MeterTone.ok : MeterTone.gold, thin: true),
        ]),
      ),
    );
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
          decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(16), border: Border.all(color: Tk.line, width: 2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(v, maxLines: 1, style: V20Text.baloo(size: 24, line: 26, color: c))),
            const SizedBox(height: 2),
            Text(lab.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
          ]),
        ),
      );
}

class _Source extends StatelessWidget {
  final String name;
  final num v, total;
  final Color c;
  final MeterTone tone;
  const _Source(this.name, this.v, this.total, this.c, this.tone);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(children: [
          KeyVal(name, _signed(v.toInt()), color: c),
          MeterBar(value: total <= 0 ? 0 : (v / total).clamp(0, 1).toDouble(), tone: tone, thin: true),
        ]),
      );
}

class _SparkPainter extends CustomPainter {
  final List<double> pts;
  _SparkPainter(this.pts);
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = Tk.line..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1), base);
    if (pts.isEmpty) return;
    final lo = pts.reduce((x, y) => x < y ? x : y), hi = pts.reduce((x, y) => x > y ? x : y);
    final span = (hi - lo) == 0 ? 1.0 : hi - lo;
    Offset at(int i) => Offset(pts.length == 1 ? size.width / 2 : i * size.width / (pts.length - 1), size.height - 8 - (pts[i] - lo) / span * (size.height - 16));
    final line = Paint()..color = Tk.cy..strokeWidth = 3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(path, line);
    canvas.drawCircle(at(pts.length - 1), 5, Paint()..color = Tk.gold);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.pts.length != pts.length || (pts.isNotEmpty && old.pts.last != pts.last);
}

class _ReleaseRow extends StatelessWidget {
  final J r;
  const _ReleaseRow(this.r);
  @override
  Widget build(BuildContext context) {
    final cost = _n(r['cost']).toInt(), rev = _n(r['rev']).toInt();
    return GameCard(
      key: ValueKey('sortie-${r['day']}-${r['kind']}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GameTag(Reg21.relKinds[r['kind']]!['n'] as String),
          const SizedBox(width: 8),
          Expanded(child: Text(r['titre'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm())),
          Text('Jour ${r['day']}', style: V20Text.bs()),
        ]),
        const SizedBox(height: 6),
        KeyVal('Qualité', '${r['q']} / 100'),
        KeyVal('Budget', '${fmt21(cost)} cauris'),
        KeyVal('Streams supplémentaires (part du label)', _signed(rev), color: rev >= cost ? Tk.ok : Tk.cy),
        KeyVal('Fans gagnés', '+${fmt21(_n(r['fans']))}'),
      ]),
    );
  }
}

class _BoostCard extends StatelessWidget {
  final J a, boost;
  final J? last;
  const _BoostCard(this.a, this.boost, this.last);
  @override
  Widget build(BuildContext context) {
    final extra = jsRound(_n(a['eco']) / 7 * Reg21.lbStream * _n(a['cut']) * _n(boost['m']));
    return GameCard(
      key: const ValueKey('artiste-boost'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(last == null ? 'Sortie en cours' : '« ${last!['titre']} »', style: V20Text.nm()),
        const SizedBox(height: 6),
        KeyVal('Écoutes en hausse', '+${(_n(boost['m']) * 100).round()} %', color: Tk.cy),
        KeyVal('Encore', '${boost['d']} jour${_n(boost['d']) > 1 ? 's' : ''}'),
        KeyVal('Gain pour ton label', '≈ ${_signed(extra)} / jour', color: Tk.gold),
        const Conseq21(ConsequenceKind.estimated, 'Une nouvelle demande n’arrive qu’une fois la sortie terminée.'),
      ]),
    );
  }
}

/// Le joueur déclenche lui-même une sortie quand l'artiste n'en demande pas.
class _OrderCard extends ConsumerWidget {
  final J s, a;
  const _OrderCard(this.s, this.a);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = _m(s['olabel'])['staff'];
    final waits = _n(a['nxt']) - _n(s['day']);
    return GameCard(
      key: const ValueKey('artiste-commande'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(waits > 0 ? 'Prochaine demande de l’artiste dans $waits jour${waits > 1 ? 's' : ''}. Tu peux aussi lancer une sortie toi-même.' : 'L’artiste prépare sa prochaine demande. Tu peux aussi lancer une sortie toi-même.', style: V20Text.bs()),
        const SizedBox(height: 10),
        for (final k in Reg21.relKinds.keys) ...[
          _launch(context, ref, k, labelRelCost21(a, k, staff)),
          const SizedBox(height: 8),
        ],
      ]),
    );
  }

  Widget _launch(BuildContext context, WidgetRef ref, String k, int cost) {
    final kd = Reg21.relKinds[k]!;
    final enough = _n(s['cash']) >= cost;
    return PrimaryButton(
      key: ValueKey('commande-$k'),
      label: 'Lancer un ${(kd['n'] as String).toLowerCase()}',
      sublabel: '${fmt21(cost)} cauris · qualité ≈ ${labelRelQuality21(a)}',
      compact: true,
      style: enough ? GameButtonStyle.secondary : GameButtonStyle.disabled,
      onPressed: () async {
        if (!enough) return toastErr(context, 'cash');
        if (cost >= 15000) {
          final yes = await confirmSheet(context,
              title: 'Lancer un ${(kd['n'] as String).toLowerCase()} ?',
              body: 'Budget de ${fmt21(cost)} cauris pour ${a['nom']}. Cash après : ${fmt21(_n(s['cash']) - cost)} cauris.',
              action: 'Payer ${fmt21(cost)} cauris');
          if (!yes || !context.mounted) return;
        }
        await doAct(context, ref, 'lrelease', {'id': a['id'], 'kind': k}, null, 'Sortie lancée');
      },
    );
  }
}

/// Demande de sortie : trois réponses, conséquences visibles avant de répondre (Certain / Estimé / Risque).
class _RequestCard extends ConsumerWidget {
  final J s, a, req;
  const _RequestCard(this.s, this.a, this.req);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = req['kind'] as String;
    final kd = Reg21.relKinds[kind]!;
    final staff = _m(s['olabel'])['staff'];
    final cost = labelRelCost21(a, kind, staff), costN = labelRelCost21(a, kind, staff, true);
    final q = labelRelQuality21(a), qN = labelRelQuality21(a, true);
    final left = Reg21.relExpire - (_n(s['day']) - _n(req['day'])).toInt();
    final enough = _n(s['cash']) >= cost;
    final fans = jsRound(_n(a['fans']) * (kd['fans'] as num) * q / 70);
    final gain = ((kd['boost'] as num) * (0.5 + q / 100) * 100).round();
    return GameCard(
      key: const ValueKey('artiste-demande'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GameTag(kd['n'] as String),
          const SizedBox(width: 8),
          Expanded(child: Text('« ${req['titre']} »', maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.nm())),
        ]),
        const SizedBox(height: 6),
        Text('${a['nom']} veut sortir un ${(kd['n'] as String).toLowerCase()} avec ton label. Réponse attendue sous $left jour${left > 1 ? 's' : ''}, sinon il se lasse.', style: V20Text.bs()),
        const SizedBox(height: 10),
        Conseq21(ConsequenceKind.certain, 'Accepter : budget ${fmt21(cost)} cauris, humeur +${Reg21.moodAccept}'),
        Conseq21(ConsequenceKind.estimated, 'Qualité ≈ $q · écoutes ≈ +$gain % pendant ${kd['days']} jours · fans ≈ +${fmt21(fans)}'),
        Conseq21(ConsequenceKind.certain, 'Négocier : budget réduit à ${fmt21(costN)} cauris (−${(Reg21.relNegoCut * 100).round()} %), qualité ≈ $qN'),
        Conseq21(ConsequenceKind.risk, 'Risque ${labelNegoRisk21(a)} : l’artiste peut refuser et retirer sa demande (humeur −${Reg21.moodFail})'),
        const Conseq21(ConsequenceKind.certain, 'Refuser : humeur −${Reg21.moodDecline}, nouvelle demande dans 14 jours'),
        const SizedBox(height: 10),
        PrimaryButton(
          key: const ValueKey('demande-accepter'),
          label: 'Accepter la sortie',
          sublabel: '${fmt21(cost)} cauris',
          style: enough ? GameButtonStyle.primary : GameButtonStyle.disabled,
          onPressed: () => _reply(context, ref, 'accept', cost, enough),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: PrimaryButton(
              key: const ValueKey('demande-negocier'),
              label: 'Négocier',
              compact: true,
              style: _n(s['cash']) >= costN ? GameButtonStyle.secondary : GameButtonStyle.disabled,
              onPressed: () => _reply(context, ref, 'negotiate', costN, _n(s['cash']) >= costN),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryButton(
              key: const ValueKey('demande-refuser'),
              label: 'Refuser',
              compact: true,
              style: GameButtonStyle.secondary,
              onPressed: () => _reply(context, ref, 'decline', 0, true),
            ),
          ),
        ]),
      ]),
    );
  }

  Future<void> _reply(BuildContext context, WidgetRef ref, String ch, int cost, bool enough) async {
    if (!enough) return toastErr(context, 'cash');
    if (cost >= 15000) {
      final yes = await confirmSheet(context,
          title: ch == 'accept' ? 'Accepter la sortie ?' : 'Négocier le budget ?',
          body: 'Budget de ${fmt21(cost)} cauris pour « ${req['titre']} ». Cash après : ${fmt21(_n(s['cash']) - cost)} cauris.',
          action: 'Payer ${fmt21(cost)} cauris');
      if (!yes || !context.mounted) return;
    }
    await doAct(context, ref, 'lreply', {'id': a['id'], 'ch': ch}, null, ch == 'decline' ? 'Demande refusée' : 'Réponse envoyée');
  }
}
