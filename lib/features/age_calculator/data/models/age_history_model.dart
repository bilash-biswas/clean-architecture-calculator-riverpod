import 'package:calculator/features/age_calculator/domain/entities/age_entity.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class AgeHistoryModel extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late DateTime birthDate;

  @HiveField(2)
  late DateTime asOfDate;

  @HiveField(3)
  late int resultYears;

  @HiveField(4)
  late int resultMonths;

  @HiveField(5)
  late int resultDays;

  @HiveField(6)
  late int resultTotalDays;

  @HiveField(7)
  late DateTime nextBirthday;

  @HiveField(8)
  late DateTime timestamp;

  AgeHistoryModel();

  factory AgeHistoryModel.fromEntry(
    int id,
    DateTime birthDate,
    DateTime asOfDate,
    AgeEntity result,
    DateTime timestamp,
  ) {
    final model = AgeHistoryModel()
      ..id = id
      ..birthDate = birthDate
      ..asOfDate = asOfDate
      ..resultYears = result.years
      ..resultMonths = result.months
      ..resultDays = result.days
      ..resultTotalDays = result.totalDays
      ..nextBirthday = result.nextBirthday
      ..timestamp = timestamp;
    return model;
  }

  Map<String, dynamic> toEntry() {
    return {
      'id': id,
      'birthDate': birthDate,
      'asOfDate': asOfDate,
      'result': AgeEntity(
        years: resultYears,
        months: resultMonths,
        days: resultDays,
        totalDays: resultTotalDays,
        nextBirthday: nextBirthday,
      ),
      'timestamp': timestamp,
    };
  }
}

class AgeHistoryModelAdapter extends TypeAdapter<AgeHistoryModel> {
  @override
  final int typeId = 0;

  @override
  AgeHistoryModel read(BinaryReader reader) {
    final model = AgeHistoryModel()
      ..id = reader.readInt()
      ..birthDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt())
      ..asOfDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt())
      ..resultYears = reader.readInt()
      ..resultMonths = reader.readInt()
      ..resultDays = reader.readInt()
      ..resultTotalDays = reader.readInt()
      ..nextBirthday = DateTime.fromMillisecondsSinceEpoch(reader.readInt())
      ..timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return model;
  }

  @override
  void write(BinaryWriter writer, AgeHistoryModel obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.birthDate.millisecondsSinceEpoch);
    writer.writeInt(obj.asOfDate.millisecondsSinceEpoch);
    writer.writeInt(obj.resultYears);
    writer.writeInt(obj.resultMonths);
    writer.writeInt(obj.resultDays);
    writer.writeInt(obj.resultTotalDays);
    writer.writeInt(obj.nextBirthday.millisecondsSinceEpoch);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
