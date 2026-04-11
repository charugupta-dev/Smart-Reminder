/// Pure domain entity for a shortcut/category mapping.
/// No framework dependencies — this is the core business object.
class ShortcutEntity {
  final String id;
  final String prefix;
  final String categoryName;
  final int colorValue;
  final String iconKey;
  final DateTime createdAt;

  const ShortcutEntity({
    required this.id,
    required this.prefix,
    required this.categoryName,
    required this.colorValue,
    required this.iconKey,
    required this.createdAt,
  });

  ShortcutEntity copyWith({
    String? id,
    String? prefix,
    String? categoryName,
    int? colorValue,
    String? iconKey,
    DateTime? createdAt,
  }) {
    return ShortcutEntity(
      id: id ?? this.id,
      prefix: prefix ?? this.prefix,
      categoryName: categoryName ?? this.categoryName,
      colorValue: colorValue ?? this.colorValue,
      iconKey: iconKey ?? this.iconKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortcutEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
