import 'package:flutter/material.dart';
import 'package:time_manager/theme/app_style.dart';

class AddIntervalButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddIntervalButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Add interval'),
      style: FilledButton.styleFrom(
        backgroundColor: AppStyle.boxColor,
        foregroundColor: AppStyle.textColor,
        disabledBackgroundColor: AppStyle.boxColor.withValues(alpha: 0.5),
        disabledForegroundColor: AppStyle.textColor.withValues(alpha: 0.4),
        textStyle: AppStyle.font,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
