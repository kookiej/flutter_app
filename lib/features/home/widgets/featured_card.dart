import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/song.dart';
import '../../shared/widgets/large_cover.dart';

class FeaturedCard extends StatefulWidget {
  final Song song;
  final int index;
  final VoidCallback onTap;

  const FeaturedCard({super.key, required this.song, required this.index, required this.onTap});

  @override
  State<FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<FeaturedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 240,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [song.colors[1], song.colors[2]],
              transform: const GradientRotation(145 * 3.14159 / 180),
            ),
            border: Border.all(color: song.accent.withOpacity(0.094)),
            boxShadow: [
              BoxShadow(color: song.coverAccent.withOpacity(0.2), blurRadius: 32, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LargeCover(song: song, size: 204),
              const SizedBox(height: 14),
              Text(song.title, style: AppTextStyles.songTitleMid, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${song.artist} · ${song.album}',
                style: AppTextStyles.caption.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
