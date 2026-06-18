import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 설정 화면의 재생/알림 토글 상태. 각각 독립 토글이며 로컬에 영속화한다.
class SettingsProvider extends ChangeNotifier {
  static const _kHqWifi = 'settings_hq_wifi';
  static const _kHqCellular = 'settings_hq_cellular';
  static const _kPush = 'settings_push';

  bool _hqWifi = true;
  bool _hqCellular = false;
  bool _push = true;

  bool get hqWifi => _hqWifi;
  bool get hqCellular => _hqCellular;
  bool get push => _push;

  SettingsProvider() {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _hqWifi = prefs.getBool(_kHqWifi) ?? true;
    _hqCellular = prefs.getBool(_kHqCellular) ?? false;
    _push = prefs.getBool(_kPush) ?? true;
    notifyListeners();
  }

  Future<void> setHqWifi(bool v) async {
    _hqWifi = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHqWifi, v);
  }

  Future<void> setHqCellular(bool v) async {
    _hqCellular = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHqCellular, v);
  }

  Future<void> setPush(bool v) async {
    _push = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPush, v);
  }
}
