import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/angle_time.dart';
import 'package:time_manager/widgets/custom_slider/clock.dart';
import 'package:time_manager/widgets/custom_slider/slider.dart';
import 'package:time_manager/widgets/sync/sync_button.dart';
import 'package:time_manager/widgets/time_interval/add_button.dart';

class TimeRangeScreen extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;

  final bool Function(TimeInterval interval) onAdd;

  // Нужны только кнопке синхронизации.
  final List<TimeInterval> intervals;

  const TimeRangeScreen({
    super.key,
    required this.preloadedSVGs,
    required this.onAdd,
    required this.intervals,
  });

  @override
  State<TimeRangeScreen> createState() => _TimeRangeScreenState();
}

class _TimeRangeScreenState extends State<TimeRangeScreen> {
  final _start = ValueNotifier<TimeOfDay?>(null);
  final _end = ValueNotifier<TimeOfDay?>(null);
  final _sliderKey = GlobalKey<CustomSliderState>();

  static const _clockMaxSize = 460.0; // максимальный диаметр часов

  bool get _canAdd =>
      _start.value != null && _end.value != null && _start.value != _end.value;

  void _addInterval() {
    final added = widget.onAdd(
      TimeInterval(
        start: AngleTime.format(_start.value!),
        end: AngleTime.format(_end.value!),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added ? 'Interval added' : 'This interval already exists',
          ),
        ),
      );
  }

  Future<void> _pickTime({
    required ValueNotifier<TimeOfDay?> time,
    required String title,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final initial = time.value ?? TimeOfDay.now();
    var selected = initial;

    // Барабан, как в будильнике iOS: выезжает снизу, подтверждается кнопкой.
    final picked = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) => Material(
        color: AppStyle.boxColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: AppStyle.font),
                  ),
                  Text(title, style: AppStyle.font),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context, selected),
                    child: Text(
                      'Done',
                      style: AppStyle.font.copyWith(
                        color: AppStyle.selectedColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 216,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: AppStyle.font.copyWith(
                        fontSize: 22,
                        color: AppStyle.selectedColor,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true, // приложение везде в 24-часовом формате
                    initialDateTime: DateTime(
                      2000,
                      1,
                      1,
                      initial.hour,
                      initial.minute,
                    ),
                    onDateTimeChanged: (value) =>
                        selected = TimeOfDay.fromDateTime(value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Widget _timeBox({
    required ValueNotifier<TimeOfDay?> time,
    required Color color,
    required IconData icon,
    required String label,
    required ValueChanged<TimeOfDay> onPicked,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            _pickTime(time: time, title: '$label time', onPicked: onPicked),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppStyle.innerBoxColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                // та же иконка, что на ручке слайдера: цвет не единственный признак
                Icon(icon, size: 18, color: color, semanticLabel: label),
                const SizedBox(width: 8),
                ValueListenableBuilder(
                  valueListenable: time,
                  builder: (context, value, _) => Text(
                    value == null ? '' : AngleTime.format(value),
                    style: AppStyle.font,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
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
              Expanded(
                child: _timeBox(
                  time: _start,
                  color: AppStyle.startColor,
                  icon: Icons.lock,
                  label: 'Start',
                  onPicked: (t) => _sliderKey.currentState?.setStart(t),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _timeBox(
                  time: _end,
                  color: AppStyle.endColor,
                  icon: Icons.lock_open,
                  label: 'End',
                  onPicked: (t) => _sliderKey.currentState?.setEnd(t),
                ),
              ),
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
                      key: _sliderKey,
                      preloadedSVGs: widget.preloadedSVGs,
                      onChanged: (start, end) {
                        _start.value = start;
                        _end.value = end;
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
          child: Row(
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([_start, _end]),
                  builder: (context, _) => AddIntervalButton(
                    onPressed: _canAdd ? _addInterval : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SyncButton(intervals: widget.intervals, filled: true),
            ],
          ),
        ),
      ],
    );
  }
}
