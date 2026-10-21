import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/save21_repository.dart';
import '../domain/v21/engine21.dart';
import '../domain/v21/reg21.dart';

final save21RepoProvider = Provider((_) => Save21Repository());

/// Messages d'erreur du moteur v21 (ERR de binder21.js).
const err21 = {
  'cash': 'Cash insuffisant',
  'energie': 'Énergie insuffisante : termine la journée',
  'tard': "Plus assez d'heures aujourd'hui : termine la journée",
  'rang': 'Rang de carrière insuffisant',
  'rep': 'Réputation insuffisante',
  'deja': 'Déjà fait',
  'encours': 'Un titre est déjà en cours',
  'pasdetexte': "Écris d'abord le texte",
  'pasenregistre': "Enregistre d'abord le titre",
  'pasdetitre': 'Aucun titre concerné',
  'maxfeat': 'Deux featurings au maximum',
  'rival': 'Indisponible : rivalité en cours',
  'pop': 'Popularité insuffisante',
  'clipapres': 'Trop tard : un clip se prépare avant la sortie',
  'pasprepare': "Prépare d'abord le clip",
  'avantsortie': 'Le clip ne peut sortir qu\'après le titre',
  'pasproduit': "Tourne d'abord le clip",
  'charisme': 'Charisme insuffisant',
  'voix': 'Voix insuffisante',
  'ecriture': 'Écriture insuffisante',
  'pasfaite': "Mission pas encore accomplie",
  'aujourdhui': 'Déjà suivie aujourd’hui : reviens demain',
  'fans': 'Pas assez de fans',
  'single': "Sors d'abord un single",
  'romjour': 'Deux actions romantiques par jour : reviens demain',
  'exclusif': 'Tu es en couple : relation exclusive',
  'ex': 'Relation terminée récemment',
  'pasdeconcert': "Fais d'abord un concert ou un open mic",
  'seuil': 'Relation encore trop faible',
  'condmariage': 'Conditions du mariage non réunies',
  'mariage': 'Réservé aux couples mariés',
  'pasdecouple': 'Aucune relation officielle',
  'age': "Pas encore de cet âge",
  'nom': 'Nom de scène invalide',
  'delai': "Trop tôt : cette date n'est pas encore disponible",
  'audience': 'Audience insuffisante à Port-Ambre et Sélène',
  'rien': 'Aucun événement en attente',
  'mature': 'Contenu mature désactivé : active-le dans le Profil (16+)',
  'prison': 'Impossible en prison : écris, fais du sport ou termine la journée',
  'garde': 'En garde à vue : paie la caution ou accepte la détention',
  'affaire': 'Une affaire est en cours : attends le procès',
  'proces': "Le procès n'a pas encore eu lieu",
  'reserve': 'Réserve pleine : 20 titres au maximum',
  'pistes': 'Nombre de titres incorrect pour ce projet',
  'postjour': 'Trois publications par jour : reviens demain',
  'campagne': 'Cette campagne est déjà en cours',
  'confirm': "Confirme l'achat (15 000 cauris ou plus)",
  'indispo': 'Tenue indisponible : une illustration manque',
  'pasachete': "Achète d'abord cette tenue",
  'inconnu': 'Action impossible',
};

String errText21(String code) => err21[code] ?? 'Action impossible';

/// État de la partie v21. Chaque action passe par le moteur pur (lib/domain/v21/engine21.dart) puis est sauvegardée.
class Game21Notifier extends AsyncNotifier<J> {
  @override
  Future<J> build() => ref.read(save21RepoProvider).load();

  /// Applique une action du moteur. Renvoie le code d'erreur, ou null si l'action a réussi.
  Future<String?> act(String name, [dynamic arg]) async {
    final cur = state.requireValue;
    final r = act21(cur, name, arg, DateTime.now().millisecondsSinceEpoch);
    if (r.err != null) return r.err;
    state = AsyncData(r.s);
    await ref.read(save21RepoProvider).save(r.s);
    return null;
  }

  /// Plusieurs actions de suite (arrêt à la première erreur).
  Future<String?> actAll(List<(String, dynamic)> steps) async {
    for (final (n, a) in steps) {
      final e = await act(n, a);
      if (e != null) return e;
    }
    return null;
  }

  /// Nouvelle partie : efface la sauvegarde et repart de l'état initial.
  Future<void> newGame() async {
    final s = init21();
    state = AsyncData(s);
    await ref.read(save21RepoProvider).save(s);
  }
}

final game21Provider = AsyncNotifierProvider<Game21Notifier, J>(Game21Notifier.new);
