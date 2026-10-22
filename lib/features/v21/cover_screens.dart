import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_icon.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'library_screens.dart' show coverAmbs21, coverThemes21, coverVariants21, trackCover21;
import 'widgets21.dart';

/// Pochettes des sons (Studio) : le joueur choisit, pour chaque son, une pochette parmi celles du jeu.
/// Intention de jeu : donner une identité visuelle à chaque sortie. Aucun effet sur les écoutes, les fans ni les classements.

J _m(dynamic x) => x as J;
List<dynamic> _l(dynamic x) => (x ?? const <dynamic>[]) as List<dynamic>;

String _themeName(String th) => th == 'autre' ? 'Autre' : (Reg21.themes[th]?['n'] ?? th) as String;
String _ambName(String am) => (Reg21.ambs[am]?['n'] ?? am) as String;

Widget _thumb(String path, double size, {double radius = 12}) => ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SvgPicture.asset(path, width: size, height: size, fit: BoxFit.cover, placeholderBuilder: (_) => SizedBox.square(dimension: size, child: const ColoredBox(color: Tk.deep))),
    );

/// Ouvre la feuille de choix de la pochette d'un son puis enregistre le choix. [song] : le son (en cours, en réserve ou sorti).
Future<void> pickCover(BuildContext context, WidgetRef ref, Map song) async {
  final picked = await showGameSheet<String>(context, builder: (ctx) => _CoverSheet(song));
  if (picked == null || !context.mounted) return;
  await doAct(context, ref, 'setcover', [song['id'], picked], null, picked.isEmpty ? 'Pochette automatique' : 'Pochette changée');
}

class _CoverSheet extends StatefulWidget {
  final Map song;
  const _CoverSheet(this.song);
  @override
  State<_CoverSheet> createState() => _CoverSheetState();
}

class _CoverSheetState extends State<_CoverSheet> {
  late String _theme;

  @override
  void initState() {
    super.initState();
    final t = '${widget.song['theme']}';
    _theme = coverThemes21.contains(t) ? t : coverThemes21.first;
  }

  @override
  Widget build(BuildContext context) {
    final current = trackCover21(widget.song);
    final custom = widget.song['cover'] is String && isCoverPath21(widget.song['cover'] as String);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('POCHETTE', style: V20Text.lab()),
      const SizedBox(height: 8),
      Row(children: [
        _thumb(current, 84, radius: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.song['title']}'.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.dm(size: 22)),
            const SizedBox(height: 4),
            GameTag(custom ? 'Choisie par toi' : 'Automatique', style: custom ? GameTagStyle.ok : GameTagStyle.outline),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      const Lab21('Motif'),
      const SizedBox(height: 4),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final th in coverThemes21) Chip21(_themeName(th), selected: th == _theme, onTap: () => setState(() => _theme = th)),
      ]),
      for (final am in coverAmbs21) ...[
        const SizedBox(height: 12),
        Lab21('Ambiance ${_ambName(am).toLowerCase()}'),
        const SizedBox(height: 4),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (var v = 0; v < coverVariants21; v++) _Choice('assets/covers/s_${_theme}_${am}_$v.svg', current, '${_themeName(_theme)}, ambiance ${_ambName(am).toLowerCase()}, variante ${v + 1}'),
        ]),
      ],
      const SizedBox(height: 16),
      Align(alignment: Alignment.centerLeft, child: Chip21('Pochette automatique', onTap: () => Navigator.of(context).pop(''))),
    ]);
  }
}

/// Une pochette à toucher : 48 px, cadre rose et coche quand c'est la pochette actuelle.
class _Choice extends StatelessWidget {
  final String path, current, label;
  const _Choice(this.path, this.current, this.label);
  @override
  Widget build(BuildContext context) {
    final on = path == current;
    return Semantics(
      button: true,
      selected: on,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(path),
        child: Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: on ? Tk.acc : Colors.transparent, width: 2)),
          child: Stack(fit: StackFit.expand, children: [
            _thumb(path, 44, radius: 10),
            if (on) const Positioned(right: 2, bottom: 2, child: DecoratedBox(decoration: BoxDecoration(color: Tk.acc, shape: BoxShape.circle), child: Padding(padding: EdgeInsets.all(2), child: GameIcon('check', size: 12, color: Tk.bg)))),
          ]),
        ),
      ),
    );
  }
}

/// Écran « Pochettes » : tous les sons du joueur (en cours, en réserve, sortis) avec leur pochette ; toucher un son ouvre le choix.
class CoversScreen21 extends ConsumerWidget {
  const CoversScreen21({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final cur = s['cur'] == null ? null : _m(s['cur']);
    final stock = _l(s['stock']).map(_m).toList();
    final disco = _l(s['disco']).map(_m).toList();
    final none = cur == null && stock.isEmpty && disco.isEmpty;
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Pochettes', step: 'Studio', onBack: () => context.go('/studio')),
      const SizedBox(height: 12),
      Text('Choisis la pochette de chaque son.', style: V20Text.baloo(size: 20, line: 24)),
      Text('${coverThemes21.length * coverAmbs21.length * coverVariants21} pochettes dans le jeu : 13 motifs, 3 ambiances, 6 variantes. Sans choix, le jeu en attribue une selon le thème et l\'ambiance du texte.', style: V20Text.bs()),
      const SizedBox(height: 12),
      if (none) ...[
        const GameHint(icon: 'info', text: 'Aucun son pour le moment. Écris un texte au studio : sa pochette apparaîtra ici.'),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Aller au studio', onPressed: () => context.go('/studio')),
      ],
      if (cur != null) ...[
        const Lab21('En cours'),
        _Row(cur, 'En cours', ref),
        const SizedBox(height: 12),
      ],
      if (stock.isNotEmpty) ...[
        const Lab21('En réserve'),
        for (final c in stock) _Row(c, 'En réserve', ref),
        const SizedBox(height: 12),
      ],
      if (disco.isNotEmpty) ...[
        const Lab21('Sortis'),
        for (final c in disco) _Row(c, 'Sorti', ref),
      ],
    ]);
  }
}

class _Row extends StatelessWidget {
  final J song;
  final String state;
  final WidgetRef ref;
  const _Row(this.song, this.state, this.ref);
  @override
  Widget build(BuildContext context) {
    final custom = song['cover'] is String && isCoverPath21(song['cover'] as String);
    final th = Reg21.themes['${song['theme']}']?['n'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        halo: false,
        padding: const EdgeInsets.all(12),
        onTap: () => pickCover(context, ref, song),
        semanticLabel: 'Changer la pochette de ${song['title']}',
        child: Row(children: [
          _thumb(trackCover21(song), 64, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${song['title']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
              Text('$state · $th', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.bs()),
              const SizedBox(height: 4),
              GameTag(custom ? 'Choisie' : 'Automatique', style: custom ? GameTagStyle.ok : GameTagStyle.outline),
            ]),
          ),
          const GameIcon('arrow', size: 18, color: Tk.ink2),
        ]),
      ),
    );
  }
}
