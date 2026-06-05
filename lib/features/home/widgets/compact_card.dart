import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/song.dart';
import '../../shared/widgets/mini_cover.dart';

class CompactCard extends StatefulWidget {
  final Song song;
  final VoidCallback onTap;

  const CompactCard({super.key, required this.song, required this.onTap});

  @override
  State<CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<CompactCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MiniCover(song: widget.song, size: 130, radius: 16),
              const SizedBox(height: 8),
              Text(widget.song.title,
                style: AppTextStyles.body.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(widget.song.artist,
                style: AppTextStyles.artistLabel.copyWith(color: Colors.white.withOpacity(0.35)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
