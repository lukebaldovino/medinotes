import '../core/database/database_tables.dart';

class MedicalRecord {
  final int? id;
  final String title;
  final int categoryId;
  final String? description;
  final String recordDate; // ISO-8601 YYYY-MM-DD
  final String? doctorName;
  final String? facilityName;
  final String? filePath; // Relative path in app documents directory
  final String? fileType; // 'pdf', 'image'
  final String createdAt;
  final String updatedAt;

  // Joined metadata (optional)
  final String? categoryName;
  final String? categoryIcon;

  MedicalRecord({
    this.id,
    required this.title,
    required this.categoryId,
    this.description,
    required this.recordDate,
    this.doctorName,
    this.facilityName,
    this.filePath,
    this.fileType,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryIcon,
  });

  bool get hasAttachment => filePath != null && filePath!.trim().isNotEmpty;
  bool get isPdf => fileType?.toLowerCase() == 'pdf';
  bool get isImage =>
      fileType?.toLowerCase() == 'image' ||
      fileType?.toLowerCase() == 'jpg' ||
      fileType?.toLowerCase() == 'png' ||
      fileType?.toLowerCase() == 'jpeg';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseTables.colRecordId: id,
      DatabaseTables.colRecordTitle: title,
      DatabaseTables.colRecordCategoryId: categoryId,
      DatabaseTables.colRecordDescription: description,
      DatabaseTables.colRecordDate: recordDate,
      DatabaseTables.colRecordDoctorName: doctorName,
      DatabaseTables.colRecordFacilityName: facilityName,
      DatabaseTables.colRecordFilePath: filePath,
      DatabaseTables.colRecordFileType: fileType,
      DatabaseTables.colRecordCreatedAt: createdAt,
      DatabaseTables.colRecordUpdatedAt: updatedAt,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map[DatabaseTables.colRecordId] as int?,
      title: map[DatabaseTables.colRecordTitle] as String? ?? '',
      categoryId: map[DatabaseTables.colRecordCategoryId] as int? ?? 1,
      description: map[DatabaseTables.colRecordDescription] as String?,
      recordDate: map[DatabaseTables.colRecordDate] as String? ?? '',
      doctorName: map[DatabaseTables.colRecordDoctorName] as String?,
      facilityName: map[DatabaseTables.colRecordFacilityName] as String?,
      filePath: map[DatabaseTables.colRecordFilePath] as String?,
      fileType: map[DatabaseTables.colRecordFileType] as String?,
      createdAt: map[DatabaseTables.colRecordCreatedAt] as String? ?? '',
      updatedAt: map[DatabaseTables.colRecordUpdatedAt] as String? ?? '',
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
    );
  }

  MedicalRecord copyWith({
    int? id,
    String? title,
    int? categoryId,
    String? description,
    String? recordDate,
    String? doctorName,
    String? facilityName,
    String? filePath,
    String? fileType,
    String? createdAt,
    String? updatedAt,
    String? categoryName,
    String? categoryIcon,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      doctorName: doctorName ?? this.doctorName,
      facilityName: facilityName ?? this.facilityName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}
