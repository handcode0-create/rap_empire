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
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'shell21.dart';
import 'widgets21.dart';

/// Dialogue (21-X1) et page des scènes (21-X0).
/// Intention de jeu : une scène de personnage où chaque réponse a un prix annoncé ; le joueur choisit en connaissant les conséquences.
/// Un seul écran générique, piloté par `dlg21` (décor, personnage, réplique, 2 à 3 choix avec leur étiquette de certitude).

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic> ? x : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

ConsequenceKind _kind(String k) => switch (k) {
      'e' => ConsequenceKind.estimated,
      'i' => ConsequenceKind.uncertain,
      'r' => ConsequenceKind.risk,
      _ => ConsequenceKind.certain,
    };

/// Les directeurs de label n'ont pas de personnage dans assets/characters : leur portrait est un SVG extrait de la planche 21-X1.
bool _hasExtractedPortrait(String who) => lbl21.values.any((l) => l.who == who) && who != 'kore';

/// Bannière de la scène : décor du lieu, Djo à gauche, le personnage à droite, référence de la scène en bas à gauche.
class DialogueBanner extends StatelessWidget {
  final Dlg d;
  final String node; // n1, n2…, ou « fin »
  const DialogueBanner(this.d, this.node, {super.key});

  @override
  Widget build(BuildContext context) {
    final mood = d.nodes[node]?.mood ?? 'poised';
    return LayoutBuilder(
        builder: (context, c) => SceneBanner(
              kind: d.place,
              height: 190,
              role: d.ref,
              chars: [
                if (_hasExtractedPortrait(d.who))
                  BannerChar(d.who, width: 108, left: c.maxWidth - 122, asset: 'assets/svg/portrait-${d.who}-${d.nodes.containsKey(node) ? node : 'fin'}.svg')
                else
                  BannerChar(d.who, mood: mood, crop: 'torso', width: 108, left: c.maxWidth - 122),
                const BannerChar('djo', mood: 'neutral', crop: 'torso', width: 92, left: 24),
              ],
            ));
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-X1 Dialogue
// ---------------------------------------------------------------------------------------------------------------------

class DialogueScreen extends ConsumerWidget {
  const DialogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final dl = s['dlg'] == null ? null : _m(s['dlg']);
    if (dl == null) {
      return Frame21(children: [
        BackHeader(title: 'Scène', onBack: () => context.go('/')),
        const SizedBox(height: 12),
        const GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aucune scène en cours'),
          SizedBox(height: 4),
          Text('Les scènes arrivent selon ta carrière. Leurs conditions sont listées dans la page Scènes.'),
        ])),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Voir les scènes', onPressed: () => context.go('/scenes')),
      ]);
    }
    final d = dlg21[dl['id']]!;
    final done = _n(dl['done']) != 0;
    final node = done ? null : d.nodes[dl['node']]!;
    final nodeKey = done ? 'fin' : dl['node'] as String;
    final steps = d.nodes.length, step = done ? steps : d.nodes.keys.toList().indexOf(dl['node'] as String) + 1;
    final waiting = _l(s['dq']).length;
    return Frame21(children: [
      BackHeader(title: 'Scène', step: d.ref.split(' · ').first, onBack: () => context.go('/')),
      const SizedBox(height: 12),
      DialogueBanner(d, nodeKey),
      const SizedBox(height: 12),
      if (!done) ...[
        GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text('${castn21[d.who] ?? d.who} · ${d.role}'.toUpperCase(), style: V20Text.lab())),
            const SizedBox(width: 8),
            Text('Échange $step/$steps', style: V20Text.bs()),
          ]),
          const SizedBox(height: 6),
          Text(node!.q, style: V20Text.bm.copyWith(fontSize: 16, height: 1.3)),
        ])),
        for (final c in node.ch) ...[
          const SizedBox(height: 10),
          GameCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.n, style: V20Text.nm()),
            const SizedBox(height: 4),
            Conseq21(_kind(c.k), c.c),
            const SizedBox(height: 8),
            PrimaryGlowButton(label: 'Choisir', onPressed: () => doAct(context, ref, 'dch', c.id)),
          ])),
        ],
        const SizedBox(height: 12),
        const GameHint(
            icon: 'info',
            text: 'Chaque choix affiche ses conséquences avant de répondre : Certain (coût fixe), Estimé (calculé), Incertain (dépend de l’autre), Risque.'),
      ] else ...[
        GlassCard(
            accent: GlassAccent.magenta,
            halo: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.t.toUpperCase(), style: V20Text.lab(color: V20.accText)),
              const SizedBox(height: 4),
              Text('${dl['end']}', style: V20Text.dm(size: 24)),
              const SizedBox(height: 8),
              Text('TES RÉPONSES', style: V20Text.lab()),
              for (final p in _l(dl['path'])) Text('› $p', style: V20Text.bs(color: Tk.ink)),
              const SizedBox(height: 6),
              Conseq21(ConsequenceKind.certain, '${dl['c']}'),
              const Conseq21(ConsequenceKind.certain, 'Conséquences appliquées et inscrites au journal. Le personnage s’en souviendra (relations, page Scènes).'),
            ])),
        const SizedBox(height: 12),
        PrimaryGlowButton(
          label: 'Continuer',
          sublabel: waiting > 0 ? 'Encore $waiting scène(s) en attente' : null,
          onPressed: () async {
            final e = await ref.read(game21Provider.notifier).act('dclose');
            if (!context.mounted) return;
            if (e != null) return toastErr(context, e);
            // une autre scène peut s'ouvrir tout de suite : on reste ici, sinon retour au QG
            if (ref.read(game21Provider).valueOrNull?['dlg'] == null) context.go('/');
          },
        ),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Toutes les scènes', style: GameButtonStyle.secondary, onPressed: () => context.go('/scenes')),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-X0 Scènes et dialogues
// ---------------------------------------------------------------------------------------------------------------------

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final seen = _m(s['dseen']), rel = _m(s['rel']);
    final dl = s['dlg'] == null ? null : _m(s['dlg']);
    final queued = _l(s['dq']).map((x) => _m(x)['id']).toSet();
    final tier = managerTier21(s);
    return Frame21(children: [
      BackHeader(title: 'Scènes et dialogues', step: 'Proposé', onBack: () => context.go('/')),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Des scènes reliées au jeu : elles se déclenchent seules quand leur condition est remplie et apparaissent au QG.'),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('MÉMOIRE DES PERSONNAGES', style: V20Text.lab()),
          const GameTag('Nouveau', style: GameTagStyle.accent),
        ]),
        const SizedBox(height: 4),
        for (final e in castn21.entries) KeyVal(e.value, '${_n(rel[e.key]).toInt()}'),
        const SizedBox(height: 4),
        KeyVal('Manager', tier == null ? 'aucun' : '${tier['n']} · ${((tier['rate'] as num) * 100).round()} % des cachets'),
        KeyVal('Contrat de label', _n(s['signed']) != 0 ? '${lblName21(s)} · ${((_n(s['lcut']) == 0 ? Reg21.labelCut : _n(s['lcut'])) * 100).round()} % des écoutes' : '—'),
      ])),
      for (final id in dlgOrder21) ...[
        const SizedBox(height: 10),
        _SceneRow(id, dlg21[id]!, seen[id] as String?, live: dl != null && dl['id'] == id && _n(dl['done']) == 0, waiting: queued.contains(id), onOpen: () => context.go('/dialogue')),
      ],
      const SizedBox(height: 12),
    ]);
  }
}

class _SceneRow extends StatelessWidget {
  final String id;
  final Dlg d;
  final String? choice;
  final bool live, waiting;
  final VoidCallback onOpen;
  const _SceneRow(this.id, this.d, this.choice, {required this.live, required this.waiting, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final (tag, style) = choice != null
        ? ('Vue', GameTagStyle.ok)
        : live || waiting
            ? ('En attente', GameTagStyle.accent)
            : ('À venir', GameTagStyle.outline);
    return GameCard(
      onTap: live ? onOpen : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(d.t, style: V20Text.nm())),
          const SizedBox(width: 8),
          GameTag(tag, style: style),
        ]),
        Text('${castn21[d.who] ?? d.who} · ${d.ref}', style: V20Text.bs(color: Tk.ink)),
        Text('Déclenchement : ${d.cl}', style: V20Text.bs()),
        if (choice != null) Text('Ton choix : $choice', style: V20Text.bs(color: Tk.ok)),
        if (live) const Padding(padding: EdgeInsets.only(top: 4), child: Text('Scène ouverte : touche pour y répondre')),
      ]),
    );
  }
}
