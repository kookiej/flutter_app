import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/search_provider.dart';
import '../home/widgets/song_row.dart';
import '../shared/icons/app_icons.dart';
import '../../data/models/song.dart';
import 'widgets/genre_grid.dart';
import 'widgets/mood_row.dart';
import 'widgets/recent_search_row.dart';
import 'widgets/search_input.dart';

/// 검색 탭 콘텐츠. 탭 전환/미니 플레이어/하단 내비는 MainShell이 담당한다.
class SearchContent extends StatefulWidget {
  final VoidCallback onProfileTap;
  final void Function(Song) onToast;

  const SearchContent({super.key, required this.onProfileTap, required this.onToast});

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
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
                          onTap: widget.onProfileTap,
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
                          widget.onToast(song);
                        },
                        onSwipeAdd: () {
                          context.read<PlayerProvider>().addSongToQueue(song);
                          widget.onToast(song);
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
