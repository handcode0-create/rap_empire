import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/env.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/enter_anim.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/screen_background.dart';

/// Crédits du jeu : équipe, outils, polices, mentions. Écran autonome (sans HUD ni navigation), ouvert par « push ».
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Tk.bg,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  BackHeader(title: 'Crédits', onBack: () => context.canPop() ? context.pop() : context.go('/demarrer')),
                  const SizedBox(height: 16),
                  EnterAnim(
                    child: Semantics(
                      image: true,
                      label: 'Logo RAP EMPIRE',
                      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/logos/rap_empire_logo.jpg', fit: BoxFit.contain, height: 280, width: double.infinity)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _Block(index: 1, title: 'ÉDITEUR', lines: ['handCode Studio · Abidjan']),
                  const _Block(index: 2, title: 'CONCEPTION ET DIRECTION', lines: ['Smith, fondateur de handCode Studio']),
                  const _Block(index: 3, title: 'DÉVELOPPEMENT ET ILLUSTRATIONS', lines: ['Réalisés avec l’assistance de Claude (Anthropic)', 'Personnages, scènes et logo générés par code, à partir des fiches de personnages du jeu']),
                  const _Block(index: 4, title: 'OUTILS', lines: ['Flutter et Dart', 'Serveur de jeu en ligne hébergé sur Render']),
                  const _Block(index: 5, title: 'POLICES', lines: ['Baloo 2 (Ek Type), licence SIL OFL 1.1', 'Poppins (Indian Type Foundry), licence SIL OFL 1.1']),
                  const _Block(index: 6, title: 'UNIVERS FICTIF', lines: ['Bakoma, ses quartiers, ses artistes, labels, salles, titres et chiffres sont inventés. Toute ressemblance avec une personne, une marque ou une œuvre réelle serait fortuite.']),
                  const SizedBox(height: 8),
                  Text('© handCode Studio · Version du ${Env.buildTime} (UTC)', textAlign: TextAlign.center, style: V20Text.bs()),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ),
        ),
      );
}

class _Block extends StatelessWidget {
  final int index;
  final String title;
  final List<String> lines;
  const _Block({required this.index, required this.title, required this.lines});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: EnterAnim(
          index: index,
          child: GameCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: V20Text.lab()),
              const SizedBox(height: 6),
              for (final l in lines) Padding(padding: const EdgeInsets.only(top: 2), child: Text(l, style: V20Text.bm)),
            ]),
          ),
        ),
      );
}
