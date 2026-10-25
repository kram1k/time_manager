import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:time_manager/data/interval_repository.dart';
import 'package:time_manager/models/time_interval.dart';
import 'package:time_manager/theme/app_style.dart';
import 'package:time_manager/widgets/time_interval/screen.dart';
import 'package:time_manager/widgets/time_range_screen.dart';

class HomeShell extends StatefulWidget {
  final Map<String, ui.Picture> preloadedSVGs;
  final IntervalRepository repository;

  const HomeShell({
    super.key,
    required this.preloadedSVGs,
    required this.repository,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late List<TimeInterval> _intervals = widget.repository.getAll();
  static const _navMaxWidth = 460.0; // как _clockMaxSize на экране часов

  // Список обновляется сразу, запись в Hive идёт в фоне.
  bool _addInterval(TimeInterval interval) {
    if (widget.repository.contains(interval.start, interval.end)) return false;

    widget.repository.add(interval);
    setState(() => _intervals = widget.repository.getAll());
    return true;
  }

  void _removeInterval(TimeInterval interval) {
    widget.repository.remove(interval);
    setState(() => _intervals = widget.repository.getAll());
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
              intervals: _intervals,
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
