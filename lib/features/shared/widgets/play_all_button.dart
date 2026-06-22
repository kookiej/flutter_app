import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../icons/app_icons.dart';

/// 전체 듣기 — 아이콘만 표시하는 원형 재생 버튼 (아티스트 인기곡 / 앨범 전체 재생).
class PlayAllButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const PlayAllButton({super.key, required this.onTap, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withOpacity(0.16),
          border: Border.all(color: AppColors.accent.withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: AppIcons.play(color: AppColors.accent),
      ),
    );
  }
}
