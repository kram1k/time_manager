/* !!!! AI SLOP !!!!! */

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:time_manager/widgets/custom_slider/paints.dart';
import 'package:time_manager/widgets/custom_slider/sizes.dart';

// Возможные состояния того, за что мы сейчас тянем
enum DragMode { none, startEdge, endEdge, body }

class CustomSlider extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;

  const CustomSlider({super.key, required this.preloadedSVGs});

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
      } else if (_dragMode == DragMode.startEdge) {
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
      } else if (_dragMode == DragMode.endEdge) {
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
            mapPicture: widget.preloadedSVGs, // <-- ПЕРЕДАТЬ КАРТИНКИ СЮДА
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

    // Радиус орбиты = половина ширины arcRadius
    final double radius = sizes.arcRadius / 2;

    // 1. Отрисовка самой дуги слайдера
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

    // --- 2. Отрисовка рисочек ПОВЕРХ дуги слайдера ---
    // Шаг между рисочками (например, каждые 15 градусов = math.pi / 12)
    // Если полкруга (math.pi) это 12 часов, то math.pi / 12 = 1 час.
    final double tickStep = math.pi / 40; 

    // Идем циклом от начала дуги до её конца с заданным шагом.
    // Начинаем с tickStep, чтобы не рисовать черточку прямо под начальным кружком.
    for (double currentSweep = tickStep; currentSweep < sweepAngle; currentSweep += tickStep) {
      final double angle = startAngle + currentSweep;
      final double tickLength = 10.0; // Длина рисочки

      // Располагаем черточку поперек дуги (центрируем по радиусу)
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
    // ---------------------------------------------------

    // 3. Вычисляем координаты краев дуги
    // Точка начала (зеленый круг)
    final Offset startPoint = Offset(
      sizes.center.dx + radius * math.cos(startAngle),
      sizes.center.dy + radius * math.sin(startAngle),
    );

    // Точка конца (красный круг)
    final Offset endPoint = Offset(
      sizes.center.dx + radius * math.cos(startAngle + sweepAngle),
      sizes.center.dy + radius * math.sin(startAngle + sweepAngle),
    );

    // 4. Рисуем круги-ручки
    final double circleRadius = 12; 
    canvas.drawCircle(startPoint, circleRadius, Paint()..color = Colors.green.shade400);
    canvas.drawCircle(endPoint, circleRadius, Paint()..color = Colors.red.shade400);

    // 5. Логика отрисовки полупрозрачных SVG
    void drawSvgIcon(String key, Offset position) {
      if (!mapPicture.containsKey(key)) return;

      canvas.saveLayer(
        Rect.fromCenter(
          center: position,
          width: circleRadius * 2,
          height: circleRadius * 2,
        ),
        Paint()..color = Colors.black,
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
