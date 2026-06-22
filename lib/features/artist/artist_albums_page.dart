import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/time_format.dart';
import '../../data/models/album.dart';
import '../../data/models/song.dart';
import '../../providers/catalog_provider.dart';
import '../album/album_page.dart';
import '../shared/icons/app_icons.dart';
import '../shared/widgets/mini_cover.dart';
import '../shared/widgets/panel_sub_header.dart';

/// 아티스트 발매 앨범 전체보기 — 앨범 타입별 필터.
class ArtistAlbumsPage extends StatefulWidget {
  final String artistName;

  const ArtistAlbumsPage({super.key, required this.artistName});

  static Route<void> route(String artistName) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => ArtistAlbumsPage(artistName: artistName),
      transitionsBuilder: (_, animation, _, child) {
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: const Cubic(0.4, 0, 0.2, 1)));
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  @override
  State<ArtistAlbumsPage> createState() => _ArtistAlbumsPageState();
}

class _ArtistAlbumsPageState extends State<ArtistAlbumsPage> {
  // null = 전체
  AlbumType? _filter;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final all = catalog.albumsByArtist(widget.artistName);
    final filtered = _filter == null ? all : all.where((a) => a.type == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PanelSubHeader(
                title: '${widget.artistName} · 발매 앨범',
                onBack: () => Navigator.of(context).pop()),
            _FilterChips(
              selected: _filter,
              onSelect: (t) => setState(() => _filter = t),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 40),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final album = filtered[i];
                  return _AlbumRow(
                    album: album,
                    coverSong: catalog.coverSongOf(album),
                    onTap: () => Navigator.of(context).push(AlbumPage.route(album)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final AlbumType? selected;
  final ValueChanged<AlbumType?> onSelect;

  const _FilterChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = <(String, AlbumType?)>[
      ('전체', null),
      ('정규', AlbumType.regular),
      ('미니', AlbumType.mini),
      ('싱글', AlbumType.single),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, type) = items[i];
          final active = type == selected;
          return GestureDetector(
            onTap: () => onSelect(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: active
                    ? const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF4A2FA0), Color(0xFF7C3AED)])
                    : null,
                color: active ? null : Colors.white.withOpacity(0.06),
                border: active ? null : Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: active
                    ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: active ? Colors.white : Colors.white.withOpacity(0.45),
                  fontWeight: active ? FontWeight.w500 : FontWeight.w300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlbumRow extends StatelessWidget {
  final Album album;
  final Song? coverSong;
  final VoidCallback onTap;

  const _AlbumRow({required this.album, required this.coverSong, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cover = coverSong;
    return GestureDetector(
      onTap: onTap,
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
                  Text('${album.type.label} · ${formatReleaseDate(album.releaseDate)}',
                      style: AppTextStyles.monoLabel),
                ],
              ),
            ),
            AppIcons.chevronRight(color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }
}
