import 'package:flutter_test/flutter_test.dart';
import 'package:medinotes/models/visit.dart';
import 'package:medinotes/providers/visit_provider.dart';
import 'package:medinotes/repositories/visit_repository.dart';

class FakeVisitRepository implements VisitRepository {
  final List<Visit> _visits = [];

  @override
  Future<List<Visit>> getVisits({int? doctorId}) async {
    var list = List<Visit>.from(_visits);
    if (doctorId != null) {
      list = list.where((v) => v.doctorId == doctorId).toList();
    }
    list.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    return list;
  }

  @override
  Future<Visit?> getVisitById(int id) async {
    try {
      return _visits.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertVisit(Visit visit) async {
    final newId = _visits.length + 1;
    final toAdd = visit.copyWith(id: newId);
    _visits.add(toAdd);
    return newId;
  }

  @override
  Future<int> updateVisit(Visit visit) async {
    final idx = _visits.indexWhere((v) => v.id == visit.id);
    if (idx != -1) {
      _visits[idx] = visit;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteVisit(int id) async {
    final count = _visits.where((v) => v.id == id).length;
    _visits.removeWhere((v) => v.id == id);
    return count;
  }

  @override
  Future<Visit?> getLatestVisit() async {
    final list = await getVisits();
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<int> getTotalVisitsCount() async => _visits.length;
}

void main() {
  group('VisitProvider & Consultation History Tests', () {
    late FakeVisitRepository fakeRepo;
    late VisitProvider provider;

    setUp(() async {
      fakeRepo = FakeVisitRepository();
      provider = VisitProvider(repository: fakeRepo);
      await provider.loadVisits();
    });

    test('Initial visits list is empty', () {
      expect(provider.visits.isEmpty, true);
      expect(provider.latestVisit, isNull);
    });

    test('Log consultations and verify chronological ordering', () async {
      await provider.createVisit(Visit(
        visitDate: '2026-02-10',
        reason: 'Flu symptoms',
        diagnosis: 'Viral infection',
        createdAt: '2026-02-10T00:00:00Z',
      ));

      await provider.createVisit(Visit(
        visitDate: '2026-05-15',
        reason: 'Follow-up BP Check',
        diagnosis: 'Blood pressure normal',
        createdAt: '2026-05-15T00:00:00Z',
      ));

      expect(provider.visits.length, 2);
      expect(provider.visits[0].reason, 'Follow-up BP Check');
      expect(provider.visits[1].reason, 'Flu symptoms');
      expect(provider.latestVisit?.reason, 'Follow-up BP Check');
    });

    test('Filter visits by doctorId', () async {
      await provider.createVisit(Visit(
        doctorId: 1,
        visitDate: '2026-01-01',
        reason: 'Heart Consultation',
        createdAt: '2026-01-01T00:00:00Z',
      ));
      await provider.createVisit(Visit(
        doctorId: 2,
        visitDate: '2026-01-02',
        reason: 'Skin Checkup',
        createdAt: '2026-01-02T00:00:00Z',
      ));

      await provider.loadVisits(doctorId: 1);
      expect(provider.visits.length, 1);
      expect(provider.visits.first.reason, 'Heart Consultation');
    });

    test('totalVisitCount stays global when the active list is doctor-filtered', () async {
      await provider.createVisit(Visit(
        doctorId: 1,
        visitDate: '2026-01-01',
        reason: 'Heart Consultation',
        createdAt: '2026-01-01T00:00:00Z',
      ));
      await provider.createVisit(Visit(
        doctorId: 2,
        visitDate: '2026-01-02',
        reason: 'Skin Checkup',
        createdAt: '2026-01-02T00:00:00Z',
      ));

      // Filtering to one doctor narrows `visits`, and that filtered state must
      // not leak into the global count shown on the dashboard.
      await provider.loadVisits(doctorId: 1);
      expect(provider.visits.length, 1);
      expect(provider.activeDoctorId, 1);
      expect(provider.totalVisitsCount, 2);
    });

    test('Mutations preserve the active doctor filter', () async {
      await provider.createVisit(Visit(
        doctorId: 1,
        visitDate: '2026-01-01',
        reason: 'Heart Consultation',
        createdAt: '2026-01-01T00:00:00Z',
      ));
      await provider.createVisit(Visit(
        doctorId: 2,
        visitDate: '2026-01-02',
        reason: 'Skin Checkup',
        createdAt: '2026-01-02T00:00:00Z',
      ));

      await provider.loadVisits(doctorId: 2);
      expect(provider.visits.length, 1);

      // Deleting from the filtered view must not widen the list back to all doctors.
      await provider.deleteVisit(provider.visits.first.id!);
      expect(provider.activeDoctorId, 2);
      expect(provider.visits.isEmpty, true);
      expect(provider.totalVisitsCount, 1);
    });

    test('Delete visit updates list and latestVisit', () async {
      await provider.createVisit(Visit(
        visitDate: '2026-01-01',
        reason: 'Visit to delete',
        createdAt: '2026-01-01T00:00:00Z',
      ));
      expect(provider.visits.length, 1);

      final id = provider.visits.first.id!;
      final deleted = await provider.deleteVisit(id);

      expect(deleted, true);
      expect(provider.visits.isEmpty, true);
      expect(provider.latestVisit, isNull);
    });
  });
}
