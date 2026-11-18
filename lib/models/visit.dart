import '../core/database/database_tables.dart';

class Visit {
  final int? id;
  final int? doctorId;
  final String visitDate; // ISO-8601 YYYY-MM-DD
  final String reason;
  final String? diagnosis;
  final String? notes;
  final String createdAt;

  // Joined doctor details (optional)
  final String? doctorName;
  final String? doctorSpecialty;
  final String? clinicName;

  Visit({
    this.id,
    this.doctorId,
    required this.visitDate,
    required this.reason,
    this.diagnosis,
    this.notes,
    required this.createdAt,
    this.doctorName,
    this.doctorSpecialty,
    this.clinicName,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseTables.colVisitId: id,
      DatabaseTables.colVisitDoctorId: doctorId,
      DatabaseTables.colVisitDate: visitDate,
      DatabaseTables.colVisitReason: reason,
      DatabaseTables.colVisitDiagnosis: diagnosis,
      DatabaseTables.colVisitNotes: notes,
      DatabaseTables.colVisitCreatedAt: createdAt,
    };
  }

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map[DatabaseTables.colVisitId] as int?,
      doctorId: map[DatabaseTables.colVisitDoctorId] as int?,
      visitDate: map[DatabaseTables.colVisitDate] as String? ?? '',
      reason: map[DatabaseTables.colVisitReason] as String? ?? '',
      diagnosis: map[DatabaseTables.colVisitDiagnosis] as String?,
      notes: map[DatabaseTables.colVisitNotes] as String?,
      createdAt: map[DatabaseTables.colVisitCreatedAt] as String? ?? '',
      doctorName: map['doctor_name'] as String?,
      doctorSpecialty: map['doctor_specialty'] as String?,
      clinicName: map['clinic_name'] as String?,
    );
  }

  Visit copyWith({
    int? id,
    int? doctorId,
    String? visitDate,
    String? reason,
    String? diagnosis,
    String? notes,
    String? createdAt,
    String? doctorName,
    String? doctorSpecialty,
    String? clinicName,
  }) {
    return Visit(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      visitDate: visitDate ?? this.visitDate,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      clinicName: clinicName ?? this.clinicName,
    );
  }
}
