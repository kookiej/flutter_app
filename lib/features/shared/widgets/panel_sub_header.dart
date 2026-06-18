import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// 프로필 패널 서브뷰 공통 헤더. html/Home.html 의 SubHeader 재현.
class PanelSubHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? right;

  const PanelSubHeader({super.key, required this.title, required this.onBack, this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: SizedBox(
              width: 40, height: 40,
              child: Icon(Icons.chevron_left, color: Colors.white.withOpacity(0.85), size: 26),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title, style: AppTextStyles.sectionTitle),
          ),
          if (right != null) right!,
        ],
      ),
    );
  }
}
