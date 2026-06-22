import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/album.dart';
import '../../data/models/song.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/like_provider.dart';
import '../../providers/player_provider.dart';
import '../album/album_page.dart';
import '../home/widgets/song_row.dart';
import '../shared/icons/app_icons.dart';
import '../shared/widgets/mini_cover.dart';

/// 보관함 — 좋아요한 곡 / 북마크한 앨범 (탭 전환). HomePage 내 _navIdx==2 에서 렌더.
class LibraryContent extends StatefulWidget {
  final void Function(Song) onToast;

  const LibraryContent({super.key, required this.onToast});

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  int _tab = 0; // 0: 좋아요한 곡, 1: 북마크한 앨범

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final like = context.watch<LikeProvider>();
    final bookmark = context.watch<BookmarkProvider>();

    final likedSongs = catalog.songs.where(like.isLiked).toList();
    final bookmarkedAlbums = catalog.albums.where(bookmark.isBookmarked).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text('보관함', style: AppTextStyles.pageTitle),
          ),
          _Tabs(selected: _tab, onSelect: (i) => setState(() => _tab = i)),
          const SizedBox(height: 8),
          Expanded(
            child: _tab == 0
                ? _LikedSongs(songs: likedSongs, catalog: catalog, onToast: widget.onToast)
                : _BookmarkedAlbums(albums: bookmarkedAlbums, catalog: catalog),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _Tabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int i) {
      final active = i == selected;
      return GestureDetector(
        onTap: () => onSelect(i),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: active ? Colors.white : AppColors.textTertiary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2, width: active ? 28 : 0,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [tab('좋아요한 곡', 0), tab('북마크한 앨범', 1)],
      ),
    );
  }
}

class _LikedSongs extends StatelessWidget {
  final List<Song> songs;
  final CatalogProvider catalog;
  final void Function(Song) onToast;

  const _LikedSongs({required this.songs, required this.catalog, required this.onToast});

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const _EmptyState(text: '좋아요한 곡이 없습니다');
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 180),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final song = songs[i];
        final idx = catalog.indexOfSong(song);
        return SongRow(
          song: song,
          index: i,
          onTap: () {
            context.read<PlayerProvider>().playSongInPlace(idx);
            onToast(song);
          },
          onSwipeAdd: () {
            context.read<PlayerProvider>().addToQueue(idx);
            onToast(song);
          },
        );
      },
    );
  }
}

class _BookmarkedAlbums extends StatelessWidget {
  final List<Album> albums;
  final CatalogProvider catalog;

  const _BookmarkedAlbums({required this.albums, required this.catalog});

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return const _EmptyState(text: '북마크한 앨범이 없습니다');
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 180),
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final album = albums[i];
        final cover = catalog.coverSongOf(album);
        return GestureDetector(
          onTap: () => Navigator.of(context).push(AlbumPage.route(album)),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                if (cover != null)
                  MiniCover(song: cover, size: 56, radius: 12)
                else
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: album.coverGradient,
                      ),
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(album.name, style: AppTextStyles.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${album.artist} · ${album.type.label} · ${catalog.releaseDateOf(album).year}',
                          style: AppTextStyles.monoLabel),
                    ],
                  ),
                ),
                AppIcons.chevronRight(color: AppColors.textFaint),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: AppTextStyles.bodyLight.copyWith(color: AppColors.textTertiary)),
    );
  }
}
