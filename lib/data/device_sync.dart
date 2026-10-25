import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:time_manager/models/time_interval.dart';

class DeviceSyncException implements Exception {
  final String message;

  const DeviceSyncException(this.message);

  @override
  String toString() => message;
}

// Протокол: JSON-массив [{"start":"08:00","end":"09:30"}, ...] и '\n' в конце.
// Если не влезает в один пакет, уходит кусками по MTU: устройство копит байты до '\n'.
abstract final class DeviceSync {
  // Суффикс стандартных сервисов Bluetooth SIG (Generic Access, Battery и т.п.).
  static const _sigBaseSuffix = '-0000-1000-8000-00805f9b34fb';

  static Future<void> send(
    BluetoothDevice device,
    List<TimeInterval> intervals,
  ) async {
    final payload = utf8.encode('${jsonEncode(intervals)}\n');

    await device.connect(license: License.nonprofit);
    try {
      final target = _findWritable(await device.discoverServices());
      if (target == null) {
        throw const DeviceSyncException(
          'Device has no writable characteristic',
        );
      }

      final withoutResponse = !target.properties.write;
      final chunkSize = device.mtuNow - 3; // 3 байта — заголовок ATT
      for (var i = 0; i < payload.length; i += chunkSize) {
        await target.write(
          payload.sublist(i, math.min(i + chunkSize, payload.length)),
          withoutResponse: withoutResponse,
        );
      }
    } finally {
      await device.disconnect();
    }
  }

  // UUID прошивки неизвестен, поэтому берём первую записываемую характеристику
  // в нестандартном сервисе.
  static BluetoothCharacteristic? _findWritable(
    List<BluetoothService> services,
  ) {
    for (final service in services) {
      if (service.uuid.str128.endsWith(_sigBaseSuffix)) continue;
      for (final c in service.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) return c;
      }
    }
    return null;
  }
}
