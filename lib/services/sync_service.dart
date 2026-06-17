import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/track_sync.dart';
import 'spotify_auth_service.dart';

/// 백엔드에서 곡별 가사/응원법 sync 데이터를 가져온다.
/// 곡이 DB에 없으면(404) null 을 반환 → 호출부는 "가사 영역 비표시"로 처리.
class SyncService {
  final _auth = SpotifyAuthService();

  Future<TrackSync?> fetch(String trackId) async {
    final uri = Uri.parse('${_auth.apiBase}/api/tracks/$trackId/sync');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 404) return null;
      if (res.statusCode != 200) return null;
      final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return TrackSync.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
