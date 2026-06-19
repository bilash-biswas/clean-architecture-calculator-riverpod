import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class WeightHistoryModel extends HiveObject {
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

  WeightHistoryModel();

  factory WeightHistoryModel.fromValues({
    required int id,
    required String fromUnit,
    required String toUnit,
    required double fromValue,
    required double toValue,
    required DateTime timestamp,
  }) {
    return WeightHistoryModel()
      ..id = id
      ..fromUnit = fromUnit
      ..toUnit = toUnit
      ..fromValue = fromValue
      ..toValue = toValue
      ..timestamp = timestamp;
  }
}

class WeightHistoryModelAdapter extends TypeAdapter<WeightHistoryModel> {
  @override
  final int typeId = 4;

  @override
  WeightHistoryModel read(BinaryReader reader) {
    return WeightHistoryModel()
      ..id = reader.readInt()
      ..fromUnit = reader.readString()
      ..toUnit = reader.readString()
      ..fromValue = reader.readDouble()
      ..toValue = reader.readDouble()
      ..timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  void write(BinaryWriter writer, WeightHistoryModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.fromUnit);
    writer.writeString(obj.toUnit);
    writer.writeDouble(obj.fromValue);
    writer.writeDouble(obj.toValue);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
