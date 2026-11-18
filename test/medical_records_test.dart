import 'package:flutter_test/flutter_test.dart';
import 'package:medinotes/models/medical_record.dart';
import 'package:medinotes/models/record_category.dart';
import 'package:medinotes/providers/record_provider.dart';
import 'package:medinotes/repositories/medical_record_repository.dart';

class FakeMedicalRecordRepository implements MedicalRecordRepository {
  final List<MedicalRecord> _records = [];
  final List<RecordCategory> _categories = [
    const RecordCategory(id: 1, name: 'Prescriptions', icon: 'medication'),
    const RecordCategory(id: 2, name: 'Lab Results', icon: 'science'),
    const RecordCategory(id: 3, name: 'Imaging & Scans', icon: 'image'),
  ];

  @override
  Future<List<RecordCategory>> getCategories() async => _categories;

  @override
  Future<List<MedicalRecord>> getRecords({String? searchQuery, int? categoryId}) async {
    var list = List<MedicalRecord>.from(_records);
    if (categoryId != null) {
      list = list.where((r) => r.categoryId == categoryId).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      list = list.where((r) => r.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    list.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    return list;
  }

  @override
  Future<MedicalRecord?> getRecordById(int id) async {
    try {
      return _records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertRecord(MedicalRecord record) async {
    final newId = _records.length + 1;
    final toAdd = record.copyWith(id: newId);
    _records.add(toAdd);
    return newId;
  }

  @override
  Future<int> updateRecord(MedicalRecord record) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _records[index] = record;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteRecord(int id) async {
    final count = _records.where((r) => r.id == id).length;
    _records.removeWhere((r) => r.id == id);
    return count;
  }

  @override
  Future<int> getTotalRecordsCount() async => _records.length;

  @override
  Future<List<MedicalRecord>> getRecentRecords({int limit = 3}) async {
    final list = List<MedicalRecord>.from(_records);
    list.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    return list.take(limit).toList();
  }
}

void main() {
  group('RecordProvider & Records Repository Tests', () {
    late FakeMedicalRecordRepository fakeRepo;
    late RecordProvider provider;

    setUp(() async {
      fakeRepo = FakeMedicalRecordRepository();
      provider = RecordProvider(repository: fakeRepo);
      await provider.initialize();
    });

    test('Initial state has categories loaded and empty records', () {
      expect(provider.categories.length, 3);
      expect(provider.records.isEmpty, true);
      expect(provider.totalRecordsCount, 0);
    });

    test('Create records and verify chronological ordering (newest first)', () async {
      await provider.createRecord(MedicalRecord(
        title: 'Old Blood Test',
        categoryId: 2,
        recordDate: '2026-01-10',
        createdAt: '2026-01-10T00:00:00Z',
        updatedAt: '2026-01-10T00:00:00Z',
      ));

      await provider.createRecord(MedicalRecord(
        title: 'Recent Chest X-Ray',
        categoryId: 3,
        recordDate: '2026-03-20',
        createdAt: '2026-03-20T00:00:00Z',
        updatedAt: '2026-03-20T00:00:00Z',
      ));

      await provider.createRecord(MedicalRecord(
        title: 'Mid Antibiotics Rx',
        categoryId: 1,
        recordDate: '2026-02-15',
        createdAt: '2026-02-15T00:00:00Z',
        updatedAt: '2026-02-15T00:00:00Z',
      ));

      expect(provider.records.length, 3);
      expect(provider.records[0].title, 'Recent Chest X-Ray');
      expect(provider.records[1].title, 'Mid Antibiotics Rx');
      expect(provider.records[2].title, 'Old Blood Test');
      expect(provider.totalRecordsCount, 3);
    });

    test('Filter records by category', () async {
      await provider.createRecord(MedicalRecord(
        title: 'Prescription 1',
        categoryId: 1,
        recordDate: '2026-01-01',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ));
      await provider.createRecord(MedicalRecord(
        title: 'Lab 1',
        categoryId: 2,
        recordDate: '2026-01-02',
        createdAt: '2026-01-02T00:00:00Z',
        updatedAt: '2026-01-02T00:00:00Z',
      ));

      provider.setCategoryFilter(1);
      await pumpEventQueue();

      expect(provider.records.length, 1);
      expect(provider.records.first.title, 'Prescription 1');

      // Toggle off filter
      provider.setCategoryFilter(1);
      await pumpEventQueue();
      expect(provider.records.length, 2);
    });

    test('Search records by title', () async {
      await provider.createRecord(MedicalRecord(
        title: 'Complete Blood Count',
        categoryId: 2,
        recordDate: '2026-01-01',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ));
      await provider.createRecord(MedicalRecord(
        title: 'Dental Checkup Prescription',
        categoryId: 1,
        recordDate: '2026-01-02',
        createdAt: '2026-01-02T00:00:00Z',
        updatedAt: '2026-01-02T00:00:00Z',
      ));

      provider.setSearchQuery('blood');
      await pumpEventQueue();

      expect(provider.records.length, 1);
      expect(provider.records.first.title, 'Complete Blood Count');
    });

    test('Delete record updates list and count', () async {
      await provider.createRecord(MedicalRecord(
        title: 'To Be Deleted',
        categoryId: 1,
        recordDate: '2026-01-01',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ));
      expect(provider.records.length, 1);

      final recordId = provider.records.first.id!;
      final deleted = await provider.deleteRecord(recordId);

      expect(deleted, true);
      expect(provider.records.isEmpty, true);
      expect(provider.totalRecordsCount, 0);
    });
  });
}
