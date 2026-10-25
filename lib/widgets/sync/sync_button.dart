import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:time_manager/data/device_sync.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/sync/device_picker.dart';

// Отправляет все интервалы из базы на выбранное BLE-устройство.
class SyncButton extends StatefulWidget {
  final List<TimeInterval> intervals;

  // filled — квадратная кнопка в пару к «Add interval», иначе иконка в заголовке.
  final bool filled;

  const SyncButton({super.key, required this.intervals, this.filled = false});

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  bool _busy = false;

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _sync() async {
    if (!await FlutterBluePlus.isSupported) {
      _showMessage('Bluetooth is not supported on this device');
      return;
    }

    // Сразу после запуска состояние адаптера бывает unknown, ждём настоящее.
    final state = await FlutterBluePlus.adapterState
        .firstWhere((s) => s != BluetoothAdapterState.unknown)
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () => BluetoothAdapterState.unknown,
        );
    if (state != BluetoothAdapterState.on) {
      _showMessage('Turn on Bluetooth to sync');
      return;
    }

    if (!mounted) return;
    final device = await showDevicePicker(context);
    if (device == null) return;

    final intervals = widget.intervals;
    setState(() => _busy = true);
    try {
      await DeviceSync.send(device, intervals);
      _showMessage('Sent ${intervals.length} intervals');
    } catch (e) {
      _showMessage('Sync failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _busy
        ? const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppStyle.textColor,
            ),
          )
        : const Icon(Icons.bluetooth);

    if (!widget.filled) {
      return IconButton(
        onPressed: _busy ? null : _sync,
        tooltip: 'Sync with device',
        color: AppStyle.textColor,
        icon: icon,
      );
    }

    return IconButton.filled(
      onPressed: _busy ? null : _sync,
      tooltip: 'Sync with device',
      icon: icon,
      style: IconButton.styleFrom(
        backgroundColor: AppStyle.boxColor,
        foregroundColor: AppStyle.textColor,
        disabledBackgroundColor: AppStyle.boxColor,
        fixedSize: const Size.square(52), // высота AddIntervalButton
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
