import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/song.dart';
import '../data/models/track_meta.dart';

/// Spotify Web API로 목업 곡들을 실제 트랙에 매칭하고
/// 앨범 커버·아티스트 이미지 URL을 가져온다. 결과는 prefs에 캐시 (1회 실행).
class SpotifyCatalogService {
  // v2: artistImages를 Spotify 응답 이름이 아닌 우리 쪽 아티스트명으로 키잉
  static const _cacheKey = 'spotify_catalog_v2';
  static const _apiBase = 'https://api.spotify.com/v1';

  /// 캐시 키: "아티스트|제목"
  static String metaKey(Song song) => '${song.artist}|${song.title}';

  // ── 캐시 ──────────────────────────────────────────────────────────────────

  Future<CatalogCache?> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return CatalogCache.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // 캐시 포맷이 깨졌으면 새로 받는다
    }
  }

  Future<void> saveCache(CatalogCache cache) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(cache.toJson()));
  }

  // ── Web API ───────────────────────────────────────────────────────────────

  /// 제목+아티스트 한정 검색으로 트랙 1건 매칭. 실패 시 null (해당 곡은 목업 유지)
  Future<TrackMeta?> searchTrack(String token, Song song) async {
    final query = 'track:"${song.title}" artist:"${song.artist}"';
    final uri = Uri.parse('$_apiBase/search').replace(queryParameters: {
      'q': query,
      'type': 'track',
      'limit': '1',
      'market': 'KR',
    });
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode != 200) return null;

    final items = (jsonDecode(res.body)['tracks']?['items'] as List?) ?? [];
    if (items.isEmpty) return null;
    final track = items.first as Map<String, dynamic>;

    final images = (track['album']?['images'] as List?) ?? [];
    final artists = (track['artists'] as List?) ?? [];
    debugPrint('[catalog] ${song.artist} - ${song.title} → '
        '${track['name']} / ${artists.isNotEmpty ? artists.first['name'] : '?'}');

    return TrackMeta(
      trackId: track['id'] as String,
      albumImageUrl: images.isNotEmpty ? images.first['url'] as String? : null,
      artistId: artists.isNotEmpty ? artists.first['id'] as String? : null,
    );
  }

  /// 아티스트 이미지 배치 조회 → {아티스트 ID: 이미지 URL}.
  /// 이름 매칭은 표기 차이로 어긋날 수 있어 ID로만 다룬다.
  Future<Map<String, String>> fetchArtistImages(
      String token, Set<String> artistIds) async {
    if (artistIds.isEmpty) return {};
    final uri = Uri.parse('$_apiBase/artists')
        .replace(queryParameters: {'ids': artistIds.join(',')});
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode != 200) {
      debugPrint('[catalog] artists fetch failed: ${res.statusCode}');
      return {};
    }

    final result = <String, String>{};
    for (final artist in (jsonDecode(res.body)['artists'] as List?) ?? []) {
      if (artist == null) continue;
      final images = (artist['images'] as List?) ?? [];
      if (images.isEmpty) continue;
      result[artist['id'] as String] = images.first['url'] as String;
    }
    debugPrint('[catalog] artist images: ${result.length}/${artistIds.length}');
    return result;
  }
}

/// prefs에 저장되는 카탈로그 전체: 곡 메타 + 아티스트 이미지
class CatalogCache {
  /// key: "아티스트|제목" (SpotifyCatalogService.metaKey)
  final Map<String, TrackMeta> songs;

  /// key: 아티스트명
  final Map<String, String> artistImages;

  const CatalogCache({required this.songs, required this.artistImages});

  Map<String, dynamic> toJson() => {
        'songs': songs.map((k, v) => MapEntry(k, v.toJson())),
        'artistImages': artistImages,
      };

  factory CatalogCache.fromJson(Map<String, dynamic> json) => CatalogCache(
        songs: (json['songs'] as Map<String, dynamic>? ?? {}).map(
            (k, v) => MapEntry(k, TrackMeta.fromJson(v as Map<String, dynamic>))),
        artistImages:
            (json['artistImages'] as Map<String, dynamic>? ?? {}).cast<String, String>(),
      );
}
