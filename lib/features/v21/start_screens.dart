import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/bottom_sheet_game.dart';
import '../../core/widgets/character_view.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../core/widgets/screen_background.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'widgets21.dart';

/// Écrans de démarrage de la v21 : splash (21-S0), univers (21-S1), création de l'artiste (21-S2 à 21-S5), nouvelle partie (21-S0b)
/// et démarrage rapide de démonstration (21-Q0). Les règles sont dans le moteur ; ici seulement l'affichage et l'enchaînement.

/// Page sans HUD ni navigation : fond v20 et contenu qui défile.
class Page21 extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  const Page21({super.key, required this.children, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Tk.bg,
        body: ScreenBackground(child: SafeArea(child: ListView(padding: padding, children: children))),
      );
}

/// L'avatar du joueur : coiffure, haut et teint choisis à la création (assets/characters/me_*, générés par tools/design).
class PlayerAvatar extends StatelessWidget {
  final J s;
  final String mood, crop;
  final double? width, height;
  const PlayerAvatar(this.s, {super.key, this.mood = 'smile', this.crop = 'torso', this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final ap = s['ap'] as J;
    return CharacterView(who: 'me_${ap['hair']}_${ap['top']}_${ap['skin']}', mood: mood, crop: crop, width: width, height: height);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-S0 Splash
// ---------------------------------------------------------------------------------------------------------------------

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    final saved = s != null && s['created'] == 1;
    return Scaffold(
      backgroundColor: Tk.bg,
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Spacer(flex: 2),
              Text('handCode Studio', style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: V20.ink2, spacing: 1.4)),
              const SizedBox(height: 8),
              Text('RAP\nEMPIRE', textAlign: TextAlign.center, style: V20Text.baloo(size: 54, line: 56)),
              const SizedBox(height: 8),
              Text('De Ndolo au monde.', style: V20Text.bm),
              const Spacer(),
              SizedBox(height: 230, child: s == null ? const SizedBox() : PlayerAvatar(s, mood: 'smile', height: 230)),
              if (saved) ...[
                _SavedCard(s),
                const SizedBox(height: 12),
                PrimaryGlowButton(label: 'Continuer', sublabel: "Reprendre là où tu t'es arrêté", onPressed: () => context.go('/')),
                const SizedBox(height: 8),
                PrimaryButton(label: 'Nouvelle partie', style: GameButtonStyle.ghost, onPressed: () => context.go('/nouvelle-partie')),
              ] else
                PrimaryGlowButton(label: 'Commencer', sublabel: 'Créer ton artiste', onPressed: s == null ? null : () => context.go('/univers')),
              const SizedBox(height: 8),
              Align(alignment: Alignment.center, child: TextButton(onPressed: () => context.go('/demo'), child: Text('OUTIL DE DÉMO', style: V20Text.lab(color: V20.ink2)))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final J s;
  const _SavedCard(this.s);
  @override
  Widget build(BuildContext context) => GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PARTIE ENREGISTRÉE', style: V20Text.lab()),
          const SizedBox(height: 4),
          Text(playerName(s), style: V20Text.nm()),
          Text('${timeLabel(s)} · ${rankTag(s)} · ${fmt21(s['cash'] as num)} cauris', style: V20Text.bs()),
        ]),
      );
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-S0b Nouvelle partie : confirmation
// ---------------------------------------------------------------------------------------------------------------------

class NewGameScreen extends ConsumerWidget {
  const NewGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    return Page21(children: [
      const SizedBox(height: 48),
      Text('RAP EMPIRE', style: V20Text.lab()),
      const SizedBox(height: 8),
      Text('Nouvelle partie', style: V20Text.dm()),
      const SizedBox(height: 16),
      if (s != null)
        GameCard(
          child: Row(children: [
            SizedBox(width: 56, height: 56, child: PlayerAvatar(s, mood: 'cool', crop: 'bust', width: 56, height: 56)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('REMPLACER LA PARTIE DE', style: V20Text.lab()),
                Text(playerName(s), style: V20Text.nm()),
                Text('${timeLabel(s)} · ${rankTag(s)}', style: V20Text.bs()),
              ]),
            ),
          ]),
        ),
      const SizedBox(height: 12),
      const Conseq21(ConsequenceKind.certain, 'La partie actuelle est effacée de cet appareil. Cette action ne peut pas être annulée.'),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'Effacer et recommencer',
        onPressed: () async {
          await ref.read(game21Provider.notifier).newGame();
          if (context.mounted) context.go('/univers');
        },
      ),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Annuler', style: GameButtonStyle.ghost, onPressed: () => context.go('/demarrer')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-S1 Univers 1 à 3
// ---------------------------------------------------------------------------------------------------------------------

class UniversScreen extends StatefulWidget {
  const UniversScreen({super.key});
  @override
  State<UniversScreen> createState() => _UniversScreenState();
}

class _UniversScreenState extends State<UniversScreen> {
  int _i = 0;
  static const _pages = [
    ('Pose ton flow', 'Écris tes textes, choisis ton thème, enregistre en cabine. Chaque son compte.', 'studio'),
    ('La street te regarde', 'Open mic, défis, concerts. Le buzz du quartier fait ta réputation.', 'street'),
    ('Vise la légende', 'Labels, featurings, tournées. De Ndolo aux Rives de Sôlo, puis le monde.', 'stage'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = _pages[_i];
    return Page21(children: [
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.go('/artiste/identite'), child: Text('PASSER →', style: V20Text.lab(color: V20.accText)))),
      const SizedBox(height: 8),
      SceneBanner(kind: p.$3, height: 300, nameSize: 20, nameSingleLine: true, role: 'Univers ${_i + 1} / 3', name: ''),
      const SizedBox(height: 12),
      Text(p.$1.toUpperCase(), style: V20Text.dm()),
      const SizedBox(height: 8),
      Text(p.$2, style: V20Text.poppins(size: 17, line: 24, color: V20.ink2)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < 3; i++)
          Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: i == _i ? 24 : 8, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: i == _i ? Tk.acc : const Color.fromRGBO(255, 255, 255, .2))),
      ]),
      const SizedBox(height: 16),
      PrimaryGlowButton(label: _i < 2 ? 'Suivant' : 'Créer mon artiste', onPressed: () => _i < 2 ? setState(() => _i++) : context.go('/artiste/identite')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-S2 Identité : nom, âge, pays d'origine
// ---------------------------------------------------------------------------------------------------------------------

class IdentiteScreen extends ConsumerStatefulWidget {
  const IdentiteScreen({super.key});
  @override
  ConsumerState<IdentiteScreen> createState() => _IdentiteScreenState();
}

class _IdentiteScreenState extends ConsumerState<IdentiteScreen> {
  late final TextEditingController _name = TextEditingController(text: ((ref.read(game21Provider).valueOrNull?['p'] as J?)?['name'] ?? '') as String);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _set(String kv) async => ref.read(game21Provider.notifier).act('setp', kv);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final p = s['p'] as J;
    final ok = nameOk21(p['name']);
    final empty = cleanName21(p['name']).isEmpty;
    final err = empty ? 'Choisis un nom de scène pour continuer.' : (ok ? '' : 'De ${Reg21.nameMin} à ${Reg21.nameMax} caractères : lettres, chiffres, espace, tiret, apostrophe ou point.');
    final age = (p['age'] as num).toInt();
    return Page21(children: [
      BackHeader(title: 'Ton artiste', onBack: () => context.go('/univers')),
      const SizedBox(height: 12),
      const Steps21(0),
      const SizedBox(height: 12),
      const Lab21('Ton nom de scène'),
      TextField(
        controller: _name,
        maxLength: 40,
        onChanged: (v) => _set('name=$v'),
        style: V20Text.nm(),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          counterText: '',
          hintText: 'EX. DJO KÉNÉ',
          hintStyle: V20Text.nm(color: V20.ink2.withValues(alpha: .5)),
          filled: true,
          fillColor: Tk.s1,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line, width: 2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.acc, width: 2)),
        ),
      ),
      if (err.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err, style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w600, color: V20.hintGoldText))),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ÂGE DE DÉPART', style: V20Text.lab()), const GameTag('Proposé', style: GameTagStyle.outline, color: Color(0xFFD8C8FF))]),
          const SizedBox(height: 8),
          Row(children: [
            _Step(label: '−', onTap: age <= Reg21.ageMin ? null : () => _set('age=-')),
            const SizedBox(width: 16),
            Text('$age ANS', style: V20Text.dm(size: 30)),
            const SizedBox(width: 16),
            _Step(label: '+', onTap: age >= Reg21.ageMax ? null : () => _set('age=+')),
          ]),
          const SizedBox(height: 8),
          Text('De ${Reg21.ageMin} à ${Reg21.ageMax} ans. Énergie maximale au départ : ${enMaxAge(age)}. Elle baisse avec l’âge (écran Profil · Année).', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TON PAYS D’ORIGINE', style: V20Text.lab()), const GameTag('Validé 16/10', style: GameTagStyle.ok)]),
          for (final c in Reg21.conts.values) ...[
            const SizedBox(height: 8),
            Lab21(c['n'] as String),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final k in (c['c'] as List).cast<String>()) Chip21(Reg21.origins[k]!, selected: p['origin'] == k, onTap: () => _set('origin=$k')),
            ]),
          ],
          const SizedBox(height: 8),
          Text('Tu débutes à Ndolo. Chaque joueur choisit son pays parmi ceux du monde fictif ; venir d’ailleurs donne +4 de notoriété de départ dans ce pays.', style: V20Text.bs()),
        ]),
      ),
      const SizedBox(height: 16),
      PrimaryGlowButton(label: 'Continuer', sublabel: 'Ton look', onPressed: ok ? () => context.go('/artiste/look') : null),
    ]);
  }
}

class _Step extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _Step({required this.label, this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label == '+' ? 'Un an de plus' : 'Un an de moins',
        enabled: onTap != null,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Tk.s1, borderRadius: BorderRadius.circular(16), border: Border.all(color: Tk.line, width: 2)),
            child: Text(label, style: V20Text.nm(color: onTap == null ? Tk.dis : Tk.ink)),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-S3 Look
// ---------------------------------------------------------------------------------------------------------------------

class LookScreen extends ConsumerWidget {
  const LookScreen({super.key});
  static const hairs = {'hitwist': 'Twists hi-top', 'afro': 'Afro', 'cornrows': 'Nattes collées'};
  static const tops = {'hoodie': 'Hoodie Néon', 'bomber': 'Bomber violet', 'tee': 'T-shirt cyan'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final ap = s['ap'] as J;
    Future<void> set(String k, String v) => ref.read(game21Provider.notifier).act('ap', '$k=$v');
    return Page21(children: [
      BackHeader(title: 'Ton look', onBack: () => context.go('/artiste/identite')),
      const SizedBox(height: 12),
      const Steps21(1),
      const SizedBox(height: 8),
      Center(child: SizedBox(height: 240, child: PlayerAvatar(s, height: 240))),
      Center(child: Text('${Reg21.skins[ap['skin']]} · ${hairs[ap['hair']]} · ${tops[ap['top']]}', style: V20Text.bm)),
      const SizedBox(height: 12),
      const Lab21('Teint'),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final e in Reg21.skins.entries) Chip21(e.value, selected: ap['skin'] == e.key, onTap: () => set('skin', e.key))]),
      const SizedBox(height: 8),
      const Lab21('Coiffure'),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final e in hairs.entries) Chip21(e.value, selected: ap['hair'] == e.key, onTap: () => set('hair', e.key))]),
      const SizedBox(height: 8),
      const Lab21('Haut'),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final e in tops.entries) Chip21(e.value, selected: ap['top'] == e.key, onTap: () => set('top', e.key))]),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Rendu 2D provisoire : il sera remplacé par les calques peints. Tu pourras changer de look plus tard.'),
      const SizedBox(height: 12),
      PrimaryGlowButton(label: 'Continuer', sublabel: 'Ton style musical', onPressed: () => context.go('/artiste/style')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-S4 Style musical
// ---------------------------------------------------------------------------------------------------------------------

class StyleScreen extends ConsumerWidget {
  const StyleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final p = s['p'] as J;
    Future<void> set(String k, String v) => ref.read(game21Provider.notifier).act('setp', '$k=$v');
    return Page21(children: [
      BackHeader(title: 'Ton style musical', onBack: () => context.go('/artiste/look')),
      const SizedBox(height: 12),
      const Steps21(2),
      const SizedBox(height: 12),
      const GameHint(icon: 'info', text: 'Un style principal (obligatoire, +3 à sa compétence) et un style secondaire facultatif (+1). Touche à nouveau « Secondaire » sur le même style pour le retirer.'),
      for (final e in Reg21.styles.entries) ...[
        const SizedBox(height: 12),
        GameCard(
          selected: p['main'] == e.key,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: Text(e.value['n'] as String, style: V20Text.nm())),
              if (p['main'] == e.key) GameTag('Principal · ${e.value['kn']} +${Reg21.mainBonus}', style: GameTagStyle.accent),
              if (p['second'] == e.key) GameTag('Secondaire · ${e.value['kn']} +${Reg21.secondBonus}', style: GameTagStyle.outline, color: Tk.ink),
            ]),
            const SizedBox(height: 4),
            Text(e.value['d'] as String, style: V20Text.bm),
            const SizedBox(height: 8),
            Row(children: [
              Chip21('Principal', selected: p['main'] == e.key, onTap: () => set('main', e.key)),
              const SizedBox(width: 8),
              Chip21('Secondaire', selected: p['second'] == e.key, onTap: () => set('second', p['second'] == e.key ? 'none' : e.key)),
            ]),
          ]),
        ),
      ],
      const SizedBox(height: 16),
      PrimaryGlowButton(label: 'Continuer', sublabel: 'Ton objectif', onPressed: () => context.go('/artiste/objectif')),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-S5 Objectif, récapitulatif et entrée dans le jeu
// ---------------------------------------------------------------------------------------------------------------------

class ObjectifScreen extends ConsumerWidget {
  const ObjectifScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const SizedBox();
    final p = s['p'] as J;
    return Page21(children: [
      BackHeader(title: 'Ton objectif', onBack: () => context.go('/artiste/style')),
      const SizedBox(height: 12),
      const Steps21(3),
      for (final e in Reg21.goals.entries) ...[
        const SizedBox(height: 12),
        GameCard(
          selected: p['goal'] == e.key,
          onTap: () => ref.read(game21Provider.notifier).act('setp', 'goal=${e.key}'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.value['n'] as String, style: V20Text.nm()), Text(e.value['d'] as String, style: V20Text.bs())]),
        ),
      ],
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TON ARTISTE', style: V20Text.lab()),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 110, height: 140, child: PlayerAvatar(s, height: 140)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(children: [
                KeyVal('Nom', cleanName21(p['name'])),
                KeyVal('Âge', '${p['age']} ans'),
                KeyVal('Origine', Reg21.origins[p['origin']]!),
                KeyVal('Style', Reg21.styles[p['main']]!['n'] as String),
                if (p['second'] != null) KeyVal('Second', Reg21.styles[p['second']]!['n'] as String),
                KeyVal('Objectif', Reg21.goals[p['goal']]!['n'] as String),
              ]),
            ),
          ]),
          const SizedBox(height: 8),
          Conseq21(ConsequenceKind.certain, 'Départ : 25 000 cauris · énergie ${enMaxAge((p['age'] as num).toInt())} · 120 fans · jour 1 à Ndolo · non classé'),
        ]),
      ),
      const SizedBox(height: 16),
      PrimaryGlowButton(
        label: 'Entrer dans la street',
        sublabel: 'Ta carrière commence',
        onPressed: () async {
          final e = await ref.read(game21Provider.notifier).act('finish');
          if (!context.mounted) return;
          if (e != null) {
            toastErr(context, e);
            if (e == 'nom') context.go('/artiste/identite');
            return;
          }
          context.go('/');
        },
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-Q0 Démarrage rapide de démonstration
// ---------------------------------------------------------------------------------------------------------------------

class DemoScreen extends ConsumerWidget {
  const DemoScreen({super.key});
  static const _items = [
    ('debut', 'Début de carrière', 'Jour 1, 19 ans, 25 000 cauris, N1'),
    ('carriere', 'Carrière lancée', 'N3, 1 single sorti, réputation 31'),
    ('star', 'Star de Bakoma', 'N5, un titre « Bon », clip publié'),
    ('couple', 'En couple avec Lina', 'Jauge 82, 15 jours : la demande est possible'),
    ('marie', 'Marié(e), projet d’enfant', 'Une naissance peut arriver en fin de journée'),
    ('parent', 'Parent de Nayla', 'Un enfant au foyer, fièvre la veille d’un concert'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) => Page21(children: [
        BackHeader(title: 'Lancer la démo', onBack: () => context.go('/demarrer')),
        const SizedBox(height: 12),
        const GameHint(icon: 'info', text: 'Raccourcis de démonstration : chaque bouton charge un état complet du jeu. Ils n’existent pas dans le jeu final. Ils remplacent la partie en cours.'),
        for (final i in _items) ...[
          const SizedBox(height: 12),
          GameCard(
            onTap: () async {
              final e = await ref.read(game21Provider.notifier).act('preset', i.$1);
              if (!context.mounted) return;
              if (e != null) return toastErr(context, e);
              context.go(i.$1 == 'debut' ? '/evenement' : '/');
            },
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(i.$2, style: V20Text.nm()), Text(i.$3, style: V20Text.bs())])),
              const Icon(Icons.arrow_forward_rounded, color: Tk.ink),
            ]),
          ),
        ],
      ]);
}

/// Feuille de confirmation réutilisable (nouvelle partie depuis le profil).
Future<bool> confirmSheet(BuildContext context, {required String title, required String body, required String action}) async {
  final r = await showGameSheet<bool>(
    context,
    builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('CONFIRMATION', style: V20Text.lab()),
      const SizedBox(height: 12),
      Text(title.toUpperCase(), style: V20Text.dm(size: 24)),
      const SizedBox(height: 12),
      Text(body, style: V20Text.bs()),
      const SizedBox(height: 16),
      PrimaryButton(label: action, onPressed: () => Navigator.of(ctx).pop(true)),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Annuler', style: GameButtonStyle.ghost, onPressed: () => Navigator.of(ctx).pop(false)),
    ]),
  );
  return r == true;
}
