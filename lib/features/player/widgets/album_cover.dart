import 'package:flutter/material.dart';
import '../../../data/models/song.dart';

class PlayerAlbumCover extends StatefulWidget {
  final Song song;
  final bool isPlaying;

  const PlayerAlbumCover({super.key, required this.song, required this.isPlaying});

  @override
  State<PlayerAlbumCover> createState() => _PlayerAlbumCoverState();
}

class _PlayerAlbumCoverState extends State<PlayerAlbumCover> with SingleTickerProviderStateMixin {
  late final AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    if (!widget.isPlaying) _rotCtrl.stop();
  }

  @override
  void didUpdateWidget(PlayerAlbumCover old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      if (widget.isPlaying) _rotCtrl.repeat(); else _rotCtrl.stop();
    }
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: song.coverGradient,
            ),
            boxShadow: [
              BoxShadow(color: song.coverAccent.withOpacity(0.33), blurRadius: 80, spreadRadius: -8, offset: const Offset(0, 32)),
              BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 32, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // vinyl inner ring (rotating)
                RotationTransition(
                  turns: _rotCtrl,
                  child: FractionallySizedBox(
                    widthFactor: 0.42, heightFactor: 0.42,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.black.withOpacity(0.9),
                            song.coverAccent.withOpacity(0.27),
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.3, 0.7, 1.0],
                        ),
                        border: Border.all(color: song.accent.withOpacity(0.2), width: 1),
                        boxShadow: [BoxShadow(color: song.coverAccent.withOpacity(0.27), blurRadius: 40)],
                      ),
                    ),
                  ),
                ),
                // center dot
                FractionallySizedBox(
                  widthFactor: 0.10, heightFactor: 0.10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: song.accent.withOpacity(0.4), width: 2),
                    ),
                  ),
                ),
                // stripe overlay
                Positioned.fill(child: CustomPaint(painter: _StripesPainter(song.accent))),
                // watermark
                Positioned(
                  bottom: 12, left: 12,
                  child: Text(
                    song.artist[0],
                    style: TextStyle(
                      fontFamily: 'serif', fontSize: 80, fontWeight: FontWeight.w900,
                      color: song.accent.withOpacity(0.094), letterSpacing: -4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  final Color accent;
  _StripesPainter(this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = accent.withOpacity(0.032)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_StripesPainter old) => old.accent != accent;
}
