import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'data/repositories/player_storage.dart';
import 'features/login/login_page.dart';
import 'providers/bookmark_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/like_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/player_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/user_provider.dart';
import 'services/spotify_auth_service.dart';

class DotMusicApp extends StatelessWidget {
  final PlayerStorage storage;

  const DotMusicApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final s = SearchProvider();
          s.init(storage);
          return s;
        }),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        // 로그인/카탈로그 상태 변화를 PlayerProvider에 주입 (선언 순서 중요)
        ChangeNotifierProxyProvider2<UserProvider, CatalogProvider, PlayerProvider>(
          create: (_) {
            final p = PlayerProvider();
            p.init(storage);
            return p;
          },
          update: (_, user, catalog, player) {
            if (user.isLoggedIn) catalog.ensureLoaded();
            player!.attachSpotify(
              enabled: kIsWeb &&
                  user.isLoggedIn &&
                  (user.user?.isPremium ?? false),
              trackIdOf: (i) => catalog.songs[i].spotifyTrackId,
              getToken: () => SpotifyAuthService().accessToken,
            );
            return player;
          },
        ),
        // 현재 재생곡 변화 시 DB에서 가사/응원법 sync 데이터 자동 로드
        ChangeNotifierProxyProvider2<PlayerProvider, CatalogProvider, SyncProvider>(
          create: (_) => SyncProvider(),
          update: (_, player, catalog, sync) {
            sync!.loadFor(catalog.songs[player.songIdx].spotifyTrackId);
            return sync;
          },
        ),
      ],
      child: MaterialApp(
        title: '._.',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.bgPrimary,
          ),
          scaffoldBackgroundColor: AppColors.bgPrimary,
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
