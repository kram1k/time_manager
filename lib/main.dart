import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:time_manager/data/interval_repository.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/home_shell.dart';

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

  await Hive.initFlutter();
  final repository = await IntervalRepository.open();

  runApp(MainApp(repository: repository));
}

class MainApp extends StatelessWidget {
  final IntervalRepository repository;

  const MainApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade800,
        fontFamily: 'Rubik',
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppStyle.boxColor,
          contentTextStyle: AppStyle.smallFont,
        ),
      ),
      home: HomeShell(preloadedSVGs: preloadedSVGs, repository: repository),
      debugShowCheckedModeBanner: false,
    );
  }
}
