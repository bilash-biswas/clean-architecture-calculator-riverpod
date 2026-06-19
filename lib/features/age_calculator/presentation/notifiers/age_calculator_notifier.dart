import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator/features/age_calculator/data/datasources/age_local_datasource.dart';
import 'package:calculator/features/age_calculator/data/repositories/age_history_repository_impl.dart';
import 'package:calculator/features/age_calculator/domain/entities/age_entity.dart';
import 'package:calculator/features/age_calculator/domain/repositories/age_history_repository.dart';
import 'package:calculator/features/age_calculator/domain/usecases/calculate_age.dart';

class AgeCalculatorState {
  final DateTime? birthDate;
  final DateTime asOfDate;
  final AgeEntity? result;
  final List<AgeHistoryEntry> history;
  final bool isLoading;

  AgeCalculatorState({
    this.birthDate,
    required this.asOfDate,
    this.result,
    this.history = const [],
    this.isLoading = false,
  });

  AgeCalculatorState copyWith({
    DateTime? birthDate,
    DateTime? asOfDate,
    AgeEntity? result,
    List<AgeHistoryEntry>? history,
    bool? isLoading,
    bool clearResult = false,
  }) {
    return AgeCalculatorState(
      birthDate: birthDate ?? this.birthDate,
      asOfDate: asOfDate ?? this.asOfDate,
      result: clearResult ? null : (result ?? this.result),
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Providers
final ageLocalDataSourceProvider = Provider<AgeLocalDataSource>((ref) {
  return AgeLocalDataSource();
});

final ageHistoryRepositoryProvider = Provider<AgeHistoryRepository>((ref) {
  final dataSource = ref.watch(ageLocalDataSourceProvider);
  return AgeHistoryRepositoryImpl(dataSource);
});

final calculateAgeUsecaseProvider = Provider<CalculateAge>((ref) {
  return CalculateAge();
});

final ageCalculatorProvider =
    NotifierProvider<AgeCalculatorNotifier, AgeCalculatorState>(AgeCalculatorNotifier.new);

class AgeCalculatorNotifier extends Notifier<AgeCalculatorState> {
  late final AgeHistoryRepository _repository;
  late final CalculateAge _calculateAge;

  @override
  AgeCalculatorState build() {
    _repository = ref.watch(ageHistoryRepositoryProvider);
    _calculateAge = ref.watch(calculateAgeUsecaseProvider);
    Future.microtask(() => loadHistory());
    return AgeCalculatorState(asOfDate: DateTime.now());
  }

  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date, clearResult: true);
  }

  void setAsOfDate(DateTime date) {
    state = state.copyWith(asOfDate: date, clearResult: true);
  }

  Future<void> calculate() async {
    final birthDate = state.birthDate;
    if (birthDate == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = _calculateAge(birthDate: birthDate, asOfDate: state.asOfDate);
      state = state.copyWith(result: result);

      // Save to repository
      await _repository.addEntry(
        birthDate: birthDate,
        asOfDate: state.asOfDate,
        result: result,
      );

      // Reload history
      await loadHistory();
    } catch (_) {
      // Handle error if any
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadHistory() async {
    final history = await _repository.getHistory();
    state = state.copyWith(history: history);
  }

  Future<void> deleteHistoryItem(int id) async {
    await _repository.deleteEntity(id);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    await loadHistory();
  }

  void loadFromHistory(AgeHistoryEntry entry) {
    state = state.copyWith(
      birthDate: entry.birthDate,
      asOfDate: entry.asOfDate,
      result: entry.result,
    );
  }

  void reset() {
    state = AgeCalculatorState(
      asOfDate: DateTime.now(),
      history: state.history,
    );
  }
}
