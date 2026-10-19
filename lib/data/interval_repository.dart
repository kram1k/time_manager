import 'package:hive_ce/hive_ce.dart';
import 'package:time_manager/data/time_interval_adapter.dart';
import 'package:time_manager/models/time_interval.dart';

class IntervalRepository {
  static const _boxName = 'intervals';

  final Box<TimeInterval> _box;

  IntervalRepository._(this._box);

  // Hive должен быть инициализирован заранее (Hive.initFlutter или Hive.init).
  static Future<IntervalRepository> open() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TimeIntervalAdapter());
    }
    return IntervalRepository._(await Hive.openBox<TimeInterval>(_boxName));
  }

  List<TimeInterval> getAll() {
    return _box.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  bool contains(String start, String end) {
    return _box.values.any((i) => i.start == start && i.end == end);
  }

  // Ключ строковый: id в микросекундах не влезает в целочисленный ключ Hive (до 2^32).
  Future<void> add(TimeInterval interval) => _box.put('${interval.id}', interval);

  Future<void> remove(TimeInterval interval) => _box.delete('${interval.id}');
}
