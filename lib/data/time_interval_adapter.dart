import 'package:hive_ce/hive_ce.dart';
import 'package:time_manager/models/time_interval.dart';

// Адаптер написан вручную, чтобы не тянуть build_runner ради одной модели.
// Порядок полей менять нельзя: от него зависит чтение уже сохранённых данных.
class TimeIntervalAdapter extends TypeAdapter<TimeInterval> {
  @override
  final int typeId = 0;

  @override
  TimeInterval read(BinaryReader reader) {
    return TimeInterval(
      id: reader.readInt(),
      start: reader.readString(),
      end: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TimeInterval obj) {
    writer
      ..writeInt(obj.id)
      ..writeString(obj.start)
      ..writeString(obj.end);
  }
}
