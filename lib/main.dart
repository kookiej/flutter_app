import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app.dart';
import 'data/repositories/player_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: '585cb1942802e1d0bf0ec13985ac847f',
    javaScriptAppKey: 'd8c3d430ba4720a97fd3ac4f22548e94',
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  final storage = await PlayerStorage.create();
  runApp(DotMusicApp(storage: storage));
}
