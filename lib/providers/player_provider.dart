import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/mock/songs.dart';
import '../data/models/song.dart';
import '../data/repositories/player_storage.dart';

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

  Song get currentSong => kSongs[_queue[_queuePos]];
  double get progress => _currentTime / currentSong.duration;
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

  void playSong(Song song) {
    final idx = kSongs.indexOf(song);
    if (idx >= 0) playSongInPlace(idx);
  }

  void addSongToQueue(Song song) {
    final idx = kSongs.indexOf(song);
    if (idx >= 0) addToQueue(idx);
  }

  void playNext(int songIdx) {
    _queue.insert(_queuePos + 1, songIdx);
    if (!_isPlaying) {
      _queuePos++;
      _currentTime = 0;
      _isPlaying = true;
      _startTimer();
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
    _persist();
    notifyListeners();
  }

  void prev() {
    if (_currentTime > 3) {
      _currentTime = 0;
    } else if (_queuePos > 0) {
      _queuePos--;
      _currentTime = 0;
    } else {
      _currentTime = 0;
    }
    _persist();
    notifyListeners();
  }

  void seek(double seconds) {
    _currentTime = seconds.clamp(0, currentSong.duration.toDouble());
    _storage.saveCurrentTime(_currentTime);
    notifyListeners();
  }

  void addToQueue(int songIdx) {
    _queue.add(songIdx);
    _storage.saveQueue(_queue);
    notifyListeners();
  }

  void removeFromQueue(int queuePosition) {
    if (_queue.length <= 1) return;
    if (queuePosition == _queuePos) return;
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isPlaying) return;
      _currentTime += 0.5;
      if (_currentTime >= currentSong.duration) {
        _onSongEnd();
      } else {
        notifyListeners();
      }
    });
  }

  void _onSongEnd() {
    if (_repeat == 2) {
      _currentTime = 0;
    } else if (_repeat == 1) {
      if (_queuePos < _queue.length - 1) {
        _queuePos++;
      } else {
        _queuePos = 0;
      }
      _currentTime = 0;
    } else {
      if (_queuePos < _queue.length - 1) {
        _queuePos++;
        _currentTime = 0;
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
    super.dispose();
  }
}
