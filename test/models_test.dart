import 'package:flutter_test/flutter_test.dart';
import 'package:medinotes/core/storage/file_storage_service.dart';
import 'package:medinotes/models/doctor.dart';
import 'package:medinotes/models/medical_record.dart';
import 'package:medinotes/models/patient.dart';
import 'package:medinotes/models/record_category.dart';
import 'package:medinotes/models/visit.dart';

void main() {
  group('Domain Models & Serialization Tests', () {
    test('Patient toMap and fromMap works correctly', () {
      final patient = Patient(
        id: 1,
        fullName: 'John Doe',
        birthDate: '1990-05-15',
        sex: 'Male',
        bloodType: 'O+',
        contactNumber: '+63 912 345 6789',
        emergencyContact: 'Jane Doe (+63 912 987 6543)',
        allergies: 'Penicillin, Peanuts',
        createdAt: '2026-11-18T10:00:00Z',
        updatedAt: '2026-11-18T10:00:00Z',
      );

      final map = patient.toMap();
      final fromMap = Patient.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.fullName, 'John Doe');
      expect(fromMap.birthDate, '1990-05-15');
      expect(fromMap.sex, 'Male');
      expect(fromMap.bloodType, 'O+');
      expect(fromMap.allergies, 'Penicillin, Peanuts');
    });

    test('MedicalRecord toMap and fromMap works correctly', () {
      final record = MedicalRecord(
        id: 10,
        title: 'Routine Blood Chemistry',
        categoryId: 2,
        description: 'Normal cholesterol and blood sugar levels.',
        recordDate: '2026-11-10',
        doctorName: 'Dr. Maria Santos',
        facilityName: 'Metro Hospital',
        filePath: 'medical_records_files/blood_chem.pdf',
        fileType: 'pdf',
        createdAt: '2026-11-10T08:00:00Z',
        updatedAt: '2026-11-10T08:00:00Z',
        categoryName: 'Lab Results',
        categoryIcon: 'science',
      );

      final map = record.toMap();
      map['category_name'] = 'Lab Results';
      map['category_icon'] = 'science';

      final fromMap = MedicalRecord.fromMap(map);

      expect(fromMap.id, 10);
      expect(fromMap.title, 'Routine Blood Chemistry');
      expect(fromMap.categoryId, 2);
      expect(fromMap.hasAttachment, true);
      expect(fromMap.isPdf, true);
      expect(fromMap.isImage, false);
      expect(fromMap.categoryName, 'Lab Results');
    });

    test('Doctor toMap and fromMap works correctly', () {
      final doctor = Doctor(
        id: 5,
        fullName: 'Dr. Arthur Pendelton',
        specialty: 'Cardiology',
        clinicName: 'Heart Care Center',
        address: '45 Healthcare Ave',
        contactNumber: '+63 918 234 5678',
        description: 'Cardiologist',
        isFavorite: true,
      );

      final map = doctor.toMap();
      final fromMap = Doctor.fromMap(map);

      expect(fromMap.id, 5);
      expect(fromMap.fullName, 'Dr. Arthur Pendelton');
      expect(fromMap.specialty, 'Cardiology');
      expect(fromMap.isFavorite, true);
    });

    test('Visit toMap and fromMap works correctly', () {
      final visit = Visit(
        id: 3,
        doctorId: 1,
        visitDate: '2026-11-01',
        reason: 'Annual Checkup',
        diagnosis: 'Healthy, mild allergy symptoms',
        notes: 'Follow up in 6 months',
        createdAt: '2026-11-01T09:00:00Z',
        doctorName: 'Dr. Maria Santos',
      );

      final map = visit.toMap();
      map['doctor_name'] = 'Dr. Maria Santos';

      final fromMap = Visit.fromMap(map);

      expect(fromMap.id, 3);
      expect(fromMap.doctorId, 1);
      expect(fromMap.reason, 'Annual Checkup');
      expect(fromMap.doctorName, 'Dr. Maria Santos');
    });

    test('RecordCategory toMap and fromMap works correctly', () {
      final category = RecordCategory(id: 1, name: 'Prescriptions', icon: 'medication');
      final map = category.toMap();
      final fromMap = RecordCategory.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.name, 'Prescriptions');
      expect(fromMap.icon, 'medication');
    });

    test('MedicalRecord.copyWith keeps values when a nullable field is omitted', () {
      final record = MedicalRecord(
        title: 'Blood Panel',
        categoryId: 2,
        description: 'Normal',
        recordDate: '2026-01-01',
        doctorName: 'Dr. Santos',
        filePath: 'medical_records_files/a.pdf',
        fileType: 'pdf',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final updated = record.copyWith(title: 'Blood Panel v2');

      expect(updated.description, 'Normal');
      expect(updated.doctorName, 'Dr. Santos');
      expect(updated.filePath, 'medical_records_files/a.pdf');
    });

    test('MedicalRecord.copyWith clears nullable fields via explicit flags', () {
      final record = MedicalRecord(
        title: 'Blood Panel',
        categoryId: 2,
        description: 'Normal',
        recordDate: '2026-01-01',
        doctorName: 'Dr. Santos',
        facilityName: 'Metro Hospital',
        filePath: 'medical_records_files/a.pdf',
        fileType: 'pdf',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final cleared = record.copyWith(
        clearDescription: true,
        clearDoctorName: true,
        clearFacilityName: true,
        clearFilePath: true,
        clearFileType: true,
      );

      expect(cleared.description, isNull);
      expect(cleared.doctorName, isNull);
      expect(cleared.facilityName, isNull);
      expect(cleared.filePath, isNull);
      expect(cleared.fileType, isNull);
      expect(cleared.hasAttachment, false);
    });

    test('Patient.copyWith clears nullable fields via explicit flags', () {
      final patient = Patient(
        fullName: 'Jane Doe',
        birthDate: '1990-01-01',
        sex: 'Female',
        bloodType: 'O+',
        allergies: 'Penicillin',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final cleared = patient.copyWith(clearBloodType: true, clearAllergies: true);
      expect(cleared.bloodType, isNull);
      expect(cleared.allergies, isNull);
      expect(cleared.fullName, 'Jane Doe');
    });

    test('Visit.copyWith can detach the doctor and drop joined fields', () {
      final visit = Visit(
        doctorId: 4,
        visitDate: '2026-01-01',
        reason: 'Checkup',
        diagnosis: 'Healthy',
        createdAt: '2026-01-01T00:00:00Z',
        doctorName: 'Dr. Lim',
        doctorSpecialty: 'Orthopedics',
        clinicName: 'Bone Center',
      );

      final detached = visit.copyWith(clearDoctorId: true, clearDiagnosis: true);

      expect(detached.doctorId, isNull);
      expect(detached.diagnosis, isNull);
      expect(detached.doctorName, isNull);
      expect(detached.doctorSpecialty, isNull);
      expect(detached.clinicName, isNull);
      expect(detached.reason, 'Checkup');
    });

    test('Doctor.copyWith can clear description without touching favorites', () {
      final doctor = Doctor(
        fullName: 'Dr. Cruz',
        specialty: 'ENT',
        clinicName: 'ENT Specialists',
        address: 'Suite 310',
        contactNumber: '+63 929 890 1234',
        description: 'Otolaryngologist',
        isFavorite: true,
      );

      final cleared = doctor.copyWith(clearDescription: true);

      expect(cleared.description, isNull);
      expect(cleared.isFavorite, true);
      expect(cleared.fullName, 'Dr. Cruz');
    });

    test('FileStorageService.formatBytes formats correctly', () {
      expect(FileStorageService.formatBytes(0), '0 B');
      expect(FileStorageService.formatBytes(500), '500 B');
      expect(FileStorageService.formatBytes(1024), '1.0 KB');
      expect(FileStorageService.formatBytes(1536), '1.5 KB');
      expect(FileStorageService.formatBytes(1048576), '1.0 MB');
      expect(FileStorageService.formatBytes(2621440), '2.5 MB');
    });
  });
}
