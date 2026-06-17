import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'playback_state.dart';

@JS('Spotify.Player')
extension type _PlayerJS._(JSObject _) implements JSObject {
  external _PlayerJS(JSObject options);
  external JSPromise<JSBoolean> connect();
  external void disconnect();
  external void addListener(String event, JSFunction callback);
  external JSPromise<JSAny?> togglePlay();
  external JSPromise<JSAny?> pause();
  external JSPromise<JSAny?> resume();
  external JSPromise<JSAny?> seek(int positionMs);
}

/// Spotify Web Playback SDK 래퍼 (웹 전용).
/// index.html에서 spotify-player.js와 spotifySDKReadyPromise를 로드해 둔다.
class SpotifyWebPlayer {
  _PlayerJS? _player;
  String? deviceId;

  bool get isSupported => true;

  /// SDK 초기화 + connect. ready 이벤트의 device_id 반환 (실패 시 null → 시뮬레이션 폴백)
  Future<String?> connect({
    required Future<String?> Function() getToken,
    required void Function(WebPlaybackState) onState,
    required void Function() onError,
  }) async {
    try {
      // SDK 스크립트 로드 대기 (차단됐으면 null/timeout → 폴백)
      final sdkReady = globalContext['spotifySDKReadyPromise'] as JSPromise?;
      if (sdkReady == null) return null;
      await sdkReady.toDart.timeout(const Duration(seconds: 10));

      final ready = Completer<String?>();
      final options = JSObject();
      options['name'] = 'dot music'.toJS;
      options['volume'] = 0.8.toJS;
      // SDK가 토큰 필요 시마다 호출 — 백엔드가 만료 전 자동 갱신해서 내려준다
      options['getOAuthToken'] = ((JSFunction cb) {
        getToken().then((t) => cb.callAsFunction(null, (t ?? '').toJS));
      }).toJS;

      final player = _PlayerJS(options);
      _player = player;

      player.addListener('ready', ((JSObject e) {
        deviceId = (e['device_id'] as JSString?)?.toDart;
        if (!ready.isCompleted) ready.complete(deviceId);
      }).toJS);
      player.addListener('not_ready', ((JSObject e) {
        deviceId = null;
      }).toJS);
      player.addListener('player_state_changed', ((JSObject? s) {
        if (s == null) return;
        onState(_parseState(s));
      }).toJS);
      for (final event in [
        'initialization_error',
        'authentication_error',
        'account_error',
        'playback_error',
      ]) {
        player.addListener(event, ((JSObject? e) => onError()).toJS);
      }

      final connected = (await player.connect().toDart).toDart;
      if (!connected) return null;
      return await ready.future
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  WebPlaybackState _parseState(JSObject s) {
    final trackWindow = s['track_window'] as JSObject?;
    final currentTrack = trackWindow?['current_track'] as JSObject?;
    return WebPlaybackState(
      paused: (s['paused'] as JSBoolean?)?.toDart ?? true,
      positionMs: (s['position'] as JSNumber?)?.toDartInt ?? 0,
      durationMs: (s['duration'] as JSNumber?)?.toDartInt ?? 0,
      trackId: (currentTrack?['id'] as JSString?)?.toDart,
    );
  }

  Future<void> togglePlay() async => _player?.togglePlay().toDart;
  Future<void> resume() async => _player?.resume().toDart;
  Future<void> pause() async => _player?.pause().toDart;
  Future<void> seek(int positionMs) async => _player?.seek(positionMs).toDart;

  void disconnect() {
    _player?.disconnect();
    _player = null;
    deviceId = null;
  }
}
