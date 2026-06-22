import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../artist/artist_page.dart';
import 'see_all_page.dart';
import 'widgets/home_header.dart';
import 'widgets/section_header.dart';
import 'widgets/featured_card.dart';
import 'widgets/chip_filter_row.dart';
import 'widgets/song_row.dart';
import 'widgets/artist_card.dart';
import 'widgets/compact_card.dart';
import '../../data/models/song.dart';

/// 홈 탭 콘텐츠. 탭 전환/미니 플레이어/하단 내비는 MainShell이 담당한다.
class HomeContent extends StatelessWidget {
  final VoidCallback onProfileTap;
  final void Function(Song) onToast;

  const HomeContent({
    super.key,
    required this.onProfileTap,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final songs = catalog.songs;
    final artists = catalog.artists;
    final allIdx = List.generate(songs.length, (i) => i);
    final reversedIdx = List.generate(songs.length, (i) => songs.length - 1 - i);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: HomeHeader(onProfileTap: onProfileTap),
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader(title: '추천 트랙', action: '전체보기 >',
          onAction: () => Navigator.of(context).push(
            SeeAllPage.route(title: '추천 트랙', songIndices: allIdx)))),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: 4,
              itemBuilder: (_, i) => FeaturedCard(
                song: songs[i],
                index: i,
                onTap: () {
                  context.read<PlayerProvider>().playSongInPlace(i);
                  onToast(songs[i]);
                },
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(child: ChipFilterRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: SectionHeader(title: '최근 재생', action: '전체보기 >',
          onAction: () => Navigator.of(context).push(
            SeeAllPage.route(title: '최근 재생', songIndices: allIdx)))),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => SongRow(
              song: songs[i],
              index: i,
              onTap: () {
                context.read<PlayerProvider>().playSongInPlace(i);
                onToast(songs[i]);
              },
              onSwipeAdd: () {
                context.read<PlayerProvider>().addToQueue(i);
                onToast(songs[i]);
              },
            ),
            childCount: 5,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: SectionHeader(title: '좋아하는 아티스트', action: '전체보기 >',
          onAction: () => Navigator.of(context).push(
            SeeAllPage.route(title: '좋아하는 아티스트', artists: artists)))),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: artists.length,
              itemBuilder: (_, i) => ArtistCard(
                artist: artists[i],
                onTap: () => Navigator.of(context).push(ArtistPage.route(artists[i])),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: SectionHeader(title: '당신을 위한 추천', action: '전체보기 >',
          onAction: () => Navigator.of(context).push(
            SeeAllPage.route(title: '당신을 위한 추천', songIndices: reversedIdx)))),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 185,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: songs.length,
              itemBuilder: (_, i) {
                final idx = songs.length - 1 - i;
                return CompactCard(
                  song: songs[idx],
                  onTap: () {
                    context.read<PlayerProvider>().playSongInPlace(idx);
                    onToast(songs[idx]);
                  },
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 180)),
      ],
    );
  }
}
