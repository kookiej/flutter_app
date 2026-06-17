import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/song.dart';

/// 곡별 좋아요 상태. "아티스트|제목" 키로 저장해 보강된(copyWith) 인스턴스와도 일치한다.
class LikeProvider extends ChangeNotifier {
  static const _prefsKey = 'liked_songs';

  final Set<String> _liked = {};

  LikeProvider() {
    _restore();
  }

  static String _keyOf(Song song) => '${song.artist}|${song.title}';

  bool isLiked(Song song) => _liked.contains(_keyOf(song));

  Future<void> toggle(Song song) async {
    final key = _keyOf(song);
    if (!_liked.remove(key)) _liked.add(key);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _liked.toList());
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _liked.addAll(prefs.getStringList(_prefsKey) ?? []);
    notifyListeners();
  }
}
