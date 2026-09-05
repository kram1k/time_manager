import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:time_manager/widgets/custom_slider/paints.dart';
import 'package:time_manager/widgets/custom_slider/sizes.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider({super.key});
  
  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _sweepAngle = 3 * math.pi / 4;

  void _onPanUpdate(DragUpdateDetails details, Size widgetSize) {
    final Offset center = Offset(widgetSize.width / 2, widgetSize.height / 2);

    double angle = math.atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );

    double newSweep = angle - (-math.pi / 2);
    newSweep = newSweep % (2 * math.pi);
    if (newSweep < 0) {
      newSweep += 2 * math.pi;
    }

    setState(() {
      _sweepAngle = newSweep;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size sliderSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.width,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) => _onPanUpdate(details, sliderSize),
      child: SizedBox(
        width: sliderSize.width,
        height: sliderSize.height,
        child: CustomPaint(
          painter: SliderPainter(sweepAngle: _sweepAngle),
        ),
      ),
    );
  }
}

class SliderPainter extends CustomPainter {
  final double sweepAngle;

  SliderPainter({required this.sweepAngle});

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
      -math.pi / 2,
      sweepAngle,
      false,
      paints.sliderArc,
    );
  }

  @override
  bool shouldRepaint(covariant SliderPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle;
  }
}
