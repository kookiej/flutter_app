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
  });
}
