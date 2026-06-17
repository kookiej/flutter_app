import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/app_user.dart';
import '../services/spotify_auth_service.dart';

class UserProvider extends ChangeNotifier {
  static const _cacheKey = 'app_user';

  AppUser? _user;
  bool _restored = false;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get restored => _restored;

  Future<void> setUser(AppUser user) async {
    _user = user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(user.toJson()));
  }

  /// 앱 시작 시 호출: 캐시를 즉시 복원하고, 서버(/api/me)와 동기화한다.
  /// 세션 JWT가 유효하면 true (자동 로그인 가능)
  Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        _user = AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        notifyListeners();
      } catch (_) {
        await prefs.remove(_cacheKey);
      }
    }

    final service = SpotifyAuthService();
    if (await service.sessionJwt == null) {
      _user = null;
      _restored = true;
      notifyListeners();
      return false;
    }

    try {
      final fresh = await service.fetchMe();
      if (fresh != null) {
        await setUser(fresh);
        _restored = true;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // 서버 미기동 등 — 캐시가 있으면 오프라인 상태로 유지
      if (_user != null) {
        _restored = true;
        notifyListeners();
        return true;
      }
    }

    // JWT가 만료/무효 → 세션 정리
    await service.logout();
    _user = null;
    _restored = true;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await SpotifyAuthService().logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    _user = null;
    notifyListeners();
  }
}
