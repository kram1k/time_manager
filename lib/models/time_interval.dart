class TimeInterval {
  final int id;
  final String start;
  final String end;

  // id передаётся при чтении из хранилища, для нового интервала генерируется.
  TimeInterval({int? id, required this.start, required this.end})
    : id = id ?? DateTime.now().microsecondsSinceEpoch;

  int get durationMinutes {
    final diff = _toMinutes(end) - _toMinutes(start);
    return diff >= 0 ? diff : diff + 24 * 60;
  }

  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
