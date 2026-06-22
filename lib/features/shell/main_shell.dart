import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/song.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../home/home_page.dart';
import '../library/library_content.dart';
import '../player/player_nav.dart';
import '../player/player_overlay.dart';
import '../search/search_page.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/mini_player_bar.dart';
import '../shared/widgets/noise_overlay.dart';
import '../shared/widgets/profile_panel.dart';
import '../shared/widgets/toast_snackbar.dart';

/// 앱 셸 — 하단 탭 + 미니 플레이어 + 토스트를 항상 띄우고,
/// 페이지 이동은 탭별 중첩 Navigator 안에서 일어나 미니 플레이어가 유지된다.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _navIdx = 0; // 0 홈, 1 검색, 2 보관함 (3 프로필 = 패널 토글)
  bool _profileVisible = false;
  bool _playerVisible = false;
  Song? _toastSong;

  late final AnimationController _mountCtrl;
  late final Animation<double> _mountOpacity;

  // 탭별 Navigator — 아티스트/앨범/전체보기 push가 탭 콘텐츠 영역 안에서 일어난다.
  final _navKeys = <GlobalKey<NavigatorState>>[
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _mountCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _mountOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 60), () => _mountCtrl.forward());
  }

  @override
  void dispose() {
    _mountCtrl.dispose();
    super.dispose();
  }

  void _showToast(Song song) => setState(() => _toastSong = song);

  NavigatorState? get _activeNav => _navKeys[_navIdx].currentState;

  Widget _tabNavigator(int index, Widget root) {
    return Navigator(
      key: _navKeys[index],
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => root),
    );
  }

  void _onNavTap(int i) {
    if (i == 3) {
      setState(() => _profileVisible = true);
      return;
    }
    if (i == _navIdx) {
      // 같은 탭 재탭 → 해당 탭을 루트까지 pop
      _navKeys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _navIdx = i);
    }
  }

  void _pushOnActiveTab(Route<void>? route) {
    if (route != null) _activeNav?.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = context.watch<CatalogProvider>().songs[player.songIdx];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _activeNav;
        if (nav != null && nav.canPop()) nav.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: FadeTransition(
          opacity: _mountOpacity,
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: AppColors.bgPrimary)),
              // ambient glow — 현재곡 색조
              Positioned(
                top: -60,
                left: MediaQuery.of(context).size.width * 0.3 - 140,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1200),
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: song.coverAccent.withOpacity(0.15),
                  ),
                  child: ImageFiltered(
                    imageFilter: const ColorFilter.srgbToLinearGamma(),
                    child: Container(),
                  ),
                ),
              ),
              const NoiseOverlay(),
              Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: _navIdx,
                      children: [
                        _tabNavigator(0, HomeContent(
                          onProfileTap: () => setState(() => _profileVisible = true),
                          onToast: _showToast,
                        )),
                        _tabNavigator(1, SearchContent(
                          onProfileTap: () => setState(() => _profileVisible = true),
                          onToast: _showToast,
                        )),
                        _tabNavigator(2, LibraryContent(onToast: _showToast)),
                      ],
                    ),
                  ),
                  if (player.initialized) ...[
                    if (_toastSong != null)
                      Padding(
                        // 미니 플레이어와 간격 유지
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ToastSnackbar(
                          song: _toastSong!,
                          onDone: () => setState(() => _toastSong = null),
                        ),
                      ),
                    MiniPlayerBar(onTap: () => setState(() => _playerVisible = true)),
                  ],
                  BottomNavBar(currentIndex: _navIdx, onTap: _onNavTap),
                ],
              ),
              ProfilePanel(
                visible: _profileVisible,
                onClose: () => setState(() => _profileVisible = false),
              ),
              if (_playerVisible)
                PlayerOverlay(
                  onClose: () => setState(() => _playerVisible = false),
                  onArtistTap: () => _pushOnActiveTab(artistRouteForCurrentSong(context)),
                  onAlbumTap: () => _pushOnActiveTab(albumRouteForCurrentSong(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
