import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/album.dart';

/// 앨범별 북마크 상태. "아티스트|앨범명" 키로 저장한다.
class BookmarkProvider extends ChangeNotifier {
  static const _prefsKey = 'bookmarked_albums';

  final Set<String> _bookmarked = {};

  BookmarkProvider() {
    _restore();
  }

  static String _keyOf(Album album) => '${album.artist}|${album.name}';

  bool isBookmarked(Album album) => _bookmarked.contains(_keyOf(album));

  Future<void> toggle(Album album) async {
    final key = _keyOf(album);
    if (!_bookmarked.remove(key)) _bookmarked.add(key);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _bookmarked.toList());
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarked.addAll(prefs.getStringList(_prefsKey) ?? []);
    notifyListeners();
  }
}
