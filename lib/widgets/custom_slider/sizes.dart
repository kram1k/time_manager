import 'package:flutter/material.dart';


class Sizes {
  final Size size;
  Sizes({required this.size});

  final bigCircleRadius = 130.0;
  final arcStrokeWidth = 28.0;

  Offset get center => Offset(size.width / 2, size.height / 2);
  double get arcRadius => bigCircleRadius * 2 - arcStrokeWidth - 16;
  double get smallCircleRadius => bigCircleRadius / 1.5;
  double get clockRadius => smallCircleRadius - 4.0;
}