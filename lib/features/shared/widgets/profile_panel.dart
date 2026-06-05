import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/notification_provider.dart';
import '../icons/app_icons.dart';

class ProfilePanel extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;

  const ProfilePanel({super.key, required this.visible, required this.onClose});

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  double _dragStartX = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
    _slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Cubic(0.4, 0, 0.2, 1)));
  }

  @override
  void didUpdateWidget(ProfilePanel old) {
    super.didUpdateWidget(old);
    if (widget.visible != old.visible) {
      if (widget.visible) _ctrl.forward(); else _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        if (_ctrl.isDismissed && !widget.visible) return const SizedBox.shrink();
        return Stack(
          children: [
            // dim overlay
            GestureDetector(
              onTap: widget.onClose,
              child: AnimatedOpacity(
                opacity: _ctrl.value,
                duration: Duration.zero,
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            // panel
            Positioned(
              right: 0, top: 0, bottom: 0,
              width: MediaQuery.of(context).size.width * 0.92,
              child: GestureDetector(
                onHorizontalDragStart: (d) => _dragStartX = d.localPosition.dx,
                onHorizontalDragUpdate: (d) {
                  final delta = d.localPosition.dx - _dragStartX;
                  if (delta > 0) _ctrl.value = (1 - delta / (MediaQuery.of(context).size.width * 0.92)).clamp(0, 1);
                },
                onHorizontalDragEnd: (d) {
                  if (_ctrl.value < 0.6) widget.onClose(); else _ctrl.forward();
                },
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF17141F), Color(0xFF0F0D16)],
                        transform: GradientRotation(160 * 3.14159 / 180),
                      ),
                      border: Border(left: BorderSide(color: Color(0x12FFFFFF))),
                    ),
                    child: SafeArea(child: _PanelContent(onClose: widget.onClose)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PanelContent extends StatelessWidget {
  final VoidCallback onClose;
  const _PanelContent({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifs, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // profile
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF4A2FA0), Color(0xFF7C3AED)]),
                  ),
                  alignment: Alignment.center,
                  child: Text('M', style: AppTextStyles.sectionTitle),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('뮤직 팬', style: AppTextStyles.body),
                      Text('@musicfan_kr', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text('프로필 보기 >', style: AppTextStyles.monoLabel.copyWith(color: AppColors.accent.withOpacity(0.7))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 16),
            // settings row
            Row(
              children: [
                AppIcons.settings(color: AppColors.textTertiary),
                const SizedBox(width: 12),
                Text('설정', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 12),
            // notifications card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: -4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.03),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppIcons.bell(color: AppColors.textTertiary),
                      const SizedBox(width: 8),
                      Text('알림', style: AppTextStyles.monoLabel),
                      const Spacer(),
                      Text('전체 보기', style: AppTextStyles.monoLabel.copyWith(color: AppColors.textFaint)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (notifs.notifs.isEmpty)
                    Text('새 알림이 없어요', style: AppTextStyles.caption)
                  else
                    ...notifs.notifs.map((n) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: n.read ? Colors.transparent : AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.text, style: AppTextStyles.bodyLight.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                Text(n.time, style: AppTextStyles.monoLabel),
                              ],
                            ),
                          ),
                          if (!n.read)
                            GestureDetector(
                              onTap: () => context.read<NotificationProvider>().markRead(n.id),
                              child: Container(
                                width: 26, height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent.withOpacity(0.1),
                                ),
                                alignment: Alignment.center,
                                child: AppIcons.check(color: AppColors.accent),
                              ),
                            ),
                        ],
                      ),
                    )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
