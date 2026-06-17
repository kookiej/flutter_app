import 'playback_state.dart';

/// 비웹 플랫폼용 no-op 구현. PlayerProvider는 isSupported=false를 보고
/// 시뮬레이션 재생으로 폴백한다.
class SpotifyWebPlayer {
  bool get isSupported => false;
  String? get deviceId => null;

  Future<String?> connect({
    required Future<String?> Function() getToken,
    required void Function(WebPlaybackState) onState,
    required void Function() onError,
  }) async =>
      null;

  Future<void> togglePlay() async {}
  Future<void> resume() async {}
  Future<void> pause() async {}
  Future<void> seek(int positionMs) async {}
  void disconnect() {}
}
