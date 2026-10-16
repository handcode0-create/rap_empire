import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/cost_row.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_scaffold.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/game_state.dart';
import '../../domain/kore.dart';
import '../shell/hud.dart';
import '../shell/toast.dart';

/// Scène A · DJ Kôrô (planches 16-A1 à 16-A6) : écoute, offre, contre-offre, accord, refus, retour.
/// Les choix appliquent les effets RÉELS de A.kdeal (lib/domain/kore.dart : cauris, relation, bonus de production) ; les consommer est du domaine.
/// Valeurs de démo (D-08) : la part de Kôrô n'est pas appliquée aux revenus ; le calendrier (créneaux, « 3 semaines plus tard ») n'est pas géré.
/// Routes : /dialogue/ecoute-kore, /offre-kore, /contre-offre-kore, /accord-kore, /refus-kore, /retour-kore. L'écoute s'ouvre à la première visite au Studio.

const _routeEcoute = '/dialogue/ecoute-kore',
    _routeOffre = '/dialogue/offre-kore',
    _routeContre = '/dialogue/contre-offre-kore',
    _routeAccord = '/dialogue/accord-kore',
    _routeRefus = '/dialogue/refus-kore',
    _routeRetour = '/dialogue/retour-kore';

/// Cadre commun : retour, étape x / 6, bandeau de scène (Kôrô et Djo, expressions de la planche), bulle de réplique, puis le contenu propre à l'écran.
class _KoreScene extends StatelessWidget {
  final int step;
  final String title, role, tag, quote, koreMood, djoMood;
  final String koreGesture;
  final VoidCallback onBack;
  final List<Widget> children;
  const _KoreScene({
    required this.step,
    required this.title,
    required this.role,
    required this.tag,
    required this.quote,
    required this.koreMood,
    this.koreGesture = '',
    required this.djoMood,
    required this.onBack,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => GameScaffold(
        scene: 'studio',
        hud: const Hud(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            BackHeader(title: title, step: 'Étape $step / 6', onBack: onBack),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) => SceneBanner(
                kind: 'studio',
                height: 200,
                role: role,
                name: 'DJ Kôrô',
                chars: [
                  BannerChar('kore', mood: koreMood, gesture: koreGesture, crop: 'torso', width: 150, left: c.maxWidth - 160),
                  BannerChar('djo', mood: djoMood, crop: 'torso', width: 96, left: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GameTag(tag, style: GameTagStyle.accent),
                const SizedBox(height: 8),
                Text(quote, style: V20Text.bm.copyWith(fontStyle: FontStyle.italic)),
              ]),
            ),
            for (final w in children) ...[const SizedBox(height: 12), w],
            const SizedBox(height: 12),
            const Center(child: GameTag('Valeurs de démo · D-08', style: GameTagStyle.outline)),
          ]),
        ),
      );
}

/// « Accord déjà conclu » : les choix sont inactifs (kcDone de game.js).
Widget _doneHint(GameState s) => GameHint(icon: 'info', warn: true, text: 'Accord déjà conclu : ${koreStatusLabel(s.kc)}. Les choix ci-dessous sont inactifs.');

/// Applique un choix du domaine ; sur erreur (cash, accord) un toast l'explique et on reste sur l'écran.
Future<void> _choose(BuildContext context, WidgetRef ref, String id, VoidCallback next) async {
  try {
    await ref.read(gameProvider.notifier).koreDeal(id);
  } on GameError catch (e) {
    if (context.mounted) showError(context, e);
    return;
  }
  if (context.mounted) next();
}

/// Solde après accord : un résumé de coût AVANT de décider, sur le cash réel.
Widget _costSummary(String label, String id, int? cash) => GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: CostRow(kind: CostKind.cauris, label: label, amount: koreChoices[id]!.cost, balanceAfter: cash == null ? null : cash - koreChoices[id]!.cost),
    );

/// 16-A1 · Studio Kôrô : Kôrô écoute. S'ouvre à la première visite au Studio ; marque l'introduction comme montrée.
class EcouteKoreScreen extends ConsumerStatefulWidget {
  const EcouteKoreScreen({super.key});
  @override
  ConsumerState<EcouteKoreScreen> createState() => _EcouteKoreScreenState();
}

class _EcouteKoreScreenState extends ConsumerState<EcouteKoreScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(gameProvider.notifier).markKoreSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider).valueOrNull;
    final done = s != null && koreDone(s);
    return _KoreScene(
      step: 1,
      title: 'Studio Kôrô',
      role: 'Producteur · attentif',
      tag: 'Attentif',
      quote: '« Pas mal, la prod est brute. Rejoue-moi le refrain, que je sente le grain de ta voix. »',
      koreMood: 'neutral',
      djoMood: 'neutral',
      onBack: () => context.go('/studio'),
      children: [
        if (done) _doneHint(s),
        ChoiceCard(
          title: 'Rejouer le refrain',
          locked: done,
          onTap: () => context.go(_routeOffre),
          consequences: const [Consequence(ConsequenceKind.certain, 'Aucun coût'), Consequence(ConsequenceKind.estimated, 'Kôrô juge ta voix')],
        ),
        ChoiceCard(
          title: 'Laisser parler la prod',
          locked: done,
          onTap: () => context.go(_routeOffre),
          consequences: const [Consequence(ConsequenceKind.certain, 'Aucun coût'), Consequence(ConsequenceKind.uncertain, 'Kôrô jugera surtout l’instru')],
        ),
      ],
    );
  }
}

/// 16-A2 · Offre de Kôrô : accepter (40 %), négocier ou refuser.
class OffreKoreScreen extends ConsumerWidget {
  const OffreKoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    final done = s != null && koreDone(s);
    return _KoreScene(
      step: 2,
      title: 'Offre de Kôrô',
      role: 'Producteur · en négociation',
      tag: 'En négociation',
      quote: '« Je te propose un deal simple : je prends 40 % sur tes trois premiers titres, je mixe, et ta voix reste au centre. »',
      koreMood: 'poised',
      koreGesture: 'deal',
      djoMood: 'serious',
      onBack: () => context.go(_routeEcoute),
      children: [
        if (done) _doneHint(s),
        _costSummary('Si tu acceptes', 'acc', s?.cash),
        ChoiceCard(
          title: 'Accepter de travailler avec lui',
          locked: done,
          onTap: () => _choose(context, ref, 'acc', () => context.go(_routeAccord)),
          consequences: const [
            Consequence(ConsequenceKind.certain, '−8 000 cauris · 2 créneaux (calendrier non géré en démo)'),
            Consequence(ConsequenceKind.estimated, 'Production +12 sur tes 3 prochains titres (R2)'),
            Consequence(ConsequenceKind.uncertain, 'Tension si un label arrive'),
          ],
        ),
        ChoiceCard(
          title: 'Négocier les conditions',
          locked: done,
          onTap: () => context.go(_routeContre),
          consequences: const [
            Consequence(ConsequenceKind.certain, '1 créneau · −5 énergie (non appliqué)'),
            Consequence(ConsequenceKind.estimated, 'Part visée : 35 %'),
            Consequence(ConsequenceKind.risk, 'Risque moyen'),
          ],
        ),
        ChoiceCard(
          title: 'Refuser et rester indépendant',
          locked: done,
          onTap: () => _choose(context, ref, 'ref', () => context.go(_routeRefus)),
          consequences: const [
            Consequence(ConsequenceKind.certain, '0 cauri · confiance de Kôrô −10'),
            Consequence(ConsequenceKind.uncertain, 'Il ne reproposera pas avant 3 semaines'),
          ],
        ),
      ],
    );
  }
}

/// 16-A3 · Contre-offre : 35 % et mix signé, insister à 30 %, ou revenir à 40 %.
/// Écart planche / game.js : la planche écrit « Relation +3 » pour revenir à 40 % ; game.js donne +15 (et la planche 16-A4 aussi) : c'est +15 qui est appliqué et affiché.
class ContreOffreKoreScreen extends ConsumerWidget {
  const ContreOffreKoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    final done = s != null && koreDone(s);
    return _KoreScene(
      step: 3,
      title: 'Contre-offre',
      role: 'Producteur · négociation',
      tag: 'Contre-offre',
      quote: '« 40 %, c’est déjà un prix d’ami. Mais je descends à 35 % si tu me laisses signer le mix. »',
      koreMood: 'poised',
      koreGesture: 'deal',
      djoMood: 'serious',
      onBack: () => context.go(_routeOffre),
      children: [
        if (done) _doneHint(s),
        _costSummary('Si tu acceptes à 35 %', 'neg', s?.cash),
        ChoiceCard(
          title: '35 % et mix signé',
          locked: done,
          onTap: () => _choose(context, ref, 'neg', () => context.go(_routeAccord)),
          consequences: [
            Consequence(ConsequenceKind.certain, '${koreCostLabel('neg')} · 2 créneaux'),
            const Consequence(ConsequenceKind.estimated, 'Part gagnée : 5 points'),
            Consequence(ConsequenceKind.certain, 'Relation ${koreRelLabel(koreChoices['neg']!.rel)}'),
          ],
        ),
        ChoiceCard(
          title: 'Insister à 30 %',
          locked: done,
          onTap: () => _choose(context, ref, 'ins', () => context.go(_routeRefus)),
          consequences: [
            Consequence(ConsequenceKind.certain, 'Relation ${koreRelLabel(koreChoices['ins']!.rel)}'),
            const Consequence(ConsequenceKind.uncertain, 'Il peut rompre la discussion'),
          ],
        ),
        ChoiceCard(
          title: 'Revenir à l’offre initiale (40 %)',
          locked: done,
          onTap: () => _choose(context, ref, 'acc', () => context.go(_routeAccord)),
          consequences: [Consequence(ConsequenceKind.certain, 'Relation ${koreRelLabel(koreChoices['acc']!.rel)} · ${koreCostLabel('acc')} · 2 créneaux')],
        ),
      ],
    );
  }
}

/// 16-A4 · Accord conclu : conséquences enregistrées, lues dans l'accord réel (kc).
class AccordKoreScreen extends ConsumerWidget {
  const AccordKoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kc = ref.watch(gameProvider).valueOrNull?.kc;
    return _KoreScene(
      step: 4,
      title: 'Accord conclu',
      role: 'Producteur · heureux',
      tag: 'Heureux',
      quote: '« Marché conclu. Reviens jeudi soir, on pose ton premier titre. »',
      koreMood: 'laugh',
      djoMood: 'smile',
      onBack: () => context.go('/studio'),
      children: [
        GlassCard(
          accent: GlassAccent.gold,
          halo: false, // le halo fort de l'écran est celui du bouton principal
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('CONSÉQUENCES ENREGISTRÉES', style: V20Text.lab()),
            const SizedBox(height: 4),
            _line('Accord', kc == null ? '–' : koreStatusLabel(kc)),
            _line('Part de Kôrô (démo)', kc == null || kc.cut.isEmpty ? '–' : kc.cut),
            if (kc != null && kc.cost > 0) CostRow(kind: CostKind.cauris, label: 'Payé', amount: kc.cost) else _line('Payé', '0 cauri'),
            _line('Relation avec Kôrô', kc == null ? '–' : koreRelLabel(kc.rel)),
            _line('Bonus', kc == null ? '–' : koreBonusLabel(kc)),
          ]),
        ),
        PrimaryGlowButton(label: 'Aller au studio', onPressed: () => context.go('/studio')),
        PrimaryButton(label: 'Retour au réseau', style: GameButtonStyle.secondary, onPressed: () => context.go('/business')),
      ],
    );
  }

  static Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(label, style: V20Text.bs())),
          const SizedBox(width: 8),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: V20Text.nm())),
        ]),
      );
}

/// 16-A5 · Refus : Kôrô se souvient (le refus définitif, 'decl', arrive aussi ici).
class RefusKoreScreen extends ConsumerWidget {
  const RefusKoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kc = ref.watch(gameProvider).valueOrNull?.kc;
    final definitive = kc?.st == 'decl';
    return _KoreScene(
      step: 5,
      title: definitive ? 'Refus définitif' : 'Refus',
      role: 'Producteur · bras croisés',
      tag: 'Froid',
      quote: '« Très bien. Tu sais où me trouver. Mais mon agenda sera plein un moment. »',
      koreMood: 'angry',
      djoMood: 'worried',
      onBack: () => context.go('/studio'),
      children: [
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('MÉMOIRE DU PERSONNAGE', style: V20Text.lab()),
            const SizedBox(height: 4),
            Text(
              definitive ? 'Tu restes indépendant : ton réseau est réduit.' : 'Kôrô se souvient du refus. Il ne reproposera pas d’offre avant 3 semaines, et son prochain deal sera moins généreux.',
              style: V20Text.bm,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('Relation avec Kôrô', style: V20Text.bs())),
              Text(kc == null ? '–' : koreRelLabel(kc.rel), style: V20Text.nm()),
            ]),
          ]),
        ),
        if (!definitive) PrimaryGlowButton(label: 'Trois semaines plus tard', sublabel: 'Calendrier non géré en démo', onPressed: () => context.go(_routeRetour)),
        PrimaryButton(label: 'Retour au réseau', style: GameButtonStyle.secondary, onPressed: () => context.go('/business')),
      ],
    );
  }
}

/// 16-A6 · Trois semaines plus tard : Kôrô se souvient du refus (45 %, assistant, ou refus définitif).
class RetourKoreScreen extends ConsumerWidget {
  const RetourKoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    final done = s != null && koreDone(s);
    return _KoreScene(
      step: 6,
      title: '3 semaines plus tard',
      role: 'Producteur · sûr de lui',
      tag: 'Sûr de lui',
      quote: '« Tu as refusé la dernière fois. J’ai gardé un créneau, mais cette fois c’est 45 %, ou tu passes par mon assistant. »',
      koreMood: 'smirk',
      djoMood: 'serious',
      onBack: () => context.go('/studio'),
      children: [
        const GameHint(icon: 'info', text: 'Scène différente de A2 : Kôrô se souvient de ton refus.'),
        if (done) _doneHint(s),
        _costSummary('Si tu acceptes à 45 %', 'back', s?.cash),
        ChoiceCard(
          title: 'Accepter à 45 %',
          locked: done,
          onTap: () => _choose(context, ref, 'back', () {
            showSuccess(context, 'Accord conclu · ${koreChoiceBonusLabel('back')}');
            context.go('/');
          }),
          consequences: [
            Consequence(ConsequenceKind.certain, '${koreCostLabel('back')} · 2 créneaux'),
            const Consequence(ConsequenceKind.estimated, 'Production +12 sur 3 titres'),
            const Consequence(ConsequenceKind.risk, 'Risque moyen : part élevée'),
          ],
        ),
        ChoiceCard(
          title: 'Passer par son assistant',
          locked: done,
          onTap: () => _choose(context, ref, 'assist', () {
            showSuccess(context, 'Accord conclu · ${koreChoiceBonusLabel('assist')}');
            context.go('/');
          }),
          consequences: const [
            Consequence(ConsequenceKind.certain, '1 créneau · délai +1 semaine'),
            Consequence(ConsequenceKind.estimated, 'Production +6 sur 2 titres'),
            Consequence(ConsequenceKind.uncertain, 'Tarif réduit si ton Business monte'),
          ],
        ),
        ChoiceCard(
          title: 'Décliner définitivement',
          locked: done,
          onTap: () => _choose(context, ref, 'decl', () => context.go('/business')),
          consequences: [
            Consequence(ConsequenceKind.certain, 'Relation ${koreRelLabel(koreChoices['decl']!.rel)}'),
            const Consequence(ConsequenceKind.certain, 'Rester indépendant, réseau réduit'),
          ],
        ),
      ],
    );
  }
}
