import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/songs.dart';
import '../../providers/player_provider.dart';
import '../shared/icons/app_icons.dart';
import '../shared/widgets/noise_overlay.dart';
import 'widgets/album_cover.dart';
import 'widgets/control_buttons.dart';
import 'widgets/lyrics_panel.dart';
import 'widgets/progress_bar.dart';

class PlayerPage extends StatefulWidget {
  final VoidCallback onClose;

  const PlayerPage({super.key, required this.onClose});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool _liked = false;
  bool _fanchantMode = false;
  bool _queueVisible = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final song = player.currentSong;
        return Stack(
          children: [

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
                          onTap: () {},
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
                  // album cover
                  PlayerAlbumCover(song: song, isPlaying: player.isPlaying),
                  const SizedBox(height: 20),
                  // lyrics panel
                  LyricsPanel(
                    song: song,
                    currentTime: player.currentTime,
                    fanchantMode: _fanchantMode,
                    onSeek: player.seek,
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
                              Text('${song.artist} · ${song.album}',
                                style: AppTextStyles.bodyLight.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _liked = !_liked),
                          child: Container(
                            width: 44, height: 44,
                            alignment: Alignment.center,
                            child: AppIcons.heart(filled: _liked, color: _liked ? song.accent : Colors.white.withOpacity(0.5)),
                          ),
                        ),
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
                        GestureDetector(
                          onTap: () => setState(() => _fanchantMode = !_fanchantMode),
                          child: Container(
                            width: 40, height: 40,
                            alignment: Alignment.center,
                            child: AppIcons.fanchant(
                              color: _fanchantMode ? song.accent : AppColors.textTertiary),
                          ),
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
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(onTap: _hide, child: Container(color: Colors.transparent)),
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: MediaQuery.of(context).size.height * 0.6,
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
                              child: AppIcons.shuffle(color: player.shuffle ? AppColors.accent : AppColors.textTertiary),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => player.toggleRepeat(),
                              child: AppIcons.repeat(color: player.repeat > 0 ? AppColors.accent : AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Consumer<PlayerProvider>(
                        builder: (context, player, _) => ReorderableListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: player.queue.length,
                          onReorder: player.reorderQueue,
                          itemBuilder: (_, i) {
                            final songIdx = player.queue[i];
                            final song = kSongs[songIdx];
                            final isCurrent = i == player.queuePos;
                            return _QueueRowItem(
                              key: ValueKey('q-$i-$songIdx'),
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

class _QueueRowItem extends StatefulWidget {
  final dynamic song;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _QueueRowItem({
    super.key, required this.song, required this.isCurrent,
    required this.onTap, this.onDelete,
  });

  @override
  State<_QueueRowItem> createState() => _QueueRowItemState();
}

class _QueueRowItemState extends State<_QueueRowItem> {
  double _swipeOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        if (widget.onDelete != null && d.delta.dx < 0) {
          setState(() => _swipeOffset = (_swipeOffset + d.delta.dx).clamp(-100.0, 0.0));
        }
      },
      onHorizontalDragEnd: (_) {
        if (_swipeOffset < -60 && widget.onDelete != null) {
          widget.onDelete!();
        } else {
          setState(() => _swipeOffset = 0);
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
          Transform.translate(
            offset: Offset(_swipeOffset, 0),
            child: Container(
              height: 64,
              color: widget.isCurrent ? const Color(0xFF1C1C24) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: widget.song.coverGradient,
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  ),
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
                  AppIcons.drag(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
