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

  /// Returns a copy with the given fields replaced.
  ///
  /// Nullable fields are cleared by passing [clearDoctorId], [clearDiagnosis] or
  /// [clearNotes]; passing `null` for the corresponding value argument keeps the
  /// current value. Clearing [doctorId] detaches the visit from its doctor, and
  /// the joined doctor fields are dropped with it.
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
    bool clearDoctorId = false,
    bool clearDiagnosis = false,
    bool clearNotes = false,
  }) {
    return Visit(
      id: id ?? this.id,
      doctorId: clearDoctorId ? null : doctorId ?? this.doctorId,
      visitDate: visitDate ?? this.visitDate,
      reason: reason ?? this.reason,
      diagnosis: clearDiagnosis ? null : diagnosis ?? this.diagnosis,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      doctorName: clearDoctorId ? null : doctorName ?? this.doctorName,
      doctorSpecialty: clearDoctorId ? null : doctorSpecialty ?? this.doctorSpecialty,
      clinicName: clearDoctorId ? null : clinicName ?? this.clinicName,
    );
  }
}
