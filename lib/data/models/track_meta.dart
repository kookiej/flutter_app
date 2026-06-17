/// Spotify 매칭 결과 메타데이터. 곡당 1개, shared_preferences에 JSON으로 캐시된다.
class TrackMeta {
  final String trackId;
  final String? albumImageUrl;
  final String? artistId;

  /// 앨범 커버에서 추출한 색 (ARGB int). [dark, mid, vibrant, accent] 순.
  /// 추출 전이거나 실패 시 null → 하드코딩 색 유지.
  final List<int>? paletteColors;

  const TrackMeta({
    required this.trackId,
    this.albumImageUrl,
    this.artistId,
    this.paletteColors,
  });

  TrackMeta withPalette(List<int> colors) => TrackMeta(
        trackId: trackId,
        albumImageUrl: albumImageUrl,
        artistId: artistId,
        paletteColors: colors,
      );

  Map<String, dynamic> toJson() => {
        'trackId': trackId,
        if (albumImageUrl != null) 'albumImageUrl': albumImageUrl,
        if (artistId != null) 'artistId': artistId,
        if (paletteColors != null) 'paletteColors': paletteColors,
      };

  factory TrackMeta.fromJson(Map<String, dynamic> json) => TrackMeta(
        trackId: json['trackId'] as String,
        albumImageUrl: json['albumImageUrl'] as String?,
        artistId: json['artistId'] as String?,
        paletteColors: (json['paletteColors'] as List?)?.cast<int>(),
      );
}
