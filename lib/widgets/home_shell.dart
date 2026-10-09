import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/time_interval/screen.dart';
import 'package:time_manager/widgets/time_range_screen.dart';

class HomeShell extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;

  const HomeShell({super.key, required this.preloadedSVGs});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _intervals = <TimeInterval>[];
  static const _navMaxWidth = 460.0; // как _clockMaxSize на экране часов

  bool _addInterval(TimeInterval interval) {
    final exists = _intervals.any(
      (i) => i.start == interval.start && i.end == interval.end,
    );
    if (exists) return false;

    setState(() {
      _intervals.add(interval);
      _intervals.sort((a, b) => a.start.compareTo(b.start));
    });
    return true;
  }

  void _removeInterval(TimeInterval interval) {
    setState(() => _intervals.remove(interval));
  }

  // Счётчик на вкладке показывает, куда попал добавленный интервал.
  Widget _intervalsIcon(IconData icon) {
    return Badge.count(
      count: _intervals.length,
      isLabelVisible: _intervals.isNotEmpty,
      backgroundColor: AppStyle.textColor,
      textColor: AppStyle.boxColor,
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            TimeRangeScreen(
              preloadedSVGs: widget.preloadedSVGs,
              onAdd: _addInterval,
            ),
            IntervalsScreen(intervals: _intervals, onDelete: _removeInterval),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Center(
            heightFactor: 1, // без этого Center растянется на всю высоту экрана
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _navMaxWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor: AppStyle.boxColor,
                    indicatorColor: AppStyle.accentBoxColor,
                    labelTextStyle: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppStyle.smallFont.copyWith(
                              color: AppStyle.selectedColor,
                              fontWeight: FontWeight.w500,
                            )
                          : AppStyle.smallFont,
                    ),
                    iconTheme: WidgetStateProperty.resolveWith(
                      (states) => IconThemeData(
                        color: states.contains(WidgetState.selected)
                            ? AppStyle.selectedColor
                            : AppStyle.textColor,
                      ),
                    ),
                  ),
                  child: NavigationBar(
                    height: 64,
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: [
                      const NavigationDestination(
                        icon: Icon(Icons.schedule_outlined),
                        selectedIcon: Icon(Icons.schedule),
                        label: 'Clock',
                      ),
                      NavigationDestination(
                        icon: _intervalsIcon(Icons.list_alt_outlined),
                        selectedIcon: _intervalsIcon(Icons.list_alt),
                        label: 'Intervals',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
