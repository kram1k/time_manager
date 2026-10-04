import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/time_interval/tile.dart';

class IntervalList extends StatelessWidget {
  final List<TimeInterval> intervals;
  final ValueChanged<TimeInterval> onDelete;

  const IntervalList({
    super.key,
    required this.intervals,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (intervals.isEmpty) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No intervals yet', style: AppStyle.smallFont),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: intervals.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final interval = intervals[index];
        return IntervalTile(
          key: ValueKey(interval.id),
          interval: interval,
          onDelete: () => onDelete(interval),
        );
      },
    );
  }
}
