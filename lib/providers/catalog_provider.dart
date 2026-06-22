import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import '../data/mock/albums.dart';
import '../data/mock/artists.dart';
import '../data/mock/songs.dart';
import '../data/models/album.dart';
import '../data/models/artist.dart';
import '../data/models/song.dart';
import '../data/models/spotify_album_meta.dart';
import '../data/models/track_meta.dart';
import '../services/spotify_auth_service.dart';
import '../services/spotify_catalog_service.dart';

/// 목업 곡/아티스트를 Spotify 메타데이터(트랙 ID, 앨범 커버, 아티스트 이미지,
/// 발매일, 디스코그래피, 수록곡)로 보강하고, 커버에서 추출한 색을 주입한다.
/// 미로그인·API 실패 시에는 목업 데이터가 그대로 유지된다.
class CatalogProvider extends ChangeNotifier {
  final _service = SpotifyCatalogService();
  final _auth = SpotifyAuthService();

  List<Song> _songs = List.of(kSongs);
  List<Artist> _artists = List.of(kArtists);
  CatalogCache? _cache;
  bool _loading = false;
  bool _loaded = false;

  // 파생 인덱스 (캐시 적용 시 갱신)
  final Map<String, DateTime> _releaseDates = {}; // 앨범명 → 발매일
  final Map<String, String> _albumIdByName = {}; // 앨범명 → Spotify 앨범 ID
  final Set<String> _fetchingTracks = {}; // 진행 중인 앨범 ID

  /// 인덱스가 kSongs와 1:1 대응 — PlayerProvider의 큐 인덱스를 그대로 쓸 수 있다
  List<Song> get songs => _songs;
  List<Artist> get artists => _artists;
  List<Album> get albums => kAlbums;

  /// "아티스트|제목" 매칭으로 songs 인덱스 반환 (재생용). 없으면 -1.
  int indexOfSong(Song song) =>
      _songs.indexWhere((s) => s.artist == song.artist && s.title == song.title);

  /// 앨범 수록곡 — (artist, album) 매칭으로 파생.
  List<Song> tracksOf(Album album) =>
      _songs.where((s) => s.artist == album.artist && s.album == album.name).toList();

  /// 앨범 수록곡의 songs 인덱스 목록 (재생/큐용).
  List<int> trackIndicesOf(Album album) {
    final out = <int>[];
    for (var i = 0; i < _songs.length; i++) {
      if (_songs[i].artist == album.artist && _songs[i].album == album.name) out.add(i);
    }
    return out;
  }

  /// 아티스트의 발매 앨범 (목업).
  List<Album> albumsByArtist(String name) =>
      kAlbums.where((a) => a.artist == name).toList();

  /// 아티스트의 곡 목록 (songs 등장 순서 = 인기곡 순).
  List<Song> songsByArtist(String name) =>
      _songs.where((s) => s.artist == name).toList();

  /// 아티스트 곡들의 songs 인덱스 목록.
  List<int> songIndicesByArtist(String name) {
    final out = <int>[];
    for (var i = 0; i < _songs.length; i++) {
      if (_songs[i].artist == name) out.add(i);
    }
    return out;
  }

  /// 곡이 속한 앨범 — 플레이어 앨범명 탭용. 없으면 null.
  Album? albumFor(Song song) {
    for (final a in kAlbums) {
      if (a.artist == song.artist && a.name == song.album) return a;
    }
    return null;
  }

  /// 대표곡(타이틀곡 우선, 없으면 첫 곡)으로 앨범 커버를 렌더링한다.
  Song? coverSongOf(Album album) {
    final tracks = tracksOf(album);
    if (tracks.isEmpty) return null;
    for (final t in tracks) {
      if (album.isTitleTrack(t.title)) return t;
    }
    return tracks.first;
  }

  /// 이름으로 아티스트 조회 — kArtists에 없으면 곡 정보로 폴백 생성.
  Artist artistByName(String name) {
    for (final a in _artists) {
      if (a.name == name) return a;
    }
    final count = _songs.where((s) => s.artist == name).length;
    final color = _songs.firstWhere((s) => s.artist == name,
            orElse: () => _songs.first)
        .coverAccent;
    return Artist(name: name, color: color, songs: count);
  }

  // ── Spotify 기반 정확 정보 (없으면 목업 폴백) ─────────────────────────────

  /// 앨범 발매일 — Spotify 우선, 없으면 목업.
  DateTime releaseDateOf(Album album) => _releaseDates[album.name] ?? album.releaseDate;

  /// 아티스트 발매 앨범 (Spotify 디스코그래피). 없으면 빈 목록.
  List<SpotifyAlbumMeta> discographyOf(String artistName) =>
      _cache?.artistAlbums[artistName] ?? const [];

  /// 앨범의 Spotify 전체 수록곡 (캐시됨). 없으면 빈 목록 → 목업 수록곡 사용.
  List<SpotifyTrackMeta> spotifyTracksOf(Album album) {
    final id = _albumIdByName[album.name];
    if (id == null) return const [];
    return _cache?.albumTracks[id] ?? const [];
  }

  /// 앨범명으로 Spotify 디스코그래피 메타 조회 (커버 이미지 등). 없으면 null.
  SpotifyAlbumMeta? spotifyAlbumNamed(String albumName) {
    for (final albums in (_cache?.artistAlbums.values ?? const <List<SpotifyAlbumMeta>>[])) {
      for (final a in albums) {
        if (a.name == albumName) return a;
      }
    }
    return null;
  }

  /// Spotify 디스코그래피 항목 → Album. 같은 이름의 목업 앨범이 있으면 그걸 우선.
  Album albumForSpotify(SpotifyAlbumMeta meta, String artistName) {
    for (final a in kAlbums) {
      if (a.artist == artistName && a.name == meta.name) return a;
    }
    return Album(
      name: meta.name,
      artist: artistName,
      type: _albumTypeOf(meta.albumType),
      releaseDate: _parseReleaseDate(meta.releaseDate) ?? DateTime(meta.year),
      coverGradient: const [Color(0xFF2A2A35), Color(0xFF1C1C24), Color(0xFF14141A)],
      coverAccent: const Color(0xFF7C3AED),
    );
  }

  AlbumType _albumTypeOf(String spotifyType) {
    switch (spotifyType) {
      case 'single':
        return AlbumType.single;
      case 'compilation':
        return AlbumType.regular;
      default:
        return AlbumType.regular;
    }
  }

  /// 앨범 수록곡을 아직 안 받았으면 lazy 조회 후 notify. (앨범 페이지 진입 시 호출)
  Future<void> ensureAlbumTracks(Album album) async {
    final id = _albumIdByName[album.name];
    if (id == null) return;
    final cache = _cache;
    if (cache == null) return;
    if (cache.albumTracks.containsKey(id)) return;
    if (_fetchingTracks.contains(id)) return;
    _fetchingTracks.add(id);
    try {
      final token = await _auth.accessToken;
      if (token == null) return;
      final tracks = await _service.fetchAlbumTracks(token, id);
      if (tracks.isEmpty) return;
      cache.albumTracks[id] = tracks;
      await _service.saveCache(cache);
      notifyListeners();
    } catch (_) {
      // 실패 → 목업 수록곡 유지
    } finally {
      _fetchingTracks.remove(id);
    }
  }

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
        } else if (cache.artistIds.isEmpty) {
          // 곡은 다 있지만 아티스트/디스코그래피 미보강(구버전 캐시) → 보강
          cache = await _fetchArtists(cache) ?? cache;
        }
      }
      if (cache == null) return; // 토큰 없음/전부 실패 → 목업 유지, 다음에 재시도

      _applyCache(cache);
      _loaded = true;
      notifyListeners(); // 커버 이미지/발매일 먼저 표시

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
  /// 이어서 아티스트(이미지/ID/디스코그래피)를 보강. 토큰 없으면 base 유지.
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

    var cache = (base ?? const CatalogCache(songs: {}, artistImages: {}))
        .copyWith(songs: metas);
    cache = await _fetchArtists(cache) ?? cache;
    await _service.saveCache(cache);
    return cache;
  }

  /// 아티스트명으로 직접 검색해 이미지/ID 확보 후 디스코그래피까지 받는다.
  Future<CatalogCache?> _fetchArtists(CatalogCache base) async {
    final token = await _auth.accessToken;
    if (token == null) return base;

    final images = <String, String>{...base.artistImages};
    final ids = <String, String>{...base.artistIds};
    final discography = <String, List<SpotifyAlbumMeta>>{...base.artistAlbums};

    final names = kSongs.map((s) => s.artist).toSet();
    for (final name in names) {
      if (ids.containsKey(name)) continue; // 이미 보강됨
      try {
        final hit = await _service.searchArtist(token, name);
        if (hit == null) continue;
        ids[name] = hit.id;
        if (hit.imageUrl != null) images[name] = hit.imageUrl!;
        discography[name] = await _service.fetchArtistAlbums(token, hit.id);
      } catch (_) {
        // 해당 아티스트만 목업 유지
      }
    }

    return base.copyWith(
      artistImages: images,
      artistIds: ids,
      artistAlbums: discography,
    );
  }

  /// 캐시 내용을 _songs/_artists 및 파생 인덱스에 반영
  void _applyCache(CatalogCache cache) {
    _cache = cache;
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

    // 앨범 발매일 / 앨범 ID — 트랙 메타에서 (앨범명 기준) 파생
    _releaseDates.clear();
    _albumIdByName.clear();
    for (final song in kSongs) {
      final meta = cache.songs[SpotifyCatalogService.metaKey(song)];
      if (meta == null) continue;
      if (meta.albumId != null) _albumIdByName.putIfAbsent(song.album, () => meta.albumId!);
      final rd = meta.albumReleaseDate;
      if (rd != null && !_releaseDates.containsKey(song.album)) {
        final parsed = _parseReleaseDate(rd);
        if (parsed != null) _releaseDates[song.album] = parsed;
      }
    }
  }

  /// ISO 부분 발매일("2020-02-21" / "2020-02" / "2020") 파싱.
  DateTime? _parseReleaseDate(String s) {
    final parts = s.split('-');
    final y = int.tryParse(parts.isNotEmpty ? parts[0] : '');
    if (y == null) return null;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
    final d = parts.length > 2 ? int.tryParse(parts[2]) ?? 1 : 1;
    return DateTime(y, m, d);
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
