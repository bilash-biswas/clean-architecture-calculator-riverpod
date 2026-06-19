import 'package:hive/hive.dart';
import 'package:calculator/core/services/database_service.dart';
import 'package:calculator/features/age_calculator/data/models/age_history_model.dart';

class AgeLocalDataSource {
  final Box<AgeHistoryModel> _box;

  AgeLocalDataSource([Box<AgeHistoryModel>? box])
      : _box = box ?? Hive.box<AgeHistoryModel>(DatabaseService.ageHistoryBoxName);

  List<AgeHistoryModel> getHistory() {
    final list = _box.values.toList();
    // Sort history by timestamp descending (newest first)
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> addEntry(AgeHistoryModel entry) async {
    final key = await _box.add(entry);
    entry.id = key;
    await entry.save();
  }

  Future<void> deleteEntry(int id) async {
    await _box.delete(id);
  }

  Future<void> clearHistory() async {
    await _box.clear();
  }
}
