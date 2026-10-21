import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_tile.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'shell21.dart';
import 'wardrobe_screens.dart';
import 'awards_screens.dart' show AwardNewsCard21;
import 'cast21.dart';
import 'widgets21.dart';

/// QG du jour (21-Q1), journée (21-Q2), bilan (21-Q3), année (21-Q4), journal (21-J1) et événements (21-V1).

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;
List _l(dynamic x) => x as List;

// ---------------------------------------------------------------------------------------------------------------------
// 21-Q1 QG
// ---------------------------------------------------------------------------------------------------------------------

class QgScreen extends ConsumerWidget {
  const QgScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final ev = s['ev'] as String?;
    final fam = _m(s['fam']);
    final rom = _m(s['rom']);
    final r = partner(s);
    final today = todayLog(s);
    final d0 = (s['d0'] ?? dayStart21(s)) as J;
    final mission = nextMission(s);
    final left = Reg21.romPerDay - _n(rom['used']).toInt();
    final nextRank = rankOf(s) < Reg21.ranks.length ? Reg21.ranks[rankOf(s)]['n'] as String : 'Rang maximal';
    final cas = s['cas'] as J?;
    final dl = s['dlg'] == null ? null : _m(s['dlg']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      _Hero(s),
      if (s['jail'] != null) ...[
        const SizedBox(height: 12),
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          onTap: () => context.go('/business/justice'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('En prison · encore ${jailDaysLeft(s)} jour(s)', style: V20Text.nm()),
            Text('Seules l’écriture, le sport et la fin de journée sont possibles.', style: V20Text.bs()),
          ]),
        ),
      ],
      if (cas != null) ...[
        const SizedBox(height: 12),
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          onTap: () => context.go('/business/justice'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Affaire en cours : ${cas['n']}', style: V20Text.nm()),
            Text('Procès le jour ${cas['trial']}', style: V20Text.bs()),
          ]),
        ),
      ],
      if (dl != null) ...[
        const SizedBox(height: 12),
        GlassCard(
          accent: GlassAccent.cyan,
          halo: false,
          onTap: () => context.go('/dialogue'),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dialogue', style: V20Text.nm()), Text('Scène · ${dlg21[dl['id']]!.t}', style: V20Text.bs())])),
            GameTag(_n(dl['done']) != 0 ? 'À clore' : 'À décider', style: GameTagStyle.accent),
          ]),
        ),
      ],
      if (ev != null) ...[
        const SizedBox(height: 12),
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          onTap: () => context.go('/evenement'),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(evt21[ev]!['t'] as String, style: V20Text.nm()), Text('À décider · ${evt21[ev]!['who']}', style: V20Text.bs())])),
            const GameTag('Événement', style: GameTagStyle.accent),
          ]),
        ),
      ],
      if (fam['ev'] != null) ...[
        const SizedBox(height: 12),
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          onTap: () => context.go('/famille/evenement'),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Événement familial', style: V20Text.nm()), Text(fev21[fam['ev']]!['t'] as String, style: V20Text.bs())])),
            const GameTag('À décider', style: GameTagStyle.accent),
          ]),
        ),
      ],
      if (r != null && _n(r['g']) < Reg21.warnAt) ...[
        const SizedBox(height: 12),
        GameHint(icon: 'info', warn: true, text: 'La relation avec ${cands21[rom['off']]!['n']} se dégrade (${r['g']}/100). Sous ${Reg21.leaveAt}, la rupture devient possible.', onTap: () => context.go('/perso/couple')),
      ],
      if (canPropose21(s)) ...[
        const SizedBox(height: 12),
        GlassCard(
          accent: GlassAccent.magenta,
          halo: false,
          onTap: () => context.go('/perso/demande'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MOMENT IMPORTANT', style: V20Text.lab(color: V20.accText)),
            Text('${cands21[rom['off']]!['n']} veut te parler de mariage.', style: V20Text.nm()),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      if (mission != null)
        GlassCard(
          onTap: () => context.go('/journal'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('MISSION ${missionsDone(s)}/${Reg21.missions.length} FAITES', style: V20Text.lab()),
              const GameTag('Existant · 10.1', style: GameTagStyle.normal),
            ]),
            const SizedBox(height: 6),
            Text(mission['t'] as String, style: V20Text.nm()),
            Text('+${fmt21(mission['cash'] as num)} cauris · +${mission['xp']} XP', style: V20Text.bs()),
          ]),
        )
      else
        CareerMissionCard21(s),
      AwardNewsCard21(s),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("AUJOURD'HUI", style: V20Text.lab()), Text('${today.length} action(s)', style: V20Text.bs(color: Tk.ink))]),
          const SizedBox(height: 6),
          if (today.isEmpty) Text('Rien encore. Choisis tes activités : studio, scène, boulots, vie perso.', style: V20Text.bs()),
          for (final l in today.take(3)) Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(l['t'] as String, style: V20Text.bs(color: Tk.ink))),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            GameTag('Cash ${sg21(_n(s['cash']) - _n(d0['cash']))}'),
            GameTag('Fans ${sg21(_n(s['fans']) - _n(d0['fans']))}'),
            GameTag('Pop. ${sg21(_n(s['pop']) - _n(d0['pop']))}'),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GlassTile(icon: 'mic', title: 'Studio', subtitle: 'Créer · sortir · clip', onTap: () => context.go('/studio'))),
        const SizedBox(width: 12),
        Expanded(child: GlassTile(icon: 'flame', title: 'Scène', subtitle: 'Open mic · tournée', onTap: () => context.go('/scene'))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GlassTile(icon: 'briefcase', title: 'Petits boulots', subtitle: 'Gagner des cauris', onTap: () => context.go('/business'))),
        const SizedBox(width: 12),
        Expanded(child: GlassTile(icon: 'users', title: 'Vie perso', subtitle: '$left action(s) romantique(s)', onTap: () => context.go('/perso'))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GlassTile(icon: 'trophy', title: 'Rang', subtitle: 'N${rankOf(s)} · prochain : $nextRank', onTap: () => context.go('/profil/rang'))),
        const SizedBox(width: 12),
        Expanded(child: GlassTile(icon: 'clock', title: 'Toutes les activités', subtitle: 'Coûts et effets', onTap: () => context.go('/journee'))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GlassTile(icon: 'trend', title: 'Réseau', subtitle: 'Plateformes, clips, réseaux', onTap: () => context.go('/profil/reseau'))),
        const SizedBox(width: 12),
        Expanded(child: GlassTile(icon: 'flame', title: 'Marketing', subtitle: 'Local · National · Global', onTap: () => context.go('/profil/reseau/marketing'))),
      ]),
      const SizedBox(height: 16),
      PrimaryGlowButton(
        label: 'Terminer la journée',
        sublabel: 'Nuit · bilan · jour suivant',
        onPressed: () => doAct(context, ref, 'endDay', null, () => context.go('/bilan')),
      ),
    ]);
  }
}

class _Hero extends StatelessWidget {
  final J s;
  const _Hero(this.s);

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        SceneBanner(
          kind: 'studio',
          height: 150,
          role: 'Ndolo · année ${yearOf(s)} · ${s['age']} ans',
          name: 'Jour ${dayInYear(s)}',
          nameSize: 30,
          subtitle: "${hoursLeft(s)} h restantes aujourd'hui",
        ),
        Positioned(right: 8, top: -40, child: IgnorePointer(child: EquippedAvatar(s, width: 100, height: 150, mood: isTired(s) ? 'worried' : 'smile'))),
      ]);
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Q2 Activités de la journée
// ---------------------------------------------------------------------------------------------------------------------

class JourneeScreen extends ConsumerWidget {
  const JourneeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final moto = _m(s['own'])['moto'] != null ? 5 : 0;
    final hs = _m(s['own'])['homestudio'] != null;
    final left = Reg21.romPerDay - _n(_m(s['rom'])['used']).toInt();
    Widget row(String title, String sub, String route, {String? tag}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionRow(title: title, subtitle: sub, trailing: tag != null ? GameTag(tag) : ActionRow.arrow(), onTap: () => context.go(route)),
        );
    return Frame21(children: [
      BackHeader(title: 'Activités de la journée', onBack: () => context.go('/')),
      const SizedBox(height: 12),
      GameHint(icon: 'info', text: "Il te reste ${hoursLeft(s)} h aujourd'hui. Chaque activité coûte des heures et de l'énergie. La journée ne se termine que lorsque tu le décides."),
      const SizedBox(height: 12),
      const Lab21('Musique'),
      row('Écrire un texte', '1 h · −20 énergie', '/studio'),
      row('Enregistrer', '2 h · −${hs ? 15 : 25} énergie${hs ? '' : ' (−15 avec home studio)'}', '/studio'),
      row('Tourner un clip', '6 h · −${Reg21.shootE - moto} énergie', '/studio/clip'),
      const Lab21('Formation'),
      row("Atelier d'écriture", '2 h · −20 énergie · −6 000 cauris · Écriture +5 · mission 3', '/business'),
      const Lab21('Scène'),
      row('Open mic de Ndolo', '1 h · −${15 - moto} énergie · +150 fans si énergie ≥ 40', '/scene'),
      row('Concert au Parvis', '4 h · −${35 - moto} énergie · rang N3', '/scene'),
      row('Tournée régionale', '10 h · −${50 - moto} énergie · −30 000 cauris de frais · N3', '/scene'),
      const Lab21('Argent'),
      for (final e in Reg21.jobs.entries) row(e.value['n'] as String, '${e.value['h']} h · −${(e.value['e'] as num) - moto} énergie · +${fmt21(e.value['cash'] as num)} cauris${jobLock21(s, e.key) != null ? ' · verrouillé : ${e.value['need']}' : ''}', '/business'),
      Lab21('Vie perso · $left/${Reg21.romPerDay} restantes'),
      for (final e in Reg21.romActs.entries)
        row(e.value['n'] as String, '${e.value['h']} h${(e.value['e'] as num) != 0 ? ' · −${e.value['e']} énergie' : ''}${(e.value['c'] as num) != 0 ? ' · −${fmt21(e.value['c'] as num)} cauris' : ''}', '/perso'),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Q3 Bilan de la journée
// ---------------------------------------------------------------------------------------------------------------------

class BilanScreen extends ConsumerWidget {
  const BilanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final b = s['bil'] as J?;
    if (b == null) {
      return Frame21(children: [
        BackHeader(title: 'Bilan de la journée', onBack: () => context.go('/')),
        const SizedBox(height: 16),
        Text('Aucun bilan pour l’instant', style: V20Text.nm()),
        Text('Le bilan s’affiche après « Terminer la journée ».', style: V20Text.bm),
      ]);
    }
    final rank0 = _n(b['rank0']), rank = _n(b['rank']);
    final rel = b['rel'] as num?, rel0 = b['rel0'] as num?;
    final evs = [..._l(b['ev']), ..._l(b['acts'])].cast<String>();
    final kids = _n(b['kids']).toInt();
    // Le bilan reste visible en prison : « Commencer la journée » ramène ensuite à la cellule.
    return Frame21(allowInJail: true, children: [
      BackHeader(title: 'Bilan de la journée', onBack: () => context.go('/')),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: V20.objective, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FIN DU JOUR ${b['day']}', style: V20Text.lab(color: Colors.white)),
          Text('BILAN', style: V20Text.dm(size: 28)),
          Text('Énergie au réveil : ${b['en']} / ${b['enMax']}', style: V20Text.bm),
        ]),
      ),
      const SizedBox(height: 12),
      KpiRow(children: [StatKpi(label: 'Argent', value: sg21(_n(b['cash']))), StatKpi(label: 'Popularité', value: sg21(_n(b['pop'])))]),
      const SizedBox(height: 8),
      KpiRow(children: [StatKpi(label: 'Fans', value: sg21(_n(b['fans']))), StatKpi(label: 'Expérience', value: sg21(_n(b['xp'])))]),
      if (b['aged'] != null) ...[
        const SizedBox(height: 12),
        GameHint(icon: 'info', text: 'Tu as ${_m(b['aged'])['age']} ans : énergie max ${_m(b['aged'])['em0']} → ${_m(b['aged'])['em1']}.'),
      ],
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CE QUI A CHANGÉ', style: V20Text.lab()),
          KeyVal('Carrière', rank > rank0 ? 'Promotion : N${rank0.toInt()} → N${rank.toInt()}' : 'N${rank.toInt()} · inchangé'),
          KeyVal('Relation', rel == null ? (rel0 != null ? 'Séparation : relation terminée' : 'Aucune relation officielle') : '${b['who']} : $rel/100 (${sg21(rel - (rel0 ?? rel))})'),
          KeyVal('Famille', kids == 0 ? 'Aucun enfant' : '$kids enfant${kids > 1 ? 's' : ''}${kids > _n(b['kids0']) ? ' · naissance' : ''}'),
        ]),
      ),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ÉVÉNEMENTS ET RÉSULTATS', style: V20Text.lab()),
          const SizedBox(height: 4),
          if (evs.isEmpty) Text('Journée sans événement.', style: V20Text.bs()),
          for (final e in evs.take(7)) Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(e, style: V20Text.bs(color: Tk.ink))),
        ]),
      ),
      const SizedBox(height: 12),
      ActionRow(title: 'Bilan familial', subtitle: 'Relation, enfants, événements du foyer', trailing: ActionRow.arrow(), onTap: () => context.go('/famille/bilan')),
      const SizedBox(height: 16),
      PrimaryGlowButton(label: 'Commencer la journée', sublabel: 'Retour au QG', onPressed: () => context.go('/')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Q4 Âge, énergie et nouvelle année
// ---------------------------------------------------------------------------------------------------------------------

class AnneeScreen extends ConsumerWidget {
  const AnneeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final age = _n(s['age']).toInt();
    final own = _m(s['own']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Âge et énergie', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      KpiRow(children: [StatKpi(label: 'Âge', value: '$age', big: true), StatKpi(label: 'Énergie max', value: '${enMax(s)}', big: true), StatKpi(label: 'Année', value: '${yearOf(s)}', big: true)]),
      const SizedBox(height: 8),
      Text('${Reg21.daysPerYear - dayInYear(s) + 1} j avant l’anniversaire. Une année = 52 semaines (${Reg21.daysPerYear} jours). Le vieillissement s’applique au passage de chaque nouvelle année.', style: V20Text.bs()),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ÉNERGIE MAX SELON L’ÂGE', style: V20Text.lab()), const GameTag('Proposé', style: GameTagStyle.outline, color: Color(0xFFD8C8FF))]),
          for (final (a, v) in Reg21.enMaxByAge) KeyVal(a == 0 ? 'Jusqu’à 29 ans' : '$a ans et plus', '$v'),
          const SizedBox(height: 4),
          Text('Cette année : ${enMaxAge(age)} · l’an prochain : ${enMaxAge(age + 1)}', style: V20Text.bs(color: Tk.ink)),
        ]),
      ),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('COMPENSATION PAR LE PATRIMOINE', style: V20Text.lab()),
          KeyVal('Appartement à Lumbé', own['appart'] != null ? '+5 énergie max' : '+0 énergie max'),
          const KeyVal('Moto', '−5 énergie par activité hors domicile', bold: false),
          const KeyVal('Home studio', '−10 énergie à l’enregistrement', bold: false),
        ]),
      ),
      const SizedBox(height: 16),
      PrimaryButton(
        label: "Passer à l'année suivante",
        sublabel: 'Raccourci de démo : simule 364 jours',
        style: GameButtonStyle.secondary,
        onPressed: () => doAct(context, ref, 'skipYear', null, () => context.go('/bilan')),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-J1 Journal et missions
// ---------------------------------------------------------------------------------------------------------------------

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});
  static const _cats = {'musique': 'Studio', 'scene': 'Scène', 'eco': 'Argent', 'perso': 'Vie perso', 'carriere': 'Carrière', 'mission': 'Mission', 'evenement': 'Événement', 'jeu': 'Jeu'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final ms = _m(s['ms']);
    final log = _l(s['log']);
    return Frame21(children: [
      BackHeader(title: 'Journal', onBack: () => context.go('/')),
      const SizedBox(height: 4),
      Align(alignment: Alignment.centerRight, child: GameTag('${missionsDone(s)} / ${Reg21.missions.length} missions')),
      const SizedBox(height: 8),
      CareerMissions21(s),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('MISSIONS DE DÉPART', style: V20Text.lab()), const GameTag('Existant · 10.1')]),
          for (final m in Reg21.missions) ...[
            const SizedBox(height: 8),
            GameCard(
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m['t'] as String, style: V20Text.nm()), Text('+${fmt21(m['cash'] as num)} cauris · +${m['xp']} XP', style: V20Text.bs())])),
                ms[m['id']] != null ? const GameTag('✓ Fait', style: GameTagStyle.ok) : const GameTag('À faire'),
              ]),
            ),
          ],
          const SizedBox(height: 8),
          Text('Récompense versée une seule fois, à l’accomplissement. L’atelier d’écriture se fait dans Business.', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FIL DE LA CARRIÈRE', style: V20Text.lab()),
          const SizedBox(height: 4),
          if (log.isEmpty) Text('Rien encore.', style: V20Text.bs()),
          for (final l in log.take(12))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 92, child: Text('J${_m(l)['d']} · ${_cats[_m(l)['c']] ?? 'Jeu'}', style: V20Text.bs())),
                Expanded(child: Text(_m(l)['t'] as String, style: V20Text.bs(color: Tk.ink))),
              ]),
            ),
        ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-V1 Événement de carrière
// ---------------------------------------------------------------------------------------------------------------------

class EvenementScreen extends ConsumerWidget {
  const EvenementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final id = s['ev'] as String?;
    final e = id == null ? null : evt21[id];
    return Frame21(children: [
      BackHeader(title: 'Événement', onBack: () => context.go('/')),
      const SizedBox(height: 12),
      if (e == null) ...[
        Text('Aucun événement en attente', style: V20Text.nm()),
        const SizedBox(height: 4),
        Text('Les événements arrivent selon ta carrière : un défi au début, une offre de producteur après ton premier son, une offre de label à ${Reg21.labelRep} de réputation.', style: V20Text.bm),
        if (s['evLast'] != null) ...[
          const SizedBox(height: 12),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DERNIÈRE DÉCISION', style: V20Text.lab()), Text('${_m(s['evLast'])['t']} : ${_m(s['evLast'])['ch']}', style: V20Text.nm()), Text(_m(s['evLast'])['c'] as String, style: V20Text.bs())])),
        ],
      ] else ...[
        Row(children: [
          CastAvatar(e['who'] as String, size: 96, mood: 'poised'),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((e['who'] as String).toUpperCase(), style: V20Text.lab()), Text((e['t'] as String).toUpperCase(), style: V20Text.baloo(size: 22, line: 24))])),
        ]),
        const SizedBox(height: 12),
        GameCard(child: Text(e['q'] as String, style: V20Text.poppins(size: 16, line: 24))),
        for (final c in (e['ch'] as List).cast<J>()) ...[
          const SizedBox(height: 12),
          GameCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['n'] as String, style: V20Text.nm()),
              Conseq21(switch (c['k']) { 'r' => ConsequenceKind.risk, 'i' => ConsequenceKind.uncertain, 'e' => ConsequenceKind.estimated, _ => ConsequenceKind.certain }, c['c'] as String),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Choisir',
                style: c['id'] == 'a' ? GameButtonStyle.primary : GameButtonStyle.secondary,
                onPressed: () => doAct(context, ref, 'evc', c['id'], () => context.go(c['id'] == 'a' && s['ev'] == 'kzer' ? '/scene/battle' : '/')),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 8),
        Text('Encore ${_l(s['evq']).length} événement(s) en attente après celui-ci.', style: V20Text.bs()),
      ],
    ]);
  }
}


// ---------------------------------------------------------------------------------------------------------------------
// Missions de carrière (six chapitres, récompense à récupérer). Valeurs provisoires (D-08).
// ---------------------------------------------------------------------------------------------------------------------

String _goal(Mission21 m, num v) {
  String f(num x) => m.metric == 'signed' ? (x >= 1 ? 'oui' : 'non') : fmt21(x);
  return m.metric == 'signed' ? f(v) : '${f(v < m.goal ? v : m.goal)} / ${f(m.goal)}';
}

/// Carte du QG : mission de carrière à récupérer ou à viser.
class CareerMissionCard21 extends StatelessWidget {
  final J s;
  const CareerMissionCard21(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    final claim = missionsToClaim21(s);
    final ch = missionChapter21(s);
    final next = missions21.where((m) => m.ch == ch && missionState21(s, m) == 'open').firstOrNull;
    final (cash, xp) = next == null ? (0, 0) : missionReward21(next);
    return GlassCard(
      accent: claim > 0 ? GlassAccent.magenta : GlassAccent.none,
      halo: false,
      onTap: () => context.go('/journal'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('CHAPITRE $ch · ${missionChapters21[ch - 1].$1.toUpperCase()}', style: V20Text.lab())),
          if (claim > 0) GameTag('$claim à récupérer', style: GameTagStyle.accent),
        ]),
        const SizedBox(height: 6),
        if (claim > 0)
          Text('Mission accomplie : récupère ta récompense', style: V20Text.nm())
        else if (next != null) ...[
          Text(next.t, style: V20Text.nm()),
          Text('${_goal(next, missionMetric21(s, next.metric))} · +${fmt21(cash)} cauris · +$xp XP', style: V20Text.bs()),
        ] else
          Text('Toutes les missions sont récupérées', style: V20Text.nm()),
      ]),
    );
  }
}

/// Liste du Journal : missions à récupérer, puis chapitre en cours avec la progression de chaque mission.
class CareerMissions21 extends ConsumerWidget {
  final J s;
  const CareerMissions21(this.s, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ch = missionChapter21(s);
    final toClaim = missions21.where((m) => missionState21(s, m) == 'done').toList();
    final cur = missions21.where((m) => m.ch == ch && missionState21(s, m) == 'open').toList();
    final inCh = missions21.where((m) => m.ch == ch).length;
    final claimedCh = missions21.where((m) => m.ch == ch && missionState21(s, m) == 'claimed').length;
    Widget row(Mission21 m) {
      final st = missionState21(s, m);
      final v = missionMetric21(s, m.metric);
      final (cash, xp) = missionReward21(m);
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: GameCard(
          selected: st == 'done',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(m.t, style: V20Text.nm())),
              if (st == 'claimed') const GameTag('✓ Récupérée', style: GameTagStyle.ok),
            ]),
            Text('${_goal(m, v)} · +${fmt21(cash)} cauris · +$xp XP', style: V20Text.bs()),
            if (st == 'open' && m.metric != 'signed') ...[
              const SizedBox(height: 6),
              MeterBarLite((v / m.goal).clamp(0, 1).toDouble()),
            ],
            if (st == 'done') ...[
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Récupérer',
                sublabel: '+${fmt21(cash)} cauris · +$xp XP',
                compact: true,
                onPressed: () => doAct(context, ref, 'mclaim', m.id, null, 'Mission récupérée : +${fmt21(cash)} cauris, +$xp XP'),
              ),
            ],
          ]),
        ),
      );
    }

    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('MISSIONS DE CARRIÈRE · CHAPITRE $ch / ${missionChapters21.length}', style: V20Text.lab())),
          GameTag('${missionsClaimed21(s)} / ${missions21.length}'),
        ]),
        const SizedBox(height: 4),
        Text(missionChapters21[ch - 1].$1, style: V20Text.baloo(size: 22, line: 24)),
        Text('$claimedCh / $inCh missions récupérées dans ce chapitre. Le chapitre suivant s\'ouvre quand toutes sont récupérées.', style: V20Text.bs()),
        if (toClaim.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('À RÉCUPÉRER', style: V20Text.lab(color: V20.accText)),
          for (final m in toClaim) row(m),
        ],
        if (cur.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('EN COURS', style: V20Text.lab()),
          for (final m in cur) row(m),
        ],
        const SizedBox(height: 8),
        Text('Les missions se terminent toutes seules, même hors du chapitre en cours ; la récompense attend que tu la récupères. Valeurs provisoires.', style: V20Text.bs()),
      ]),
    );
  }
}

/// Jauge fine de progression (6 px) aux couleurs du jeu.
class MeterBarLite extends StatelessWidget {
  final double v;
  const MeterBarLite(this.v, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: 6,
          child: Stack(fit: StackFit.expand, children: [
            const ColoredBox(color: Tk.line),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: v,
              child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Tk.acc, Tk.violet]))),
            ),
          ]),
        ),
      );
}
