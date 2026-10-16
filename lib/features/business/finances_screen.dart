import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/stat_kpi.dart';
import '../../domain/rules.dart';

/// Finances (09.5) : cash en caisse, revenus et dépenses par catégorie, lus dans le registre (cat de game.js, cC* de la vue).
/// Le contrat de label (avance, part) n'est pas encore porté : sa ligne, masquée dans la planche sans contrat, n'apparaît pas.
class FinancesScreen extends ConsumerWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    int c(String k) => s.cat[k] ?? 0;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text('FINANCES', style: V20Text.baloo(size: 28, line: 28)),
        const SizedBox(width: 8),
        Expanded(child: Text('DONNÉES DE DÉMONSTRATION · PARAMÈTRES PROVISOIRES', textAlign: TextAlign.end, style: V20Text.poppins(size: 10, line: 12, weight: FontWeight.w700, color: V20.hintGoldText, spacing: .8))),
      ]),
      const SizedBox(height: 8),
      KpiRow(children: [StatKpi(label: 'En caisse', value: fmt(s.cash), delta: 'cauris', big: true)]),
      const SizedBox(height: 8),
      Text('REVENUS', style: V20Text.lab()),
      _Row('Écoutes', '+${fmt(c('ecoutes'))}', revenue: true),
      _Row('Cachets', '+${fmt(c('cachets'))}', revenue: true),
      _Row('Missions', '+${fmt(c('mission'))}', revenue: true),
      _Row('Niveaux', '+${fmt(c('niveau'))}', revenue: true),
      const SizedBox(height: 8),
      Text('DÉPENSES', style: V20Text.lab()),
      _Row('Instrus', fmt(c('instru'))),
      _Row('Promo', fmt(c('promo'))),
      _Row('Matériel', fmt(c('materiel'))),
      _Row('Formations', fmt(c('formation'))),
    ]);
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool revenue;
  const _Row(this.label, this.value, {this.revenue = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromRGBO(255, 255, 255, .08), width: 1.5))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(label, style: V20Text.bm)),
          const SizedBox(width: 8),
          Text(value, style: V20Text.nm(color: revenue ? Tk.ok : Tk.ink)),
        ]),
      );
}
