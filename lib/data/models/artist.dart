import 'package:flutter/material.dart';

class Artist {
  final String name;
  final Color color;
  final int songs;
  final String? imageUrl; // Spotify 아티스트 이미지 (null이면 이니셜 아바타)
  const Artist({required this.name, required this.color, required this.songs, this.imageUrl});

  Artist copyWith({String? name, Color? color, int? songs, String? imageUrl}) {
    return Artist(
      name: name ?? this.name,
      color: color ?? this.color,
      songs: songs ?? this.songs,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
