import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/app_user.dart';
import '../services/spotify_auth_service.dart';

class UserProvider extends ChangeNotifier {
  static const _cacheKey = 'app_user';
  static const _kProfileName = 'profile_name';
  static const _kProfilePhoto = 'profile_photo';
  static const _kProfileColorIdx = 'profile_color_idx';

  AppUser? _user;
  bool _restored = false;

  // 로컬 프로필 커스터마이징 (서버 계정과 별개, 기기 로컬 저장)
  String? _localName;
  Uint8List? _localPhotoBytes;
  int _localColorIdx = 0;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get restored => _restored;

  /// 표시용 닉네임 — 로컬 설정 → 서버 displayName → 기본값 순.
  String get effectiveName =>
      (_localName != null && _localName!.isNotEmpty)
          ? _localName!
          : (_user?.displayName ?? '뮤직 팬');
  Uint8List? get localPhotoBytes => _localPhotoBytes;
  int get colorIdx => _localColorIdx;

  /// 프로필 편집 저장 — 즉시 반영 후 로컬 영속화.
  Future<void> saveLocalProfile({
    required String name,
    required Uint8List? photoBytes,
    required int colorIdx,
  }) async {
    _localName = name;
    _localPhotoBytes = photoBytes;
    _localColorIdx = colorIdx;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileName, name);
    await prefs.setInt(_kProfileColorIdx, colorIdx);
    if (photoBytes != null) {
      await prefs.setString(_kProfilePhoto, base64Encode(photoBytes));
    } else {
      await prefs.remove(_kProfilePhoto);
    }
  }

  void _loadLocalProfile(SharedPreferences prefs) {
    _localName = prefs.getString(_kProfileName);
    _localColorIdx = prefs.getInt(_kProfileColorIdx) ?? 0;
    final photo = prefs.getString(_kProfilePhoto);
    _localPhotoBytes = photo != null ? base64Decode(photo) : null;
  }

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

    _loadLocalProfile(prefs);

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
    await prefs.remove(_kProfileName);
    await prefs.remove(_kProfilePhoto);
    await prefs.remove(_kProfileColorIdx);
    _user = null;
    _localName = null;
    _localPhotoBytes = null;
    _localColorIdx = 0;
    notifyListeners();
  }
}
