import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/artist.dart';
import '../../data/models/song.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../album/album_page.dart';
import '../album/widgets/album_card.dart';
import '../album/widgets/spotify_album_card.dart';
import '../home/see_all_page.dart';
import '../home/widgets/section_header.dart';
import '../home/widgets/song_row.dart';
import '../shared/widgets/panel_sub_header.dart';
import '../shared/widgets/play_all_button.dart';
import '../shared/widgets/toast_snackbar.dart';
import 'artist_albums_page.dart';

/// 아티스트 채널 — 아티스트 정보 + 인기곡 + 발매 앨범.
class ArtistPage extends StatefulWidget {
  final Artist artist;

  const ArtistPage({super.key, required this.artist});

  static Route<void> route(Artist artist) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => ArtistPage(artist: artist),
      transitionsBuilder: (_, animation, _, child) {
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: const Cubic(0.4, 0, 0.2, 1)));
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  Song? _toastSong;

  void _showToast(Song song) => setState(() => _toastSong = song);

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final catalog = context.watch<CatalogProvider>();
    final songIndices = catalog.songIndicesByArtist(artist.name);
    final albums = catalog.albumsByArtist(artist.name);
    final discography = catalog.discographyOf(artist.name); // Spotify 발매 앨범
    final popularIndices = songIndices.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                PanelSubHeader(title: artist.name, onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 40),
                    children: [
                      _ArtistHeader(artist: artist),
                      const SizedBox(height: 24),
                      // 인기 곡
                      SectionHeader(
                        title: '인기 곡',
                        trailing: popularIndices.isNotEmpty
                            ? PlayAllButton(
                                onTap: () =>
                                    context.read<PlayerProvider>().playAll(popularIndices),
                              )
                            : null,
                        action: songIndices.length > popularIndices.length ? '전체보기 >' : null,
                        onAction: () => Navigator.of(context).push(
                            SeeAllPage.route(title: '${artist.name} · 인기 곡', songIndices: songIndices)),
                      ),
                      ...popularIndices.map((idx) {
                        final song = catalog.songs[idx];
                        return SongRow(
                          song: song,
                          index: popularIndices.indexOf(idx),
                          onTap: () {
                            context.read<PlayerProvider>().playSongInPlace(idx);
                            _showToast(song);
                          },
                          onSwipeAdd: () {
                            context.read<PlayerProvider>().addToQueue(idx);
                            _showToast(song);
                          },
                        );
                      }),
                      // 발매 앨범 — Spotify 디스코그래피 우선, 없으면 목업
                      if (discography.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const SectionHeader(title: '발매 앨범'),
                        SizedBox(
                          height: 196,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: discography.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 16),
                            itemBuilder: (_, i) {
                              final meta = discography[i];
                              return SpotifyAlbumCard(
                                album: meta,
                                onTap: () => Navigator.of(context).push(
                                    AlbumPage.route(catalog.albumForSpotify(meta, artist.name))),
                              );
                            },
                          ),
                        ),
                      ] else if (albums.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SectionHeader(
                          title: '발매 앨범',
                          action: '전체보기 >',
                          onAction: () => Navigator.of(context).push(
                              ArtistAlbumsPage.route(artist.name)),
                        ),
                        SizedBox(
                          height: 196,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: albums.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 16),
                            itemBuilder: (_, i) {
                              final album = albums[i];
                              return AlbumCard(
                                album: album,
                                coverSong: catalog.coverSongOf(album),
                                onTap: () => Navigator.of(context).push(AlbumPage.route(album)),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (_toastSong != null)
              Positioned(
                left: 0, right: 0, bottom: 24,
                child: ToastSnackbar(song: _toastSong!, onDone: () => setState(() => _toastSong = null)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArtistHeader extends StatelessWidget {
  final Artist artist;
  const _ArtistHeader({required this.artist});

  @override
  Widget build(BuildContext context) {
    const double size = 130;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.3),
                colors: [artist.color.withOpacity(0.53), artist.color.withOpacity(0.13)],
              ),
              border: Border.all(color: artist.color.withOpacity(0.27), width: 1.5),
            ),
            alignment: Alignment.center,
            child: artist.imageUrl != null
                ? ClipOval(
                    child: Image.network(artist.imageUrl!, width: size, height: size, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _initial()),
                  )
                : _initial(),
          ),
          const SizedBox(height: 16),
          Text(artist.name, style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _initial() => Text(
        artist.name[0],
        style: AppTextStyles.pageTitle.copyWith(fontSize: 48),
      );
}
