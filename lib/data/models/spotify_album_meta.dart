/// Spotify 디스코그래피/앨범 상세 메타. shared_preferences에 JSON으로 캐시된다.
class SpotifyAlbumMeta {
  final String id;
  final String name;
  final String albumType; // album / single / compilation
  final String releaseDate; // ISO ("2020-02-21" 또는 "2020")
  final String? imageUrl;
  final int totalTracks;

  const SpotifyAlbumMeta({
    required this.id,
    required this.name,
    required this.albumType,
    required this.releaseDate,
    this.imageUrl,
    this.totalTracks = 0,
  });

  /// ISO 부분 발매일 → 연도 (정렬/표시용). 파싱 실패 시 0.
  int get year {
    final m = RegExp(r'^(\d{4})').firstMatch(releaseDate);
    return m == null ? 0 : int.parse(m.group(1)!);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'albumType': albumType,
        'releaseDate': releaseDate,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'totalTracks': totalTracks,
      };

  factory SpotifyAlbumMeta.fromJson(Map<String, dynamic> json) => SpotifyAlbumMeta(
        id: json['id'] as String,
        name: json['name'] as String,
        albumType: json['albumType'] as String? ?? 'album',
        releaseDate: json['releaseDate'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        totalTracks: (json['totalTracks'] as num?)?.toInt() ?? 0,
      );
}

/// Spotify 앨범 수록곡 1건 (표시용).
class SpotifyTrackMeta {
  final String name;
  final int durationMs;
  final int trackNumber;

  const SpotifyTrackMeta({
    required this.name,
    required this.durationMs,
    required this.trackNumber,
  });

  int get durationSeconds => (durationMs / 1000).round();

  Map<String, dynamic> toJson() => {
        'name': name,
        'durationMs': durationMs,
        'trackNumber': trackNumber,
      };

  factory SpotifyTrackMeta.fromJson(Map<String, dynamic> json) => SpotifyTrackMeta(
        name: json['name'] as String,
        durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
        trackNumber: (json['trackNumber'] as num?)?.toInt() ?? 0,
      );
}
