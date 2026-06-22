import 'dart:math' show pi;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/song.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/like_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/sync_provider.dart';
import '../shared/icons/app_icons.dart';
import '../shared/widgets/mini_cover.dart';
import '../shared/widgets/noise_overlay.dart';
import 'widgets/album_cover.dart';
import 'widgets/control_buttons.dart';
import 'widgets/lyrics_panel.dart';
import 'widgets/more_menu_sheet.dart';
import 'widgets/progress_bar.dart';

class PlayerPage extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onArtistTap;
  final VoidCallback? onAlbumTap;

  const PlayerPage({super.key, required this.onClose, this.onArtistTap, this.onAlbumTap});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool _queueVisible = false;

  void _openMoreMenu(Song song, String? fanchantVideoUrl) {
    // 매칭 앨범이 있을 때만 '앨범 보러 가기' 노출
    final hasAlbum = context.read<CatalogProvider>().albumFor(song) != null;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => MoreMenuSheet(
        song: song,
        fanchantVideoUrl: fanchantVideoUrl,
        onArtist: widget.onArtistTap,
        onAlbum: hasAlbum ? widget.onAlbumTap : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final song = context.watch<CatalogProvider>().songs[player.songIdx];
        final sync = context.watch<SyncProvider>();
        final hasFanchant = sync.hasFanchant;
        final showLyrics = sync.showLyrics;
        // 모드는 SyncProvider가 보유(곡 전환 시 리셋, 닫기/열기엔 유지). 응원법 없으면 OFF.
        final fanchantMode = sync.fanchantOn;
        return Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: AppColors.bgPrimary)),

            // animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 1200),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1.1),
                  radius: 1.3,
                  colors: [
                    song.colors[2].withOpacity(0.8),
                    song.colors[1].withOpacity(0.53),
                    song.colors[0],
                    const Color(0xFF060608),
                  ],
                  stops: const [0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
            const NoiseOverlay(),
            SafeArea(
              child: Column(
                children: [
                  // top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            width: 40, height: 40,
                            alignment: Alignment.center,
                            child: AppIcons.chevronDown(color: Colors.white.withOpacity(0.6)),
                          ),
                        ),
                        Expanded(
                          child: Text('NOW PLAYING',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.monoLabel.copyWith(letterSpacing: 2, color: Colors.white.withOpacity(0.35))),
                        ),
                        GestureDetector(
                          onTap: () => _openMoreMenu(song, sync.fanchantVideoUrl),
                          child: Container(
                            width: 40, height: 40,
                            alignment: Alignment.center,
                            child: AppIcons.more(color: Colors.white.withOpacity(0.6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // album cover + lyrics overlay
                  // 가사 패널을 Stack 경계 안에 두어야 탭이 인식된다 (경계 밖은 히트테스트 안 됨)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: showLyrics ? 52 : 0),
                        child: PlayerAlbumCover(song: song, isPlaying: player.isPlaying),
                      ),
                      // 현재곡의 가사/응원법이 DB에 있을 때만 가사 영역 표시
                      if (showLyrics)
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          child: LyricsPanel(
                            key: ValueKey(player.songIdx), // 곡 전환 시 패널 재생성 → 축소 기본값 복귀
                            song: song,
                            entries: sync.data!.entries,
                            currentTime: player.currentTime,
                            fanchantMode: fanchantMode,
                            onSeek: player.seek,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // song info + like
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title, style: AppTextStyles.songTitleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: widget.onArtistTap,
                                      child: Text(song.artist,
                                        style: AppTextStyles.bodyLight.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  Text(' · ',
                                    style: AppTextStyles.bodyLight.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: widget.onAlbumTap,
                                      child: Text(song.album,
                                        style: AppTextStyles.bodyLight.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Builder(builder: (context) {
                          final liked = context.watch<LikeProvider>().isLiked(song);
                          return GestureDetector(
                            onTap: () => context.read<LikeProvider>().toggle(song),
                            child: Container(
                              width: 44, height: 44,
                              alignment: Alignment.center,
                              child: AppIcons.heart(filled: liked, color: liked ? song.accent : Colors.white.withOpacity(0.5)),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // progress bar
                  PlayerProgressBar(
                    song: song,
                    currentTime: player.currentTime,
                    onSeek: player.seek,
                  ),
                  const SizedBox(height: 24),
                  // controls
                  ControlButtons(song: song),
                  const SizedBox(height: 24),
                  // fanchant + queue
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FanchantButton(
                          active: fanchantMode,
                          enabled: hasFanchant,
                          accent: song.accent,
                          onTap: sync.toggleFanchant,
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _queueVisible = true),
                          child: Container(
                            width: 40, height: 40,
                            alignment: Alignment.center,
                            child: AppIcons.queue(color: AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // queue sheet (overlay)
            if (_queueVisible)
              _QueueSheetWrapper(onClose: () => setState(() => _queueVisible = false)),
          ],
        );
      },
    );
  }
}

class _QueueSheetWrapper extends StatefulWidget {
  final VoidCallback onClose;
  const _QueueSheetWrapper({required this.onClose});

  @override
  State<_QueueSheetWrapper> createState() => _QueueSheetState();
}

class _QueueSheetState extends State<_QueueSheetWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Cubic(0.4, 0, 0.2, 1)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _hide() {
    _ctrl.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // 시트 상단 = 앨범 커버 세로 중앙 (프로토타입 coverMid)
    final coverH = (media.size.width - 56).clamp(0.0, 300.0);
    final coverTop = media.padding.top + 16 + 40 + 20; // SafeArea + 상단바(패딩16+높이40) + SizedBox(20)
    final sheetHeight = media.size.height - (coverTop + coverH / 2);
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(onTap: _hide, child: Container(color: Colors.transparent)),
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: sheetHeight,
            child: SlideTransition(
              position: _slide,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgPanel,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(color: Colors.white.withOpacity(0.044)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onVerticalDragEnd: (d) {
                        if (d.primaryVelocity != null && d.primaryVelocity! > 300) _hide();
                      },
                      child: Container(
                        height: 40, color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Container(
                          width: 36, height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    Consumer<PlayerProvider>(
                      builder: (context, player, _) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Row(
                          children: [
                            Text('QUEUE — ${player.queue.length} TRACKS', style: AppTextStyles.monoLabel),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => player.toggleShuffle(),
                              child: Opacity(
                                opacity: player.shuffle ? 1.0 : 0.25,
                                child: AppIcons.shuffle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => player.toggleRepeat(),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 28, height: 28,
                                    child: Opacity(
                                      opacity: player.repeat > 0 ? 1.0 : 0.25,
                                      child: Center(child: AppIcons.repeat(color: Colors.white)),
                                    ),
                                  ),
                                  if (player.repeat == 2)
                                    const Text('1', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Consumer<PlayerProvider>(
                        builder: (context, player, _) => ReorderableListView.builder(
                          padding: EdgeInsets.zero,
                          buildDefaultDragHandles: false,
                          itemCount: player.queue.length,
                          onReorder: player.reorderQueue,
                          itemBuilder: (_, i) {
                            final songIdx = player.queue[i];
                            final song = context.read<CatalogProvider>().songs[songIdx];
                            final isCurrent = i == player.queuePos;
                            return _QueueRowItem(
                              key: ValueKey('q-$i-$songIdx'),
                              index: i,
                              song: song,
                              isCurrent: isCurrent,
                              onTap: () => player.play(songIdx),
                              onDelete: player.queue.length > 1 ? () => player.removeFromQueue(i) : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 응원봉 버튼 — 활성 시 -30° 회전 + 펄스 글로우 (프로토타입 fanchantGlow)
class _FanchantButton extends StatefulWidget {
  final bool active;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;

  const _FanchantButton({
    required this.active,
    required this.enabled,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_FanchantButton> createState() => _FanchantButtonState();
}

class _FanchantButtonState extends State<_FanchantButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_FanchantButton old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      if (widget.active) {
        _ctrl.repeat(reverse: true);
      } else {
        _ctrl.stop();
        _ctrl.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 활성 글로우 — 아이콘·글로우 모두 흰색
    final Widget activeIcon = AnimatedBuilder(
      key: const ValueKey('on'),
      animation: _ctrl,
      builder: (context, _) {
        final sigma = 3.0 + 4.0 * _ctrl.value; // 3 → 7px 펄스
        return Stack(
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: AppIcons.fanchant(color: Colors.white),
            ),
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma * 0.5, sigmaY: sigma * 0.5),
              child: AppIcons.fanchant(color: Colors.white),
            ),
            AppIcons.fanchant(color: Colors.white),
          ],
        );
      },
    );
    final Widget inactiveIcon = KeyedSubtree(
      key: const ValueKey('off'),
      child: AppIcons.fanchant(color: AppColors.textTertiary),
    );

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44, height: 44,
        child: Center(
          child: Transform.rotate(
            angle: -30 * pi / 180,
            // enabled 전환을 부드럽게 (비활성 곡 → 활성 곡 스킵 시 dim→bright)
            child: AnimatedOpacity(
              opacity: widget.enabled ? 1.0 : 0.35,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // active↔inactive 아이콘 교체를 페이드로
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.active ? activeIcon : inactiveIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueRowItem extends StatefulWidget {
  final int index;
  final Song song;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _QueueRowItem({
    super.key, required this.index, required this.song, required this.isCurrent,
    required this.onTap, this.onDelete,
  });

  @override
  State<_QueueRowItem> createState() => _QueueRowItemState();
}

class _QueueRowItemState extends State<_QueueRowItem> {
  double _swipeOffset = 0;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return GestureDetector(
      onHorizontalDragStart: (_) {
        if (widget.onDelete != null) setState(() => _dragging = true);
      },
      onHorizontalDragUpdate: (d) {
        if (widget.onDelete != null && (_swipeOffset < 0 || d.delta.dx < 0)) {
          setState(() => _swipeOffset = (_swipeOffset + d.delta.dx).clamp(-100.0, 0.0));
        }
      },
      onHorizontalDragEnd: (_) {
        if (_swipeOffset < -60 && widget.onDelete != null) {
          // 화면 밖으로 슬라이드 후 제거 (프로토타입 220ms)
          setState(() { _dragging = false; _swipeOffset = -screenW; });
          Future.delayed(const Duration(milliseconds: 220), () {
            if (mounted) widget.onDelete!();
          });
        } else {
          setState(() { _dragging = false; _swipeOffset = 0; });
        }
      },
      onTap: widget.onTap,
      child: Stack(
        children: [
          if (_swipeOffset < 0)
            Positioned.fill(
              child: Container(
                alignment: Alignment.centerRight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xFFC0392B), Color(0xFFE74C3C)],
                    stops: [0, 0.4, 1.0],
                  ),
                ),
                padding: const EdgeInsets.only(right: 20),
                child: Text('삭제', style: AppTextStyles.monoLabel.copyWith(color: Colors.white)),
              ),
            ),
          AnimatedContainer(
            duration: _dragging ? Duration.zero : const Duration(milliseconds: 220),
            curve: const Cubic(0.4, 0, 0.2, 1),
            transform: Matrix4.translationValues(_swipeOffset, 0, 0),
            child: Container(
              height: 64,
              color: widget.isCurrent ? const Color(0xFF1C1C24) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  MiniCover(song: widget.song, size: 44, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.song.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: widget.isCurrent ? FontWeight.w600 : FontWeight.w400),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${widget.song.artist} · ${widget.song.duration ~/ 60}:${(widget.song.duration % 60).toString().padLeft(2, '0')}',
                          style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: widget.index,
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: AppIcons.drag(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
