import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/sync/sync_button.dart';
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
          child: Row(
            children: [
              const Expanded(child: Text('Intervals', style: AppStyle.font)),
              SyncButton(intervals: intervals),
            ],
          ),
        ),
        Expanded(
          child: IntervalList(intervals: intervals, onDelete: onDelete),
        ),
      ],
    );
  }
}
