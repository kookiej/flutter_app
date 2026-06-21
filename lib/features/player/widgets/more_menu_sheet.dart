import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/song.dart';
import '../../shared/icons/app_icons.dart';
import '../../shared/widgets/mini_cover.dart';

/// 플레이어 더보기(⋮) 바텀시트. html/Player.html 의 MORE MENU 재현.
/// 옵션 선택 시 시트만 닫는다(피드백 토스트 없음).
class MoreMenuSheet extends StatelessWidget {
  final Song song;
  final String? fanchantVideoUrl;
  const MoreMenuSheet({super.key, required this.song, this.fanchantVideoUrl});

  @override
  Widget build(BuildContext context) {
    final hasFanchantVideo =
        fanchantVideoUrl != null && fanchantVideoUrl!.isNotEmpty;
    final options = <_MoreOption>[
      _MoreOption(
        icon: AppIcons.artistChannel(),
        label: '아티스트 채널 가기',
        sub: song.artist,
      ),
      _MoreOption(
        icon: AppIcons.albumDisc(),
        label: '앨범 보러 가기',
        sub: "${song.artist} '${song.title}' 앨범",
      ),
      // 응원법 영상 URL이 있는 곡에서만 노출 → 탭 시 외부 브라우저/앱으로 열기
      if (hasFanchantVideo)
        _MoreOption(
          icon: AppIcons.fanchantVideo(),
          label: '응원법 영상 보러 가기',
          sub: "${song.artist} '${song.title}' 응원법",
          onTap: () => launchUrl(
            Uri.parse(fanchantVideoUrl!),
            mode: LaunchMode.externalApplication,
          ),
        ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1726), Color(0xFF14111D)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 그래버
            Container(
              width: 38, height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            // 현재 곡 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
              child: Row(
                children: [
                  MiniCover(song: song, size: 44, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${song.artist} · ${song.album}',
                          style: AppTextStyles.bodyLight.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.fromLTRB(22, 4, 22, 6),
              color: Colors.white.withOpacity(0.06),
            ),
            // 옵션 — 모두 시트를 닫고, 액션이 있으면(응원법 영상) 추가 실행
            ...options.map((o) => _OptionRow(
              option: o,
              onTap: () {
                Navigator.of(context).pop();
                o.onTap?.call();
              },
            )),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _MoreOption {
  final Widget icon;
  final String label;
  final String sub;
  final VoidCallback? onTap; // 시트 닫은 뒤 실행할 추가 액션 (없으면 닫기만)
  const _MoreOption({required this.icon, required this.label, required this.sub, this.onTap});
}

class _OptionRow extends StatelessWidget {
  final _MoreOption option;
  final VoidCallback onTap;
  const _OptionRow({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.05),
              ),
              alignment: Alignment.center,
              child: option.icon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label,
                    style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 2),
                  Text(option.sub,
                    style: AppTextStyles.bodyLight.copyWith(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            AppIcons.chevronRight(color: Colors.white.withOpacity(0.25)),
          ],
        ),
      ),
    );
  }
}
