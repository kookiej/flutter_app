import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

class NaverUser {
  final String id;
  final String? email;
  final String? nickname;
  final String? profileImage;

  const NaverUser({required this.id, this.email, this.nickname, this.profileImage});
}

class NaverAuthService {
  Future<NaverUser> login() async {
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
