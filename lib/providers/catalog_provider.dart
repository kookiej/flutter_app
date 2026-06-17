import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import '../data/mock/artists.dart';
import '../data/mock/songs.dart';
import '../data/models/artist.dart';
import '../data/models/song.dart';
import '../data/models/track_meta.dart';
import '../services/spotify_auth_service.dart';
import '../services/spotify_catalog_service.dart';

/// 목업 곡/아티스트를 Spotify 메타데이터(트랙 ID, 앨범 커버, 아티스트 이미지)로
/// 보강하고, 커버에서 추출한 색을 기존 색 체계에 주입한다.
/// 미로그인·API 실패 시에는 목업 데이터가 그대로 유지된다.
class CatalogProvider extends ChangeNotifier {
  final _service = SpotifyCatalogService();
  final _auth = SpotifyAuthService();

  List<Song> _songs = List.of(kSongs);
  List<Artist> _artists = List.of(kArtists);
  bool _loading = false;
  bool _loaded = false;

  /// 인덱스가 kSongs와 1:1 대응 — PlayerProvider의 큐 인덱스를 그대로 쓸 수 있다
  List<Song> get songs => _songs;
  List<Artist> get artists => _artists;

  /// 로그인 후 1회 호출. 캐시 → 없으면 검색 → 팔레트 추출 순으로 단계별 publish.
  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      var cache = await _service.loadCache();
      // 캐시에 없는 곡(신규 추가 등)만 추려 증분 조회·병합. 캐시가 없으면 전체 조회.
      if (cache == null) {
        cache = await _fetchCatalog(kSongs, null);
      } else {
        final missing = kSongs
            .where((s) => !cache!.songs.containsKey(SpotifyCatalogService.metaKey(s)))
            .toList();
        if (missing.isNotEmpty) {
          cache = await _fetchCatalog(missing, cache) ?? cache;
        }
      }
      if (cache == null) return; // 토큰 없음/전부 실패 → 목업 유지, 다음에 재시도

      _applyCache(cache);
      _loaded = true;
      notifyListeners(); // 커버 이미지 먼저 표시

      final updated = await _extractPalettes(cache);
      if (updated) {
        _applyCache(cache);
        await _service.saveCache(cache); // 추출한 색까지 캐시 (팔레트도 1회 실행)
        notifyListeners();
      }
    } finally {
      _loading = false;
    }
  }

  /// [targets] 곡들을 Web API로 검색해 [base] 캐시에 병합한다(없으면 새로 생성).
  /// 아티스트 이미지는 전체 kSongs 기준으로 재조회해 병합. 토큰 없으면 base 유지.
  Future<CatalogCache?> _fetchCatalog(List<Song> targets, CatalogCache? base) async {
    final token = await _auth.accessToken;
    if (token == null) return base;

    final metas = <String, TrackMeta>{...?base?.songs};
    for (final song in targets) {
      try {
        final meta = await _service.searchTrack(token, song);
        if (meta != null) metas[SpotifyCatalogService.metaKey(song)] = meta;
      } catch (_) {
        // 한 곡 실패가 전체를 막지 않도록 — 해당 곡만 목업 유지
      }
    }
    if (metas.isEmpty) return base;

    // 곡 검색에서 얻은 artistId로 우리 쪽 아티스트명 → 이미지 URL 매핑
    // (Spotify 응답 이름과의 표기 차이에 영향받지 않도록 ID로 연결)
    final artistImages = <String, String>{...?base?.artistImages};
    try {
      final idByName = <String, String>{};
      for (final song in kSongs) {
        final id = metas[SpotifyCatalogService.metaKey(song)]?.artistId;
        if (id != null) idByName[song.artist] = id;
      }
      final urlById =
          await _service.fetchArtistImages(token, idByName.values.toSet());
      for (final e in idByName.entries) {
        if (urlById.containsKey(e.value)) artistImages[e.key] = urlById[e.value]!;
      }
    } catch (_) {}

    final cache = CatalogCache(songs: metas, artistImages: artistImages);
    await _service.saveCache(cache);
    return cache;
  }

  /// 캐시 내용을 _songs/_artists에 반영
  void _applyCache(CatalogCache cache) {
    _songs = [
      for (final song in kSongs)
        _enrichSong(song, cache.songs[SpotifyCatalogService.metaKey(song)]),
    ];
    _artists = [
      for (final artist in kArtists)
        cache.artistImages.containsKey(artist.name)
            ? artist.copyWith(imageUrl: cache.artistImages[artist.name])
            : artist,
    ];
  }

  Song _enrichSong(Song base, TrackMeta? meta) {
    if (meta == null) return base;
    var song = base.copyWith(
      spotifyTrackId: meta.trackId,
      albumImageUrl: meta.albumImageUrl,
    );
    final p = meta.paletteColors;
    if (p != null && p.length >= 4) {
      final dark = Color(p[0]);
      final mid = Color(p[1]);
      final vibrant = Color(p[2]);
      final accent = Color(p[3]);
      song = song.copyWith(
        colors: [dark, mid, vibrant],
        accent: accent,
        lyricsColor: Color.lerp(accent, Colors.white, 0.35)!,
        coverGradient: [dark, mid, vibrant],
        coverAccent: vibrant,
      );
    }
    return song;
  }

  /// 커버 이미지에서 색 추출 → 캐시에 기록. 하나라도 추출했으면 true.
  /// CORS 등으로 픽셀 접근이 막히면 해당 곡은 하드코딩 색 유지.
  Future<bool> _extractPalettes(CatalogCache cache) async {
    var updated = false;
    for (final entry in cache.songs.entries.toList()) {
      final meta = entry.value;
      if (meta.paletteColors != null || meta.albumImageUrl == null) continue;
      try {
        final palette = await PaletteGenerator.fromImageProvider(
          NetworkImage(meta.albumImageUrl!),
          size: const Size(100, 100),
          maximumColorCount: 16,
        );
        final base = kSongs.firstWhere(
            (s) => SpotifyCatalogService.metaKey(s) == entry.key);
        // 기존 색 체계(어두운 배경 → 중간 → 비비드 + 밝은 액센트)로 매핑
        final dark = palette.darkMutedColor?.color ?? base.colors[0];
        final mid = palette.darkVibrantColor?.color ?? base.colors[1];
        final vibrant = palette.vibrantColor?.color ?? base.colors[2];
        final accent = palette.lightVibrantColor?.color ?? base.accent;
        cache.songs[entry.key] = meta.withPalette([
          dark.toARGB32(),
          mid.toARGB32(),
          vibrant.toARGB32(),
          accent.toARGB32(),
        ]);
        updated = true;
      } catch (_) {
        // 추출 실패 → 이미지 URL만 적용, 색은 하드코딩 유지
      }
    }
    return updated;
  }
}
