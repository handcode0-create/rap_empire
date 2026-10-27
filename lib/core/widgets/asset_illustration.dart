import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Photo locale d’un bien ; garde l’illustration SVG comme secours.
class AssetIllustration extends StatelessWidget {
  final String id;
  final double size;
  final double radius;
  const AssetIllustration(this.id, {super.key, this.size = 64, this.radius = 14});

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

  /// Photos Unsplash affichées par lien direct (licence Unsplash) ; l'illustration originale
  /// (tools/design/gen_patrimoine.py) sert de chargement et de secours hors ligne.
  static const _remote = <String, String>{
    'studiomeuble': '1702014859908-d48b9b844240',
    'villa': '1757524492552-d47a66a2b63e',
    'penthouse': '1776362355123-ca966d36e29c',
    'local': '1564227503787-ad186f508e6f',
    'immeuble': '1760235674447-fe0cc115b697',
    'scooter': '1554223789-df81106a45ed',
    'suv': '1757922589576-129377dadac9',
    'berline': '1674719645138-c3fd1aaf8307',
    'chaine': '1635767798638-3e25273a8236',
    'bracelet': '1639065643006-e217c4fee12e',
    'diamantrose': '1772047678465-b786569c7c64',
    'cabinepro': '1544719576-0b52abab3d03',
    'regie': '1762952805560-130ccc74c3fa',
  };

  Widget _vector() => SvgPicture.asset('assets/patrimoine/$id.svg', fit: BoxFit.cover, semanticsLabel: 'Illustration du bien');

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
    'studiomeuble':
        '<rect x="16" y="40" width="68" height="40" rx="4" fill="#3A1B52" stroke="#FFC83D" stroke-width="4"/><path d="M12 42 50 18l38 24" fill="none" stroke="#F43F9D" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/><rect x="26" y="52" width="16" height="14" fill="#3CD6F2"/><rect x="58" y="52" width="16" height="28" fill="#8B5CF6"/>',
    'villa':
        '<path d="M10 80V46l22-14 18 10 18-10 22 14v34z" fill="#3A1B52" stroke="#FFC83D" stroke-width="4" stroke-linejoin="round"/><path d="M18 58h14v12H18zm50 0h14v12H68zm-26 6h16v16H42z" fill="#3CD6F2"/><path d="M6 88q12-6 24 0t24 0 24 0 12 0" fill="none" stroke="#3CD6F2" stroke-width="3"/>',
    'penthouse':
        '<rect x="30" y="14" width="40" height="72" fill="#3A1B52" stroke="#8B5CF6" stroke-width="4"/><rect x="22" y="14" width="56" height="10" fill="#F43F9D"/><path d="M38 34h8m8 0h8M38 46h8m8 0h8M38 58h8m8 0h8M38 70h8m8 0h8" stroke="#FFC83D" stroke-width="5" stroke-linecap="round"/>',
    'local':
        '<rect x="14" y="40" width="72" height="42" fill="#3A1B52" stroke="#FFC83D" stroke-width="4"/><path d="M10 40h80l-6-18H16z" fill="#F43F9D" stroke="#FFC83D" stroke-width="3" stroke-linejoin="round"/><rect x="24" y="52" width="26" height="30" fill="#3CD6F2"/><rect x="58" y="52" width="20" height="14" fill="#8B5CF6"/>',
    'immeuble':
        '<rect x="20" y="12" width="60" height="74" fill="#3A1B52" stroke="#3CD6F2" stroke-width="4"/><path d="M30 24h10m10 0h10m-30 14h10m10 0h10M30 52h10m10 0h10M30 66h10m10 0h10" stroke="#FFC83D" stroke-width="5" stroke-linecap="round"/><rect x="43" y="72" width="14" height="14" fill="#F43F9D"/>',
    'scooter':
        '<circle cx="26" cy="70" r="11" fill="none" stroke="#FFC83D" stroke-width="5"/><circle cx="76" cy="70" r="11" fill="none" stroke="#FFC83D" stroke-width="5"/><path d="M26 70h22l12-28h-8m8 0 6-14h10M44 70h32" fill="none" stroke="#F43F9D" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>',
    'suv':
        '<path d="M10 64V48l10-6 12-16h36l12 16 10 6v16z" fill="#3A1B52" stroke="#3CD6F2" stroke-width="4" stroke-linejoin="round"/><path d="M34 30h14v14H26zm20 0h12l8 14H54z" fill="#3CD6F2" fill-opacity=".7"/><circle cx="30" cy="68" r="9" fill="#14102B" stroke="#FFC83D" stroke-width="4"/><circle cx="72" cy="68" r="9" fill="#14102B" stroke="#FFC83D" stroke-width="4"/>',
    'berline':
        '<path d="M8 62c0-8 6-10 14-12l10-14h36l14 14c8 2 10 6 10 12z" fill="#3A1B52" stroke="#FFC83D" stroke-width="4" stroke-linejoin="round"/><path d="M34 40h16v12H26zm22 0h10l8 12H56z" fill="#8B5CF6"/><circle cx="28" cy="66" r="8" fill="#14102B" stroke="#F43F9D" stroke-width="4"/><circle cx="72" cy="66" r="8" fill="#14102B" stroke="#F43F9D" stroke-width="4"/>',
    'chaine':
        '<path d="M22 20q28 66 56 0" fill="none" stroke="#B6B0DD" stroke-width="6" stroke-linecap="round" stroke-dasharray="1 9"/><circle cx="50" cy="66" r="10" fill="#B6B0DD" stroke="#F8F7FF" stroke-width="3"/>',
    'bracelet':
        '<ellipse cx="50" cy="52" rx="30" ry="24" fill="none" stroke="#B6B0DD" stroke-width="9"/><ellipse cx="50" cy="52" rx="30" ry="24" fill="none" stroke="#F8F7FF" stroke-width="2" stroke-dasharray="3 6"/><circle cx="50" cy="28" r="6" fill="#3CD6F2"/>',
    'diamantrose':
        '<path d="m15 35 13-18h44l13 18-35 48z" fill="#FF6BB8" fill-opacity=".8" stroke="#FFC83D" stroke-width="4"/><path d="m15 35 35 3 35-3M28 17l22 21 22-21M50 38 50 83" fill="none" stroke="#F8F7FF" stroke-width="3"/>',
    'cabinepro':
        '<rect x="16" y="14" width="68" height="72" rx="6" fill="#3A1B52" stroke="#8B5CF6" stroke-width="4"/><path d="M26 28h48M26 40h48M26 52h48" stroke="#2B2459" stroke-width="5"/><circle cx="50" cy="66" r="9" fill="none" stroke="#3CD6F2" stroke-width="5"/><circle cx="50" cy="66" r="3" fill="#F43F9D"/>',
    'regie':
        '<rect x="10" y="40" width="80" height="40" rx="5" fill="#3A1B52" stroke="#8B5CF6" stroke-width="4"/><path d="M22 52v18m12-18v18m12-18v18m12-18v18m12-18v18" stroke="#FFC83D" stroke-width="4" stroke-linecap="round"/><rect x="26" y="14" width="48" height="20" rx="3" fill="#14102B" stroke="#3CD6F2" stroke-width="4"/>',
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
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox.square(
          dimension: size,
          child: _remote.containsKey(id)
              ? Image.network(
                  'https://images.unsplash.com/photo-${_remote[id]}?w=640&q=70&fit=crop&auto=format',
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) => p == null ? child : _vector(),
                  errorBuilder: (_, __, ___) => _vector(),
                )
              : _photos[id] == null
              ? _fallback()
              : Image.asset(
                  _photos[id]!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                ),
        ),
      );
}
