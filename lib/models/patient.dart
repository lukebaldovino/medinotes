import '../core/database/database_tables.dart';

class Patient {
  final int? id;
  final String fullName;
  final String birthDate; // ISO-8601 YYYY-MM-DD
  final String sex;
  final String? bloodType;
  final String? contactNumber;
  final String? emergencyContact;
  final String? allergies;
  final String createdAt;
  final String updatedAt;

  Patient({
    this.id,
    required this.fullName,
    required this.birthDate,
    required this.sex,
    this.bloodType,
    this.contactNumber,
    this.emergencyContact,
    this.allergies,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseTables.colPatientId: id,
      DatabaseTables.colPatientFullName: fullName,
      DatabaseTables.colPatientBirthDate: birthDate,
      DatabaseTables.colPatientSex: sex,
      DatabaseTables.colPatientBloodType: bloodType,
      DatabaseTables.colPatientContactNumber: contactNumber,
      DatabaseTables.colPatientEmergencyContact: emergencyContact,
      DatabaseTables.colPatientAllergies: allergies,
      DatabaseTables.colPatientCreatedAt: createdAt,
      DatabaseTables.colPatientUpdatedAt: updatedAt,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map[DatabaseTables.colPatientId] as int?,
      fullName: map[DatabaseTables.colPatientFullName] as String? ?? '',
      birthDate: map[DatabaseTables.colPatientBirthDate] as String? ?? '',
      sex: map[DatabaseTables.colPatientSex] as String? ?? '',
      bloodType: map[DatabaseTables.colPatientBloodType] as String?,
      contactNumber: map[DatabaseTables.colPatientContactNumber] as String?,
      emergencyContact: map[DatabaseTables.colPatientEmergencyContact] as String?,
      allergies: map[DatabaseTables.colPatientAllergies] as String?,
      createdAt: map[DatabaseTables.colPatientCreatedAt] as String? ?? '',
      updatedAt: map[DatabaseTables.colPatientUpdatedAt] as String? ?? '',
    );
  }

  Patient copyWith({
    int? id,
    String? fullName,
    String? birthDate,
    String? sex,
    String? bloodType,
    String? contactNumber,
    String? emergencyContact,
    String? allergies,
    String? createdAt,
    String? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      bloodType: bloodType ?? this.bloodType,
      contactNumber: contactNumber ?? this.contactNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
