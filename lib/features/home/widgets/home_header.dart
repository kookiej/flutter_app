import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/greeting.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/user_provider.dart';
import '../../shared/icons/app_icons.dart';

class HomeHeader extends StatefulWidget {
  final VoidCallback onProfileTap;

  const HomeHeader({super.key, required this.onProfileTap});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final String _greeting = getGreeting();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                  style: AppTextStyles.monoLabel.copyWith(letterSpacing: 2.5, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text('오늘의 음악', style: AppTextStyles.pageTitle),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Consumer2<NotificationProvider, UserProvider>(
            builder: (_, notifs, userProv, child) => GestureDetector(
              onTap: widget.onProfileTap,
              child: Stack(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: AppColors.borderSubtle),
                      image: userProv.user?.pfpUrl != null
                          ? DecorationImage(
                              image: NetworkImage(userProv.user!.pfpUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: userProv.user?.pfpUrl == null
                        ? AppIcons.profile(color: AppColors.textSecondary)
                        : null,
                  ),
                  if (notifs.hasUnread)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                          border: Border.all(color: AppColors.bgPrimary, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
