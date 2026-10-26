import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/config/env.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_icon.dart';
import '../../core/widgets/glass_tile.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'wardrobe_screens.dart';
import 'start_screens.dart';
import 'widgets21.dart';

/// Profil (21-P1), rang de carrière (21-R1), classements (21-R2) et réglages.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;

// ---------------------------------------------------------------------------------------------------------------------
// 21-P1 Profil
// ---------------------------------------------------------------------------------------------------------------------

class ProfilScreen21 extends ConsumerWidget {
  const ProfilScreen21({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final sr = singlesRank(s), gr = globalRank(s);
    final off = _m(s['rom'])['off'] as String?;
    final claim = missionsToClaim21(s);
    final mature = _n(s['mature']) != 0;
    final owned = (_m(s['wd'])['owned'] as List).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      _ProfileHero(s),
      const SizedBox(height: 12),
      _StatStrip(s),
      const SizedBox(height: 12),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: GlassTile(
            icon: 'check',
            title: 'Missions',
            subtitle: claim > 0 ? '$claim récompense(s) à récupérer' : '${missionsClaimed21(s)} / ${missions21.length} de carrière',
            badge: claim > 0 ? '$claim' : null,
            onTap: () => context.go('/journal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassTile(
            icon: 'trophy',
            title: 'Classements',
            subtitle: 'Singles ${sr == 0 ? 'non classé' : '#$sr'} · Global ${gr == 0 ? 'non classé' : '#$gr'}',
            onTap: () => context.go('/profil/classements'),
          ),
        ),
      ])),
      _Group('Carrière', [
        _Item('user', 'Bakopédia', 'Ton article : infos, discographie, distinctions, finances', () => context.go('/profil/wiki')),
        _Item('trophy', 'Salle des trophées', '${certCount21(s)} certification(s) · ${awardWins21(s)} trophée(s) · ${awardNoms21(s)} nomination(s)', () => context.go('/profil/trophees')),
        _Item('trend', 'Rang de carrière', 'Conditions de promotion', () => context.go('/profil/rang')),
        _Item('mic', 'Catalogue des sons', 'Streams, ventes, crédits, EP et albums', () => context.go('/studio/catalogue')),
        _Item('flame', 'Popularité par ville', 'Bakoma, Port-Ambre, Sélène et l\'étranger', () => context.go('/scene/popularite')),
        _Item('bell', 'Journal', 'Fil de la carrière et missions de départ', () => context.go('/journal')),
      ]),
      _Group('Image et réseau', [
        _Item('music', 'Plateformes', 'Ondéa, Klipo, Cauri Music · mes clips · marketing', () => context.go('/profil/reseau')),
        _Item('users', 'Réseaux sociaux', 'Lueur, Bakoz, Griot · ${fmt21(followersTotal21(s))} abonnés', () => context.go('/profil/reseau/social')),
        _Item('user', 'Garde-robe', '$owned / ${Wardrobe21.outfits.length} tenues', () => context.go('/profil/garde-robe')),
        _Item('users', 'Personnages', 'Galerie des personnages du jeu', () => context.go('/profil/personnages')),
      ]),
      _Group('Vie privée', [
        _Item('moon', 'Vie perso', off == null ? 'Célibataire' : 'En couple avec ${cands21[off]!['n']}', () => context.go('/perso')),
        _Item('home', 'Famille', '${(_m(s['fam'])['kids'] as List).length} enfant(s)', () => context.go('/famille')),
        _Item('clock', 'Âge et énergie', '${s['age']} ans · vieillissement annuel', () => context.go('/profil/annee')),
      ]),
      _Group('Jeu', [
        _Item('bell', 'Scènes et dialogues', 'Conditions, choix faits, mémoire des personnages', () => context.go('/scenes')),
        _Item(
          'lock',
          'Contenu mature (16+)',
          mature ? 'Activé · activités illégales, tribunal, prison' : 'Désactivé',
          () => doAct(context, ref, 'mature', mature ? 'off' : 'on', null, mature ? 'Contenu mature désactivé' : 'Contenu mature activé'),
          trailing: GameTag(mature ? 'Activé' : 'Désactivé', style: mature ? GameTagStyle.accent : GameTagStyle.outline),
        ),
        _Item('briefcase', 'Réglages et démo', 'Nouvelle partie, raccourcis de démonstration, version', () => context.go('/profil/reglages')),
      ]),
    ]);
  }
}

/// Loge de l'artiste : décor de coulisses, avatar dans sa tenue, nom, rang et progression vers le rang suivant.
class _ProfileHero extends StatelessWidget {
  final J s;
  const _ProfileHero(this.s);
  @override
  Widget build(BuildContext context) {
    final p = _m(s['p']);
    final rk = rankOf(s);
    final xp = _n(s['xp']);
    final next = rk < Reg21.ranks.length ? Reg21.ranks[rk] : null;
    final cur = _n(Reg21.ranks[rk - 1]['xp']);
    final goal = next == null ? null : _n(next['xp']);
    final prog = goal == null ? 1.0 : ((xp - cur) / (goal - cur)).clamp(0, 1).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 236),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .12), width: 1.5),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A1B52), Tk.s1, Tk.deep]),
        ),
        child: Stack(children: [
          Positioned.fill(child: Opacity(opacity: .22, child: SvgPicture.asset('assets/scenes/backstage.svg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()))),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0x00000000), Color(0xCC14102B)], stops: [.25, .7])),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 0,
            child: Semantics(
              button: true,
              label: 'Garde-robe : changer de tenue',
              child: GestureDetector(onTap: () => context.go('/profil/garde-robe'), child: EquippedAvatar(s, width: 128, height: 220)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(136, 16, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GameTag(rankTag(s), style: GameTagStyle.accent),
              const SizedBox(height: 6),
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(playerName(s), style: V20Text.baloo(size: 30, line: 32))),
              Text('${s['age']} ans · ${Reg21.origins[p['origin']]} · vit à Ndolo', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              Text('${Reg21.styles[p['main']]!['n']}${p['second'] != null ? ' · ${Reg21.styles[p['second']]!['n']}' : ''}',
                  style: V20Text.poppins(size: 13, line: 17, weight: FontWeight.w700)),
              Text('Objectif : ${Reg21.goals[p['goal']]!['n']}', style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Text(next == null ? 'RANG MAXIMUM' : 'VERS N${rk + 1} · ${(next['n'] as String).toUpperCase()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab())),
              ]),
              const SizedBox(height: 4),
              MeterBar(value: prog, tone: MeterTone.gold),
              const SizedBox(height: 4),
              Text(goal == null ? '${fmt21(xp)} XP' : '${fmt21(xp)} / ${fmt21(goal)} XP${next!['cl'] != null ? ' · ${next['cl']}' : ''}',
                  style: V20Text.poppins(size: 11, line: 15, color: V20.ink2)),
              const SizedBox(height: 8),
              Semantics(
                button: true,
                child: GestureDetector(
                  onTap: () => context.go('/profil/garde-robe'),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white.withValues(alpha: .3))),
                    child: Text('Changer de tenue', style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Quatre chiffres de carrière dans une seule bande.
class _StatStrip extends StatelessWidget {
  final J s;
  const _StatStrip(this.s);
  @override
  Widget build(BuildContext context) {
    Widget cell(String lab, String v, Color c) => Expanded(
          child: Column(children: [
            FittedBox(fit: BoxFit.scaleDown, child: Text(v, style: V20Text.baloo(size: 22, line: 24, color: c))),
            const SizedBox(height: 2),
            Text(lab.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
          ]),
        );
    Widget sep() => Container(width: 1, height: 32, color: Colors.white.withValues(alpha: .1));
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(children: [
        cell('Fans', fmt21(_n(s['fans'])), Tk.ink),
        sep(),
        cell('Popularité', '${s['pop']}', Tk.acc4),
        sep(),
        cell('Réputation', '${s['rep']}', Tk.gold),
        sep(),
        cell('Titres', '${(s['disco'] as List).length}', Tk.cy),
      ]),
    );
  }
}

class _Item {
  final String icon, title, sub;
  final VoidCallback onTap;
  final Widget? trailing;
  const _Item(this.icon, this.title, this.sub, this.onTap, {this.trailing});
}

/// Section du profil : titre et lignes regroupées dans une même carte.
class _Group extends StatelessWidget {
  final String title;
  final List<_Item> items;
  const _Group(this.title, this.items);

  Widget _itemTile(BuildContext context, _Item item, {bool desktop = false}) {
    return Semantics(
      button: true,
      label: '${item.title}, ${item.sub}',
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: desktop ? 12 : 8),
          decoration: desktop
              ? BoxDecoration(
                  color: Tk.s1.withValues(alpha: .58),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: .08)),
                )
              : null,
          child: ExcludeSemantics(
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(gradient: V20.tileIcon, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: GameIcon(item.icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: V20Text.poppins(size: 15, line: 19, weight: FontWeight.w700)),
                    Text(item.sub, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: V20Text.poppins(size: 12, line: 16, color: V20.ink2)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              item.trailing ?? const GameIcon('arrow', size: 20, color: V20.ink2),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final desktop = MediaQuery.sizeOf(context).width >= 1000;
          final columns = (constraints.maxWidth / 360).floor().clamp(2, 3);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
              child: Text(title.toUpperCase(), style: V20Text.lab()),
            ),
            if (desktop)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: (constraints.maxWidth - (columns - 1) * 12) / columns,
                      child: _itemTile(context, item, desktop: true),
                    ),
                ],
              )
            else
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) Divider(height: 1, thickness: 1, indent: 64, color: Colors.white.withValues(alpha: .08)),
                    _itemTile(context, items[i]),
                  ],
                ]),
              ),
          ]);
        },
      );
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-R1 Rang de carrière
// ---------------------------------------------------------------------------------------------------------------------

class RangScreen extends ConsumerWidget {
  const RangScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final rk = rankOf(s);
    final next = rk < Reg21.ranks.length ? Reg21.ranks[rk] : null;
    final xpOk = next != null && _n(s['xp']) >= (next['xp'] as num);
    final condOk = next != null && condOk21(s, next);
    final sr = singlesRank(s), gr = globalRank(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Rang de carrière', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      GlassCard(
        accent: GlassAccent.magenta,
        halo: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RANG ACTUEL', style: V20Text.lab(color: V20.accText)),
          Text('N$rk · ${rankName(s)}', style: V20Text.dm(size: 26)),
          const SizedBox(height: 8),
          MeterBar(value: xpFraction(s)),
          const SizedBox(height: 4),
          Text(next == null ? '${s['xp']} XP' : '${s['xp']} / ${next['xp']} XP', style: V20Text.bs(color: Tk.ink)),
        ]),
      ),
      if (next != null) ...[
        const SizedBox(height: 12),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PROCHAIN RANG : ${(next['n'] as String).toUpperCase()}', style: V20Text.lab()),
            Text('${next['xp']} XP${next['cl'] != null ? ' · ${next['cl']}' : ''}', style: V20Text.nm()),
            KeyVal('Expérience', xpOk ? '✓ atteinte' : 'pas encore', color: xpOk ? Tk.ok : V20.hintGoldText),
            KeyVal('Conditions de carrière', condOk ? '✓ remplies' : 'pas encore', color: condOk ? Tk.ok : V20.hintGoldText),
            if (xpOk && !condOk) Text('Tu as l’expérience, mais une condition de carrière manque.', style: V20Text.bs()),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      ActionRow(title: 'Classements officiels', subtitle: 'Singles · ${sr == 0 ? 'Non classé' : '#$sr'} · Global · ${gr == 0 ? 'Non classé' : '#$gr'}', trailing: ActionRow.arrow(), onTap: () => context.go('/profil/classements')),
      const SizedBox(height: 12),
      for (var i = 0; i < Reg21.ranks.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            accent: rk == i + 1 ? GlassAccent.magenta : GlassAccent.none,
            halo: false,
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('N${i + 1} · ${Reg21.ranks[i]['n']}', style: V20Text.nm()), Text('${Reg21.ranks[i]['xp']} XP${Reg21.ranks[i]['cl'] != null ? ' · ${Reg21.ranks[i]['cl']}' : ''}', style: V20Text.bs())])),
              rk > i + 1 ? const GameTag('✓', style: GameTagStyle.ok) : (rk == i + 1 ? const GameTag('Actuel', style: GameTagStyle.accent) : const GameTag('À venir')),
            ]),
          ),
        ),
      const SizedBox(height: 4),
      const GameHint(icon: 'info', text: 'Seuils d’XP relevés le 16/10 (N3 à 1 500 XP, valeurs provisoires) pour qu’un débutant n’atteigne pas les concerts en deux jours. Le rang ouvre concerts (N3), entreprises, réalisateurs et merch.'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-R2 Classements
// ---------------------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------------------
// Réglages et démo
// ---------------------------------------------------------------------------------------------------------------------

class ReglagesScreen extends ConsumerWidget {
  const ReglagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Réglages', onBack: () => context.go('/profil')),
        const SizedBox(height: 12),
        const GameHint(icon: 'info', text: 'Toutes les valeurs chiffrées de la zone v21 sont provisoires et regroupées dans lib/domain/v21/reg21.dart. Aucune n’est validée, sauf mention contraire.'),
        const SizedBox(height: 12),
        ActionRow(title: 'Lancer la démo', subtitle: 'Charger un état complet : carrière, couple, famille', trailing: ActionRow.arrow(), onTap: () => context.go('/demo')),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Nouvelle partie',
          style: GameButtonStyle.secondary,
          onPressed: () async {
            final ok = await confirmSheet(context, title: 'Nouvelle partie ?', body: 'La partie actuelle est effacée de cet appareil. Cette action ne peut pas être annulée.', action: 'Effacer et recommencer');
            if (!ok || !context.mounted) return;
            await ref.read(game21Provider.notifier).newGame();
            if (context.mounted) context.go('/univers');
          },
        ),
        const SizedBox(height: 16),
        Text('Version du ${Env.buildTime} (UTC) · 63 tenues · Réseau v21', textAlign: TextAlign.center, style: V20Text.bs()),
      ]);
}
