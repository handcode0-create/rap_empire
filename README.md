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
