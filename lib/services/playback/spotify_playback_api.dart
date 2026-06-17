import 'dart:convert';
import 'package:http/http.dart' as http;

/// Web API로 재생 시작/재개를 지시한다 (SDK는 오디오 출력 담당, 트랙 지정은 Web API).
class SpotifyPlaybackApi {
  final Future<String?> Function() getToken;

  SpotifyPlaybackApi({required this.getToken});

  /// 지정 디바이스에서 트랙 재생. 성공 시 true, 실패 시 false (→ 시뮬레이션 폴백)
  Future<bool> playTrack(String deviceId, String trackId) async {
    var token = await getToken();
    if (token == null) return false;

    var res = await _put(token, deviceId, trackId);
    if (res.statusCode == 401) {
      // 토큰 만료 경합 — 한 번만 재발급 후 재시도
      token = await getToken();
      if (token == null) return false;
      res = await _put(token, deviceId, trackId);
    }
    return res.statusCode == 204 || res.statusCode == 202;
  }

  Future<http.Response> _put(String token, String deviceId, String trackId) {
    return http.put(
      Uri.parse('https://api.spotify.com/v1/me/player/play?device_id=$deviceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uris': ['spotify:track:$trackId'],
      }),
    );
  }
}
