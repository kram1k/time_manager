import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:time_manager/widgets/angle_time.dart';
import 'package:time_manager/widgets/custom_slider/paints.dart';
import 'package:time_manager/widgets/custom_slider/sizes.dart';

enum DragMode { none, startEdge, endEdge, body }

class CustomSlider extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;
  final void Function(TimeOfDay start, TimeOfDay end)? onChanged;

  const CustomSlider({super.key, required this.preloadedSVGs, this.onChanged});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _startAngle = -math.pi / 2;
  double _sweepAngle = 3 * math.pi / 4;

  DragMode _dragMode = DragMode.none;
  double _lastAngle = 0.0;

  int? _lastStartMin;
  int? _lastEndMin;

  @override
  void initState() {
    super.initState();
    // начальные значения отдаём после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  void _notify() {
    if (widget.onChanged == null) return;

    final startMin = AngleTime.angleToMinutes(_startAngle);
    final endMin = AngleTime.angleToMinutes(_startAngle + _sweepAngle);

    // не дёргаем колбэк, если минуты не поменялись
    if (startMin == _lastStartMin && endMin == _lastEndMin) return;
    _lastStartMin = startMin;
    _lastEndMin = endMin;

    widget.onChanged!(
      TimeOfDay(hour: startMin ~/ 60, minute: startMin % 60),
      TimeOfDay(hour: endMin ~/ 60, minute: endMin % 60),
    );
  }

  double _angleDelta(double from, double to) {
    double delta = to - from;
    while (delta > math.pi) {
      delta -= 2 * math.pi;
    }
    while (delta < -math.pi) {
      delta += 2 * math.pi;
    }
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
    final sizes = Sizes(size: widgetSize);
    final center = sizes.center;
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;

    final touchAngle = math.atan2(dy, dx);
    final touchRadius = math.sqrt(dx * dx + dy * dy);
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

    final center = Sizes(size: widgetSize).center; // было: середина виджета
    final touchAngle = math.atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );

    // дальше без изменений

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

    _notify(); // после setState, не внутри
  }

  void _onPanEnd(DragEndDetails details) {
    _dragMode = DragMode.none;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenWidth;
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : maxW;
        final side = math.min(maxW, maxH);
        final sliderSize = Size(side, side);

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
      },
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

    for (
      double currentSweep = tickStep;
      currentSweep < sweepAngle;
      currentSweep += tickStep
    ) {
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
