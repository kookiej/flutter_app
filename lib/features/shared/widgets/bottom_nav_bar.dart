import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../icons/app_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderFaint)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            children: [
              _NavItem(icon: AppIcons.home(active: currentIndex == 0, color: currentIndex == 0 ? AppColors.accent : null), label: '홈', active: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: AppIcons.search(color: currentIndex == 1 ? AppColors.accent : AppColors.textTertiary), label: '검색', active: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: AppIcons.library(color: currentIndex == 2 ? AppColors.accent : AppColors.textTertiary), label: '보관함', active: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: AppIcons.profile(active: currentIndex == 3, color: currentIndex == 3 ? AppColors.accent : null), label: '프로필', active: currentIndex == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: active ? AppColors.accent : AppColors.textTertiary,
                fontWeight: active ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
