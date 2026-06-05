import 'package:flutter/material.dart';
import '../data/mock/notifications.dart';
import '../data/models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifs = List.from(kNotifications);

  List<AppNotification> get notifs => List.unmodifiable(_notifs);
  bool get hasUnread => _notifs.any((n) => !n.read);

  void markRead(int id) {
    final idx = _notifs.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifs[idx] = _notifs[idx].copyWith(read: true);
      notifyListeners();
    }
  }

  void markAllRead() {
    _notifs = _notifs.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
  }
}
