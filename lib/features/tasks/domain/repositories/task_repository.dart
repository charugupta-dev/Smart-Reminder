import '../entities/task_entity.dart';

/// Abstract repository contract for task operations.
/// Implemented by the data layer, consumed by use cases.
abstract class TaskRepository {
  /// Get all pending (not completed) tasks, ordered by sortOrder then createdAt.
  Future<List<TaskEntity>> getPendingTasks();

  /// Get all completed tasks, ordered by completedAt descending.
  Future<List<TaskEntity>> getCompletedTasks();

  /// Get a single task by ID.
  Future<TaskEntity?> getById(String id);

  /// Add a new task. Returns the saved entity.
  Future<TaskEntity> add(TaskEntity task);

  /// Update an existing task.
  Future<TaskEntity> update(TaskEntity task);

  /// Delete a task by ID.
  Future<void> delete(String id);

  /// Delete all completed tasks.
  Future<void> clearCompleted();

  /// Reorder tasks within or across categories.
  Future<void> reorder(List<TaskEntity> reorderedTasks);
}
