import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/spotify_album_meta.dart';

/// 세로형 앨범 카드 (Spotify 디스코그래피용) — 네트워크 커버 + 앨범명 + 타입·연도.
class SpotifyAlbumCard extends StatelessWidget {
  final SpotifyAlbumMeta album;
  final double size;
  final VoidCallback onTap;

  const SpotifyAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    this.size = 140,
  });

  static String _typeLabel(String spotifyType) {
    switch (spotifyType) {
      case 'single':
        return '싱글';
      case 'compilation':
        return '컴필레이션';
      default:
        return '정규';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cover() {
      final placeholder = Container(
        width: size, height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.05),
        ),
      );
      if (album.imageUrl == null) return placeholder;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(album.imageUrl!, width: size, height: size, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cover(),
            const SizedBox(height: 10),
            Text(album.name,
                style: AppTextStyles.body.copyWith(fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${_typeLabel(album.albumType)} · ${album.year}',
                style: AppTextStyles.artistLabel, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
