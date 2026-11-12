import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/character_view.dart';
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

/// Espace manager : qui travaille avec toi, ce que ça coûte, ce qu'il faut pour monter d'un cran, et les six profils.
/// Les barèmes viennent de Reg21.managerTiers ; les libellés de niveau et de spécialité de la planche 19.1 (proposés).

const _tierNames = {'m1': 'Débutant', 'm2': 'Local', 'm3': 'Confirmé', 'm4': 'National', 'm5': 'International', 'm6': 'Élite'};
const _tierFocus = {
  'm1': 'Conseils simples · négociation de cachet',
  'm2': 'Showcases, petits concerts, offres locales',
  'm3': 'Featurings · festivals régionaux',
  'm4': 'Contrats avancés · grands festivals',
  'm5': 'Marchés internationaux · lancements',
  'm6': 'Plan de carrière · gestion de crise',
};

String _pct(num r) => '${(r * 100).round()} %';
String _fee(num f) => f == 0 ? 'sans fixe' : '${fmt21(f)} / semaine';

/// Portrait du manager : illustration du personnage, sinon monogramme (jamais le visage d'un autre).
class ManagerPortrait21 extends StatelessWidget {
  final String name;
  final double height;
  const ManagerPortrait21(this.name, {super.key, required this.height});
  @override
  Widget build(BuildContext context) {
    final id = castId21(name);
    return id != null ? CharacterView(who: id, mood: 'poised', crop: 'bust', height: height) : Center(child: CastAvatar(name, size: height * .7));
  }
}

/// Une exigence chiffrée : ✓ si atteinte, sinon l'écart restant.
class _Req extends StatelessWidget {
  final String label;
  final num have, need;
  const _Req(this.label, this.have, this.need);
  @override
  Widget build(BuildContext context) {
    final ok = have >= need;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        Icon(ok ? Icons.check_circle_rounded : Icons.lock_outline_rounded, size: 16, color: ok ? Tk.ok : V20.lockedIcon),
        const SizedBox(width: 6),
        Expanded(child: Text('$label ${fmt21(need)}', style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w600, color: ok ? V20.okText : V20.ink2))),
        Text(ok ? 'atteint' : 'tu as ${fmt21(have)}', style: V20Text.poppins(size: 12, line: 16, color: ok ? V20.okText : V20.hintGoldText)),
      ]),
    );
  }
}

class Manager21Screen extends ConsumerWidget {
  const Manager21Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final keys = Reg21.managerTiers.keys.toList();
    final cur = s['mgr'] == 'maya' ? 'm1' : s['mgr'] as String?;
    final tier = cur == null ? null : Reg21.managerTiers[cur];
    final next = cur == null ? null : (keys.indexOf(cur) + 1 < keys.length ? keys[keys.indexOf(cur) + 1] : null);
    final rep = _n(s['rep']), xp = _n(s['xp']);

    bool eligible(J t) => rep >= (t['rep'] as num) && xp >= (t['xp'] as num);

    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Mon manager', onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      // --- héros : le manager en poste, ou l'invitation à en recruter un ---
      GameCard(
        selected: tier != null,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: 104, height: 140, child: ManagerPortrait21(tier == null ? Reg21.managerTiers['m1']!['n'] as String : tier['n'] as String, height: 140)),
          const SizedBox(width: 12),
          Expanded(
            child: tier == null
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AUCUN MANAGER', style: V20Text.lab(color: V20.accText)),
                    const SizedBox(height: 2),
                    Text('Tu gères seul', style: V20Text.dm(size: 24, line: 26)),
                    const SizedBox(height: 6),
                    Text('Un manager est optionnel : il prend une commission sur tes cachets. Le premier, Maya Tessé, se recrute sans condition.', style: V20Text.bs()),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('EN POSTE · ${cur!.toUpperCase()} ${_tierNames[cur]!.toUpperCase()}', style: V20Text.lab(color: V20.accText)),
                    const SizedBox(height: 2),
                    Text(tier['n'] as String, style: V20Text.dm(size: 24, line: 26)),
                    const SizedBox(height: 4),
                    Text(_tierFocus[cur]!, style: V20Text.bs()),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      GameTag(_pct(tier['rate'] as num), style: GameTagStyle.accent),
                      GameTag(_fee(tier['fee'] as num), style: GameTagStyle.outline, color: Tk.ink),
                    ]),
                  ]),
          ),
        ]),
      ),
      // --- contrat ---
      if (tier != null) ...[
        const SizedBox(height: 12),
        GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CONTRAT', style: V20Text.lab()),
            const SizedBox(height: 4),
            KeyVal('Commission', '${_pct(tier['rate'] as num)} de chaque cachet'),
            KeyVal('Fixe hebdomadaire', tier['fee'] == 0 ? 'Aucun fixe' : '${fmt21(tier['fee'] as num)} cauris'),
            KeyVal('Déjà versé', '${fmt21(_n(s['managerPaid']))} cauris', color: Tk.gold),
            const SizedBox(height: 6),
            Text('Le fixe est prélevé tous les 7 jours. La commission porte sur les cachets de scène ; écoutes et merchandising restent intacts.', style: V20Text.bs()),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Mettre fin au contrat',
              style: GameButtonStyle.secondary,
              compact: true,
              onPressed: () async {
                final yes = await confirmSheet(context,
                    title: 'Quitter ${tier['n']} ?',
                    body: 'Le contrat s’arrête tout de suite, sans pénalité. Tu pourras recruter un autre manager (ou le même) à tout moment.',
                    action: 'Mettre fin au contrat');
                if (yes && context.mounted) await doAct(context, ref, 'mgr', null, null, 'Contrat terminé');
              },
            ),
          ]),
        ),
        // --- progression vers le niveau suivant ---
        if (next != null) ...[
          const SizedBox(height: 12),
          _NextTier(next: next, rep: rep, xp: xp),
        ],
      ],
      const SizedBox(height: 16),
      Text('LES SIX NIVEAUX', style: V20Text.lab()),
      for (final k in keys) ...[
        const SizedBox(height: 10),
        _TierCard(
          k: k,
          t: Reg21.managerTiers[k]!,
          active: cur == k,
          eligible: eligible(Reg21.managerTiers[k]!),
          rep: rep,
          xp: xp,
          onHire: () async {
            final t = Reg21.managerTiers[k]!;
            final yes = await confirmSheet(context,
                title: 'Signer avec ${t['n']} ?',
                body: '${k.toUpperCase()} · ${_tierNames[k]} : ${_pct(t['rate'] as num)} de chaque cachet, ${_fee(t['fee'] as num)}.${cur != null ? ' Ton contrat actuel est remplacé.' : ''}',
                action: 'Signer le contrat');
            if (yes && context.mounted) await doAct(context, ref, 'hireManager', k, null, 'Contrat signé avec ${t['n']}');
          },
        ),
      ],
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Aujourd’hui le manager prélève sa commission et déclenche des scènes (bilans de sortie, succès, concerts). Les bonus propres à chaque niveau (réseau, accès aux grands festivals) sont proposés mais pas encore actifs. Barèmes provisoires.'),
    ]);
  }
}

num _n(dynamic x) => x is num ? x : 0;

class _NextTier extends StatelessWidget {
  final String next;
  final num rep, xp;
  const _NextTier({required this.next, required this.rep, required this.xp});
  @override
  Widget build(BuildContext context) {
    final t = Reg21.managerTiers[next]!;
    final rn = t['rep'] as num, xn = t['xp'] as num;
    final p = ((rep / (rn == 0 ? 1 : rn)).clamp(0, 1) + (xp / (xn == 0 ? 1 : xn)).clamp(0, 1)) / 2;
    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SizedBox(width: 44, height: 52, child: ManagerPortrait21(t['n'] as String, height: 52)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PROCHAIN NIVEAU · ${next.toUpperCase()} ${_tierNames[next]!.toUpperCase()}', style: V20Text.lab()),
              Text(t['n'] as String, style: V20Text.nm()),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        MeterBar(value: p.toDouble(), tone: p >= 1 ? MeterTone.ok : MeterTone.gold),
        _Req('Réputation', rep, rn),
        _Req('XP', xp, xn),
      ]),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String k;
  final J t;
  final bool active, eligible;
  final num rep, xp;
  final VoidCallback onHire;
  const _TierCard({required this.k, required this.t, required this.active, required this.eligible, required this.rep, required this.xp, required this.onHire});

  @override
  Widget build(BuildContext context) {
    final tag = active ? const GameTag('En poste', style: GameTagStyle.ok) : (eligible ? const GameTag('Disponible', style: GameTagStyle.accent) : const GameTag('Verrouillé', style: GameTagStyle.outline));
    return Opacity(
      opacity: eligible || active ? 1 : .8,
      child: GameCard(
        selected: active,
        onTap: eligible && !active ? onHire : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(width: 56, height: 68, child: ManagerPortrait21(t['n'] as String, height: 68)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${k.toUpperCase()} · ${_tierNames[k]!.toUpperCase()}', style: V20Text.lab(color: V20.accText)),
                Text(t['n'] as String, style: V20Text.nm()),
                Text(_tierFocus[k]!, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              ]),
            ),
            const SizedBox(width: 8),
            tag,
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            GameTag(_pct(t['rate'] as num), style: GameTagStyle.outline, color: Tk.ink),
            GameTag(_fee(t['fee'] as num), style: GameTagStyle.outline, color: Tk.ink),
          ]),
          if (!active && !eligible) ...[
            _Req('Réputation', rep, t['rep'] as num),
            _Req('XP', xp, t['xp'] as num),
          ],
          if (!active && eligible) ...[
            const SizedBox(height: 10),
            PrimaryButton(label: 'Recruter', sublabel: '${_pct(t['rate'] as num)} · ${_fee(t['fee'] as num)}', compact: true, style: GameButtonStyle.secondary, onPressed: onHire),
          ],
        ]),
      ),
    );
  }
}
