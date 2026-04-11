import 'package:hive_ce/hive.dart';
import '../models/task_model.dart';
import '../../../../core/constants/defaults.dart';

/// Local data source for tasks using Hive.
class TaskLocalDatasource {
  late Box<Map> _box;

  /// Initialize or access the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<Map>(Defaults.tasksBoxName);
  }

  Box<Map> get box => _box;

  /// Get all tasks from local storage.
  List<TaskModel> getAll() {
    return _box.values
        .map((json) => TaskModel.fromJson(json))
        .toList();
  }

  /// Get a task by ID.
  TaskModel? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return TaskModel.fromJson(json);
  }

  /// Save a task (insert or update).
  Future<void> save(TaskModel model) async {
    await _box.put(model.id, model.toJson());
  }

  /// Delete a task by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all completed tasks.
  Future<void> clearCompleted() async {
    final completedKeys = _box.keys.where((key) {
      final json = _box.get(key);
      return json != null && json['isCompleted'] == true;
    }).toList();
    await _box.deleteAll(completedKeys);
  }

  /// Save multiple tasks at once (for reorder operations).
  Future<void> saveAll(List<TaskModel> models) async {
    final entries = {
      for (final m in models) m.id: m.toJson(),
    };
    await _box.putAll(entries);
  }
}
