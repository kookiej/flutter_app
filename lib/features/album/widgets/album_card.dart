import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/album.dart';
import '../../../data/models/song.dart';
import '../../shared/widgets/mini_cover.dart';

/// 세로형 앨범 카드 — 커버(대표곡 기준) + 앨범명 + 타입·연도.
/// [coverSong] 은 catalog.coverSongOf(album) 로 해석해 넘긴다.
class AlbumCard extends StatelessWidget {
  final Album album;
  final Song? coverSong;
  final double size;
  final VoidCallback onTap;

  const AlbumCard({
    super.key,
    required this.album,
    required this.coverSong,
    required this.onTap,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final cover = coverSong ??
        Song(
          title: album.name, artist: album.artist, album: album.name, duration: 0,
          colors: album.coverGradient, accent: album.coverAccent,
          lyricsColor: album.coverAccent, coverGradient: album.coverGradient,
          coverAccent: album.coverAccent,
        );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MiniCover(song: cover, size: size, radius: 12),
            const SizedBox(height: 10),
            Text(album.name,
                style: AppTextStyles.body.copyWith(fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${album.type.label} · ${album.releaseDate.year}',
                style: AppTextStyles.artistLabel, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
