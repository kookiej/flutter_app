import 'package:flutter/foundation.dart';
import '../data/models/track_sync.dart';
import '../services/sync_service.dart';

/// 현재 재생곡의 가사/응원법 sync 데이터를 보유. 곡(trackId)이 바뀌면 자동 로드.
/// app.dart 에서 Player/Catalog 변화에 맞춰 [loadFor] 가 호출된다.
class SyncProvider extends ChangeNotifier {
  final _service = SyncService();
  final Map<String, TrackSync?> _cache = {};

  String? _trackId; // 현재 표시 대상 trackId
  TrackSync? _data;
  bool _fanchantMode = false; // 응원 모드 ON/OFF (사용자 토글, 곡 전환 시 리셋)

  TrackSync? get data => _data;
  bool get hasFanchant => _data?.hasFanchant ?? false;
  bool get hasLyrics => _data?.hasLyrics ?? false;
  String? get fanchantVideoUrl => _data?.fanchantVideoUrl;

  /// 둘 다 없으면(또는 DB 미적재) 가사 영역 비표시.
  bool get showLyrics => _data != null && (_data!.hasLyrics || _data!.hasFanchant);

  /// 실제 적용되는 응원 모드 (응원법 있는 곡에서만 ON).
  bool get fanchantOn => _fanchantMode && hasFanchant;

  /// 응원 버튼 토글. 응원법 있는 곡에서만 동작.
  void toggleFanchant() {
    if (!hasFanchant) return;
    _fanchantMode = !_fanchantMode;
    notifyListeners();
  }

  Future<void> loadFor(String? trackId) async {
    if (trackId == _trackId) return; // 동일 곡(닫기/열기 등) → 모드·데이터 유지
    _trackId = trackId;
    _fanchantMode = false; // 곡 전환 시 무조건 응원 모드 초기화

    if (trackId == null) {
      _data = null;
      notifyListeners();
      return;
    }

    if (_cache.containsKey(trackId)) {
      _data = _cache[trackId];
      notifyListeners();
      return;
    }

    // 새 곡 로드 시작: 이전 데이터 비우고(영역 즉시 숨김) 가져온다.
    _data = null;
    notifyListeners();

    final result = await _service.fetch(trackId);
    _cache[trackId] = result;
    // 로드 중 다른 곡으로 바뀌었으면 무시
    if (_trackId == trackId) {
      _data = result;
      notifyListeners();
    }
  }
}
