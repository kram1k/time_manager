import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';

class IntervalTile extends StatelessWidget {
  final TimeInterval interval;
  final VoidCallback onDelete;

  const IntervalTile({
    super.key,
    required this.interval,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppStyle.boxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppStyle.innerBoxColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${interval.start} – ${interval.end}',
                        style: AppStyle.font,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(interval.durationLabel, style: AppStyle.smallFont),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8), // отступ перед кнопкой удаления
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: AppStyle.textColor,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
