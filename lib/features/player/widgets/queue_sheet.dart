import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock/songs.dart';
import '../../../providers/player_provider.dart';
import '../../shared/icons/app_icons.dart';
import '../../shared/widgets/mini_cover.dart';
import '../../../core/utils/time_format.dart';

class QueueSheet extends StatefulWidget {
  const QueueSheet({super.key});

  @override
  State<QueueSheet> createState() => _QueueSheetState();
}

class _QueueSheetState extends State<QueueSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Cubic(0.4, 0, 0.2, 1)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void show() {
    setState(() => _visible = true);
    _ctrl.forward();
  }

  void hide() {
    _ctrl.reverse().then((_) => setState(() => _visible = false));
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible && _ctrl.isDismissed) return const SizedBox.shrink();
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(onTap: hide, child: Container(color: Colors.transparent)),
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
                    // drag handle
                    GestureDetector(
                      onVerticalDragEnd: (d) {
                        if (d.primaryVelocity != null && d.primaryVelocity! > 300) hide();
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
                      builder: (context, player, _) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Row(
                            children: [
                              Text('QUEUE — ${player.queue.length} TRACKS',
                                style: AppTextStyles.monoLabel),
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
                        );
                      },
                    ),
                    Expanded(
                      child: Consumer<PlayerProvider>(
                        builder: (context, player, _) {
                          return ReorderableListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: player.queue.length,
                            onReorder: player.reorderQueue,
                            itemBuilder: (_, i) {
                              final songIdx = player.queue[i];
                              final song = kSongs[songIdx];
                              final isCurrent = i == player.queuePos;
                              return _QueueItem(
                                key: ValueKey('$i-$songIdx'),
                                song: song,
                                isCurrent: isCurrent,
                                onTap: () => player.play(songIdx),
                                onDelete: player.queue.length > 1
                                    ? () => player.removeFromQueue(i)
                                    : null,
                              );
                            },
                          );
                        },
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

class _QueueItem extends StatefulWidget {
  final dynamic song;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _QueueItem({
    super.key, required this.song, required this.isCurrent,
    required this.onTap, this.onDelete,
  });

  @override
  State<_QueueItem> createState() => _QueueItemState();
}

class _QueueItemState extends State<_QueueItem> {
  double _swipeOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        if (widget.onDelete != null && d.delta.dx < 0) {
          setState(() => _swipeOffset = (_swipeOffset + d.delta.dx).clamp(-100.0, 0.0));
        }
      },
      onHorizontalDragEnd: (d) {
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                    colors: [Colors.transparent, const Color(0xFFC0392B).withOpacity(0.6), const Color(0xFFE74C3C)],
                    stops: const [0, 0.4, 1.0],
                  ),
                ),
                padding: const EdgeInsets.only(right: 20),
                child: AppTextStyles.monoLabel.color != null
                    ? Text('삭제', style: AppTextStyles.monoLabel.copyWith(color: Colors.white))
                    : const Text('삭제'),
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
                  MiniCover(song: widget.song, size: 44),
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
                        Text('${widget.song.artist} · ${formatTime(widget.song.duration.toDouble())}',
                          style: AppTextStyles.caption, maxLines: 1),
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
