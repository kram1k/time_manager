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
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return Center(
                child: SizedBox(
                  width: side,
                  height: side,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomClock(preloadedSVGs: widget.preloadedSVGs),
                      CustomSlider(
                        // сверху, чтобы ловить жесты
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Начало'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _endCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Конец'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
