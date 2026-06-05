import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoUser {
  final String id;
  final String? nickname;
  final String? profileImageUrl;

  const KakaoUser({required this.id, this.nickname, this.profileImageUrl});
}

class KakaoAuthService {
  Future<KakaoUser> login() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
      } catch (e) {
        if (e is PlatformException && e.code == 'CANCELED') rethrow;
        await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      await UserApi.instance.loginWithKakaoAccount();
    }
    try {
      return await _fetchUserInfo();
    } catch (e) {
      debugPrint('[KakaoAuth] me() failed: $e');
      return const KakaoUser(id: 'unknown');
    }
  }

  Future<KakaoUser> _fetchUserInfo() async {
    final user = await UserApi.instance.me();
    return KakaoUser(
      id: user.id.toString(),
      nickname: user.kakaoAccount?.profile?.nickname,
      profileImageUrl: user.kakaoAccount?.profile?.profileImageUrl,
    );
  }
}
