import 'package:flutter/material.dart';
import '../../../data/models/song.dart';

class MiniCover extends StatelessWidget {
  final Song song;
  final double size;
  final double radius;

  const MiniCover({super.key, required this.song, this.size = 48, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: song.coverGradient,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FractionallySizedBox(
            widthFactor: 0.44, heightFactor: 0.44,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xD9000000), song.coverAccent.withOpacity(0.27)],
                  stops: const [0.25, 1.0],
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.12, heightFactor: 0.12,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0a0a0f),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
