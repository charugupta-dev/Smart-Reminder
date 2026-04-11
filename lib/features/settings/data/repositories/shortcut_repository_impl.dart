import '../../domain/entities/shortcut_entity.dart';
import '../../domain/repositories/shortcut_repository.dart';
import '../datasources/shortcut_local_datasource.dart';
import '../models/shortcut_model.dart';

/// Concrete implementation of [ShortcutRepository] using Hive local storage.
class ShortcutRepositoryImpl implements ShortcutRepository {
  final ShortcutLocalDatasource _datasource;

  ShortcutRepositoryImpl(this._datasource);

  @override
  Future<List<ShortcutEntity>> getAll() async {
    final models = _datasource.getAll();
    final entities = models.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return entities;
  }

  @override
  Future<ShortcutEntity?> getById(String id) async {
    return _datasource.getById(id)?.toEntity();
  }

  @override
  Future<ShortcutEntity> add(ShortcutEntity shortcut) async {
    final model = ShortcutModel.fromEntity(shortcut);
    await _datasource.save(model);
    return shortcut;
  }

  @override
  Future<ShortcutEntity> update(ShortcutEntity shortcut) async {
    final model = ShortcutModel.fromEntity(shortcut);
    await _datasource.save(model);
    return shortcut;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
  }

  @override
  Future<bool> isPrefixTaken(String prefix, {String? excludeId}) async {
    final all = _datasource.getAll();
    return all.any((m) =>
        m.prefix.toLowerCase() == prefix.toLowerCase() &&
        m.id != excludeId);
  }

  @override
  Future<void> seedDefaults(List<ShortcutEntity> defaults) async {
    if (_datasource.isEmpty) {
      final models = defaults.map((e) => ShortcutModel.fromEntity(e)).toList();
      await _datasource.saveAll(models);
    }
  }
}
