import '../core/database/database_tables.dart';

class RecordCategory {
  final int id;
  final String name;
  final String icon;

  const RecordCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colCategoryId: id,
      DatabaseTables.colCategoryName: name,
      DatabaseTables.colCategoryIcon: icon,
    };
  }

  factory RecordCategory.fromMap(Map<String, dynamic> map) {
    return RecordCategory(
      id: map[DatabaseTables.colCategoryId] as int,
      name: map[DatabaseTables.colCategoryName] as String? ?? '',
      icon: map[DatabaseTables.colCategoryIcon] as String? ?? 'folder',
    );
  }
}
