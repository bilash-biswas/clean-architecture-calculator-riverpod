import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class BmiHistoryModel extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late double weight;

  @HiveField(2)
  late double height;

  @HiveField(3)
  late double bmi;

  @HiveField(4)
  late String category;

  @HiveField(5)
  late String gender;

  @HiveField(6)
  late int age;

  @HiveField(7)
  late String unitSystem;

  @HiveField(8)
  late DateTime timestamp;

  BmiHistoryModel();

  factory BmiHistoryModel.fromValues({
    required int id,
    required double weight,
    required double height,
    required double bmi,
    required String category,
    required String gender,
    required int age,
    required String unitSystem,
    required DateTime timestamp,
  }) {
    return BmiHistoryModel()
      ..id = id
      ..weight = weight
      ..height = height
      ..bmi = bmi
      ..category = category
      ..gender = gender
      ..age = age
      ..unitSystem = unitSystem
      ..timestamp = timestamp;
  }
}

class BmiHistoryModelAdapter extends TypeAdapter<BmiHistoryModel> {
  @override
  final int typeId = 2;

  @override
  BmiHistoryModel read(BinaryReader reader) {
    return BmiHistoryModel()
      ..id = reader.readInt()
      ..weight = reader.readDouble()
      ..height = reader.readDouble()
      ..bmi = reader.readDouble()
      ..category = reader.readString()
      ..gender = reader.readString()
      ..age = reader.readInt()
      ..unitSystem = reader.readString()
      ..timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  void write(BinaryWriter writer, BmiHistoryModel obj) {
    writer.writeInt(obj.id);
    writer.writeDouble(obj.weight);
    writer.writeDouble(obj.height);
    writer.writeDouble(obj.bmi);
    writer.writeString(obj.category);
    writer.writeString(obj.gender);
    writer.writeInt(obj.age);
    writer.writeString(obj.unitSystem);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
