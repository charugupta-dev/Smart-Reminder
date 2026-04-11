import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';
import 'core/constants/defaults.dart';
import 'features/settings/data/datasources/shortcut_local_datasource.dart';
import 'features/settings/data/repositories/shortcut_repository_impl.dart';
import 'features/settings/domain/entities/shortcut_entity.dart';
import 'features/settings/presentation/providers/shortcut_provider.dart';
import 'features/tasks/data/datasources/task_local_datasource.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await Hive.initFlutter();

  // Initialize data sources synchronously before starting the app
  final shortcutDatasource = ShortcutLocalDatasource();
  await shortcutDatasource.init();

  final taskDatasource = TaskLocalDatasource();
  await taskDatasource.init();

  // Seed default shortcuts if this is the first launch
  final shortcutRepo = ShortcutRepositoryImpl(shortcutDatasource);
  if (shortcutDatasource.isEmpty) {
    const uuid = Uuid();
    final defaults = Defaults.defaultShortcuts.map((d) {
      return ShortcutEntity(
        id: uuid.v4(),
        prefix: d['prefix'] as String,
        categoryName: d['categoryName'] as String,
        colorValue: d['colorValue'] as int,
        iconKey: d['iconKey'] as String,
        createdAt: DateTime.now(),
      );
    }).toList();
    await shortcutRepo.seedDefaults(defaults);
  }

  runApp(
    ProviderScope(
      overrides: [
        shortcutDatasourceProvider.overrideWithValue(shortcutDatasource),
        taskDatasourceProvider.overrideWithValue(taskDatasource),
      ],
      child: const SmartRemindApp(),
    ),
  );
}
