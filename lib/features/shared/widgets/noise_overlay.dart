import 'dart:math';
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';

class NoiseOverlay extends StatelessWidget {
  const NoiseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _NoisePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  static final _rng = Random(42);
  static List<Offset>? _pts;

  @override
  void paint(Canvas canvas, Size size) {
    if (_pts == null) {
      _pts = List.generate(3000, (_) => Offset(
        _rng.nextDouble() * 1000,
        _rng.nextDouble() * 1000,
      ));
    }
    final paint = Paint()..color = const Color(0x06FFFFFF)..strokeWidth = 1;
    final scaleX = size.width / 1000;
    final scaleY = size.height / 1000;
    for (final pt in _pts!) {
      final x = (pt.dx * scaleX) % size.width;
      final y = (pt.dy * scaleY) % size.height;
      canvas.drawPoints(PointMode.points, [Offset(x, y)], paint);
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => false;
}
