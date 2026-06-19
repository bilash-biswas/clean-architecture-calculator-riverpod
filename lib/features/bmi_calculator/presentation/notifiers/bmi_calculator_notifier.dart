import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:calculator/core/services/database_service.dart';
import '../../data/models/bmi_history_model.dart';
import '../../domain/entities/bmi_entity.dart';
import '../../domain/usecases/calculate_bmi.dart';

class BmiCalculatorState {
  final String gender;
  final int age;
  final double height; // cm or inches
  final double weight; // kg or lbs
  final String unitSystem;
  final BmiEntity? bmiEntity;
  final List<BmiHistoryModel> history;

  BmiCalculatorState({
    this.gender = 'male',
    this.age = 25,
    this.height = 170.0,
    this.weight = 65.0,
    this.unitSystem = 'metric',
    this.bmiEntity,
    this.history = const [],
  });

  BmiCalculatorState copyWith({
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? unitSystem,
    BmiEntity? bmiEntity,
    List<BmiHistoryModel>? history,
  }) {
    return BmiCalculatorState(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      unitSystem: unitSystem ?? this.unitSystem,
      bmiEntity: bmiEntity ?? this.bmiEntity,
      history: history ?? this.history,
    );
  }
}

class BmiCalculatorNotifier extends Notifier<BmiCalculatorState> {
  late final Box<BmiHistoryModel> _box;
  final _calculateBmi = CalculateBmi();

  @override
  BmiCalculatorState build() {
    _box = Hive.box<BmiHistoryModel>(DatabaseService.bmiHistoryBoxName);
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return BmiCalculatorState(history: list);
  }

  void _loadHistory() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = state.copyWith(history: list);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setAge(int age) {
    state = state.copyWith(age: age);
  }

  void setHeight(double height) {
    state = state.copyWith(height: height);
  }

  void setWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void setUnitSystem(String unitSystem) {
    if (state.unitSystem == unitSystem) return;

    double newHeight;
    double newWeight;

    if (unitSystem == 'metric') {
      // Imperial (inches, lbs) to Metric (cm, kg)
      newHeight = (state.height * 2.54).roundToDouble();
      newWeight = (state.weight / 2.20462).roundToDouble();
    } else {
      // Metric (cm, kg) to Imperial (inches, lbs)
      newHeight = (state.height / 2.54).roundToDouble();
      newWeight = (state.weight * 2.20462).roundToDouble();
    }

    state = state.copyWith(
      unitSystem: unitSystem,
      height: newHeight,
      weight: newWeight,
      bmiEntity: state.bmiEntity != null
          ? _calculateBmi(weight: newWeight, height: newHeight, unitSystem: unitSystem)
          : null,
    );
  }

  Future<void> calculate() async {
    final entity = _calculateBmi(
      weight: state.weight,
      height: state.height,
      unitSystem: state.unitSystem,
    );

    // Save to Hive
    final timestamp = DateTime.now();
    final model = BmiHistoryModel.fromValues(
      id: 0,
      weight: state.weight,
      height: state.height,
      bmi: entity.bmi,
      category: entity.category,
      gender: state.gender,
      age: state.age,
      unitSystem: state.unitSystem,
      timestamp: timestamp,
    );

    final key = await _box.add(model);
    model.id = key;
    await model.save();

    state = state.copyWith(bmiEntity: entity);
    _loadHistory();
  }

  void reset() {
    state = BmiCalculatorState(
      gender: 'male',
      age: 25,
      height: state.unitSystem == 'metric' ? 170.0 : 67.0,
      weight: state.unitSystem == 'metric' ? 65.0 : 140.0,
      unitSystem: state.unitSystem,
      bmiEntity: null,
      history: state.history,
    );
  }

  Future<void> deleteHistoryItem(int id) async {
    await _box.delete(id);
    _loadHistory();
  }

  Future<void> clearHistory() async {
    await _box.clear();
    _loadHistory();
  }
}

final bmiCalculatorProvider =
    NotifierProvider<BmiCalculatorNotifier, BmiCalculatorState>(BmiCalculatorNotifier.new);
