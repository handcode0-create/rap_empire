import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

/// KPI (.kpi de v20.css) : libellé en majuscules, grande valeur Baloo 26 (40 avec [big]), variation facultative en vert.
class StatKpi extends StatelessWidget {
  final String label, value;
  final String? delta;
  final bool big;
  final Color? valueColor;
  const StatKpi({super.key, required this.label, required this.value, this.delta, this.big = false, this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(gradient: V20.surface, borderRadius: BorderRadius.circular(Tk.rCard), border: Border.all(color: V20.kpiBorder, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.lab()),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.baloo(size: big ? 40 : 26, line: big ? 40 : 28, color: valueColor ?? Tk.ink)),
          if (delta != null) ...[
            const SizedBox(height: 2),
            Text(delta!, style: V20Text.poppins(size: 11, line: 14, weight: FontWeight.w700, color: Tk.ok)),
          ],
        ]),
      );
}
