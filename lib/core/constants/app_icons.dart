import 'package:flutter/material.dart';

/// Standard icons that can be assigned to categories.
class AppIcons {
  AppIcons._();

  /// Map of icon name to IconData for category assignment.
  static const Map<String, IconData> categoryIcons = {
    'kitchen': Icons.kitchen_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'work': Icons.work_rounded,
    'learn': Icons.school_rounded,
    'health': Icons.favorite_rounded,
    'finance': Icons.account_balance_wallet_rounded,
    'home': Icons.home_rounded,
    'travel': Icons.flight_rounded,
    'fitness': Icons.fitness_center_rounded,
    'food': Icons.restaurant_rounded,
    'music': Icons.music_note_rounded,
    'phone': Icons.phone_rounded,
    'email': Icons.email_rounded,
    'calendar': Icons.calendar_today_rounded,
    'star': Icons.star_rounded,
    'inbox': Icons.inbox_rounded,
  };

  /// List of icon keys for selection UI.
  static List<String> get iconKeys => categoryIcons.keys.toList();

  /// Get an IconData by its key, with fallback.
  static IconData getIcon(String key) {
    return categoryIcons[key] ?? Icons.label_rounded;
  }
}
