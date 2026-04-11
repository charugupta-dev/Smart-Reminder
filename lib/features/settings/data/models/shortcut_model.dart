import '../../domain/entities/shortcut_entity.dart';

/// Hive-compatible data model for [ShortcutEntity].
/// Handles serialization to/from JSON maps for Hive storage.
class ShortcutModel {
  final String id;
  final String prefix;
  final String categoryName;
  final int colorValue;
  final String iconKey;
  final DateTime createdAt;

  const ShortcutModel({
    required this.id,
    required this.prefix,
    required this.categoryName,
    required this.colorValue,
    required this.iconKey,
    required this.createdAt,
  });

  /// Convert from domain entity.
  factory ShortcutModel.fromEntity(ShortcutEntity entity) {
    return ShortcutModel(
      id: entity.id,
      prefix: entity.prefix,
      categoryName: entity.categoryName,
      colorValue: entity.colorValue,
      iconKey: entity.iconKey,
      createdAt: entity.createdAt,
    );
  }

  /// Convert from Hive JSON map.
  factory ShortcutModel.fromJson(Map<dynamic, dynamic> json) {
    return ShortcutModel(
      id: json['id'] as String,
      prefix: json['prefix'] as String,
      categoryName: json['categoryName'] as String,
      colorValue: json['colorValue'] as int,
      iconKey: json['iconKey'] as String? ?? 'star',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to Hive JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prefix': prefix,
      'categoryName': categoryName,
      'colorValue': colorValue,
      'iconKey': iconKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to domain entity.
  ShortcutEntity toEntity() {
    return ShortcutEntity(
      id: id,
      prefix: prefix,
      categoryName: categoryName,
      colorValue: colorValue,
      iconKey: iconKey,
      createdAt: createdAt,
    );
  }
}
