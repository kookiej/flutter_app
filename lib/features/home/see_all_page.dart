import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/artist.dart';
import '../../data/models/song.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../artist/artist_page.dart';
import '../shared/icons/app_icons.dart';
import '../shared/widgets/panel_sub_header.dart';
import '../shared/widgets/toast_snackbar.dart';
import 'widgets/song_row.dart';

/// 홈 섹션 "전체보기" — 전체 곡 리스트 또는 전체 아티스트 리스트.
class SeeAllPage extends StatefulWidget {
  final String title;
  final List<int>? songIndices; // catalog.songs 인덱스 (곡 리스트용)
  final List<Artist>? artists; // 아티스트 리스트용

  const SeeAllPage({super.key, required this.title, this.songIndices, this.artists})
      : assert(songIndices != null || artists != null);

  /// 우→좌 슬라이드 라우트.
  static Route<void> route({required String title, List<int>? songIndices, List<Artist>? artists}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) =>
          SeeAllPage(title: title, songIndices: songIndices, artists: artists),
      transitionsBuilder: (_, animation, _, child) {
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: const Cubic(0.4, 0, 0.2, 1)));
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  Song? _toastSong;

  void _showToast(Song song) => setState(() => _toastSong = song);

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                PanelSubHeader(title: widget.title, onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: widget.artists != null
                      ? _buildArtists(widget.artists!)
                      : _buildSongs(context, catalog),
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

  Widget _buildSongs(BuildContext context, CatalogProvider catalog) {
    final indices = widget.songIndices!;
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      itemCount: indices.length,
      itemBuilder: (_, i) {
        final idx = indices[i];
        final song = catalog.songs[idx];
        return SongRow(
          song: song,
          index: i,
          onTap: () {
            context.read<PlayerProvider>().playSongInPlace(idx);
            _showToast(song);
          },
          onSwipeAdd: () {
            context.read<PlayerProvider>().addToQueue(idx);
            _showToast(song);
          },
        );
      },
    );
  }

  Widget _buildArtists(List<Artist> artists) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(ArtistPage.route(a)),
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.2, -0.3),
                    colors: [a.color.withOpacity(0.53), a.color.withOpacity(0.13)],
                  ),
                  border: Border.all(color: a.color.withOpacity(0.27), width: 1.5),
                ),
                alignment: Alignment.center,
                child: a.imageUrl != null
                    ? ClipOval(
                        child: Image.network(a.imageUrl!, width: 54, height: 54, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _initial(a)),
                      )
                    : _initial(a),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: AppTextStyles.body),
                    const SizedBox(height: 2),
                    Text('${a.songs}곡', style: AppTextStyles.monoLabel),
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

  Widget _initial(Artist a) => Text(
        a.name[0],
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
      );
}
