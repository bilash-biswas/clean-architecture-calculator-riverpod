import 'package:calculator/features/age_calculator/domain/entities/age_entity.dart';

abstract class AgeHistoryRepository {
  Future<List<AgeHistoryEntry>> getHistory();
  Future<void> addEntry({
    required DateTime birthDate,
    required DateTime asOfDate,
    required AgeEntity result,
  });
  Future<void> deleteEntity(int id);
  Future<void> clearHistory();
}

class AgeHistoryEntry {
  final int id;
  final DateTime birthDate;
  final DateTime asOfDate;
  final AgeEntity result;
  final DateTime timestamp;

  AgeHistoryEntry({
    required this.id,
    required this.birthDate,
    required this.asOfDate,
    required this.result,
    required this.timestamp,
  });
}
