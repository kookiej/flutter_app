String formatTime(double seconds) {
  final s = seconds.floor();
  final m = s ~/ 60;
  final sec = s % 60;
  return '$m:${sec.toString().padLeft(2, '0')}';
}
