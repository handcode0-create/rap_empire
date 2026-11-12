/// Variables injectées au build : flutter run --dart-define-from-file=env.json
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  /// Date du build web (UTC), pour vérifier sur le téléphone que la dernière version est bien chargée.
  static const buildTime = String.fromEnvironment('BUILD_TIME', defaultValue: 'locale');
  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
