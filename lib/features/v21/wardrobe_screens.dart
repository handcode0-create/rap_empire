import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/character_view.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import '../../domain/v21/view21.dart';
import 'start_screens.dart';
import 'widgets21.dart';

/// Garde-robe à tenues préfabriquées : liste (21-W1), fiche d'une tenue (21-W2), confirmation d'achat (21-W3).
/// [PROPOSÉ, à valider] Les aperçus utilisent le personnage 2D créé par le joueur (coiffure et teint conservés). Les règles d’achat restent dans wardrobe21.dart et le moteur.

num _n(dynamic x) => (x ?? 0) as num;
J _m(dynamic x) => x as J;

/// Illustration d'une tenue (chemin du résolveur). Absente ou illisible : avatar provisoire du joueur, jamais de chemin cassé.
class OutfitImage extends StatelessWidget {
  final J s;
  final String? path;
  final double width, height;
  final String label, mood;
  final String? outfitId;
  /// Aperçu d'une autre coiffure ou d'autres tatouages que ceux du joueur (null = ceux du joueur).
  final String? hair;
  final Map<String, String>? tats;
  const OutfitImage(this.s, {super.key, required this.path, required this.width, required this.height, required this.label, this.mood = 'smile', this.outfitId, this.hair, this.tats});

  @override
  Widget build(BuildContext context) {
    Widget fallback() {
      final ap = _m(s['ap']);
      final top = <String, String>{
        'OUTFIT_001': 'hoodie', 'OUTFIT_002': 'hoodie', 'OUTFIT_003': 'bomber',
        'OUTFIT_004': 'bomber', 'OUTFIT_005': 'hoodie', 'OUTFIT_006': 'hoodie',
        'OUTFIT_007': 'bomber', 'OUTFIT_008': 'bomber', 'OUTFIT_009': 'hoodie',
      }[outfitId] ?? (ap['top'] as String? ?? 'hoodie');
      return CharacterView(who: 'me_${ap['hair'] ?? 'hitwist'}_${top}_${ap['skin'] ?? '3'}',
        mood: mood == 'smile' ? 'smile' : 'cool', crop: 'torso', width: width * .94, height: height * .94);
    }
    // Illustration en calques : corps de la tenue, coiffure, tatouages, accessoires de tête. L'image complète reste le secours.
    final layers = outfitId == null || path == null || !path!.toLowerCase().endsWith('.svg')
        ? null
        : layerPaths21(s, outfitId: outfitId, variant: path!.contains('/mature/') ? 'mature' : 'young', hair: hair, tats: tats);
    if (layers != null) {
      return SizedBox(
        width: width,
        height: height,
        child: Semantics(
          label: label,
          image: true,
          child: ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              child: SizedBox(width: 300, height: 640, child: Stack(fit: StackFit.expand, children: [
                for (var i = 0; i < layers.length; i++)
                  SvgPicture.asset(layers[i], fit: BoxFit.contain, alignment: Alignment.bottomCenter, placeholderBuilder: i == 0 ? (_) => Center(child: fallback()) : null),
              ])),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: path == null
          ? Center(
              child: outfitId != null
                  ? fallback()
                  : PlayerAvatar(s, mood: mood, height: height * .8),
            )
          : path!.toLowerCase().endsWith('.svg')
              ? SvgPicture.asset(
                  path!,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  semanticsLabel: label,
                  placeholderBuilder: (_) => Center(child: fallback()),
                )
              : Image.asset(
                  path!,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  semanticLabel: label,
                  errorBuilder: (_, error, __) {
                    debugPrint('OutfitImage: chargement impossible de $path : $error');
                    return Center(child: fallback());
                  },
                ),
    );
  }
}

/// Avatar du joueur dans sa tenue équipée (variante jeune ou mature selon le rang). Look non couvert ou image absente :
/// avatar SVG provisoire, avec l'humeur demandée.
class EquippedAvatar extends StatelessWidget {
  final J s;
  final double width, height;
  final String mood;
  const EquippedAvatar(this.s, {super.key, required this.width, required this.height, this.mood = 'smile'});

  @override
  Widget build(BuildContext context) =>
      OutfitImage(s, path: resolveLook21(s).path, outfitId: resolveLook21(s).outfit, width: width, height: height, label: 'Ton rappeur dans sa tenue équipée', mood: mood);
}

/// Visage du joueur pour les photos de profil rondes (réseaux) : l'avatar équipé, recadré sur la tête (x 70 à 230, y 0 à 160 du dessin 300 × 640).
class PlayerFace21 extends StatelessWidget {
  final J s;
  final double size;
  const PlayerFace21(this.s, {super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final w = size * 300 / 160, h = size * 640 / 160;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          minHeight: 0,
          maxWidth: w,
          maxHeight: h,
          child: Transform.translate(offset: Offset(-70 * size / 160, 0), child: EquippedAvatar(s, width: w, height: h)),
        ),
      ),
    );
  }
}

/// Buste du joueur dans sa tenue du moment, qui remplit l'espace donné (publications, résultats). La largeur fixe l'échelle : 260 unités du dessin 300 × 640.
class PlayerBust21 extends StatelessWidget {
  final J s;
  final String mood;
  const PlayerBust21(this.s, {super.key, this.mood = 'smile'});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final u = c.maxWidth / 260;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0,
            minHeight: 0,
            maxWidth: 300 * u,
            maxHeight: 640 * u,
            child: Transform.translate(offset: Offset(-20 * u, 0), child: EquippedAvatar(s, width: 300 * u, height: 640 * u, mood: mood)),
          ),
        );
      });
}

String _price(Map<String, dynamic> o) => (o['price'] as num) == 0 ? 'Offerte' : '${fmt21(o['price'] as num)} cauris';

String _cond(Map<String, dynamic> o) => (o['rank'] as num) > 1 ? 'Rang N${o['rank']} requis' : 'Aucune condition';

// ---------------------------------------------------------------------------------------------------------------------
// 21-W1 Garde-robe
// ---------------------------------------------------------------------------------------------------------------------

class GardeRobeScreen extends ConsumerStatefulWidget {
  const GardeRobeScreen({super.key});
  @override
  ConsumerState<GardeRobeScreen> createState() => _GardeRobeState();
}

class _GardeRobeState extends ConsumerState<GardeRobeScreen> {
  /// Filtre de catégorie (null = toutes) ; « Possédées » montre l'inventaire.
  String? _cat;
  /// Onglet : 0 tenues, 1 coiffures, 2 tatouages.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final wd = _m(s['wd']);
    final owned = wd['owned'] as List;
    final look = resolveLook21(s);
    final eq = outfit21(wd['eq'] as String?);
    final mature = look.variant == 'mature';
    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: 'Garde-robe', step: 'W1', onBack: () => context.go('/profil')),
      const SizedBox(height: 12),
      const Align(alignment: Alignment.centerLeft, child: GameTag('Style 2D V21 · aperçus adaptés', style: GameTagStyle.outline)),
      const SizedBox(height: 8),
      GameCard(
        child: Column(children: [
          OutfitImage(s, path: look.path, width: 220, height: 330, label: 'Ton rappeur dans sa tenue équipée'),
          const SizedBox(height: 8),
          Text((eq?['n'] ?? '—') as String, style: V20Text.dm(size: 24)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GameTag(mature ? 'Mature' : 'Jeune', style: GameTagStyle.accent),
            const SizedBox(width: 8),
            GameTag('${owned.length} / ${Wardrobe21.outfits.length} tenues'),
          ]),
          const SizedBox(height: 6),
          Text(
              mature
                  ? 'Variante mature active'
                  : 'Encore ${Wardrobe21.matureRank - rankOf(s)} rang(s) avant la variante mature · N${rankOf(s)} aujourd\'hui',
              style: V20Text.bs(),
              textAlign: TextAlign.center),
        ]),
      ),
      if (look.fallback != null) ...[
        const SizedBox(height: 8),
        const GameHint(icon: 'info', text: 'Illustration manquante pour cette variante : avatar provisoire affiché.', warn: true),
      ],
      const SizedBox(height: 12),
      _WardrobeTabs(_tab, (i) => setState(() => _tab = i)),
      const SizedBox(height: 12),
      if (_tab == 1) _CosmeticsTab(s, tattoo: false, key: const ValueKey('coiffures'))
      else if (_tab == 2) _CosmeticsTab(s, tattoo: true, key: const ValueKey('tatouages'))
      else ...[
      Text('TENUES · ${Wardrobe21.outfits.length} PIÈCES', style: V20Text.lab()),
      const SizedBox(height: 8),
      SizedBox(
        height: 48,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final c in <String?>[null, 'Possédées', ...Wardrobe21.categories])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c ?? 'Toutes', style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: _cat == c ? Tk.bg : Tk.ink)),
                selected: _cat == c,
                selectedColor: Tk.gold,
                backgroundColor: Tk.s1,
                side: BorderSide(color: _cat == c ? Tk.gold : Tk.line),
                showCheckmark: false,
                onSelected: (_) => setState(() => _cat = c),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - 8) / 2;
        final list = Wardrobe21.outfits.where((o) => _cat == null || (_cat == 'Possédées' ? owned.contains(o['id']) : o['cat'] == _cat)).toList();
        if (list.isEmpty) return Text('Aucune tenue dans cette catégorie pour l\'instant.', style: V20Text.bs());
        return Wrap(spacing: 8, runSpacing: 8, children: [
          for (final o in list) SizedBox(width: w, child: _OutfitCard(s, o)),
        ]);
      }),
      ],
    ]);
  }
}

class _WardrobeTabs extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  const _WardrobeTabs(this.tab, this.onTab);

  @override
  Widget build(BuildContext context) => Row(children: [
        for (final (i, l) in const ['Tenues', 'Coiffures', 'Tatouages'].indexed)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
              child: Semantics(
                button: true,
                selected: tab == i,
                label: l,
                child: GestureDetector(
                  key: ValueKey('onglet-$l'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTab(i),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tab == i ? Tk.tint : Tk.s1,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: tab == i ? Tk.acc : Tk.line, width: 2),
                    ),
                    child: Text(l.toUpperCase(), style: V20Text.poppins(size: 12, line: 16, weight: FontWeight.w800, color: tab == i ? Tk.ink : Tk.ink2)),
                  ),
                ),
              ),
            ),
          ),
      ]);
}

/// Zone de l'image 300 × 640 à montrer pour chaque aperçu (x, y, largeur, hauteur).
const _cropHead = Rect.fromLTWH(60, -14, 180, 214);
const _cropFace = Rect.fromLTWH(78, 14, 144, 170);
const _cropHands = Rect.fromLTWH(18, 318, 264, 128);

/// Aperçu recadré du rappeur, avec la coiffure et les tatouages demandés (ceux du joueur par défaut).
class LookCrop21 extends StatelessWidget {
  final J s;
  final Rect crop;
  final double width, height;
  final String? hair;
  final Map<String, String>? tats;
  final String label;
  const LookCrop21(this.s, {super.key, required this.crop, required this.width, required this.height, this.hair, this.tats, required this.label});

  @override
  Widget build(BuildContext context) {
    final look = resolveLook21(s);
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: crop.width,
          height: crop.height,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: 0,
              minHeight: 0,
              maxWidth: 300,
              maxHeight: 640,
              child: Transform.translate(
                offset: Offset(-crop.left, -crop.top),
                child: OutfitImage(s,
                    path: look.path, outfitId: look.outfit, width: 300, height: 640, label: label, hair: hair, tats: tats),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _cosCond(Map<String, dynamic> o) => (o['rank'] as num) > 1 ? 'Rang N${o['rank']} requis' : 'Aucune condition';

/// Onglets Coiffures et Tatouages : aperçu sur le rappeur avant achat, achat (confirmation dès 15 000 cauris), équipement.
class _CosmeticsTab extends ConsumerStatefulWidget {
  final J s;
  final bool tattoo;
  const _CosmeticsTab(this.s, {super.key, required this.tattoo});
  @override
  ConsumerState<_CosmeticsTab> createState() => _CosmeticsTabState();
}

class _CosmeticsTabState extends ConsumerState<_CosmeticsTab> {
  String? _sel;
  /// Zone de tatouage filtrée (null = toutes).
  String? _zone;

  List<Map<String, dynamic>> get _items => widget.tattoo ? Wardrobe21.tattoos : Wardrobe21.hairs;

  Rect _cropOf(Map<String, dynamic> o) => !widget.tattoo ? _cropHead : (o['zone'] == 'mains' ? _cropHands : _cropFace);

  /// Apparence montrée pour [o] : la coiffure choisie, ou le tatouage ajouté à ceux du joueur.
  (String?, Map<String, String>?) _look(Map<String, dynamic> o) =>
      widget.tattoo ? (null, {...tattoosOf21(widget.s), o['zone'] as String: o['id'] as String}) : (o['id'] as String, null);

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final id = _sel ?? (widget.tattoo ? Wardrobe21.tattoos.first['id'] : hairOf21(s)) as String;
    final o = cosmetic21(id)!;
    final own = cosmeticOwned21(s, id), eq = cosmeticEquipped21(s, id);
    final locked = !own && rankOf(s) < (o['rank'] as num);
    final poor = !own && !locked && _n(s['cash']) < (o['price'] as num);
    final price = (o['price'] as num) == 0 ? 'Offerte' : '${fmt21(o['price'] as num)} cauris';
    final (h, t) = _look(o);
    final list = _items.where((e) => !widget.tattoo || _zone == null || e['zone'] == _zone).toList();
    final countOwned = widget.tattoo ? tattoosOwned21(s).length : hairsOwned21(s).length;
    final kind = widget.tattoo ? 'tatouage' : 'coiffure';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: const Color.fromRGBO(255, 255, 255, .05),
                child: LookCrop21(s,
                    key: const ValueKey('apercu-look'),
                    crop: _cropOf(o),
                    width: 300,
                    height: widget.tattoo && o['zone'] == 'mains' ? 150 : 250,
                    hair: h,
                    tats: t,
                    label: 'Aperçu : ${o['n']}'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(o['n'] as String, style: V20Text.dm(size: 22)),
          const SizedBox(height: 4),
          Text(o['d'] as String, style: V20Text.bs(color: Tk.ink)),
          const SizedBox(height: 8),
          if (widget.tattoo) KeyVal('Zone', Wardrobe21.tattooZones[o['zone']]!),
          KeyVal('Prix', price),
          KeyVal('Condition', _cosCond(o)),
          if (!own) KeyVal('Cash après achat', '${fmt21(_n(s['cash']) - (o['price'] as num))} cauris'),
        ]),
      ),
      const SizedBox(height: 12),
      if (eq && !widget.tattoo)
        const GameTag('Coiffure équipée', style: GameTagStyle.accent)
      else if (eq)
        PrimaryButton(
            label: 'Retirer ce tatouage',
            style: GameButtonStyle.ghost,
            onPressed: () => doAct(context, ref, 'tclear', o['zone'], null, 'Tatouage masqué'))
      else if (own)
        PrimaryButton(label: 'Équiper', onPressed: () => doAct(context, ref, 'ceq', id, null, '${kind[0].toUpperCase()}${kind.substring(1)} équipé${widget.tattoo ? '' : 'e'} : ${o['n']}'))
      else if (locked)
        GameHint(icon: 'lock', text: '${_cosCond(o)} · tu es N${rankOf(s)}.', warn: true)
      else ...[
        PrimaryButton(label: 'Acheter · $price', onPressed: poor ? null : () => _buy(context, s, o)),
        if (poor) ...[
          const SizedBox(height: 8),
          const GameHint(icon: 'info', text: 'Cash insuffisant', warn: true),
        ],
      ],
      const SizedBox(height: 16),
      Text(widget.tattoo ? 'TATOUAGES · $countOwned / ${Wardrobe21.tattoos.length}' : 'COIFFURES · $countOwned / ${Wardrobe21.hairs.length}', style: V20Text.lab()),
      const SizedBox(height: 8),
      if (widget.tattoo) ...[
        SizedBox(
          height: 48,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final z in <String?>[null, ...Wardrobe21.tattooZones.keys])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(z == null ? 'Toutes' : Wardrobe21.tattooZones[z]!, style: V20Text.poppins(size: 13, line: 16, weight: FontWeight.w700, color: _zone == z ? Tk.bg : Tk.ink)),
                  selected: _zone == z,
                  selectedColor: Tk.gold,
                  backgroundColor: Tk.s1,
                  side: BorderSide(color: _zone == z ? Tk.gold : Tk.line),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _zone = z),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 8),
      ],
      LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - 8) / 2;
        return Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in list)
            SizedBox(width: w, child: _CosmeticCard(s, e, selected: e['id'] == id, preview: _look(e), crop: _cropOf(e), onTap: () => setState(() => _sel = e['id'] as String))),
        ]);
      }),
    ]);
  }

  /// En dessous de 15 000 cauris l'achat est direct ; au-delà, feuille de confirmation comme pour les tenues.
  Future<void> _buy(BuildContext context, J s, Map<String, dynamic> o) async {
    final id = o['id'] as String;
    final what = widget.tattoo ? 'Tatouage' : 'Coiffure';
    final ok = '$what acheté${widget.tattoo ? '' : 'e'} et équipé${widget.tattoo ? '' : 'e'} : ${o['n']}';
    if ((o['price'] as num) < Wardrobe21.confirmAt) {
      await doAct(context, ref, 'cbuy', id, null, ok);
      return;
    }
    final notifier = ref.read(game21Provider.notifier);
    final e = await notifier.act('cask', id);
    if (!context.mounted) return;
    if (e != null) return toastErr(context, e);
    final yes = await confirmSheet(context,
        title: o['n'] as String,
        body: 'Prix : ${fmt21(o['price'] as num)} cauris. Cash après achat : ${fmt21(_n(s['cash']) - (o['price'] as num))} cauris.',
        action: 'Confirmer l\'achat');
    if (!context.mounted) return;
    if (!yes) {
      await notifier.act('ccancel');
      return;
    }
    await doAct(context, ref, 'cconfirm', null, null, ok);
  }
}

class _CosmeticCard extends StatelessWidget {
  final J s;
  final Map<String, dynamic> o;
  final bool selected;
  final (String?, Map<String, String>?) preview;
  final Rect crop;
  final VoidCallback onTap;
  const _CosmeticCard(this.s, this.o, {required this.selected, required this.preview, required this.crop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final id = o['id'] as String;
    final own = cosmeticOwned21(s, id), eq = cosmeticEquipped21(s, id);
    final locked = !own && rankOf(s) < (o['rank'] as num);
    final (tag, style) = eq
        ? ('Équipé', GameTagStyle.accent)
        : own
            ? ('Possédé', GameTagStyle.ok)
            : locked
                ? ('Rang N${o['rank']}', GameTagStyle.outline)
                : ((o['price'] as num) == 0 ? 'Offerte' : '${fmt21(o['price'] as num)} cauris', GameTagStyle.normal);
    return GameCard(
      key: ValueKey('cos-$id'),
      padding: const EdgeInsets.all(8),
      selected: selected,
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: locked ? .5 : 1,
            child: LookCrop21(s, crop: crop, width: double.infinity, height: 110, hair: preview.$1, tats: preview.$2, label: o['n'] as String),
          ),
        ),
        const SizedBox(height: 8),
        Text(o['n'] as String, style: V20Text.nm()),
        const SizedBox(height: 4),
        GameTag(tag, style: style),
      ]),
    );
  }
}

class _OutfitCard extends ConsumerWidget {
  final J s;
  final Map<String, dynamic> o;
  const _OutfitCard(this.s, this.o);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wd = _m(s['wd']);
    final id = o['id'] as String;
    final own = (wd['owned'] as List).contains(id), eq = wd['eq'] == id, ind = outfitUnavailable21(o);
    final locked = !own && !ind && rankOf(s) < (o['rank'] as num);
    final young = (o['images'] as Map)['young'] as String?;
    final (tag, style) = eq
        ? ('Équipée', GameTagStyle.accent)
        : own
            ? ('Possédée', GameTagStyle.ok)
            : ind
                ? ('Indisponible', GameTagStyle.outline)
                : locked
                    ? ('Rang N${o['rank']}', GameTagStyle.outline)
                    : (_price(o), GameTagStyle.normal);
    return GameCard(
      padding: const EdgeInsets.all(8),
      onTap: () => doAct(context, ref, 'osel', id, () => context.go('/profil/garde-robe/tenue')),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(color: const Color.fromRGBO(255, 255, 255, .05), borderRadius: BorderRadius.circular(12)),
          child: Opacity(
            opacity: ind || locked ? .5 : 1,
            child: OutfitImage(s, path: young == null ? null : Wardrobe21.base + young, outfitId: id, width: 100, height: 150, label: o['n'] as String),
          ),
        ),
        const SizedBox(height: 8),
        Text(o['n'] as String, style: V20Text.nm()),
        const SizedBox(height: 4),
        GameTag(tag, style: style),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------------
// 21-W2 Fiche d'une tenue (aperçus jeune et mature, achat, équipement) · 21-W3 confirmation d'achat
// ---------------------------------------------------------------------------------------------------------------------

class TenueScreen extends ConsumerWidget {
  const TenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());
    final wd = _m(s['wd']);
    final o = outfit21(wd['sel'] as String?) ?? outfit21(wd['eq'] as String?)!;
    final id = o['id'] as String;
    final own = (wd['owned'] as List).contains(id), eq = wd['eq'] == id, ind = outfitUnavailable21(o);
    final locked = !own && !ind && rankOf(s) < (o['rank'] as num);
    final poor = !own && !ind && !locked && _n(s['cash']) < (o['price'] as num);
    final im = o['images'] as Map;
    String? img(String v) => im[v] == null ? null : Wardrobe21.base + (im[v] as String);
    final cur = resolveLook21(s, id).variant;

    Widget view(String v, String title) => Expanded(
          child: Column(children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, .05),
                  borderRadius: BorderRadius.circular(12),
                  border: cur == v ? Border.all(color: Tk.acc, width: 2) : null),
              child: OutfitImage(s, path: img(v), outfitId: id, width: 150, height: 230, label: '${o['n']}, $title', mood: v == 'mature' ? 'cool' : 'smile'),
            ),
            const SizedBox(height: 4),
            Text(title, style: V20Text.bs()),
            if (img(v) == null) const GameTag('Illustration manquante', style: GameTagStyle.outline),
          ]),
        );

    return ListView(padding: const EdgeInsets.all(16), children: [
      BackHeader(title: o['n'] as String, step: 'W2', onBack: () => context.go('/profil/garde-robe')),
      const SizedBox(height: 12),
      GameCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [view('young', 'Jeune'), const SizedBox(width: 8), view('mature', 'Mature')]),
          const SizedBox(height: 12),
          Text(o['d'] as String, style: V20Text.bs(color: Tk.ink)),
          const SizedBox(height: 8),
          KeyVal('Prix', _price(o)),
          KeyVal('Condition', _cond(o)),
          if (!own && !ind) KeyVal('Cash après achat', '${fmt21(_n(s['cash']) - (o['price'] as num))} cauris'),
        ]),
      ),
      const SizedBox(height: 12),
      if (eq)
        const GameTag('Tenue équipée', style: GameTagStyle.accent)
      else if (own)
        PrimaryButton(label: 'Équiper', onPressed: () => doAct(context, ref, 'oeqsel', null, () => context.go('/profil/garde-robe'), 'Tenue équipée : ${o['n']}'))
      else if (ind)
        const GameHint(icon: 'info', text: 'Tenue indisponible : une illustration manque.', warn: true)
      else if (locked)
        GameHint(icon: 'lock', text: '${_cond(o)} · tu es N${rankOf(s)}.', warn: true)
      else ...[
        PrimaryButton(
            label: 'Acheter · ${_price(o)}',
            onPressed: poor ? null : () => _buy(context, ref, s, o)),
        if (poor) ...[
          const SizedBox(height: 8),
          const GameHint(icon: 'info', text: 'Cash insuffisant', warn: true),
        ],
      ],
      const SizedBox(height: 8),
      PrimaryButton(label: 'Retour à la garde-robe', style: GameButtonStyle.ghost, onPressed: () => context.go('/profil/garde-robe')),
    ]);
  }

  /// En dessous de 15 000 cauris l'achat est direct ; à partir de là, feuille de confirmation (21-W3).
  Future<void> _buy(BuildContext context, WidgetRef ref, J s, Map<String, dynamic> o) async {
    final id = o['id'] as String;
    if ((o['price'] as num) < Wardrobe21.confirmAt) {
      await doAct(context, ref, 'obuy', id, null, 'Tenue achetée : ${o['n']}');
      return;
    }
    final notifier = ref.read(game21Provider.notifier);
    final e = await notifier.act('oask', id);
    if (!context.mounted) return;
    if (e != null) return toastErr(context, e);
    final ok = await confirmSheet(context,
        title: o['n'] as String,
        body: 'Prix : ${fmt21(o['price'] as num)} cauris. Cash après achat : ${fmt21(_n(s['cash']) - (o['price'] as num))} cauris.',
        action: 'Confirmer l\'achat');
    if (!context.mounted) return;
    if (!ok) {
      await notifier.act('ocancel');
      return;
    }
    await doAct(context, ref, 'oconfirm', null, null, 'Tenue achetée : ${o['n']}');
  }
}
