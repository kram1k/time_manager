import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/angle_time.dart';
import 'package:time_manager/widgets/custom_slider/clock.dart';
import 'package:time_manager/widgets/custom_slider/slider.dart';
import 'package:time_manager/widgets/time_interval/list.dart';
import 'package:time_manager/widgets/time_interval/add_button.dart' show AddIntervalButton;

class TimeRangeScreen extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;
  const TimeRangeScreen({super.key, required this.preloadedSVGs});

  @override
  State<TimeRangeScreen> createState() => _TimeRangeScreenState();
}

class _TimeRangeScreenState extends State<TimeRangeScreen> {
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _intervals = <TimeInterval>[];

  static const _clockMaxSize = 460.0; // максимальный диаметр часов

  bool get _canAdd =>
      _startCtrl.text.isNotEmpty &&
      _endCtrl.text.isNotEmpty &&
      _startCtrl.text != _endCtrl.text;

  void _addInterval() {
    final interval = TimeInterval(start: _startCtrl.text, end: _endCtrl.text);
    final exists = _intervals.any(
      (i) => i.start == interval.start && i.end == interval.end,
    );
    if (exists) return;

    setState(() {
      _intervals.add(interval);
      _intervals.sort((a, b) => a.start.compareTo(b.start)); // "HH:MM" сортируется как строка
    });
  }

  void _removeInterval(TimeInterval interval) {
    setState(() => _intervals.remove(interval));
  }

  Widget _timeBox(TextEditingController controller, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppStyle.boxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(label, style: AppStyle.font),
          ),
          Container(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(
          _clockMaxSize,
          math.min(constraints.maxWidth, constraints.maxHeight * 0.5),
        );

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
            SizedBox(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              // Перестраивается только кнопка, когда меняется время в полях.
              child: ListenableBuilder(
                listenable: Listenable.merge([_startCtrl, _endCtrl]),
                builder: (context, _) => AddIntervalButton(
                  onPressed: _canAdd ? _addInterval : null,
                ),
              ),
            ),
            Expanded(
              child: IntervalList(
                intervals: _intervals,
                onDelete: _removeInterval,
              ),
            ),
          ],
        );
      },
    );
  }
}
