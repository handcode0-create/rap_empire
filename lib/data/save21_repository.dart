import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/v21/engine21.dart';
import '../domain/v21/reg21.dart';

/// Sauvegarde locale de la partie v21 : l'état du moteur, tel quel, en JSON. Hors ligne d'abord ; la synchronisation distante reste à décider (D-09).
class Save21Repository {
  static const _key = 'save_v21';

  Future<J> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return init21();
    try {
      return norm21(jsonDecode(raw) as J);
    } on Object {
      return init21();
    }
  }

  Future<void> save(J s) async => (await SharedPreferences.getInstance()).setString(_key, jsonEncode(s));

  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}
