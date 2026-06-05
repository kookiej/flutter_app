class AppNotification {
  final int id;
  final String text;
  final String time;
  final bool read;
  const AppNotification({
    required this.id,
    required this.text,
    required this.time,
    required this.read,
  });
  AppNotification copyWith({bool? read}) {
    return AppNotification(id: id, text: text, time: time, read: read ?? this.read);
  }
}
