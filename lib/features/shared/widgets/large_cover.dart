import 'package:flutter/material.dart';
import '../../../data/models/song.dart';

class LargeCover extends StatelessWidget {
  final Song song;
  final double size;

  const LargeCover({super.key, required this.song, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: song.coverGradient,
        ),
        boxShadow: [BoxShadow(color: song.coverAccent.withOpacity(0.27), blurRadius: 48, offset: const Offset(0, 16))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.44, heightFactor: 0.44,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xE6000000), song.coverAccent.withOpacity(0.33)],
                    stops: const [0.25, 1.0],
                  ),
                  border: Border.all(color: song.accent.withOpacity(0.2), width: 1),
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.11, heightFactor: 0.11,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0a0a0f),
                  border: Border.all(color: song.accent.withOpacity(0.33), width: 1.5),
                ),
              ),
            ),
            // stripe overlay
            Positioned.fill(
              child: CustomPaint(painter: _StripePainter(song.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color accent;
  _StripePainter(this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = accent.withOpacity(0.028)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 33) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.accent != accent;
}
