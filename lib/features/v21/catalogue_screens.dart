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
import '../../core/widgets/game_icon.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'cover_screens.dart';
import 'library_screens.dart';
import 'widgets21.dart';

/// Catalogue (21-A0), fiche d'un titre (21-A0b), création d'un EP ou d'un album (21-A1) et résultats d'un projet (21-A2).
/// Intention de jeu : voir ce que valent ses sons, puis les regrouper en EP ou en album pour viser un classement.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic>
    ? x
    : x is Map
        ? x.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

/// Pochette vivante : elle se fond en douceur quand le joueur en change (Studio > Pochettes), sans animation si le système le demande.
class _LiveCover extends StatelessWidget {
  final String path;
  final double size;
  const _LiveCover(this.path, this.size);
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 250),
        child: Cover21(path, key: ValueKey(path), size: size, radius: size > 60 ? 16 : 10),
      );
}

/// Ligne de titre : pochette, nom, détail, streams et ventes.
class _TitleRow extends StatelessWidget {
  final int index;
  final J t;
  final J s;
  final VoidCallback onTap;
  const _TitleRow(this.index, this.t, this.s, this.onTap);
  @override
  Widget build(BuildContext context) => GameCard(
        onTap: onTap,
        child: Row(children: [
          _LiveCover(trackCover21(t), 52),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t['title'] as String, style: V20Text.nm()),
            Text(titleMeta(t), style: V20Text.bs()),
            Text('${fmt21(streamsTotal(s, t))} streams · ${fmt21(salesOf(t))} ventes', style: V20Text.bs(color: Tk.ink)),
          ])),
          const GameIcon('arrow', color: Tk.ink),
        ]),
      );
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-A0 Catalogue
// ---------------------------------------------------------------------------------------------------------------------

class CatalogueScreen extends ConsumerWidget {
  const CatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final disco = _l(s['disco']).map(_m).toList();
    final projects = _l(s['projects']).map(_m).toList();
    final pendingProjects = _l(s['pendingProjects'] ?? const []).map(_m).toList();
    final ep = bestProject(s, 'EP'), al = bestProject(s, 'Album');
    Widget board(String title, J? p, String none, String hint) => _BoardTile(
          title,
          p == null ? none : projectRankLabel(p),
          p == null ? hint : '${p['title']} · ${fmt21(_n(p['sales']))} ventes',
        );
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('CATALOGUE', style: V20Text.dm()),
        GameTag('${disco.length} titres · ${projects.length} projets'),
      ]),
      const SizedBox(height: 12),
      KpiRow(children: [
        board(projectBoard('EP'), ep, 'Aucun EP', 'Crée un EP de 3 à 7 titres'),
        board(projectBoard('Album'), al, 'Aucun album', 'Crée un album de 8 titres ou plus'),
      ]),
      const SizedBox(height: 12),
      PrimaryGlowButton(
          label: 'Créer un EP ou un album',
          sublabel: 'EP : 3 à 7 titres · album : 8 titres ou plus',
          onPressed: () => context.go('/studio/catalogue/projet')),
      const SizedBox(height: 12),
      if (pendingProjects.isNotEmpty) ...[
        const SizedBox(height: 12),
        const Lab21('SORTIES PROGRAMMÉES'),
        for (final p in pendingProjects) ...[
          const SizedBox(height: 8),
          GameCard(child: Row(children: [
            _LiveCover(projectCover21(p), 52),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['title'] as String, style: V20Text.nm()),
              Text('${p['type']} · ${dateLabel21(_n(p['relDay']))} · ${_l(p['tracks']).length} titres', style: V20Text.bs()),
              Text('Campagne : ${p['promoName'] ?? promos21[_n(p['promo']).toInt()]['n']}', style: V20Text.bs(color: Tk.gold)),
            ])),
            const GameTag('Programmé', style: GameTagStyle.accent),
          ])),
        ],
      ],
      const Row(children: [
        Lab21('Singles sortis'),
        SizedBox(width: 8),
        GameTag('Nouveau', style: GameTagStyle.accent),
      ]),
      const SizedBox(height: 8),
      if (disco.isEmpty)
        const GlassCard(child: Text('Aucun titre sorti pour l’instant.')),
      for (var i = 0; i < disco.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        _TitleRow(i, disco[i], s, () => doAct(context, ref, 'ctki', i, () => context.go('/studio/catalogue/titre'))),
      ],
      if (projects.isNotEmpty) ...[
        const SizedBox(height: 12),
        const Lab21('EP et albums sortis'),
        for (var i = 0; i < projects.length; i++) ...[
          const SizedBox(height: 8),
          GameCard(
            onTap: () => context.go('/studio/catalogue/projet-sorti?i=$i'),
            child: Row(children: [
              _LiveCover(projectCover21(projects[i]), 52),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${projects[i]['title']}', style: V20Text.nm()),
                Text('${projects[i]['type']} · ${_l(projects[i]['tracks']).length} titres · ${projectRankLabel(projects[i])}', style: V20Text.bs()),
                Text('${fmt21(_n(projects[i]['sales']))} ventes', style: V20Text.bs(color: Tk.ink)),
              ])),
              const GameIcon('arrow', color: Tk.ink),
            ]),
          ),
        ],
      ],
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Streams cumulés : 7 premiers jours, puis +35 % par semaine pendant 12 semaines (provisoire). Ventes : 1,2 % des streams des 7 premiers jours, '
              '30 cauris la vente, ajoutées aux revenus (part du label déduite). Valeurs provisoires (D-08).'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-A0b Fiche d'un titre
// ---------------------------------------------------------------------------------------------------------------------

class TitreScreen extends ConsumerWidget {
  const TitreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = selectedTitle(s);
    final back = BackHeader(title: 'Fiche du titre', onBack: () => context.go('/studio/catalogue'));
    if (t == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [back, const SizedBox(height: 12), const GlassCard(child: Text('Aucun titre sorti.'))]);
    }
    final clip = _m(t['clip']);
    final clipName = clip['st'] == 'publie' ? (Reg21.directors[clip['dir']]?['n'] ?? 'Réalisé') : 'Pas de clip';
    final feats = _l(t['feats']);
    final rank = singleRankOf(t);
    return ListView(padding: const EdgeInsets.all(16), children: [
      back,
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        GestureDetector(
          onTap: () => pickCover(context, ref, t),
          child: Stack(children: [
            _LiveCover(trackCover21(t), 84),
            Positioned(right: 4, bottom: 4, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Tk.deep.withValues(alpha: .8), shape: BoxShape.circle), child: const GameIcon('music', size: 14, color: Tk.ink))),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((t['title'] as String).toUpperCase(), style: V20Text.baloo(size: 24, line: 26)),
          Text(dateLabel21(_n(t['day'])), style: V20Text.bs(color: Tk.ink)),
          Text('${t['labelAt'] ?? 'Indépendant'}', style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: Tk.ink)),
        ])),
      ]),
      const SizedBox(height: 12),
      KpiRow(children: [
        StatKpi(label: 'Streams 7 j', value: fmt21(_n(t['L']))),
        StatKpi(label: 'Streams cumulés', value: fmt21(streamsTotal(s, t))),
      ]),
      const SizedBox(height: 8),
      KpiRow(children: [
        StatKpi(label: 'Ventes', value: fmt21(salesOf(t))),
        StatKpi(label: 'Top 100', value: rank == 0 ? 'Non classé' : '#$rank'),
      ]),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('CRÉDITS', style: V20Text.lab()),
          const GameTag('Nouveau', style: GameTagStyle.accent),
        ]),
        KeyVal('Artiste et auteur', '${t['auteur'] ?? _m(s['p'])['name']}'),
        KeyVal('Production', '${t['prodBy'] ?? 'Studio de quartier'}'),
        KeyVal('Featurings', feats.isEmpty ? 'Aucun' : feats.map((k) => Reg21.feats[k]!['n']).join(', ')),
        KeyVal('Clip', '$clipName'),
        KeyVal('Label à la sortie', '${t['labelAt'] ?? 'Indépendant'}'),
      ])),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('FICHE TECHNIQUE', style: V20Text.lab()),
        KeyVal('Qualité', '${t['Q']}'),
        KeyVal('Succès', '${t['tier']}'),
        KeyVal('Thème · ambiance', '${Reg21.themes[t['theme']]?['n'] ?? ''} · ${Reg21.ambs[t['amb']]?['n'] ?? ''}'),
        KeyVal('Revenus (écoutes et ventes)', fmt21(_n(t['rev']))),
        KeyVal('Part du label', fmt21(_n(t['cut']))),
        KeyVal('Présent sur', titleInProjects(s, t)),
      ])),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-A1 Créer un EP ou un album
// ---------------------------------------------------------------------------------------------------------------------

class ProjetScreen extends ConsumerStatefulWidget {
  const ProjetScreen({super.key});
  @override
  ConsumerState<ProjetScreen> createState() => _ProjetScreenState();
}

class _ProjetScreenState extends ConsumerState<ProjetScreen> {
  final _title = TextEditingController();
  int _promo = 0;
  int _days = 3;

  Future<void> _submitProject(BuildContext context, WidgetRef ref, {required bool schedule, required int totalCost}) async {
    if (totalCost >= 15000) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirmer la sortie du projet'),
          content: Text('Production et mastering, campagne comprise : ${fmt21(totalCost)} cauris.\nLa dépense sera débitée ${schedule ? 'maintenant, avant la date prévue' : 'à la publication'}. Continuer ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirmer la sortie')),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    await doAct(context, ref, schedule ? 'pschedule' : 'prel', schedule ? _days : null,
      () => context.go(schedule ? '/studio/catalogue' : '/studio/catalogue/projet-sorti?i=0'));
  }

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
    final type = (ui['ptype'] ?? 'EP') as String;
    final P = Reg21.proj[type]!;
    final picked = _l(ui['ptk']).cast<String>();
    final disco = _l(s['disco']).map(_m).toList();
    final min = P['min'] as int, max = P['max'] as int;
    final stock = _l(s['stock']).map(_m).toList();
    final enough = disco.length + stock.length >= min;
    final ok = picked.length >= min && picked.length <= max;
    final need = picked.length < min ? 'Encore ${min - picked.length} titre(s) à choisir' : (picked.length > max ? 'Trop de titres : $max au maximum' : 'Prêt à sortir');
    if (_title.text.isEmpty && (ui['ptitle'] ?? '') != '' && !FocusScope.of(context).hasFocus) _title.text = ui['ptitle'] as String;
    final hs = type == 'EP';
    final promo = _n(ui['ppromo'] ?? _promo).toInt().clamp(0, promos21.length - 1).toInt();
    final promoCost = (s['lperk'] == 'radio' && promo == 2) ? 0 : (promos21[promo]['c'] as num).toInt();
    final totalCost = (P['cost'] as num).toInt() + promoCost;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Créer un projet', step: 'Existant · 05-5', onBack: () => context.go('/studio/catalogue')),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        Chip21('EP · 3 à 7 titres', selected: type == 'EP', onTap: () => ref.read(game21Provider.notifier).act('ptype', 'EP')),
        Chip21('Album · 8 titres et plus', selected: type == 'Album', onTap: () => ref.read(game21Provider.notifier).act('ptype', 'Album')),
      ]),
      const SizedBox(height: 8),
      const Lab21('Titre du projet'),
      TextField(
        controller: _title,
        maxLength: 30,
        onChanged: (v) => ref.read(game21Provider.notifier).act('setui', 'ptitle=$v'),
        style: V20Text.nm(),
        decoration: InputDecoration(
          counterText: '',
          hintText: 'EX. NDO SESSIONS',
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
      TitleIdeas21(
        key: ValueKey('ideas-$type'),
        label: type == 'EP' ? 'Idées de noms d\'EP' : 'Idées de noms d\'album',
        ideas: (page) => titleIdeas21(s, kind: type, page: page),
        onPick: (t) {
          _title.text = t;
          ref.read(game21Provider.notifier).act('setui', 'ptitle=$t');
        },
      ),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: Chip21('Nom aléatoire', onTap: () {
          FocusScope.of(context).unfocus();
          _title.clear();
          ref.read(game21Provider.notifier).act('rptitle', '');
        }),
      ),
      const SizedBox(height: 12),
      if (!enough) ...[
        GameHint(icon: 'info', warn: true, text: 'Tu n’as pas encore assez de singles sortis : il en faut au moins $min. Sors d’autres titres au studio.'),
        const SizedBox(height: 12),
      ],
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('TITRES · ${picked.length} CHOISI(S)', style: V20Text.lab()),
        Text('$min à $max', style: V20Text.bs()),
      ]),
      const SizedBox(height: 4),
      Text(
        need,
        key: const ValueKey('project-selection-status'),
        style: V20Text.bs(color: ok ? Tk.ok : Tk.ink),
      ),
      const SizedBox(height: 8),
      for (var i = 0; i < disco.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        GameCard(
          selected: picked.contains(disco[i]['id']),
          onTap: () => ref.read(game21Provider.notifier).act('ptki', i),
          child: Row(children: [
            _LiveCover(trackCover21(disco[i]), 40),
            const SizedBox(width: 12),
            Expanded(child: Text('${disco[i]['title']} · qualité ${disco[i]['Q']}', style: V20Text.nm())),
            const SizedBox(width: 8),
            if (picked.contains(disco[i]['id']))
              const Row(mainAxisSize: MainAxisSize.min, children: [GameIcon('check', size: 14, color: Tk.ok), SizedBox(width: 4), GameTag('Choisi', style: GameTagStyle.ok)])
            else
              const GameTag('Ajouter'),
          ]),
        ),
      ],
      if (stock.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text('PAS ENCORE SORTIS · ${stock.length}', style: V20Text.lab()),
        const SizedBox(height: 4),
        Text('Ils sortent avec le projet, pas en single.', style: V20Text.bs()),
        const SizedBox(height: 8),
        for (var i = 0; i < stock.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          GameCard(
            selected: picked.contains(stock[i]['id']),
            onTap: () => ref.read(game21Provider.notifier).act('ptk', stock[i]['id']),
            child: Row(children: [
              _LiveCover(trackCover21(stock[i]), 40),
              const SizedBox(width: 12),
              Expanded(child: Text('${stock[i]['title']} · qualité ${stock[i]['Q']}', style: V20Text.nm())),
              const SizedBox(width: 8),
              if (picked.contains(stock[i]['id']))
                const Row(mainAxisSize: MainAxisSize.min, children: [GameIcon('check', size: 14, color: Tk.ok), SizedBox(width: 4), GameTag('Choisi', style: GameTagStyle.ok)])
              else
                const GameTag('Inédit', style: GameTagStyle.accent),
            ]),
          ),
        ],
      ],
      const SizedBox(height: 12),
      const SizedBox(height: 12),
      const Lab21('CAMPAGNE MARKETING'),
      for (var i = 0; i < promos21.length; i++) ...[
        const SizedBox(height: 8),
        GameCard(
          selected: promo == i,
          onTap: () { setState(() => _promo = i); ref.read(game21Provider.notifier).act('ppromo', i); },
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(promos21[i]['n'] as String, style: V20Text.nm()),
              Text(i == 0 ? 'Sortie organique' : (i == 1 ? 'Portée ×1,6 · campagne numérique fictive' : 'Portée ×3,2 · campagne média locale fictive'), style: V20Text.bs()),
            ])),
            Text((s['lperk'] == 'radio' && i == 2) || (promos21[i]['c'] as num) == 0 ? 'Gratuit' : '${fmt21(promos21[i]['c'] as num)} cauris', style: V20Text.nm(color: Tk.gold)),
          ]),
        ),
      ],
      Conseq21(ConsequenceKind.certain, 'Mastering et pochette : ${fmt21(P['cost'] as num)} cauris · marketing : ${fmt21(promoCost)} · total : ${fmt21(totalCost)} cauris · ${hs ? 'EP' : 'album'} ${P['h']} h −${P['e']} énergie'),
      Conseq21(ConsequenceKind.estimated,
          'Ventes selon tes fans et la qualité moyenne des titres ; entrée au Top ${Reg21.proj['EP']!['top']} EPs à ${fmt21(Reg21.proj['EP']!['entry'] as num)} ventes, au Top ${Reg21.proj['Album']!['top']} Albums à ${fmt21(Reg21.proj['Album']!['entry'] as num)}.'),
      const SizedBox(height: 12),
      PrimaryGlowButton(
        label: 'Sortir le projet',
        sublabel: ok ? 'Maintenant · total ${fmt21(totalCost)} cauris' : need,
        onPressed: ok ? () => _submitProject(context, ref, schedule: false, totalCost: totalCost) : null,
      ),
      const SizedBox(height: 12),
      const Lab21('DATE DE SORTIE'),
      DropdownButtonFormField<int>(
        initialValue: _days,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Délai dans le jeu'),
        items: [for (var d = 1; d <= Reg21.relMaxDays; d++) DropdownMenuItem(value: d, child: Text('Dans $d j · ${dateLabel21(_n(s['day']).toInt() + d)}', maxLines: 1, overflow: TextOverflow.ellipsis))],
        onChanged: (v) { if (v != null) setState(() => _days = v); },
      ),
      const SizedBox(height: 8),
      PrimaryButton(
        label: 'Programmer la sortie',
        style: GameButtonStyle.secondary,
        onPressed: ok ? () => _submitProject(context, ref, schedule: true, totalCost: totalCost) : null,
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-A2 Résultats d'un EP ou d'un album
// ---------------------------------------------------------------------------------------------------------------------

class ProjetSortiScreen extends ConsumerWidget {
  /// Indice du projet dans `projects` (0 = le plus récent).
  final int index;
  const ProjetSortiScreen({super.key, this.index = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final projects = _l(s['projects']);
    final p = index < projects.length ? _m(projects[index]) : null;
    final back = BackHeader(title: 'Projet sorti', onBack: () => context.go('/studio/catalogue'));
    if (p == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        back,
        const SizedBox(height: 12),
        const GlassCard(child: Text('Aucun projet sorti.')),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Voir les classements', onPressed: () => context.go('/profil/classements')),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Retour au catalogue', style: GameButtonStyle.secondary, onPressed: () => context.go('/studio/catalogue')),
      ]);
    }
    final type = p['type'] as String;
    final ranked = _n(p['rank']) > 0;
    return ListView(padding: const EdgeInsets.all(16), children: [
      back,
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: V20.objective, borderRadius: BorderRadius.circular(24)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _LiveCover(projectCover21(p), 84),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${type == 'EP' ? 'EP' : 'ALBUM'} SORTI', style: V20Text.lab(color: Colors.white)),
          Text((p['title'] as String).toUpperCase(), style: V20Text.baloo(size: 26, line: 28)),
          Text('$type · ${_l(p['tracks']).length} titres · ${p['labelAt']}', style: V20Text.bm),
          Text('Sorti le jour J${p['day']} · Campagne : ${p['promoName'] ?? 'Aucune'}', style: V20Text.bs()),
        ])),
        ]),
      ),
      const SizedBox(height: 8),
      KpiRow(children: [
        StatKpi(label: 'Ventes 7 j', value: fmt21(_n(p['sales']))),
        StatKpi(label: 'Streams 7 j', value: fmt21(_n(p['L']))),
      ]),
      const SizedBox(height: 8),
      KpiRow(children: [
        StatKpi(label: 'Revenus', value: fmt21(_n(p['rev'])), delta: 'part label : ${fmt21(_n(p['cut']))}'),
        StatKpi(label: 'Nouveaux fans', value: '+${fmt21(_n(p['fans']))}'),
      ]),
      const SizedBox(height: 12),
      GlassCard(
          accent: ranked ? GlassAccent.cyan : GlassAccent.magenta,
          halo: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CLASSEMENT', style: V20Text.lab()),
            const SizedBox(height: 4),
            Text(
                ranked
                    ? '${projectRankLabel(p)} au ${projectBoard(type)}'
                    : 'Non classé : entrée au ${projectBoard(type)} à ${fmt21(Reg21.proj[type]!['entry'] as num)} ventes.',
                style: V20Text.bm),
          ])),
      const SizedBox(height: 16),
      PrimaryGlowButton(label: 'Voir les classements', onPressed: () => context.go('/profil/classements')),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Retour au catalogue', style: GameButtonStyle.secondary, onPressed: () => context.go('/studio/catalogue')),
    ]);
  }
}

/// Tuile de classement (EP ou album) : la valeur se réduit pour tenir sur une ligne (« Aucun album »).
class _BoardTile extends StatelessWidget {
  final String label, value, hint;
  const _BoardTile(this.label, this.value, this.hint);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(gradient: V20.surface, borderRadius: BorderRadius.circular(Tk.rCard), border: Border.all(color: V20.kpiBorder, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label.toUpperCase(), style: V20Text.lab()),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, maxLines: 1, style: V20Text.baloo(size: 26, line: 28))),
          const SizedBox(height: 2),
          Text(hint, style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w700, color: Tk.ok)),
        ]),
      );
}
