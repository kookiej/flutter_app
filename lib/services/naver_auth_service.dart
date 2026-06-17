import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:url_launcher/url_launcher.dart';

class NaverUser {
  final String id;
  final String? email;
  final String? nickname;
  final String? profileImage;

  const NaverUser({required this.id, this.email, this.nickname, this.profileImage});
}

class NaverAuthService {
  static const _naverClientId = 'KVD_1LF4XKHn1PEKo8Zn';

  Future<NaverUser> login() async {
    if (kIsWeb) {
      final redirectUri = '${Uri.base.origin}/login/naver/oauth';
      final state = List.generate(16, (_) => Random.secure().nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      final uri = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
        'response_type': 'code',
        'client_id': _naverClientId,
        'redirect_uri': redirectUri,
        'state': state,
      });
      await launchUrl(uri, webOnlyWindowName: '_self');
      return Completer<NaverUser>().future; // 페이지 이동 전까지 대기
    }

    final result = await FlutterNaverLogin.logIn();
    if (result.status != NaverLoginStatus.loggedIn) {
      throw Exception('네이버 로그인이 취소됐습니다.');
    }
    final account = result.account;
    if (account != null) {
      return NaverUser(
        id: account.id ?? 'unknown',
        email: account.email,
        nickname: account.nickname,
        profileImage: account.profileImage,
      );
    }
    try {
      final fetched = await FlutterNaverLogin.getCurrentAccount();
      return NaverUser(
        id: fetched.id ?? 'unknown',
        email: fetched.email,
        nickname: fetched.nickname,
        profileImage: fetched.profileImage,
      );
    } catch (e) {
      debugPrint('[NaverAuth] getCurrentAccount() failed: $e');
      return const NaverUser(id: 'unknown');
    }
  }
}
