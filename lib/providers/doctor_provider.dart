import 'package:flutter/foundation.dart';
import '../models/doctor.dart';
import '../repositories/doctor_repository.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorRepository _repository;

  List<Doctor> _doctors = [];
  List<String> _specialties = ['All'];
  String _selectedSpecialty = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  DoctorProvider({DoctorRepository? repository})
      : _repository = repository ?? SqliteDoctorRepository();

  List<Doctor> get doctors => _doctors;
  List<String> get specialties => _specialties;
  String get selectedSpecialty => _selectedSpecialty;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await loadSpecialties();
    await loadDoctors();
  }

  Future<void> loadSpecialties() async {
    try {
      _specialties = await _repository.getSpecialties();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadDoctors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _doctors = await _repository.getDoctors(
        searchQuery: _searchQuery,
        specialty: _selectedSpecialty,
      );
    } catch (e) {
      _errorMessage = 'Failed to load doctors: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSpecialty(String specialty) {
    if (_selectedSpecialty == specialty) return;
    _selectedSpecialty = specialty;
    loadDoctors();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadDoctors();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedSpecialty = 'All';
    loadDoctors();
  }

  Future<void> toggleFavorite(Doctor doctor) async {
    if (doctor.id == null) return;
    final newFavorite = !doctor.isFavorite;

    // Optimistic UI update
    final index = _doctors.indexWhere((d) => d.id == doctor.id);
    if (index != -1) {
      _doctors[index] = doctor.copyWith(isFavorite: newFavorite);
      notifyListeners();
    }

    try {
      await _repository.toggleFavorite(doctor.id!, newFavorite);
      await loadDoctors();
    } catch (e) {
      _errorMessage = 'Failed to update favorite: $e';
      await loadDoctors();
    }
  }
}
