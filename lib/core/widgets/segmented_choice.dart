import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/v20.dart';

class SegmentItem {
  final String label;
  final bool on;
  final VoidCallback? onTap;
  const SegmentItem(this.label, {this.on = false, this.onTap});
}

/// Sélecteur à segments (.seg de rap.css) : 48 px, rayon 24, bordure 2 px ; le segment actif est plein (ink sur bg), en majuscules.
class SegmentedChoice extends StatelessWidget {
  final List<SegmentItem> items;
  const SegmentedChoice({super.key, required this.items});

  @override
  Widget build(BuildContext context) => Container(
        height: Tk.minTap,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Tk.line, width: 2)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Row(children: [
            for (final i in items)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i.on,
                  child: InkWell(
                    onTap: i.onTap,
                    child: Container(
                      alignment: Alignment.center,
                      color: i.on ? Tk.ink : Tk.s1,
                      child: Text(
                        i.on ? i.label.toUpperCase() : i.label,
                        textAlign: TextAlign.center,
                        style: V20Text.poppins(size: 13, line: 18, weight: i.on ? FontWeight.w800 : FontWeight.w400, color: i.on ? Tk.bg : V20.ink2),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      );
}
