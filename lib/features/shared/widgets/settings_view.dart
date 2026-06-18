import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/user_provider.dart';
import '../../login/login_page.dart';
import '../icons/app_icons.dart';
import 'app_toggle.dart';
import 'panel_sub_header.dart';

/// 설정 — 계정 정보, 재생 품질/푸시 토글, 로그아웃.
class SettingsView extends StatelessWidget {
  final VoidCallback onBack;
  const SettingsView({super.key, required this.onBack});

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<UserProvider>().logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final name = context.watch<UserProvider>().effectiveName;

    return Column(
      children: [
        PanelSubHeader(title: '설정', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              _sectionLabel('계정'),
              _row(label: name, desc: 'Spotify로 연결됨'),
              _divider(),
              _sectionLabel('재생'),
              _row(
                label: 'Wi-Fi 고음질', desc: 'Wi-Fi에서 최고 음질로 재생',
                right: AppToggle(value: settings.hqWifi, onChanged: settings.setHqWifi),
              ),
              _row(
                label: '모바일 데이터 고음질', desc: '모바일 데이터에서 최고 음질로 재생',
                right: AppToggle(value: settings.hqCellular, onChanged: settings.setHqCellular),
              ),
              _row(
                label: '푸시 알림', desc: '새 발매·응원법 소식 받기',
                right: AppToggle(value: settings.push, onChanged: settings.setPush),
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                child: GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0x1AF43F5E),
                      border: Border.all(color: const Color(0x4DF43F5E)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcons.logout(color: const Color(0xFFFB7185)),
                        const SizedBox(width: 8),
                        Text('로그아웃',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFFB7185))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
        child: Text(t, style: AppTextStyles.monoLabel),
      );

  Widget _row({required String label, String? desc, Widget? right}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.85))),
                  if (desc != null) ...[
                    const SizedBox(height: 2),
                    Text(desc, style: AppTextStyles.caption.copyWith(fontSize: 11, color: Colors.white.withOpacity(0.35))),
                  ],
                ],
              ),
            ),
            if (right != null) right,
          ],
        ),
      );

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        color: Colors.white.withOpacity(0.05),
      );
}
