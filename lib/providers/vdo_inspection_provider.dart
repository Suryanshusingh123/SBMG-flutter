import 'package:flutter/material.dart';
import '../models/inspection_model.dart';
import '../services/api_services.dart';
import '../services/auth_services.dart';

class VdoInspectionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // State
  List<Inspection> _inspections = [];
  bool _isInspectionsLoading = true;
  int _totalInspections = 0;

  // Getters
  List<Inspection> get inspections => _inspections;
  bool get isInspectionsLoading => _isInspectionsLoading;
  int get totalInspections => _totalInspections;

  // Load inspections
  Future<void> loadInspections() async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 VDO INSPECTIONS: Loading Inspections');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _isInspectionsLoading = true;
      notifyListeners();

      // Get village_id from auth service
      final villageId = await _authService.getVillageId();
      print('🏘️ Village ID: $villageId');

      if (villageId == null) {
        print('❌ Village ID not found');
        _isInspectionsLoading = false;
        notifyListeners();
        return;
      }

      print('📡 Calling API service to fetch inspections');
      final inspectionResponse = await _apiService.getInspections(
        villageId: villageId,
        page: 1,
        pageSize: 20,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 VDO INSPECTIONS: Success');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Processing inspection data...');
      print('   - Total inspections: ${inspectionResponse.total}');
      print('   - Items received: ${inspectionResponse.items.length}');
      print('   - Page: ${inspectionResponse.page}');
      print('   - Page Size: ${inspectionResponse.pageSize}');
      print('   - Total Pages: ${inspectionResponse.totalPages}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      _inspections = inspectionResponse.items;
      _totalInspections = inspectionResponse.total;
      _isInspectionsLoading = false;
      notifyListeners();

      print('✅ Inspection data loaded successfully!');
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ VDO INSPECTIONS: Error');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Error: $e');
      print('💥 Error Type: ${e.runtimeType}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _isInspectionsLoading = false;
      notifyListeners();
    }
  }
}
