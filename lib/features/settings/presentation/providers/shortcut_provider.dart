import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/shortcut_local_datasource.dart';
import '../../data/repositories/shortcut_repository_impl.dart';
import '../../domain/entities/shortcut_entity.dart';
import '../../domain/repositories/shortcut_repository.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../../core/constants/defaults.dart';

const _uuid = Uuid();

// ── Datasource & Repository Providers ──

final shortcutDatasourceProvider = Provider<ShortcutLocalDatasource>((ref) {
  // Initialized in main.dart before runApp.
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final shortcutRepositoryProvider = Provider<ShortcutRepository>((ref) {
  final datasource = ref.watch(shortcutDatasourceProvider);
  return ShortcutRepositoryImpl(datasource);
});

// ── State Notifier ──

final shortcutListProvider =
    StateNotifierProvider<ShortcutNotifier, AsyncValue<List<ShortcutEntity>>>(
  (ref) {
    final repository = ref.watch(shortcutRepositoryProvider);
    return ShortcutNotifier(repository, ref);
  },
);

class ShortcutNotifier extends StateNotifier<AsyncValue<List<ShortcutEntity>>> {
  final ShortcutRepository _repository;
  final Ref _ref;

  ShortcutNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadAll();
  }

  /// Load all shortcuts from storage.
  Future<void> loadAll() async {
    try {
      state = const AsyncValue.loading();
      final shortcuts = await _repository.getAll();
      state = AsyncValue.data(shortcuts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add a new shortcut mapping.
  Future<bool> add({
    required String prefix,
    required String categoryName,
    required int colorValue,
    required String iconKey,
  }) async {
    try {
      // Check for duplicate prefix.
      final taken = await _repository.isPrefixTaken(prefix);
      if (taken) return false;

      final shortcut = ShortcutEntity(
        id: _uuid.v4(),
        prefix: prefix.trim(),
        categoryName: categoryName.trim(),
        colorValue: colorValue,
        iconKey: iconKey,
        createdAt: DateTime.now(),
      );
      await _repository.add(shortcut);
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update an existing shortcut.
  Future<bool> update(ShortcutEntity updated) async {
    try {
      final taken = await _repository.isPrefixTaken(
        updated.prefix,
        excludeId: updated.id,
      );
      if (taken) return false;

      await _repository.update(updated);
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a shortcut by ID and move its tasks to miscellaneous.
  Future<void> delete(String id) async {
    try {
      final shortcut = await _repository.getById(id);
      if (shortcut != null) {
        try {
          await _ref.read(pendingTasksProvider.notifier).assignTasksToMiscellaneous(shortcut.categoryName);
        } catch (_) {}
        await _repository.delete(id);
        await loadAll();
      }
    } catch (e) {
      // Ignored for resilience.
    }
  }

  /// Seed defaults on first launch.
  Future<void> seedDefaults() async {
    final defaults = Defaults.defaultShortcuts.map((d) {
      return ShortcutEntity(
        id: _uuid.v4(),
        prefix: d['prefix'] as String,
        categoryName: d['categoryName'] as String,
        colorValue: d['colorValue'] as int,
        iconKey: d['iconKey'] as String,
        createdAt: DateTime.now(),
      );
    }).toList();
    await _repository.seedDefaults(defaults);
    await loadAll();
  }
}
