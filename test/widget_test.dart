import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:calculator/core/services/database_service.dart';
import 'package:calculator/features/standard_calculator/data/models/calculator_history_model.dart';
import 'package:calculator/features/standard_calculator/presentation/notifiers/calculator_notifier.dart';
import 'package:calculator/features/age_calculator/domain/usecases/calculate_age.dart';
import 'package:calculator/features/bmi_calculator/data/models/bmi_history_model.dart';
import 'package:calculator/features/bmi_calculator/domain/usecases/calculate_bmi.dart';
import 'package:calculator/features/bmi_calculator/presentation/notifiers/bmi_calculator_notifier.dart';
import 'package:calculator/features/length_converter/data/models/length_history_model.dart';
import 'package:calculator/features/length_converter/domain/usecases/convert_length.dart';
import 'package:calculator/features/length_converter/presentation/notifiers/length_converter_notifier.dart';
import 'package:calculator/features/weight_converter/data/models/weight_history_model.dart';
import 'package:calculator/features/weight_converter/domain/usecases/convert_weight.dart';
import 'package:calculator/features/weight_converter/presentation/notifiers/weight_converter_notifier.dart';


void main() {
  group('Standard Calculator Parser Tests', () {
    late ProviderContainer container;
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_test_dir');
      Hive.init(tempDir.path);

      try {
        Hive.registerAdapter(CalculatorHistoryModelAdapter());
      } catch (_) {
        // Already registered
      }

      await Hive.openBox<CalculatorHistoryModel>(DatabaseService.calculatorHistoryBoxName);
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Simple addition', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('2');
      notifier.append('+');
      notifier.append('3');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '5');
    });

    test('Operator precedence (multiplication before addition)', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('2');
      notifier.append('+');
      notifier.append('3');
      notifier.append('×');
      notifier.append('4');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '14');
    });

    test('Parentheses overriding precedence', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('(');
      notifier.append('2');
      notifier.append('+');
      notifier.append('3');
      notifier.append(')');
      notifier.append('×');
      notifier.append('4');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '20');
    });

    test('Decimals', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('2');
      notifier.append('.');
      notifier.append('5');
      notifier.append('×');
      notifier.append('2');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '5');
    });

    test('Percentages', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('5');
      notifier.append('0');
      notifier.append('%');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '0.5');
    });

    test('Division by zero handling', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('5');
      notifier.append('÷');
      notifier.append('0');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, 'Error');
    });

    test('Continue calculation after evaluation', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('1');
      notifier.append('2');
      notifier.append('+');
      notifier.append('3');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '15');
      expect(container.read(calculatorProvider).expression, '');

      notifier.append('+');
      notifier.append('3');
      expect(container.read(calculatorProvider).expression, '15+3');

      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '18');
    });

    test('Toggle sign on previous result', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('1');
      notifier.append('2');
      notifier.append('+');
      notifier.append('3');
      await notifier.evaluate();
      expect(container.read(calculatorProvider).result, '15');

      notifier.toggleSign();
      expect(container.read(calculatorProvider).expression, '-15');
      expect(container.read(calculatorProvider).result, '0');
    });

    test('Toggle sign with decimal point', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('.');
      expect(container.read(calculatorProvider).expression, '0.');
      notifier.toggleSign();
      expect(container.read(calculatorProvider).expression, '-0.');
    });

    test('Toggle sign on expression ending with decimal point after operator', () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.clear();
      notifier.append('1');
      notifier.append('2');
      notifier.append('+');
      notifier.append('.');
      expect(container.read(calculatorProvider).expression, '12+0.');
      notifier.toggleSign();
      expect(container.read(calculatorProvider).expression, '12+-0.');
    });
  });

  group('Age Calculator Business Logic Tests', () {
    final calculateAge = CalculateAge();

    test('Age calculation on same year future date', () {
      final birthDate = DateTime(2000, 5, 15);
      final asOfDate = DateTime(2026, 6, 19);

      final result = calculateAge(birthDate: birthDate, asOfDate: asOfDate);

      expect(result.years, 26);
      expect(result.months, 1);
      expect(result.days, 4);
    });

    test('Age calculation on same year past date', () {
      final birthDate = DateTime(2000, 10, 25);
      final asOfDate = DateTime(2026, 6, 19);

      final result = calculateAge(birthDate: birthDate, asOfDate: asOfDate);

      expect(result.years, 25);
      expect(result.months, 7);
      expect(result.days, 25);
    });
  });

  group('BMI Calculator Tests', () {
    late ProviderContainer container;
    late Directory tempDir;
    final calculateBmi = CalculateBmi();

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_bmi_test_dir');
      Hive.init(tempDir.path);

      try {
        Hive.registerAdapter(BmiHistoryModelAdapter());
      } catch (_) {
        // Already registered
      }

      await Hive.openBox<BmiHistoryModel>(DatabaseService.bmiHistoryBoxName);
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Metric calculation logic (Normal weight)', () {
      final result = calculateBmi(weight: 70, height: 175, unitSystem: 'metric');
      expect(result.bmi, closeTo(22.86, 0.05));
      expect(result.category, 'Normal');
      expect(result.idealWeightRange, '56.7 - 76.3 kg');
      expect(result.statusColorHex, 'FF2ECC71');
    });

    test('Imperial calculation logic (Normal weight)', () {
      final result = calculateBmi(weight: 150, height: 67, unitSystem: 'imperial');
      expect(result.bmi, closeTo(23.49, 0.05));
      expect(result.category, 'Normal');
      expect(result.idealWeightRange, '118.1 - 159.0 lbs');
      expect(result.statusColorHex, 'FF2ECC71');
    });

    test('Underweight, Overweight and Obese classifications', () {
      // Underweight metric
      final uw = calculateBmi(weight: 50, height: 175, unitSystem: 'metric');
      expect(uw.category, 'Underweight');
      expect(uw.statusColorHex, 'FFFA9F1B');

      // Overweight metric
      final ow = calculateBmi(weight: 85, height: 175, unitSystem: 'metric');
      expect(ow.category, 'Overweight');
      expect(ow.statusColorHex, 'FFE67E22');

      // Obese metric
      final ob = calculateBmi(weight: 100, height: 175, unitSystem: 'metric');
      expect(ob.category, 'Obese');
      expect(ob.statusColorHex, 'FFE74C3C');
    });

    test('Notifier calculation state and persistent history logging', () async {
      final notifier = container.read(bmiCalculatorProvider.notifier);

      // Default state
      expect(container.read(bmiCalculatorProvider).unitSystem, 'metric');
      expect(container.read(bmiCalculatorProvider).height, 170.0);
      expect(container.read(bmiCalculatorProvider).weight, 65.0);

      // Set input
      notifier.setHeight(180.0);
      notifier.setWeight(75.0);
      notifier.setAge(30);
      notifier.setGender('female');

      await notifier.calculate();

      final state = container.read(bmiCalculatorProvider);
      expect(state.bmiEntity, isNotNull);
      expect(state.bmiEntity!.bmi, closeTo(23.15, 0.05));
      expect(state.bmiEntity!.category, 'Normal');

      // Confirm logged to history
      expect(state.history.length, 1);
      final log = state.history.first;
      expect(log.weight, 75.0);
      expect(log.height, 180.0);
      expect(log.bmi, closeTo(23.15, 0.05));
      expect(log.gender, 'female');
      expect(log.age, 30);
      expect(log.category, 'Normal');
    });
  });

  group('Length Converter Tests', () {
    late ProviderContainer container;
    late Directory tempDir;
    final convertLength = ConvertLength();

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_length_test_dir');
      Hive.init(tempDir.path);

      try {
        Hive.registerAdapter(LengthHistoryModelAdapter());
      } catch (_) {
        // Already registered
      }

      await Hive.openBox<LengthHistoryModel>(DatabaseService.lengthHistoryBoxName);
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Conversion math logic', () {
      // 1 m -> 100 cm
      expect(convertLength(value: 1, fromAbbr: 'm', toAbbr: 'cm'), 100.0);

      // 1 mi -> km (approx 1.609)
      expect(convertLength(value: 1, fromAbbr: 'mi', toAbbr: 'km'), closeTo(1.60934, 0.001));

      // 1 ft -> 12 in
      expect(convertLength(value: 1, fromAbbr: 'ft', toAbbr: 'in'), closeTo(12.0, 1e-9));
    });

    test('Notifier state transitions and keypad input', () {
      final notifier = container.read(lengthConverterProvider.notifier);

      // Default state
      var state = container.read(lengthConverterProvider);
      expect(state.fromUnit, 'm');
      expect(state.toUnit, 'cm');
      expect(state.fromValue, '1');
      expect(state.toValue, '100');

      // Input digits via keypad
      notifier.clear();
      notifier.appendDigit('5');
      
      state = container.read(lengthConverterProvider);
      expect(state.fromValue, '5');
      expect(state.toValue, '500');

      // Change target unit to mm
      notifier.setToUnit('mm');
      state = container.read(lengthConverterProvider);
      expect(state.fromValue, '5');
      expect(state.toValue, '5000');

      // Swap units
      notifier.swapUnits();
      state = container.read(lengthConverterProvider);
      expect(state.fromUnit, 'mm');
      expect(state.toUnit, 'm');
      expect(state.fromValue, '5000');
      expect(state.toValue, '5');
    });

    test('History logging persistent save', () async {
      final notifier = container.read(lengthConverterProvider.notifier);
      notifier.clear();
      notifier.appendDigit('2'); // 2 mm -> 0.002 m
      await notifier.saveToHistory();

      final state = container.read(lengthConverterProvider);
      expect(state.history.length, 1);
      
      final log = state.history.first;
      expect(log.fromUnit, 'm'); // wait, the swap test above didn't run on this container, so fromUnit is default 'm' and toUnit is 'cm'
      // wait, notifier.clear() sets active focused field to '0', then notifier.appendDigit('2') makes it '2'.
      // Since it is metric defaults ('m' to 'cm'), 2 m -> 200 cm is stored!
      expect(log.fromValue, 2.0);
      expect(log.toValue, 200.0);
    });
  });

  group('Weight Converter Tests', () {
    late ProviderContainer container;
    late Directory tempDir;
    final convertWeight = ConvertWeight();

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_weight_test_dir');
      Hive.init(tempDir.path);

      try {
        Hive.registerAdapter(WeightHistoryModelAdapter());
      } catch (_) {
        // Already registered
      }

      await Hive.openBox<WeightHistoryModel>(DatabaseService.weightHistoryBoxName);
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Conversion math logic', () {
      // 1 kg -> 1000 g
      expect(convertWeight(value: 1, fromAbbr: 'kg', toAbbr: 'g'), 1000.0);

      // 1 lb -> 16 oz
      expect(convertWeight(value: 1, fromAbbr: 'lb', toAbbr: 'oz'), closeTo(16.0, 1e-9));

      // 1 st -> 14 lb
      expect(convertWeight(value: 1, fromAbbr: 'st', toAbbr: 'lb'), closeTo(14.0, 1e-9));

      // 1 t -> 1000 kg
      expect(convertWeight(value: 1, fromAbbr: 't', toAbbr: 'kg'), 1000.0);
    });

    test('Notifier state transitions and keypad input', () {
      final notifier = container.read(weightConverterProvider.notifier);

      // Default state
      var state = container.read(weightConverterProvider);
      expect(state.fromUnit, 'kg');
      expect(state.toUnit, 'g');
      expect(state.fromValue, '1');
      expect(state.toValue, '1000');

      // Input digits via keypad
      notifier.clear();
      notifier.appendDigit('5');
      
      state = container.read(weightConverterProvider);
      expect(state.fromValue, '5');
      expect(state.toValue, '5000');

      // Change target unit to mg
      notifier.setToUnit('mg');
      state = container.read(weightConverterProvider);
      expect(state.fromValue, '5');
      expect(state.toValue, '5000000');

      // Swap units
      notifier.swapUnits();
      state = container.read(weightConverterProvider);
      expect(state.fromUnit, 'mg');
      expect(state.toUnit, 'kg');
      expect(state.fromValue, '5000000');
      expect(state.toValue, '5');
    });

    test('History logging persistent save', () async {
      final notifier = container.read(weightConverterProvider.notifier);
      notifier.clear();
      notifier.appendDigit('2'); // 2 kg -> 2000 g
      await notifier.saveToHistory();

      final state = container.read(weightConverterProvider);
      expect(state.history.length, 1);
      
      final log = state.history.first;
      expect(log.fromUnit, 'kg');
      expect(log.toUnit, 'g');
      expect(log.fromValue, 2.0);
      expect(log.toValue, 2000.0);

      // Delete history item
      await notifier.deleteHistoryItem(log.id);
      expect(container.read(weightConverterProvider).history.length, 0);
    });
  });
}

