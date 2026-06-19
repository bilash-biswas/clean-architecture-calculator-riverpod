import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:calculator/core/services/database_service.dart';
import '../../data/models/weight_history_model.dart';
import '../../domain/usecases/convert_weight.dart';

class WeightConverterState {
  final String fromUnit;
  final String toUnit;
  final String fromValue;
  final String toValue;
  final bool isFromFocused;
  final List<WeightHistoryModel> history;

  WeightConverterState({
    this.fromUnit = 'kg',
    this.toUnit = 'g',
    this.fromValue = '1',
    this.toValue = '1000',
    this.isFromFocused = true,
    this.history = const [],
  });

  WeightConverterState copyWith({
    String? fromUnit,
    String? toUnit,
    String? fromValue,
    String? toValue,
    bool? isFromFocused,
    List<WeightHistoryModel>? history,
  }) {
    return WeightConverterState(
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      fromValue: fromValue ?? this.fromValue,
      toValue: toValue ?? this.toValue,
      isFromFocused: isFromFocused ?? this.isFromFocused,
      history: history ?? this.history,
    );
  }
}

class WeightConverterNotifier extends Notifier<WeightConverterState> {
  late final Box<WeightHistoryModel> _box;
  final _convertWeight = ConvertWeight();

  @override
  WeightConverterState build() {
    _box = Hive.box<WeightHistoryModel>(DatabaseService.weightHistoryBoxName);
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return WeightConverterState(history: list);
  }

  void _loadHistory() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = state.copyWith(history: list);
  }

  void selectTab(bool isFrom) {
    state = state.copyWith(isFromFocused: isFrom);
  }

  void appendDigit(String digit) {
    String currentText = state.isFromFocused ? state.fromValue : state.toValue;

    if (digit == '.') {
      if (currentText.contains('.')) return; // Only one dot
      if (currentText.isEmpty) {
        currentText = '0.';
      } else {
        currentText += '.';
      }
    } else {
      if (currentText == '0') {
        currentText = digit;
      } else {
        currentText += digit;
      }
    }

    _updateTargetAndConvert(currentText);
  }

  void backspace() {
    String currentText = state.isFromFocused ? state.fromValue : state.toValue;
    if (currentText.isEmpty) return;

    currentText = currentText.substring(0, currentText.length - 1);
    if (currentText.isEmpty) {
      currentText = '0';
    }

    _updateTargetAndConvert(currentText);
  }

  void clear() {
    _updateTargetAndConvert('0');
  }

  void _updateTargetAndConvert(String text) {
    final numericVal = double.tryParse(text) ?? 0.0;

    final convertedVal = _convertWeight(
      value: numericVal,
      fromAbbr: state.isFromFocused ? state.fromUnit : state.toUnit,
      toAbbr: state.isFromFocused ? state.toUnit : state.fromUnit,
    );

    final formattedConvertedText = _formatValue(convertedVal);

    if (state.isFromFocused) {
      state = state.copyWith(
        fromValue: text,
        toValue: formattedConvertedText,
      );
    } else {
      state = state.copyWith(
        toValue: text,
        fromValue: formattedConvertedText,
      );
    }
  }

  String _formatValue(double val) {
    if (val == 0.0) return '0';
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    String str = val.toStringAsFixed(6);
    while (str.contains('.') && (str.endsWith('0') || str.endsWith('.'))) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }

  void setFromUnit(String unit) {
    if (state.fromUnit == unit) return;

    state = state.copyWith(fromUnit: unit);
    if (state.isFromFocused) {
      _updateTargetAndConvert(state.fromValue);
    } else {
      final numericTo = double.tryParse(state.toValue) ?? 0.0;
      final convertedFrom = _convertWeight(
        value: numericTo,
        fromAbbr: state.toUnit,
        toAbbr: unit,
      );
      state = state.copyWith(fromValue: _formatValue(convertedFrom));
    }
  }

  void setToUnit(String unit) {
    if (state.toUnit == unit) return;

    state = state.copyWith(toUnit: unit);
    if (!state.isFromFocused) {
      _updateTargetAndConvert(state.toValue);
    } else {
      final numericFrom = double.tryParse(state.fromValue) ?? 0.0;
      final convertedTo = _convertWeight(
        value: numericFrom,
        fromAbbr: state.fromUnit,
        toAbbr: unit,
      );
      state = state.copyWith(toValue: _formatValue(convertedTo));
    }
  }

  void swapUnits() {
    final oldFromUnit = state.fromUnit;
    final oldToUnit = state.toUnit;
    final oldFromValue = state.fromValue;
    final oldToValue = state.toValue;

    state = state.copyWith(
      fromUnit: oldToUnit,
      toUnit: oldFromUnit,
      fromValue: oldToValue,
      toValue: oldFromValue,
    );
  }

  Future<void> saveToHistory() async {
    final fromVal = double.tryParse(state.fromValue) ?? 0.0;
    final toVal = double.tryParse(state.toValue) ?? 0.0;

    final timestamp = DateTime.now();
    final model = WeightHistoryModel.fromValues(
      id: 0,
      fromUnit: state.fromUnit,
      toUnit: state.toUnit,
      fromValue: fromVal,
      toValue: toVal,
      timestamp: timestamp,
    );

    final key = await _box.add(model);
    model.id = key;
    await model.save();

    _loadHistory();
  }

  void reset() {
    state = WeightConverterState(
      fromUnit: 'kg',
      toUnit: 'g',
      fromValue: '1',
      toValue: '1000',
      isFromFocused: true,
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

final weightConverterProvider =
    NotifierProvider<WeightConverterNotifier, WeightConverterState>(WeightConverterNotifier.new);
