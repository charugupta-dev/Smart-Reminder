import '../entities/shortcut_entity.dart';

/// Abstract repository contract for shortcut operations.
/// Implemented by the data layer, consumed by use cases.
abstract class ShortcutRepository {
  /// Get all shortcuts, ordered by creation date.
  Future<List<ShortcutEntity>> getAll();

  /// Get a single shortcut by ID.
  Future<ShortcutEntity?> getById(String id);

  /// Add a new shortcut. Returns the saved entity.
  Future<ShortcutEntity> add(ShortcutEntity shortcut);

  /// Update an existing shortcut.
  Future<ShortcutEntity> update(ShortcutEntity shortcut);

  /// Delete a shortcut by ID.
  Future<void> delete(String id);

  /// Check if a prefix is already in use (case-insensitive).
  Future<bool> isPrefixTaken(String prefix, {String? excludeId});

  /// Seed default shortcuts (first launch only).
  Future<void> seedDefaults(List<ShortcutEntity> defaults);
}
