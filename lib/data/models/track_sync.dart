// 백엔드 /api/tracks/:id/sync 응답 모델.
// sync_data 는 merge.js 의 merged 포맷 그대로:
//   [{ line?:{time,text}, lyrics?:{time,text}, fanChant?:[{time,text}] }]
// time 은 초(seconds) 단위.

class SyncRef {
  final double time;
  final String text;

  const SyncRef({required this.time, required this.text});

  factory SyncRef.fromJson(Map<String, dynamic> json) => SyncRef(
        time: (json['time'] as num).toDouble(),
        text: json['text'] as String? ?? '',
      );
}

class SyncEntry {
  final SyncRef? line;
  final SyncRef? lyrics;
  final List<SyncRef>? fanChant;

  const SyncEntry({this.line, this.lyrics, this.fanChant});

  factory SyncEntry.fromJson(Map<String, dynamic> json) {
    final fc = json['fanChant'] as List?;
    return SyncEntry(
      line: json['line'] is Map
          ? SyncRef.fromJson((json['line'] as Map).cast<String, dynamic>())
          : null,
      lyrics: json['lyrics'] is Map
          ? SyncRef.fromJson((json['lyrics'] as Map).cast<String, dynamic>())
          : null,
      fanChant: fc
          ?.map((e) => SyncRef.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  /// 응원법 전용 줄(가사/라인 텍스트 없음) 여부. content.js 의 fanchant-only 라인.
  bool get isFanchantOnly => line == null && lyrics == null;

  /// 줄의 기준 시각 (content.js 의 폴백 체인).
  double get startTime =>
      line?.time ?? (fanChant?.isNotEmpty == true ? fanChant!.first.time : null) ?? lyrics?.time ?? 0;

  /// collapsed 바 등에 쓸 대표 텍스트.
  String get displayText {
    if (line != null) return line!.text;
    if (lyrics != null) return lyrics!.text;
    if (fanChant != null) return fanChant!.map((c) => c.text).join(' ');
    return '';
  }
}

class TrackSync {
  final bool hasLyrics;
  final bool hasFanchant;
  final String? fanchantVideoUrl;
  final List<SyncEntry> entries;

  const TrackSync({
    required this.hasLyrics,
    required this.hasFanchant,
    this.fanchantVideoUrl,
    required this.entries,
  });

  factory TrackSync.fromJson(Map<String, dynamic> json) {
    final data = json['syncData'] as List?;
    return TrackSync(
      hasLyrics: json['hasSyncedLyrics'] as bool? ?? false,
      hasFanchant: json['hasFanchant'] as bool? ?? false,
      fanchantVideoUrl: json['fanchantVideoUrl'] as String?,
      entries: data == null
          ? const []
          : data
              .map((e) => SyncEntry.fromJson((e as Map).cast<String, dynamic>()))
              .toList(),
    );
  }
}
