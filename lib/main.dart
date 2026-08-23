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
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue.shade400),
      home: Scaffold(
          body: Center(
            child: CustomSlider(),
          ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.shield_moon), label: "Mood"),
            NavigationDestination(
              icon: Icon(Icons.sunny),
              label: "Sunny",
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
