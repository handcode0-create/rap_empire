import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Photo locale d’un bien ; garde l’illustration SVG comme secours.
class AssetIllustration extends StatelessWidget {
  final String id;
  final double size;
  const AssetIllustration(this.id, {super.key, this.size = 64});

  static const _photos = <String, String>{
    'maison': 'assets/patrimoine/maison.jpg',
    'moto': 'assets/patrimoine/moto.jpg',
    'appart': 'assets/patrimoine/appartement.jpg',
    'homestudio': 'assets/patrimoine/home-studio.jpg',
    'terrain': 'assets/patrimoine/terrain.jpg',
    'voiture': 'assets/patrimoine/voiture.jpg',
    'bateau': 'assets/patrimoine/bateau.jpg',
    'bague': 'assets/patrimoine/bague.jpg',
    'montre': 'assets/patrimoine/montre.jpg',
    'diamant': 'assets/patrimoine/diamant.jpg',
  };

  static const _art = <String, String>{
    'moto':
        '<circle cx="25" cy="68" r="13" fill="none" stroke="#FFC83D" stroke-width="5"/><circle cx="77" cy="68" r="13" fill="none" stroke="#FFC83D" stroke-width="5"/><path d="M25 68 42 42h17l18 26H48l-8-16m18-10 9-9h9" fill="none" stroke="#F43F9D" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/><path d="M43 42h18" stroke="#3CD6F2" stroke-width="5" stroke-linecap="round"/>',
    'appart':
        '<path d="m18 45 32-27 32 27v36H18z" fill="#3A1B52" stroke="#FFC83D" stroke-width="4"/><path d="M42 81V58h16v23M28 49h12v12H28zm32 0h12v12H60z" fill="#3CD6F2"/><path d="M12 46 50 14l38 32" fill="none" stroke="#F43F9D" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>',
    'homestudio':
        '<path d="M18 20h64v62H18z" fill="#3A1B52" stroke="#8B5CF6" stroke-width="4"/><circle cx="50" cy="48" r="17" fill="none" stroke="#3CD6F2" stroke-width="6"/><circle cx="50" cy="48" r="5" fill="#FFC83D"/><path d="M35 73h30" stroke="#F43F9D" stroke-width="5" stroke-linecap="round"/>',
    'terrain':
        '<path d="M12 76 38 38l14 19 13-28 23 47z" fill="#3A1B52" stroke="#3CD6F2" stroke-width="4" stroke-linejoin="round"/><path d="M12 77h76" stroke="#FFC83D" stroke-width="5" stroke-linecap="round"/><circle cx="72" cy="23" r="8" fill="#F43F9D"/>',
    'voiture':
        '<path d="M16 61h68l-7-22H29z" fill="#3A1B52" stroke="#F43F9D" stroke-width="4"/><path d="M28 40 37 27h28l11 13" fill="#3CD6F2" stroke="#FFC83D" stroke-width="3"/><circle cx="31" cy="66" r="8" fill="#14102B" stroke="#FFC83D" stroke-width="4"/><circle cx="69" cy="66" r="8" fill="#14102B" stroke="#FFC83D" stroke-width="4"/>',
    'bateau':
        '<path d="M15 56h70L69 78H32z" fill="#3A1B52" stroke="#3CD6F2" stroke-width="4"/><path d="M48 20v36H27zM54 27v29h21z" fill="#F43F9D" stroke="#FFC83D" stroke-width="3"/><path d="M18 84q10-7 20 0t20 0 20 0" fill="none" stroke="#3CD6F2" stroke-width="4"/>',
    'bague':
        '<path d="M29 48 39 24h22l10 24-21 32z" fill="#3A1B52" stroke="#FFC83D" stroke-width="5" stroke-linejoin="round"/><path d="m39 24 11 12 11-12M29 48h42" fill="none" stroke="#3CD6F2" stroke-width="4"/>',
    'montre':
        '<rect x="37" y="10" width="26" height="80" rx="8" fill="#3A1B52" stroke="#8B5CF6" stroke-width="4"/><circle cx="50" cy="50" r="22" fill="#14102B" stroke="#FFC83D" stroke-width="5"/><path d="M50 35v16l12 7" fill="none" stroke="#3CD6F2" stroke-width="4" stroke-linecap="round"/>',
    'diamant':
        '<path d="m15 35 13-18h44l13 18-35 48z" fill="#3CD6F2" fill-opacity=".7" stroke="#FFC83D" stroke-width="4"/><path d="m15 35 35 3 35-3M28 17l22 21 22-21M50 38 50 83" fill="none" stroke="#F8F7FF" stroke-width="3"/>',
  };

  Widget _fallback() => ColoredBox(
        color: const Color(0xFF1F1942),
        child: SvgPicture.string(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><linearGradient id="g" x2="1" y2="1"><stop stop-color="#2B2459"/><stop offset="1" stop-color="#14102B"/></linearGradient></defs><rect width="100" height="100" fill="url(#g)"/>${_art[id] ?? _art['terrain']}</svg>',
          fit: BoxFit.contain,
          semanticsLabel: 'Illustration du bien',
        ),
      );

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.square(
          dimension: size,
          child: _photos[id] == null
              ? _fallback()
              : Image.asset(
                  _photos[id]!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                ),
        ),
      );
}
