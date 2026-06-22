import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/mock/songs.dart';
import '../data/models/song.dart';
import '../data/repositories/player_storage.dart';
import '../services/playback/playback_state.dart';
import '../services/playback/spotify_playback_api.dart';
import '../services/playback/spotify_web_player_stub.dart'
    if (dart.library.js_interop) '../services/playback/spotify_web_player_web.dart';

class PlayerProvider extends ChangeNotifier {
  late PlayerStorage _storage;
  bool _initialized = false;

  List<int> _queue = List.generate(kSongs.length, (i) => i);
  int _queuePos = 0;
  bool _isPlaying = false;
  double _currentTime = 0.0;
  int _repeat = 0; // 0: off, 1: all, 2: one
  bool _shuffle = false;
  List<int>? _preShuffleQueue;

  Timer? _timer;

  // ── Spotify (웹 전용 — 비웹은 stub이 isSupported=false) ─────────────────────
  final _web = SpotifyWebPlayer();
  SpotifyPlaybackApi? _playApi;
  String? Function(int songIdx)? _trackIdOf; // catalog.songs[i].spotifyTrackId
  Future<String?> Function()? _getToken;
  bool _spotifyEnabled = false; // 웹 && 로그인 && Premium
  bool _spotifyReady = false; // SDK connect + device_id 확보됨
  bool _spotifyStarted = false; // Web API로 트랙 재생을 시작한 상태
  bool _connecting = false;
  int _webDurationMs = 0; // SDK가 알려준 실제 트랙 길이

  Song get currentSong => kSongs[_queue[_queuePos]];

  /// Spotify 재생 중엔 실제 트랙 길이, 아니면 목업 duration
  int get effectiveDuration => _spotifyStarted && _webDurationMs > 0
      ? (_webDurationMs / 1000).round()
      : currentSong.duration;

  double get progress => _currentTime / effectiveDuration;
  int get songIdx => _queue[_queuePos];
  List<int> get queue => List.unmodifiable(_queue);
  int get queuePos => _queuePos;
  bool get isPlaying => _isPlaying;
  double get currentTime => _currentTime;
  int get repeat => _repeat;
  bool get shuffle => _shuffle;
  bool get initialized => _initialized;

  Future<void> init(PlayerStorage storage) async {
    _storage = storage;
    _queue = storage.queue;
    _queuePos = _queue.indexOf(storage.songIdx);
    if (_queuePos < 0) _queuePos = 0;
    _currentTime = storage.currentTime;
    _initialized = true;
    notifyListeners();
  }

  /// app.dart에서 로그인/카탈로그 상태가 바뀔 때마다 호출 (build 중이므로 notify 금지)
  void attachSpotify({
    required bool enabled,
    String? Function(int songIdx)? trackIdOf,
    Future<String?> Function()? getToken,
  }) {
    _trackIdOf = trackIdOf;
    _getToken = getToken;
    if (getToken != null) {
      _playApi ??= SpotifyPlaybackApi(getToken: getToken);
    }
    if (_spotifyEnabled && !enabled) {
      // 로그아웃 등으로 비활성화 → 연결 해제 후 시뮬레이션으로 복귀
      _web.disconnect();
      _spotifyReady = false;
      _spotifyStarted = false;
    }
    _spotifyEnabled = enabled && _web.isSupported;
  }

  void playSong(Song song) {
    final idx = _indexOfSong(song);
    if (idx >= 0) playSongInPlace(idx);
  }

  void addSongToQueue(Song song) {
    final idx = _indexOfSong(song);
    if (idx >= 0) addToQueue(idx);
  }

  /// 보강된(copyWith) 인스턴스가 와도 매칭되도록 제목+아티스트로 찾는다
  int _indexOfSong(Song song) => kSongs
      .indexWhere((s) => s.title == song.title && s.artist == song.artist);

  void playNext(int songIdx) {
    _queue.insert(_queuePos + 1, songIdx);
    if (!_isPlaying) {
      _queuePos++;
      _currentTime = 0;
      _isPlaying = true;
      _startTimer();
      _playCurrent();
    }
    _persist();
    notifyListeners();
  }

  void play(int songIdx) {
    _queuePos = _queue.indexOf(songIdx);
    if (_queuePos < 0) {
      _queue.add(songIdx);
      _queuePos = _queue.length - 1;
    }
    _currentTime = 0;
    _isPlaying = true;
    _startTimer();
    _playCurrent();
    _persist();
    notifyListeners();
  }

  void playSongInPlace(int songIdx) {
    final insertAt = _queuePos + 1;
    _queue.insert(insertAt, songIdx);
    _queuePos = insertAt;
    _currentTime = 0;
    _isPlaying = true;
    _startTimer();
    _playCurrent();
    _persist();
    notifyListeners();
  }

  /// 주어진 곡 인덱스 목록으로 큐를 교체하고 첫 곡부터 재생 (전체 듣기).
  void playAll(List<int> songIndices) {
    if (songIndices.isEmpty) return;
    _queue = List.of(songIndices);
    _queuePos = 0;
    _shuffle = false;
    _preShuffleQueue = null;
    _currentTime = 0;
    _isPlaying = true;
    _startTimer();
    _playCurrent();
    _persist();
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    _storage.saveIsPlaying(_isPlaying);
    if (_spotifyEnabled) {
      if (_isPlaying && !_spotifyStarted) {
        _playCurrent(); // 첫 재생: SDK 연결 + 트랙 로드 (사용자 제스처 시점)
      } else if (_spotifyStarted) {
        _isPlaying ? _web.resume() : _web.pause();
      }
    }
    notifyListeners();
  }

  void next() {
    if (_queuePos < _queue.length - 1) {
      _queuePos++;
    } else if (_repeat == 1) {
      _queuePos = 0;
    } else {
      _queuePos = 0;
      _isPlaying = true;
      _startTimer();
    }
    _currentTime = 0;
    _playCurrent();
    _persist();
    notifyListeners();
  }

  void prev() {
    if (_currentTime > 3) {
      _currentTime = 0;
      _seekWeb(0);
    } else if (_queuePos > 0) {
      _queuePos--;
      _currentTime = 0;
      _playCurrent();
    } else {
      _currentTime = 0;
      _seekWeb(0);
    }
    _persist();
    notifyListeners();
  }

  void seek(double seconds) {
    _currentTime = seconds.clamp(0, effectiveDuration.toDouble());
    _seekWeb((_currentTime * 1000).round());
    _storage.saveCurrentTime(_currentTime);
    notifyListeners();
  }

  void addToQueue(int songIdx) {
    _queue.add(songIdx);
    _storage.saveQueue(_queue);
    notifyListeners();
  }

  void removeFromQueue(int queuePosition) {
    if (_queue.length <= 1) return; // 마지막 한 곡은 삭제 불가
    if (queuePosition == _queuePos) {
      final wasLast = queuePosition == _queue.length - 1;
      _queue.removeAt(queuePosition);
      // 마지막곡이었으면 이전 곡으로, 아니면 다음 곡이 현재 위치로 밀려 들어옴
      if (wasLast) _queuePos = _queue.length - 1;
      _currentTime = 0;
      _playCurrent();
      _persist();
      notifyListeners();
      return;
    }
    _queue.removeAt(queuePosition);
    if (queuePosition < _queuePos) _queuePos--;
    _storage.saveQueue(_queue);
    notifyListeners();
  }

  void reorderQueue(int from, int to) {
    final item = _queue.removeAt(from);
    _queue.insert(to, item);
    if (from == _queuePos) {
      _queuePos = to;
    } else if (from < _queuePos && to >= _queuePos) {
      _queuePos--;
    } else if (from > _queuePos && to <= _queuePos) {
      _queuePos++;
    }
    _storage.saveQueue(_queue);
    notifyListeners();
  }

  void toggleRepeat() {
    _repeat = (_repeat + 1) % 3;
    notifyListeners();
  }

  void toggleShuffle() {
    if (_shuffle) {
      if (_preShuffleQueue != null) {
        final currentSongIdx = _queue[_queuePos];
        _queue = List.from(_preShuffleQueue!);
        _queuePos = _queue.indexOf(currentSongIdx);
        if (_queuePos < 0) _queuePos = 0;
        _preShuffleQueue = null;
      }
    } else {
      _preShuffleQueue = List.from(_queue);
      final current = _queue[_queuePos];
      final rest = _queue.where((i) => i != current).toList()..shuffle(Random());
      _queue = [current, ...rest];
      _queuePos = 0;
    }
    _shuffle = !_shuffle;
    _storage.saveQueue(_queue);
    notifyListeners();
  }

  // ── Spotify 위임 ────────────────────────────────────────────────────────────

  /// 현재 곡 재생 훅 — Spotify 모드면 실제 트랙 재생, 아니면 no-op (시뮬레이션 유지)
  Future<void> _playCurrent() async {
    final trackId = _trackIdOf?.call(songIdx);
    if (!_spotifyEnabled || trackId == null || _playApi == null) return;
    if (!_spotifyReady) await _connectSpotify(); // 첫 재생 = 사용자 제스처 시점
    final deviceId = _web.deviceId;
    if (!_spotifyReady || deviceId == null) return; // 연결 실패 → 시뮬레이션
    _webDurationMs = 0;
    final ok = await _playApi!.playTrack(deviceId, trackId);
    if (ok) {
      _spotifyStarted = true;
    } else {
      // 디바이스 유실(탭 절전 등) → 폴백, 다음 재생 시도에서 재연결
      _spotifyReady = false;
      _spotifyStarted = false;
    }
  }

  Future<void> _connectSpotify() async {
    if (_connecting || _getToken == null) return;
    _connecting = true;
    try {
      final deviceId = await _web.connect(
        getToken: _getToken!,
        onState: _onWebState,
        onError: () {
          // 인증/계정(비Premium)/재생 오류 → 시뮬레이션 폴백
          _spotifyReady = false;
          _spotifyStarted = false;
        },
      );
      _spotifyReady = deviceId != null;
    } finally {
      _connecting = false;
    }
  }

  /// SDK player_state_changed → 로컬 상태 동기화.
  /// 위치는 이벤트 사이를 기존 500ms 타이머가 보간한다.
  void _onWebState(WebPlaybackState s) {
    if (!_spotifyStarted) return;
    if (s.durationMs > 0) _webDurationMs = s.durationMs;

    // 트랙 끝: SDK는 position 0에서 일시정지 상태가 된다 → 곡 종료 처리
    final nearEnd = _currentTime >= effectiveDuration - 3;
    if (s.paused && s.positionMs == 0 && _isPlaying && nearEnd) {
      _onSongEnd();
      return;
    }

    _isPlaying = !s.paused;
    _currentTime = s.positionMs / 1000.0;
    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void _seekWeb(int positionMs) {
    if (_spotifyStarted) _web.seek(positionMs);
  }

  // ── 시뮬레이션 타이머 ────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isPlaying) return;
      _currentTime += 0.5;
      if (_currentTime >= effectiveDuration) {
        _onSongEnd();
      } else {
        notifyListeners();
      }
    });
  }

  void _onSongEnd() {
    if (_repeat == 2) {
      _currentTime = 0;
      _playCurrent(); // Spotify 모드: 같은 트랙 다시 재생
    } else if (_repeat == 1) {
      if (_queuePos < _queue.length - 1) {
        _queuePos++;
      } else {
        _queuePos = 0;
      }
      _currentTime = 0;
      _playCurrent();
    } else {
      if (_queuePos < _queue.length - 1) {
        _queuePos++;
        _currentTime = 0;
        _playCurrent();
      } else {
        _isPlaying = false;
        _timer?.cancel();
        _currentTime = 0;
      }
    }
    _persist();
    notifyListeners();
  }

  void _persist() {
    _storage.saveSongIdx(_queue[_queuePos]);
    _storage.saveIsPlaying(_isPlaying);
    _storage.saveCurrentTime(_currentTime);
    _storage.saveQueue(_queue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _web.disconnect();
    super.dispose();
  }
}
