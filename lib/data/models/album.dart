import 'package:flutter/material.dart';

/// 앨범 타입 — 정규/미니/싱글.
enum AlbumType {
  regular('정규'),
  mini('미니'),
  single('싱글');

  final String label;
  const AlbumType(this.label);
}

/// 앨범 메타. 수록곡은 저장하지 않고 곡의 (artist, album) 매칭으로 파생한다.
/// 커버는 대표곡(타이틀곡)의 Song을 커버 위젯에 넘겨 렌더링한다.
class Album {
  final String name;
  final String artist; // Song.artist 와 매칭되는 이름
  final AlbumType type;
  final DateTime releaseDate;
  final List<Color> coverGradient;
  final Color coverAccent;
  final List<String> titleTracks; // 타이틀곡 제목 (수록곡 목록 별도 표기용)

  const Album({
    required this.name,
    required this.artist,
    required this.type,
    required this.releaseDate,
    required this.coverGradient,
    required this.coverAccent,
    this.titleTracks = const [],
  });

  bool isTitleTrack(String songTitle) => titleTracks.contains(songTitle);
}
