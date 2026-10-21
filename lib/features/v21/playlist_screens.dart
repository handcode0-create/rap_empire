import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/reward_burst.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/svg_precache.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'cast21.dart';
import 'library_screens.dart' show coverOf21;
import 'widgets21.dart';

/// Playlists éditoriales d'Ondéa (21-N1d, 21-N1e) : chaque playlist a son curateur ; le joueur lui fait écouter un single.
/// Intention : convaincre une personne, pas cliquer sur un bouton. Conséquences affichées avant de proposer.
/// Règles dans playlists21.dart ; valeurs provisoires (D-08).

num _n(dynamic x) => (x ?? 0) as num;

const _ondA = Color(0xFF123A55), _ondB = Color(0xFF1E1650);

Widget _cover(String path, double size, {double r = 14}) => ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(path, fit: BoxFit.cover, placeholderBuilder: (_) => const SvgLoadingPlaceholder(), errorBuilder: (_, __, ___) => const SvgLoadingPlaceholder())),
    );

String _styles(Playlist21 p) => p.styles.isEmpty ? 'Tous styles' : p.styles.map((k) => Reg21.styles[k]?['n'] ?? k).join(' · ');

/// Grille des playlists sur la page Ondéa.
class PlaylistGrid21 extends StatelessWidget {
  final J s;
  const PlaylistGrid21(this.s, {super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final p in playlists21)
            SizedBox(
              width: w,
              child: Semantics(
                button: true,
                label: 'Playlist ${p.n}, par ${p.curatorName}',
                child: GestureDetector(
                  onTap: () => context.go('/profil/reseau/ondea/playlist?id=${p.id}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: w,
                      child: Stack(fit: StackFit.expand, children: [
                        SvgPicture.asset(p.cover, fit: BoxFit.cover, placeholderBuilder: (_) => const SvgLoadingPlaceholder(radius: 0)),
                        const DecoratedBox(
                            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xD9000000)], stops: [.3, 1]))),
                        Positioned(left: 8, top: 8, child: CastAvatar(p.curatorName, size: 36, ring: Tk.cy)),
                        if (placement21(s, p.id) != null)
                          const Positioned(right: 8, top: 8, child: GameTag('Ton titre y est', style: GameTagStyle.ok)),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.n, style: V20Text.baloo(size: 16, line: 17)),
                            Text('${fmt21(p.followers)} abonnés', style: V20Text.poppins(size: 11, line: 14, color: const Color(0xFFBFF4FF))),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
        ]);
      });
}

// ---------------------------------------------------------------------------------------------------------------------
// Page d'une playlist
// ---------------------------------------------------------------------------------------------------------------------

class PlaylistScreen extends ConsumerWidget {
  final String? id;
  const PlaylistScreen(this.id, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final p = playlist21(id) ?? playlists21.first;
    final plc = placement21(s, p.id);
    final cool = cooldown21(s, p.id);
    final mine = plc == null ? null : (s['disco'] as List).cast<Map>().where((t) => t['id'] == plc['tid']).firstOrNull;
    final songs = recentSongs21(_n(s['day']), (a) => p.artists.contains(a));
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_ondA, _ondB, Color(0xFF0E1230)])),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Ondéa', step: 'N1d', onBack: () => context.go('/profil/reseau/ondea')),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Tk.cy.withValues(alpha: .25), blurRadius: 30)]),
            child: _cover(p.cover, 128, r: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PLAYLIST ÉDITORIALE', style: V20Text.lab(color: V20.hintCyanText)),
              Text(p.n, style: V20Text.baloo(size: 26, line: 28)),
              Text('${fmt21(p.followers)} abonnés · ${_styles(p)}', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Text(p.desc, style: V20Text.bs(color: Tk.ink)),
        const SizedBox(height: 12),
        // le curateur
        GlassCard(
          child: Row(children: [
            CastAvatar(p.curatorName, size: 64, ring: Tk.cy, mood: plc != null ? 'smile' : 'poised'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.curatorName, style: V20Text.nm()),
                Text(castRole21(p.curatorName).isEmpty ? 'Curateur Ondéa' : castRole21(p.curatorName), style: V20Text.bs()),
                const SizedBox(height: 4),
                Text(p.quote, style: V20Text.poppins(size: 13, line: 18, color: Tk.ink)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        if (plc != null && mine != null)
          GlassCard(
            accent: GlassAccent.cyan,
            halo: false,
            child: Row(children: [
              _cover(coverOf21('${mine['id']}'), 52, r: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TON TITRE EST DANS LA PLAYLIST', style: V20Text.lab(color: V20.hintCyanText)),
                  Text('${mine['title']}', style: V20Text.nm()),
                  Text('Jusqu\'au jour ${plc['until']} · ≈ ${fmt21(playlistDaily21(p, mine.cast<String, dynamic>()))} écoutes par jour', style: V20Text.bs()),
                ]),
              ),
            ]),
          )
        else if (cool != null)
          GameHint(icon: 'info', warn: true, text: '${p.curatorName} a refusé ton dernier titre. Tu pourras en proposer un autre à partir du jour $cool.')
        else
          PrimaryGlowButton(
            label: 'Proposer un titre',
            sublabel: '1 h · −5 énergie · rencontre avec ${p.curatorName}',
            onPressed: () => context.go('/profil/reseau/ondea/playlist/pitch?id=${p.id}'),
          ),
        const SizedBox(height: 16),
        Text('DANS LA PLAYLIST', style: V20Text.lab()),
        const SizedBox(height: 6),
        if (plc != null && mine != null) _songRow(coverOf21('${mine['id']}'), '${mine['title']}', 'Toi', me: true),
        for (final x in songs) _songRow(_artThumb(x.a), x.t, x.a),
        const SizedBox(height: 12),
        GameHint(
            icon: 'info',
            text: 'Critères : qualité du titre, style attendu (${_styles(p)}), popularité, façon de présenter le titre et humeur du curateur. '
                'Seuil d\'entrée : ${p.threshold}. Un titre accepté reste $playlistDays21 jours et gagne des écoutes chaque jour ; un refus impose $playlistCooldown21 jours d\'attente. Valeurs provisoires.'),
      ]),
    );
  }

  Widget _songRow(String img, String t, String a, {bool me = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          _cover(img, 48, r: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 14, line: 18, weight: FontWeight.w700, color: me ? Tk.cy : Tk.ink)),
              Text(a, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
            ]),
          ),
          Icon(Icons.graphic_eq_rounded, color: Tk.cy.withValues(alpha: .8), size: 20),
        ]),
      );
}

String _artThumb(String artist) {
  for (final k in klipo21) {
    if (k['a'] == artist) return k['img'] as String;
  }
  return coverOf21(artist);
}

// ---------------------------------------------------------------------------------------------------------------------
// Rencontre avec le curateur : choix du titre, façon de le présenter, écoute, verdict
// ---------------------------------------------------------------------------------------------------------------------

class PitchScreen extends ConsumerStatefulWidget {
  final String? id;
  const PitchScreen(this.id, {super.key});
  @override
  ConsumerState<PitchScreen> createState() => _PitchState();
}

class _PitchState extends ConsumerState<PitchScreen> {
  String? _tid;
  String _ap = 'son';
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final p = playlist21(widget.id) ?? playlists21.first;
    final tracks = pitchableTracks21(s);
    final last = (s['pl'] as Map?)?['last'] as Map?;
    if (_done && last != null && last['id'] == p.id) return _result(context, s, p, last);
    final t = tracks.where((x) => x['id'] == _tid).firstOrNull ?? (tracks.isEmpty ? null : tracks.first);
    final sc = t == null ? null : pitchScore21(s, p, t, _ap);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Rencontre', step: 'N1e', onBack: () => context.go('/profil/reseau/ondea/playlist?id=${p.id}')),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, c) => SceneBanner(
          kind: 'studio',
          height: 200,
          role: 'CURATEUR ONDÉA · ${p.n.toUpperCase()}',
          name: p.curatorName,
          chars: [
            BannerChar(p.curator, mood: 'poised', crop: 'torso', width: 108, left: c.maxWidth - 122),
            const BannerChar('djo', mood: 'neutral', crop: 'torso', width: 92, left: 24),
          ],
        ),
      ),
      const SizedBox(height: 12),
      GameCard(child: Text(p.quote, style: V20Text.poppins(size: 15, line: 22))),
      const SizedBox(height: 16),
      Text('1 · QUEL TITRE LUI FAIRE ÉCOUTER ?', style: V20Text.lab()),
      const SizedBox(height: 8),
      if (tracks.isEmpty)
        const GameHint(icon: 'info', warn: true, text: 'Aucun single sorti. Sors un titre au studio avant de démarcher les playlists.')
      else
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tracks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final x = tracks[i];
              final sel = x['id'] == t?['id'];
              return Semantics(
                button: true,
                selected: sel,
                label: '${x['title']}, qualité ${x['Q']}',
                child: GestureDetector(
                  onTap: () => setState(() => _tid = '${x['id']}'),
                  child: Container(
                    width: 112,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: sel ? Tk.tint : Colors.white.withValues(alpha: .04),
                      border: Border.all(color: sel ? Tk.acc : Colors.white.withValues(alpha: .1), width: sel ? 2 : 1),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _cover(coverOf21('${x['id']}'), 98, r: 10),
                      const SizedBox(height: 4),
                      Text('${x['title']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 15, weight: FontWeight.w700)),
                      Text('Qualité ${x['Q']}', style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      const SizedBox(height: 16),
      Text('2 · COMMENT LE PRÉSENTER ?', style: V20Text.lab()),
      for (final e in pitchApproaches21.entries) ...[
        const SizedBox(height: 8),
        ChoiceCard(
          title: e.value.n,
          selected: _ap == e.key,
          onTap: () => setState(() => _ap = e.key),
          consequences: [
            Consequence(ConsequenceKind.certain, '1 h · −5 énergie${e.value.cost > 0 ? ' · −${fmt21(e.value.cost)} cauris' : ''}'),
            Consequence(ConsequenceKind.estimated, e.value.c),
          ],
        ),
      ],
      if (t != null && sc != null) ...[
        const SizedBox(height: 16),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AVANT DE LUI FAIRE ÉCOUTER', style: V20Text.lab()),
            const SizedBox(height: 6),
            Conseq21(ConsequenceKind.estimated,
                'Score sans l\'humeur du curateur : ${(sc.total - sc.jury).round()} · seuil ${p.threshold} (qualité ${sc.q.round()}, style ${sc.fit.round()}, popularité ${sc.pop.round()}, présentation ${sc.approach.round()})'),
            const Conseq21(ConsequenceKind.uncertain, 'Humeur du curateur le jour de l\'écoute : de −8 à +8'),
            Conseq21(ConsequenceKind.estimated, 'Si c\'est oui : ≈ ${fmt21(playlistDaily21(p, t))} écoutes par jour pendant $playlistDays21 jours'),
            Conseq21(ConsequenceKind.risk, 'Si c\'est non : $playlistCooldown21 jours avant de pouvoir reproposer un titre à ${p.curatorName}'),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryGlowButton(
          label: 'Faire écouter « ${t['title']} »',
          onPressed: () => doAct(context, ref, 'plpitch', [p.id, t['id'], _ap], () {
            HapticFeedback.mediumImpact();
            setState(() => _done = true);
          }),
        ),
      ],
    ]);
  }

  Widget _result(BuildContext context, J s, Playlist21 p, Map last) {
    final ok = last['ok'] == 1;
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, c) => SceneBanner(
            kind: 'studio',
            height: 210,
            role: ok ? 'C\'EST OUI' : 'PAS CETTE FOIS',
            name: p.curatorName,
            chars: [
              BannerChar(p.curator, mood: ok ? 'laugh' : 'worried', crop: 'torso', width: 108, left: c.maxWidth - 122),
              BannerChar('djo', mood: ok ? 'laugh' : 'worried', crop: 'torso', width: 92, left: 24),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GameCard(
          child: Text(
            ok
                ? '« ${last['t']}, je le prends. Il passe dans ${p.n} dès demain. Ne me fais pas regretter. »'
                : '« Pas pour ${p.n}, pas maintenant. Retravaille-le, ou reviens avec autre chose. »',
            style: V20Text.poppins(size: 15, line: 22),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          accent: ok ? GlassAccent.cyan : GlassAccent.none,
          halo: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('SCORE DE L\'ÉCOUTE', style: V20Text.lab())),
              GameTag(ok ? 'Accepté' : 'Refusé', style: ok ? GameTagStyle.ok : GameTagStyle.outline),
            ]),
            Text('${last['score']} / seuil ${last['th']}', style: V20Text.baloo(size: 28, line: 30, color: ok ? Tk.ok : Tk.ink)),
            const SizedBox(height: 6),
            if (ok) ...[
              Conseq21(ConsequenceKind.certain, '« ${last['t']} » entre dans ${p.n} pour $playlistDays21 jours · relation ${p.curatorName} +3'),
              Conseq21(ConsequenceKind.estimated, '≈ ${fmt21(_n(last['daily']))} écoutes par jour, comptées sur Ondéa et Cauri Music, et quelques fans'),
            ] else ...[
              Conseq21(ConsequenceKind.certain, 'Nouvelle proposition possible dans $playlistCooldown21 jours · relation ${p.curatorName} −1'),
              const Conseq21(ConsequenceKind.estimated, 'Pistes : un titre de meilleure qualité, ton style principal, ou une autre façon de le présenter'),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryGlowButton(label: 'Retour à la playlist', onPressed: () => context.go('/profil/reseau/ondea/playlist?id=${p.id}')),
      ]),
      if (ok) const IgnorePointer(child: Align(alignment: Alignment.topCenter, child: RewardBurst(height: 260))),
    ]);
  }
}
