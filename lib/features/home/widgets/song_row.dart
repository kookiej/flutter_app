import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';
import '../../../data/models/song.dart';
import '../../shared/widgets/mini_cover.dart';

class SongRow extends StatefulWidget {
  final Song song;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onSwipeAdd;
  final bool showIndex;

  const SongRow({
    super.key,
    required this.song,
    required this.index,
    required this.onTap,
    required this.onSwipeAdd,
    this.showIndex = true,
  });

  @override
  State<SongRow> createState() => _SongRowState();
}

class _SongRowState extends State<SongRow> with SingleTickerProviderStateMixin {
  double _offset = 0;
  bool _blocking = false;
  late AnimationController _snapCtrl;
  late Animation<double> _snapAnim;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _snapAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _snapCtrl, curve: const Cubic(0.4, 0, 0.2, 1)));
    _snapCtrl.addListener(() => setState(() => _offset = _snapAnim.value));
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_blocking) return;
    setState(() => _offset = (_offset + d.delta.dx).clamp(0, 140));
  }

  void _onDragEnd(DragEndDetails d) {
    if (_offset > 70) {
      widget.onSwipeAdd();
      _blocking = true;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _blocking = false);
      });
    }
    _snapAnim = Tween<double>(begin: _offset, end: 0).animate(
        CurvedAnimation(parent: _snapCtrl, curve: const Cubic(0.4, 0, 0.2, 1)));
    _snapCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: _blocking ? null : widget.onTap,
      child: Stack(
        children: [
          // swipe background
          if (_offset > 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0x8C50A078), Colors.transparent],
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                  ),
                ),
                padding: const EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                child: Text('+ 재생목록에 추가',
                  style: AppTextStyles.bodyLight.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.7))),
              ),
            ),
          Transform.translate(
            offset: Offset(_offset, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.transparent,
              child: Row(
                children: [
                  if (widget.showIndex)
                    SizedBox(
                      width: 20,
                      child: Text('${widget.index + 1}', style: AppTextStyles.monoIndex),
                    ),
                  if (widget.showIndex) const SizedBox(width: 10),
                  MiniCover(song: widget.song, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.song.title,
                          style: AppTextStyles.body.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(widget.song.artist,
                          style: AppTextStyles.artistLabel, maxLines: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(formatTime(widget.song.duration.toDouble()), style: AppTextStyles.monoTime),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
