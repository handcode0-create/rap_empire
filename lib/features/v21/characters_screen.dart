import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/character_view.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';

/// Galerie v21. Les personnages du registre du générateur (tools/design/cast.py)
/// utilisent les SVG exportés dans assets/characters/ via export_assets.py.
/// Les portraits proposés hors de ce registre conservent leurs SVG dédiés jusqu'à
/// leur intégration explicite dans le générateur. Les identités validées ne sont pas redessinées.

const _generatedCastIds = <String>{
  'djo', 'kore', 'orage', 'zaki', 'nadia', 'zamba', 'rosine', 'anselme',
  'ayana', 'kzer', 'woro', 'sanko', 'ines', 'kadi', 'lina', 'sefa',
  'amara', 'yao', 'noe', 'teo', 'awa', 'bakary', 'liv', 'marius', 'kre',
  'maze', 'benedicte', 'kofi', 'kaira', 'tito', 'lazuli', 'nadia-kolo', 'solo',
  'mika', 'tamsir', 'desire', 'naya',
};

const _newCast = <(String, String, String)>[
  ('kzer', "K-Zer d'Mabaya", 'Rappeur · rival de Mabaya'),
  ('kaira', 'Kaïra Nox', 'Artiste · drill'),
  ('tito', 'Tito Brume', 'Artiste · rap conscient'),
  ('lazuli', 'Lazuli', 'Artiste · afro-soul'),
  ('nadia-kolo', 'Nadia Kolo', 'Chanteuse · featuring'),
  ('solo', 'Sôlo Vance', 'Artiste · trap'),
  ('sanko', 'Sanko Beats', 'Producteur · Pont des Griots'),
  ('woro', 'Mister Wôrô', "Producteur · Lagune d'Ambre"),
];

const _directors = <(String, String, String)>[
  ('awa', 'Awa Liméa', 'Découvreuse · Aube Nouvelle'),
  ('bakary', 'Bakary Fé', 'Fondateur · Ndolo Underground'),
  ('liv', 'Liv Sélou', 'Porte-parole · Sélène Indie Collective'),
  ('marius', 'Marius Argent', 'Directeur · Vague Argentée'),
  ('kre', 'Jonas Kré', 'Directeur artistique · Black Lagune'),
  ('maze', 'Prof Mazé', 'Fondateur · Lyrik Atelier'),
  ('benedicte', 'Bénédicte Kassi', 'Présidente · Ambre Music Group'),
  ('kofi', 'Kofi Ndayé', 'Directeur export · Rythme Cardinal'),
];

const _existing = <(String, String, String)>[
  ('djo', 'Djo Kéné', 'Toi, rappeur'),
  ('kore', 'DJ Kôrô', 'Producteur · Studio Kôrô'),
  ('orage', 'Madame Orage', 'Directrice artistique · Bakoma Sound Records'),
  ('zaki', 'Zaki Mbela', 'Rappeur · rival de Ndolo'),
  ('nadia', 'Maya Tessé', 'Manager'),
  ('zamba', 'Kouassi Zamba', "Promoteur · Festival Lagune d'Ambre"),
  ('ayana', 'Ayana Dembé', 'Artiste · chanteuse afro-soul'),
  ('rosine', 'Rosine Adjoua', 'Manager · presse et crise'),
  ('anselme', 'Anselme Bayoko', 'Manager · négociation de contrats'),
  ('mika', 'Mika Soro', 'Manager · développement et image'),
  ('tamsir', 'Tamsir Koffi', 'Beatmaker · sonorités afro-drill'),
  ('desire', 'Désiré Kpan', 'Road manager · logistique de tournée'),
  ('naya', 'Naya Rêve', 'Artiste · rap mélodique et R&B'),
];

class PersonnagesScreen extends StatelessWidget {
  const PersonnagesScreen({super.key});

  Widget _portrait((String, String, String) p) {
    final id = p.$1;
    if (_generatedCastIds.contains(id)) {
      return CharacterView(
        who: id,
        mood: 'cool',
        crop: 'bust',
        width: double.infinity,
        height: 112,
      );
    }

    // Portrait dédié conservé pour les personnages qui ne figurent pas encore
    // dans CAST : ne pas les remplacer par un avatar générique.
    return SvgPicture.asset(
      'assets/svg/galerie-$id.svg',
      fit: BoxFit.contain,
      semanticsLabel: p.$2,
    );
  }

  Widget _section(String title, String tag, List<(String, String, String)> cast, {required bool isNew}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(title.toUpperCase(), style: V20Text.lab())),
          GameTag(tag, style: GameTagStyle.accent),
        ]),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, c) {
          final w = (c.maxWidth - 8) / 2;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in cast)
              SizedBox(
                width: w,
                child: GameCard(
                  padding: const EdgeInsets.all(8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      height: 112,
                      decoration: BoxDecoration(color: const Color.fromRGBO(255, 255, 255, .05), borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: _portrait(p),
                    ),
                    const SizedBox(height: 8),
                    Text(p.$2, style: V20Text.nm()),
                    const SizedBox(height: 2),
                    Text(p.$3, style: V20Text.bs()),
                    if (isNew) ...[
                      const SizedBox(height: 6),
                      const GameTag('Nouveau', style: GameTagStyle.accent),
                    ],
                  ]),
                ),
              ),
          ]);
        }),
      ]);

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        BackHeader(title: 'Personnages', step: 'D-01', onBack: () => context.go('/profil')),
        const SizedBox(height: 12),
        const GameHint(
          icon: 'info',
          text: 'Les portraits de cette galerie sont générés par le moteur 2D RAP EMPIRE : identité, coiffure, teint, accessoires et tenue sont définis dans tools/design/cast.py.',
        ),
        _section('Nouveaux personnages', 'Proposé · à valider', _newCast, isNew: true),
        _section('Directeurs de label', 'Proposé · à valider', _directors, isNew: true),
        _section('Personnages existants', 'Existant · 16-1, 17-4', _existing, isNew: false),
      ]);
}
