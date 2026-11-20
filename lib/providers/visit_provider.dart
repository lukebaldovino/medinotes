import 'package:flutter/foundation.dart';
import '../models/visit.dart';
import '../repositories/visit_repository.dart';

class VisitProvider with ChangeNotifier {
  final VisitRepository _repository;

  List<Visit> _visits = [];
  int? _activeDoctorId;
  int _totalVisitsCount = 0;
  Visit? _latestVisit;
  bool _isLoading = false;
  String? _errorMessage;

  VisitProvider({VisitRepository? repository})
      : _repository = repository ?? SqliteVisitRepository();

  /// The visits for the most recent [loadVisits] call, scoped to [_activeDoctorId].
  List<Visit> get visits => _visits;

  /// The doctor the current [visits] list is filtered by, or null for all visits.
  int? get activeDoctorId => _activeDoctorId;

  /// Total consultations across all doctors, refreshed by every [loadVisits].
  /// Unlike [visits], this is never narrowed by the active doctor filter.
  int get totalVisitsCount => _totalVisitsCount;

  Visit? get latestVisit => _latestVisit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads consultations, optionally scoped to one doctor.
  ///
  /// A filtered load replaces [visits] with only that doctor's consultations.
  /// Widgets that show a global count must therefore call [loadVisits] without
  /// a [doctorId]; [totalVisitCount] stays authoritative either way.
  Future<void> loadVisits({int? doctorId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _visits = await _repository.getVisits(doctorId: doctorId);
      _activeDoctorId = doctorId;
      _totalVisitsCount = await _repository.getTotalVisitsCount();
      _latestVisit = await _repository.getLatestVisit();
    } catch (e) {
      _errorMessage = 'Failed to load consultation visits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes [totalVisitsCount] without disturbing the active doctor filter.
  Future<void> refreshTotalCount() async {
    _totalVisitsCount = await _repository.getTotalVisitsCount();
    notifyListeners();
  }

  Future<bool> createVisit(Visit visit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.insertVisit(visit);
      await loadVisits(doctorId: _activeDoctorId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to log visit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVisit(Visit visit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateVisit(visit);
      await loadVisits(doctorId: _activeDoctorId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update visit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVisit(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteVisit(id);
      await loadVisits(doctorId: _activeDoctorId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete visit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
