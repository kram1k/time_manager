import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:time_manager/widgets/angle_time.dart';
import 'package:time_manager/widgets/custom_slider/clock.dart';
import 'package:time_manager/widgets/custom_slider/slider.dart';

class TimeRangeScreen extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;
  const TimeRangeScreen({super.key, required this.preloadedSVGs});

  @override
  State<TimeRangeScreen> createState() => _TimeRangeScreenState();
}

class _TimeRangeScreenState extends State<TimeRangeScreen> {
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  static const _boxColor = Colors.black;
  static const _clockMaxSize = 460.0;

  static const _innerBoxColor = Color(0xFF212121);
  static const _textColor = Color(0xFFADADAD);
  static const _font = TextStyle(
    fontFamily: 'Rubik',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: _textColor,
  );

  Widget _timeBox(TextEditingController controller, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _boxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(label, style: _font),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _innerBoxColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextField(
              controller: controller,
              readOnly: true,
              style: _font,
              decoration: const InputDecoration.collapsed(hintText: null),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _timeBox(_startCtrl, 'Start')),
              const SizedBox(width: 16),
              Expanded(child: _timeBox(_endCtrl, 'End')),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.min(
                _clockMaxSize,
                math.min(constraints.maxWidth, constraints.maxHeight),
              );
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: side,
                  height: side,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomClock(preloadedSVGs: widget.preloadedSVGs),
                      CustomSlider(
                        preloadedSVGs: widget.preloadedSVGs,
                        onChanged: (start, end) {
                          _startCtrl.text = AngleTime.format(start);
                          _endCtrl.text = AngleTime.format(end);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
