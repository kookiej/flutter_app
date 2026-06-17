import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/catalog_provider.dart';
import '../../../providers/player_provider.dart';
import '../icons/app_icons.dart';
import 'mini_cover.dart';

class MiniPlayerBar extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayerBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final song = context.watch<CatalogProvider>().songs[player.songIdx];
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [song.colors[1].withOpacity(0.8), song.colors[2].withOpacity(0.6)],
              ),
              border: Border.all(color: song.accent.withOpacity(0.13)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        children: [
                          MiniCover(song: song, size: 42, radius: 10),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(song.title, style: AppTextStyles.miniPlayerTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(song.artist, style: AppTextStyles.artistLabel, maxLines: 1),
                              ],
                            ),
                          ),
                          _ControlBtn(
                            size: 32,
                            onTap: (e) { e.stopPropagation(); player.prev(); },
                            child: AppIcons.prevSm(color: Colors.white.withOpacity(0.7)),
                          ),
                          const SizedBox(width: 4),
                          _ControlBtn(
                            size: 36,
                            bg: Colors.white.withOpacity(0.12),
                            onTap: (e) { e.stopPropagation(); player.togglePlay(); },
                            child: player.isPlaying
                                ? AppIcons.pause(color: Colors.white)
                                : AppIcons.play(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          _ControlBtn(
                            size: 32,
                            onTap: (e) { e.stopPropagation(); player.next(); },
                            child: AppIcons.nextSm(color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                    // progress bar
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          value: player.progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation(song.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final double size;
  final Color? bg;
  final Widget child;
  final void Function(TapDownDetails) onTap;

  const _ControlBtn({required this.size, required this.child, required this.onTap, this.bg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

extension on TapDownDetails {
  void stopPropagation() {}
}
