import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/search_provider.dart';
import '../home/home_page.dart';
import '../home/widgets/song_row.dart';
import '../shared/icons/app_icons.dart';
import '../player/player_page.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/mini_player_bar.dart';
import '../shared/widgets/noise_overlay.dart';
import '../shared/widgets/profile_panel.dart';
import '../shared/widgets/toast_snackbar.dart';
import '../../data/models/song.dart';
import 'widgets/genre_grid.dart';
import 'widgets/mood_row.dart';
import 'widgets/recent_search_row.dart';
import 'widgets/search_input.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  bool _profileVisible = false;
  bool _playerVisible = false;
  Song? _toastSong;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.bgPrimary)),
          const NoiseOverlay(),
          Column(
            children: [
              Expanded(
                child: Consumer<SearchProvider>(
                  builder: (context, search, _) {
                    // 보강된 카탈로그(앨범 커버 포함) 기준으로 검색 결과를 만든다
                    final catalog = context.watch<CatalogProvider>();
                    final results = search.filter(catalog.songs);
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                              child: Row(
                                children: [
                                  Expanded(child: Text('검색', style: AppTextStyles.pageTitle)),
                                  Consumer<NotificationProvider>(
                                    builder: (_, notifs, __) => GestureDetector(
                                      onTap: () => setState(() => _profileVisible = true),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 40, height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.06),
                                              border: Border.all(color: AppColors.borderSubtle),
                                            ),
                                            alignment: Alignment.center,
                                            child: AppIcons.profile(color: AppColors.textSecondary),
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
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: SearchInput(
                              controller: _ctrl,
                              onChanged: (q) {
                                search.setQuery(q);
                                setState(() {});
                              },
                              onSubmitted: (q) {
                                search.saveSearch(q);
                                search.setQuery(q);
                              },
                              onClear: () {
                                _ctrl.clear();
                                search.setQuery('');
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        if (search.query.isEmpty) ...[
                          // recent searches
                          if (search.recentSearches.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                                child: Row(
                                  children: [
                                    Text('최근 검색', style: AppTextStyles.sectionTitle),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => search.clearRecents(),
                                      child: Text('전체 삭제',
                                        style: AppTextStyles.monoLabel.copyWith(color: AppColors.textFaint)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => RecentSearchRow(
                                  term: search.recentSearches[i],
                                  onTap: () {
                                    _ctrl.text = search.recentSearches[i];
                                    search.setQuery(search.recentSearches[i]);
                                    setState(() {});
                                  },
                                  onRemove: () => search.removeRecent(search.recentSearches[i]),
                                ),
                                childCount: search.recentSearches.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          ],
                          // genre/mood toggle
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: _TabToggle(
                                activeTab: search.activeTab,
                                onTab: search.setActiveTab,
                              ),
                            ),
                          ),
                          if (search.activeTab == 'genre')
                            const SliverToBoxAdapter(child: GenreGrid())
                          else
                            const SliverToBoxAdapter(child: MoodList()),
                        ] else ...[
                          // results
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                              child: Text('결과 ${results.length}곡', style: AppTextStyles.sectionTitle),
                            ),
                          ),
                          if (results.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 60),
                                child: Column(
                                  children: [
                                    Text('NO RESULTS', style: AppTextStyles.monoLabel),
                                    const SizedBox(height: 8),
                                    Text('"${search.query}"',
                                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 18, color: Colors.white.withOpacity(0.4))),
                                    const SizedBox(height: 8),
                                    Text('다른 검색어를 시도해 보세요', style: AppTextStyles.bodyLight),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  final song = results[i];
                                  return SongRow(
                                    song: song,
                                    index: i,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      context.read<PlayerProvider>().playSong(song);
                                      setState(() => _toastSong = song);
                                    },
                                    onSwipeAdd: () {
                                      context.read<PlayerProvider>().addSongToQueue(song);
                                      setState(() => _toastSong = song);
                                    },
                                    showIndex: false,
                                  );
                                },
                                childCount: results.length,
                              ),
                            ),
                        ],
                        const SliverToBoxAdapter(child: SizedBox(height: 160)),
                      ],
                    );
                  },
                ),
              ),
              if (player.initialized) ...[
                if (_toastSong != null)
                  ToastSnackbar(song: _toastSong!, onDone: () => setState(() => _toastSong = null)),
                MiniPlayerBar(onTap: () => setState(() => _playerVisible = true)),
              ],
              BottomNavBar(
                currentIndex: 1,
                onTap: (i) {
                  if (i == 0) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()));
                  }
                },
              ),
            ],
          ),
          ProfilePanel(visible: _profileVisible, onClose: () => setState(() => _profileVisible = false)),
          if (_playerVisible)
            _SearchPlayerOverlay(onClose: () => setState(() => _playerVisible = false)),
        ],
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTab;

  const _TabToggle({required this.activeTab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _Tab(label: '장르', active: activeTab == 'genre', onTap: () => onTab('genre')),
          _Tab(label: '무드', active: activeTab == 'mood', onTap: () => onTab('mood')),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active ? const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF4A2FA0), Color(0xFF7C3AED)],
            ) : null,
            boxShadow: active ? [
              BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 8),
            ] : [],
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: active ? Colors.white : AppColors.textTertiary,
            fontWeight: active ? FontWeight.w500 : FontWeight.w300,
          )),
        ),
      ),
    );
  }
}

class _SearchPlayerOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const _SearchPlayerOverlay({required this.onClose});

  @override
  State<_SearchPlayerOverlay> createState() => _SearchPlayerOverlayState();
}

class _SearchPlayerOverlayState extends State<_SearchPlayerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Cubic(0.4, 0, 0.2, 1)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() async {
    await _ctrl.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => SlideTransition(
        position: _slide,
        child: Transform.translate(offset: Offset(0, _dragOffset), child: child),
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (d) {
          if (d.delta.dy > 0) setState(() => _dragOffset += d.delta.dy);
        },
        onVerticalDragEnd: (_) {
          if (_dragOffset > 120) _close(); else setState(() => _dragOffset = 0);
        },
        child: SizedBox(
          width: size.width, height: size.height,
          child: PlayerPage(onClose: _close),
        ),
      ),
    );
  }
}
