import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_manager/widgets/angle_time.dart';
import 'package:time_manager/widgets/custom_slider/paints.dart';
import 'package:time_manager/widgets/custom_slider/sizes.dart';

enum DragMode { none, startEdge, endEdge, body }

class CustomSlider extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;
  final void Function(TimeOfDay start, TimeOfDay end)? onChanged;

  const CustomSlider({super.key, required this.preloadedSVGs, this.onChanged});

  @override
  State<CustomSlider> createState() => CustomSliderState();
}

class CustomSliderState extends State<CustomSlider> {
  static const _snapMinutes = 5; // шаг при перетаскивании
  static const _minSweepMinutes = 30;
  static const _maxSweepMinutes = 12 * 60;
  static const _minSweep = _minSweepMinutes * AngleTime.minuteAngle;
  static const _maxSweep = _maxSweepMinutes * AngleTime.minuteAngle;

  double _startAngle = -math.pi / 2;
  double _sweepAngle = 3 * math.pi / 4;

  DragMode _dragMode = DragMode.none;
  double _lastAngle = 0.0;

  // Положение пальца без привязки к шагу: копим его отдельно,
  // иначе мелкие сдвиги терялись бы при округлении.
  double _rawStart = 0.0;
  double _rawSweep = 0.0;

  int? _lastStartMin;
  int? _lastEndMin;

  @override
  void initState() {
    super.initState();
    // начальные значения отдаём после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  int get _startMinutes => AngleTime.angleToMinutes(_startAngle);
  int get _endMinutes => AngleTime.angleToMinutes(_startAngle + _sweepAngle);

  /// Ставит начало на [time]. Конец остаётся на месте, а если длительность
  /// выходит за пределы — весь интервал сдвигается.
  void setStart(TimeOfDay time) {
    final startMin = time.hour * 60 + time.minute;
    final sweepMin = (_endMinutes - startMin) % AngleTime.minutesInCircle;

    setState(() {
      _startAngle = AngleTime.minutesToAngle(startMin);
      if (_isSweepAllowed(sweepMin)) {
        _sweepAngle = sweepMin * AngleTime.minuteAngle;
      }
    });
    _notify();
  }

  /// Ставит конец на [time]. Начало остаётся на месте, а если длительность
  /// выходит за пределы — весь интервал сдвигается.
  void setEnd(TimeOfDay time) {
    final endMin = time.hour * 60 + time.minute;
    final startMin = _startMinutes;
    final currentSweepMin =
        (_endMinutes - startMin) % AngleTime.minutesInCircle;
    final sweepMin = (endMin - startMin) % AngleTime.minutesInCircle;

    setState(() {
      if (_isSweepAllowed(sweepMin)) {
        _sweepAngle = sweepMin * AngleTime.minuteAngle;
      } else {
        _startAngle = AngleTime.minutesToAngle(
          (endMin - currentSweepMin) % AngleTime.minutesInCircle,
        );
      }
    });
    _notify();
  }

  bool _isSweepAllowed(int minutes) =>
      minutes >= _minSweepMinutes && minutes <= _maxSweepMinutes;

  double _snap(double angle) => AngleTime.minutesToAngle(
    AngleTime.angleToMinutes(angle, snap: _snapMinutes),
  );

  void _notify() {
    if (widget.onChanged == null) return;

    final startMin = _startMinutes;
    final endMin = _endMinutes;

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

    // если ручки рядом, берём ближайшую к пальцу
    if (deltaStart < hitTolerance && deltaStart <= deltaEnd) {
      _dragMode = DragMode.startEdge;
    } else if (deltaEnd < hitTolerance) {
      _dragMode = DragMode.endEdge;
    } else if (_isAngleInArc(touchAngle, _startAngle, _sweepAngle)) {
      _dragMode = DragMode.body;
    } else {
      _dragMode = DragMode.none;
    }

    _lastAngle = touchAngle;
    _rawStart = _startAngle;
    _rawSweep = _sweepAngle;
  }

  void _onPanUpdate(DragUpdateDetails details, Size widgetSize) {
    if (_dragMode == DragMode.none) return;

    final center = Sizes(size: widgetSize).center; // было: середина виджета
    final touchAngle = math.atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );

    final delta = _angleDelta(_lastAngle, touchAngle);
    _lastAngle = touchAngle;

    final endAngle = _startAngle + _sweepAngle;
    double newStart = _startAngle;
    double newSweep = _sweepAngle;

    if (_dragMode == DragMode.body) {
      _rawStart += delta;
      newStart = _snap(_rawStart);
    } else if (_dragMode == DragMode.startEdge) {
      _rawSweep = (_rawSweep - delta).clamp(_minSweep, _maxSweep);
      newStart = _snap(endAngle - _rawSweep);
      newSweep = (endAngle - newStart) % (2 * math.pi);
    } else if (_dragMode == DragMode.endEdge) {
      _rawSweep = (_rawSweep + delta).clamp(_minSweep, _maxSweep);
      newSweep = (_snap(_startAngle + _rawSweep) - _startAngle) % (2 * math.pi);
    }

    // пока палец не дошёл до следующего шага, перерисовывать нечего
    final changed =
        AngleTime.angleToMinutes(newStart) != _startMinutes ||
        AngleTime.angleToMinutes(newStart + newSweep) != _endMinutes;
    if (!changed) return;

    setState(() {
      _startAngle = newStart;
      _sweepAngle = newSweep;
    });

    HapticFeedback.selectionClick();
    _notify(); // после setState, не внутри
  }

  void _onPanEnd(DragEndDetails details) {
    _dragMode = DragMode.none;
  }

  @override
  Widget build(BuildContext context) {
    final startLabel = AngleTime.format(AngleTime.angleToTime(_startAngle));
    final endLabel = AngleTime.format(
      AngleTime.angleToTime(_startAngle + _sweepAngle),
    );

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
          child: Semantics(
            label: 'Time range',
            value: '$startLabel – $endLabel',
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
    // обводка отделяет ручки от дуги
    canvas.drawCircle(startPoint, circleRadius, paints.sliderLine);
    canvas.drawCircle(endPoint, circleRadius, paints.sliderLine);

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
