import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';
import '../../../data/models/song.dart';

class PlayerProgressBar extends StatefulWidget {
  final Song song;
  final double currentTime;
  final ValueChanged<double> onSeek;

  const PlayerProgressBar({
    super.key, required this.song, required this.currentTime, required this.onSeek,
  });

  @override
  State<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends State<PlayerProgressBar> {
  bool _dragging = false;
  double _dragValue = 0;

  double get _displayTime => _dragging ? _dragValue : widget.currentTime;
  double get _progress => (_displayTime / widget.song.duration).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          GestureDetector(
            onHorizontalDragStart: (d) {
              setState(() {
                _dragging = true;
                final box = context.findRenderObject() as RenderBox;
                _dragValue = (d.localPosition.dx / box.size.width * widget.song.duration)
                    .clamp(0, widget.song.duration.toDouble());
              });
            },
            onHorizontalDragUpdate: (d) {
              setState(() {
                final box = context.findRenderObject() as RenderBox;
                _dragValue = (d.localPosition.dx / box.size.width * widget.song.duration)
                    .clamp(0, widget.song.duration.toDouble());
              });
            },
            onHorizontalDragEnd: (_) {
              widget.onSeek(_dragValue);
              setState(() => _dragging = false);
            },
            onTapDown: (d) {
              final box = context.findRenderObject() as RenderBox;
              final v = (d.localPosition.dx / box.size.width * widget.song.duration)
                  .clamp(0.0, widget.song.duration.toDouble());
              widget.onSeek(v);
            },
            child: SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.12),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: LayoutBuilder(
                        builder: (_, constraints) => Container(
                          width: constraints.maxWidth * _progress,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [widget.song.accent.withOpacity(0.53), widget.song.accent],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(_progress * 2 - 1, 0),
                    child: Container(
                      width: _dragging ? 16 : 10,
                      height: _dragging ? 16 : 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: widget.song.accent.withOpacity(0.53), blurRadius: 12)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatTime(_displayTime), style: AppTextStyles.monoTime.copyWith(color: Colors.white.withOpacity(0.35))),
              Text(formatTime(widget.song.duration.toDouble()), style: AppTextStyles.monoTime.copyWith(color: Colors.white.withOpacity(0.35))),
            ],
          ),
        ],
      ),
    );
  }
}
