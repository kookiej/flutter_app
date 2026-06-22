String formatTime(double seconds) {
  final s = seconds.floor();
  final m = s ~/ 60;
  final sec = s % 60;
  return '$m:${sec.toString().padLeft(2, '0')}';
}

/// 출시일 → "YYYY년 MM월 DD일".
String formatReleaseDate(DateTime date) {
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '${date.year}년 $mm월 $dd일';
}

/// 앨범 전체 재생시간 → "n분" 또는 "h시간 m분".
String formatTotalDuration(int totalSeconds) {
  final totalMin = (totalSeconds / 60).round();
  if (totalMin < 60) return '$totalMin분';
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  return m == 0 ? '$h시간' : '$h시간 $m분';
}
