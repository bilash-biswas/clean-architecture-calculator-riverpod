import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:calculator/core/services/database_service.dart';
import 'package:calculator/features/standard_calculator/data/models/calculator_history_model.dart';

class CalculatorState {
  final String expression;
  final String result;
  final String realTimePreview;
  final List<CalculatorHistoryModel> history;

  CalculatorState({
    this.expression = '',
    this.result = '0',
    this.realTimePreview = '',
    this.history = const [],
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    String? realTimePreview,
    List<CalculatorHistoryModel>? history,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      realTimePreview: realTimePreview ?? this.realTimePreview,
      history: history ?? this.history,
    );
  }
}

// Providers
final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(CalculatorNotifier.new);

class CalculatorNotifier extends Notifier<CalculatorState> {
  late final Box<CalculatorHistoryModel> _box;

  @override
  CalculatorState build() {
    _box = Hive.box<CalculatorHistoryModel>(DatabaseService.calculatorHistoryBoxName);
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return CalculatorState(history: list);
  }

  void _loadHistory() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = state.copyWith(history: list);
  }

  void append(String char) {
    String currentExpr = state.expression;
    String currentResult = state.result;

    // Handle operator constraints (avoid double operators)
    if (_isOperator(char)) {
      if (currentExpr.isEmpty) {
        if (state.result != 'Error') {
          currentExpr = state.result + char;
        } else if (char == '-') {
          currentExpr = '-';
          currentResult = '0';
        } else {
          return; // Don't start with operator (except minus)
        }
      } else {
        final lastChar = currentExpr[currentExpr.length - 1];
        if (_isOperator(lastChar)) {
          // Replace last operator
          currentExpr = currentExpr.substring(0, currentExpr.length - 1) + char;
        } else {
          currentExpr += char;
        }
      }
    } else if (char == '.') {
      if (currentExpr.isEmpty) {
        currentExpr = '0.';
        currentResult = '0';
      } else {
        final lastChar = currentExpr[currentExpr.length - 1];
        if (_isOperator(lastChar) || lastChar == '(') {
          currentExpr += '0.';
        } else {
          // Only allow dot if the current number token doesn't have one
          final lastNumberMatch = RegExp(r'(\d+\.?\d*)$').firstMatch(currentExpr);
          if (lastNumberMatch != null) {
            final lastNum = lastNumberMatch.group(0)!;
            if (lastNum.contains('.')) return; // Already has dot
          }
          currentExpr += char;
        }
      }
    } else {
      if (currentExpr.isEmpty) {
        currentExpr = char;
        currentResult = '0';
      } else {
        currentExpr += char;
      }
    }

    state = state.copyWith(
      expression: currentExpr,
      result: currentResult,
      realTimePreview: _calculatePreview(currentExpr),
    );
  }

  void clear() {
    state = state.copyWith(
      expression: '',
      result: '0',
      realTimePreview: '',
    );
  }

  void backspace() {
    if (state.expression.isEmpty) return;
    final newExpr = state.expression.substring(0, state.expression.length - 1);
    state = state.copyWith(
      expression: newExpr,
      realTimePreview: _calculatePreview(newExpr),
    );
  }

  void toggleSign() {
    if (state.expression.isEmpty) {
      if (state.result != '0' && state.result != 'Error') {
        final number = state.result;
        final replacement = number.startsWith('-') ? number.substring(1) : '-$number';
        state = state.copyWith(
          expression: replacement,
          result: '0',
          realTimePreview: _calculatePreview(replacement),
        );
      }
      return;
    }
    final regex = RegExp(r'(-?\d+\.?\d*)$');
    final match = regex.firstMatch(state.expression);
    if (match != null) {
      final number = match.group(1)!;
      final replacement = number.startsWith('-') ? number.substring(1) : '-$number';
      final newExpression = state.expression.replaceRange(match.start, match.end, replacement);
      state = state.copyWith(
        expression: newExpression,
        realTimePreview: _calculatePreview(newExpression),
      );
    }
  }


  Future<void> evaluate() async {
    if (state.expression.isEmpty) return;

    try {
      final evaluatedVal = _evaluateMathExpression(state.expression);
      final formatted = _formatVal(evaluatedVal);

      // Save to Hive
      final timestamp = DateTime.now();
      final historyModel = CalculatorHistoryModel.fromValues(
        0,
        state.expression,
        formatted,
        timestamp,
      );
      final key = await _box.add(historyModel);
      historyModel.id = key;
      await historyModel.save();

      state = state.copyWith(
        expression: '',
        result: formatted,
        realTimePreview: '',
      );

      _loadHistory();
    } catch (_) {
      state = state.copyWith(
        result: 'Error',
        realTimePreview: '',
      );
    }
  }

  Future<void> deleteHistoryItem(int id) async {
    await _box.delete(id);
    _loadHistory();
  }

  Future<void> clearHistory() async {
    await _box.clear();
    _loadHistory();
  }

  void loadFromHistory(CalculatorHistoryModel entry) {
    state = state.copyWith(
      expression: entry.expression,
      result: entry.result,
      realTimePreview: '',
    );
  }

  // --- Parser Engine ---

  bool _isOperator(String char) {
    return char == '+' || char == '-' || char == '×' || char == '÷' || char == '%';
  }

  String _calculatePreview(String expr) {
    if (expr.isEmpty) return '';

    // Strip trailing operators/parentheses for temporary preview evaluation
    String temp = expr.trim();
    while (temp.isNotEmpty && RegExp(r'[+\-×÷(]$').hasMatch(temp)) {
      temp = temp.substring(0, temp.length - 1).trim();
    }

    if (temp.isEmpty) return '';

    try {
      final val = _evaluateMathExpression(temp);
      return _formatVal(val);
    } catch (_) {
      return '';
    }
  }

  double _evaluateMathExpression(String expr) {
    final sanitized = expr.replaceAll('×', '*').replaceAll('÷', '/');
    final tokens = _tokenize(sanitized);
    int index = 0;

    late final double Function() parseExpressionHelper;
    late final double Function() parseTerm;
    late final double Function() parsePrimary;

    parsePrimary = () {
      if (index >= tokens.length) return 0.0;

      String token = tokens[index];
      if (token == '(') {
        index++; // consume '('
        double val = parseExpressionHelper();
        if (index < tokens.length && tokens[index] == ')') {
          index++; // consume ')'
        }
        return val;
      }

      if (token == '-') {
        index++;
        return -parsePrimary();
      }

      if (token == '+') {
        index++;
        return parsePrimary();
      }

      double val = double.tryParse(token) ?? 0.0;
      index++;

      // Postfix percentage
      if (index < tokens.length && tokens[index] == '%') {
        val = val / 100.0;
        index++;
      }

      return val;
    };

    parseTerm = () {
      double left = parsePrimary();
      while (index < tokens.length) {
        String op = tokens[index];
        if (op == '*' || op == '/') {
          index++;
          double right = parsePrimary();
          if (op == '*') {
            left *= right;
          } else {
            if (right == 0) throw Exception();
            left /= right;
          }
        } else {
          break;
        }
      }
      return left;
    };

    parseExpressionHelper = () {
      double left = parseTerm();
      while (index < tokens.length) {
        String op = tokens[index];
        if (op == '+' || op == '-') {
          index++;
          double right = parseTerm();
          if (op == '+') {
            left += right;
          } else {
            left -= right;
          }
        } else {
          break;
        }
      }
      return left;
    };

    final result = parseExpressionHelper();
    if (index < tokens.length) {
      throw Exception();
    }
    return result;
  }

  List<String> _tokenize(String expr) {
    final List<String> tokens = [];
    final buffer = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      final char = expr[i];
      if (RegExp(r'[0-9.]').hasMatch(char)) {
        buffer.write(char);
      } else {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        if (char.trim().isEmpty) continue;
        if (char == '+' || char == '-' || char == '*' || char == '/' || char == '(' || char == ')' || char == '%') {
          tokens.add(char);
        }
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    return tokens;
  }

  String _formatVal(double val) {
    if (val.isInfinite || val.isNaN) return 'Error';
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    String str = val.toStringAsFixed(8);
    while (str.contains('.') && (str.endsWith('0') || str.endsWith('.'))) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }
}
