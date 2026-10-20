# RAP EMPIRE (Flutter + Supabase · Android + Web)

Monde 100 % fictif · handCode Studio. Le prototype HTML v20 sert de référence fonctionnelle (moteur `engine.js` porté en Dart).

## Démarrer
```bash
# 1. Générer les dossiers plateformes (ne touche pas à lib/ ni pubspec.yaml)
flutter create --platforms=android,web --project-name rap_empire --org studio.handcode .
flutter pub get
flutter test                       # parité avec le prototype
# 2. Lancer sans Supabase (jeu hors ligne)
flutter run -d chrome
# 3. Avec Supabase
cp env.example.json env.json       # renseigner URL + clé anon
flutter run -d chrome --dart-define-from-file=env.json
```
## Supabase
`supabase link --project-ref <ref>` puis `supabase db push` (applique `supabase/migrations`). Importer ensuite `assets/data/artistes-demo.json` dans `labels` et `artists` (script à écrire, étape suivante).

## Structure
`lib/domain` règles pures · `lib/data` sauvegarde · `lib/app` routes et état · `lib/features/<écran>` UI · `lib/core/theme` tokens.


## État de référence v21 — 2026-10-20

- La branche `main` contient déjà une implémentation Flutter v21 étendue. Avant d'ajouter une fonctionnalité, comparer le besoin aux routes, écrans, moteur Dart, moteur de référence JS et tests existants.
- Inventaire observé lors de la consolidation : **76 fichiers de planches HTML distincts** dans `docs/design-ref/v21/`; l'index contient 78 liens, dont des doublons. Ce nombre est un instantané du dépôt, à recalculer si les planches changent.
- Dernière CI consultée : analyse Flutter, tests, build Web release et build APK debug réussis sur le commit `014ed0b0430de2a5faa6ffc868a2423534d0863d`. Cela ne remplace pas une vérification des parcours UI.
- Le concept de garde-robe à tenues complètes et variantes jeune/mature est validé. Les illustrations de `rapper_001` restent des ressources de test non finales.
- Toute consolidation doit être différentielle : ne pas recréer un module déjà présent ; documenter les écarts prouvés et ajouter des tests de régression.
- Ne pas supprimer ni modifier les archives ou prototypes v19/v20 dans le cadre d'une consolidation v21.
