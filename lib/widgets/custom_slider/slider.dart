/* AI SLOP !!!!! */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:time_manager/widgets/custom_slider/paints.dart';
import 'package:time_manager/widgets/custom_slider/sizes.dart';

// Возможные состояния того, за что мы сейчас тянем
enum DragMode { none, startEdge, endEdge, body }

class CustomSlider extends StatefulWidget {
  const CustomSlider({super.key});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  // Теперь у дуги меняется и точка старта, и длина
  double _startAngle = -math.pi / 2;
  double _sweepAngle = 3 * math.pi / 4;

  DragMode _dragMode = DragMode.none;
  double _lastAngle = 0.0;

  // Функция для нахождения кратчайшего расстояния между двумя углами
  double _angleDelta(double from, double to) {
    double delta = to - from;
    while (delta > math.pi) delta -= 2 * math.pi;
    while (delta < -math.pi) delta += 2 * math.pi;
    return delta;
  }

  // Проверка: находится ли угол касания внутри тела нашей дуги
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

  // Срабатывает в момент ПЕРВОГО касания экрана
  void _onPanDown(DragDownDetails details, Size widgetSize) {
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;

    final touchAngle = math.atan2(dy, dx);
    // Находим радиус касания, чтобы убедиться, что мы попали именно по кольцу, а не в центр часов
    final touchRadius = math.sqrt(dx * dx + dy * dy);

    // Получаем радиус кольца (предполагаем, что arcRadius - это ширина квадрата, значит настоящий радиус / 2)
    final sizes = Sizes(size: widgetSize);
    final expectedRadius = sizes.arcRadius / 2;

    // Если коснулись слишком далеко от кольца (погрешность 40 пикселей) - игнорируем
    if ((touchRadius - expectedRadius).abs() > 40) {
      _dragMode = DragMode.none;
      return;
    }

    // Вычисляем углы краев
    final startAngleMod = _startAngle % (2 * math.pi);
    final endAngleMod = (_startAngle + _sweepAngle) % (2 * math.pi);

    // Насколько близко палец к краям
    final deltaStart = _angleDelta(startAngleMod, touchAngle).abs();
    final deltaEnd = _angleDelta(endAngleMod, touchAngle).abs();

    // Зона захвата краев в радианах (0.3 радиана ≈ 17 градусов)
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

  // Срабатывает при движении пальца
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
        // Двигаем дугу целиком
        _startAngle += delta;
      } 
      else if (_dragMode == DragMode.startEdge) {
        // Вычисляем новую длину
        double newSweep = _sweepAngle - delta;
        
        // Ограничиваем длину: 
        // 0.15 - защита от выворачивания наизнанку
        // math.pi - максимум 12 часов (половина круга)
        double clampedSweep = newSweep.clamp(0.15, math.pi);
        
        // Смещаем старт только на ту разницу, которую разрешил clamp
        double actualDelta = _sweepAngle - clampedSweep;
        _startAngle += actualDelta;
        _sweepAngle = clampedSweep;
      } 
      else if (_dragMode == DragMode.endEdge) {
        // Вычисляем новую длину и сразу применяем лимит
        double newSweep = _sweepAngle + delta;
        _sweepAngle = newSweep.clamp(0.15, math.pi);
      }
      
      _lastAngle = touchAngle;
    });
  }


  // Когда отпускаем палец - сбрасываем режим
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
          ),
        ),
      ),
    );
  }
}

class SliderPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;

  SliderPainter({required this.startAngle, required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    Sizes sizes = Sizes(size: size);
    Paints paints = Paints(sizes: sizes);

    canvas.drawArc(
      Rect.fromCenter(
        center: sizes.center,
        width: sizes.arcRadius,
        height: sizes.arcRadius,
      ),
      startAngle, // <-- ТЕПЕРЬ СТАРТ ДИНАМИЧЕСКИЙ
      sweepAngle,
      false,
      paints.sliderArc,
    );
  }

  @override
  bool shouldRepaint(covariant SliderPainter oldDelegate) {
    // Перерисовываем, если изменился старт или длина
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle;
  }
}
