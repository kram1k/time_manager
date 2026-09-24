import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:time_manager/widgets/custom_slider/clock.dart';
import 'package:time_manager/widgets/time_range_screen.dart';

final Map<String, ui.Picture> preloadedSVGs = {};

Future<void> preloadAssets() async {
  final paths = {
    'moon': 'moon.svg',
    'sun': 'sun.svg',
    'lock': 'lock.svg',
    'lock_open': 'lock_open.svg',
  };

  for (final entry in paths.entries) {
    final loader = svg.SvgAssetLoader(entry.value);
    final svg.PictureInfo pictureInfo = await svg.vg.loadPicture(loader, null);
    preloadedSVGs[entry.key] = pictureInfo.picture;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await preloadAssets();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.grey.shade800),
      home: Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.center, // Центрируем оба слоя
            children: [
              TimeRangeScreen(preloadedSVGs: preloadedSVGs),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
