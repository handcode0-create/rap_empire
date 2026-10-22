import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/cascade.dart';
import '../../core/widgets/hero_stat.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/reward_burst.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart' show J;
import '../../domain/v21/view21.dart';
import 'wardrobe_screens.dart' show PlayerBust21, PlayerFace21;
import 'widgets21.dart';

/// Réseaux sociaux fictifs v21 : Lueur (photos), Bakoz (vidéos courtes), Griot (messages) [VALIDÉ par Smith le 20/10/2026].
/// Intention de jeu : choisir quoi publier aujourd'hui (trois publications par jour) en voyant le coût, la portée estimée
/// et le risque, puis voir la réaction du public. Valeurs provisoires (D-08). Aucun réseau réel.

num _n(dynamic x) => (x ?? 0) as num;

String handle21(J s) => '@${playerName(s).toLowerCase().replaceAll(RegExp(r'\s+'), '.')}';

/// Ambiance de chaque appli (palette du jeu, seule l'ambiance change).
const _amb = <String, List<Color>>{
  'lueur': [Color(0xFF3A2A0C), Color(0xFF1C1424), Tk.bg],
  'bakoz': [Color(0xFF3C0A2C), Color(0xFF0C0712), Color(0xFF0C0712)],
  'griot': [Color(0xFF0B2F3F), Color(0xFF111A3A), Tk.bg],
};
const _icons = <String, IconData>{'lueur': Icons.photo_camera_rounded, 'bakoz': Icons.play_circle_fill_rounded, 'griot': Icons.forum_rounded};

class _NetBadge extends StatelessWidget {
  final String net;
  final double size;
  const _NetBadge(this.net, [this.size = 44]);
  @override
  Widget build(BuildContext context) {
    final c = Color(socialNets21[net]!.col);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .3),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c, Color.lerp(c, Tk.violet, .55)!])),
      child: Icon(_icons[net], color: Tk.bg, size: size * .55, semanticLabel: socialNets21[net]!.n),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Réseaux sociaux : vue d'ensemble
// ---------------------------------------------------------------------------------------------------------------------

class SocialHubScreen extends ConsumerWidget {
  const SocialHubScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final buzz = buzz21(s), left = postsLeft21(s);
    final soc = (s['soc'] as Map?) ?? const {};
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Réseaux sociaux', step: 'N9', onBack: () => context.go('/profil/reseau')),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('BUZZ DU MOMENT', style: V20Text.lab())),
            GameTag('$left publication(s) aujourd\'hui', style: left > 0 ? GameTagStyle.ok : GameTagStyle.outline),
          ]),
          const SizedBox(height: 4),
          Text('$buzz / 100', style: V20Text.baloo(size: 34, line: 34)),
          const SizedBox(height: 6),
          MeterBar(value: buzz / 100, tone: MeterTone.brand),
          const SizedBox(height: 8),
          Text('${fmt21(followersTotal21(s))} abonnés · ${_n(soc['tot'])} publication(s) · ${_n(soc['viral'])} virale(s) · ${_n(soc['polem'])} polémique(s)', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      for (final id in socialOrder21) ...[
        _NetCard(s, id),
        const SizedBox(height: 12),
      ],
      Text('TENDANCES À BAKOMA', style: V20Text.lab()),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final t in socialTrends21) GameTag(t, style: GameTagStyle.outline)]),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          text: 'Trois réseaux fictifs. Trois publications par jour au total. Le buzz retombe chaque nuit ; les abonnés suivent ta popularité. Valeurs provisoires.'),
    ]);
  }
}

class _NetCard extends StatelessWidget {
  final J s;
  final String id;
  const _NetCard(this.s, this.id);
  @override
  Widget build(BuildContext context) {
    final net = socialNets21[id]!;
    final posts = postsOf21(s, id);
    final c = Color(net.col);
    return Semantics(
      button: true,
      label: '${net.n}, ${followers21(s, id)} abonnés',
      child: GestureDetector(
        onTap: () => context.go('/profil/reseau/social/$id'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _amb[id]!),
            border: Border.all(color: c.withValues(alpha: .45), width: 1.5),
          ),
          child: Row(children: [
            _NetBadge(id, 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(net.n, style: V20Text.baloo(size: 22, line: 24)),
                Text(net.kind.toUpperCase(), style: V20Text.lab(color: c)),
                const SizedBox(height: 4),
                Text(posts.isEmpty ? net.tagline : '« ${posts.first['txt']} »', maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: Tk.ink)),
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(fmt21(followers21(s, id)), style: V20Text.baloo(size: 20, line: 22)),
              Text('abonnés', style: V20Text.poppins(size: 11, line: 14, color: V20.ink2)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// Une appli : profil, publier, fil
// ---------------------------------------------------------------------------------------------------------------------

class SocialNetScreen extends ConsumerWidget {
  final String net;
  const SocialNetScreen({super.key, required this.net});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final info = socialNets21[net];
    if (info == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Réseau inconnu', onBack: () => context.go('/profil/reseau/social')),
      ]);
    }
    final c = Color(info.col);
    final posts = postsOf21(s, net);
    final types = postTypes21.values.where((t) => t.net == net).toList();
    final left = postsLeft21(s);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _amb[net]!)),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: info.n, onBack: () => context.go('/profil/reseau/social')),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c, width: 3)),
            child: PlayerFace21(s, size: 66),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(playerName(s), style: V20Text.baloo(size: 22, line: 24)),
              Text('${handle21(s)} · ${info.kind}', style: V20Text.poppins(size: 12, line: 16, color: c)),
              const SizedBox(height: 4),
              Text('${fmt21(followers21(s, net))} abonnés · ${posts.length} publication(s)', style: V20Text.bs(color: Tk.ink)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('PUBLIER', style: V20Text.lab())),
          GameTag('$left / $postsPerDay21 aujourd\'hui', style: left > 0 ? GameTagStyle.ok : GameTagStyle.outline),
        ]),
        const SizedBox(height: 8),
        for (final t in types) ...[_Composer(s, t, left), const SizedBox(height: 10)],
        const SizedBox(height: 6),
        Text('TON FIL', style: V20Text.lab()),
        const SizedBox(height: 8),
        if (posts.isEmpty) GameCard(child: Text('Rien publié sur ${info.n} pour l\'instant. ${info.tagline}', style: V20Text.bs(color: Tk.ink))),
        if (net == 'lueur' && posts.isNotEmpty)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .78,
            children: [for (var i = 0; i < posts.length; i++) _PhotoPost(s, posts[i], i)],
          )
        else if (net == 'bakoz')
          for (var i = 0; i < posts.length; i++) ...[_VideoPost(s, posts[i], i), const SizedBox(height: 10)]
        else
          for (final p in posts) ...[_ThreadPost(s, p), const SizedBox(height: 10)],
        const SizedBox(height: 4),
        GameHint(icon: 'info', text: '${info.n} est un réseau fictif de l\'univers de Bakoma. Portée, abonnés et commentaires sont estimés ; valeurs provisoires.'),
      ]),
    );
  }
}

class _Composer extends ConsumerWidget {
  final J s;
  final PostType21 t;
  final int left;
  const _Composer(this.s, this.t, this.left);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final need = postNeed21(s, t);
    final reach = reachEstimate21(s, t);
    final off = need != null || left <= 0;
    final c = Color(socialNets21[t.net]!.col);
    final cost = '${t.h == 0 ? 'moins d\'1 h' : '${t.h} h'} · −${t.e} énergie';
    return Opacity(
      opacity: off ? .7 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Tk.s1.withValues(alpha: .85), borderRadius: BorderRadius.circular(18), border: Border.all(color: off ? Tk.line : c.withValues(alpha: .6), width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(t.n, style: V20Text.nm())),
            if (need != null) GameTag(switch (need) { 'single' => 'Un titre sorti', 'pasdetitre' => 'Un titre en cours', _ => 'Une date jouée' }, style: GameTagStyle.outline),
          ]),
          Text(t.d, style: V20Text.bs()),
          const SizedBox(height: 6),
          Conseq21(ConsequenceKind.certain, cost),
          Conseq21(ConsequenceKind.uncertain, 'Entre ${fmt21(jsRound(reach * .6))} et ${fmt21(jsRound(reach * 1.4))} vues · environ +${fmt21(jsRound(reach * .04))} abonnés · +${fmt21(jsRound(reach * t.fanRate))} fans (varie à chaque publication)'),
          if (t.hype > 0) Conseq21(ConsequenceKind.certain, 'Annonce : +20 % d\'écoutes si tu sors le titre dans les ${t.hype} jours'),
          if (t.viral) const Conseq21(ConsequenceKind.uncertain, 'Peut devenir virale (portée × 4)'),
          Conseq21(ConsequenceKind.risk, t.clash ? 'Risque ${t.risk} : polémique possible (réputation −2)' : 'Risque ${t.risk}'),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Publier sur ${socialNets21[t.net]!.n}',
            compact: true,
            style: off ? GameButtonStyle.disabled : GameButtonStyle.primary,
            onPressed: off ? null : () => _publish(context, ref, t),
          ),
        ]),
      ),
    );
  }
}

Future<void> _publish(BuildContext context, WidgetRef ref, PostType21 t) async {
  final e = await ref.read(game21Provider.notifier).act('post', t.id);
  if (!context.mounted) return;
  if (e != null) {
    toastErr(context, e);
    return;
  }
  final s = ref.read(game21Provider).valueOrNull;
  final p = s == null ? null : postsOf21(s, t.net).firstOrNull;
  if (s == null || p == null) return;
  HapticFeedback.lightImpact();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PostResult(s, p, t),
  );
}

/// Résultat d'une publication, en trois temps : réaction de Djo et chiffre héroïque, détails en cascade, commentaires.
class _PostResult extends StatelessWidget {
  final J s, p;
  final PostType21 t;
  const _PostResult(this.s, this.p, this.t);
  @override
  Widget build(BuildContext context) {
    final viral = _n(p['viral']) == 1, polem = _n(p['polem']) == 1;
    final net = socialNets21[t.net]!;
    final mood = viral ? 'laugh' : polem ? 'worried' : 'smile';
    return BottomSheetGame(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Stack(clipBehavior: Clip.none, children: [
          if (viral) const Positioned.fill(child: IgnorePointer(child: RewardBurst(height: 200))),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _NetBadge(t.net, 30),
                  const SizedBox(width: 8),
                  Text('${net.n.toUpperCase()} · ${t.n.toUpperCase()}', style: V20Text.lab(color: Color(net.col))),
                ]),
                const SizedBox(height: 8),
                if (viral) const GameTag('Virale', style: GameTagStyle.accent),
                if (polem) const GameTag('Polémique', style: GameTagStyle.accent),
                HeroStat(label: 'Vues', value: _n(p['reach']).toInt(), size: 44, color: viral ? Tk.gold : Tk.ink),
                Text(viral ? 'Tout Bakoma partage ta vidéo.' : polem ? 'La ville s\'enflamme : réputation −2.' : 'Ta publication tourne dans le quartier.',
                    style: V20Text.bs(color: Tk.ink)),
              ]),
            ),
            SizedBox(width: 110, height: 140, child: PlayerBust21(s, mood: mood)),
          ]),
        ]),
        const SizedBox(height: 12),
        Cascade(children: [
          Row(children: [
            Expanded(child: _Fig('J\'aime', fmt21(_n(p['likes'])))),
            const SizedBox(width: 8),
            Expanded(child: _Fig('Commentaires', fmt21(_n(p['cm'])))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Fig('Abonnés', '+${fmt21(_n(p['nf']))}')),
            const SizedBox(width: 8),
            Expanded(child: _Fig('Fans', '+${fmt21(_n(p['fg']))}')),
          ]),
          const SizedBox(height: 10),
          for (final (u, c) in _comments(p))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.chat_bubble_rounded, color: V20.ink2, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: '$u  ', style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700, color: Tk.cy)),
                    TextSpan(text: c, style: V20Text.poppins(size: 12, line: 16)),
                  ])),
                ),
              ]),
            ),
        ]),
        const SizedBox(height: 12),
        PrimaryGlowButton(label: 'Continuer', onPressed: () => Navigator.of(context).pop()),
      ]),
    );
  }
}

class _Fig extends StatelessWidget {
  final String k, v;
  const _Fig(this.k, this.v);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .08))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k.toUpperCase(), style: V20Text.lab()),
          Text(v, style: V20Text.baloo(size: 20, line: 22)),
        ]),
      );
}

class _Stats extends StatelessWidget {
  final J p;
  const _Stats(this.p);
  @override
  Widget build(BuildContext context) => Row(children: [
        const Icon(Icons.favorite_rounded, color: Tk.acc4, size: 16),
        const SizedBox(width: 4),
        Text(fmtK21(_n(p['likes'])), style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700)),
        const SizedBox(width: 12),
        const Icon(Icons.chat_bubble_rounded, color: V20.ink2, size: 15),
        const SizedBox(width: 4),
        Text(fmtK21(_n(p['cm'])), style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700)),
        const SizedBox(width: 12),
        const Icon(Icons.visibility_rounded, color: V20.ink2, size: 15),
        const SizedBox(width: 4),
        Text(fmtK21(_n(p['reach'])), style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700)),
      ]);
}

List<(String, String)> _comments(J p) {
  final c = (p['c'] as List?) ?? const [], u = (p['u'] as List?) ?? const [];
  return [
    for (var i = 0; i < c.length && i < u.length; i++) ('@${socialHandles21[_n(u[i]).toInt() % socialHandles21.length]}', socialComments21[_n(c[i]).toInt() % socialComments21.length])
  ];
}

/// Décor d'une publication : dégradé de scène (huit ambiances) derrière le joueur, qui porte toujours sa tenue du moment.
const _sceneGrads = <List<Color>>[
  [Color(0xFF2A1060), Color(0xFF0B0620)],
  [Color(0xFF5A1D5C), Color(0xFF1A0B2E)],
  [Color(0xFF7A1F5A), Color(0xFF14102B)],
  [Color(0xFF3A1B52), Color(0xFF0C0820)],
  [Color(0xFF8A4A12), Color(0xFF1A0B0B)],
  [Color(0xFF0E6B6B), Color(0xFF0C0820)],
  [Color(0xFF8A1030), Color(0xFF14102B)],
  [Color(0xFF6B5A12), Color(0xFF14102B)],
];

class _PostScene extends StatelessWidget {
  final J s;
  final int i;
  const _PostScene(this.s, this.i);
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _sceneGrads[i % _sceneGrads.length]))),
        Padding(padding: const EdgeInsets.only(left: 24, right: 24, top: 6), child: PlayerBust21(s)),
      ]);
}

class _PhotoPost extends StatelessWidget {
  final J s, p;
  final int i;
  const _PhotoPost(this.s, this.p, this.i);
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Tk.s1,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(aspectRatio: 1, child: _PostScene(s, i)),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${p['txt']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 11, line: 14)),
                const SizedBox(height: 4),
                _Stats(p),
              ]),
            ),
          ]),
        ),
      );
}

class _VideoPost extends StatelessWidget {
  final J s, p;
  final int i;
  const _VideoPost(this.s, this.p, this.i);
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 300,
          child: Stack(fit: StackFit.expand, children: [
            _PostScene(s, i + 4),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xD9000000)], stops: [.35, 1]))),
            const Center(child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 54)),
            if (_n(p['viral']) == 1) const Positioned(left: 12, top: 12, child: GameTag('Virale', style: GameTagStyle.accent)),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${p['txt']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 13, line: 17, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                _Stats(p),
                for (final (u, c) in _comments(p).take(1)) Text('$u  $c', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 11, line: 15, color: V20.ink2)),
              ]),
            ),
          ]),
        ),
      );
}

class _ThreadPost extends StatelessWidget {
  final J s, p;
  const _ThreadPost(this.s, this.p);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Tk.s1.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _n(p['polem']) == 1 ? Tk.acc : Tk.line, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(playerName(s), style: V20Text.nm()),
            const SizedBox(width: 6),
            Expanded(child: Text('${handle21(s)} · ${dateLabel21(p['day'] as num)}', overflow: TextOverflow.ellipsis, style: V20Text.poppins(size: 12, line: 16, color: V20.ink2))),
            if (_n(p['polem']) == 1) const GameTag('Polémique', style: GameTagStyle.accent),
          ]),
          const SizedBox(height: 6),
          Text('${p['txt']}', style: V20Text.poppins(size: 15, line: 21)),
          const SizedBox(height: 8),
          _Stats(p),
          const SizedBox(height: 6),
          for (final (u, c) in _comments(p))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text.rich(TextSpan(children: [
                TextSpan(text: '$u  ', style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700, color: Tk.cy)),
                TextSpan(text: c, style: V20Text.poppins(size: 12, line: 16, color: Tk.ink)),
              ])),
            ),
        ]),
      );
}

/// Entrée depuis l'espace Réseau.
class SocialEntryCard extends ConsumerWidget {
  const SocialEntryCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    return GameCard(
      onTap: () => context.go('/profil/reseau/social'),
      child: Row(children: [
        for (final id in socialOrder21) ...[_NetBadge(id, 34), const SizedBox(width: 6)],
        const SizedBox(width: 6),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Réseaux sociaux', style: V20Text.nm()),
            Text('${fmt21(followersTotal21(s))} abonnés · buzz ${buzz21(s)} · ${postsLeft21(s)} publication(s) aujourd\'hui', style: V20Text.bs()),
          ]),
        ),
        const Icon(Icons.arrow_forward_rounded, color: Tk.ink),
      ]),
    );
  }
}

