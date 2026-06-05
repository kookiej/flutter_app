import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/songs.dart';
import '../../data/mock/artists.dart';
import '../../providers/player_provider.dart';
import '../search/search_page.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/mini_player_bar.dart';
import '../shared/widgets/noise_overlay.dart';
import '../shared/widgets/profile_panel.dart';
import '../shared/widgets/toast_snackbar.dart';
import '../player/player_page.dart';
import 'widgets/home_header.dart';
import 'widgets/section_header.dart';
import 'widgets/featured_card.dart';
import 'widgets/chip_filter_row.dart';
import 'widgets/song_row.dart';
import 'widgets/artist_card.dart';
import 'widgets/compact_card.dart';
import '../../data/models/song.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _navIdx = 0;
  bool _profileVisible = false;
  bool _playerVisible = false;
  Song? _toastSong;

  late AnimationController _mountCtrl;
  late Animation<double> _mountOpacity;

  @override
  void initState() {
    super.initState();
    _mountCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _mountOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 60), () => _mountCtrl.forward());
  }

  @override
  void dispose() {
    _mountCtrl.dispose();
    super.dispose();
  }

  void _showToast(Song song) {
    setState(() => _toastSong = song);
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: FadeTransition(
        opacity: _mountOpacity,
        child: Stack(
          children: [
            // background
            const Positioned.fill(child: ColoredBox(color: AppColors.bgPrimary)),
            // ambient glow
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
            // main content
            Column(
              children: [
                Expanded(
                  child: _navIdx == 0 ? _HomeContent(
                    onProfileTap: () => setState(() => _profileVisible = true),
                    onPlayerOpen: () => setState(() => _playerVisible = true),
                    onToast: _showToast,
                  ) : const SizedBox(),
                ),
                // mini player + nav
                if (player.initialized) ...[
                  if (_toastSong != null)
                    ToastSnackbar(song: _toastSong!, onDone: () => setState(() => _toastSong = null)),
                  MiniPlayerBar(onTap: () => setState(() => _playerVisible = true)),
                ],
                BottomNavBar(
                  currentIndex: _navIdx,
                  onTap: (i) {
                    if (i == 1) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchPage()));
                    } else {
                      setState(() => _navIdx = i);
                    }
                  },
                ),
              ],
            ),
            // profile panel overlay
            ProfilePanel(
              visible: _profileVisible,
              onClose: () => setState(() => _profileVisible = false),
            ),
            // player overlay
            if (_playerVisible)
              _PlayerOverlay(onClose: () => setState(() => _playerVisible = false)),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onPlayerOpen;
  final void Function(Song) onToast;

  const _HomeContent({
    required this.onProfileTap,
    required this.onPlayerOpen,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HomeHeader(onProfileTap: onProfileTap)),
        SliverToBoxAdapter(child: SectionHeader(title: '추천 트랙', action: '전체보기 >')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: 4,
              itemBuilder: (_, i) => FeaturedCard(
                song: kSongs[i],
                index: i,
                onTap: () {
                  context.read<PlayerProvider>().play(i);
                  onPlayerOpen();
                },
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(child: ChipFilterRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: SectionHeader(title: '최근 재생', action: '전체보기 >')),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => SongRow(
              song: kSongs[i],
              index: i,
              onTap: () {
                context.read<PlayerProvider>().play(i);
                onPlayerOpen();
              },
              onSwipeAdd: () {
                context.read<PlayerProvider>().addToQueue(i);
                onToast(kSongs[i]);
              },
            ),
            childCount: 5,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: SectionHeader(title: '좋아하는 아티스트', action: '전체보기 >')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: kArtists.length,
              itemBuilder: (_, i) => ArtistCard(artist: kArtists[i]),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: SectionHeader(title: '당신을 위한 추천', action: '전체보기 >')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 185,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: kSongs.length,
              itemBuilder: (_, i) {
                final idx = kSongs.length - 1 - i;
                return CompactCard(
                  song: kSongs[idx],
                  onTap: () {
                    context.read<PlayerProvider>().play(idx);
                    onPlayerOpen();
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

class _PlayerOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const _PlayerOverlay({required this.onClose});

  @override
  State<_PlayerOverlay> createState() => _PlayerOverlayState();
}

class _PlayerOverlayState extends State<_PlayerOverlay> with SingleTickerProviderStateMixin {
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
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: child,
        ),
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (d) {
          if (d.delta.dy > 0) setState(() => _dragOffset += d.delta.dy);
        },
        onVerticalDragEnd: (d) {
          if (_dragOffset > 120) {
            _close();
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        child: SizedBox(
          width: size.width, height: size.height,
          child: PlayerPage(onClose: _close),
        ),
      ),
    );
  }
}
