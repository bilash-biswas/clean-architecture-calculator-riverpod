import 'package:calculator/features/age_calculator/data/datasources/age_local_datasource.dart';
import 'package:calculator/features/age_calculator/data/models/age_history_model.dart';
import 'package:calculator/features/age_calculator/domain/entities/age_entity.dart';
import 'package:calculator/features/age_calculator/domain/repositories/age_history_repository.dart';

class AgeHistoryRepositoryImpl implements AgeHistoryRepository {
  final AgeLocalDataSource _dataSource;

  AgeHistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<AgeHistoryEntry>> getHistory() async {
    final models = _dataSource.getHistory();
    return models.map((model) {
      final entryMap = model.toEntry();
      return AgeHistoryEntry(
        id: entryMap['id'] as int,
        birthDate: entryMap['birthDate'] as DateTime,
        asOfDate: entryMap['asOfDate'] as DateTime,
        result: entryMap['result'] as AgeEntity,
        timestamp: entryMap['timestamp'] as DateTime,
      );
    }).toList();
  }

  @override
  Future<void> addEntry({
    required DateTime birthDate,
    required DateTime asOfDate,
    required AgeEntity result,
  }) async {
    final timestamp = DateTime.now();
    final model = AgeHistoryModel.fromEntry(
      0,
      birthDate,
      asOfDate,
      result,
      timestamp,
    );
    await _dataSource.addEntry(model);
  }

  @override
  Future<void> deleteEntity(int id) async {
    await _dataSource.deleteEntry(id);
  }

  @override
  Future<void> clearHistory() async {
    await _dataSource.clearHistory();
  }
}
