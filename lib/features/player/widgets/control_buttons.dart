import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/song.dart';
import '../../../providers/player_provider.dart';
import '../../shared/icons/app_icons.dart';

class ControlButtons extends StatelessWidget {
  final Song song;

  const ControlButtons({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IconBtn(
                child: Opacity(
                  opacity: player.shuffle ? 1.0 : 0.5,
                  child: AppIcons.shuffle(color: Colors.white),
                ),
                onTap: () => player.toggleShuffle(),
              ),
              _IconBtn(child: AppIcons.prev(color: Colors.white), onTap: () => player.prev()),
              _PlayPauseBtn(song: song, player: player),
              _IconBtn(child: AppIcons.next(color: Colors.white), onTap: () => player.next()),
              _RepeatBtn(song: song, player: player),
            ],
          ),
        );
      },
    );
  }
}

class _IconBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;

  const _IconBtn({required this.child, required this.onTap, this.size = 44});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(width: widget.size, height: widget.size, child: Center(child: widget.child)),
      ),
    );
  }
}

class _PlayPauseBtn extends StatefulWidget {
  final Song song;
  final PlayerProvider player;
  const _PlayPauseBtn({required this.song, required this.player});

  @override
  State<_PlayPauseBtn> createState() => _PlayPauseBtnState();
}

class _PlayPauseBtnState extends State<_PlayPauseBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.player.togglePlay(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [song.colors[2], song.coverAccent],
            ),
            border: Border.all(color: song.accent.withOpacity(0.27), width: 1.5),
            boxShadow: [BoxShadow(color: song.coverAccent.withOpacity(0.33), blurRadius: 32, offset: const Offset(0, 8))],
          ),
          alignment: Alignment.center,
          child: widget.player.isPlaying
              ? AppIcons.pauseLarge()
              : AppIcons.playLarge(),
        ),
      ),
    );
  }
}

class _RepeatBtn extends StatefulWidget {
  final Song song;
  final PlayerProvider player;
  const _RepeatBtn({required this.song, required this.player});

  @override
  State<_RepeatBtn> createState() => _RepeatBtnState();
}

class _RepeatBtnState extends State<_RepeatBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.player.repeat > 0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.player.toggleRepeat(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 44, height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: active ? 1.0 : 0.5,
                child: AppIcons.repeat(color: Colors.white),
              ),
              if (widget.player.repeat == 2)
                Text('1', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
