import 'package:flutter/material.dart';
import '../data/models/song.dart';
import '../data/repositories/player_storage.dart';

class SearchProvider extends ChangeNotifier {
  late PlayerStorage _storage;
  String _query = '';
  List<String> _recentSearches = [];
  String _activeTab = 'genre';

  String get query => _query;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  String get activeTab => _activeTab;

  /// 현재 쿼리로 [songs]를 필터링. 검색 페이지가 보강된 CatalogProvider.songs를
  /// 넘겨주면 실제 앨범 커버가 포함된 결과가 나온다. 빈 쿼리면 빈 리스트.
  List<Song> filter(List<Song> songs) {
    if (_query.isEmpty) return const [];
    final q = _query.toLowerCase();
    return songs.where((s) =>
      s.title.toLowerCase().contains(q) ||
      s.artist.toLowerCase().contains(q) ||
      s.album.toLowerCase().contains(q) ||
      s.tags.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }

  Future<void> init(PlayerStorage storage) async {
    _storage = storage;
    _recentSearches = storage.recentSearches;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void saveSearch(String term) {
    if (term.isEmpty) return;
    _recentSearches.remove(term);
    _recentSearches.insert(0, term);
    if (_recentSearches.length > 10) _recentSearches = _recentSearches.sublist(0, 10);
    _storage.saveRecentSearches(_recentSearches);
    notifyListeners();
  }

  void removeRecent(String term) {
    _recentSearches.remove(term);
    _storage.saveRecentSearches(_recentSearches);
    notifyListeners();
  }

  void clearRecents() {
    _recentSearches.clear();
    _storage.saveRecentSearches(_recentSearches);
    notifyListeners();
  }

  void setActiveTab(String t) {
    _activeTab = t;
    notifyListeners();
  }
}
