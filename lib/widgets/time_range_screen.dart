import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/angle_time.dart';
import 'package:time_manager/widgets/custom_slider/clock.dart';
import 'package:time_manager/widgets/custom_slider/slider.dart';
import 'package:time_manager/widgets/time_interval/add_button.dart';

class TimeRangeScreen extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;

  final bool Function(TimeInterval interval) onAdd;

  const TimeRangeScreen({
    super.key,
    required this.preloadedSVGs,
    required this.onAdd,
  });

  @override
  State<TimeRangeScreen> createState() => _TimeRangeScreenState();
}

class _TimeRangeScreenState extends State<TimeRangeScreen> {
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  static const _clockMaxSize = 460.0; // максимальный диаметр часов

  bool get _canAdd =>
      _startCtrl.text.isNotEmpty &&
      _endCtrl.text.isNotEmpty &&
      _startCtrl.text != _endCtrl.text;

  void _addInterval() {
    widget.onAdd(TimeInterval(start: _startCtrl.text, end: _endCtrl.text));
  }

  Widget _timeBox(TextEditingController controller, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppStyle.innerBoxColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextField(
          controller: controller,
          readOnly: true,
          style: AppStyle.font,
          decoration: const InputDecoration.collapsed(hintText: null),
        ),
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
              Expanded(child: _timeBox(_startCtrl, AppStyle.startColor)),
              const SizedBox(width: 16),
              Expanded(child: _timeBox(_endCtrl, AppStyle.endColor)),
            ],
          ),
        ),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.min(
                _clockMaxSize,
                math.min(constraints.maxWidth, constraints.maxHeight),
              );
              return SizedBox(
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
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          // Перестраивается только кнопка, когда меняется время в полях.
          child: ListenableBuilder(
            listenable: Listenable.merge([_startCtrl, _endCtrl]),
            builder: (context, _) =>
                AddIntervalButton(onPressed: _canAdd ? _addInterval : null),
          ),
        ),
      ],
    );
  }
}
