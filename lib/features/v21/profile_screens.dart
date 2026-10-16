import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
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
    final p = _m(s['p']);
    final sr = singlesRank(s), gr = globalRank(s);
    final off = _m(s['rom'])['off'] as String?;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        SizedBox(width: 96, height: 120, child: PlayerAvatar(s, height: 120)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(playerName(s), style: V20Text.dm(size: 26)),
            Text('${s['age']} ans · origine ${Reg21.origins[p['origin']]} · vit à Ndolo', style: V20Text.bs()),
            Text('${Reg21.styles[p['main']]!['n']}${p['second'] != null ? ' · ${Reg21.styles[p['second']]!['n']}' : ''}', style: V20Text.bs(color: Tk.ink)),
            Text('Objectif : ${Reg21.goals[p['goal']]!['n']}', style: V20Text.bs()),
            const SizedBox(height: 4),
            GameTag(rankTag(s), style: GameTagStyle.accent),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      KpiRow(children: [StatKpi(label: 'Fans', value: fmt21(s['fans'] as num)), StatKpi(label: 'Popularité', value: '${s['pop']}')]),
      const SizedBox(height: 8),
      KpiRow(children: [StatKpi(label: 'Réputation', value: '${s['rep']}'), StatKpi(label: 'Titres sortis', value: '${(s['disco'] as List).length}')]),
      const SizedBox(height: 12),
      ActionRow(title: 'Journal et missions', subtitle: '${missionsDone(s)} / ${Reg21.missions.length} missions faites', trailing: ActionRow.arrow(), onTap: () => context.go('/journal')),
      const SizedBox(height: 8),
      ActionRow(title: 'Classements', subtitle: 'Singles · ${sr == 0 ? 'Non classé' : '#$sr'} · Global · ${gr == 0 ? 'Non classé' : '#$gr'}', trailing: ActionRow.arrow(), onTap: () => context.go('/profil/classements')),
      const SizedBox(height: 8),
      ActionRow(title: 'Rang de carrière', subtitle: 'Conditions de promotion', trailing: ActionRow.arrow(), onTap: () => context.go('/profil/rang')),
      const SizedBox(height: 8),
      ActionRow(title: 'Popularité par ville et continent', subtitle: 'Bakoma, Port-Ambre, Sélène…', trailing: ActionRow.arrow(), onTap: () => context.go('/scene/popularite')),
      const SizedBox(height: 8),
      ActionRow(title: 'Âge et énergie', subtitle: 'Vieillissement annuel', trailing: ActionRow.arrow(), onTap: () => context.go('/profil/annee')),
      const SizedBox(height: 8),
      ActionRow(title: 'Vie perso', subtitle: off == null ? '—' : cands21[off]!['n'] as String, trailing: ActionRow.arrow(), onTap: () => context.go('/perso')),
      const SizedBox(height: 8),
      ActionRow(title: 'Famille', subtitle: '${(_m(s['fam'])['kids'] as List).length} enfant(s)', trailing: ActionRow.arrow(), onTap: () => context.go('/famille')),
      const SizedBox(height: 8),
      ActionRow(title: 'Réglages et démo', subtitle: 'Nouvelle partie, raccourcis de démonstration', trailing: ActionRow.arrow(), onTap: () => context.go('/profil/reglages')),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Tenues, éditeur d’avatar 2D et boutique : écrans existants 12.x et 17-17. L’apparence reste la même sur tous les écrans.'),
    ]);
  }
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

class ClassementsScreen extends ConsumerWidget {
  const ClassementsScreen({super.key});
  static const _singles = [
    ('Minuit Doré', 'Kaïra Nox', '12,4 M'),
    ("Pluie d'Argent", 'Zaki Mbela', '11,8 M'),
    ('Tonnerre Doux', 'Madame Orage', '10,9 M'),
    ('Brume sur Ndo', 'Tito Brume', '9,7 M'),
    ('Verre Bleu', 'Lazuli', '9,1 M'),
  ];
  static const _global = [
    ('Kaïra Nox', '98,4'), ('Zaki Mbela', '95,1'), ('Madame Orage', '93,7'), ('Tito Brume', '90,2'), ('Lazuli', '88,9'),
    ('Sôlo Vance', '85,0'), ('Nadia Kolo', '83,4'), ('Bako Flux', '80,6'), ('Dr. Sable', '78,8'), ('Yaya Cendre', '76,3'),
  ];

  Widget _row(String rank, String title, String sub, String value, {bool me = false}) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: me ? const Color.fromRGBO(244, 63, 157, .16) : null, borderRadius: BorderRadius.circular(12), border: me ? Border.all(color: Tk.acc, width: 1.5) : null),
        child: Row(children: [
          SizedBox(width: 44, child: Text(rank, style: V20Text.nm(color: me ? V20.accText : Tk.gold))),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: V20Text.nm()), if (sub.isNotEmpty) Text(sub, style: V20Text.bs())])),
          Text(value, style: V20Text.nm(color: Tk.ink)),
        ]),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final best = bestSong(s);
    final bl = best == null ? 0 : _n(best['L']);
    final sr = singlesRank(s), ip = idxParts21(s), gr = globalRank(s);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Classements', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TOP 100 SINGLES', style: V20Text.lab()), const GameTag('Écoutes, 7 j')]),
          const SizedBox(height: 8),
          for (var i = 0; i < _singles.length; i++) _row('${i + 1}', _singles[i].$1, _singles[i].$2, _singles[i].$3),
          _row(sr == 0 ? '—' : '#$sr', best == null ? 'Aucun titre sorti' : best['title'] as String, 'Toi · meilleur titre', fmt21(bl), me: true),
          Text(sr == 0 ? 'Non classé · entrée au Top 100 à partir de ${fmt21(Reg21.entry)} écoutes sur 7 jours (R25, D-16 A).' : 'Classé grâce à tes vraies écoutes.', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TOP 10 GLOBAL ARTISTS', style: V20Text.lab()), const GameTag('Indice')]),
          const SizedBox(height: 8),
          for (var i = 0; i < _global.length; i++) _row('${i + 1}', _global[i].$1, '', _global[i].$2),
          _row(gr == 0 ? '—' : '#$gr', playerName(s), 'Toi', d1(ip.i), me: true),
          Text(gr == 0 ? 'Non classé · écart au #10 : ${d1(76.3 - ip.i)}' : 'Dans le Top 10 Global.', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      const GlassCard(child: Row(children: [Expanded(child: Text('Top 200 Albums\nVerrouillé : un album demande 8 titres sortis et la sortie d’album n’existe pas encore.')), GameTag('À concevoir', style: GameTagStyle.outline)])),
      const SizedBox(height: 8),
      const GlassCard(child: Row(children: [Expanded(child: Text('Top 50 EPs\nVerrouillé : la sortie d’EP (05-5) est une maquette non interactive.')), GameTag('À concevoir', style: GameTagStyle.outline)])),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Les rangs du joueur sont calculés à partir de ses vraies écoutes (loi R18) et de son indice (R10, normalisation provisoire D-17). Les autres lignes sont les valeurs existantes de 13.2 et 13.5.'),
    ]);
  }
}

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
      ]);
}
