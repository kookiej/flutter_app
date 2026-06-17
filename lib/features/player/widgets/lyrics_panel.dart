import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/song.dart';
import '../../../data/models/track_sync.dart';

/// 곡의 가사/응원법(merged sync_data)을 표시한다.
/// content.js 의 렌더 규칙을 이식: 응원 모드 ON이면 응원법 줄/스팬까지 표시·점진 하이라이트,
/// OFF면 가사(+가사에 포함된 응원=lyrics-part)만 표시한다.
class LyricsPanel extends StatefulWidget {
  final Song song;
  final List<SyncEntry> entries;
  final double currentTime; // 초
  final bool fanchantMode;
  final ValueChanged<double> onSeek;

  const LyricsPanel({
    super.key,
    required this.song,
    required this.entries,
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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
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

  /// 응원 모드 OFF → 응원법 전용 줄 숨김. ON → 전체 표시.
  List<SyncEntry> get _visible => widget.fanchantMode
      ? widget.entries
      : widget.entries.where((e) => !e.isFanchantOnly).toList();

  /// 표시 줄 기준 활성 인덱스 ([start, nextStart) 구간).
  int _activeIdx(List<SyncEntry> lines) {
    int idx = 0;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startTime <= widget.currentTime) idx = i; else break;
    }
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final screenWidth = MediaQuery.of(context).size.width;
    final albumCoverH = (screenWidth - 56.0).clamp(100.0, 300.0);
    final expandedH = albumCoverH + 52.0;

    final lines = _visible;
    final activeIdx = lines.isEmpty ? 0 : _activeIdx(lines);
    final activeText = lines.isEmpty ? '' : lines[activeIdx].displayText;

    return GestureDetector(
      onTap: _expanded ? null : _expand,
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null) {
          if (d.primaryVelocity! < -200 && !_expanded) _expand();
          else if (d.primaryVelocity! > 200 && _expanded) _collapse();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 440),
        curve: const Cubic(0.4, 0, 0.2, 1),
        height: _expanded ? expandedH : 44,
        margin: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: song.colors[1].withOpacity(0.8),
          border: Border.all(color: song.accent.withOpacity(0.13)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: _expanded
                ? _ExpandedPanel(
                    lines: lines,
                    activeIdx: activeIdx,
                    song: song,
                    fanchantMode: widget.fanchantMode,
                    currentTime: widget.currentTime,
                    onCollapse: _collapse,
                    onSeek: widget.onSeek,
                  )
                : _CollapsedRow(
                    icon: widget.fanchantMode ? '📣' : '♪',
                    text: activeText,
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
      behavior: HitTestBehavior.opaque,
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

class _ExpandedPanel extends StatefulWidget {
  final List<SyncEntry> lines;
  final int activeIdx;
  final Song song;
  final bool fanchantMode;
  final double currentTime;
  final VoidCallback onCollapse;
  final ValueChanged<double> onSeek;

  const _ExpandedPanel({
    required this.lines,
    required this.activeIdx,
    required this.song,
    required this.fanchantMode,
    required this.currentTime,
    required this.onCollapse,
    required this.onSeek,
  });

  @override
  State<_ExpandedPanel> createState() => _ExpandedPanelState();
}

class _ExpandedPanelState extends State<_ExpandedPanel> {
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
  }

  @override
  void didUpdateWidget(_ExpandedPanel old) {
    super.didUpdateWidget(old);
    if (widget.activeIdx != old.activeIdx) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    }
  }

  void _scrollToActive() {
    final key = _lineKeys[widget.activeIdx];
    final ctx = key?.currentContext;
    if (ctx == null || !_scroll.hasClients) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5, // 활성 줄을 뷰포트 중앙으로
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onCollapse,
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
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            itemCount: widget.lines.length,
            itemBuilder: (_, i) {
              final entry = widget.lines[i];
              final active = i == widget.activeIdx;
              final key = _lineKeys.putIfAbsent(i, () => GlobalKey());
              final spans = _buildSpans(
                entry: entry,
                fanchantMode: widget.fanchantMode,
                lineActive: active,
                currentTime: widget.currentTime,
                song: widget.song,
              );
              return GestureDetector(
                key: key,
                onTap: () => widget.onSeek(entry.startTime),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Text.rich(
                    TextSpan(children: spans),
                    style: TextStyle(
                      fontSize: active ? 15 : 13,
                      height: 1.3,
                    ),
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

/// content.js renderFanchantList 의 span 토큰화를 이식.
/// 반환된 TextSpan 들은 부모 Text.rich 의 fontSize 를 상속한다.
List<InlineSpan> _buildSpans({
  required SyncEntry entry,
  required bool fanchantMode,
  required bool lineActive,
  required double currentTime,
  required Song song,
}) {
  final lyricColor =
      lineActive ? song.lyricsColor : song.lyricsColor.withOpacity(0.27);
  final lyricWeight = lineActive ? FontWeight.w600 : FontWeight.w300;

  TextStyle lyricStyle() => TextStyle(color: lyricColor, fontWeight: lyricWeight);

  // 응원(fanchant)·lyrics-part 스팬 스타일 (응원 모드 ON에서만 강조)
  TextStyle chantStyle(double time) {
    final spanActive = lineActive && currentTime >= time;
    return TextStyle(
      color: spanActive ? Colors.white : Colors.white.withOpacity(0.5),
      fontWeight: FontWeight.w600,
      shadows: spanActive
          ? const [Shadow(blurRadius: 14, color: Color(0xE6FFFFFF))]
          : null,
    );
  }

  // mode A: 가사만
  if (entry.fanChant == null || entry.fanChant!.isEmpty) {
    final text = entry.lyrics?.text ?? entry.line?.text ?? '';
    return [TextSpan(text: text, style: lyricStyle())];
  }

  // mode B: 응원법 전용 줄 (OFF에서는 애초에 visible 에서 제외됨)
  if (entry.isFanchantOnly) {
    return [
      for (final fc in entry.fanChant!)
        TextSpan(
          text: '${fc.text}  ',
          style: fanchantMode ? chantStyle(fc.time) : lyricStyle(),
        ),
    ];
  }

  // mode C: line + lyrics + fanChant → line.text 를 chant 위치로 분할
  final lineText = entry.line?.text ?? entry.lyrics?.text ?? '';
  final lyricsText = entry.lyrics?.text ?? '';
  final spans = <InlineSpan>[];
  var remain = lineText;

  for (final fc in entry.fanChant!) {
    final idx = remain.indexOf(fc.text);
    if (idx == -1) continue;
    if (idx > 0) {
      spans.add(TextSpan(text: remain.substring(0, idx), style: lyricStyle()));
    }
    final isLyricsPart = lyricsText.contains(fc.text);
    if (fanchantMode) {
      // ON: 응원·lyrics-part 모두 강조 스팬
      spans.add(TextSpan(text: fc.text, style: chantStyle(fc.time)));
    } else if (isLyricsPart) {
      // OFF: 가사에 포함된 응원(lyrics-part)은 일반 가사처럼 표시
      spans.add(TextSpan(text: fc.text, style: lyricStyle()));
    }
    // OFF & 순수 fanchant → 표시하지 않음 (content.js display:none)
    remain = remain.substring(idx + fc.text.length);
  }

  if (remain.trim().isNotEmpty) {
    spans.add(TextSpan(text: remain, style: lyricStyle()));
  }
  if (spans.isEmpty) {
    spans.add(TextSpan(text: lyricsText, style: lyricStyle()));
  }
  return spans;
}
