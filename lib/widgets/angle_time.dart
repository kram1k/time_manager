import 'dart:math' as math;

import 'package:flutter/material.dart';

class AngleTime {
  static const int minutesInCircle = 24 * 60; // 720 для 12-часового циферблата
  static const double zeroAngle = -math.pi / 2; // 00:00 наверху

  static int angleToMinutes(double angle, {int snap = 1}) {
    const twoPi = 2 * math.pi;
    double norm = (angle - zeroAngle) % twoPi;
    if (norm < 0) norm += twoPi;

    int minutes = (norm / twoPi * minutesInCircle).round();
    if (snap > 1) minutes = (minutes / snap).round() * snap;
    return minutes % minutesInCircle;
  }

  static TimeOfDay angleToTime(double angle, {int snap = 1}) {
    final m = angleToMinutes(angle, snap: snap);
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  static String format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
