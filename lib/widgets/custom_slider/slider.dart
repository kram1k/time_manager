import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:time_manager/widgets/custom_slider/paints.dart';
import 'package:time_manager/widgets/custom_slider/sizes.dart';

enum DragMode { none, startEdge, endEdge, body }

class CustomSlider extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;

  const CustomSlider({super.key, required this.preloadedSVGs});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}


class _CustomSliderState extends State<CustomSlider> {
  double _startAngle = -math.pi / 2;
  double _sweepAngle = 3 * math.pi / 4;

  DragMode _dragMode = DragMode.none;
  double _lastAngle = 0.0;

  double _angleDelta(double from, double to) {
    double delta = to - from;
    while (delta > math.pi) delta -= 2 * math.pi;
    while (delta < -math.pi) delta += 2 * math.pi;
    return delta;
  }

  bool _isAngleInArc(double checkAngle, double start, double sweep) {
    double startNorm = start % (2 * math.pi);
    if (startNorm < 0) startNorm += 2 * math.pi;

    double checkNorm = checkAngle % (2 * math.pi);
    if (checkNorm < 0) checkNorm += 2 * math.pi;

    double endNorm = startNorm + sweep;

    if (endNorm <= 2 * math.pi) {
      return checkNorm >= startNorm && checkNorm <= endNorm;
    } else {
      return checkNorm >= startNorm || checkNorm <= (endNorm - 2 * math.pi);
    }
  }

  void _onPanDown(DragDownDetails details, Size widgetSize) {
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;

    final touchAngle = math.atan2(dy, dx);
    final touchRadius = math.sqrt(dx * dx + dy * dy);

    final sizes = Sizes(size: widgetSize);
    final expectedRadius = sizes.arcRadius / 2;

    if ((touchRadius - expectedRadius).abs() > 40) {
      _dragMode = DragMode.none;
      return;
    }

    final startAngleMod = _startAngle % (2 * math.pi);
    final endAngleMod = (_startAngle + _sweepAngle) % (2 * math.pi);

    final deltaStart = _angleDelta(startAngleMod, touchAngle).abs();
    final deltaEnd = _angleDelta(endAngleMod, touchAngle).abs();

    const hitTolerance = 0.3;

    if (deltaStart < hitTolerance) {
      _dragMode = DragMode.startEdge;
    } else if (deltaEnd < hitTolerance) {
      _dragMode = DragMode.endEdge;
    } else if (_isAngleInArc(touchAngle, _startAngle, _sweepAngle)) {
      _dragMode = DragMode.body;
    } else {
      _dragMode = DragMode.none;
    }

    _lastAngle = touchAngle;
  }

  void _onPanUpdate(DragUpdateDetails details, Size widgetSize) {
    if (_dragMode == DragMode.none) return;

    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final touchAngle = math.atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );

    double delta = _angleDelta(_lastAngle, touchAngle);

    setState(() {
      if (_dragMode == DragMode.body) {
        _startAngle += delta;
      } else if (_dragMode == DragMode.startEdge) {
        double newSweep = _sweepAngle - delta;
        double clampedSweep = newSweep.clamp(0.15, math.pi);
        double actualDelta = _sweepAngle - clampedSweep;
        _startAngle += actualDelta;
        _sweepAngle = clampedSweep;
      } else if (_dragMode == DragMode.endEdge) {
        double newSweep = _sweepAngle + delta;
        _sweepAngle = newSweep.clamp(0.15, math.pi);
      }

      _lastAngle = touchAngle;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _dragMode = DragMode.none;
  }

  @override
  Widget build(BuildContext context) {
    final Size sliderSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.width,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanDown: (details) => _onPanDown(details, sliderSize),
      onPanUpdate: (details) => _onPanUpdate(details, sliderSize),
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: sliderSize.width,
        height: sliderSize.height,
        child: CustomPaint(
          painter: SliderPainter(
            startAngle: _startAngle,
            sweepAngle: _sweepAngle,
            mapPicture: widget.preloadedSVGs,
          ),
        ),
      ),
    );
  }
}

class SliderPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Map<String, ui.Picture> mapPicture;

  SliderPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.mapPicture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Sizes sizes = Sizes(size: size);
    Paints paints = Paints(sizes: sizes);

    final double radius = sizes.arcRadius / 2;

    canvas.drawArc(
      Rect.fromCenter(
        center: sizes.center,
        width: sizes.arcRadius,
        height: sizes.arcRadius,
      ),
      startAngle,
      sweepAngle,
      false,
      paints.sliderArc,
    );

    final double tickStep = math.pi / 40;

    for (double currentSweep = tickStep; currentSweep < sweepAngle; currentSweep += tickStep) {
      final double angle = startAngle + currentSweep;
      final double tickLength = 10.0;

      final Offset outerPoint = Offset(
        sizes.center.dx + (radius + tickLength / 2) * math.cos(angle),
        sizes.center.dy + (radius + tickLength / 2) * math.sin(angle),
      );
      
      final Offset innerPoint = Offset(
        sizes.center.dx + (radius - tickLength / 2) * math.cos(angle),
        sizes.center.dy + (radius - tickLength / 2) * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, paints.sliderLine);
    }

    final Offset startPoint = Offset(
      sizes.center.dx + radius * math.cos(startAngle),
      sizes.center.dy + radius * math.sin(startAngle),
    );

    final Offset endPoint = Offset(
      sizes.center.dx + radius * math.cos(startAngle + sweepAngle),
      sizes.center.dy + radius * math.sin(startAngle + sweepAngle),
    );

    final double circleRadius = 12;
    canvas.drawCircle(startPoint, circleRadius, paints.offIcon);
    canvas.drawCircle(endPoint, circleRadius, paints.onIcon);

    void drawSvgIcon(String key, Offset position) {
      if (!mapPicture.containsKey(key)) return;

      canvas.saveLayer(
        Rect.fromCenter(
          center: position,
          width: circleRadius * 2,
          height: circleRadius * 2,
        ),
        paints.lockIcon,
      );

      canvas.translate(position.dx, position.dy);
      canvas.scale(0.60, 0.60);
      const double svgWidth = 24.0;
      const double svgHeight = 24.0;
      canvas.translate(-svgWidth / 2, -svgHeight / 2);

      canvas.drawPicture(mapPicture[key]!);
      canvas.restore();
    }

    drawSvgIcon('lock', startPoint);
    drawSvgIcon('lock_open', endPoint);
  }

  @override
  bool shouldRepaint(covariant SliderPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.mapPicture.length != mapPicture.length;
  }
}
