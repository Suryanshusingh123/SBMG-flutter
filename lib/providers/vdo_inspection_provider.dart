import 'package:flutter/material.dart';
import '../models/inspection_model.dart';
import '../services/api_services.dart';

class VdoInspectionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

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
      print('🔄 Starting to load inspections...');
      _isInspectionsLoading = true;
      notifyListeners();

      // For now, using village_id = 1 as per the API example
      print('📡 Calling API service to fetch inspections for village_id: 1');
      final inspectionResponse = await _apiService.getInspections(
        villageId: 1,
        page: 1,
        pageSize: 100,
      );

      print('📊 Processing inspection data...');
      print('   - Total inspections received: ${inspectionResponse.total}');
      print('   - Items in response: ${inspectionResponse.items.length}');

      _inspections = inspectionResponse.items;
      _totalInspections = inspectionResponse.total;
      _isInspectionsLoading = false;
      notifyListeners();

      print('✅ Inspection data loaded successfully!');
    } catch (e) {
      print('❌ Error loading inspections: $e');
      _isInspectionsLoading = false;
      notifyListeners();
    }
  }
}
