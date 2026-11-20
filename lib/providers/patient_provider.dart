import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../repositories/patient_repository.dart';

class PatientProvider with ChangeNotifier {
  final PatientRepository _repository;

  Patient? _patient;
  bool _isLoading = false;
  String? _errorMessage;

  PatientProvider({PatientRepository? repository})
      : _repository = repository ?? SqlitePatientRepository();

  Patient? get patient => _patient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _patient != null;

  /// Returns calculated age in years from birthDate (YYYY-MM-DD), or null if invalid or in the future.
  int? get age {
    if (_patient == null || _patient!.birthDate.isEmpty) return null;
    try {
      final dob = DateTime.parse(_patient!.birthDate);
      final today = DateTime.now();
      if (dob.isAfter(today)) return null;
      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age < 0 ? null : age;
    } catch (_) {
      return null;
    }
  }

  /// Returns user initials for avatar.
  String get initials {
    if (_patient == null || _patient!.fullName.trim().isEmpty) return '?';
    final clean = _patient!.fullName
        .replaceAll(RegExp(r'^(Dr\.|Dra\.|Mr\.|Mrs\.|Ms\.|Atty\.|Prof\.)\s*', caseSensitive: false), '')
        .trim();
    if (clean.isEmpty) return '?';
    final parts = clean.split(RegExp(r'\s+'));
    final validParts = parts.where((p) => p.isNotEmpty).toList();
    if (validParts.length >= 2 && validParts[0].isNotEmpty && validParts[1].isNotEmpty) {
      return '${validParts[0][0]}${validParts[1][0]}'.toUpperCase();
    }
    if (validParts.isNotEmpty && validParts[0].isNotEmpty) {
      return validParts[0][0].toUpperCase();
    }
    return '?';
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patient = await _repository.getPatient();
    } catch (e) {
      _errorMessage = 'Failed to load patient profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(Patient patient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patient = await _repository.savePatient(patient);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save patient profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
