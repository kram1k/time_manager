import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/time_interval/list.dart';

class IntervalsScreen extends StatelessWidget {
  final List<TimeInterval> intervals;
  final ValueChanged<TimeInterval> onDelete;

  const IntervalsScreen({
    super.key,
    required this.intervals,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Intervals', style: AppStyle.font),
        ),
        Expanded(
          child: IntervalList(intervals: intervals, onDelete: onDelete),
        ),
      ],
    );
  }
}
