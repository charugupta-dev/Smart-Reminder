import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Default shorthand mappings seeded on first launch.
class Defaults {
  Defaults._();

  /// The category ID used for tasks with no matching prefix.
  static const String inboxCategoryId = 'Miscellaneous';
  static const String inboxCategoryName = 'Miscellaneous';
  static const String inboxIconKey = 'inbox';

  /// Default shortcut mappings: (prefix, categoryName, colorValue, iconKey).
  static const List<Map<String, dynamic>> defaultShortcuts = [
    {
      'prefix': 'K',
      'categoryName': 'Kitchen',
      'colorValue': 0xFF6E8EFB,
      'iconKey': 'kitchen',
    },
    {
      'prefix': 'S',
      'categoryName': 'Shopping',
      'colorValue': 0xFFA777E3,
      'iconKey': 'shopping',
    },
    {
      'prefix': 'W',
      'categoryName': 'Work',
      'colorValue': 0xFF60A5FA,
      'iconKey': 'work',
    },
    {
      'prefix': 'L',
      'categoryName': 'Learn',
      'colorValue': 0xFFFBBF24,
      'iconKey': 'learn',
    },
  ];

  /// Hive box names.
  static const String tasksBoxName = 'tasks';
  static const String shortcutsBoxName = 'shortcuts';
  static const String settingsBoxName = 'settings';

  /// Settings keys.
  static const String isFirstLaunchKey = 'isFirstLaunch';
}
