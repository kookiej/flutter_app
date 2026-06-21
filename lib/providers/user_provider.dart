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

  // 로컬 프로필 커스터마이징 (이름·색상은 로컬 + DB, 사진은 S3 pfp_url)
  String? _localName;
  Uint8List? _localPhotoBytes; // 방금 고른 사진의 즉시 미리보기 전용 (영속 X)
  int _localColorIdx = 0;
  bool _hasLocalColor = false; // 로컬 prefs에 색상 값이 있었는지

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get restored => _restored;

  /// 표시용 닉네임 — 로컬 설정 → 서버 displayName → 기본값 순.
  String get effectiveName =>
      (_localName != null && _localName!.isNotEmpty)
          ? _localName!
          : (_user?.displayName ?? '뮤직 팬');
  Uint8List? get localPhotoBytes => _localPhotoBytes;
  String? get pfpUrl => _user?.pfpUrl;
  int get colorIdx => _localColorIdx;

  /// 프로필 편집 저장. 즉시 낙관적 반영 후 이름·색상은 DB, 사진은 S3에 반영.
  /// [photoBytes]가 있으면 새 사진 업로드, 없고 [photoDeleted]면 사진 삭제, 둘 다 아니면 사진 변경 없음.
  Future<void> saveProfile({
    required String name,
    required Uint8List? photoBytes,
    required bool photoDeleted,
    required int colorIdx,
  }) async {
    // 1) 즉시 반영 (낙관적)
    _localName = name;
    _localColorIdx = colorIdx;
    _hasLocalColor = true;
    if (photoBytes != null) {
      _localPhotoBytes = photoBytes;
    } else if (photoDeleted) {
      _localPhotoBytes = null;
    }
    notifyListeners();

    // 2) 로컬 영속 (이름·색상). 사진은 prefs에 저장하지 않음.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileName, name);
    await prefs.setInt(_kProfileColorIdx, colorIdx);

    final auth = SpotifyAuthService();

    // 3) 사진 먼저 (DB pfp_url 갱신) — 서버 미기동/실패해도 로컬 미리보기는 유지
    try {
      if (photoBytes != null) {
        final url = await auth.uploadPfp(photoBytes);
        if (url != null && _user != null) _user = _user!.copyWith(pfpUrl: url);
      } else if (photoDeleted) {
        final ok = await auth.deletePfp();
        if (ok && _user != null) _user = _user!.copyWith(clearPfpUrl: true);
      }
    } catch (_) {}

    // 4) 이름·색상 → DB. 반환 user엔 위에서 갱신된 pfp_url이 포함됨.
    try {
      final updated =
          await auth.updateProfile(displayName: name, profileColor: colorIdx);
      if (updated != null) _user = updated;
    } catch (_) {}

    if (_user != null) await setUser(_user!);
    notifyListeners();
  }

  void _loadLocalProfile(SharedPreferences prefs) {
    _localName = prefs.getString(_kProfileName);
    final storedColor = prefs.getInt(_kProfileColorIdx);
    _hasLocalColor = storedColor != null;
    _localColorIdx = storedColor ?? 0;
    _localPhotoBytes = null; // 사진은 S3 pfp_url에서 표시 (로컬 영속 안 함)
  }

  Future<void> setUser(AppUser user) async {
    _user = user;
    // 로컬에 색상 설정이 없으면 서버 값으로 시드 (다른 기기에서 바꾼 색 반영)
    if (!_hasLocalColor) _localColorIdx = user.profileColor;
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
        if (!_hasLocalColor) _localColorIdx = _user!.profileColor;
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
    _hasLocalColor = false;
    notifyListeners();
  }
}
