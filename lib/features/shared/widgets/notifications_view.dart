import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/notification_provider.dart';
import 'panel_sub_header.dart';

/// 알림 전체 보기 — 항목 탭 시 읽음 처리, 헤더 우측 모두 읽음.
class NotificationsView extends StatelessWidget {
  final VoidCallback onBack;
  const NotificationsView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifs, _) {
        final list = notifs.notifs;
        return Column(
          children: [
            PanelSubHeader(
              title: '알림',
              onBack: onBack,
              right: notifs.hasUnread
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: notifs.markAllRead,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text('모두 읽음',
                          style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.accent)),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      child: Text('새 알림이 없어요',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.25))),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 6, bottom: 30),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final n = list[i];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => notifs.markRead(n.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: n.read ? Colors.transparent : AppColors.accent.withOpacity(0.05),
                              border: Border(
                                top: i > 0
                                    ? BorderSide(color: Colors.white.withOpacity(0.04))
                                    : BorderSide.none,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 7, height: 7,
                                  margin: const EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: n.read ? Colors.transparent : AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n.text,
                                        style: AppTextStyles.bodyLight.copyWith(
                                          fontSize: 13,
                                          height: 1.5,
                                          fontWeight: n.read ? FontWeight.w300 : FontWeight.w400,
                                          color: Colors.white.withOpacity(n.read ? 0.4 : 0.8),
                                        )),
                                      const SizedBox(height: 3),
                                      Text(n.time, style: AppTextStyles.monoLabel.copyWith(fontSize: 9, letterSpacing: 0.5)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
