import 'package:flutter/foundation.dart';
import '../models/visit.dart';
import '../repositories/visit_repository.dart';

class VisitProvider with ChangeNotifier {
  final VisitRepository _repository;

  List<Visit> _visits = [];
  Visit? _latestVisit;
  bool _isLoading = false;
  String? _errorMessage;

  VisitProvider({VisitRepository? repository})
      : _repository = repository ?? SqliteVisitRepository();

  List<Visit> get visits => _visits;
  Visit? get latestVisit => _latestVisit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVisits({int? doctorId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _visits = await _repository.getVisits(doctorId: doctorId);
      _latestVisit = await _repository.getLatestVisit();
    } catch (e) {
      _errorMessage = 'Failed to load consultation visits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createVisit(Visit visit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.insertVisit(visit);
      await loadVisits();
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
      await loadVisits();
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
      await loadVisits();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete visit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
