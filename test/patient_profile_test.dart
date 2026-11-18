import 'package:flutter_test/flutter_test.dart';
import 'package:medinotes/models/patient.dart';
import 'package:medinotes/providers/patient_provider.dart';
import 'package:medinotes/repositories/patient_repository.dart';

class FakePatientRepository implements PatientRepository {
  Patient? _current;

  @override
  Future<Patient?> getPatient() async => _current;

  @override
  Future<bool> hasProfile() async => _current != null;

  @override
  Future<Patient> savePatient(Patient patient) async {
    _current = patient.copyWith(id: 1);
    return _current!;
  }
}

void main() {
  group('PatientProvider Unit Tests', () {
    late FakePatientRepository fakeRepo;
    late PatientProvider provider;

    setUp(() {
      fakeRepo = FakePatientRepository();
      provider = PatientProvider(repository: fakeRepo);
    });

    test('Initial state has no profile', () async {
      await provider.loadProfile();
      expect(provider.hasProfile, false);
      expect(provider.patient, isNull);
      expect(provider.initials, '?');
      expect(provider.age, isNull);
    });

    test('Save profile updates state and computes initials & age correctly', () async {
      final patient = Patient(
        fullName: 'Maria Clara',
        birthDate: '2000-01-01',
        sex: 'Female',
        bloodType: 'A+',
        contactNumber: '+63 917 111 2222',
        allergies: 'Penicillin',
        createdAt: '2026-11-18T00:00:00Z',
        updatedAt: '2026-11-18T00:00:00Z',
      );

      final success = await provider.saveProfile(patient);

      expect(success, true);
      expect(provider.hasProfile, true);
      expect(provider.patient?.fullName, 'Maria Clara');
      expect(provider.initials, 'MC');
      expect(provider.age, isNotNull);
      expect(provider.age! >= 26, true);
    });

    test('Reloading loads saved patient profile', () async {
      final patient = Patient(
        fullName: 'Juan Luna',
        birthDate: '1995-10-15',
        sex: 'Male',
        bloodType: 'O+',
        createdAt: '2026-11-18T00:00:00Z',
        updatedAt: '2026-11-18T00:00:00Z',
      );

      await fakeRepo.savePatient(patient);
      await provider.loadProfile();

      expect(provider.hasProfile, true);
      expect(provider.patient?.fullName, 'Juan Luna');
      expect(provider.initials, 'JL');
    });
  });
}
