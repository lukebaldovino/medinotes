import 'package:flutter_test/flutter_test.dart';
import 'package:medinotes/models/doctor.dart';
import 'package:medinotes/providers/doctor_provider.dart';
import 'package:medinotes/repositories/doctor_repository.dart';

class FakeDoctorRepository implements DoctorRepository {
  final List<Doctor> _doctors = [
    Doctor(
      id: 1,
      fullName: 'Dr. Maria Santos, MD',
      specialty: 'General Medicine',
      clinicName: 'St. Luke Family Care Clinic',
      address: 'Suite 302, Medical Arts Bldg',
      contactNumber: '+63 917 123 4567',
      isFavorite: true,
    ),
    Doctor(
      id: 2,
      fullName: 'Dr. Arthur Pendelton, MD',
      specialty: 'Cardiology',
      clinicName: 'Heart & Vascular Care Center',
      address: 'Room 512, Heart Institute',
      contactNumber: '+63 918 234 5678',
      isFavorite: false,
    ),
    Doctor(
      id: 3,
      fullName: 'Dr. Elena Reyes, MD',
      specialty: 'Pediatrics',
      clinicName: 'Children Wellness Hub',
      address: 'City Children Hospital',
      contactNumber: '+63 920 345 6789',
      isFavorite: false,
    ),
  ];

  @override
  Future<List<Doctor>> getDoctors({String? searchQuery, String? specialty}) async {
    var list = List<Doctor>.from(_doctors);
    if (specialty != null && specialty != 'All') {
      list = list.where((d) => d.specialty == specialty).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((d) => d.fullName.toLowerCase().contains(q) || d.clinicName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Future<Doctor?> getDoctorById(int id) async {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getSpecialties() async {
    return ['All', 'General Medicine', 'Cardiology', 'Pediatrics'];
  }

  @override
  Future<void> toggleFavorite(int doctorId, bool isFavorite) async {
    final idx = _doctors.indexWhere((d) => d.id == doctorId);
    if (idx != -1) {
      _doctors[idx] = _doctors[idx].copyWith(isFavorite: isFavorite);
    }
  }
}

void main() {
  group('DoctorProvider & Directory Tests', () {
    late FakeDoctorRepository fakeRepo;
    late DoctorProvider provider;

    setUp(() async {
      fakeRepo = FakeDoctorRepository();
      provider = DoctorProvider(repository: fakeRepo);
      await provider.initialize();
    });

    test('Initial state loads all seeded doctors and specialties', () {
      expect(provider.doctors.length, 3);
      expect(provider.specialties.contains('Cardiology'), true);
      expect(provider.selectedSpecialty, 'All');
    });

    test('Filter doctors by specialty', () async {
      provider.setSpecialty('Cardiology');
      await pumpEventQueue();

      expect(provider.doctors.length, 1);
      expect(provider.doctors.first.fullName, 'Dr. Arthur Pendelton, MD');
    });

    test('Search doctors by name and clinic', () async {
      provider.setSearchQuery('Maria');
      await pumpEventQueue();

      expect(provider.doctors.length, 1);
      expect(provider.doctors.first.specialty, 'General Medicine');

      provider.setSearchQuery('Children Wellness');
      await pumpEventQueue();

      expect(provider.doctors.length, 1);
      expect(provider.doctors.first.fullName, 'Dr. Elena Reyes, MD');
    });

    test('Toggle doctor favorite status', () async {
      final doctor = provider.doctors.firstWhere((d) => d.id == 2);
      expect(doctor.isFavorite, false);

      await provider.toggleFavorite(doctor);

      final updated = provider.doctors.firstWhere((d) => d.id == 2);
      expect(updated.isFavorite, true);
    });
  });
}
