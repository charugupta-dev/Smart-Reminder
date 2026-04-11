/// Pure domain entity for a task.
/// No framework dependencies — this is the core business object.
class TaskEntity {
  final String id;
  final String title;
  final String rawInput;
  final String categoryId;
  final String categoryName;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int sortOrder;

  const TaskEntity({
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

  TaskEntity copyWith({
    String? id,
    String? title,
    String? rawInput,
    String? categoryId,
    String? categoryName,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? sortOrder,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      rawInput: rawInput ?? this.rawInput,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
