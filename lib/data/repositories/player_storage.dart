import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerStorage {
  static const _keySongIdx = 'player_song_idx';
  static const _keyIsPlaying = 'player_is_playing';
  static const _keyCurrentTime = 'player_current_time';
  static const _keyQueue = 'player_queue';
  static const _keyRecentSearches = 'recent_searches';
  static const _keyLoginEmail = 'login_email';

  final SharedPreferences _prefs;
  PlayerStorage(this._prefs);

  static Future<PlayerStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PlayerStorage(prefs);
  }

  int get songIdx => _prefs.getInt(_keySongIdx) ?? 0;
  bool get isPlaying => _prefs.getBool(_keyIsPlaying) ?? false;
  double get currentTime => _prefs.getDouble(_keyCurrentTime) ?? 0.0;
  List<int> get queue {
    final s = _prefs.getString(_keyQueue);
    if (s == null) return List.generate(10, (i) => i);
    return (jsonDecode(s) as List).cast<int>();
  }

  Future<void> saveSongIdx(int v) => _prefs.setInt(_keySongIdx, v);
  Future<void> saveIsPlaying(bool v) => _prefs.setBool(_keyIsPlaying, v);
  Future<void> saveCurrentTime(double v) => _prefs.setDouble(_keyCurrentTime, v);
  Future<void> saveQueue(List<int> v) => _prefs.setString(_keyQueue, jsonEncode(v));

  List<String> get recentSearches {
    final s = _prefs.getString(_keyRecentSearches);
    if (s == null) return ['BTS', 'IU Celebrity', 'NewJeans', 'aespa Savage'];
    return (jsonDecode(s) as List).cast<String>();
  }
  Future<void> saveRecentSearches(List<String> v) =>
      _prefs.setString(_keyRecentSearches, jsonEncode(v));

  String get loginEmail => _prefs.getString(_keyLoginEmail) ?? '';
  Future<void> saveLoginEmail(String v) => _prefs.setString(_keyLoginEmail, v);
}
