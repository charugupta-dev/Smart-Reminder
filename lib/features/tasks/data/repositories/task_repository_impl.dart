import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

/// Concrete implementation of [TaskRepository] using Hive local storage.
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<List<TaskEntity>> getPendingTasks() async {
    final models = _datasource.getAll();
    final pending = models
        .where((m) => !m.isCompleted)
        .map((m) => m.toEntity())
        .toList();
    // Sort by sortOrder first, then by createdAt (oldest first).
    pending.sort((a, b) {
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    return pending;
  }

  @override
  Future<List<TaskEntity>> getCompletedTasks() async {
    final models = _datasource.getAll();
    final completed = models
        .where((m) => m.isCompleted)
        .map((m) => m.toEntity())
        .toList();
    // Most recently completed first.
    completed.sort((a, b) =>
        (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
    return completed;
  }

  @override
  Future<TaskEntity?> getById(String id) async {
    return _datasource.getById(id)?.toEntity();
  }

  @override
  Future<TaskEntity> add(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _datasource.save(model);
    return task;
  }

  @override
  Future<TaskEntity> update(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _datasource.save(model);
    return task;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
  }

  @override
  Future<void> clearCompleted() async {
    await _datasource.clearCompleted();
  }

  @override
  Future<void> reorder(List<TaskEntity> reorderedTasks) async {
    final models = reorderedTasks.map((e) => TaskModel.fromEntity(e)).toList();
    await _datasource.saveAll(models);
  }
}
