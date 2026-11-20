import '../core/database/database_tables.dart';

class Doctor {
  final int? id;
  final String fullName;
  final String specialty;
  final String clinicName;
  final String address;
  final String contactNumber;
  final String? description;
  final String? imagePath;
  final bool isFavorite;

  Doctor({
    this.id,
    required this.fullName,
    required this.specialty,
    required this.clinicName,
    required this.address,
    required this.contactNumber,
    this.description,
    this.imagePath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseTables.colDoctorId: id,
      DatabaseTables.colDoctorFullName: fullName,
      DatabaseTables.colDoctorSpecialty: specialty,
      DatabaseTables.colDoctorClinicName: clinicName,
      DatabaseTables.colDoctorAddress: address,
      DatabaseTables.colDoctorContactNumber: contactNumber,
      DatabaseTables.colDoctorDescription: description,
      DatabaseTables.colDoctorImagePath: imagePath,
      DatabaseTables.colDoctorIsFavorite: isFavorite ? 1 : 0,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map[DatabaseTables.colDoctorId] as int?,
      fullName: map[DatabaseTables.colDoctorFullName] as String? ?? '',
      specialty: map[DatabaseTables.colDoctorSpecialty] as String? ?? '',
      clinicName: map[DatabaseTables.colDoctorClinicName] as String? ?? '',
      address: map[DatabaseTables.colDoctorAddress] as String? ?? '',
      contactNumber: map[DatabaseTables.colDoctorContactNumber] as String? ?? '',
      description: map[DatabaseTables.colDoctorDescription] as String?,
      imagePath: map[DatabaseTables.colDoctorImagePath] as String?,
      isFavorite: map[DatabaseTables.colDoctorIsFavorite] == 1 ||
          map[DatabaseTables.colDoctorIsFavorite] == true,
    );
  }

  Doctor copyWith({
    int? id,
    String? fullName,
    String? specialty,
    String? clinicName,
    String? address,
    String? contactNumber,
    String? description,
    String? imagePath,
    bool? isFavorite,
  }) {
    return Doctor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
