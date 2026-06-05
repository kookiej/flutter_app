import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock/lyrics.dart';
import '../../../data/models/lyric_line.dart';
import '../../../data/models/song.dart';

class LyricsPanel extends StatefulWidget {
  final Song song;
  final double currentTime;
  final bool fanchantMode;
  final ValueChanged<double> onSeek;

  const LyricsPanel({
    super.key,
    required this.song,
    required this.currentTime,
    required this.fanchantMode,
    required this.onSeek,
  });

  @override
  State<LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends State<LyricsPanel> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _height;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
    _height = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Cubic(0.4, 0, 0.2, 1)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    _ctrl.forward();
  }

  void _collapse() {
    setState(() => _expanded = false);
    _ctrl.reverse();
  }

  List<LyricLine> get _lines => widget.fanchantMode ? kFanchant : kLyrics;

  int get _activeIdx {
    int idx = 0;
    for (int i = 0; i < _lines.length; i++) {
      if (_lines[i].time <= widget.currentTime) idx = i; else break;
    }
    return idx;
  }

  String get _activeLine => _lines.isEmpty ? '' : _lines[_activeIdx].text;

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    return GestureDetector(
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null) {
          if (d.primaryVelocity! < -200 && !_expanded) _expand();
          else if (d.primaryVelocity! > 200 && _expanded) _collapse();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 440),
        curve: const Cubic(0.4, 0, 0.2, 1),
        height: _expanded ? 220 : 44,
        margin: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: song.colors[1].withOpacity(0.8),
          border: Border.all(color: song.accent.withOpacity(0.13)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: const ColorFilter.srgbToLinearGamma(),
            child: _expanded ? _ExpandedPanel(
              lines: _lines,
              activeIdx: _activeIdx,
              song: song,
              onCollapse: _collapse,
              onSeek: widget.onSeek,
            ) : _CollapsedRow(
              icon: widget.fanchantMode ? '📣' : '♪',
              text: _activeLine,
              song: song,
              onExpand: _expand,
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedRow extends StatelessWidget {
  final String icon;
  final String text;
  final Song song;
  final VoidCallback onExpand;

  const _CollapsedRow({required this.icon, required this.text, required this.song, required this.onExpand});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExpand,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                style: AppTextStyles.bodyLight.copyWith(fontSize: 13, color: song.lyricsColor),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedPanel extends StatelessWidget {
  final List<LyricLine> lines;
  final int activeIdx;
  final Song song;
  final VoidCallback onCollapse;
  final ValueChanged<double> onSeek;

  const _ExpandedPanel({
    required this.lines, required this.activeIdx, required this.song,
    required this.onCollapse, required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onCollapse,
          child: Container(
            height: 36, alignment: Alignment.center,
            child: Container(
              width: 36, height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            itemCount: lines.length,
            itemBuilder: (_, i) {
              final active = i == activeIdx;
              return GestureDetector(
                onTap: () => onSeek(lines[i].time.toDouble()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: AppTextStyles.bodyLight.copyWith(
                      fontSize: active ? 15 : 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w300,
                      color: active ? song.lyricsColor : song.lyricsColor.withOpacity(0.27),
                    ),
                    child: Text(lines[i].text),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
