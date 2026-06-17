import 'package:flutter/material.dart';

class Song {
  final String title;
  final String artist;
  final String album;
  final int duration;
  final List<Color> colors;
  final Color accent;
  final Color lyricsColor;
  final List<Color> coverGradient;
  final Color coverAccent;
  final List<String> tags;
  final String? spotifyTrackId; // Spotify 매칭 트랙 ID (미매칭 시 null → 시뮬레이션 재생)
  final String? albumImageUrl; // 실제 앨범 커버 URL (null이면 그라디언트 커버)

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.colors,
    required this.accent,
    required this.lyricsColor,
    required this.coverGradient,
    required this.coverAccent,
    this.tags = const [],
    this.spotifyTrackId,
    this.albumImageUrl,
  });

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    int? duration,
    List<Color>? colors,
    Color? accent,
    Color? lyricsColor,
    List<Color>? coverGradient,
    Color? coverAccent,
    List<String>? tags,
    String? spotifyTrackId,
    String? albumImageUrl,
  }) {
    return Song(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      colors: colors ?? this.colors,
      accent: accent ?? this.accent,
      lyricsColor: lyricsColor ?? this.lyricsColor,
      coverGradient: coverGradient ?? this.coverGradient,
      coverAccent: coverAccent ?? this.coverAccent,
      tags: tags ?? this.tags,
      spotifyTrackId: spotifyTrackId ?? this.spotifyTrackId,
      albumImageUrl: albumImageUrl ?? this.albumImageUrl,
    );
  }
}
