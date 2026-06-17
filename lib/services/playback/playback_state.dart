/// Web Playback SDK의 player_state_changed 이벤트를 플랫폼 중립적으로 표현
class WebPlaybackState {
  final bool paused;
  final int positionMs;
  final int durationMs;
  final String? trackId;

  const WebPlaybackState({
    required this.paused,
    required this.positionMs,
    required this.durationMs,
    this.trackId,
  });
}
