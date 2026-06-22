import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/time_format.dart';
import '../../data/models/album.dart';
import '../../data/models/song.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../artist/artist_page.dart';
import '../shared/icons/app_icons.dart';
import '../shared/widgets/mini_cover.dart';
import '../shared/widgets/panel_sub_header.dart';
import '../shared/widgets/play_all_button.dart';
import '../shared/widgets/toast_snackbar.dart';

/// 곡이 수록된 앨범 페이지 — 앨범 정보 + 수록곡 + 북마크.
class AlbumPage extends StatefulWidget {
  final Album album;

  const AlbumPage({super.key, required this.album});

  static Route<void> route(Album album) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => AlbumPage(album: album),
      transitionsBuilder: (_, animation, _, child) {
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: const Cubic(0.4, 0, 0.2, 1)));
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  Song? _toastSong;

  void _showToast(Song song) => setState(() => _toastSong = song);

  @override
  void initState() {
    super.initState();
    // 진입 시 Spotify 전체 수록곡 lazy 조회 (로그인+매칭 시에만 동작, 아니면 목업 유지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CatalogProvider>().ensureAlbumTracks(widget.album);
    });
  }

  /// Spotify 트랙명에 대응하는 큐레이션 곡 (재생 가능 여부 판단).
  Song? _curatedFor(CatalogProvider catalog, String title) {
    for (final s in catalog.songs) {
      if (s.artist == widget.album.artist && s.title == title) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final catalog = context.watch<CatalogProvider>();
    final coverSong = catalog.coverSongOf(album);
    final coverUrl = catalog.spotifyAlbumNamed(album.name)?.imageUrl;
    final releaseDate = catalog.releaseDateOf(album);

    // Spotify 전체 수록곡이 있으면 그것을, 없으면 큐레이션 수록곡을 사용
    final spotifyTracks = catalog.spotifyTracksOf(album);
    final useSpotify = spotifyTracks.isNotEmpty;
    final curatedTracks = catalog.tracksOf(album);

    final trackCount = useSpotify ? spotifyTracks.length : curatedTracks.length;
    final totalSeconds = useSpotify
        ? spotifyTracks.fold<int>(0, (sum, t) => sum + t.durationSeconds)
        : curatedTracks.fold<int>(0, (sum, s) => sum + s.duration);

    final List<Widget> trackRows = useSpotify
        ? spotifyTracks.map((t) {
            final curated = _curatedFor(catalog, t.name);
            return _AlbumTrackRow(
              number: t.trackNumber,
              title: t.name,
              durationSeconds: t.durationSeconds,
              isTitle: album.isTitleTrack(t.name),
              song: curated,
              onTap: curated == null
                  ? null
                  : () {
                      context.read<PlayerProvider>().playSongInPlace(catalog.indexOfSong(curated));
                      _showToast(curated);
                    },
            );
          }).toList()
        : curatedTracks.map((s) {
            return _AlbumTrackRow(
              number: null,
              title: s.title,
              durationSeconds: s.duration,
              isTitle: album.isTitleTrack(s.title),
              song: s,
              onTap: () {
                context.read<PlayerProvider>().playSongInPlace(catalog.indexOfSong(s));
                _showToast(s);
              },
            );
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                PanelSubHeader(
                  title: album.name,
                  onBack: () => Navigator.of(context).pop(),
                  right: _BookmarkButton(album: album),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 40),
                    children: [
                      _AlbumHeader(
                        album: album,
                        coverSong: coverSong,
                        coverUrl: coverUrl,
                        releaseDate: releaseDate,
                      ),
                      const SizedBox(height: 20),
                      ...trackRows,
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$trackCount곡 · ${formatTotalDuration(totalSeconds)}',
                          style: AppTextStyles.monoLabel,
                          textAlign: TextAlign.center,
                        ),
                      ),
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

class _AlbumHeader extends StatelessWidget {
  final Album album;
  final Song? coverSong;
  final String? coverUrl;
  final DateTime releaseDate;

  const _AlbumHeader({
    required this.album,
    required this.coverSong,
    required this.coverUrl,
    required this.releaseDate,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          // Spotify 앨범 커버가 있으면 네트워크 이미지, 없으면 대표곡 커버
          if (coverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(coverUrl!, width: 200, height: 200, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => MiniCover(song: cover, size: 200, radius: 16)),
            )
          else
            MiniCover(song: cover, size: 200, radius: 16),
          const SizedBox(height: 20),
          Text(album.name, style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          // 아티스트명 — 탭하면 아티스트 채널로 이동
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final catalog = context.read<CatalogProvider>();
              Navigator.of(context).push(ArtistPage.route(catalog.artistByName(album.artist)));
            },
            child: Text(album.artist,
                style: AppTextStyles.body.copyWith(color: AppColors.accent)),
          ),
          const SizedBox(height: 6),
          Text('${album.type.label} · ${formatReleaseDate(releaseDate)}',
              style: AppTextStyles.caption),
          const SizedBox(height: 18),
          // 앨범 전체 듣기 — 아이콘만
          PlayAllButton(
            size: 44,
            onTap: () {
              final catalog = context.read<CatalogProvider>();
              context.read<PlayerProvider>().playAll(catalog.trackIndicesOf(album));
            },
          ),
        ],
      ),
    );
  }
}

class _AlbumTrackRow extends StatelessWidget {
  /// Spotify 트랙 번호 (목업 모드에선 null → 커버 표시)
  final int? number;
  final String title;
  final int durationSeconds;
  final bool isTitle;

  /// 재생 가능한 큐레이션 곡 (없으면 표시 전용)
  final Song? song;
  final VoidCallback? onTap;

  const _AlbumTrackRow({
    required this.number,
    required this.title,
    required this.durationSeconds,
    required this.isTitle,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final playable = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: playable ? 1.0 : 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // 큐레이션 곡은 커버, Spotify 비매칭 곡은 트랙 번호
              if (song != null)
                MiniCover(song: song!, size: 48)
              else
                SizedBox(
                  width: 48,
                  child: Text(
                    number != null ? '$number' : '',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.monoLabel,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              style: AppTextStyles.body.copyWith(fontSize: 14),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (isTitle) ...[
                          const SizedBox(width: 8),
                          const _TitleBadge(),
                        ],
                      ],
                    ),
                    Text(song?.artist ?? '', style: AppTextStyles.artistLabel, maxLines: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(formatTime(durationSeconds.toDouble()), style: AppTextStyles.monoTime),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleBadge extends StatelessWidget {
  const _TitleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.accent.withOpacity(0.18),
      ),
      child: Text('TITLE',
          style: AppTextStyles.monoLabel.copyWith(
              fontSize: 8, letterSpacing: 1, color: AppColors.accent)),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final Album album;
  const _BookmarkButton({required this.album});

  @override
  Widget build(BuildContext context) {
    final bookmarked = context.watch<BookmarkProvider>().isBookmarked(album);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<BookmarkProvider>().toggle(album),
      child: SizedBox(
        width: 40, height: 40,
        child: Center(child: AppIcons.bookmark(filled: bookmarked)),
      ),
    );
  }
}
