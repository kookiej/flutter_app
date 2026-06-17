import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../data/models/app_user.dart';

/// 서버 주도 인증: 클라이언트는 PKCE로 code만 획득하고,
/// 토큰 교환·보관·갱신은 백엔드(/api/*)가 담당한다. (login-flow.md 참고)
class SpotifyAuthService {
  static const _clientId = '6b7ade2c89e64d64bbf78f4c24c60694';
  static const _authEndpoint = 'https://accounts.spotify.com/authorize';
  static const _mobileRedirectUri = 'dotmusic://login/callback';
  // login-flow.md 기준 스코프 (email 등 deprecated 필드는 요청하지 않음)
  static const _scopes =
      'user-read-private streaming '
      'user-read-playback-state user-modify-playback-state';

  static const _jwtKey = 'session_jwt';
  static const _verifierKey = 'spotify_pkce_verifier';
  static const _stateKey = 'spotify_oauth_state';

  /// 개발 환경 기준 백엔드 주소.
  /// 웹은 백엔드가 SPA를 함께 서빙하므로 현재 origin을 그대로 사용.
  String get apiBase {
    if (kIsWeb) return Uri.base.origin;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080'; // Android 에뮬레이터 → 호스트 루프백
    }
    return 'http://127.0.0.1:8080';
  }

  String get _redirectUri =>
      kIsWeb ? '${Uri.base.origin}/login/spotify/callback' : _mobileRedirectUri;

  // ── PKCE helpers ──────────────────────────────────────────────────────────

  String _randomUrlSafe(int byteLength) {
    final random = Random.secure();
    final bytes = List<int>.generate(byteLength, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _codeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  Uri _buildAuthUri(String challenge, String state) {
    return Uri.parse(_authEndpoint).replace(queryParameters: {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'state': state,
      'scope': _scopes,
    });
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// 로그인 시작. 모바일은 완료까지 대기 후 AppUser 반환,
  /// 웹은 같은 탭으로 리다이렉트하며 [SpotifyWebRedirectException]을 던진다.
  Future<AppUser> login() async {
    final verifier = _randomUrlSafe(96);
    final challenge = _codeChallenge(verifier);
    final state = _randomUrlSafe(16);
    final authUri = _buildAuthUri(challenge, state);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_verifierKey, verifier);
      await prefs.setString(_stateKey, state);
      // 같은 탭으로 이동해야 기존 로그인 페이지가 남지 않는다
      await launchUrl(authUri, webOnlyWindowName: '_self');
      throw const SpotifyWebRedirectException();
    }

    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: 'dotmusic',
    );

    final callbackUri = Uri.parse(callbackUrl);
    if (callbackUri.queryParameters['state'] != state) {
      throw Exception('OAuth state mismatch');
    }
    final code = callbackUri.queryParameters['code'];
    if (code == null) {
      throw Exception(
          callbackUri.queryParameters['error'] ?? 'Authorization failed');
    }

    return _authenticateWithServer(code, verifier);
  }

  /// 웹 전용: 리다이렉트 복귀 후 ?code=... 처리
  Future<AppUser?> handleWebCallback(Uri uri) async {
    final code = uri.queryParameters['code'];
    if (code == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final verifier = prefs.getString(_verifierKey);
    final savedState = prefs.getString(_stateKey);
    if (verifier == null) return null;
    if (savedState != null && uri.queryParameters['state'] != savedState) {
      throw Exception('OAuth state mismatch');
    }

    final user = await _authenticateWithServer(code, verifier);
    await prefs.remove(_verifierKey);
    await prefs.remove(_stateKey);
    return user;
  }

  /// code를 서버에 넘겨 토큰 교환·DB 저장 후 자체 JWT와 유저 정보를 받는다
  Future<AppUser> _authenticateWithServer(String code, String verifier) async {
    final response = await http.post(
      Uri.parse('$apiBase/api/auth/spotify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'code_verifier': verifier,
        'redirect_uri': _redirectUri,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('서버 인증 실패 (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, data['token'] as String);

    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  // ── Session / token ───────────────────────────────────────────────────────

  Future<String?> get sessionJwt async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtKey);
  }

  /// 서버에서 현재 유저 정보 조회. 세션이 없거나 만료면 null
  Future<AppUser?> fetchMe() async {
    final jwt = await sessionJwt;
    if (jwt == null) return null;

    final response = await http.get(
      Uri.parse('$apiBase/api/me'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Spotify access token. 만료 시 서버가 자동 갱신. 재로그인 필요 시 null
  Future<String?> get accessToken async {
    final jwt = await sessionJwt;
    if (jwt == null) return null;

    final response = await http.get(
      Uri.parse('$apiBase/api/spotify/token'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['access_token'] as String?;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
    await prefs.remove(_verifierKey);
    await prefs.remove(_stateKey);
  }
}

// 웹에서 리다이렉트가 시작됐음을 알리는 신호.
// 로그인 페이지는 이를 잡아 스피너 상태를 유지한다.
class SpotifyWebRedirectException implements Exception {
  const SpotifyWebRedirectException();
}
