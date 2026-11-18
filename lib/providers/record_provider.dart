import 'package:flutter/foundation.dart';
import '../models/medical_record.dart';
import '../models/record_category.dart';
import '../repositories/medical_record_repository.dart';

class RecordProvider with ChangeNotifier {
  final MedicalRecordRepository _repository;

  List<RecordCategory> _categories = [];
  List<MedicalRecord> _records = [];
  List<MedicalRecord> _recentRecords = [];
  int _totalRecordsCount = 0;

  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  RecordProvider({MedicalRecordRepository? repository})
      : _repository = repository ?? SqliteMedicalRecordRepository();

  List<RecordCategory> get categories => _categories;
  List<MedicalRecord> get records => _records;
  List<MedicalRecord> get recentRecords => _recentRecords;
  int get totalRecordsCount => _totalRecordsCount;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await loadCategories();
    await loadRecords();
    await loadDashboardMetrics();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      notifyListeners();
    }
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _repository.getRecords(
        searchQuery: _searchQuery,
        categoryId: _selectedCategoryId,
      );
      _totalRecordsCount = await _repository.getTotalRecordsCount();
    } catch (e) {
      _errorMessage = 'Failed to load medical records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardMetrics() async {
    try {
      _recentRecords = await _repository.getRecentRecords(limit: 3);
      _totalRecordsCount = await _repository.getTotalRecordsCount();
      notifyListeners();
    } catch (e) {
      // Non-blocking dashboard load
    }
  }

  void setCategoryFilter(int? categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null; // Toggle off if already selected
    } else {
      _selectedCategoryId = categoryId;
    }
    loadRecords();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadRecords();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    loadRecords();
  }

  Future<bool> createRecord(MedicalRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.insertRecord(record);
      await loadRecords();
      await loadDashboardMetrics();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add medical record: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecord(MedicalRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateRecord(record);
      await loadRecords();
      await loadDashboardMetrics();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update medical record: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecord(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteRecord(id);
      await loadRecords();
      await loadDashboardMetrics();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete medical record: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
