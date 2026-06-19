import 'package:hive_flutter/hive_flutter.dart';
import 'package:calculator/features/age_calculator/data/models/age_history_model.dart';
import 'package:calculator/features/standard_calculator/data/models/calculator_history_model.dart';
import 'package:calculator/features/bmi_calculator/data/models/bmi_history_model.dart';
import 'package:calculator/features/length_converter/data/models/length_history_model.dart';
import 'package:calculator/features/weight_converter/data/models/weight_history_model.dart';

class DatabaseService {
  static const String ageHistoryBoxName = 'age_history_box';
  static const String calculatorHistoryBoxName = 'calculator_history_box';
  static const String bmiHistoryBoxName = 'bmi_history_box';
  static const String lengthHistoryBoxName = 'length_history_box';
  static const String weightHistoryBoxName = 'weight_history_box';
  static const String settingsBoxName = 'settings_box';

  Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(AgeHistoryModelAdapter());
    Hive.registerAdapter(CalculatorHistoryModelAdapter());
    Hive.registerAdapter(BmiHistoryModelAdapter());
    Hive.registerAdapter(LengthHistoryModelAdapter());
    Hive.registerAdapter(WeightHistoryModelAdapter());

    // Open boxes
    await Hive.openBox<AgeHistoryModel>(ageHistoryBoxName);
    await Hive.openBox<CalculatorHistoryModel>(calculatorHistoryBoxName);
    await Hive.openBox<BmiHistoryModel>(bmiHistoryBoxName);
    await Hive.openBox<LengthHistoryModel>(lengthHistoryBoxName);
    await Hive.openBox<WeightHistoryModel>(weightHistoryBoxName);
    await Hive.openBox(settingsBoxName);
  }
}
