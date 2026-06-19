import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class CalculatorHistoryModel extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String expression;

  @HiveField(2)
  late String result;

  @HiveField(3)
  late DateTime timestamp;

  CalculatorHistoryModel({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  factory CalculatorHistoryModel.fromValues(
    int id,
    String expression,
    String result,
    DateTime timestamp,
  ) {
    final model = CalculatorHistoryModel(
      id: id,
      expression: expression,
      result: result,
      timestamp: timestamp,
    );
    return model;
  }
}

class CalculatorHistoryModelAdapter extends TypeAdapter<CalculatorHistoryModel> {
  @override
  final int typeId = 1;

  @override
  CalculatorHistoryModel read(BinaryReader reader) {
    final model = CalculatorHistoryModel(
      id: reader.readInt(),
      expression: reader.readString(),
      result: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
    return model;
  }

  @override
  void write(BinaryWriter writer, CalculatorHistoryModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.expression);
    writer.writeString(obj.result);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
