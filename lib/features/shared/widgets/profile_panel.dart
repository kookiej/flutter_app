import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/avatar_palette.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/user_provider.dart';
import '../icons/app_icons.dart';
import 'notifications_view.dart';
import 'profile_edit_view.dart';
import 'settings_view.dart';
import 'slide_over_panel.dart';

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

enum _SubView { none, profile, settings, notifs }

class _PanelContent extends StatefulWidget {
  final VoidCallback onClose;
  const _PanelContent({required this.onClose});

  @override
  State<_PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends State<_PanelContent> {
  _SubView _sub = _SubView.none;

  void _open(_SubView v) => setState(() => _sub = v);
  void _closeSub() => setState(() => _sub = _SubView.none);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMain(context),
        if (_sub == _SubView.profile)
          SlideOverPanel(
            onClosed: _closeSub,
            builder: (_, close) => ProfileEditView(onBack: close),
          ),
        if (_sub == _SubView.settings)
          SlideOverPanel(
            onClosed: _closeSub,
            builder: (_, close) => SettingsView(onBack: close),
          ),
        if (_sub == _SubView.notifs)
          SlideOverPanel(
            onClosed: _closeSub,
            builder: (_, close) => NotificationsView(onBack: close),
          ),
      ],
    );
  }

  Widget _buildMain(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifs, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // profile
            Consumer<UserProvider>(
              builder: (context, userProv, _) {
                final user = userProv.user;
                final name = userProv.effectiveName;
                final handle = user != null ? '@${user.spotifyUserId}' : '@musicfan_kr';
                final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'M';
                final photo = userProv.localPhotoBytes;
                final pfpUrl = userProv.pfpUrl;
                final pal = kAvatarPalette[userProv.colorIdx % kAvatarPalette.length];
                // 아바타: 로컬 미리보기 → pfp_url → 그라디언트+이니셜
                final ImageProvider? avatarImage = photo != null
                    ? MemoryImage(photo)
                    : (pfpUrl != null ? NetworkImage(pfpUrl) as ImageProvider : null);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _open(_SubView.profile),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: avatarImage == null
                              ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: pal)
                              : null,
                          image: avatarImage != null
                              ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: avatarImage == null
                            ? Text(initial, style: AppTextStyles.sectionTitle)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.body),
                            Text(handle, style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Text('프로필 보기 >', style: AppTextStyles.monoLabel.copyWith(color: AppColors.accent.withOpacity(0.7))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 16),
            // settings row
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _open(_SubView.settings),
              child: Row(
                children: [
                  AppIcons.settings(color: AppColors.textTertiary),
                  const SizedBox(width: 12),
                  Text('설정', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  AppIcons.chevronRight(color: AppColors.textFaint),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 12),
            // notifications card
            Container(
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _open(_SubView.notifs),
                        child: Text('전체 보기', style: AppTextStyles.monoLabel.copyWith(color: AppColors.textFaint)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (notifs.notifs.isEmpty)
                    Text('새 알림이 없어요', style: AppTextStyles.caption)
                  else
                    ...notifs.notifs.take(3).map((n) => Padding(
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
                              behavior: HitTestBehavior.opaque, // 배경 원 없이도 26x26 터치 영역 유지
                              onTap: () => context.read<NotificationProvider>().markRead(n.id),
                              child: SizedBox(
                                width: 26, height: 26,
                                child: Center(child: AppIcons.check(color: AppColors.accent)),
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
