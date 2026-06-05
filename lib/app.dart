import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'data/repositories/player_storage.dart';
import 'features/login/login_page.dart';
import 'providers/notification_provider.dart';
import 'providers/player_provider.dart';
import 'providers/search_provider.dart';

class DotMusicApp extends StatelessWidget {
  final PlayerStorage storage;

  const DotMusicApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final p = PlayerProvider();
          p.init(storage);
          return p;
        }),
        ChangeNotifierProvider(create: (_) {
          final s = SearchProvider();
          s.init(storage);
          return s;
        }),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
