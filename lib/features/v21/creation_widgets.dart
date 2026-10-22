import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/game_tag.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'start_screens.dart' show PlayerAvatar;

/// Composants de l'espace de création de l'artiste (identité, look, style, objectif).
/// Aucune règle de jeu ici : ils lisent l'état et affichent.

/// Teintes de peau du créateur (identifiants de Reg21.skins) : mêmes valeurs que tools/design/chars.py (SKINS 3, 5, 6).
const _skinColors = {'3': Color(0xFFA5683F), '5': Color(0xFF64391F), '6': Color(0xFF4B2916)};
Color skinColor21(String id) => _skinColors[id] ?? const Color(0xFFA5683F);

/// Texte du nom de scène en cours de saisie, ou un libellé d'attente.
String stageName21(J s) {
  final n = cleanName21((s['p'] as J)['name']);
  return n.isEmpty ? 'TON NOM DE SCÈNE' : n.toUpperCase();
}

Duration _dur(BuildContext c, int ms) => MediaQuery.of(c).disableAnimations ? Duration.zero : Duration(milliseconds: ms);

String _lookKey(J s) => '${(s['ap'] as J).values.join('-')}';

/// Fond de scène sous le personnage : halo magenta mesuré sur violet nuit.
class _StageGlow extends StatelessWidget {
  final Widget child;
  final double height;
  const _StageGlow({required this.child, required this.height});
  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minHeight: height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: V20.bannerBorder, width: 2),
          gradient: const RadialGradient(center: Alignment(0, .35), radius: 1.0, colors: [Color(0xFF4A1F6B), Tk.bg]),
          boxShadow: V20.cardShadow,
        ),
        child: child,
      );
}

/// Grande scène du créateur de look : le personnage en pied, qui change en fondu à chaque choix.
class LookStage21 extends StatelessWidget {
  final J s;
  const LookStage21(this.s, {super.key});
  @override
  Widget build(BuildContext context) => _StageGlow(
        height: 300,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(bottom: 18, child: Container(width: 150, height: 14, decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: const Color.fromRGBO(0, 0, 0, .35)))),
          AnimatedSwitcher(
            duration: _dur(context, 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: PlayerAvatar(s, key: ValueKey(_lookKey(s)), height: 270),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Text(stageName21(s), style: V20Text.baloo(size: 18, line: 22, color: cleanName21((s['p'] as J)['name']).isEmpty ? V20.ink2 : Tk.ink)),
          ),
        ]),
      );
}

/// Carte d'artiste : portrait, nom de scène en direct et repères (âge, origine, style).
class ArtistHero21 extends StatelessWidget {
  final J s;
  final double avatar;
  const ArtistHero21(this.s, {super.key, this.avatar = 120});

  @override
  Widget build(BuildContext context) {
    final p = s['p'] as J;
    final named = cleanName21(p['name']).isNotEmpty;
    final main = Reg21.styles[p['main']];
    return _StageGlow(
      height: avatar + 24,
      child: Row(children: [
        const SizedBox(width: 8),
        SizedBox(
          width: avatar * .8,
          child: AnimatedSwitcher(
            duration: _dur(context, 200),
            child: PlayerAvatar(s, key: ValueKey(_lookKey(s)), crop: 'bust', height: avatar),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TON ARTISTE', style: V20Text.lab()),
              const SizedBox(height: 2),
              Text(stageName21(s), maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.dm(size: 26, line: 26, color: named ? Tk.ink : V20.ink2)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                GameTag('${p['age']} ans', style: GameTagStyle.outline, color: Tk.ink),
                GameTag(Reg21.origins[p['origin']] ?? '', style: GameTagStyle.outline, color: Tk.ink),
                if (main != null) GameTag(main['n'] as String, style: GameTagStyle.accent),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Choix de teint : pastille de couleur, 48 px de cible, libellé dessous.
class SkinDot21 extends StatelessWidget {
  final String id;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const SkinDot21({super.key, required this.id, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: 'Teint $label',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 80),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: _dur(context, 150),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skinColor21(id),
                  border: Border.all(color: selected ? Tk.acc4 : const Color.fromRGBO(255, 255, 255, .2), width: selected ? 3 : 2),
                  boxShadow: selected ? const [BoxShadow(color: Color.fromRGBO(244, 63, 157, .4), blurRadius: 14)] : null,
                ),
                child: selected ? const Icon(Icons.check_rounded, color: Tk.ink, size: 22) : null,
              ),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: V20Text.poppins(size: 12, line: 14, weight: FontWeight.w700, color: selected ? Tk.ink : V20.ink2)),
            ]),
          ),
        ),
      );
}

/// Tuile d'option avec vignette du personnage et libellé (coiffure, haut).
class OptionTile21 extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget thumb;
  const OptionTile21({super.key, required this.label, required this.selected, required this.onTap, required this.thumb});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: _dur(context, 150),
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Tk.rCard),
              color: selected ? Tk.tint : Tk.s1,
              border: Border.all(color: selected ? Tk.acc4 : V20.cardBorder, width: 2),
              boxShadow: selected ? const [BoxShadow(color: Color.fromRGBO(244, 63, 157, .3), blurRadius: 16)] : null,
            ),
            child: Column(children: [
              SizedBox(height: 92, child: Center(child: thumb)),
              const SizedBox(height: 4),
              SizedBox(
                height: 32,
                child: Center(child: Text(label, maxLines: 2, textAlign: TextAlign.center, style: V20Text.poppins(size: 12, line: 15, weight: FontWeight.w700, color: selected ? Tk.ink : V20.ink2))),
              ),
            ]),
          ),
        ),
      );
}

/// Jauge d'énergie de départ selon l'âge (cyan) : montre ce que coûte de vieillir, sans règle ajoutée.
class EnergyMeter21 extends StatelessWidget {
  final int value;
  const EnergyMeter21(this.value, {super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('ÉNERGIE MAXIMALE', style: V20Text.lab()),
          Text('$value', style: V20Text.nm(color: Tk.cy)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: (value / 100).clamp(0, 1).toDouble()),
            duration: _dur(context, 250),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 6, backgroundColor: const Color.fromRGBO(255, 255, 255, .12), valueColor: const AlwaysStoppedAnimation(Tk.cy)),
          ),
        ),
      ]);
}
