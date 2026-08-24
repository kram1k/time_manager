import 'package:flutter/material.dart';
import 'sizes.dart';

class Paints {
  final Sizes sizes;
  Paints({required this.sizes});

  Paint bigCircle = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.blue.shade900;
  Paint smallCircle = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.blue.shade300;
  Paint clockLine = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.5;

  Paint get sliderArc => Paint()
    ..color = Colors.blue.shade300
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = sizes.arcStrokeWidth;
}
