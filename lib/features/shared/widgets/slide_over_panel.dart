import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 프로필 패널 위로 우→좌 슬라이드되는 서브뷰 컨테이너.
/// html/Home.html 서브뷰의 transform: translateX(100%)→0 패턴 재현.
/// [builder] 에 전달되는 close 콜백으로 슬라이드 아웃 후 [onClosed] 호출.
class SlideOverPanel extends StatefulWidget {
  final VoidCallback onClosed;
  final Widget Function(BuildContext context, VoidCallback close) builder;

  const SlideOverPanel({super.key, required this.onClosed, required this.builder});

  @override
  State<SlideOverPanel> createState() => _SlideOverPanelState();
}

class _SlideOverPanelState extends State<SlideOverPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Cubic(0.4, 0, 0.2, 1)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() {
    _ctrl.reverse().then((_) => widget.onClosed());
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.bgPanelTop, AppColors.bgPanelBot],
              transform: GradientRotation(160 * 3.14159 / 180),
            ),
          ),
          child: widget.builder(context, _close),
        ),
      ),
    );
  }
}
