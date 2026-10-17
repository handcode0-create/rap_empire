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
import '../../core/widgets/game_cover.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/mini_game_parts.dart';
import '../../core/widgets/portrait.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import '../../domain/minigame.dart';
import 'widgets21.dart';

/// Studio v21 : création v21 complétée par les instrus, prises et mix du studio v20.

num _n(dynamic x) => (x ?? 0) as num;
// Les anciennes sauvegardes et les fixtures de démo peuvent contenir des
// ImmutableMap<dynamic, dynamic>; les vues ne modifient jamais ces maps.
J _m(dynamic x) => x is Map<String, dynamic>
    ? x
    : x is Map
        ? x.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
List _l(dynamic x) => x as List;

String _feats(J song) {
  final f = _l(song['feats']).cast<String>();
  return f.isEmpty
      ? 'Aucun'
      : f
          .map((k) => '${Reg21.feats[k]!['n']} (${Reg21.feats[k]!['role']})')
          .join(' · ');
}

num _projectForecast(J s, J project, int promo) {
  var fans = _n(s['fans']);
  num total = 0;
  for (final raw in _l(project['tracks'])) {
    final track = _m(raw);
    final vir = virOf21(track, promo);
    final listens = listensFor21(_n(track['Q']), fans, promo) *
        (0.8 + vir / 250) * featBoost21(track);
    total += listens;
    fans += listens * 0.07 / (1 + fans / Reg21.fanSat);
  }
  return total;
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M1 Studio : création d'un titre
// ---------------------------------------------------------------------------------------------------------------------

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});
  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen> {
  final _title = TextEditingController();
  final _projectTitle = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _projectTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final ui = _m(s['ui']);
    final cur = s['cur'] as J?;
    final project = s['project'] == null ? null : _m(s['project']);
    final projectTracks = project == null ? <J>[] : _l(project['tracks']).map((t) => _m(t)).toList();
    final th = (ui['th'] ?? 'quartier') as String,
        am = (ui['am'] ?? 'sombre') as String;
    final st = cur?['st'] as String?;
    final steps = st == null
        ? 0
        : (st == 'draft'
            ? 1
            : (st == 'instrumental' ? 2 : (st == 'ecrit' ? 3 : 4)));
    final hs = _m(s['own'])['homestudio'] != null;
    Future<void> set(String name, String id) =>
        ref.read(game21Provider.notifier).act(name, id);
    if (_title.text.isEmpty &&
        (ui['title'] ?? '') != '' &&
        !FocusScope.of(context).hasFocus) {
      _title.text = ui['title'] as String;
    }
    if (_projectTitle.text.isEmpty && (ui['projectTitle'] ?? '') != '') {
      _projectTitle.text = ui['projectTitle'] as String;
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('STUDIO', style: V20Text.dm()),
        GameTag('${_l(s['disco']).length} sorti(s)'),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  height: 6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: i < steps ||
                              (i == 4 &&
                                  _l(s['disco']).isNotEmpty &&
                                  cur == null)
                          ? Tk.ok
                          : const Color.fromRGBO(255, 255, 255, .14))),
              const SizedBox(height: 4),
              Text(
                  ['Titre', 'Instru', 'Écriture', 'Cabine', 'Sortie'][i]
                      .toUpperCase(),
                  style: V20Text.poppins(
                      size: 10,
                      line: 12,
                      weight: FontWeight.w700,
                      color: V20.ink2,
                      spacing: .4)),
            ]),
          ),
        ],
      ]),
      const SizedBox(height: 12),
      if (cur == null) ...[
        if (project == null) ...[
          const Lab21('Format de sortie'),
          TextField(
            controller: _projectTitle,
            maxLength: 40,
            onChanged: (v) => ref.read(game21Provider.notifier).act('setui', 'projectTitle=$v'),
            style: V20Text.nm(),
            decoration: const InputDecoration(labelText: 'Nom de l’EP ou de l’album', counterText: ''),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Chip21('Créer un EP · 3 à 7 titres', onTap: () => doAct(context, ref, 'projectStart', 'ep')),
            Chip21('Créer un album · dès 8 titres*', onTap: () => doAct(context, ref, 'projectStart', 'album')),
          ]),
          Text('* Seuil album provisoire. L’EP suit la planche : 3 à 7 titres.', style: V20Text.bs()),
        ] else ...[
          GlassCard(
            accent: GlassAccent.cyan,
            halo: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${project['format'] == 'ep' ? 'EP' : 'ALBUM'} EN PRÉPARATION', style: V20Text.lab()),
              Text('${project['title'] ?? (_projectTitle.text.trim().isEmpty ? 'Projet sans titre' : _projectTitle.text.trim())} · ${projectTracks.length}/${Reg21.projectMinTracks[project['format']] ?? 999} titres minimum', style: V20Text.nm()),
              for (var i = 0; i < projectTracks.length; i++)
                Text('${i + 1}. ${projectTracks[i]['title']} · qualité ${projectTracks[i]['Q']}', style: V20Text.bs()),
              if (projectTracks.length >= (Reg21.projectMaxTracks[project['format']] ?? 999))
                const Text('Maximum de 7 titres atteint.'),
              if (projectTracks.length >= (Reg21.projectMinTracks[project['format']] ?? 999))
                PrimaryButton(label: 'Préparer la sortie', onPressed: () => context.go('/studio/sortie')),
            ]),
          ),
        ],
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
              child: Text('NOUVEAU TITRE · CRÉATION MANUELLE',
                  style: V20Text.lab())),
          const SizedBox(width: 8),
          const GameTag('Validé D-G03', style: GameTagStyle.ok)
        ]),
        const SizedBox(height: 8),
        const Lab21('Thème'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in Reg21.themes.entries)
            Chip21(e.value['n'] as String,
                selected: th == e.key, onTap: () => set('th', e.key))
        ]),
        const SizedBox(height: 8),
        const Lab21('Ambiance'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in Reg21.ambs.entries)
            Chip21(e.value['n'] as String,
                selected: am == e.key, onTap: () => set('am', e.key))
        ]),
        const SizedBox(height: 8),
        const Conseq21(ConsequenceKind.certain,
            'Création du titre sans coût · le temps et l’énergie sont pris à l’écriture.'),
        const Conseq21(ConsequenceKind.estimated,
            'Le thème et l’ambiance modifient la note du texte et la viralité.'),
        const SizedBox(height: 8),
        const Lab21('Titre du morceau (facultatif)'),
        TextField(
          controller: _title,
          maxLength: 30,
          onChanged: (v) =>
              ref.read(game21Provider.notifier).act('setui', 'title=$v'),
          style: V20Text.nm(),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'LAISSE VIDE : UN TITRE DU THÈME',
            hintStyle: V20Text.nm(color: V20.ink2.withValues(alpha: .5)),
            filled: true,
            fillColor: Tk.s1,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Tk.line, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Tk.line, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Tk.acc, width: 2)),
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
          label: 'Créer le titre',
          sublabel: 'Thème · ambiance · titre',
          onPressed: () => doAct(context, ref, 'draft', null, () {
            _title.clear();
            context.go('/studio/instru');
          }),
        ),
        const SizedBox(height: 12),
        GameCard(
          onTap: () => doAct(context, ref, 'draft', 'random', () {
            _title.clear();
            context.go('/studio/instru');
          }),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Inspiration aléatoire', style: V20Text.nm()),
                  Text('Thème et ambiance tirés au hasard', style: V20Text.bs())
                ])),
            const Icon(Icons.casino_outlined, color: Tk.ink),
          ]),
        ),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                st == 'draft'
                    ? 'TITRE CRÉÉ · CHOISIS UNE INSTRU'
                    : (st == 'instrumental'
                        ? 'INSTRU CHOISIE · ÉCRIS LE TEXTE'
                        : (st == 'ecrit'
                            ? 'TEXTE ÉCRIT · PRÊT POUR LA CABINE'
                            : 'ENREGISTRÉ · PRÊT À SORTIR')),
                style: V20Text.lab(color: V20.accText)),
            const SizedBox(height: 4),
            Text(cur['title'] as String,
                style: V20Text.baloo(size: 24, line: 26)),
            const SizedBox(height: 8),
            KeyVal('Thème · ambiance',
                '${Reg21.themes[cur['theme']]!['n']} · ${Reg21.ambs[cur['amb']]!['n']}'),
            KeyVal('Note du texte', '${cur['tx']}'),
            if (cur['inst'] != null)
              KeyVal('Instru', '${instName21(cur)} · qualité ${instQ21(cur)}'),
            if (st == 'enregistre')
              KeyVal('Prises', _l(cur['takes'] ?? const []).join(' · ')),
            KeyVal('Qualité (après enregistrement)',
                st == 'enregistre' ? '${cur['Q']}' : '—'),
            KeyVal(
                'Viralité estimée', '${virOf21(cur, _n(ui['promo']).toInt())}'),
            KeyVal('Featurings', _feats(cur)),
          ]),
        ),
        const SizedBox(height: 12),
        if (st == 'draft')
          PrimaryGlowButton(
              label: 'Choisir une instru',
              onPressed: () => context.go('/studio/instru')),
        if (st == 'instrumental')
          PrimaryGlowButton(
              label: 'Écrire le texte',
              sublabel: '1 h · −20 énergie',
              onPressed: () => context.go('/studio/ecriture')),
        if (st == 'ecrit')
          PrimaryGlowButton(
              label: 'Entrer en cabine',
              sublabel: '2 h · −${hs ? 15 : 25} énergie',
              onPressed: () => context.go('/studio/cabine')),
        if (st == 'enregistre' && project == null)
          PrimaryGlowButton(
              label: 'Préparer la sortie',
              sublabel: 'Promo · prévision',
              onPressed: () => context.go('/studio/sortie')),
        if (st == 'enregistre' && project != null)
          PrimaryButton(
            label: 'Ajouter au ${project['format'] == 'ep' ? 'EP' : 'album'}',
            style: GameButtonStyle.secondary,
            onPressed: () => doAct(context, ref, 'projectAdd', null, () => context.go('/studio')),
          ),
      ],
      const SizedBox(height: 12),
      GameCard(
        onTap: () => context.go('/studio/feats'),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Featurings', style: V20Text.nm()),
                Text(
                    '${_l(cur?['feats'] ?? const []).length}/${Reg21.maxFeats} artistes',
                    style: V20Text.bs())
              ])),
          const Icon(Icons.arrow_forward_rounded, color: Tk.ink),
        ]),
      ),
      const SizedBox(height: 8),
      GameCard(
        onTap: () => context.go('/studio/clip'),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Clip', style: V20Text.nm()),
                Text('À préparer avant la sortie', style: V20Text.bs())
              ])),
          const Icon(Icons.arrow_forward_rounded, color: Tk.ink),
        ]),
      ),
      const SizedBox(height: 8),
      GameCard(
        onTap: () => context.go('/studio/catalogue'),
        child: Row(children: [
          const Icon(Icons.library_music_outlined, color: Tk.cy),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Mon catalogue', style: V20Text.nm()),
                Text(
                    '${_l(s['disco']).length} sortie(s) · singles, EP et albums',
                    style: V20Text.bs()),
              ])),
          const Icon(Icons.arrow_forward_rounded, color: Tk.ink),
        ]),
      ),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'Les singles sortent seuls. Un EP regroupe 3 à 7 titres ; un album demande 8 titres minimum. Ajoute chaque titre terminé au projet avant de créer le suivant.'),
    ]);
  }
}

/// Choix d'instrumentales v20 dans la sauvegarde v21.
class Instru21Screen extends ConsumerWidget {
  const Instru21Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Choisir une instru', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (cur != null)
        GlassCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cur['title'] as String, style: V20Text.nm()),
          Text(
              '${Reg21.themes[cur['theme']]!['n']} · ${Reg21.ambs[cur['amb']]!['n']}',
              style: V20Text.bs()),
        ])),
      for (final entry in instrus21.entries) ...[
        const SizedBox(height: 10),
        _Instru21Card(
            id: entry.key,
            data: entry.value,
            s: s,
            selected: (cur?['instId'] ?? cur?['inst']) == entry.key),
      ],
      const SizedBox(height: 8),
      const GameHint(
          icon: 'info',
          text:
              "Les quatre instrumentales de game.js : prix et qualité sont affichés avant l'achat. Lagune d'Ambre demande 30 de réputation."),
    ]);
  }
}

class _Instru21Card extends ConsumerWidget {
  final String id;
  final J data, s;
  final bool selected;
  const _Instru21Card(
      {required this.id,
      required this.data,
      required this.s,
      required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = _n(data['price']);
    final rankLock = _n(s['rank']) < _n(data['lvl']);
    final repLock = _n(s['rep']) < _n(data['rep']);
    final cashLock = _n(s['cash']) < price;
    final blocked = rankLock || repLock || cashLock;
    return GameCard(
        selected: selected,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.graphic_eq_rounded, color: Tk.acc, size: 30),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(data['n'] as String, style: V20Text.nm()),
                  Text(data['who'] as String, style: V20Text.bs()),
                ])),
            Text(price == 0 ? 'Gratuite' : '${fmt21(price)} cauris',
                style: V20Text.nm(color: Tk.gold)),
          ]),
          const SizedBox(height: 8),
          KeyVal('Qualité production', '${data['q']} / 100'),
          if (rankLock)
            Text('Rang N${data['lvl']} requis',
                style: V20Text.bs(color: V20.hintGoldText)),
          if (repLock)
            Text('Réputation ${data['rep']} requise',
                style: V20Text.bs(color: V20.hintGoldText)),
          if (cashLock)
            Text('Il manque ${fmt21(price - _n(s['cash']))} cauris',
                style: V20Text.bs(color: V20.hintGoldText)),
          const SizedBox(height: 8),
          PrimaryButton(
              label: selected
                  ? 'Instru choisie'
                  : 'Choisir · ${price == 0 ? 'gratuit' : '−${fmt21(price)} cauris'}',
              style: selected
                  ? GameButtonStyle.ghost
                  : (blocked
                      ? GameButtonStyle.disabled
                      : GameButtonStyle.primary),
              onPressed: blocked
                  ? null
                  : () => doAct(context, ref, 'pickInstru', id,
                      () => context.go('/studio/ecriture'))),
        ]));
  }
}

class Ecriture21Screen extends ConsumerWidget {
  const Ecriture21Screen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: "Écriture", onBack: () => context.go('/studio/instru')),
      const SizedBox(height: 12),
      if (cur != null)
        GlassCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cur['title'] as String, style: V20Text.dm(size: 26)),
          KeyVal('Thème', Reg21.themes[cur['theme']]!['n'] as String),
          KeyVal('Instru', '${instName21(cur)} · qualité ${instQ21(cur)}'),
          KeyVal('Note du texte', '${cur['tx']} / 100'),
        ])),
      const SizedBox(height: 12),
      if (cur?['st'] == 'instrumental') ...[
        const Conseq21(
            ConsequenceKind.certain, '1 h · −20 énergie · Écriture +1'),
        const Conseq21(ConsequenceKind.certain,
            'Cabine ensuite · 2 h · −25 énergie (−15 avec home studio)'),
        const SizedBox(height: 12),
        PrimaryGlowButton(
            label: 'Terminer le texte',
            sublabel: 'Coût affiché avant action',
            onPressed: () => doAct(context, ref, 'write', null,
                () => context.go('/studio/cabine'))),
      ],
    ]);
  }
}

/// Cabine v20 : trois prises chronométrées, évaluées avec les mêmes centres et la même pente.
class Cabine21Screen extends ConsumerStatefulWidget {
  const Cabine21Screen({super.key});
  @override
  ConsumerState<Cabine21Screen> createState() => _Cabine21ScreenState();
}

class _Cabine21ScreenState extends ConsumerState<Cabine21Screen>
    with SingleTickerProviderStateMixin {
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

  double get _cursor => cursorAt(
      (_now - _takeStart).inMicroseconds / Duration.microsecondsPerSecond);

  Future<void> _submit(List<int> values) async {
    if (_busy) return;
    _busy = true;
    for (final value in values) {
      final error = await ref.read(game21Provider.notifier).act('take', value);
      if (!mounted) return;
      if (error != null) {
        toastErr(context, error);
        _busy = false;
        return;
      }
      setState(() => _takes.add(value));
    }
    if (mounted) context.go('/studio/mix');
  }

  Future<void> _rec() async {
    if (_busy || _takes.length >= 3) return;
    final score = takeScore(_cursor, _takes.length);
    HapticFeedback.lightImpact();
    if (_takes.length < 2) {
      final error = await ref.read(game21Provider.notifier).act('take', score);
      if (!mounted) return;
      if (error != null) {
        toastErr(context, error);
        return;
      }
      setState(() {
        _takes.add(score);
        _takeStart = _now;
      });
      return;
    }
    HapticFeedback.mediumImpact();
    await _submit([score]);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final stored =
        cur == null ? <int>[] : _l(cur['takes'] ?? const []).cast<int>();
    if (_takes.isEmpty && stored.isNotEmpty) _takes.addAll(stored);
    final energyCost = _m(s['own'])['homestudio'] != null ? 15 : 25;
    final take = _takes.length.clamp(0, takesPerSession - 1);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Cabine · prises',
          step: 'Prise ${take + 1} / 3',
          onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (cur != null)
        GlassCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cur['title'] as String, style: V20Text.nm()),
          KeyVal('Instru', instName21(cur)),
          KeyVal('Coût cabine', '2 h · −$energyCost énergie')
        ])),
      const SizedBox(height: 12),
      Row(children: [
        for (var i = 0; i < takesPerSession; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
              child: i < _takes.length
                  ? TakeChip('Prise ${i + 1} · ${_takes[i]}', done: true)
                  : TakeChip('Prise ${i + 1}'))
        ]
      ]),
      const SizedBox(height: 14),
      GlassCard(
          accent: GlassAccent.cyan,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            MiniGameTrack(cursor: _busy ? .5 : _cursor, zone: zoneCenter(take)),
            const SizedBox(height: 12),
            Text(
                _takes.isEmpty
                    ? 'Appuie sur REC dans la zone verte.'
                    : takeMessage(_takes.last),
                textAlign: TextAlign.center,
                style: V20Text.bs()),
            const SizedBox(height: 12),
            Center(
                child: RecButton(
                    onPressed: _busy || _takes.length >= 3 ? null : _rec)),
          ])),
      const SizedBox(height: 12),
      PrimaryButton(
          label: 'Simuler les 3 prises',
          style: GameButtonStyle.secondary,
          onPressed: _busy || _takes.isNotEmpty
              ? null
              : () => _submit(const [74, 48, 43])),
    ]);
  }
}

class Mix21Screen extends ConsumerWidget {
  const Mix21Screen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Mix · qualité finale', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (cur != null)
        GlassCard(
            accent: GlassAccent.magenta,
            halo: false,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cur['title'] as String, style: V20Text.dm(size: 26)),
              KeyVal('Note du texte', '${cur['tx']}'),
              KeyVal('Instru · production', '${instName21(cur)} · ${cur['prod']}'),
              KeyVal('Voix · moyenne des prises',
                  '${cur['voix']} · ${_l(cur['takes']).join(' / ')}'),
              const Divider(),
              KeyVal('Qualité finale', '${cur['Q']} / 100', color: Tk.ok),
            ])),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'La note combine le texte v21, la qualité de l’instru et la moyenne des trois prises, avec le malus de forme v20.'),
      const SizedBox(height: 12),
      PrimaryGlowButton(
          label: 'Préparer la sortie',
          onPressed: () => context.go('/studio/sortie')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M2 Featurings
// ---------------------------------------------------------------------------------------------------------------------

class FeatsScreen extends ConsumerWidget {
  const FeatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final on = cur == null ? <String>[] : _l(cur['feats']).cast<String>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Featurings',
          step: '${on.length} /${Reg21.maxFeats}',
          onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (cur == null || cur['st'] == 'sorti')
        const GameHint(
            icon: 'info',
            text:
                'Écris d’abord un titre : un featuring s’ajoute à un titre en cours, jamais à un titre déjà sorti.'),
      for (final e in Reg21.feats.entries) ...[
        const SizedBox(height: 12),
        _FeatCard(id: e.key, f: e.value, s: s, added: on.contains(e.key)),
      ],
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
              'Artistes et conditions existants (08.3, 16-G). Rôles et effets chiffrés : proposés.'),
    ]);
  }
}

class _FeatCard extends ConsumerWidget {
  final String id;
  final J f, s;
  final bool added;
  const _FeatCard(
      {required this.id,
      required this.f,
      required this.s,
      required this.added});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rival = f['needRival'] == true;
    final popLock =
        f['needPop'] != null && _n(s['pop']) < (f['needPop'] as num);
    final locked = rival || popLock;
    final cost = _n(f['cost']);
    final initials =
        (f['n'] as String).split(' ').map((w) => w[0]).take(2).join();
    return GameCard(
      selected: added,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Portrait(initials, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f['n'] as String, style: V20Text.nm()),
              Text(
                  '${f['role']} · ${cost == 0 ? 'Sans cachet · ${f['share']} % des revenus du titre' : '${fmt21(cost)} cauris'}',
                  style: V20Text.bs()),
            ]),
          ),
          if (added)
            const GameTag('Ajouté', style: GameTagStyle.ok)
          else if (locked)
            const GameTag('Verrou', style: GameTagStyle.outline)
          else
            const GameTag('Dispo'),
        ]),
        const SizedBox(height: 8),
        Conseq21(ConsequenceKind.estimated,
            'Qualité +${f['q']} · viralité +${f['vir']} · écoutes ×${(f['boost'] as num).toString().replaceAll('.', ',')}'),
        if (popLock)
          Text('Popularité ${f['needPop']} requise',
              style: V20Text.poppins(
                  size: 11,
                  line: 14,
                  weight: FontWeight.w600,
                  color: V20.hintGoldText)),
        if (rival)
          Text('Rivalité en cours : indisponible',
              style: V20Text.poppins(
                  size: 11,
                  line: 14,
                  weight: FontWeight.w600,
                  color: V20.hintGoldText)),
        const SizedBox(height: 8),
        if (added)
          PrimaryButton(
              label: 'Retirer',
              style: GameButtonStyle.ghost,
              compact: true,
              onPressed: () => doAct(context, ref, 'unfeat', id))
        else
          PrimaryButton(
              label: 'Ajouter au titre',
              style:
                  locked ? GameButtonStyle.disabled : GameButtonStyle.secondary,
              compact: true,
              onPressed: () =>
                  doAct(context, ref, 'feat', id, null, '${f['n']} ajouté')),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M3 Préparer la sortie
// ---------------------------------------------------------------------------------------------------------------------

class SortieScreen extends ConsumerWidget {
  const SortieScreen({super.key});
  static const _promoNotes = [
    'Aucun effet',
    'Viralité +5 · portée ×1,6',
    'Viralité +12 · portée ×3,2 · Port-Ambre et Sélène +2'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final cur = s['cur'] as J?;
    final project = s['project'] == null ? null : _m(s['project']);
    final projectTracks = project == null ? <J>[] : _l(project['tracks']).map((t) => _m(t)).toList();
    final promo = _n(_m(s['ui'])['promo']).toInt();
    final ready = project == null
        ? cur != null && cur['st'] == 'enregistre'
        : cur == null && projectTracks.length >= (Reg21.projectMinTracks[project['format']] ?? 999);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Préparer la sortie', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (project != null)
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: Text('${project['title'] ?? (project['format'] == 'ep' ? 'EP' : 'Album')} · ${project['format'] == 'ep' ? 'EP' : 'Album'}', style: V20Text.nm())),
              GameTag('${projectTracks.length} titres'),
            ]),
            for (var i = 0; i < projectTracks.length; i++)
              KeyVal('${i + 1}. ${projectTracks[i]['title']}', 'Qualité ${projectTracks[i]['Q']} · viralité ${virOf21(projectTracks[i], promo)}'),
            KeyVal('Écoutes prévues', fmt21(_projectForecast(s, project, promo))),
          ]),
        )
      else if (cur != null)
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                  child: Text(cur['title'] as String, style: V20Text.nm())),
              const GameTag('Single')
            ]),
            const SizedBox(height: 4),
            KeyVal('Qualité', ready ? '${cur['Q']}' : '—'),
            KeyVal('Viralité estimée', '${virOf21(cur, promo)}'),
            KeyVal('Featurings', _feats(cur)),
          ]),
        ),
      const SizedBox(height: 12),
      const Lab21('Promotion'),
      for (var i = 0; i < promos21.length; i++) ...[
        const SizedBox(height: 8),
        GameCard(
          selected: promo == i,
          onTap: () => ref.read(game21Provider.notifier).act('promo', i),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(promos21[i]['n'] as String, style: V20Text.nm()),
                  Text(_promoNotes[i], style: V20Text.bs())
                ])),
            Text(
                (promos21[i]['c'] as num) == 0
                    ? 'Gratuit'
                    : fmt21(promos21[i]['c'] as num),
                style: V20Text.nm(color: Tk.gold)),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      const Lab21('Avant de sortir'),
      if (project != null && !ready)
        Conseq21(ConsequenceKind.certain,
            'Ajoute encore ${((Reg21.projectMinTracks[project['format']] ?? 999) - projectTracks.length)} titre(s) terminé(s) au projet.'),
      if (cur != null || project != null) ...[
        Conseq21(ConsequenceKind.estimated,
            project == null ? 'Viralité estimée : ${virOf21(cur!, promo)}' : 'Sortie groupée · ${projectTracks.length} titre(s)'),
        Conseq21(ConsequenceKind.estimated,
            'Écoutes prévues sur 7 jours : ${fmt21(project == null ? predictedListens21(s) : _projectForecast(s, project, promo))}'),
      ],
      const Conseq21(ConsequenceKind.uncertain,
          'Le succès dépend aussi des fans du moment.'),
      const SizedBox(height: 8),
      const GameHint(
          icon: 'info',
          text:
              'Un clip se prépare maintenant, avant la sortie. Il ne pourra être publié qu’après.'),
      const SizedBox(height: 12),
      PrimaryGlowButton(
        label: ready ? 'Sortir ${project == null ? 'le titre' : (project['format'] == 'ep' ? 'l’EP' : 'l’album')}' : (project == null ? 'Enregistre d’abord le titre' : 'Projet incomplet'),
        sublabel: ready
            ? 'Promo ${promos21[promo]['n']}${(promos21[promo]['c'] as num) > 0 ? ' · −${fmt21(promos21[promo]['c'] as num)}' : ''}'
            : null,
        onPressed: ready
            ? () => doAct(context, ref, 'release', null,
                () => context.go('/studio/resultats'))
            : null,
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M3b Résultats de la sortie
// ---------------------------------------------------------------------------------------------------------------------

class ResultatsScreen extends ConsumerWidget {
  const ResultatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final d = _l(s['disco']).isEmpty ? null : _m(_l(s['disco']).first);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Résultats de la sortie', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      if (d == null) ...[
        Text('Aucun titre sorti', style: V20Text.nm()),
        const SizedBox(height: 12),
        PrimaryButton(
            label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ] else ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: V20.objective, borderRadius: BorderRadius.circular(24)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SORTIE · 7 PREMIERS JOURS',
                style: V20Text.lab(color: Colors.white)),
            Text((d['title'] as String).toUpperCase(),
                style: V20Text.baloo(size: 26, line: 28)),
            Text('${fmt21(d['L'] as num)} écoutes · ${d['tier']}',
                style: V20Text.bm),
          ]),
        ),
        const SizedBox(height: 12),
        const Lab21('Quatre indicateurs'),
        KpiRow(children: [
          StatKpi(
              label: 'Qualité du titre',
              value: '${d['Q']}',
              delta: 'note 0-100'),
          StatKpi(
              label: 'Viralité',
              value: '${d['vir']}',
              delta: 'potentiel de partage')
        ]),
        const SizedBox(height: 8),
        KpiRow(children: [
          StatKpi(
              label: 'Succès',
              value: '${d['tier']}',
              delta: 'selon les écoutes'),
          StatKpi(
              label: 'Ta popularité',
              value: '${s['pop']}',
              delta: '+${d['pg']} avec ce titre')
        ]),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(children: [
            KeyVal('Nouveaux fans', '+${fmt21(d['fg'] as num)}'),
            KeyVal('Revenus des écoutes',
                '${fmt21(d['rev'] as num)} cauris${_n(d['cut']) > 0 ? ' (après 35 % au label : −${fmt21(d['cut'] as num)})' : ''}'),
            KeyVal(
                'Featurings',
                _l(d['feats']).isEmpty
                    ? 'Aucun'
                    : _l(d['feats'])
                        .map((k) => Reg21.feats[k]!['n'])
                        .join(', ')),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CLASSEMENT', style: V20Text.lab()),
            const SizedBox(height: 4),
            Text(
                _n(d['L']) >= Reg21.entry
                    ? 'Entré au Top 100 Singles'
                    : 'Non classé · il manque ${fmt21(Reg21.entry - _n(d['L']))} écoutes (seuil ${fmt21(Reg21.entry)})',
                style: V20Text.bm),
            const SizedBox(height: 8),
            MeterBar(value: (_n(d['L']) / Reg21.entry).clamp(0, 1).toDouble()),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CARRIÈRE', style: V20Text.lab()),
            KeyVal('Rang', 'N${rankOf(s)} · ${_n(s['xp']).toInt()} XP'),
            KeyVal(
                'Prochain rang',
                rankOf(s) < Reg21.ranks.length
                    ? '${Reg21.ranks[rankOf(s)]['xp']} XP${Reg21.ranks[rankOf(s)]['cl'] != null ? ' · ${Reg21.ranks[rankOf(s)]['cl']}' : ''}'
                    : 'Rang maximal'),
          ]),
        ),
        const SizedBox(height: 8),
        const GameHint(
            icon: 'info',
            text:
                'Quatre notions distinctes : la qualité (le titre), la viralité (son potentiel de partage), le succès (ce qu’il a réellement fait) et la popularité (toi). Joueur non classé au départ (D-16).'),
        const SizedBox(height: 12),
        GameCard(
            onTap: () => context.go('/studio/clip'),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Clip', style: V20Text.nm()),
                    Text(clipLabel(_m(d['clip'])['st'] as String),
                        style: V20Text.bs())
                  ])),
              const Icon(Icons.arrow_forward_rounded, color: Tk.ink)
            ])),
        const SizedBox(height: 8),
        GameCard(
            onTap: () => context.go('/profil/classements'),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Classements', style: V20Text.nm()),
                    Text(
                        'Singles · ${singlesRank(s) == 0 ? 'Non classé' : '#${singlesRank(s)}'}',
                        style: V20Text.bs())
                  ])),
              const Icon(Icons.arrow_forward_rounded, color: Tk.ink)
            ])),
        const SizedBox(height: 16),
        PrimaryGlowButton(
            label: 'Retour au QG', onPressed: () => context.go('/')),
      ],
    ]);
  }
}

class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});
  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  String _filter = 'Tous';

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final all = _l(s['disco']).cast<J>();
    final songs = all.where((song) {
      final format = song['format'] ?? 'single';
      return _filter == 'Tous' ||
          (_filter == 'Singles' && format == 'single') ||
          (_filter == 'EP' && format == 'ep') ||
          (_filter == 'Albums' && format == 'album');
    }).toList();
    final streams = all.fold<num>(0, (sum, song) => sum + _n(song['L']));
    final views = all.fold<num>(0, (sum, song) => sum + _n(song['views']));
    final revenue = all.fold<num>(0, (sum, song) => sum + _n(song['rev']));
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Mon catalogue', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Streams', value: fmt21(streams)),
        StatKpi(label: 'Vues clips', value: fmt21(views)),
      ]),
      const SizedBox(height: 8),
      GlassCard(
          child: Row(children: [
        Expanded(child: Text('Revenus cumulés', style: V20Text.nm())),
        Text('${fmt21(revenue)} cauris', style: V20Text.nm(color: Tk.gold)),
      ])),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        for (final category in const ['Tous', 'Singles', 'EP', 'Albums'])
          ChoiceChip(
              label: Text(category),
              selected: _filter == category,
              onSelected: (_) => setState(() => _filter = category)),
      ]),
      const SizedBox(height: 8),
      if (songs.isEmpty)
        GlassCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              _filter == 'EP'
                  ? 'Aucun EP sorti'
                  : (_filter == 'Albums'
                      ? 'Aucun album sorti'
                      : 'Aucun single sorti'),
              style: V20Text.nm()),
          const SizedBox(height: 4),
          Text(
              'Les sorties de cette catégorie apparaîtront ici après leur publication.',
              style: V20Text.bs()),
        ]))
      else
        for (final song in songs) ...[
          const SizedBox(height: 8),
          GameCard(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const GameCover(letter: 'R', size: 68),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(song['title'] as String, style: V20Text.nm()),
                  Text(
                      '${(song['format'] ?? 'single').toString().toUpperCase()} · ${song['year'] ?? 1} · ${song['label'] ?? 'Indépendant'}',
                      style: V20Text.bs()),
                  if (song['tracks'] is List)
                    Text('Titres : ${(song['tracks'] as List).join(' · ')}', style: V20Text.bs()),
                  const SizedBox(height: 6),
                  Text(
                      '${fmt21(_n(song['L']))} streams · ${fmt21(_n(song['views']))} vues',
                      style: V20Text.bm),
                  Text('Ventes virtuelles estimées : ${fmt21(_n(song['sales']))} unités', style: V20Text.bs()),
                  const SizedBox(height: 4),
                  _PlatformStreams(song: song),
                ])),
          ])),
        ],
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text:
            'Streams et vues évoluent pendant 14 jours. Les ventes virtuelles sont estimées selon une segmentation provisoire des fans ; le prix unitaire reste à définir, donc aucun revenu de vente n’est ajouté. La répartition par plateforme est simulée.'),
    ]);
  }
}

class _PlatformStreams extends StatelessWidget {
  final J song;
  const _PlatformStreams({required this.song});

  @override
  Widget build(BuildContext context) {
    final raw = _m(song['platforms'] ?? const {});
    // Anciennes sauvegardes : pas de clés Ondéa / Cauri Music, on recalcule la répartition depuis les écoutes.
    final split = platformSplit21(_n(song['L']));
    final ondea = raw['ondea'] ?? split.ondea, cauri = raw['cauri'] ?? split.cauri;
    final clipOn = song['clip'] is Map && (song['clip'] as Map)['st'] == 'publie';
    final klipo = clipOn ? jsRound(_n(song['clipL']) * (Reg21.platforms['klipo']!['viewsPerClipListen'] as num)) : 0;
    Widget item(String name, String mark, num value, [String unit = '']) => Padding(
          padding: const EdgeInsets.only(right: 8, top: 4),
          child: Chip(
            avatar: CircleAvatar(
                child: Text(mark,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold))),
            label: Text('$name ${fmt21(value)}$unit', style: V20Text.bs()),
            visualDensity: VisualDensity.compact,
          ),
        );
    return Wrap(children: [
      item('Ondéa', 'O', ondea as num),
      item('Cauri Music', 'C', cauri as num),
      if (clipOn) item('Klipo', '▶', klipo, ' vues'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M4 Clip : préparer, tourner, publier
// ---------------------------------------------------------------------------------------------------------------------

class ClipScreen extends ConsumerWidget {
  const ClipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final t = clipSong21(s);
    final cs = t == null ? 'none' : _m(t['clip'])['st'] as String;
    final sold = t != null && t['st'] == 'sorti';
    final rank = rankOf(s);
    final dir = _m(s['ui'])['dir'] as String?;
    final moto = _m(s['own'])['moto'] != null;
    final canPrep = t != null && !sold && cs == 'aucun';
    Widget step(String label, bool done) => Expanded(
          child: Column(children: [
            Container(
                height: 6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: done
                        ? Tk.ok
                        : const Color.fromRGBO(255, 255, 255, .14))),
            const SizedBox(height: 4),
            Text(label.toUpperCase(),
                style: V20Text.poppins(
                    size: 10,
                    line: 12,
                    weight: FontWeight.w700,
                    color: V20.ink2)),
          ]),
        );
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Clip', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
                child: Text(t == null ? 'Aucun titre' : t['title'] as String,
                    style: V20Text.nm())),
            GameTag(
                t == null ? '—' : (sold ? 'Titre sorti' : 'Titre non sorti'))
          ]),
          const SizedBox(height: 8),
          Row(children: [
            step('Préparé', cs != 'aucun' && cs != 'none'),
            const SizedBox(width: 6),
            step('Tourné', cs == 'produit' || cs == 'publie'),
            const SizedBox(width: 6),
            step('Titre sorti', sold),
            const SizedBox(width: 6),
            step('Publié', cs == 'publie')
          ]),
          const SizedBox(height: 8),
          KeyVal(
              'Réalisation',
              t != null && _m(t['clip'])['dir'] != null
                  ? Reg21.directors[_m(t['clip'])['dir']]!['n'] as String
                  : '—'),
        ]),
      ),
      if (t == null) ...[
        const SizedBox(height: 12),
        const GameHint(
            icon: 'info',
            text: 'Aucun titre : écris d’abord un titre au studio.'),
      ],
      if (t != null && cs == 'aucun') ...[
        const SizedBox(height: 12),
        const Lab21('1 · Préparer (avant la sortie)'),
        for (final e in Reg21.directors.entries) ...[
          const SizedBox(height: 8),
          GameCard(
            selected: dir == e.key,
            onTap: rank < (e.value['rank'] as num)
                ? null
                : () => ref.read(game21Provider.notifier).act('dir', e.key),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(e.value['n'] as String,
                        style: V20Text.nm(
                            color: rank < (e.value['rank'] as num)
                                ? Tk.dis
                                : Tk.ink)),
                    Text(
                        rank < (e.value['rank'] as num)
                            ? '${e.value['lv']} · rang N${e.value['rank']} requis'
                            : '${e.value['lv']} · viralité +${e.value['vir']}',
                        style: V20Text.bs())
                  ])),
              rank < (e.value['rank'] as num)
                  ? GameTag('N${e.value['rank']}', style: GameTagStyle.outline)
                  : Text(fmt21(e.value['cost'] as num),
                      style: V20Text.nm(color: Tk.gold)),
            ]),
          ),
        ],
        const SizedBox(height: 8),
        if (sold)
          const GameHint(
              icon: 'info',
              warn: true,
              text:
                  'Trop tard pour ce titre : un clip se prépare avant la sortie. Prépare-le pour ton prochain titre.'),
        if (canPrep)
          PrimaryButton(
              label: 'Préparer avec ce réalisateur',
              sublabel: 'Paiement à la préparation',
              onPressed: dir == null
                  ? null
                  : () => doAct(
                      context, ref, 'clipPrep', dir, null, 'Clip préparé')),
      ],
      if (t != null && cs == 'prepare') ...[
        const SizedBox(height: 12),
        const Lab21('2 · Tourner'),
        Conseq21(ConsequenceKind.certain,
            '${Reg21.shootH} h · −${Reg21.shootE - (moto ? 5 : 0)} énergie${moto ? '' : ' (−5 avec la moto)'}'),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Tourner le clip',
            onPressed: () => doAct(
                context, ref, 'clipShoot', null, null, 'Tournage terminé')),
      ],
      if (t != null && (cs == 'prepare' || cs == 'produit') && !sold) ...[
        const SizedBox(height: 12),
        const Lab21('3 · Sortie du titre'),
        const Text('Publication possible après la sortie'),
        const SizedBox(height: 8),
        PrimaryButton(
            label: 'Préparer la sortie du titre',
            style: GameButtonStyle.secondary,
            onPressed: () => context.go('/studio/sortie')),
      ],
      if (t != null && sold && cs == 'produit') ...[
        const SizedBox(height: 12),
        const Lab21('4 · Publier'),
        const Conseq21(ConsequenceKind.estimated,
            'Viralité du titre en hausse, écoutes supplémentaires, popularité +2.'),
        const SizedBox(height: 8),
        PrimaryGlowButton(
            label: 'Publier le clip',
            onPressed: () => doAct(context, ref, 'clipPub', null,
                () => context.go('/studio/clip-publie'))),
      ],
      if (cs == 'publie') ...[
        const SizedBox(height: 12),
        PrimaryButton(
            label: 'Voir les effets',
            onPressed: () => context.go('/studio/clip-publie')),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-M5 Résultats du clip
// ---------------------------------------------------------------------------------------------------------------------

class ClipPubScreen extends ConsumerWidget {
  const ClipPubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final d = _l(s['disco']).isEmpty ? null : _m(_l(s['disco']).first);
    final pub = d != null && _m(d['clip'])['st'] == 'publie';
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(
          title: 'Clip publié', onBack: () => context.go('/studio/clip')),
      const SizedBox(height: 12),
      if (!pub) ...[
        Text('Aucun clip publié', style: V20Text.nm()),
        const SizedBox(height: 12),
        PrimaryButton(
            label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ] else ...[
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CLIP PUBLIÉ', style: V20Text.lab(color: V20.accText)),
            Text(d['title'] as String,
                style: V20Text.baloo(size: 24, line: 26)),
            Conseq21(ConsequenceKind.estimated,
                '+${fmt21(_n(d['clipL']))} écoutes · +${fmt21(_n(d['clipF']))} fans · viralité ${d['vir0'] ?? d['vir']} → ${d['vir']}'),
          ]),
        ),
        const SizedBox(height: 12),
        KpiRow(children: [
          StatKpi(label: 'Écoutes du titre', value: fmt21(d['L'] as num)),
          StatKpi(label: 'Succès', value: '${d['tier']}')
        ]),
        const SizedBox(height: 8),
        KpiRow(children: [
          StatKpi(label: 'Viralité', value: '${d['vir']}'),
          StatKpi(label: 'Popularité', value: '${s['pop']}')
        ]),
        const SizedBox(height: 12),
        GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('POPULARITÉ PAR VILLE', style: V20Text.lab()),
            const SizedBox(height: 4),
            for (final c in Reg21.cities.entries)
              Gauge21(c.value, geoOf(s, c.key), color: Tk.cy),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryGlowButton(
            label: 'Retour au studio', onPressed: () => context.go('/studio')),
      ],
    ]);
  }
}
