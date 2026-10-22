import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/character_view.dart';
import '../../core/widgets/portrait.dart';

/// Registre des personnages illustrés (assets/characters, générés par tools/design) et de leur poste.
/// Un nom affiché à l'écran retrouve toujours le même personnage ; sans illustration, un monogramme (jamais le visage d'un autre).
const castIllustrated21 = <String>{
  'djo', 'kore', 'orage', 'zaki', 'nadia', 'zamba', 'rosine', 'anselme', 'ayana', 'kzer', 'woro', 'sanko', 'ines', 'kadi', 'lina', 'sefa',
  'amara', 'yao', 'noe', 'teo', 'awa', 'bakary', 'liv', 'marius', 'kre', 'maze', 'benedicte', 'kofi', 'kaira', 'tito', 'lazuli', 'nadia-kolo',
  'solo', 'mika', 'salif', 'lea', 'seraphine', 'tamsir', 'desire', 'naya', 'sadia', 'malik', 'yele', 'tidjane', 'bako', 'sable', 'yaya',
};

/// Nom affiché → identifiant du personnage, avec son poste.
const castByName21 = <String, (String, String)>{
  'Djo Kéné': ('djo', 'Toi, rappeur'),
  'DJ Kôrô': ('kore', 'Producteur · Studio Kôrô'),
  'Madame Orage': ('orage', 'Directrice artistique · Bakoma Sound Records'),
  'Zaki Mbela': ('zaki', 'Rappeur · rival de Ndolo'),
  'Maya Tessé': ('nadia', 'Manager'),
  'Kouassi Zamba': ('zamba', "Promoteur · Festival Lagune d'Ambre"),
  'Ayana Dembé': ('ayana', 'Chanteuse afro-soul'),
  'Rosine Adjoua': ('rosine', 'Manager · presse et crise'),
  'Anselme Bayoko': ('anselme', 'Manager · négociation de contrats'),
  'Mika Soro': ('mika', 'Manager · développement et image'),
  'Salif Odjé': ('salif', 'Manager · concerts et tournées locales'),
  'Léa Sombré': ('lea', 'Manager · développement international'),
  'Séraphine Aboa': ('seraphine', 'Manager d\'élite · plan de carrière et crises majeures'),
  'Tamsir Koffi': ('tamsir', 'Beatmaker · afro-drill'),
  'Désiré Kpan': ('desire', 'Road manager'),
  'Naya Rêve': ('naya', 'Rap mélodique et R&B'),
  "K-Zer d'Mabaya": ('kzer', 'Rappeur · rival de Mabaya'),
  'K-Zer': ('kzer', 'Rappeur · rival de Mabaya'),
  'Kaïra Nox': ('kaira', 'Artiste · drill'),
  'Tito Brume': ('tito', 'Artiste · rap conscient'),
  'Lazuli': ('lazuli', 'Artiste · afro-soul'),
  'Nadia Kolo': ('nadia-kolo', 'Chanteuse · featuring'),
  'Sôlo Vance': ('solo', 'Artiste · trap'),
  'Sanko Beats': ('sanko', 'Producteur · Pont des Griots'),
  'Mister Wôrô': ('woro', "Producteur · Lagune d'Ambre"),
  'Awa Liméa': ('awa', 'Découvreuse · Aube Nouvelle'),
  'Bakary Fé': ('bakary', 'Fondateur · Ndolo Underground'),
  'Liv Sélou': ('liv', 'Porte-parole · Sélène Indie Collective'),
  'Marius Argent': ('marius', 'Directeur · Vague Argentée'),
  'Jonas Kré': ('kre', 'Directeur artistique · Black Lagune'),
  'Prof Mazé': ('maze', 'Fondateur · Lyrik Atelier'),
  'Bénédicte Kassi': ('benedicte', 'Présidente · Ambre Music Group'),
  'Kofi Ndayé': ('kofi', 'Directeur export · Rythme Cardinal'),
  'Sadia Kouamé': ('sadia', 'Curatrice Ondéa · Drill de Bakoma'),
  'Malik Ebo': ('malik', 'Curateur Ondéa · Nuits de Lumbé'),
  'Yélé Dossou': ('yele', 'Curatrice Ondéa · Afro-soul Sélène'),
  'Tidjane Bah': ('tidjane', 'Curateur Ondéa · Nouveaux talents'),
  'Bako Flux': ('bako', 'Artiste · rap technique'),
  'Dr. Sable': ('sable', 'Artiste et producteur · afro-trap'),
  'Yaya Cendre': ('yaya', 'Chanteuse · soul'),
};

/// Identifiant illustré d'un nom (ou d'un identifiant), sinon null.
String? castId21(String nameOrId) {
  if (castIllustrated21.contains(nameOrId)) return nameOrId;
  final hit = castByName21[nameOrId.trim()];
  return hit != null && castIllustrated21.contains(hit.$1) ? hit.$1 : null;
}

String castRole21(String name) => castByName21[name.trim()]?.$2 ?? '';

String _initials(String n) => n.split(RegExp(r"[\s'’-]+")).where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase();

/// Portrait rond d'un personnage : illustration (tête ou buste) dans un anneau coloré, ou monogramme.
class CastAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String mood;
  final Color ring;
  const CastAvatar(this.name, {super.key, this.size = 48, this.mood = 'smile', this.ring = Tk.acc});
  @override
  Widget build(BuildContext context) {
    final id = castId21(name);
    if (id == null) return Portrait(_initials(name), size: size);
    return Semantics(
      image: true,
      label: name,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [ring, Tk.violet])),
        child: ClipOval(
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Tk.s2, Tk.deep])),
            child: OverflowBox(
              maxWidth: size * 1.25,
              maxHeight: size * 1.25,
              alignment: const Alignment(0, -.2),
              child: CharacterView(who: id, mood: mood, crop: 'head', width: size * 1.1, height: size * 1.1),
            ),
          ),
        ),
      ),
    );
  }
}
