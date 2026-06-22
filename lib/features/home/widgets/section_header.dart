import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  /// 제목 오른쪽(액션 텍스트 앞)에 들어가는 추가 위젯 — 예: 전체 재생 아이콘 버튼.
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            if (action != null) const SizedBox(width: 14),
          ],
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                style: AppTextStyles.monoLabel.copyWith(color: AppColors.textFaint, letterSpacing: 1.5)),
            ),
        ],
      ),
    );
  }
}
