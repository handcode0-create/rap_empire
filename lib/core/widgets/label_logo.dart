import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Identité vectorielle locale du label fictif Bakoma Sound Records.
class LabelLogo extends StatelessWidget {
  final double size;
  const LabelLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Logo Bakoma Sound Records',
        child: SizedBox.square(
          dimension: size,
          child: Stack(alignment: Alignment.center, children: [
            SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><linearGradient id="g" x2="1" y2="1"><stop stop-color="#F43F9D"/><stop offset="1" stop-color="#8B5CF6"/></linearGradient></defs><rect width="100" height="100" rx="24" fill="#14102B"/><path d="M50 10 89 33v34L50 90 11 67V33z" fill="url(#g)" stroke="#FFC83D" stroke-width="3"/><circle cx="50" cy="50" r="23" fill="#14102B"/><path d="M35 70h30" stroke="#3CD6F2" stroke-width="3" stroke-linecap="round"/></svg>',
              width: size,
              height: size,
            ),
            Text('BSR',
                style: TextStyle(
                    color: const Color(0xFFF8F7FF),
                    fontSize: size * .2,
                    fontWeight: FontWeight.w800)),
          ]),
        ),
      );
}
