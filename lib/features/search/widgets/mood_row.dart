import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock/moods.dart';
import '../../../data/models/mood.dart';
import '../../shared/icons/app_icons.dart';

class MoodList extends StatelessWidget {
  const MoodList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: kMoods.map((m) => _MoodRow(mood: m)).toList(),
    );
  }
}

class _MoodRow extends StatelessWidget {
  final Mood mood;
  const _MoodRow({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.accent.withOpacity(0.05),
              border: Border.all(color: AppColors.accent.withOpacity(0.075)),
            ),
            alignment: Alignment.center,
            child: Text(mood.icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mood.label, style: AppTextStyles.body.copyWith(fontSize: 14)),
                Text('${mood.songs} TRACKS',
                  style: AppTextStyles.monoLabel.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          AppIcons.chevronRight(color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
