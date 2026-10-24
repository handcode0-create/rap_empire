import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/scene_banner.dart';
import '../../domain/game_state.dart';

/// Garde-robe v21 : catalogue issu du manifeste existant, sans génération d'illustrations au runtime.
class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  late final Future<List<Map<String, dynamic>>> _catalog = _loadCatalog();

  Future<List<Map<String, dynamic>>> _loadCatalog() async {
    final raw = await rootBundle.loadString('assets/characters/rapper_001/manifest.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['outfits'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  String _money(int amount) {
    final digits = amount.toString();
    return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ') + ' C';
  }

  Future<void> _act(Future<void> Function() action) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Garde-robe mise à jour.')),
        );
      }
    } on GameError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action impossible. Réessaie.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider).valueOrNull;
    if (state == null) return const Center(child: CircularProgressIndicator());

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Catalogue de tenues indisponible', style: V20Text.dm(size: 24)),
                  const SizedBox(height: 8),
                  Text('Le manifeste de garde-robe n’a pas pu être chargé.', style: V20Text.bs()),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Retour au profil', onPressed: () => context.go('/profil')),
                ],
              ),
            ),
          );
        }

        final outfits = snapshot.data!;
        final equippedPath =
            'assets/characters/rapper_001/${state.avatarStage}/v21b_${state.equippedOutfit}.svg';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Retour au profil',
                  onPressed: () => context.go('/profil'),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(child: Text('GARDE-ROBE', style: V20Text.dm(size: 28))),
              ],
            ),
            const SizedBox(height: 8),
            SceneBanner(
              kind: 'studio',
              height: 220,
              nameSize: 28,
              role: 'TENUE ÉQUIPÉE',
              name: 'Djo Kéné',
              subtitle: '${state.equippedOutfit} · ${state.avatarStage == 'young' ? 'Version jeune' : 'Version mature'}',
              chars: [
                BannerChar('Djo Kéné', width: 116, left: 230, asset: equippedPath),
              ],
            ),
            const SizedBox(height: 16),
            Text('VARIANTE DU PERSONNAGE', style: V20Text.lab()),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Jeune'),
                  selected: state.avatarStage == 'young',
                  onSelected: (selected) {
                    if (selected) _act(() => ref.read(gameProvider.notifier).setAvatarStage('young'));
                  },
                ),
                ChoiceChip(
                  label: const Text('Mature'),
                  selected: state.avatarStage == 'mature',
                  onSelected: (selected) {
                    if (selected) _act(() => ref.read(gameProvider.notifier).setAvatarStage('mature'));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Les deux versions utilisent les illustrations SVG déjà présentes dans le dépôt. Le choix est sauvegardé avec la partie.',
              style: V20Text.bs(),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text('TENUES DISPONIBLES', style: V20Text.lab())),
                Text('${outfits.length} modèles', style: V20Text.bs()),
              ],
            ),
            const SizedBox(height: 10),
            for (final outfit in outfits)
              _OutfitCard(
                outfit: outfit,
                stage: state.avatarStage,
                level: state.level,
                cash: state.cash,
                owned: state.outfitOwned.contains(outfit['id'] as String),
                equipped: state.equippedOutfit == outfit['id'],
                money: _money,
                onAction: (id, name, price, requiredLevel, owned) => _act(() async {
                  final notifier = ref.read(gameProvider.notifier);
                  if (owned) {
                    await notifier.equipOutfit(id);
                  } else {
                    await notifier.buyOutfit(
                      id: id,
                      name: name,
                      price: price,
                      requiredLevel: requiredLevel,
                    );
                  }
                }),
              ),
          ],
        );
      },
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final String stage;
  final int level;
  final int cash;
  final bool owned;
  final bool equipped;
  final String Function(int) money;
  final void Function(String id, String name, int price, int requiredLevel, bool owned) onAction;

  const _OutfitCard({
    required this.outfit,
    required this.stage,
    required this.level,
    required this.cash,
    required this.owned,
    required this.equipped,
    required this.money,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final id = outfit['id'] as String;
    final name = outfit['n'] as String? ?? id;
    final category = outfit['cat'] as String? ?? 'Tenue';
    final description = outfit['d'] as String? ?? '';
    final price = (outfit['price'] as num?)?.toInt() ?? 0;
    final requiredLevel = (outfit['rank'] as num?)?.toInt() ?? 1;
    final images = Map<String, dynamic>.from(outfit['images'] as Map);
    final imagePath = images[stage] as String? ?? images['young'] as String;
    final locked = level < requiredLevel;
    final insufficientFunds = !owned && cash < price;
    final disabled = locked || insufficientFunds || equipped;
    final label = equipped
        ? 'ÉQUIPÉE'
        : owned
            ? 'ÉQUIPER'
            : locked
                ? 'NIVEAU ${requiredLevel} REQUIS'
                : insufficientFunds
                    ? 'CAURIS INSUFFISANTS'
                    : price == 0
                        ? 'RÉCUPÉRER'
                        : 'ACHETER · ${money(price)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: V20.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: equipped ? Tk.acc.withOpacity(.8) : V20.cardBorder,
          width: equipped ? 2 : 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 174,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF14102B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                'assets/characters/rapper_001/${imagePath}',
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.toUpperCase(), style: V20Text.lab()),
                  const SizedBox(height: 4),
                  Text(name, style: V20Text.nm()),
                  const SizedBox(height: 6),
                  Text(description, style: V20Text.bs()),
                  const SizedBox(height: 8),
                  Text('Niveau requis : ${requiredLevel}', style: V20Text.bs()),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: label,
                      compact: true,
                      arrow: false,
                      style: equipped ? GameButtonStyle.ghost : GameButtonStyle.primary,
                      onPressed: disabled
                          ? null
                          : () => onAction(id, name, price, requiredLevel, owned),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
