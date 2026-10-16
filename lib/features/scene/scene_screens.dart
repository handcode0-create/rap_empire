import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_toast.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reward_chip.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/econ.dart';
import '../../domain/game_state.dart';
import '../../domain/rules.dart';
import '../../domain/scene.dart';
import '../shell/game_frame.dart';
import '../shell/toast.dart';

/// Scène (06.1) : open mic, battle, concert, freestyle. Les règles sont dans lib/domain/scene.dart ; ici seulement l'affichage et l'enchaînement.
/// Un passage de scène coûte de l'énergie et du temps ; sous 40 d'énergie, le public décroche (règle de démo).
class SceneScreen extends ConsumerWidget {
  const SceneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final concertLocked = s.level < concertLevel;
    final tired = s.energy < sceneEnergy;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const SceneBanner(
        kind: 'stage',
        height: 170,
        nameSize: 28,
        role: 'Le public attend',
        name: 'Scène',
        chars: [BannerChar('djo', mood: 'sing', gesture: 'micup', crop: 'torso', width: 110, left: 250)],
      ),
      const SizedBox(height: 12),
      ActionRow(
        icon: 'mic',
        title: 'Open mic',
        subtitle: 'Ndolo · 1 h · $sceneEnergy énergie',
        note: tired ? const GameError('energie').message : null,
        disabled: tired,
        trailing: ActionRow.arrow(disabled: tired),
        onTap: () => context.go('/scene/openmic'),
      ),
      const SizedBox(height: 8),
      ActionRow(
        icon: 'flame',
        title: 'Battle',
        subtitle: 'Face à K-Zer d’Mabaya · 1 h · $sceneEnergy énergie',
        note: tired ? const GameError('energie').message : null,
        disabled: tired,
        trailing: ActionRow.arrow(disabled: tired),
        onTap: () => context.go('/scene/battle'),
      ),
      const SizedBox(height: 8),
      ActionRow(
        icon: concertLocked ? 'lock' : 'trophy',
        title: 'Concert · Le Parvis',
        subtitle: '300 places · cachet jusqu’à ${fmt(Econ.concertFee)} cauris',
        note: concertLocked ? 'Niveau $concertLevel requis' : (s.energy < concertEnergy ? const GameError('energie').message : null),
        disabled: concertLocked || s.energy < concertEnergy,
        trailing: concertLocked ? null : ActionRow.arrow(disabled: s.energy < concertEnergy),
        onTap: () => context.go('/scene/concert'),
      ),
      const SizedBox(height: 8),
      ActionRow(
        icon: 'zap',
        title: 'Freestyle au carrefour',
        subtitle: 'Gratuit · Flow +2 · −15 énergie',
        note: s.energy < 15 ? const GameError('energie').message : null,
        disabled: s.energy < 15,
        trailing: ActionRow.arrow(disabled: s.energy < 15),
        onTap: () async {
          try {
            await ref.read(gameProvider.notifier).freestyleScene();
            if (context.mounted) showGameToast(context, 'Flow +2 · Freestyle terminé', kind: ToastKind.success);
          } on Object catch (e) {
            if (context.mounted) showError(context, e);
          }
        },
      ),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Chaque passage coûte de l’énergie et du temps. En dessous de 40 d’énergie, le public décroche (règle de démo).'),
    ]);
  }
}

Future<void> _go(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
  try {
    await action();
    if (!context.mounted) return;
    context.go('/scene-resultat');
  } on Object catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// Open mic (06.2) : le public attendu, ce qu'on peut y gagner, et le seuil d'énergie.
class OpenMicScreen extends ConsumerWidget {
  const OpenMicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final ready = s.energy >= openMicWinEnergy;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Open mic', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      const SceneBanner(
        kind: 'street',
        height: 170,
        nameSize: 26,
        nameSingleLine: true,
        role: 'Ce soir',
        name: 'Open mic de Ndolo',
        chars: [BannerChar('djo', mood: 'cool', crop: 'torso', width: 100, left: 270)],
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        const RewardChip(value: '+150 fans', color: Tk.ok),
        const RewardChip(value: '+6 rép.', color: Tk.ink),
        RewardChip(value: '+${fmt(Econ.openMicFee)} cauris'),
      ]),
      const SizedBox(height: 12),
      GameHint(
        icon: ready ? 'info' : 'zap',
        warn: !ready,
        text: ready
            ? 'Public attendu ≈ 60 personnes. Réussi si ton énergie est d’au moins $openMicWinEnergy : tu as ${s.energy}.'
            : 'Énergie ${s.energy} : sous $openMicWinEnergy, le public risque de décrocher (+12 fans seulement). Dors ou reviens plus tard.',
      ),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Monter sur scène', sublabel: '1 h · −$sceneEnergy énergie', onPressed: () => _go(context, ref, () => ref.read(gameProvider.notifier).openMic())),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Pas prêt', style: GameButtonStyle.ghost, onPressed: () => context.go('/scene')),
    ]);
  }
}

/// Battle (06.3) : trois punchlines, une réponse juste par round (Malin, Agressif, Cool). Deux sur trois pour gagner. Adversaire scripté.
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});
  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  static const _rounds = [
    ('« T’as le flow d’un gbaka en panne. »', 'Il ironise : réponds avec malice.', 'Malin'),
    ('« Dans mon quartier, on te connaît pas. »', 'Il attaque de front : réponds fort.', 'Agressif'),
    ('« Ton refrain ? Il est où ? »', 'Il se détend : garde la tête froide.', 'Cool'),
  ];
  static const _answers = ['Agressif', 'Malin', 'Cool'];
  int _round = 0, _score = 0;
  bool _busy = false;

  Future<void> _answer(String a) async {
    if (_busy) return;
    final score = _score + (a == _rounds[_round].$3 ? 1 : 0);
    if (_round < 2) {
      setState(() {
        _score = score;
        _round++;
      });
      return;
    }
    _busy = true;
    await _go(context, ref, () => ref.read(gameProvider.notifier).battle(score));
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final r = _rounds[_round];
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Battle', step: 'Round ${_round + 1} / 3', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      SceneBanner(
        kind: 'stage',
        height: 150,
        nameSize: 24,
        nameSingleLine: true,
        role: 'Djo Kéné · K-Zer d’Mabaya',
        name: 'Punchline $_score / 3',
        chars: const [BannerChar('kzer', mood: 'angry', crop: 'torso', width: 90, left: 170), BannerChar('djo', mood: 'smirk', crop: 'torso', width: 100, left: 270)],
      ),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ROUND ${_round + 1}', style: V20Text.lab()),
          const SizedBox(height: 6),
          Text(r.$1, style: V20Text.nm()),
          const SizedBox(height: 4),
          Text(r.$2, style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      for (final a in _answers) ...[
        PrimaryButton(label: a, style: GameButtonStyle.secondary, onPressed: () => _answer(a)),
        const SizedBox(height: 8),
      ],
      const GameHint(icon: 'info', text: 'Bataille réelle, adversaire scripté : choisis la réponse qui colle au ton de la punchline.'),
    ]);
  }
}

/// Concert (Le Parvis) : trois actions, Hype (+8) ou Rap (+14, +6 de plus après un Hype). La note A, B ou C vient du remplissage de la salle.
class ConcertScreen extends ConsumerStatefulWidget {
  const ConcertScreen({super.key});
  @override
  ConsumerState<ConcertScreen> createState() => _ConcertScreenState();
}

class _ConcertScreenState extends ConsumerState<ConcertScreen> {
  final List<String> _seq = [];
  bool _busy = false;

  Future<void> _pick(String a) async {
    if (_busy) return;
    setState(() => _seq.add(a));
    if (_seq.length < 3) return;
    _busy = true;
    await _go(context, ref, () => ref.read(gameProvider.notifier).concert(List.of(_seq)));
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final crowd = concertCrowd(_seq).clamp(0, 100);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Concert', step: 'Morceau ${_seq.length + 1 > 3 ? 3 : _seq.length + 1} / 3', onBack: () => context.go('/scene')),
      const SizedBox(height: 12),
      const SceneBanner(
        kind: 'stage',
        height: 170,
        nameSize: 26,
        nameSingleLine: true,
        role: '300 places',
        name: 'Le Parvis',
        chars: [BannerChar('djo', mood: 'sing', gesture: 'micup', crop: 'torso', width: 110, left: 250)],
      ),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('SALLE', style: V20Text.lab()),
            Text('$crowd %', style: V20Text.poppins(size: 13, line: 18, weight: FontWeight.w700, color: V20.ink2)),
          ]),
          const SizedBox(height: 8),
          MeterBar(value: crowd / 100, tone: MeterTone.ok),
          const SizedBox(height: 6),
          Text('A à 85 %, B à 70 %, en dessous : C.', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Rap', sublabel: '+14 · +6 après un Hype', onPressed: () => _pick('r')),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Hype', sublabel: '+8 · prépare le rap suivant', style: GameButtonStyle.secondary, onPressed: () => _pick('h')),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Concert : −35 énergie, la soirée se termine à 23 h. Cachet et fans dépendent de la note.'),
    ]);
  }
}

/// Résultat d'une scène (06.4, 06.4b, 06.5) : bilan de l'open mic, de la battle ou du concert, puis retour à la scène.
class SceneResultScreen extends ConsumerWidget {
  const SceneResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(lastSceneProvider);
    if (r == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/scene');
      });
      return const GameFrame(children: []);
    }
    final (role, title, text) = switch (r.kind) {
      SceneKind.openMic => r.win
          ? ('Open mic · résultat', 'Bien joué', 'Le public a suivi. Le quartier en parle.')
          : ('Open mic · résultat', 'Trou de mémoire', 'Le public a décroché. Ça arrive aux meilleurs.'),
      SceneKind.battle => r.win
          ? ('Battle · K-Zer d’Mabaya', 'Battle gagnée', 'K-Zer salue ton flow. Ndolo en parle.')
          : ('Battle · K-Zer d’Mabaya', 'Battle perdue', 'Il a eu le dernier mot. Reviens plus affûté.'),
      SceneKind.concert => ('Concert · Le Parvis', 'Note ${r.grade}', 'Salle remplie à ${r.crowd} %.'),
    };
    final celebrate = r.win;
    return GameFrame(burst: celebrate, children: [
      SceneBanner(
        kind: r.kind == SceneKind.openMic ? 'street' : 'stage',
        height: 160,
        nameSize: 26,
        nameSingleLine: true,
        role: role,
        name: title,
        chars: [BannerChar('djo', mood: celebrate ? 'laugh' : 'worried', crop: 'torso', width: 100, left: 270)],
      ),
      const SizedBox(height: 12),
      Text(text, textAlign: TextAlign.center, style: V20Text.bm),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Fans', value: '+${fmt(r.fans)}', big: true, valueColor: Tk.ok),
        StatKpi(label: 'Réputation', value: '+${r.rep}'),
        StatKpi(label: 'Cachet', value: r.cash > 0 ? '+${fmt(r.cash)}' : '0', valueColor: r.cash > 0 ? Tk.gold : null),
      ]),
      if (r.xp > 0) ...[
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [RewardChip(value: '+${r.xp} XP', color: Tk.ink)]),
      ],
      if (!r.win && r.kind == SceneKind.openMic) ...[
        const SizedBox(height: 12),
        const GameHint(icon: 'info', text: 'Conseil : repose-toi avant de monter sur scène, et un coach vocal ou un atelier d’écriture limite les trous de mémoire.'),
      ],
      const SizedBox(height: 12),
      PrimaryButton(
        label: 'Continuer',
        onPressed: () => context.go(ref.read(gameProvider).requireValue.pend != null ? '/niveau' : '/scene'),
      ),
      if (!r.win) ...[
        const SizedBox(height: 12),
        PrimaryButton(label: 'Voir les formations', style: GameButtonStyle.ghost, onPressed: () => context.go('/business/formation')),
      ],
    ]);
  }
}
