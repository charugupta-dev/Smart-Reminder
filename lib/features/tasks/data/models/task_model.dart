import '../../domain/entities/task_entity.dart';

/// Hive-compatible data model for [TaskEntity].
/// Handles serialization to/from JSON maps for Hive storage.
class TaskModel {
  final String id;
  final String title;
  final String rawInput;
  final String categoryId;
  final String categoryName;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int sortOrder;

  const TaskModel({
    required this.id,
    required this.title,
    required this.rawInput,
    required this.categoryId,
    required this.categoryName,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.sortOrder = 0,
  });

  /// Convert from domain entity.
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      rawInput: entity.rawInput,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      sortOrder: entity.sortOrder,
    );
  }

  /// Convert from Hive JSON map.
  factory TaskModel.fromJson(Map<dynamic, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      rawInput: json['rawInput'] as String? ?? '',
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// Convert to Hive JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rawInput': rawInput,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  /// Convert to domain entity.
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      rawInput: rawInput,
      categoryId: categoryId,
      categoryName: categoryName,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      sortOrder: sortOrder,
    );
  }
}
