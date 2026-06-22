import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/song.dart';
import '../data/models/spotify_album_meta.dart';
import '../data/models/track_meta.dart';

/// Spotify Web API로 목업 곡들을 실제 트랙에 매칭하고
/// 앨범 커버·아티스트 이미지·발매일·디스코그래피·수록곡을 가져온다.
/// 결과는 prefs에 캐시 (1회 실행).
class SpotifyCatalogService {
  // v3: 아티스트 ID/디스코그래피/앨범 수록곡 캐시 추가
  static const _cacheKey = 'spotify_catalog_v3';
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
    final album = track['album'] as Map<String, dynamic>?;

    final images = (album?['images'] as List?) ?? [];
    final artists = (track['artists'] as List?) ?? [];

    return TrackMeta(
      trackId: track['id'] as String,
      albumImageUrl: images.isNotEmpty ? images.first['url'] as String? : null,
      artistId: artists.isNotEmpty ? artists.first['id'] as String? : null,
      albumId: album?['id'] as String?,
      albumReleaseDate: album?['release_date'] as String?,
    );
  }

  /// 아티스트명으로 직접 검색 → {id, imageUrl}. 트랙의 첫 아티스트 ID보다 안정적.
  /// 실패 시 null.
  Future<({String id, String? imageUrl})?> searchArtist(
      String token, String name) async {
    final uri = Uri.parse('$_apiBase/search').replace(queryParameters: {
      'q': name,
      'type': 'artist',
      'limit': '1',
      'market': 'KR',
    });
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode != 200) return null;

    final items = (jsonDecode(res.body)['artists']?['items'] as List?) ?? [];
    if (items.isEmpty) return null;
    final artist = items.first as Map<String, dynamic>;
    final images = (artist['images'] as List?) ?? [];
    return (
      id: artist['id'] as String,
      imageUrl: images.isNotEmpty ? images.first['url'] as String? : null,
    );
  }

  /// 아티스트 발매 앨범(정규+미니/싱글) 목록. 중복 제거 후 최신순.
  Future<List<SpotifyAlbumMeta>> fetchArtistAlbums(
      String token, String artistId) async {
    final uri = Uri.parse('$_apiBase/artists/$artistId/albums').replace(
        queryParameters: {
          'include_groups': 'album,single',
          'market': 'KR',
          'limit': '50',
        });
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode != 200) return [];

    final items = (jsonDecode(res.body)['items'] as List?) ?? [];
    final byName = <String, SpotifyAlbumMeta>{};
    for (final a in items) {
      final m = a as Map<String, dynamic>;
      final images = (m['images'] as List?) ?? [];
      final meta = SpotifyAlbumMeta(
        id: m['id'] as String,
        name: m['name'] as String,
        albumType: m['album_type'] as String? ?? 'album',
        releaseDate: m['release_date'] as String? ?? '',
        imageUrl: images.isNotEmpty ? images.first['url'] as String? : null,
        totalTracks: (m['total_tracks'] as num?)?.toInt() ?? 0,
      );
      // 같은 이름의 리마스터/리이슈 중복은 첫(최신) 항목만 유지
      byName.putIfAbsent(meta.name, () => meta);
    }
    final list = byName.values.toList()
      ..sort((a, b) => b.year.compareTo(a.year));
    return list;
  }

  /// 앨범 수록곡 (표시용 — 트랙명/길이/번호).
  Future<List<SpotifyTrackMeta>> fetchAlbumTracks(
      String token, String albumId) async {
    final uri = Uri.parse('$_apiBase/albums/$albumId/tracks')
        .replace(queryParameters: {'market': 'KR', 'limit': '50'});
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode != 200) return [];

    final items = (jsonDecode(res.body)['items'] as List?) ?? [];
    return [
      for (final t in items)
        SpotifyTrackMeta(
          name: (t as Map<String, dynamic>)['name'] as String,
          durationMs: (t['duration_ms'] as num?)?.toInt() ?? 0,
          trackNumber: (t['track_number'] as num?)?.toInt() ?? 0,
        ),
    ];
  }
}

/// prefs에 저장되는 카탈로그 전체.
class CatalogCache {
  /// key: "아티스트|제목" (SpotifyCatalogService.metaKey)
  final Map<String, TrackMeta> songs;

  /// key: 아티스트명 → 이미지 URL
  final Map<String, String> artistImages;

  /// key: 아티스트명 → Spotify 아티스트 ID
  final Map<String, String> artistIds;

  /// key: 아티스트명 → 발매 앨범 목록
  final Map<String, List<SpotifyAlbumMeta>> artistAlbums;

  /// key: Spotify 앨범 ID → 수록곡 목록
  final Map<String, List<SpotifyTrackMeta>> albumTracks;

  const CatalogCache({
    required this.songs,
    required this.artistImages,
    this.artistIds = const {},
    this.artistAlbums = const {},
    this.albumTracks = const {},
  });

  CatalogCache copyWith({
    Map<String, TrackMeta>? songs,
    Map<String, String>? artistImages,
    Map<String, String>? artistIds,
    Map<String, List<SpotifyAlbumMeta>>? artistAlbums,
    Map<String, List<SpotifyTrackMeta>>? albumTracks,
  }) =>
      CatalogCache(
        songs: songs ?? this.songs,
        artistImages: artistImages ?? this.artistImages,
        artistIds: artistIds ?? this.artistIds,
        artistAlbums: artistAlbums ?? this.artistAlbums,
        albumTracks: albumTracks ?? this.albumTracks,
      );

  Map<String, dynamic> toJson() => {
        'songs': songs.map((k, v) => MapEntry(k, v.toJson())),
        'artistImages': artistImages,
        'artistIds': artistIds,
        'artistAlbums': artistAlbums
            .map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
        'albumTracks': albumTracks
            .map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      };

  factory CatalogCache.fromJson(Map<String, dynamic> json) => CatalogCache(
        songs: (json['songs'] as Map<String, dynamic>? ?? {}).map(
            (k, v) => MapEntry(k, TrackMeta.fromJson(v as Map<String, dynamic>))),
        artistImages:
            (json['artistImages'] as Map<String, dynamic>? ?? {}).cast<String, String>(),
        artistIds:
            (json['artistIds'] as Map<String, dynamic>? ?? {}).cast<String, String>(),
        artistAlbums: (json['artistAlbums'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(
            k,
            (v as List)
                .map((e) => SpotifyAlbumMeta.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        ),
        albumTracks: (json['albumTracks'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(
            k,
            (v as List)
                .map((e) => SpotifyTrackMeta.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        ),
      );
}
