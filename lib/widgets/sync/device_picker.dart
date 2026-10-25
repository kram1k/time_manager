import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:time_manager/theme/app_style.dart';

Future<BluetoothDevice?> showDevicePicker(BuildContext context) {
  return showModalBottomSheet<BluetoothDevice>(
    context: context,
    backgroundColor: AppStyle.boxColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (_) => const _DevicePicker(),
  );
}

class _DevicePicker extends StatefulWidget {
  const _DevicePicker();

  @override
  State<_DevicePicker> createState() => _DevicePickerState();
}

class _DevicePickerState extends State<_DevicePicker> {
  static const _scanTimeout = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    try {
      await FlutterBluePlus.startScan(timeout: _scanTimeout);
    } catch (_) {
      // Ошибку покажет пустой список: вне этого листа её некуда вывести.
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  String _name(ScanResult r) {
    final name = r.advertisementData.advName;
    if (name.isNotEmpty) return name;
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    return r.device.remoteId.str;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Choose device', style: AppStyle.font),
                ),
                StreamBuilder<bool>(
                  stream: FlutterBluePlus.isScanning,
                  initialData: FlutterBluePlus.isScanningNow,
                  builder: (context, snapshot) => snapshot.data!
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppStyle.textColor,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _scan,
                          tooltip: 'Scan again',
                          color: AppStyle.textColor,
                          icon: const Icon(Icons.refresh),
                        ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.onScanResults,
              initialData: const [],
              builder: (context, snapshot) {
                final results = snapshot.data!;
                if (results.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Searching for devices…',
                      style: AppStyle.smallFont,
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return Material(
                      color: AppStyle.innerBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: const Icon(
                          Icons.bluetooth,
                          color: AppStyle.textColor,
                        ),
                        title: Text(_name(r), style: AppStyle.font),
                        trailing: Text(
                          '${r.rssi} dBm',
                          style: AppStyle.smallFont,
                        ),
                        onTap: () => Navigator.pop(context, r.device),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
