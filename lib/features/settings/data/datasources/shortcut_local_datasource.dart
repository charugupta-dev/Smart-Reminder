import 'package:hive_ce/hive.dart';
import '../models/shortcut_model.dart';
import '../../../../core/constants/defaults.dart';

/// Local data source for shortcuts using Hive.
class ShortcutLocalDatasource {
  late Box<Map> _box;

  /// Initialize or access the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<Map>(Defaults.shortcutsBoxName);
  }

  Box<Map> get box => _box;

  /// Get all shortcuts from local storage.
  List<ShortcutModel> getAll() {
    return _box.values
        .map((json) => ShortcutModel.fromJson(json))
        .toList();
  }

  /// Get a shortcut by ID.
  ShortcutModel? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return ShortcutModel.fromJson(json);
  }

  /// Save a shortcut (insert or update).
  Future<void> save(ShortcutModel model) async {
    await _box.put(model.id, model.toJson());
  }

  /// Delete a shortcut by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Check if the box is empty (for first-launch seeding).
  bool get isEmpty => _box.isEmpty;

  /// Save multiple shortcuts at once.
  Future<void> saveAll(List<ShortcutModel> models) async {
    final entries = {
      for (final m in models) m.id: m.toJson(),
    };
    await _box.putAll(entries);
  }
}
