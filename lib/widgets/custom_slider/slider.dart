import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sizes.dart';
import 'clock_ticks.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider({super.key});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.height / 4,
      child: CustomPaint(painter: SliderPainter()),
    );
  }
}

class SliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Sizes sizes = Sizes(size: size);
    // BigCircle
    Paint bigCirclePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.shade900;
    canvas.drawCircle(sizes.center, sizes.bigCircleRadius, bigCirclePaint);
    // smallCircle
    Paint smallCircle = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.shade300;
    canvas.drawCircle(sizes.center, sizes.smallCircleRadius, smallCircle);
    // Text
    _smallCircleTextCreater(canvas: canvas, sizes: sizes);
    // Arc
    Paint arcPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = sizes.arcStrokeWidth;
    canvas.drawArc(
      Rect.fromCenter(
        center: sizes.center,
        width: sizes.arcRadius,
        height: sizes.arcRadius,
      ),
      -math.pi / 2,
      3 * math.pi / 4,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void _smallCircleTextCreater({required Canvas canvas, required Sizes sizes}) {
    // big
    Paint linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;
    _drawPartOfClock(
      angles: ClockTicks.medium + ClockTicks.large,
      canvas: canvas,
      sizes: sizes,
      paint: linePaint,
      lineLength: 6,
    );
    _drawPartOfClock(
      angles: ClockTicks.small(),
      canvas: canvas,
      sizes: sizes,
      paint: linePaint,
      lineLength: 0.5,
    );

    final textRadius = sizes.clockRadius - 17;
    for (int hour = 0; hour < 24; hour += 2) {
      double drawAngle = (hour * ClockTicks.hourStep) - (math.pi / 2);

      _drawTextAtAngle(
        canvas: canvas,
        text: hour.toString(),
        center: sizes.center,
        radius: textRadius,
        angle: drawAngle,
      );
    }
  }

  void _drawPartOfClock({
    required List<num> angles,
    required Canvas canvas,
    required Sizes sizes,
    required Paint paint,
    required double lineLength,
  }) {
    for (var i = 0; i < angles.length; i++) {
      // Смещаем угол на -90 градусов (вверх)
      final double drawAngle = angles[i].toDouble() - (math.pi / 2);

      final double x1 =
          sizes.center.dx +
          (sizes.clockRadius - lineLength) * math.cos(drawAngle);
      final double y1 =
          sizes.center.dy +
          (sizes.clockRadius - lineLength) * math.sin(drawAngle);

      final double x2 =
          sizes.center.dx + sizes.clockRadius * math.cos(drawAngle);
      final double y2 =
          sizes.center.dy + sizes.clockRadius * math.sin(drawAngle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawTextAtAngle({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double radius,
    required double angle,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final double x = center.dx + radius * math.cos(angle);
    final double y = center.dy + radius * math.sin(angle);

    final offset = Offset(
      x - textPainter.width / 2,
      y - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }
}
