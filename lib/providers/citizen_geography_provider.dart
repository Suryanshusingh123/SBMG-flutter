import 'package:flutter/material.dart';
import '../models/geography_model.dart';
import '../services/api_services.dart';

class GeographyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<District> _districts = [];
  List<Block> _blocks = [];
  List<Village> _villages = [];

  bool _isLoadingDistricts = false;
  bool _isLoadingBlocks = false;
  bool _isLoadingVillages = false;

  String? _errorMessage;

  List<District> get districts => _districts;
  List<Block> get blocks => _blocks;
  List<Village> get villages => _villages;

  bool get isLoadingDistricts => _isLoadingDistricts;
  bool get isLoadingBlocks => _isLoadingBlocks;
  bool get isLoadingVillages => _isLoadingVillages;

  String? get errorMessage => _errorMessage;

  Future<void> loadDistricts() async {
    _isLoadingDistricts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final districts = await _apiService.getDistricts();
      _districts = districts;
      _isLoadingDistricts = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load districts';
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }

  Future<void> loadBlocks(int districtId) async {
    _isLoadingBlocks = true;
    _blocks = [];
    _villages = [];
    _errorMessage = null;
    notifyListeners();

    try {
      final blocks = await _apiService.getBlocks(districtId: districtId);
      _blocks = blocks;
      _isLoadingBlocks = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load blocks';
      _isLoadingBlocks = false;
      notifyListeners();
    }
  }

  Future<void> loadVillages(int blockId, int districtId) async {
    _isLoadingVillages = true;
    _villages = [];
    _errorMessage = null;
    notifyListeners();

    try {
      final villages = await _apiService.getVillages(
        blockId: blockId,
        districtId: districtId,
      );
      _villages = villages;
      _isLoadingVillages = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load villages';
      _isLoadingVillages = false;
      notifyListeners();
    }
  }

  Future<Contractor?> getContractorByVillageId(int villageId) async {
    try {
      return await _apiService.getContractorByVillageId(villageId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearBlocks() {
    _blocks = [];
    _villages = [];
    notifyListeners();
  }

  void clearVillages() {
    _villages = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
