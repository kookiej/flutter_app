import 'package:flutter/material.dart';
import 'player_page.dart';

/// 미니 플레이어 탭 시 아래에서 올라오는 풀 플레이어 오버레이.
/// 아티스트/앨범 이동 콜백은 셸이 제공(활성 탭 Navigator로 push)해
/// 이동 후에도 미니 플레이어/하단 탭이 유지된다.
class PlayerOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onArtistTap;
  final VoidCallback? onAlbumTap;

  const PlayerOverlay({
    super.key,
    required this.onClose,
    this.onArtistTap,
    this.onAlbumTap,
  });

  @override
  State<PlayerOverlay> createState() => _PlayerOverlayState();
}

class _PlayerOverlayState extends State<PlayerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Cubic(0.4, 0, 0.2, 1)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() async {
    await _ctrl.reverse();
    widget.onClose();
  }

  // 오버레이를 닫은 뒤 이동 콜백 실행 (라우트 push는 셸이 활성 탭 Navigator로 처리)
  void _navTo(VoidCallback? action) async {
    if (action == null) return;
    await _ctrl.reverse();
    widget.onClose();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => SlideTransition(
        position: _slide,
        child: Transform.translate(offset: Offset(0, _dragOffset), child: child),
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (d) {
          if (d.delta.dy > 0) setState(() => _dragOffset += d.delta.dy);
        },
        onVerticalDragEnd: (_) {
          if (_dragOffset > 120) {
            _close();
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: PlayerPage(
            onClose: _close,
            onArtistTap: widget.onArtistTap == null ? null : () => _navTo(widget.onArtistTap),
            onAlbumTap: widget.onAlbumTap == null ? null : () => _navTo(widget.onAlbumTap),
          ),
        ),
      ),
    );
  }
}
