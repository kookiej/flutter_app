import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/icons/app_icons.dart';

class RecentSearchRow extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const RecentSearchRow({super.key, required this.term, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.05),
              ),
              alignment: Alignment.center,
              child: AppIcons.clock(color: AppColors.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(term,
                style: AppTextStyles.bodyLight.copyWith(color: Colors.white.withOpacity(0.6))),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AppIcons.close(color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
