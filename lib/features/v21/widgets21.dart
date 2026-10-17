import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/game_toast.dart';

/// Composants communs aux écrans de la v21 (planches 21-*). Aucun calcul de jeu : tout vient du moteur.

/// Étiquette de section (.lab) : 11 px, majuscules.
class Lab21 extends StatelessWidget {
  final String text;
  final Color? color;
  const Lab21(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 4, bottom: 2), child: Text(text.toUpperCase(), style: V20Text.lab(color: color ?? V20.ink2)));
}

/// Pastille de choix (a.chip2) : contour 2 px, rose plein quand elle est choisie. Cible tactile de 48 px.
class Chip21 extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const Chip21(this.label, {super.key, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // Hauteur 48 px (16 + ligne de 16 + 16) sans étirer la pastille : elle prend la largeur de son texte.
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: selected ? V20.pinkBtn : null,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? V20.pinkBtn : const Color.fromRGBO(255, 255, 255, .16), width: 2),
            ),
            child: Text(label, style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: selected ? Tk.bg : V20.ink2)),
          ),
        ),
      );
}

/// Étapes de la création (.stp) : quatre segments, les faits en blanc, l'actuel en rose.
class Steps21 extends StatelessWidget {
  final int current; // 0 à 3
  const Steps21(this.current, {super.key});
  static const _names = ['Identité', 'Look', 'Style', 'Objectif'];

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 6, decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: i < current ? Tk.ink : (i == current ? Tk.acc : const Color.fromRGBO(139, 92, 246, .45)))),
              const SizedBox(height: 4),
              Text(_names[i].toUpperCase(), style: V20Text.poppins(size: 10, line: 12, weight: FontWeight.w700, color: i <= current ? Tk.ink : V20.ink2, spacing: .4)),
            ]),
          ),
        ],
      ]);
}

/// Ligne « libellé  valeur » d'une fiche.
class KeyVal extends StatelessWidget {
  final String k, v;
  final Color? color;
  final bool bold;
  const KeyVal(this.k, this.v, {super.key, this.color, this.bold = true});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(k, style: V20Text.bs(color: V20.ink2))),
          const SizedBox(width: 12),
          Flexible(child: Text(v, textAlign: TextAlign.end, style: V20Text.poppins(size: 14, line: 18, weight: bold ? FontWeight.w700 : FontWeight.w400, color: color ?? Tk.ink))),
        ]),
      );
}

/// Ligne de conséquence : étiquette (Certain, Estimé, Incertain, Risque) puis le texte.
class Conseq21 extends StatelessWidget {
  final ConsequenceKind kind;
  final String text;
  const Conseq21(this.kind, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ConsequenceTag(kind),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: V20Text.bs(color: Tk.ink))),
        ]),
      );
}

/// Barre de relation ou de jauge : libellé à gauche, barre, valeur.
class Gauge21 extends StatelessWidget {
  final String label;
  final num value; // 0 à 100
  final Color color;
  final double labelWidth;
  const Gauge21(this.label, this.value, {super.key, this.color = Tk.acc, this.labelWidth = 96});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: labelWidth, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: V20Text.nm())),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Stack(children: [
                Container(height: 10, color: const Color.fromRGBO(255, 255, 255, .1)),
                FractionallySizedBox(widthFactor: (value / 100).clamp(0, 1).toDouble(), child: Container(height: 10, color: color)),
              ]),
            ),
          ),
          SizedBox(width: 38, child: Text('${value.round()}', textAlign: TextAlign.end, style: V20Text.baloo(size: 16, line: 18))),
        ]),
      );
}

/// Toast d'erreur du moteur (codes de err21).
void toastErr(BuildContext context, String code) => showGameToast(context, errText21(code), kind: ToastKind.error);

void toastOk(BuildContext context, String msg) => showGameToast(context, msg, kind: ToastKind.success);

/// Lance une action du moteur depuis un écran : toast d'erreur si elle échoue, [then] si elle réussit.
Future<void> doAct(BuildContext context, WidgetRef ref, String name, [dynamic arg, VoidCallback? then, String? ok]) async {
  final e = await ref.read(game21Provider.notifier).act(name, arg);
  if (!context.mounted) return;
  if (e != null) {
    toastErr(context, e);
    return;
  }
  if (ok != null) toastOk(context, ok);
  then?.call();
}
