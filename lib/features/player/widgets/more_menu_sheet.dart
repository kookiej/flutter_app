import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/song.dart';
import '../../shared/icons/app_icons.dart';

/// 플레이어 더보기(⋮) 바텀시트. html/Player.html 의 MORE MENU 재현.
/// 옵션 선택 시 표시할 토스트 문구를 Navigator.pop 으로 반환한다.
class MoreMenuSheet extends StatelessWidget {
  final Song song;
  const MoreMenuSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final options = <_MoreOption>[
      _MoreOption(
        icon: AppIcons.artistChannel(),
        label: '아티스트 채널 가기',
        sub: song.artist,
        toast: '${song.artist} 채널로 이동',
      ),
      _MoreOption(
        icon: AppIcons.albumDisc(),
        label: '앨범 보러 가기',
        sub: "${song.artist} '${song.title}' 앨범",
        toast: "앨범 '${song.album}' 열기",
      ),
      _MoreOption(
        icon: AppIcons.fanchantVideo(),
        label: '응원법 영상 보러 가기',
        sub: "${song.artist} '${song.title}' 응원법",
        toast: '응원법 영상 재생',
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
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [song.colors[1], song.colors[2]],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      song.artist.isNotEmpty ? song.artist.characters.first : '?',
                      style: AppTextStyles.songTitleMid.copyWith(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
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
            // 옵션
            ...options.map((o) => _OptionRow(
              option: o,
              onTap: () => Navigator.of(context).pop(o.toast),
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
  final String toast;
  const _MoreOption({required this.icon, required this.label, required this.sub, required this.toast});
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
