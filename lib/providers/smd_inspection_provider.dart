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
      // Clear old inspections immediately to prevent showing stale data
      _inspections = [];
      _totalInspections = 0;
      notifyListeners();

      print('🔄 Starting to load inspections...');

      // Get saved location for INSPECTIONS page (includes district, block, and GP)
      // Fallback to old inspection location for backward compatibility
      var savedLocation = await _authService.getPageLocation('smd', 'inspections');
      savedLocation ??= await _authService.getInspectionLocation('smd');
      
      // Get district ID from saved location, fallback to old storage method
      int? districtId;
      if (savedLocation != null && savedLocation['districtId'] != null) {
        districtId = savedLocation['districtId'] as int?;
        print('📍 Using district ID from saved INSPECTIONS page location: $districtId');
      } else {
        // Fallback to old storage method for backward compatibility
        districtId = await _authService.getSmdSelectedDistrictId();
        print('📍 Using district ID from old storage method: $districtId');
      }
      
      if (districtId == null) {
        _isLoading = false;
        notifyListeners();
        print('❌ Error: District ID not found');
        return;
      }
      
      final blockId = savedLocation?['blockId'] as int?;
      final gpId = savedLocation?['gpId'] as int?;

      print('📡 SMD Inspection Provider Parameters:');
      print('   - District ID: $districtId');
      if (blockId != null) print('   - Block ID: $blockId');
      if (gpId != null) print('   - GP ID: $gpId');
      print('   - Saved Location Full: $savedLocation');
      print('   - Block ID from saved: ${savedLocation?['blockId']}');
      print('   - GP ID from saved: ${savedLocation?['gpId']}');
      print('   - Block Name from saved: ${savedLocation?['blockName']}');
      print('   - GP Name from saved: ${savedLocation?['gpName']}');

      final inspectionResponse = await _apiService.getInspections(
        districtId: districtId,
        blockId: blockId,
        gpId: gpId,
        page: page,
        pageSize: pageSize,
      );

      // Apply client-side filtering if GP ID is specified
      // This ensures we only show inspections for the selected GP, even if API returns wrong data
      List<Inspection> filteredInspections = inspectionResponse.items;
      if (gpId != null) {
        final beforeCount = filteredInspections.length;
        filteredInspections = filteredInspections.where((inspection) => inspection.villageId == gpId).toList();
        final afterCount = filteredInspections.length;
        if (beforeCount != afterCount) {
          print('⚠️ API returned $beforeCount inspections, but only $afterCount match GP ID $gpId');
          print('   Filtered out ${beforeCount - afterCount} inspections that don\'t match the selected GP');
        }
      }
      
      _inspections = filteredInspections;
      _totalInspections = filteredInspections.length; // Use filtered count
      
      print('📊 Loaded inspections (after filtering):');
      for (var inspection in _inspections) {
        print('   - ID: ${inspection.id}, Village: ${inspection.villageName}, GP ID: ${inspection.villageId}');
      }
      
      if (_inspections.isEmpty && gpId != null) {
        print('ℹ️ No inspections found for GP ID: $gpId');
      }

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

  Future<void> loadInspectionsForGp({required int gpId, int page = 1, int pageSize = 20}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final districtId = await _authService.getSmdSelectedDistrictId();

      final inspectionResponse = await _apiService.getInspections(
        districtId: districtId,
        gpId: gpId,
        page: page,
        pageSize: pageSize,
      );

      _inspections = inspectionResponse.items;
      _totalInspections = inspectionResponse.total;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('❌ Error loading GP inspections: $e');
    }
  }

  // Update current month
  void updateCurrentMonth(String month) {
    _currentMonth = month;
    notifyListeners();
  }
}
