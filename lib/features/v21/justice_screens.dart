import 'package:flutter/material.dart';
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
import '../../core/widgets/meter_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'widgets21.dart';

/// Justice (contenu mature 16+) : activités illégales (21-Z1), garde à vue (21-Z2), avocat (21-Z3), tribunal (21-Z4), prison (21-Z5).
/// Activités fictives, sans aucune méthode : seuls le risque, le gain et les conséquences sont modélisés.
/// Tout l'écran est verrouillé tant que le contenu mature est désactivé (réglage du Profil, désactivé par défaut).

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x is Map<String, dynamic> ? x : <String, dynamic>{};
List _l(dynamic x) => x is List ? x : const [];

const _mature = 'Mature · 16+';

/// Carte « contenu mature désactivé » avec le bouton d'activation.
class _MatureLock extends ConsumerWidget {
  const _MatureLock();
  @override
  Widget build(BuildContext context, WidgetRef ref) => GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Contenu mature désactivé', style: V20Text.nm()),
        const SizedBox(height: 4),
        Text('Ces activités sont réservées au mode 16+. Elles restent désactivées par défaut pour une version tout public.', style: V20Text.bs()),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Activer le contenu mature (16+)', style: GameButtonStyle.secondary, onPressed: () => doAct(context, ref, 'mature', 'on', null, 'Contenu mature activé')),
      ]));
}

Widget _portrait(String asset, {double size = 56}) => ClipOval(child: SizedBox.square(dimension: size, child: SvgPicture.asset(asset, fit: BoxFit.cover, alignment: Alignment.topCenter)));

Widget _banner(String decor, String role, List<BannerChar> chars) => SceneBanner(kind: 'office', sceneAsset: 'assets/svg/$decor.svg', height: 180, role: role, chars: chars);

const _djo = BannerChar('djo', mood: 'worried', crop: 'torso', width: 92, left: 24);

// ---------------------------------------------------------------------------------------------------------------------
// 21-Z1 Activités illégales
// ---------------------------------------------------------------------------------------------------------------------

class Justice21Screen extends ConsumerWidget {
  const Justice21Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final on = _n(s['mature']) != 0;
    final cas = s['cas'] as J?;
    final heat = _n(s['heat']).toInt();
    final lc = s['lastCrime'] as J?;
    final casier = _l(s['casier']).map(_m).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Activités illégales', step: _mature, onBack: () => context.go('/business')),
      const SizedBox(height: 12),
      const GameHint(
          icon: 'info',
          warn: true,
          text: 'Activités fictives, sans aucune méthode : seuls le risque, le gain et les conséquences sont modélisés. Elles peuvent relever la classification du jeu sur les stores (16 ou 18 ans).'),
      const SizedBox(height: 12),
      if (!on) ...[const _MatureLock(), const SizedBox(height: 12)],
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CHALEUR POLICIÈRE', style: V20Text.lab()),
        Row(children: [
          Text('$heat', style: V20Text.baloo(size: 26, line: 28)),
          Text(' / 100', style: V20Text.bm),
          const SizedBox(width: 12),
          Expanded(child: MeterBar(value: heat / 100)),
        ]),
        Text('Chaque délit l’augmente, elle baisse de ${Reg21.heatDecay} par jour. La moitié s’ajoute au risque d’arrestation.', style: V20Text.bs()),
      ])),
      if (s['jail'] != null) ...[
        const SizedBox(height: 12),
        GameCard(
            onTap: () => context.go('/business/justice/prison'),
            child: Text('En prison · encore ${jailDaysLeft(s)} jour(s) : ouvrir la prison', style: V20Text.nm())),
      ],
      if (cas != null) ...[
        const SizedBox(height: 12),
        GameCard(
            selected: true,
            onTap: () => context.go(cas['stage'] == 'garde' ? '/business/justice/garde' : '/business/justice/avocat'),
            child: Row(children: [
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Affaire en cours : ${cas['n']}', style: V20Text.nm()),
                Text('Garde à vue, avocat, procès', style: V20Text.bs()),
              ])),
              const GameTag('À traiter', style: GameTagStyle.accent),
            ])),
      ],
      if (lc != null) ...[
        const SizedBox(height: 12),
        GlassCard(
            accent: _n(lc['ok']) != 0 ? GlassAccent.cyan : GlassAccent.magenta,
            halo: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DERNIÈRE TENTATIVE', style: V20Text.lab()),
              Text(_n(lc['ok']) != 0 ? '${lc['n']} : +${fmt21(_n(lc['gain']))} cauris (risque ${lc['risk']} %)' : '${lc['n']} : arrêté (risque ${lc['risk']} %)', style: V20Text.nm()),
            ])),
      ],
      const SizedBox(height: 12),
      for (final e in Reg21.crimes.entries) ...[
        Builder(builder: (context) {
          final c = e.value;
          final risk = (c['risk'] as num) + jsRound(heat / 2);
          final blocked = !on || cas != null || s['jail'] != null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GameCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('${c['n']}', style: V20Text.nm())),
                GameTag('Risque ${risk > 85 ? 85 : risk} %', style: GameTagStyle.accent),
              ]),
              Text('${c['h']} h · −${c['e']} énergie · gain ${fmt21(c['lo'] as num)} à ${fmt21(c['hi'] as num)} cauris · chaleur +${c['heat']}', style: V20Text.bs()),
              Conseq21(ConsequenceKind.risk, 'Si tu es arrêté : ${c['ch']}'),
              const SizedBox(height: 6),
              PrimaryButton(
                  label: 'Tenter',
                  style: blocked ? GameButtonStyle.disabled : GameButtonStyle.secondary,
                  onPressed: blocked ? null : () => doAct(context, ref, 'crime', e.key)),
            ])),
          );
        }),
      ],
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CASIER JUDICIAIRE', style: V20Text.lab()),
        if (casier.isEmpty) Text('Vierge', style: V20Text.nm()),
        for (final c in casier) Text('${dateLabel21(c['day'] as num)} · ${c['ch']}', style: V20Text.bs(color: Tk.ink)),
      ])),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Z2 Garde à vue
// ---------------------------------------------------------------------------------------------------------------------

class GardeScreen extends ConsumerWidget {
  const GardeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final cas = s['cas'] as J?;
    final back = BackHeader(title: 'Garde à vue', step: _mature, onBack: () => context.go('/business/justice'));
    if (cas == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [back, const SizedBox(height: 12), const GlassCard(child: Text('Aucune affaire en cours')), const SizedBox(height: 12), PrimaryButton(label: 'Retour', onPressed: () => context.go('/business/justice'))]);
    }
    final garde = cas['stage'] == 'garde';
    final lw = Reg21.lawyers[cas['lawyer']]!;
    final bail = _n(cas['bail']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      back,
      const SizedBox(height: 12),
      LayoutBuilder(
          builder: (context, c) => _banner('decor-commissariat', 'Commissariat de Ndolo', [
                BannerChar('gnaore', width: 108, left: c.maxWidth - 126, asset: 'assets/svg/portrait-gnaore.svg'),
                _djo,
              ])),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('LIEUTENANT GNAORÉ', style: V20Text.lab()),
        const SizedBox(height: 6),
        Text('« Tu es poursuivi pour ${cas['ch']}. Ton procès aura lieu le jour ${cas['trial']}. »', style: V20Text.bm.copyWith(fontSize: 16, height: 1.3)),
      ])),
      if (garde) ...[
        const SizedBox(height: 10),
        GameCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payer la caution', style: V20Text.nm()),
          const SizedBox(height: 4),
          Conseq21(ConsequenceKind.certain, '−${fmt21(bail)} cauris · tu restes libre jusqu’au procès'),
          const SizedBox(height: 8),
          PrimaryGlowButton(label: 'Payer', onPressed: _n(s['cash']) < bail ? null : () => doAct(context, ref, 'bail', null, () => context.go('/business/justice/avocat'))),
          if (_n(s['cash']) < bail) Text('Il manque ${fmt21(bail - _n(s['cash']))} cauris.', style: V20Text.bs(color: V20.hintGoldText)),
        ])),
        const SizedBox(height: 10),
        GameCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rester en détention provisoire', style: V20Text.nm()),
          const SizedBox(height: 4),
          const Conseq21(ConsequenceKind.risk, 'Aucun coût · tu ne peux ni enregistrer ni monter sur scène avant le procès'),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Accepter', style: GameButtonStyle.secondary, onPressed: () => doAct(context, ref, 'detention', null, () => context.go('/business/justice/prison'))),
        ])),
      ],
      const SizedBox(height: 10),
      GameCard(
          onTap: () => context.go('/business/justice/avocat'),
          child: Row(children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Choisir un avocat', style: V20Text.nm()),
              Text('Avocat actuel : ${lw['n']}', style: V20Text.bs()),
            ])),
          ])),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Z3 Avocat
// ---------------------------------------------------------------------------------------------------------------------

class AvocatScreen extends ConsumerWidget {
  const AvocatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final cas = s['cas'] as J?;
    final back = BackHeader(title: 'Ton avocat', step: _mature, onBack: () => context.go('/business/justice'));
    if (cas == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [back, const SizedBox(height: 12), const GlassCard(child: Text('Aucune affaire en cours'))]);
    }
    final left = (_n(cas['trial']) - _n(s['day'])).clamp(0, 999);
    return ListView(padding: const EdgeInsets.all(16), children: [
      back,
      for (final e in Reg21.lawyers.entries) ...[
        const SizedBox(height: 10),
        GameCard(
            selected: cas['lawyer'] == e.key,
            onTap: () => doAct(context, ref, 'lawyer', e.key),
            child: Row(children: [
              _portrait('assets/svg/portrait-${e.value['who']}-bust.svg'),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${e.value['n']}', style: V20Text.nm()),
                Text('${e.value['role']} · ${_n(e.value['cost']) == 0 ? 'gratuit' : '${fmt21(e.value['cost'] as num)} cauris'} · efficacité ${e.value['skill']}', style: V20Text.bs()),
              ])),
              if (cas['lawyer'] == e.key) const GameTag('Choisi', style: GameTagStyle.ok),
            ])),
      ],
      const SizedBox(height: 12),
      const Conseq21(ConsequenceKind.estimated, 'L’efficacité augmente les chances de relaxe et réduit la peine de prison.'),
      const Conseq21(ConsequenceKind.certain, 'Les honoraires sont payés au choix de l’avocat.'),
      const SizedBox(height: 8),
      GameHint(icon: 'info', text: 'Procès dans $left jour(s). Tu peux continuer ta vie d’ici là (sauf en détention).'),
      const SizedBox(height: 12),
      PrimaryGlowButton(label: 'Aller au tribunal', onPressed: () => context.go('/business/justice/tribunal')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Z4 Tribunal
// ---------------------------------------------------------------------------------------------------------------------

class TribunalScreen extends ConsumerWidget {
  const TribunalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final cas = s['cas'] as J?;
    final vd = s['verdict'] as J?;
    final back = BackHeader(title: 'Tribunal de Lumbé', step: _mature, onBack: () => context.go('/business/justice'));
    final key = cas?['lawyer'] as String?;
    final lwKey = key ?? Reg21.lawyers.entries.firstWhere((e) => e.value['n'] == vd?['lawyer'], orElse: () => Reg21.lawyers.entries.first).key;
    final lw = Reg21.lawyers[lwKey]!;
    final banner = LayoutBuilder(
        builder: (context, c) => _banner('decor-tribunal', 'Audience publique', [
              BannerChar('juge', width: 100, left: c.maxWidth / 2 - 50, asset: 'assets/svg/portrait-juge.svg'),
              BannerChar('avocat', width: 92, left: c.maxWidth - 116, asset: 'assets/svg/portrait-${lw['who']}-torso.svg'),
              _djo,
            ]));
    if (cas == null && vd == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [back, const SizedBox(height: 12), const GlassCard(child: Text('Aucune affaire en cours')), const SizedBox(height: 12), PrimaryButton(label: 'Retour au QG', onPressed: () => context.go('/'))]);
    }
    if (cas == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        back,
        const SizedBox(height: 12),
        banner,
        const SizedBox(height: 12),
        GlassCard(
            accent: _n(vd!['acq']) != 0 ? GlassAccent.cyan : GlassAccent.magenta,
            halo: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('VERDICT · ${vd['ch']}'.toUpperCase(), style: V20Text.lab()),
              const SizedBox(height: 4),
              Text('${vd['txt']}', style: V20Text.dm(size: 22)),
              const SizedBox(height: 4),
              Text('Défense : ${vd['lawyer']} · plaidoyer : ${vd['plea']}', style: V20Text.bs()),
            ])),
        const SizedBox(height: 8),
        Conseq21(ConsequenceKind.certain, _n(vd['acq']) != 0 ? 'Popularité +1 · pas d’inscription au casier' : 'Popularité −5 · fans −8 % · inscription au casier'),
        const SizedBox(height: 12),
        if (s['jail'] != null) PrimaryGlowButton(label: 'Aller en prison', onPressed: () => context.go('/business/justice/prison')),
        if (s['jail'] != null) const SizedBox(height: 8),
        PrimaryButton(label: 'Retour au QG', style: s['jail'] != null ? GameButtonStyle.secondary : GameButtonStyle.primary, onPressed: () => context.go('/')),
      ]);
    }
    final ready = cas['stage'] != 'garde' && _n(s['day']) >= _n(cas['trial']);
    final days = (_n(cas['trial']) - _n(s['day'])).clamp(0, 999);
    return ListView(padding: const EdgeInsets.all(16), children: [
      back,
      const SizedBox(height: 12),
      banner,
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('JUGE ASSIATOU NDRI', style: V20Text.lab()),
        const SizedBox(height: 6),
        Text('« L’accusé est poursuivi pour ${cas['ch']}. Défendu par ${lw['n']}. Comment plaidez-vous ? »', style: V20Text.bm.copyWith(fontSize: 16, height: 1.3)),
      ])),
      if (!ready) ...[
        const SizedBox(height: 10),
        GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cas['stage'] == 'garde' ? 'Garde à vue en cours' : 'Le procès a lieu dans $days jour(s)', style: V20Text.nm()),
          Text(cas['stage'] == 'garde' ? 'Paie la caution ou accepte la détention provisoire.' : 'Reviens le jour ${cas['trial']}.', style: V20Text.bs()),
        ])),
      ],
      const SizedBox(height: 10),
      GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Plaider non coupable', style: V20Text.nm()),
        const SizedBox(height: 4),
        const Conseq21(ConsequenceKind.uncertain, 'Chance de relaxe selon l’avocat et la gravité ; sinon peine complète'),
        const SizedBox(height: 8),
        PrimaryGlowButton(label: 'Plaider non coupable', onPressed: ready ? () => doAct(context, ref, 'trial', 'nc') : null),
      ])),
      const SizedBox(height: 10),
      GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Plaider coupable', style: V20Text.nm()),
        const SizedBox(height: 4),
        const Conseq21(ConsequenceKind.certain, 'Pas de relaxe, mais peine réduite d’un quart et amende −20 %'),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Plaider coupable', style: ready ? GameButtonStyle.secondary : GameButtonStyle.disabled, onPressed: ready ? () => doAct(context, ref, 'trial', 'coupable') : null),
      ])),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Z5 Prison
// ---------------------------------------------------------------------------------------------------------------------

class PrisonScreen extends ConsumerWidget {
  const PrisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final jail = s['jail'] as J?;
    final casier = _l(s['casier']).map(_m).toList();
    final back = BackHeader(title: 'Prison de Lumbé', step: _mature, onBack: () => context.go('/business/justice'));
    if (jail == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        back,
        const SizedBox(height: 12),
        GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tu es libre', style: V20Text.dm(size: 24)),
          if (casier.isNotEmpty) Text('Casier : J${casier.last['day']} · ${casier.last['ch']}', style: V20Text.bs()),
        ])),
        const SizedBox(height: 12),
        if (s['cas'] != null) ...[PrimaryGlowButton(label: 'Préparer le procès', onPressed: () => context.go('/business/justice/avocat')), const SizedBox(height: 8)],
        PrimaryButton(label: 'Retour au QG', style: s['cas'] != null ? GameButtonStyle.secondary : GameButtonStyle.primary, onPressed: () => context.go('/')),
      ]);
    }
    final left = jailDaysLeft(s);
    final phone = _n(s['jphone']) != 0;
    final current = s['cur'] as J?;
    final busy = current != null && current['st'] != 'sorti';
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        const Icon(Icons.lock, color: Color(0xFFFF4DA6)),
        const SizedBox(width: 10),
        Expanded(child: Text('PRISON DE LUMBÉ', style: V20Text.dm(size: 22))),
        const GameTag('ACCÈS RESTREINT', style: GameTagStyle.accent),
      ]),
      const SizedBox(height: 12),
      _banner('decor-cellule', 'Cellule 12', const [BannerChar('djo', mood: 'worried', crop: 'torso', width: 92, left: 150)]),
      const SizedBox(height: 12),
      GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Encore $left jour(s)', style: V20Text.dm(size: 26)),
        if (_n(jail['pre']) != 0) Text('Détention provisoire : tu sors le jour du procès.', style: V20Text.bs(color: Tk.ink)),
        Text('Tous les autres espaces sont verrouillés. Ici, tu peux écrire, enregistrer en qualité limitée, créer un RIO et bâtir ta réputation carcérale.', style: V20Text.bs()),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: Text('Réputation carcérale', style: V20Text.bs())), Text('${_n(s['jrep']).toInt()}', style: V20Text.baloo(size: 24, line: 26, color: const Color(0xFFFF4DA6)))]),
        Row(children: [Expanded(child: Text('Téléphone satellite', style: V20Text.bs())), GameTag(phone ? 'ÉQUIPÉ' : 'NON ÉQUIPÉ', style: phone ? GameTagStyle.ok : GameTagStyle.accent)]),
      ])),
      const SizedBox(height: 10),
      GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Écrire en cellule', style: V20Text.nm()),
        const Conseq21(ConsequenceKind.certain, 'Écriture +2 · une fois par jour'),
        const SizedBox(height: 6),
        PrimaryButton(label: 'Écrire', style: s['jw'] == s['day'] ? GameButtonStyle.disabled : GameButtonStyle.secondary, onPressed: s['jw'] == s['day'] ? null : () => doAct(context, ref, 'jw', null, null, 'Écriture +2')),
      ])),
      const SizedBox(height: 10),
      GameCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Enregistrer en cellule', style: V20Text.nm()),
        const SizedBox(height: 4),
        Text(phone ? 'Téléphone satellite · qualité estimée 62/100' : 'Téléphone basique · qualité estimée 24/100', style: V20Text.bs()),
        if (busy) Text('Projet en cours : ${current['title']} · tu le reprendras après ta libération.', style: V20Text.bs(color: V20.hintGoldText)),
        const SizedBox(height: 8),
        PrimaryGlowButton(label: 'Enregistrer un freestyle', onPressed: busy || s['jrec'] == s['day'] ? null : () => doAct(context, ref, 'jrecord', null, null, 'Freestyle enregistré en cellule')),
      ])),
      const SizedBox(height: 10),
      GameCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Créer un RIO', style: V20Text.nm()),
        Text('Un morceau-défi carcéral. Qualité faible sans téléphone satellite, réputation +2.', style: V20Text.bs()),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Lancer le RIO', style: GameButtonStyle.secondary, onPressed: busy || s['jrio'] == s['day'] ? null : () => doAct(context, ref, 'jrio', null, null, 'RIO créé')),
      ])),
      const SizedBox(height: 10),
      GameCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Téléphone satellite', style: V20Text.nm()),
        Text(phone ? 'Équipement acquis : les prochaines prises seront meilleures.' : 'Coût : 18 000 cauris · augmente la qualité des prochains enregistrements.', style: V20Text.bs()),
        const SizedBox(height: 8),
        PrimaryButton(label: phone ? 'Déjà équipé' : 'Acheter · 18 000 cauris', style: phone ? GameButtonStyle.disabled : GameButtonStyle.secondary, onPressed: phone || _n(s['cash']) < 18000 ? null : () => doAct(context, ref, 'jphone', null, null, 'Téléphone satellite acheté')),
        if (!phone && _n(s['cash']) < 18000) Text('Il te manque ${fmt21(18000 - _n(s['cash']))} cauris.', style: V20Text.bs(color: V20.hintGoldText)),
      ])),
      const SizedBox(height: 10),
      GameCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Affronter un détenu', style: V20Text.nm()),
        Text('Duel scénarisé automatique : victoire réputation +3, défaite réputation −1. Une tentative par jour.', style: V20Text.bs()),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Défier un détenu', style: s['jfight'] == s['day'] ? GameButtonStyle.disabled : GameButtonStyle.secondary, onPressed: s['jfight'] == s['day'] ? null : () => doAct(context, ref, 'jfight', null, null, 'Affrontement terminé')),
      ])),
      const SizedBox(height: 10),
      GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Sport dans la cour', style: V20Text.nm()),
        const Conseq21(ConsequenceKind.certain, 'Charisme +1 · énergie +10 · une fois par jour'),
        const SizedBox(height: 6),
        PrimaryButton(label: 'S’entraîner', style: s['jsp'] == s['day'] ? GameButtonStyle.disabled : GameButtonStyle.secondary, onPressed: s['jsp'] == s['day'] ? null : () => doAct(context, ref, 'js', null, null, 'Charisme +1')),
      ])),
      const SizedBox(height: 12),
      PrimaryGlowButton(label: 'Terminer la journée', sublabel: 'Un jour de moins', onPressed: () => doAct(context, ref, 'endDay', null, () => context.go('/bilan'))),
    ]);
  }
}
