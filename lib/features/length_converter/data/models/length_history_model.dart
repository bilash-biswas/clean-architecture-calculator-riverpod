import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class LengthHistoryModel extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String fromUnit;

  @HiveField(2)
  late String toUnit;

  @HiveField(3)
  late double fromValue;

  @HiveField(4)
  late double toValue;

  @HiveField(5)
  late DateTime timestamp;

  LengthHistoryModel();

  factory LengthHistoryModel.fromValues({
    required int id,
    required String fromUnit,
    required String toUnit,
    required double fromValue,
    required double toValue,
    required DateTime timestamp,
  }) {
    return LengthHistoryModel()
      ..id = id
      ..fromUnit = fromUnit
      ..toUnit = toUnit
      ..fromValue = fromValue
      ..toValue = toValue
      ..timestamp = timestamp;
  }
}

class LengthHistoryModelAdapter extends TypeAdapter<LengthHistoryModel> {
  @override
  final int typeId = 3;

  @override
  LengthHistoryModel read(BinaryReader reader) {
    return LengthHistoryModel()
      ..id = reader.readInt()
      ..fromUnit = reader.readString()
      ..toUnit = reader.readString()
      ..fromValue = reader.readDouble()
      ..toValue = reader.readDouble()
      ..timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  void write(BinaryWriter writer, LengthHistoryModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.fromUnit);
    writer.writeString(obj.toUnit);
    writer.writeDouble(obj.fromValue);
    writer.writeDouble(obj.toValue);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
