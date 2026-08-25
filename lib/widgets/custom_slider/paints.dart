import 'package:flutter/material.dart';
import 'sizes.dart';

class Paints {
  final Sizes sizes;
  Paints({required this.sizes});

  Paint bigCircle = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.black;
  Paint smallCircle = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.grey.shade900;
  Paint clockLine = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.5;

  Paint get sliderArc => Paint()
    ..color = Colors.grey.shade900
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = sizes.arcStrokeWidth;
}
