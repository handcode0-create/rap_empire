import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/env.dart';
import '../domain/game_state.dart';

/// Sauvegarde locale d'abord (jouable hors ligne), synchronisation Supabase si connecté (D-09, option 2).
/// Règle de conflit provisoire : la sauvegarde la plus récente (updated_at) gagne ; l'ancienne est conservée (slot "previous").
class SaveRepository {
  static const _key = 'save_v1';
  Future<GameState> loadLocal() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return const GameState();
    return GameState.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<void> saveLocal(GameState s) async => (await SharedPreferences.getInstance()).setString(_key, s.encode());

  /// À brancher après validation de D-09 : upsert dans public.saves (voir supabase/migrations).
  Future<void> pushRemote(GameState s) async {
    if (!Env.hasSupabase) return;
    final u = Supabase.instance.client.auth.currentUser;
    if (u == null) return;
    await Supabase.instance.client.from('saves').upsert({'user_id': u.id, 'slot': 'current', 'schema_version': s.version, 'state': s.toJson()});
  }
}
