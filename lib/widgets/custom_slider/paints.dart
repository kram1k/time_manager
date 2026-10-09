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
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.5;
  Paint sliderLine = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.5;
  Paint offIcon = Paint()..color = Colors.red.shade400;
  Paint onIcon = Paint()..color = Colors.green.shade400;
  Paint lockIcon = Paint()..color = Colors.black;

  Paint get clockArc => Paint()
    ..color = Colors.grey.shade700
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = sizes.arcStrokeWidth;
  Paint get sliderArc => clockArc;
}
