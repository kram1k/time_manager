import 'package:flutter/material.dart';

import 'widgets/custom_slider/slider.dart';

void main() {
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
            child: CustomSlider(),
          ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
