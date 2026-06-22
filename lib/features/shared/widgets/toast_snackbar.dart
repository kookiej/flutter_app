import 'package:flutter/material.dart';
import '../../../data/models/song.dart';
import '../../../core/theme/app_text_styles.dart';

class ToastSnackbar extends StatefulWidget {
  final Song? song;
  final String? message;
  final VoidCallback onDone;

  const ToastSnackbar({super.key, this.song, this.message, required this.onDone})
      : assert(song != null || message != null);

  @override
  State<ToastSnackbar> createState() => _ToastSnackbarState();
}

class _ToastSnackbarState extends State<ToastSnackbar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: Padding(
          // 배경 없이 텍스트만 — 텍스트 크기에 맞춘 최소 여백
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.message ?? '재생목록에 추가됨 · ${widget.song!.title} — ${widget.song!.artist}',
            style: AppTextStyles.bodyLight.copyWith(
              fontSize: 13,
              // 배경이 없으므로 가독성용 미세 그림자
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
