import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_icon.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/mini_game_parts.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../domain/minigame.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'widgets21.dart';

/// Studio v21 : création (21-M1), instru (21-M6), cabine (21-M7) et mix (21-M8).
/// Intention de jeu : le joueur fabrique un titre étape par étape ; chaque étape montre ce qu'elle coûte avant qu'il la lance.
/// Aucune navigation automatique : après la cabine, un bouton « Écouter le mix » apparaît et c'est le joueur qui le touche.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic>
    ? x
    : x is Map
        ? x.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

String _feats(J song) {
  final f = _l(song['feats']).cast<String>();
  return f.isEmpty ? 'Aucun' : f.map((k) => '${Reg21.feats[k]!['n']} (${Reg21.feats[k]!['role']})').join(' · ');
}

/// Bandeau d'étapes de la planche M1 : Création, Production, Sortie, Résultats.
class _StudioSteps extends StatelessWidget {
  final int done;
  const _StudioSteps(this.done);
  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  height: 6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: i < done ? Tk.ok : const Color.fromRGBO(255, 255, 255, .14))),
              const SizedBox(height: 4),
              Text(['Création', 'Production', 'Sortie', 'Résultats'][i].toUpperCase(),
                  style: V20Text.poppins(size: 10, line: 12, weight: FontWeight.w700, color: V20.ink2, spacing: .4)),
            ]),
          ),
        ],
      ]);
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M1 Studio
// ---------------------------------------------------------------------------------------------------------------------

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});
  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen> {
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final ui = _m(s['ui']);
    final cur = s['cur'] as J?;
    final th = (ui['th'] ?? 'quartier') as String, am = (ui['am'] ?? 'sombre') as String;
    final st = cur?['st'] as String?;
    final steps = st == 'ecrit' ? 1 : (st == 'enregistre' ? 2 : 0);
    final hs = _m(s['own'])['homestudio'] != null;
    final nothingYet = _l(s['disco']).isEmpty && cur == null;
    Future<void> set(String name, String id) => ref.read(game21Provider.notifier).act(name, id);
    if (_title.text.isEmpty && (ui['title'] ?? '') != '' && !FocusScope.of(context).hasFocus) {
      _title.text = ui['title'] as String;
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('STUDIO', style: V20Text.dm()),
        GameTag('${_l(s['disco']).length} sorti(s)'),
      ]),
      const SizedBox(height: 12),
      _StudioSteps(steps),
      const SizedBox(height: 12),
      if (cur == null) ...[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text('NOUVEAU TITRE · CRÉATION MANUELLE', style: V20Text.lab())),
          const SizedBox(width: 8),
          const GameTag('Validé D-G03', style: GameTagStyle.ok),
        ]),
        const SizedBox(height: 8),
        const Lab21('Thème'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in Reg21.themes.entries) Chip21(e.value['n'] as String, selected: th == e.key, onTap: () => set('th', e.key)),
        ]),
        const SizedBox(height: 8),
        const Lab21('Ambiance'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in Reg21.ambs.entries) Chip21(e.value['n'] as String, selected: am == e.key, onTap: () => set('am', e.key)),
        ]),
        const SizedBox(height: 8),
        Conseq21(ConsequenceKind.certain, '1 h · −20 énergie${_n(s['en']) < 20 ? ' (énergie insuffisante : termine la journée)' : ''}'),
        const Conseq21(ConsequenceKind.estimated, 'Le thème et l’ambiance modifient la note du texte et la viralité.'),
        const SizedBox(height: 8),
        const Lab21('Titre du morceau (facultatif)'),
        TextField(
          controller: _title,
          maxLength: 30,
          onChanged: (v) => ref.read(game21Provider.notifier).act('setui', 'title=$v'),
          style: V20Text.nm(),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'LAISSE VIDE : UN TITRE DU THÈME',
            hintStyle: V20Text.nm(color: V20.ink2.withValues(alpha: .5)),
            filled: true,
            fillColor: Tk.s1,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.acc, width: 2)),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip21('Titre aléatoire', onTap: () {
            _title.clear();
            set('rtitle', '');
          }),
        ),
        const SizedBox(height: 12),
        PrimaryGlowButton(
          label: 'Écrire le texte',
          sublabel: 'Création manuelle',
          onPressed: () => doAct(context, ref, 'create', null, _title.clear),
        ),
        const SizedBox(height: 12),
        GameCard(
          onTap: () => doAct(context, ref, 'create', 'random', _title.clear),
          child: Row(children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Inspiration aléatoire', style: V20Text.nm()),
              Text('Thème et ambiance tirés au hasard', style: V20Text.bs()),
            ])),
            const GameTag('Nouveau', style: GameTagStyle.ok),
          ]),
        ),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(st == 'ecrit' ? 'TEXTE ÉCRIT · CHOISIS UNE INSTRU' : 'ENREGISTRÉ · PRÊT À SORTIR', style: V20Text.lab(color: V20.accText)),
            const SizedBox(height: 4),
            Text(cur['title'] as String, style: V20Text.baloo(size: 24, line: 26)),
            const SizedBox(height: 8),
            KeyVal('Thème · ambiance', '${Reg21.themes[cur['theme']]!['n']} · ${Reg21.ambs[cur['amb']]!['n']}'),
            KeyVal('Note du texte', '${cur['tx']}'),
            if (st == 'enregistre') ...[
              KeyVal('Instru', '${instName21(cur)} · production ${cur['prod']}'),
              KeyVal('Prises', _l(cur['takes']).join(' · ')),
            ],
            KeyVal('Qualité (après enregistrement)', st == 'enregistre' ? '${cur['Q']}' : '—'),
            KeyVal('Viralité estimée', '${virOf21(cur, _n(ui['promo']).toInt())}'),
            KeyVal('Featurings', _feats(cur)),
          ]),
        ),
        const SizedBox(height: 12),
        if (st == 'ecrit')
          PrimaryGlowButton(
              label: 'Choisir l’instru, puis la cabine',
              sublabel: 'Instru (04.3) · cabine 2 h · −${hs ? 15 : 25} énergie (−15 avec home studio)',
              onPressed: () => context.go('/studio/instru')),
        if (st == 'enregistre') ...[
          PrimaryGlowButton(label: 'Préparer la sortie', sublabel: 'Promo · prévision', onPressed: () => context.go('/studio/sortie')),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Voir le mix', style: GameButtonStyle.secondary, onPressed: () => context.go('/studio/mix')),
        ],
      ],
      const SizedBox(height: 12),
      GameCard(
        onTap: () => context.go('/studio/catalogue'),
        child: Row(children: [
          const GameIcon('music', color: Tk.cy),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Catalogue, EP et album', style: V20Text.nm()),
            Text('${_l(s['disco']).length} titre(s) sorti(s) · fiches, crédits, projets', style: V20Text.bs()),
          ])),
          const GameIcon('arrow', color: Tk.ink),
        ]),
      ),
      const SizedBox(height: 8),
      GameCard(
        onTap: () => context.go('/studio/feats'),
        child: Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Featurings', style: V20Text.nm()),
            Text('${_l(cur?['feats']).length}/${Reg21.maxFeats} artistes', style: V20Text.bs()),
          ])),
          const GameIcon('arrow', color: Tk.ink),
        ]),
      ),
      const SizedBox(height: 8),
      GameCard(
        onTap: () => context.go('/studio/clip'),
        child: Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Clip', style: V20Text.nm()),
            Text('À préparer avant la sortie', style: V20Text.bs()),
          ])),
          const GameIcon('arrow', color: Tk.ink),
        ]),
      ),
      const SizedBox(height: 12),
      GameHint(
          icon: 'info',
          text: nothingYet
              ? 'Instru, cabine et mix : un titre se fait en trois temps. Un titre non sorti n’apparaît pas dans la discographie.'
              : 'Un titre non sorti n’apparaît pas dans la discographie. Un clip se prépare avant la sortie.'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M6 Instru
// ---------------------------------------------------------------------------------------------------------------------

class Instru21Screen extends ConsumerWidget {
  const Instru21Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final picked = _m(s['ui'])['inst'] as String?;
    final canRecord = cur != null && cur['st'] == 'ecrit';
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Choisis une instru', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (cur != null)
        GlassCard(
            accent: GlassAccent.magenta,
            halo: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TITRE EN COURS', style: V20Text.lab()),
              Text(cur['title'] as String, style: V20Text.nm()),
              Text('Note du texte ${cur['tx']}', style: V20Text.bs()),
            ])),
      for (final entry in Reg21.instrus.entries) ...[
        const SizedBox(height: 8),
        _InstruCard(id: entry.key, data: entry.value, s: s, selected: picked == entry.key),
      ],
      const SizedBox(height: 8),
      const Conseq21(ConsequenceKind.certain,
          'L’instru est payée une fois, au moment du choix. Sans choix, la cabine utilise « Nuit à Ndo », gratuite.'),
      const Conseq21(ConsequenceKind.estimated, 'La qualité de l’instru compte pour 35 % de la note finale du titre.'),
      const SizedBox(height: 12),
      PrimaryGlowButton(
        label: canRecord ? 'Passer en cabine' : 'Écris d’abord le texte',
        sublabel: canRecord ? 'Instru : ${Reg21.instrus[picked ?? 'nuit']!['n']}' : null,
        onPressed: canRecord ? () => context.go('/studio/cabine') : null,
      ),
    ]);
  }
}

class _InstruCard extends ConsumerWidget {
  final String id;
  final J data, s;
  final bool selected;
  const _InstruCard({required this.id, required this.data, required this.s, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = _n(data['cost']);
    final rankLock = _n(s['rank']) < _n(data['rank']);
    final repLock = data['rep'] != null && _n(s['rep']) < _n(data['rep']);
    final lock = rankLock || repLock;
    final short = !lock && !selected && _n(s['cash']) < price;
    return GameCard(
      selected: selected,
      onTap: () => doAct(context, ref, 'pick', id),
      child: Row(children: [
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['n'] as String, style: V20Text.nm()),
          Text('${data['who']} · qualité de production ${data['Q']}', style: V20Text.bs()),
          if (rankLock) Text('Rang N${data['rank']} requis', style: V20Text.bs(color: V20.hintGoldText)),
          if (repLock) Text('Réputation ${data['rep']} requise', style: V20Text.bs(color: V20.hintGoldText)),
          if (short) Text('Il manque ${fmt21(price - _n(s['cash']))} cauris', style: V20Text.bs(color: V20.hintGoldText)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price == 0 ? 'Gratuite' : fmt21(price), style: V20Text.nm(color: Tk.gold)),
          const SizedBox(height: 4),
          if (selected) const GameTag('Choisie', style: GameTagStyle.ok) else if (lock) const GameTag('Verrou', style: GameTagStyle.outline),
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M7 Cabine
// ---------------------------------------------------------------------------------------------------------------------

/// Trois prises chronométrées (mini-jeu v20). Les trois valeurs partent d'un coup à `record` ; ensuite le joueur touche « Écouter le mix ».
class Cabine21Screen extends ConsumerStatefulWidget {
  const Cabine21Screen({super.key});
  @override
  ConsumerState<Cabine21Screen> createState() => _Cabine21ScreenState();
}

class _Cabine21ScreenState extends ConsumerState<Cabine21Screen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _now = Duration.zero, _takeStart = Duration.zero;
  final List<int> _takes = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) setState(() => _now = elapsed);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _cursor => cursorAt((_now - _takeStart).inMicroseconds / Duration.microsecondsPerSecond);

  Future<void> _record(List<int> values) async {
    setState(() => _busy = true);
    final error = await ref.read(game21Provider.notifier).act('record', values);
    if (!mounted) return;
    if (error != null) {
      toastErr(context, error);
      setState(() {
        _busy = false;
        _takes.clear();
        _takeStart = _now;
      });
      return;
    }
    setState(() => _busy = false);
  }

  Future<void> _rec() async {
    if (_busy || _takes.length >= 3) return;
    final score = takeScore(_cursor, _takes.length);
    HapticFeedback.lightImpact();
    setState(() {
      _takes.add(score);
      _takeStart = _now;
    });
    if (_takes.length == 3) {
      HapticFeedback.mediumImpact();
      await _record(List.of(_takes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final recorded = cur != null && cur['st'] == 'enregistre';
    final ready = cur != null && cur['st'] == 'ecrit';
    final shown = recorded && _takes.isEmpty ? _l(cur['takes']).cast<num>().map((e) => e.toInt()).toList() : _takes;
    final hs = _m(s['own'])['homestudio'] != null;
    final energyCost = hs ? 15 : 25;
    final inst = Reg21.instrus[_m(s['ui'])['inst'] ?? 'nuit']!;
    final take = _takes.length.clamp(0, takesPerSession - 1);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Session cabine', step: '2 h · −$energyCost énergie', onBack: () => context.go('/studio/instru')),
      const SizedBox(height: 12),
      LayoutBuilder(
          builder: (context, c) => SceneBanner(
                kind: 'studio',
                height: 150,
                role: 'Cabine · Studio Kôrô',
                subtitle: 'Instru : ${recorded ? instName21(cur) : inst['n']}',
                chars: [
                  BannerChar('kore', mood: 'neutral', crop: 'torso', width: 92, left: c.maxWidth - 120),
                  const BannerChar('djo', mood: 'serious', gesture: 'mic', crop: 'torso', width: 92, left: 18),
                ],
              )),
      const SizedBox(height: 12),
      if (!ready && !recorded) ...[
        const GameHint(icon: 'info', text: 'Aucun texte à enregistrer. Écris d’abord un titre au studio.'),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ] else ...[
        Row(children: [
          for (var i = 0; i < takesPerSession; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: i < shown.length ? TakeChip('Prise ${i + 1} · ${shown[i]}', done: true) : TakeChip('Prise ${i + 1}')),
          ]
        ]),
        const SizedBox(height: 14),
        GlassCard(
            accent: GlassAccent.cyan,
            halo: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              MiniGameTrack(cursor: recorded || _busy ? .5 : _cursor, zone: zoneCenter(take)),
              const SizedBox(height: 12),
              Text(
                  recorded
                      ? 'Trois prises enregistrées : écoute ton mix.'
                      : (_takes.isEmpty ? 'Appuie sur REC quand le curseur est dans la zone verte. Trois prises : leur moyenne donne ta note de voix.' : takeMessage(_takes.last)),
                  textAlign: TextAlign.center,
                  style: V20Text.bs()),
              const SizedBox(height: 12),
              Center(child: RecButton(onPressed: recorded || _busy ? null : _rec)),
            ])),
        const SizedBox(height: 12),
        if (recorded)
          PrimaryGlowButton(label: 'Écouter le mix', onPressed: () => context.go('/studio/mix'))
        else
          PrimaryButton(
              label: 'Enregistrer sans le mini-jeu',
              sublabel: 'Prises ${Reg21.takesDefault.join(' · ')} (accessibilité)',
              style: GameButtonStyle.secondary,
              onPressed: _busy || _takes.isNotEmpty ? null : () => _record(List.of(Reg21.takesDefault))),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M8 Mix
// ---------------------------------------------------------------------------------------------------------------------

class Mix21Screen extends ConsumerWidget {
  const Mix21Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final done = cur != null && cur['st'] == 'enregistre';
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Mix et note', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (!done) ...[
        GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aucun titre enregistré', style: V20Text.nm()),
          const SizedBox(height: 4),
          Text('Écris un texte, choisis une instru, puis passe en cabine.', style: V20Text.bs()),
        ])),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ] else ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: V20.objective, borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MIX TERMINÉ', style: V20Text.lab(color: Colors.white)),
            Text((cur['title'] as String).toUpperCase(), style: V20Text.baloo(size: 26, line: 28)),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'Qualité ', style: V20Text.bm),
              TextSpan(text: '${cur['Q']}', style: V20Text.bm.copyWith(fontWeight: FontWeight.w800)),
              TextSpan(text: ' / 100', style: V20Text.bm),
            ])),
          ]),
        ),
        const SizedBox(height: 8),
        KpiRow(children: [
          StatKpi(label: 'Texte', value: '${cur['tx']}', delta: '35 %'),
          StatKpi(label: 'Voix', value: '${cur['voix']}', delta: '30 % · prises'),
        ]),
        const SizedBox(height: 8),
        KpiRow(children: [
          StatKpi(label: 'Production', value: '${cur['prod']}', delta: '35 % · instru'),
          StatKpi(label: 'Prises', value: _l(cur['takes']).join(' · ')),
        ]),
        const SizedBox(height: 12),
        const Conseq21(ConsequenceKind.certain,
            'Qualité = 0,35 × texte + 0,30 × voix + 0,35 × production − fatigue, + bonus des featurings (règle v20, 04.9).'),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Préparer la sortie', onPressed: () => context.go('/studio/sortie')),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _MixTile('users', 'Featurings', '${_l(cur['feats']).length}/${Reg21.maxFeats}', () => context.go('/studio/feats'))),
            const SizedBox(width: 8),
            Expanded(child: _MixTile('music', 'Clip', 'À préparer avant la sortie', () => context.go('/studio/clip'))),
          ]),
        ),
      ],
    ]);
  }
}

class _MixTile extends StatelessWidget {
  final String icon, title, sub;
  final VoidCallback onTap;
  const _MixTile(this.icon, this.title, this.sub, this.onTap);
  @override
  Widget build(BuildContext context) => GameCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(gradient: V20.objective, borderRadius: BorderRadius.circular(12)),
          child: Center(child: GameIcon(icon, size: 20, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        Text(title, style: V20Text.nm()),
        Text(sub, style: V20Text.bs()),
      ]));
}
