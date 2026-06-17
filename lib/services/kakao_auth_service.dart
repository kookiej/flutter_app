import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:url_launcher/url_launcher.dart';

class KakaoUser {
  final String id;
  final String? nickname;
  final String? profileImageUrl;

  const KakaoUser({required this.id, this.nickname, this.profileImageUrl});
}

class KakaoAuthService {
  static const _kakaoRestApiKey = 'f86527f1864b35e44f873fcb052f1f1c';

  Future<KakaoUser> login() async {
    if (kIsWeb) {
      final redirectUri = '${Uri.base.origin}/login/kakao/oauth';
      final uri = Uri.https('kauth.kakao.com', '/oauth/authorize', {
        'response_type': 'code',
        'client_id': _kakaoRestApiKey,
        'redirect_uri': redirectUri,
      });
      await launchUrl(uri, webOnlyWindowName: '_self');
      return Completer<KakaoUser>().future; // 페이지 이동 전까지 대기
    }

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
