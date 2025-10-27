import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/auth_services.dart';
import '../models/inspection_model.dart';

class SmdInspectionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  String _currentMonth = 'December';
  List<Inspection> _inspections = [];
  bool _isLoading = false;
  int _totalInspections = 0;

  // Getters
  String get currentMonth => _currentMonth;
  List<Inspection> get inspections => _inspections;
  bool get isLoading => _isLoading;
  int get totalInspections => _totalInspections;

  // Load inspections
  Future<void> loadInspections({int page = 1, int pageSize = 20}) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Starting to load inspections...');

      // Get location ID from auth service (SMD selected district)
      final districtId = await _authService.getSmdSelectedDistrictId();

      final inspectionResponse = await _apiService.getInspections(
        districtId: districtId,
        page: page,
        pageSize: pageSize,
      );

      _inspections = inspectionResponse.items;
      _totalInspections = inspectionResponse.total;

      _isLoading = false;
      notifyListeners();

      print(
        '✅ Loaded ${_inspections.length} inspections (total: $_totalInspections)',
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('❌ Error loading inspections: $e');
    }
  }

  // Update current month
  void updateCurrentMonth(String month) {
    _currentMonth = month;
    notifyListeners();
  }
}
