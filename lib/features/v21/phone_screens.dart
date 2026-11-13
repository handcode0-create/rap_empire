import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/game21.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/v20.dart';
import '../../core/widgets/action_row.dart';
import '../../core/widgets/back_header.dart';
import '../../core/widgets/game_hint.dart';
import '../../core/widgets/game_tag.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/primary_glow_button.dart';
import '../../domain/v21/engine21.dart';
import '../../domain/v21/reg21.dart';
import 'widgets21.dart' show doAct;
import 'copyright_screens.dart' show PhoneInbox21, crPhone21;
import 'shell21.dart';

num _phoneN(dynamic value) => (value ?? 0) as num;

/// Première coque du téléphone : une vue centralisée des événements existants.
/// Les actions restent dans leurs écrans et leurs moteurs d'origine.
class PhoneScreen extends ConsumerWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(game21Provider).valueOrNull;
    if (s == null) return const Center(child: CircularProgressIndicator());

    final officialMessages = crPhone21(s);
    final concerts = cvView21(s);
    final invitations = concerts
        .where((offer) => offer['status'] == 'available')
        .toList()
      ..sort((a, b) => _phoneN(a['exp']).compareTo(_phoneN(b['exp'])));
    final accepted = concerts
        .where((offer) => offer['status'] == 'accepted')
        .toList();
    final acceptedCount = accepted.length;
    final wait = Reg21.concertEvery - (_phoneN(s['day']) - _phoneN(s['lastConcert'])).toInt();
    final manager = managerTier21(s);

    return Frame21(children: [
      BackHeader(title: 'Téléphone', onBack: () => context.go('/')),
      const SizedBox(height: 8),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: V20.tileIcon,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.smartphone_rounded, color: Colors.white, size: 29),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('RAP PHONE', style: V20Text.baloo(size: 23, line: 26)),
              Text('Ta carrière, tes contacts, tes messages.', style: V20Text.bs()),
            ]),
          ),
          const GameTag('V22'),
        ]),
      ),
      const SizedBox(height: 18),
      Text('BOÎTE DE RÉCEPTION', style: V20Text.lab()),
      const SizedBox(height: 8),
      if (officialMessages.isNotEmpty) PhoneInbox21(s),
      if (invitations.isEmpty && accepted.isEmpty && officialMessages.isEmpty)
        const GameHint(
          icon: 'info',
          text: 'Ta boîte de réception est vide. Les invitations et notifications importantes apparaîtront ici.',
        ),
      for (final offer in invitations)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            accent: GlassAccent.gold,
            halo: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Tk.gold.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.confirmation_number_rounded, color: Tk.gold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('INVITATION DE CONCERT', style: V20Text.lab(color: Tk.gold)),
                  Text(offer['title'] as String, style: V20Text.nm()),
                  Text(
                    '${offer['cityName']} · ${fmt21(_phoneN(offer['fee']))} cauris',
                    style: V20Text.bs(),
                  ),
                  Text('Réponse avant le jour ${offer['exp']}', style: V20Text.bs(color: V20.ink2)),
                ]),
              ),
              const Icon(Icons.mark_email_unread_rounded, color: Tk.gold),
              ]),
              const SizedBox(height: 10),
              if (acceptedCount < Cv21.maxAccepted)
                PrimaryGlowButton(
                  label: 'ACCEPTER L’INVITATION',
                  onPressed: () => doAct(context, ref, 'cvAccept', offer['id']),
                )
              else
                Text(
                  '3/3 concerts acceptés. Joue une date pour libérer un créneau.',
                  style: V20Text.bs(color: Tk.gold),
                ),
              const SizedBox(height: 6),
              PrimaryButton(
                label: 'REFUSER',
                style: GameButtonStyle.ghost,
                compact: true,
                centered: true,
                arrow: false,
                onPressed: () => doAct(context, ref, 'cvDecline', offer['id']),
              ),
            ]),
          ),
        ),
      if (accepted.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('CONCERTS ACCEPTÉS', style: V20Text.lab()),
        const SizedBox(height: 8),
        for (final offer in accepted)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              accent: GlassAccent.cyan,
              halo: false,
              onTap: () => context.go('/scene'),
              child: Row(children: [
                const Icon(Icons.event_available_rounded, color: Tk.cy, size: 25),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(offer['title'] as String, style: V20Text.nm()),
                  Text('${offer['cityName']} · Cachet ${fmt21(_phoneN(offer['fee']))} cauris', style: V20Text.bs()),
                  Text(wait > 0 ? 'Date jouable dans $wait jour(s)' : 'Date prête à être jouée', style: V20Text.bs(color: V20.ink2)),
                ])),
                const Icon(Icons.event_available_rounded, color: Tk.cy, size: 25),
              ]),
              const SizedBox(height: 8),
              if (wait > 0)
                GameTag('Prochaine date dans $wait j', style: GameTagStyle.outline)
              else
                PrimaryGlowButton(
                  label: 'JOUER LE CONCERT',
                  onPressed: () => doAct(context, ref, 'cvPlay', offer['id'], () => context.go('/scene/resultat')),
                ),
            ]),
          ),
      ],
      const SizedBox(height: 18),
      Text('RÉPERTOIRE', style: V20Text.lab()),
      const SizedBox(height: 8),
      GlassCard(
        halo: false,
        child: Column(children: [
          ActionRow(
            title: 'Manager',
            subtitle: manager == null ? 'Consulter les offres et contrats' : manager['n'] as String,
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/business/manager'),
          ),
          const Divider(color: Tk.line, height: 18),
          ActionRow(
            title: 'Labels et maisons de production',
            subtitle: 'Contrats, propositions et signatures',
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/business/labels'),
          ),
          const Divider(color: Tk.line, height: 18),
          ActionRow(
            title: 'Réseaux sociaux',
            subtitle: 'Lueur, Bakoz et Griot',
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/profil/reseau/social'),
          ),
          const Divider(color: Tk.line, height: 18),
          ActionRow(
            title: 'Famille et entourage',
            subtitle: 'Vie personnelle et foyer',
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/famille'),
          ),
          const Divider(color: Tk.line, height: 18),
          ActionRow(
            title: 'Médias et plateformes',
            subtitle: 'Ondéa, Klipo et Cauri Music',
            trailing: ActionRow.arrow(),
            onTap: () => context.go('/profil/reseau'),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Text(
        'Les invitations, dates acceptées et notifications sont reliées aux moteurs existants : aucune carrière parallèle ni seconde sauvegarde.',
        style: V20Text.bs(color: V20.ink2),
      ),
    ]);
  }
}
