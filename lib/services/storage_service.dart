import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyPlayers = 'players';

  Future<List<String>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPlayers) ?? [];
  }

  Future<void> addPlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final players = prefs.getStringList(_keyPlayers) ?? [];
    if (!players.contains(name)) {
      players.add(name);
      await prefs.setStringList(_keyPlayers, players);
    }
  }

  Future<void> deletePlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final players = prefs.getStringList(_keyPlayers) ?? [];
    players.remove(name);
    await prefs.setStringList(_keyPlayers, players);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlayers);
  }
}

