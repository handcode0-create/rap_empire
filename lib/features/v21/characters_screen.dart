import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';

/// Galerie des personnages (21-K1) : 25 portraits 2D provisoires, extraits de la planche (assets/svg/galerie-*).
/// Chaque personnage garde la même apparence partout (I-17). Aucune donnée de jeu : présentation seulement.

const _newCast = <(String, String, String)>[
  ('kzer', "K-Zer d'Mabaya", 'Rappeur · rival de Mabaya'),
  ('kaira', 'Kaïra Nox', 'Artiste n° 1 · Drill de Bakoma'),
  ('tito', 'Tito Brume', 'Artiste n° 4 · rap conscient'),
  ('lazuli', 'Lazuli', 'Artiste n° 5 · afro-soul (RCD)'),
  ('nadia-kolo', 'Nadia Kolo', 'Chanteuse · featuring (08.3)'),
  ('solo', 'Sôlo Vance', 'Artiste n° 6 · trap bakomaise'),
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
  ('maya', 'Maya Tessé', 'Manager'),
  ('zamba', 'Kouassi Zamba', "Promoteur · Festival Lagune d'Ambre"),
  ('ayana', 'Ayana Dembé', 'Artiste · chanteuse afro-soul'),
  ('rosine', 'Rosine Adjoua', 'Manager · presse et crise'),
  ('anselme', 'Anselme Bayoko', 'Manager · négociation de contrats'),
];

class PersonnagesScreen extends StatelessWidget {
  const PersonnagesScreen({super.key});

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
                      child: SvgPicture.asset('assets/svg/galerie-${p.$1}.svg', fit: BoxFit.contain, semanticsLabel: p.$2),
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
            text: 'Rendu 2D provisoire, en attendant les portraits peints (planche « Assets personnage v1.0 »). Chaque personnage garde la même apparence partout (I-17).'),
        _section('Nouveaux personnages', 'Proposé · à valider', _newCast, isNew: true),
        _section('Directeurs de label', 'Proposé · à valider', _directors, isNew: true),
        _section('Personnages existants', 'Existant · 16-1, 17-4', _existing, isNew: false),
      ]);
}
