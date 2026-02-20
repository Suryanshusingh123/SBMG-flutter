import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/auth_services.dart';
import '../models/inspection_model.dart';

class BdoInspectionProvider extends ChangeNotifier {
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

      // BDO: district and block are FIXED from login. Only optional GP comes from saved location.
      final blockId = await _authService.getBlockId();
      if (blockId == null) {
        _isLoading = false;
        notifyListeners();
        print('❌ Error: Block ID not found');
        return;
      }
      var savedLocation = await _authService.getPageLocation('bdo', 'inspections');
      savedLocation ??= await _authService.getInspectionLocation('bdo');
      final gpId = savedLocation?['gpId'] as int?;

      print('📡 BDO Inspection Provider Parameters:');
      print('   - Block ID: $blockId');
      if (gpId != null) print('   - GP ID: $gpId');
      print('   - Saved Location Full: $savedLocation');
      print('   - GP ID from saved: ${savedLocation?['gpId']}');
      print('   - GP Name from saved: ${savedLocation?['gpName']}');

      // Block-level users must only send block_id (omit district_id)
      final inspectionResponse = await _apiService.getInspections(
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

  // Load inspections for a specific GP within the user's block
  Future<void> loadInspectionsForGp({required int gpId, int page = 1, int pageSize = 20}) async {
    try {
      _isLoading = true;
      // Clear old inspections immediately to prevent showing stale data
      _inspections = [];
      _totalInspections = 0;
      notifyListeners();

      print('🔄 Loading inspections for GP ID: $gpId');

      final blockId = await _authService.getBlockId();

      print('📋 Request Parameters:');
      print('   - Block ID: $blockId');
      print('   - GP ID: $gpId');
      print('   - Page: $page');
      print('   - Page Size: $pageSize');

      final inspectionResponse = await _apiService.getInspections(
        blockId: blockId,
        gpId: gpId,
        page: page,
        pageSize: pageSize,
      );

      _inspections = inspectionResponse.items;
      _totalInspections = inspectionResponse.total;

      _isLoading = false;
      notifyListeners();

      print('✅ Loaded ${_inspections.length} inspections for GP $gpId (total: $_totalInspections)');
    } catch (e) {
      _isLoading = false;
      _inspections = [];
      _totalInspections = 0;
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
