import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/enter_anim.dart';
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
import 'start_screens.dart' show confirmSheet;
import 'widgets21.dart';

/// Droits d'auteur (21-DA) : avis de réclamation, rendez-vous avec le producteur, contestation, intervention officielle, retrait.
/// Intention de jeu : un succès devient un problème ; le joueur choisit entre payer, négocier, contester ou laisser filer,
/// en voyant le prix et le risque de chaque voie. Émotion : la tension d'un courrier officiel, puis le soulagement ou la perte.
/// Les règles sont dans lib/domain/v21/copyright21.dart ; cet écran n'en contient aucune.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic> ? x : <String, dynamic>{};

ConsequenceKind _riskKind(String level) => level == 'Faible' ? ConsequenceKind.estimated : ConsequenceKind.risk;

/// Mine du titulaire des droits selon l'étape du rendez-vous.
String _ownerMood(String? node) => switch (node) { 'counter' => 'smirk', 'refus' => 'angry', _ => 'serious' };

J? _song(J s, dynamic id) {
  for (final d in (s['disco'] as List? ?? const [])) {
    if (_m(d)['id'] == id) return _m(d);
  }
  return null;
}

// ---------------------------------------------------------------------------------------------------------------------
// Animation « Copyright claim » : assombrissement, vibration, notification qui glitche, titre, alerte, montant qui compte.
// Finie (≈ 3,4 s), jamais en boucle ; réduite à son état final si l'appareil demande moins d'animations.
// Couleurs : la palette validée (fond #0C0820, magenta foncé #C21E78 pour l'alerte, or pour le montant) ; aucune couleur nouvelle.
// ---------------------------------------------------------------------------------------------------------------------

class CopyrightStrike extends StatefulWidget {
  /// 'avis', 'intervention', 'retrait' ou 'verdict'.
  final String kind;
  final String title, owner, headline;
  final num amount;
  final List<String> stakes;
  final VoidCallback onDone;
  final String action;
  const CopyrightStrike({super.key, required this.kind, required this.title, required this.owner, required this.headline, required this.amount, required this.stakes, required this.onDone, this.action = 'Voir l’avis'});

  @override
  State<CopyrightStrike> createState() => _CopyrightStrikeState();
}

class _CopyrightStrikeState extends State<CopyrightStrike> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400));
  bool _buzzed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
      _c.addListener(_buzz);
    }
  }

  void _buzz() {
    if (!_buzzed && _c.value > .12) {
      _buzzed = true;
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _iv(double a, double b, [Curve curve = Curves.easeOutCubic]) => curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        label: '${widget.headline}. ${widget.title}. ${fmt21(widget.amount)} cauris.',
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final dim = _iv(0, .12);
              final shake = _c.value > .12 && _c.value < .34 ? math.sin(_c.value * 180) * 7 * (1 - _iv(.12, .34)) : 0.0;
              final glitch = _c.value > .24 && _c.value < .46 ? (1 - _iv(.24, .46)) : 0.0;
              final show = _iv(.22, .34);
              final alert = _iv(.40, .52, Curves.elasticOut);
              final head = _iv(.48, .60);
              final count = _iv(.58, .84);
              final stakes = _iv(.82, .96);
              final beam = _iv(.30, .72, Curves.easeInOutCubic);
              return Container(
                decoration: BoxDecoration(
                  color: Color.lerp(Tk.bg, Tk.deep, dim),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Tk.acc7.withValues(alpha: .25 + .55 * head), width: 1.5),
                  boxShadow: [BoxShadow(color: Tk.acc7.withValues(alpha: .35 * head), blurRadius: 32, spreadRadius: -4)],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(children: [
                  Positioned.fill(child: CustomPaint(painter: _Scan(opacity: .05 + .07 * dim, beam: beam))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Opacity(
                        opacity: show,
                        child: Transform.translate(
                          offset: Offset(shake, (1 - show) * -18),
                          child: _Notif(title: widget.title, owner: widget.owner, kind: widget.kind, glitch: glitch, t: _c.value),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Transform.scale(
                        scale: .4 + .6 * alert,
                        child: Opacity(opacity: alert.clamp(0, 1).toDouble(), child: const Center(child: _AlertMark())),
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: head,
                        child: Text(widget.headline,
                            textAlign: TextAlign.center,
                            style: V20Text.baloo(size: 26, line: 28, color: Tk.acc4).copyWith(letterSpacing: 1.2, shadows: [Shadow(color: Tk.acc7.withValues(alpha: .9), blurRadius: 18)])),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: count > 0 ? 1 : 0,
                        child: Column(children: [
                          Text(widget.kind == 'retrait' ? 'REVENUS FUTURS PERDUS' : 'MONTANT EN JEU', style: V20Text.lab(color: Tk.ink2)),
                          Text('${fmt21((widget.amount * count).round())} cauris',
                              style: V20Text.baloo(size: 40, line: 44, color: Tk.gold).copyWith(shadows: [Shadow(color: Tk.gold.withValues(alpha: .45), blurRadius: 16)])),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      for (final (i, x) in widget.stakes.indexed)
                        Opacity(
                          opacity: ((stakes * widget.stakes.length) - i).clamp(0, 1).toDouble(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 7, right: 8), decoration: const BoxDecoration(color: Tk.acc4, shape: BoxShape.circle)),
                              Expanded(child: Text(x, style: V20Text.bm)),
                            ]),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: _iv(.84, .92),
                        child: PrimaryGlowButton(label: widget.action, onPressed: _c.value >= .88 ? widget.onDone : null),
                      ),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
      );
}

/// Notification du téléphone en jeu, avec dédoublement magenta / cyan pendant le glitch.
class _Notif extends StatelessWidget {
  final String title, owner, kind;
  final double glitch, t;
  const _Notif({required this.title, required this.owner, required this.kind, required this.glitch, required this.t});

  Widget _card() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Tk.s1.withValues(alpha: .95), borderRadius: BorderRadius.circular(18), border: Border.all(color: Tk.acc7.withValues(alpha: .7), width: 1.5)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Tk.acc7, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.gavel_rounded, color: Tk.ink, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                kind == 'intervention'
                    ? 'INTERVENTION OFFICIELLE'
                    : kind == 'retrait'
                        ? 'RETRAIT DES PLATEFORMES'
                        : kind == 'verdict'
                            ? 'DÉCISION DE LA PROCÉDURE'
                            : 'RÉCLAMATION · DROITS D’AUTEUR',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: V20Text.lab(color: Tk.acc4)),
            Text('« $title »', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
            Text('Titulaire : $owner', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.bs()),
          ])),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    if (glitch <= 0) return _card();
    final j = math.sin(t * 900) * 4 * glitch;
    return Stack(children: [
      Transform.translate(offset: Offset(-3 * glitch + j, 0), child: Opacity(opacity: .55 * glitch, child: ColorFiltered(colorFilter: const ColorFilter.mode(Tk.acc, BlendMode.srcATop), child: _card()))),
      Transform.translate(offset: Offset(3 * glitch - j, 0), child: Opacity(opacity: .55 * glitch, child: ColorFiltered(colorFilter: const ColorFilter.mode(Tk.cy, BlendMode.srcATop), child: _card()))),
      Transform.translate(offset: Offset(j / 2, 0), child: _card()),
    ]);
  }
}

class _AlertMark extends StatelessWidget {
  const _AlertMark();
  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [Tk.acc7, Tk.deep]),
          border: Border.all(color: Tk.gold, width: 2),
          boxShadow: [BoxShadow(color: Tk.acc7.withValues(alpha: .6), blurRadius: 24)],
        ),
        child: const Icon(Icons.priority_high_rounded, color: Tk.gold, size: 36),
      );
}

/// Lignes de balayage et faisceau lumineux qui traverse l'écran.
class _Scan extends CustomPainter {
  final double opacity, beam;
  const _Scan({required this.opacity, required this.beam});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Tk.ink.withValues(alpha: opacity);
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), p);
    }
    if (beam > 0 && beam < 1) {
      final x = -size.width * .6 + size.width * 2.2 * beam;
      final r = Rect.fromLTWH(x, 0, size.width * .45, size.height);
      canvas.drawRect(
          r,
          Paint()
            ..shader = LinearGradient(colors: [Tk.acc7.withValues(alpha: 0), Tk.acc7.withValues(alpha: .22), Tk.gold.withValues(alpha: .10), Tk.acc7.withValues(alpha: 0)]).createShader(r));
    }
  }

  @override
  bool shouldRepaint(_Scan old) => old.opacity != opacity || old.beam != beam;
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-DA1 Litige : avis, contestation, intervention, issue
// ---------------------------------------------------------------------------------------------------------------------

class LitigeScreen extends ConsumerWidget {
  const LitigeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final c = crClaim21(s);
    final back = BackHeader(title: 'Droits d’auteur', onBack: () => context.go('/'));
    final out = s['crOut'] == null ? null : _m(s['crOut']);
    if (c == null || c['st'] == 'decouvert') {
      if (out != null && _n(out['seen']) == 0) return Frame21(children: [back, const SizedBox(height: 12), _Outcome(out)]);
      return Frame21(children: [
        back,
        const SizedBox(height: 12),
        const GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aucun litige en cours'),
          SizedBox(height: 4),
          Text('Le statut des droits de chaque titre est indiqué dans sa fiche, au catalogue.'),
        ])),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Ouvrir le catalogue', onPressed: () => context.go('/studio/catalogue')),
      ]);
    }
    final owner = crOwnerName21(c['owner']);
    final st = c['st'] as String;
    if (st == 'nego') return const RendezVousScreen();
    final inter = st == 'intervention';
    if (_n(c['seen']) == 0) {
      return Frame21(children: [
        back,
        const SizedBox(height: 12),
        CopyrightStrike(
          key: ValueKey('strike-$st'),
          kind: inter ? 'intervention' : 'avis',
          title: c['title'] as String,
          owner: owner,
          headline: inter ? 'TITRE SUSPENDU' : 'LITIGE DE DROITS D’AUTEUR',
          amount: crDue21(s),
          stakes: inter
              ? ['Le titre n’est plus écouté sur Ondéa et Cauri Music.', 'Ses revenus partent au titulaire des droits.', 'Retrait définitif le jour ${_n(c['due2']) + 1} sans règlement.']
              : ['Compensation ou retrait du titre des plateformes.', 'Réponse attendue avant le jour ${_n(c['due']) + 1}.', 'Payer, négocier, contester ou ignorer : chaque voie a un prix.'],
          onDone: () => doAct(context, ref, 'crSeen'),
        ),
      ]);
    }
    final song = _song(s, c['id']);
    return Frame21(children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            back,
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, b) => SceneBanner(
                kind: 'office',
                sceneAsset: inter || st == 'conteste' ? 'assets/svg/decor-tribunal.svg' : null,
                animate: true,
                height: b.maxWidth >= 600 ? 230 : 180,
                role: inter ? 'Intervention officielle' : st == 'conteste' ? 'Procédure en cours' : 'Avis de réclamation',
                name: owner,
                chars: [
                  BannerChar(c['owner'] as String, mood: inter ? 'angry' : 'serious', crop: 'torso', width: 108, left: b.maxWidth - 122),
                  const BannerChar('djo', mood: 'worried', crop: 'torso', width: 92, left: 24),
                ],
              ),
            ),
            const SizedBox(height: 12),
            EnterAnim(
              child: GlassCard(
                accent: GlassAccent.magenta,
                halo: false,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(inter ? 'INTERVENTION OFFICIELLE' : 'AVIS DE RÉCLAMATION', style: V20Text.lab(color: Tk.acc4))),
                    GameTag(crStatusLabel21[song == null ? 'litige' : crStatus21(song)] ?? '', style: GameTagStyle.accent),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                      inter
                          ? '« ${c['title']} » est suspendu des plateformes. Ses revenus sont versés à $owner jusqu’au règlement.'
                          : 'Ton morceau « ${c['title']} » fait l’objet d’une réclamation pour l’utilisation d’une instrumentale protégée. Le titulaire des droits demande une compensation financière ou le retrait du morceau.',
                      style: V20Text.bm),
                  const SizedBox(height: 8),
                  KeyVal('Titulaire des droits', owner),
                  KeyVal('Instru', '${Reg21.instrus[song?['inst']]?['n'] ?? '—'}'),
                  KeyVal('Statut de l’instru', crShortLabel21(c['kind'] as String)),
                  KeyVal('Écoutes du titre', fmt21(_n(song?['L'] ?? c['L']))),
                  KeyVal('Revenus du titre', '${fmt21(_n(song?['rev'] ?? c['rev']))} cauris'),
                  KeyVal('Montant réclamé', '${fmt21(_n(c['amt']))} cauris'),
                  Text('${(_n(c['pct']) * 100).round()} % des revenus du titre, jamais moins que le prix de la licence.', style: V20Text.bs()),
                  if (inter) KeyVal('À payer maintenant', '${fmt21(crDue21(s))} cauris (retard +${(CrReg21.latePct * 100).round()} %)'),
                  KeyVal('Délai', inter ? 'Retrait le jour ${_n(c['due2']) + 1}' : st == 'conteste' ? 'Décision le jour ${c['trial']}' : 'Réponse avant le jour ${_n(c['due']) + 1}'),
                  if (_t(s['signed'])) KeyVal('Ton label', '${lblName21(s)} prend ${(CrReg21.labelLegal * 100).round()} % des frais de négociation et d’avocat'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            if (st == 'conteste')
              _Contested(s, c)
            else ...[
              if (!inter && !_t(c['met']))
                _Choice(
                  index: 1,
                  title: 'Négocier un accord',
                  lines: [
                    (ConsequenceKind.certain, '${CrReg21.negoH} h · −${CrReg21.negoEn} énergie · −${fmt21(crNegoFee21(s))} cauris de frais'),
                    (ConsequenceKind.uncertain, 'Rendez-vous avec $owner : réduction possible, refus possible'),
                  ],
                  verb: 'Aller au rendez-vous',
                  onTap: () => doAct(context, ref, 'crNego', null, () => context.go('/droits/rendez-vous')),
                ),
              _Choice(
                index: 2,
                title: inter ? 'Payer pour rétablir le titre' : 'Payer immédiatement',
                lines: [
                  (ConsequenceKind.certain, '−${fmt21(crDue21(s))} cauris · le titre ${inter ? 'revient' : 'reste'} en ligne'),
                  (ConsequenceKind.certain, 'Litige clos · aucune autre réclamation sur ce titre'),
                ],
                verb: 'Payer ${fmt21(crDue21(s))}',
                onTap: () => doAct(context, ref, 'crPay', null, () => context.go('/'), 'Litige réglé'),
              ),
              if (!_t(c['contested']))
                _Choice(
                  index: 3,
                  title: 'Contester la réclamation',
                  lines: [
                    (ConsequenceKind.certain, 'Avocat à choisir · revenus du titre gelés ${CrReg21.contestDays} jours'),
                    (ConsequenceKind.risk, 'Défaite : montant +${(CrReg21.contestLossPct * 100).round()} % et réputation −2'),
                  ],
                  verb: 'Choisir un avocat',
                  onTap: () => _lawyerSheet(context, ref, s),
                ),
              if (!inter)
                _Choice(
                  index: 4,
                  title: 'Ignorer la réclamation',
                  lines: [
                    (ConsequenceKind.certain, 'Rien tout de suite'),
                    (ConsequenceKind.risk, 'Après le délai : titre suspendu, revenus au titulaire, montant +${(CrReg21.latePct * 100).round()} %'),
                  ],
                  verb: st == 'ignore' ? 'Déjà ignorée' : 'Ignorer',
                  onTap: st == 'ignore' ? null : () => doAct(context, ref, 'crIgnore', null, () => context.go('/')),
                )
              else
                _Choice(
                  index: 4,
                  title: 'Accepter le retrait',
                  lines: [
                    (ConsequenceKind.certain, 'Le titre quitte les plateformes · plus d’écoutes ni de ventes'),
                    (ConsequenceKind.certain, 'Popularité −${CrReg21.popLoss} · réputation −${CrReg21.repLoss} · fans −${(CrReg21.fansLoss * 100).round()} %'),
                  ],
                  verb: 'Retirer le titre',
                  onTap: () => doAct(context, ref, 'crDrop'),
                ),
              const SizedBox(height: 4),
              const GameHint(icon: 'info', text: 'Certain · Estimé · Incertain · Risque : chaque pastille annonce l’effet avant ton choix.'),
            ],
          ]),
        ),
      ),
    ]);
  }
}

bool _t(dynamic x) => x != null && x != 0 && x != false && x != '';

/// Statut court pour les pastilles (le libellé complet reste dans crStatusLabel21).
String crShortLabel21(String st) => const {
      'libre': 'Libre de droits', 'sec': 'Sécurisé', 'lic': 'Licence valide', 'exp': 'Licence expirée', 'cond': 'Avec conditions',
      'nonaut': 'Non autorisée', 'litige': 'Litige en cours', 'susp': 'Suspendu', 'regle': 'Réglé', 'rejete': 'Rejeté', 'retire': 'Retiré',
    }[st] ?? st;

class _Choice extends StatelessWidget {
  final int index;
  final String title, verb;
  final List<(ConsequenceKind, String)> lines;
  final VoidCallback? onTap;
  const _Choice({required this.index, required this.title, required this.lines, required this.verb, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: EnterAnim(
          index: index,
          child: GameCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: V20Text.nm()),
              const SizedBox(height: 4),
              for (final (k, x) in lines) Conseq21(k, x),
              const SizedBox(height: 8),
              PrimaryButton(label: verb, style: GameButtonStyle.secondary, onPressed: onTap),
            ]),
          ),
        ),
      );
}

class _Contested extends StatelessWidget {
  final J s, c;
  const _Contested(this.s, this.c);
  @override
  Widget build(BuildContext context) => GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Procédure en cours', style: V20Text.nm()),
          Text('Avocat : ${Reg21.lawyers[c['lawyer']]?['n'] ?? '—'} · décision le jour ${c['trial']}', style: V20Text.bs()),
          const SizedBox(height: 6),
          Conseq21(ConsequenceKind.certain, 'Revenus gelés pour l’instant : ${fmt21(_n(c['escrow']))} cauris'),
          Conseq21(_riskKind(crContestRisk21(s, '${c['lawyer']}')), 'Risque de défaite : ${crContestRisk21(s, '${c['lawyer']}')}'),
          const SizedBox(height: 8),
          Text('Termine tes journées : la décision arrive seule, à la date prévue.', style: V20Text.bs()),
        ]),
      );
}

void _lawyerSheet(BuildContext context, WidgetRef ref, J s) => showGameSheet<void>(
      context,
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Choisir un avocat', style: V20Text.nm()),
        const SizedBox(height: 4),
        Text('Les revenus du titre sont gelés pendant ${CrReg21.contestDays} jours, puis rendus si tu gagnes.', style: V20Text.bs()),
        const SizedBox(height: 12),
        for (final e in Reg21.lawyers.entries) ...[
          GameCard(
            onTap: () {
              Navigator.of(ctx).pop();
              doAct(context, ref, 'crContest', e.key, null, 'Contestation déposée');
            },
            child: Row(children: [
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${e.value['n']}', style: V20Text.nm()),
                Text('${e.value['role']}', style: V20Text.bs()),
                Conseq21(_riskKind(crContestRisk21(s, e.key)), 'Risque de défaite : ${crContestRisk21(s, e.key)}'),
              ])),
              const SizedBox(width: 8),
              Text(crLawyerCost21(s, e.key) == 0 ? 'Gratuit' : fmt21(crLawyerCost21(s, e.key)), style: V20Text.nm(color: Tk.gold)),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ]),
    );

/// Issue d'un litige (verdict de contestation ou retrait), avec la même mise en scène que l'avis.
class _Outcome extends ConsumerWidget {
  final J out;
  const _Outcome(this.out);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retrait = out['type'] == 'retrait';
    final win = _n(out['win']) == 1;
    return CopyrightStrike(
      key: ValueKey('out-${out['type']}-${out['day']}'),
      kind: retrait ? 'retrait' : 'verdict',
      title: out['title'] as String,
      owner: retrait ? 'Plateformes Ondéa et Cauri Music' : (win ? 'Réclamation rejetée' : 'Réclamation confirmée'),
      headline: retrait ? 'TITRE RETIRÉ' : (win ? 'CONTESTATION GAGNÉE' : 'CONTESTATION PERDUE'),
      amount: retrait ? 0 : (win ? _n(out['esc']) : _n(out['owe'])),
      stakes: retrait
          ? ['Le titre reste dans ta discographie avec le statut « Retiré pour litige de droits d’auteur ».', 'Plus d’écoutes, plus de ventes, plus de classement.', 'Popularité −${out['pop']} · réputation −${out['rep']} · ${fmt21(_n(out['fans']))} fans perdus.']
          : win
              ? ['Les revenus gelés te sont rendus.', 'Réputation +1. Le titre est désormais protégé.']
              : ['Montant majoré de ${(CrReg21.contestLossPct * 100).round()} %, payé en partie avec les revenus gelés.', 'Réputation −2. Le titre reste en ligne.'],
      action: 'Compris',
      onDone: () => doAct(context, ref, 'crSeen', 'out', () => context.go('/')),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-DA2 Rendez-vous avec le producteur : négociation en deux échanges, tension visible
// ---------------------------------------------------------------------------------------------------------------------

class RendezVousScreen extends ConsumerWidget {
  const RendezVousScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final c = crClaim21(s);
    if (c == null || c['st'] != 'nego') return const LitigeScreen();
    final owner = crOwnerName21(c['owner']);
    final node = (c['node'] ?? 'n1') as String;
    final amt = _n(c['amt']);
    final half = (amt * .5).round();
    final tension = _n(c['tension']).toInt();
    final q = switch (node) {
      'counter' => '« La moitié ? Non. Je descends à ${fmt21(_n(c['counter']))}, pas un cauri de moins. Mon instru a fait ton succès. »',
      'refus' => '« Tu me prends pour qui ? Mon nom n’est même pas crédité. C’est ${fmt21(amt)}, ou on se revoit devant un juge. »',
      _ => '« Ton morceau tourne partout, et c’est mon instru. Je réclame ${fmt21(amt)} cauris. Qu’est-ce que tu proposes ? »',
    };
    final song = _song(s, c['id']);
    return Frame21(children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            BackHeader(title: 'Rendez-vous', step: 'Tension $tension/2', onBack: () => context.go('/')),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, b) => SceneBanner(
                kind: 'studio',
                animate: true,
                height: b.maxWidth >= 600 ? 250 : 190,
                role: 'Titulaire des droits',
                name: owner,
                chars: [
                  BannerChar(c['owner'] as String, mood: _ownerMood(node), crop: 'torso', width: 108, left: b.maxWidth - 122),
                  BannerChar('djo', mood: node == 'n1' ? 'poised' : 'worried', crop: 'torso', width: 92, left: 24),
                ],
              ),
            ),
            const SizedBox(height: 12),
            EnterAnim(
              key: ValueKey('rdv-$node'),
              child: GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('$owner · titulaire des droits'.toUpperCase(), style: V20Text.lab())),
                    GameTag(tension == 0 ? 'Calme' : tension == 1 ? 'Tendu' : 'Très tendu', style: tension == 0 ? GameTagStyle.outline : GameTagStyle.accent),
                  ]),
                  const SizedBox(height: 6),
                  Text(q, style: V20Text.bm.copyWith(fontSize: 16, height: 1.3)),
                  const SizedBox(height: 6),
                  Text('Revenus du titre : ${fmt21(_n(song?['rev'] ?? c['rev']))} cauris · réclamé : ${fmt21(amt)} cauris', style: V20Text.bs()),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            if (node == 'n1')
              _Choice(
                index: 2,
                title: 'Proposer la moitié',
                lines: [
                  (ConsequenceKind.estimated, '−${fmt21(half)} cauris si accepté'),
                  (_riskKind(crNegoRisk21(s, 'half')), 'Risque de refus : ${crNegoRisk21(s, 'half')} · relation −3 si refus'),
                ],
                verb: 'Proposer ${fmt21(half)}',
                onTap: () => doAct(context, ref, 'crOffer', 'half'),
              ),
            if (node == 'counter')
              _Choice(
                index: 2,
                title: 'Accepter sa contre-offre',
                lines: [(ConsequenceKind.certain, '−${fmt21(_n(c['counter']))} cauris · litige clos')],
                verb: 'Accepter ${fmt21(_n(c['counter']))}',
                onTap: () => doAct(context, ref, 'crOffer', 'counter', () => context.go('/'), 'Accord conclu'),
              ),
            _Choice(
              index: 3,
              title: 'Partager les revenus futurs',
              lines: [
                (ConsequenceKind.certain, 'Acompte −${fmt21((crLicenceFee21(song ?? const <String, dynamic>{}) / 2).round())} cauris · ${(CrReg21.share * 100).round()} % des revenus futurs du titre au titulaire'),
                (_riskKind(crNegoRisk21(s, 'share')), 'Risque de refus : ${crNegoRisk21(s, 'share')}'),
              ],
              verb: 'Proposer le partage',
              onTap: () => doAct(context, ref, 'crOffer', 'share', () {
                if (crClaim21(ref.read(game21Provider).valueOrNull ?? const <String, dynamic>{}) == null) context.go('/');
              }),
            ),
            _Choice(
              index: 4,
              title: 'Payer ce qu’il demande',
              lines: [(ConsequenceKind.certain, '−${fmt21(amt)} cauris · litige clos · relation préservée')],
              verb: 'Payer ${fmt21(amt)}',
              onTap: () => doAct(context, ref, 'crOffer', 'full', () => context.go('/'), 'Litige réglé'),
            ),
            _Choice(
              index: 5,
              title: 'Quitter le rendez-vous',
              lines: [
                (ConsequenceKind.certain, 'Relation avec $owner −10 · pas de second rendez-vous'),
                (ConsequenceKind.risk, 'L’avis reste ouvert : payer, contester ou laisser passer le délai'),
              ],
              verb: 'Partir',
              onTap: () => doAct(context, ref, 'crOffer', 'leave', () => context.go('/droits')),
            ),
            const SizedBox(height: 4),
            const GameHint(icon: 'info', text: 'Ton label, ton manager et ta relation avec le producteur rendent un accord plus probable. Le ton monte à chaque refus.'),
          ]),
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Carte « Droits d'auteur » de la fiche d'un titre (catalogue)
// ---------------------------------------------------------------------------------------------------------------------

class RightsCard extends ConsumerWidget {
  final J s, t;
  const RightsCard(this.s, this.t, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cr = crOf21(t);
    final st = cr['st'] as String;
    final risk = crRiskLevel21(s, t);
    final inst = Reg21.instrus[t['inst']];
    final risky = crRisky21.contains(st) && !_t(cr['claimed']);
    final off = st == 'retire' || st == 'susp' || st == 'litige';
    return GlassCard(
      accent: off ? GlassAccent.magenta : GlassAccent.none,
      halo: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('DROITS D’AUTEUR', style: V20Text.lab())),
          GameTag(crShortLabel21(st), style: off ? GameTagStyle.accent : (risky ? GameTagStyle.outline : GameTagStyle.ok)),
        ]),
        KeyVal('Instru', inst == null ? '—' : '${inst['n']} · ${inst['who']}'),
        if (cr['lic'] == 'nonexcl') KeyVal('Licence', 'Non exclusive · ${fmt21(_n(cr['cap']))} écoutes · jusqu’au jour ${cr['until'] ?? '—'}'),
        if (cr['lic'] == 'excl') const KeyVal('Licence', 'Exclusive, sans limite'),
        if (cr['lic'] == 'prod') const KeyVal('Licence', 'Production Studio Kôrô : droits cédés'),
        if (_n(cr['share']) > 0) KeyVal('Rétrocession', '${(_n(cr['share']) * 100).round()} % des revenus futurs au titulaire (${fmt21(_n(cr['shared']))} versés)'),
        if (risky) ...[
          const SizedBox(height: 4),
          Conseq21(risk == 'Faible' || risk == 'Aucun' ? ConsequenceKind.estimated : ConsequenceKind.risk, 'Risque de réclamation : $risk (grandit avec les écoutes et le classement)'),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Acheter la licence · ${fmt21(crRegPrice21(t))}',
            style: GameButtonStyle.secondary,
            onPressed: () async {
              final ok = await confirmSheet(context, title: 'Acheter la licence ?', body: '${fmt21(crRegPrice21(t))} cauris à ${crOwnerName21(cr['owner'])}. Le titre ne pourra plus faire l’objet d’une réclamation.', action: 'Acheter');
              if (ok && context.mounted) await doAct(context, ref, 'crReg', t['id'], null, 'Licence achetée');
            },
          ),
        ],
        if (st == 'retire' || st == 'susp' || st == 'litige') Padding(padding: const EdgeInsets.only(top: 4), child: Text(crStatusLabel21[st] ?? st, style: V20Text.bs())),
        if (st == 'litige' || st == 'susp') ...[
          const SizedBox(height: 8),
          PrimaryGlowButton(label: 'Voir le litige', onPressed: () => context.go('/droits')),
        ],
      ]),
    );
  }
}
