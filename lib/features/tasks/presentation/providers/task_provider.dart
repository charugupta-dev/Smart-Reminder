import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../settings/presentation/providers/shortcut_provider.dart';
import '../../../../core/utils/task_parser.dart';
import '../../../../core/constants/defaults.dart';

const _uuid = Uuid();

// ── Datasource & Repository Providers ──

final taskDatasourceProvider = Provider<TaskLocalDatasource>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final datasource = ref.watch(taskDatasourceProvider);
  return TaskRepositoryImpl(datasource);
});

// ── Task State ──

/// Holds all pending tasks.
final pendingTasksProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskEntity>>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository, ref);
});

/// Holds all completed tasks.
final completedTasksProvider = FutureProvider<List<TaskEntity>>((ref) async {
  // Re-fetch whenever pending tasks change (i.e. a task was completed).
  ref.watch(pendingTasksProvider);
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getCompletedTasks();
});

/// Derived: pending tasks grouped by category name.
final groupedPendingTasksProvider =
    Provider<Map<String, List<TaskEntity>>>((ref) {
  final tasksAsync = ref.watch(pendingTasksProvider);
  return tasksAsync.when(
    data: (tasks) {
      final grouped = <String, List<TaskEntity>>{};
      // Ensure "Inbox" appears first if it has tasks.
      for (final task in tasks) {
        grouped.putIfAbsent(task.categoryName, () => []).add(task);
      }
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadPending();
  }

  /// Load all pending tasks from storage.
  Future<void> loadPending() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getPendingTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add a task from raw user input. Auto-parses prefix and categorizes.
  Future<void> addTask(String rawInput) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return;

    // Get current shortcuts for parsing.
    final shortcutsAsync = _ref.read(shortcutListProvider);
    final shortcuts = shortcutsAsync.valueOrNull ?? [];

    // Parse the input.
    final result = parseTaskInput(trimmed, shortcuts);

    final task = TaskEntity(
      id: _uuid.v4(),
      title: result.title,
      rawInput: trimmed,
      categoryId: result.categoryId,
      categoryName: result.categoryName,
      createdAt: DateTime.now(),
      sortOrder: _getNextSortOrder(result.categoryId),
    );

    await _repository.add(task);
    await loadPending();
  }

  /// Toggle task completion status.
  Future<void> toggleComplete(String id) async {
    final task = await _repository.getById(id);
    if (task == null) return;

    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await _repository.update(updated);
    await loadPending();
  }

  /// Delete a task.
  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
    await loadPending();
  }

  /// Update the title of a task.
  Future<void> updateTaskTitle(String id, String newTitle) async {
    final task = await _repository.getById(id);
    if (task == null) return;

    final updated = task.copyWith(title: newTitle);
    await _repository.update(updated);
    await loadPending();
  }

  /// Move tasks from a deleted category to Miscellaneous.
  Future<void> assignTasksToMiscellaneous(String categoryName) async {
    final pending = await _repository.getPendingTasks();
    final completed = await _repository.getCompletedTasks();
    final allTasks = [...pending, ...completed];
    for (final t in allTasks) {
      if (t.categoryName == categoryName) {
        final updated = t.copyWith(
          categoryId: Defaults.inboxCategoryId,
          categoryName: Defaults.inboxCategoryName,
        );
        await _repository.update(updated);
      }
    }
    // Refresh both pending and completed lists if needed (completed triggers from pending implicitly)
    await loadPending();
  }

  /// Reorder tasks (updates sortOrder for all affected tasks).
  Future<void> reorderTasks(
    String categoryName,
    int oldIndex,
    int newIndex,
  ) async {
    final currentTasks = state.valueOrNull;
    if (currentTasks == null) return;

    // Get tasks for this category.
    final categoryTasks =
        currentTasks.where((t) => t.categoryName == categoryName).toList();

    if (oldIndex < 0 || oldIndex >= categoryTasks.length) return;
    if (newIndex < 0 || newIndex >= categoryTasks.length) return;

    final task = categoryTasks.removeAt(oldIndex);
    categoryTasks.insert(newIndex, task);

    // Assign new sort orders.
    final updated = <TaskEntity>[];
    for (var i = 0; i < categoryTasks.length; i++) {
      updated.add(categoryTasks[i].copyWith(sortOrder: i));
    }

    await _repository.reorder(updated);
    await loadPending();
  }

  /// Clear all completed tasks.
  Future<void> clearCompleted() async {
    await _repository.clearCompleted();
    await loadPending();
  }

  /// Get the next sort order for a category.
  int _getNextSortOrder(String categoryId) {
    final currentTasks = state.valueOrNull ?? [];
    final categoryTasks =
        currentTasks.where((t) => t.categoryId == categoryId).toList();
    if (categoryTasks.isEmpty) return 0;
    return categoryTasks
            .map((t) => t.sortOrder)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }
}
