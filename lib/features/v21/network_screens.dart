import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'cast21.dart';
import 'social_screens.dart';
import 'widgets21.dart';

/// Espace Réseau v21 (planches 21-N0 à 21-N8) [VALIDÉ par Smith le 20/10/2026].
/// Intention de jeu : voir où vit sa musique (trois plateformes, chacune avec son identité), regarder ses clips,
/// et décider d'une campagne Local, National ou Global en voyant son coût et ses effets avant d'acheter.
/// Les plateformes répartissent des écoutes déjà calculées : aucune écoute ni aucun revenu en plus. Valeurs provisoires (D-08).

num _n(dynamic x) => (x ?? 0) as num;

const _ondA = Color(0xFF0F4C66), _ondB = Color(0xFF2C2272);
const _klpGold = Tk.gold, _klpBg = Color(0xFF07060B);
const _cauA = Color(0xFF7A1F55), _cauB = Color(0xFF3A1B52);

/// Fond d'ambiance d'une plateforme : la palette reste celle du jeu, seule l'ambiance change.
class _Ambience extends StatelessWidget {
  final List<Color> colors;
  final List<Widget> children;
  const _Ambience({required this.colors, required this.children});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors)),
        child: ListView(padding: const EdgeInsets.all(16), children: children),
      );
}

class _Logo extends StatelessWidget {
  final String name;
  final double size;
  const _Logo(this.name, this.size);
  @override
  Widget build(BuildContext context) => SvgPicture.asset('assets/svg/logo-$name.svg', width: size, height: size);
}

/// Miniature 16:9 (SVG sans texte) avec durée, type et bouton lecture ; repli sombre si le fichier manque.
class _Thumb extends StatelessWidget {
  final String path;
  final String? dur, kind;
  final bool play;
  final double radius;
  const _Thumb(this.path, {this.dur, this.kind, this.play = false, this.radius = 14});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(fit: StackFit.expand, children: [
            SvgPicture.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF171323))),
            if (play)
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .16), border: Border.all(color: Colors.white.withValues(alpha: .45), width: 1.5)),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                ),
              ),
            if (kind != null)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _klpGold, borderRadius: BorderRadius.circular(99)),
                  child: Text(kind!.toUpperCase(), style: V20Text.poppins(size: 10, line: 15, weight: FontWeight.w800, color: Tk.bg, spacing: .8)),
                ),
              ),
            if (dur != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: .78), borderRadius: BorderRadius.circular(6)),
                  child: Text(dur!, style: V20Text.poppins(size: 11, line: 15, weight: FontWeight.w700)),
                ),
              ),
          ]),
        ),
      );
}

/// Trois chiffres côte à côte.
class _Kpis extends StatelessWidget {
  final List<(String, String, Color?)> items;
  const _Kpis(this.items);
  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .08), width: 1.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(items[i].$1.toUpperCase(), style: V20Text.lab()),
                const SizedBox(height: 2),
                FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(items[i].$2, style: V20Text.baloo(size: 20, line: 22, color: items[i].$3 ?? Tk.ink))),
              ]),
            ),
          ),
        ],
      ]);
}

/// Notoriété Local / National / Global.
class _Tiers extends StatelessWidget {
  final J s;
  final bool subs;
  const _Tiers(this.s, {this.subs = true});
  @override
  Widget build(BuildContext context) {
    final nt = notoriety21(s);
    Widget cell(String lab, double v, String sub, MeterTone tone) => Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .06), Colors.white.withValues(alpha: .02)]),
                border: Border.all(color: Colors.white.withValues(alpha: .08), width: 1.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lab.toUpperCase(), style: V20Text.lab()),
              const SizedBox(height: 4),
              Text(_dec(v), style: V20Text.baloo(size: 26, line: 26)),
              const SizedBox(height: 6),
              MeterBar(value: v / 100, tone: tone, thin: true),
              if (subs) ...[const SizedBox(height: 6), Text(sub, style: V20Text.poppins(size: 11, line: 14, color: V20.ink2))],
            ]),
          ),
        );
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      cell('Local', nt.local, 'Bakoma', MeterTone.gold),
      const SizedBox(width: 8),
      cell('National', nt.national, 'Bakoma, Port-Ambre, Sélène', MeterTone.brand),
      const SizedBox(width: 8),
      cell('Global', nt.global, '6 villes, 4 continents', MeterTone.cyan),
    ]);
  }
}

/// Auditeurs estimés d'une ville : répartition des auditeurs au prorata de la popularité par ville.
int _cityListeners(J s, String city, int total) {
  final g = (s['geo'] as Map?) ?? const {};
  final sum = Reg21.cities.keys.fold<num>(0, (a, k) => a + _n(g[k]));
  return sum <= 0 ? 0 : jsRound(total * _n(g[city]) / sum);
}

String _dec(num v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1).replaceAll('.', ',');

/// Grande carte de plateforme (hub).
class _PfCard extends StatelessWidget {
  final String logo, eyebrow, big, sub;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;
  final String? image;
  const _PfCard({required this.logo, required this.eyebrow, required this.big, required this.sub, required this.colors, required this.accent, required this.onTap, this.image});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '$eyebrow, $big',
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              constraints: const BoxConstraints(minHeight: 150),
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                  border: Border.all(color: accent.withValues(alpha: .35), width: 1.5),
                  borderRadius: BorderRadius.circular(22)),
              child: Stack(children: [
                if (image != null) ...[
                  Positioned.fill(child: Opacity(opacity: .75, child: SvgPicture.asset(image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()))),
                  const Positioned.fill(
                      child: DecoratedBox(
                          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xD9000000)], stops: [.3, 1])))),
                ],
                if (logo.isNotEmpty) Positioned(left: 16, top: 14, child: _Logo(logo, 40)),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: .35)),
                      child: const Icon(Icons.arrow_forward_rounded, color: Tk.ink, size: 22)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 66, 16, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(eyebrow.toUpperCase(), style: V20Text.lab(color: accent)),
                    FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(big, style: V20Text.baloo(size: 30, line: 30))),
                    Text(sub, style: V20Text.poppins(size: 12, line: 16, color: Tk.ink)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _Sec extends StatelessWidget {
  final String title;
  final String? sub;
  const _Sec(this.title, [this.sub]);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(title, style: V20Text.baloo(size: 18, line: 20))),
          if (sub != null) Text(sub!, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
        ]),
      );
}

String _thumbOf(int i) => (klipo21[i]['img'] as String);

// ---------------------------------------------------------------------------------------------------------------------
// 21-N0 Réseau
// ---------------------------------------------------------------------------------------------------------------------

class ReseauScreen extends ConsumerWidget {
  const ReseauScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final clips = myClips21(s);
    final act = mkActive21(s);
    final sp = mkSponsor21(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Réseau', step: 'N0', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      _Tiers(s),
      const SizedBox(height: 12),
      _PfCard(
          logo: 'ondea',
          eyebrow: 'Ondéa · streaming audio',
          big: fmt21(t.ondea),
          sub: 'écoutes · ${fmt21(t.listeners)} auditeurs estimés',
          colors: const [_ondA, _ondB, Tk.bg],
          accent: Tk.cy,
          onTap: () => context.go('/profil/reseau/ondea')),
      const SizedBox(height: 12),
      _PfCard(
          logo: 'klipo',
          eyebrow: 'Klipo · vidéos',
          big: fmt21(t.klipoViews),
          sub: 'vues de tes clips · 50 vidéos à la une',
          colors: const [Color(0xFF2A2108), _klpBg],
          accent: _klpGold,
          onTap: () => context.go('/profil/reseau/klipo')),
      const SizedBox(height: 12),
      _PfCard(
          logo: 'cauri',
          eyebrow: 'Cauri Music · premium',
          big: fmt21(t.cauri),
          sub: 'écoutes premium · ${fmt21(t.revCauri)} cauris',
          colors: const [_cauA, _cauB, Color(0xFF1A0A1F)],
          accent: Tk.acc4,
          onTap: () => context.go('/profil/reseau/cauri')),
      const SizedBox(height: 12),
      _PfCard(
          logo: '',
          eyebrow: 'Mes clips',
          big: '${clips.length} clip(s)',
          sub: '${fmt21(t.klipoViews)} vues cumulées sur Klipo',
          colors: const [Colors.black, Colors.black],
          accent: _klpGold,
          image: clips.isEmpty ? 'assets/klipo/mine/M1.svg' : clipStats21(clips.first, 0).img,
          onTap: () => context.go('/profil/reseau/clips')),
      const SizedBox(height: 12),
      const SocialEntryCard(),
      const SizedBox(height: 12),
      GameCard(
        onTap: () => context.go('/profil/reseau/marketing'),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Marketing et médias', style: V20Text.nm()),
              Text('${act.length} campagne(s) en cours · partenaire en concert : ${sp == null ? 'aucun' : media21[sp]!.n}', style: V20Text.bs()),
            ]),
          ),
          GameTag(act.isEmpty ? 'Aucune' : 'Actif', style: act.isEmpty ? GameTagStyle.outline : GameTagStyle.ok),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, color: Tk.ink),
        ]),
      ),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Trois plateformes fictives se partagent les écoutes déjà calculées par le jeu (aucune écoute en plus). La notoriété Local, National et Global vient de ta popularité par ville.'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-N1 Ondéa (cyan et violet, page artiste)
// ---------------------------------------------------------------------------------------------------------------------

class OndeaArtistScreen extends ConsumerWidget {
  const OndeaArtistScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final disco = (s['disco'] as List).map((x) => x as J).toList();
    final share = Reg21.platforms['ondea']!['share'] as num;
    const pls = [('Drill de Bakoma', 7), ('Nuits de Lumbé', 13), ('Afro-soul Sélène', 6), ('Nouveaux talents', 21)];
    return _Ambience(colors: const [Color(0xFF123A55), Color(0xFF1E1650), Color(0xFF0E1230)], children: [
      Row(children: [
        Expanded(child: BackHeader(title: 'Ondéa', step: 'N1', onBack: () => context.go('/profil/reseau'))),
        const _Logo('ondea', 36),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withValues(alpha: .09), Colors.white.withValues(alpha: .03)]),
            border: Border.all(color: Colors.white.withValues(alpha: .12), width: 1.5)),
        child: Column(children: [
          Row(children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Tk.cy, width: 3)),
              child: ClipOval(child: SvgPicture.asset('assets/klipo/mine/M3.svg', fit: BoxFit.cover, alignment: const Alignment(0, -.4))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('ARTISTE', style: V20Text.lab(color: V20.hintCyanText)),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: Tk.cy, size: 16, semanticLabel: 'Profil vérifié'),
                ]),
                Text(playerName(s), style: V20Text.baloo(size: 28, line: 30)),
                Text('${fmt21(t.listeners)} auditeurs estimés · ${fmt21(t.followers)} abonnés', style: V20Text.poppins(size: 12, line: 16, color: V20.hintCyanText)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          _Kpis([('Écoutes', fmt21(t.ondea), null), ('Revenus', fmt21(t.revOndea), Tk.gold), ('Part', '${(share * 100).round()} %', null)]),
        ]),
      ),
      const _Sec('Titres populaires', 'écoutes Ondéa'),
      if (disco.isEmpty)
        const GameCard(child: Text('Aucun titre sorti. Sors un single pour apparaître sur Ondéa.'))
      else
        for (var i = 0; i < disco.length && i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: 22, child: Text('${i + 1}', textAlign: TextAlign.center, style: V20Text.baloo(size: 16, line: 16, color: const Color(0xFF7FE7FF)))),
              const SizedBox(width: 10),
              ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 52, height: 52, child: SvgPicture.asset('assets/klipo/mine/M${i + 1}.svg', fit: BoxFit.cover))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${disco[i]['title']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
                  Text('${fmt21(jsRound(platformListens(disco[i]) * share))} écoutes · ${playerName(s)}', style: V20Text.bs()),
                ]),
              ),
              const Icon(Icons.music_note_rounded, color: V20.ink2, size: 20),
            ]),
          ),
      const _Sec('Auditeurs par ville', 'estimés'),
      GameCard(child: Column(children: [
        for (final c in Reg21.cities.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: 96, child: Text(c.value, style: V20Text.poppins(size: 13, line: 17, weight: FontWeight.w700))),
              Expanded(child: MeterBar(value: (geoOf(s, c.key) / 100).clamp(0, 1).toDouble(), tone: MeterTone.cyan, thin: true)),
              SizedBox(
                  width: 70,
                  child: Text(fmt21(_cityListeners(s, c.key, t.listeners)), textAlign: TextAlign.end, style: V20Text.poppins(size: 13, line: 17, weight: FontWeight.w700))),
            ]),
          ),
      ])),
      const Row(children: [
        Expanded(child: _Sec('Playlists éditoriales')),
        Padding(padding: EdgeInsets.only(top: 12), child: GameTag('Démo', style: GameTagStyle.outline)),
      ]),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          for (final p in pls)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(fit: StackFit.expand, children: [
                SvgPicture.asset(_thumbOf(p.$2), fit: BoxFit.cover),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xBF000000)], stops: [.4, 1]))),
                Positioned(left: 10, right: 10, bottom: 10, child: Text(p.$1, style: V20Text.baloo(size: 16, line: 17))),
              ]),
            ),
        ],
      ),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Playlists de démonstration : le placement en playlist n\'est pas encore une règle du jeu (à concevoir).'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-N2 Klipo (noir et or, 50 vidéos) et 21-N3 lecteur
// ---------------------------------------------------------------------------------------------------------------------

class _RailItem extends ConsumerWidget {
  final int i;
  const _RailItem(this.i);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final k = klipo21[i];
    return Semantics(
      button: true,
      label: 'Vidéo ${k['t']} de ${k['a']}',
      child: GestureDetector(
        onTap: () => doAct(context, ref, 'kv', i, () => context.go('/profil/reseau/klipo/video')),
        child: SizedBox(
          width: 208,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Thumb(_thumbOf(i), dur: k['du'] as String),
            const SizedBox(height: 6),
            Text(k['t'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 13, line: 17, weight: FontWeight.w600)),
            Row(children: [
              CastAvatar(k['a'] as String, size: 22, ring: _klpGold),
              const SizedBox(width: 6),
              Expanded(child: Text('${k['a']} · ${fmtK21(k['v'] as num)} vues', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 11, line: 14, color: V20.ink2))),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final String title;
  final String? sub;
  final List<int> idx;
  const _Rail(this.title, this.idx, [this.sub]);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Sec(title, sub),
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: idx.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, j) => _RailItem(idx[j]),
          ),
        ),
      ]);
}

List<int> _cat(List<String> kinds) => [for (var i = 0; i < klipo21.length; i++) if (kinds.contains(klipo21[i]['k'])) i];

class KlipoHomeScreen extends ConsumerWidget {
  const KlipoHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final clips = myClips21(s);
    final h = klipo21.first;
    final officials = _cat(['Clip officiel']);
    return _Ambience(colors: const [Color(0xFF1A1508), _klpBg, _klpBg], children: [
      Row(children: [
        Expanded(child: BackHeader(title: 'Klipo', step: 'N2', onBack: () => context.go('/profil/reseau'))),
        const _Logo('klipo', 32),
      ]),
      const SizedBox(height: 8),
      const Align(alignment: Alignment.centerLeft, child: GameTag('50 vidéos · démo', style: GameTagStyle.outline)),
      const SizedBox(height: 12),
      Semantics(
        button: true,
        label: 'À la une : ${h['t']}',
        child: GestureDetector(
          onTap: () => doAct(context, ref, 'kv', 0, () => context.go('/profil/reseau/klipo/video')),
          child: _Thumb(_thumbOf(0), dur: h['du'] as String, kind: 'À la une', play: true, radius: 20),
        ),
      ),
      const SizedBox(height: 8),
      Text(h['t'] as String, style: V20Text.nm()),
      Text('${h['a']} · ${fmtK21(h['v'] as num)} vues · ${h['k']}', style: V20Text.bs()),
      const SizedBox(height: 12),
      _PfCard(
          logo: '',
          eyebrow: 'Ta chaîne · Klipo Studio',
          big: '${fmt21(t.klipoViews)} vues',
          sub: '${clips.length} clip(s) publié(s)',
          colors: const [Colors.black, Colors.black],
          accent: _klpGold,
          image: clips.isEmpty ? 'assets/klipo/mine/M1.svg' : clipStats21(clips.first, 0).img,
          onTap: () => context.go('/profil/reseau/clips')),
      _Rail('Tendances', [for (var i = 1; i < 10; i++) i], 'les plus vues'),
      _Rail('Clips officiels', officials.length > 9 ? officials.sublist(9) : officials),
      _Rail('Live et festivals', _cat(['Live'])),
      _Rail('Freestyles et battles', _cat(['Freestyle', 'Battle'])),
      _Rail('Coulisses et visualizers', _cat(['Coulisses', 'Visualizer'])),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Catalogue de démonstration : 50 vidéos d\'artistes fictifs. Les vues sont des données d\'univers, pas des écoutes du joueur.'),
    ]);
  }
}

class KlipoPlayerScreen extends ConsumerWidget {
  const KlipoPlayerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final i = _n(s['kv']).toInt().clamp(0, klipo21.length - 1).toInt();
    final k = klipo21[i];
    final v = k['v'] as num;
    const next = [10, 11, 15, 13, 20, 29, 35, 44];
    return _Ambience(colors: const [_klpBg, _klpBg], children: [
      Row(children: [
        Expanded(child: BackHeader(title: 'Klipo', step: 'N3', onBack: () => context.go('/profil/reseau/klipo'))),
        const GameTag('Lecture simulée', style: GameTagStyle.outline),
      ]),
      const SizedBox(height: 12),
      _Thumb(_thumbOf(i), dur: k['du'] as String, play: true, radius: 16),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: _klpGold, borderRadius: BorderRadius.circular(99)),
          child: Text((k['k'] as String).toUpperCase(), style: V20Text.poppins(size: 10, line: 15, weight: FontWeight.w800, color: Tk.bg, spacing: .8)),
        ),
      ),
      const SizedBox(height: 4),
      Text(k['t'] as String, style: V20Text.baloo(size: 24, line: 26)),
      const SizedBox(height: 6),
      Row(children: [
        CastAvatar(k['a'] as String, size: 44, ring: _klpGold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(k['a'] as String, style: V20Text.nm()),
            Text('${castRole21(k['a'] as String).isEmpty ? 'Artiste de Bakoma' : castRole21(k['a'] as String)} · ${fmtK21(v)} vues · il y a ${k['age']} j', style: V20Text.bs()),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      _Kpis([('Vues', fmtK21(v), null), ("J'aime", fmtK21(jsRound(v * 0.048)), null), ('Comm.', fmtK21(jsRound(v * 0.0042)), null)]),
      const _Sec('À suivre'),
      for (final j in next)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Semantics(
            button: true,
            label: 'Vidéo ${klipo21[j]['t']}',
            child: GestureDetector(
              onTap: () => doAct(context, ref, 'kv', j),
              child: Row(children: [
                SizedBox(width: 132, child: _Thumb(_thumbOf(j), dur: klipo21[j]['du'] as String, radius: 10)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(klipo21[j]['t'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700)),
                    Text('${klipo21[j]['a']} · ${fmtK21(klipo21[j]['v'] as num)} vues', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-N4 Mes clips et 21-N5 détail
// ---------------------------------------------------------------------------------------------------------------------

class MyClipsScreen extends ConsumerWidget {
  const MyClipsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final clips = myClips21(s);
    final tot = [for (var i = 0; i < clips.length; i++) clipStats21(clips[i], i).v].fold<int>(0, (a, b) => a + b);
    return _Ambience(colors: const [Color(0xFF15110A), Color(0xFF0B0912)], children: [
      Row(children: [
        Expanded(child: BackHeader(title: 'Mes clips', step: 'N4', onBack: () => context.go('/profil/reseau'))),
        const _Logo('klipo', 30),
      ]),
      const SizedBox(height: 12),
      _Kpis([('Clips', '${clips.length}', null), ('Vues', fmt21(tot), null), ('Plateforme', 'Klipo', _klpGold)]),
      const SizedBox(height: 12),
      if (clips.isEmpty)
        GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Aucun clip publié', style: V20Text.nm()),
            Text('Un clip se prépare avant la sortie du titre, se tourne, puis se publie après la sortie.', style: V20Text.bs()),
            const SizedBox(height: 12),
            PrimaryGlowButton(label: 'Préparer un clip', onPressed: () => context.go('/studio/clip')),
          ]),
        ),
      for (var q = 0; q < clips.length; q++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GameCard(
            padding: const EdgeInsets.all(8),
            onTap: () => doAct(context, ref, 'mcl', q, () => context.go('/profil/reseau/clips/clip')),
            child: Row(children: [
              SizedBox(width: 140, child: _Thumb(clipStats21(clips[q], q).img, dur: 'Clip', radius: 10)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${clips[q]['title']}', style: V20Text.nm()),
                  Text('${fmt21(clipStats21(clips[q], q).v)} vues', style: V20Text.bs()),
                ]),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Tk.ink),
            ]),
          ),
        ),
      const SizedBox(height: 4),
      const GameHint(icon: 'info', text: 'Vues = 2 par écoute apportée par le clip (règle provisoire). J\'aime, commentaires et rétention : estimations de démonstration.'),
    ]);
  }
}

const _directors = {'sika': 'Sika Nébo', 'ombre': 'Studio Ombre', 'ilan': 'Ilan Kéré'};

class ClipDetailScreen extends ConsumerWidget {
  const ClipDetailScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final clips = myClips21(s);
    if (clips.isEmpty) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Mon clip', step: 'N5', onBack: () => context.go('/profil/reseau/clips')),
        const SizedBox(height: 12),
        Text('Aucun clip publié', style: V20Text.nm()),
      ]);
    }
    final i = _n(s['mcl']).toInt().clamp(0, clips.length - 1).toInt();
    final c = clips[i];
    final st = clipStats21(c, i);
    final dir = (c['clip'] as Map)['dir'];
    return _Ambience(colors: const [Color(0xFF15110A), Color(0xFF0B0912)], children: [
      Row(children: [
        Expanded(child: BackHeader(title: 'Mon clip', step: 'N5', onBack: () => context.go('/profil/reseau/clips'))),
        const GameTag('Estimé', style: GameTagStyle.outline),
      ]),
      const SizedBox(height: 12),
      _Thumb(st.img, kind: 'Clip officiel', play: true, radius: 16),
      const SizedBox(height: 8),
      Text('${c['title']}', style: V20Text.baloo(size: 26, line: 28)),
      Text('Réalisation ${_directors[dir] ?? dir ?? '—'} · publié J${c['day']} · viralité ${c['vir']}', style: V20Text.bs()),
      const SizedBox(height: 12),
      _Kpis([('Vues', fmt21(st.v), null), ("J'aime", fmt21(st.lk), null), ('Comm.', fmt21(st.cm), null)]),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('RÉTENTION MOYENNE', style: V20Text.lab())), Text('${st.ret} %', style: V20Text.nm())]),
          const SizedBox(height: 6),
          MeterBar(value: st.ret / 100, tone: MeterTone.gold),
          const SizedBox(height: 8),
          Conseq21(ConsequenceKind.certain, 'Écoutes apportées par le clip : +${fmt21(_n(c['clipL']))} · fans : ${sg21(_n(c['clipF']))}'),
          const Conseq21(ConsequenceKind.estimated, 'Rétention, j\'aime et commentaires : estimations de démonstration'),
        ]),
      ),
      const SizedBox(height: 16),
      PrimaryGlowButton(label: 'Booster avec une campagne', onPressed: () => context.go('/profil/reseau/marketing')),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Voir Klipo', style: GameButtonStyle.ghost, onPressed: () => context.go('/profil/reseau/klipo')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-N6 Cauri Music (rose et or, éditorial premium)
// ---------------------------------------------------------------------------------------------------------------------

class CauriPremiumScreen extends ConsumerWidget {
  const CauriPremiumScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final t = platformTotals(s);
    final disco = (s['disco'] as List).map((x) => x as J).toList();
    final share = Reg21.platforms['cauri']!['share'] as num;
    Widget prem(String txt) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: Tk.gold.withValues(alpha: .6))),
          child: Text(txt.toUpperCase(), style: V20Text.poppins(size: 10, line: 14, weight: FontWeight.w700, color: V20.hintGoldText, spacing: 1.4)),
        );
    return _Ambience(colors: const [Color(0xFF3B1236), Color(0xFF1A0A1F)], children: [
      Row(children: [
        Expanded(child: BackHeader(title: 'Cauri Music', step: 'N6', onBack: () => context.go('/profil/reseau'))),
        const _Logo('cauri', 32),
      ]),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: SizedBox(
          height: 250,
          child: Stack(fit: StackFit.expand, children: [
            SvgPicture.asset('assets/klipo/mine/M7.svg', fit: BoxFit.cover),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x001A0A1F), Color(0xF21A0A1F)], stops: [.25, 1]))),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
                prem('Sélection premium'),
                const SizedBox(height: 8),
                Text(disco.isEmpty ? 'Ta première sortie' : '${disco.first['title']}', style: V20Text.baloo(size: 30, line: 30)),
                Text('par ${playerName(s)} · édition Hi-Fi', style: V20Text.poppins(size: 12, line: 16, color: const Color(0xFFFFE3F1))),
              ]),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      _Kpis([('Écoutes', fmt21(t.cauri), null), ('Revenus', fmt21(t.revCauri), Tk.gold), ('Part', '${(share * 100).round()} %', null)]),
      const SizedBox(height: 8),
      _Kpis([
        ('Ventes', fmt21(disco.fold<num>(0, (a, d) => a + _n(d['sales']))), null),
        ('Titres', '${disco.length}', null),
        ('Hi-Fi', 'Oui', Tk.gold),
      ]),
      const _Sec('Ta discographie', 'écoute premium'),
      if (disco.isEmpty) const GameCard(child: Text('Aucun titre sorti.')),
      for (var i = 0; i < disco.length && i < 5; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 52, height: 52, child: SvgPicture.asset('assets/klipo/mine/M${8 - i}.svg', fit: BoxFit.cover))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${disco[i]['title']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm()),
                Text('${fmt21(jsRound(platformListens(disco[i]) * share))} écoutes premium', style: V20Text.bs()),
              ]),
            ),
            prem('Hi-Fi'),
          ]),
        ),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Cauri Music reçoit 30 % des écoutes audio (règle provisoire des plateformes).'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-N7 Marketing et médias, 21-N8 confirmation
// ---------------------------------------------------------------------------------------------------------------------

String _mono(String n) => n.split(RegExp(r'[\s\-]+')).where((w) => w.isNotEmpty && RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(w[0])).map((w) => w[0]).take(3).join().toUpperCase();
String _fx(Media21 m) => m.geo.entries.map((e) => '${geoName21[e.key]} +${_dec(e.value)}/j').join(' · ');

class MarketingScreen extends ConsumerWidget {
  const MarketingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final act = mkActive21(s);
    final sp = mkSponsor21(s);
    final mk = (s['mk'] as Map?) ?? const {};
    const tiers = [('local', 'Local', 'Bakoma · dès N1'), ('national', 'National', 'Bakoma, Port-Ambre, Sélène · dès N3'), ('global', 'Global', 'Tamarel, Korvane, Aldéra · dès N5')];
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Marketing et médias', step: 'N7', onBack: () => context.go('/profil/reseau')),
      const SizedBox(height: 12),
      _Tiers(s, subs: false),
      const SizedBox(height: 12),
      _Kpis([('En cours', '${act.length}', null), ('Bonus écoutes', '+${(mkBoost21(s) * 100).round()} %', null), ('Investi', fmt21(_n(mk['tot'])), Tk.gold)]),
      const SizedBox(height: 12),
      GlassCard(
        accent: sp == null ? GlassAccent.none : GlassAccent.magenta,
        halo: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('VISIBLE SUR SCÈNE', style: V20Text.lab())),
            GameTag(sp == null ? 'Aucun' : 'Actif', style: sp == null ? GameTagStyle.outline : GameTagStyle.ok),
          ]),
          const SizedBox(height: 4),
          Text(
              sp == null
                  ? 'Lance une campagne avec un média partenaire : son nom s\'affiche sur l\'écran géant de tes concerts.'
                  : 'Partenaire actuel : ${media21[sp]!.n}. Son nom s\'affiche sur l\'écran géant de tes concerts (+${(media21[sp]!.spon * 100).round()} % de cachet).',
              style: V20Text.bs(color: Tk.ink)),
        ]),
      ),
      for (final t in tiers) ...[
        _Sec(t.$2, t.$3),
        for (final id in mediaOrder21.where((x) => media21[x]!.lvl == t.$1)) ...[_MediaCard(s, media21[id]!), const SizedBox(height: 10)],
      ],
      const GameHint(
          icon: 'info',
          text: 'Médias fictifs. Prix, durées et effets provisoires (D-08). Effets appliqués chaque fin de journée ; le bonus d\'écoutes s\'applique aux sorties pendant la campagne. Achat de 15 000 cauris ou plus : confirmation.'),
    ]);
  }
}

class _MediaCard extends ConsumerWidget {
  final J s;
  final Media21 m;
  const _MediaCard(this.s, this.m);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = mkActive21(s).where((c) => c['id'] == m.id).firstOrNull;
    final e = mkCheck21(s, m.id);
    final locked = _n(s['rank']) < m.rank;
    final col = Color(m.col);
    return Opacity(
      opacity: locked ? .72 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Tk.s1,
          gradient: on != null ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Tk.ok.withValues(alpha: .10), Tk.s1]) : null,
          border: Border.all(color: on != null ? Tk.ok : Tk.line, width: 2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(12)),
                child: Text(_mono(m.n), style: V20Text.baloo(size: 14, line: 14, color: Tk.bg))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.n, style: V20Text.nm()),
                Text('${m.kind} · ${m.d} jours', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              ]),
            ),
            if (on != null) GameTag('En cours · ${_n(on['until']) - _n(s['day'])} j', style: GameTagStyle.ok),
            if (on == null && locked) GameTag('Rang N${m.rank}', style: GameTagStyle.outline),
            if (on == null && !locked && e == 'cash') const GameTag('Cash insuffisant', style: GameTagStyle.outline),
          ]),
          const SizedBox(height: 8),
          Text('${_fx(m)} · fans +${m.fans}/j · écoutes des sorties +${(m.boost * 100).round()} %${m.spon > 0 ? ' · sponsor en concert +${(m.spon * 100).round()} % de cachet' : ''}', style: V20Text.bs()),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('${fmt21(m.c)} cauris', style: V20Text.poppins(size: 13, line: 18, weight: FontWeight.w700, color: Tk.gold))),
            if (e == null)
              SizedBox(
                height: 48,
                child: PrimaryButton(
                  label: 'Lancer · ${fmt21(m.c)}',
                  compact: true,
                  arrow: false,
                  onPressed: () => m.c >= mediaConfirmAt21
                      ? doAct(context, ref, 'mkask', m.id, () => _confirmSheet(context, ref))
                      : doAct(context, ref, 'mkbuy', m.id, null, 'Campagne lancée : ${m.n}'),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

Future<void> _confirmSheet(BuildContext context, WidgetRef ref) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Consumer(builder: (ctx, ref, _) {
      final s = ref.watch(game21Provider).valueOrNull;
      final id = s == null ? null : (s['mk'] as Map?)?['ask'] as String?;
      final m = id == null ? null : media21[id];
      if (s == null || m == null) return const SizedBox();
      return BottomSheetGame(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('CONFIRMATION · CAMPAGNE ${mediaLevelName21[m.lvl]!.toUpperCase()}', style: V20Text.lab()),
          const SizedBox(height: 4),
          Text('Lancer ${m.n} ?', style: V20Text.dm(size: 26)),
          const SizedBox(height: 8),
          Conseq21(ConsequenceKind.certain, 'Coût ${fmt21(m.c)} cauris, débité tout de suite · durée ${m.d} jours'),
          Conseq21(ConsequenceKind.estimated, 'Effets par jour : ${_fx(m)} · fans +${m.fans}/j'),
          Conseq21(ConsequenceKind.estimated, 'Écoutes des sorties pendant la campagne : +${(m.boost * 100).round()} % · cachet de concert : +${(m.spon * 100).round()} %'),
          const Conseq21(ConsequenceKind.uncertain, 'Effets provisoires, à calibrer.'),
          const SizedBox(height: 8),
          KeyVal('Cash après achat', fmt21(_n(s['cash']) - m.c)),
          const SizedBox(height: 12),
          PrimaryGlowButton(
              label: 'Lancer la campagne',
              sublabel: 'Achat définitif',
              onPressed: () => doAct(ctx, ref, 'mkconfirm', null, () => Navigator.of(ctx).pop(true), 'Campagne lancée : ${m.n}')),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Annuler', style: GameButtonStyle.ghost, onPressed: () => Navigator.of(ctx).pop(false)),
        ]),
      );
    }),
  );
  if (done != true) await ref.read(game21Provider.notifier).act('mkcancel');
}

// ---------------------------------------------------------------------------------------------------------------------
// Public visible en concert (21-C2 aperçu, 21-C3 résultat) : 4 densités, écran LED avec le média partenaire
// ---------------------------------------------------------------------------------------------------------------------

/// Scène vue depuis la fosse : image du public selon le remplissage ; le nom du média est posé en texte sur l'écran LED
/// (zone 101, 28, 188 × 52 du cadre 390 × 220), car flutter_svg n'affiche pas le texte des SVG.
class CrowdStage extends StatelessWidget {
  final num fill; // 0 à 1
  final String? media;
  final String fillLabel;
  const CrowdStage({super.key, required this.fill, this.media, this.fillLabel = 'Salle remplie à'});
  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: 'Le public devant la scène, ${(fill * 100).round()} % de remplissage${media != null ? ', partenaire $media sur l\'écran' : ''}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 390 / 220,
            child: LayoutBuilder(builder: (_, c) {
              final k = c.maxWidth / 390;
              return Stack(children: [
                Positioned.fill(child: SvgPicture.asset(crowdAsset21(fill), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Tk.deep))),
                Positioned(
                  left: 101 * k,
                  top: 28 * k,
                  width: 188 * k,
                  height: 52 * k,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(media == null ? 'NDOLO' : 'PARTENAIRE MÉDIA', style: V20Text.poppins(size: 9, line: 11, weight: FontWeight.w700, color: V20.hintGoldText, spacing: 1.6)),
                      Text((media ?? 'Le Parvis').toUpperCase(),
                          style: V20Text.baloo(size: 18, line: 19).copyWith(shadows: const [Shadow(color: Tk.acc4, blurRadius: 10)], letterSpacing: 1)),
                    ]),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .7), borderRadius: BorderRadius.circular(99)),
                    child: Text('$fillLabel ${(fill * 100).round()} %', style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700)),
                  ),
                ),
              ]);
            }),
          ),
        ),
      );
}
