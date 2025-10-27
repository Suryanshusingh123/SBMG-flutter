import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../services/api_services.dart';

class SchemesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Scheme> _schemes = [];
  List<Scheme> _featuredSchemes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Scheme> get schemes => _schemes;
  List<Scheme> get featuredSchemes => _featuredSchemes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSchemes => _schemes.isNotEmpty;

  Future<void> loadSchemes({int limit = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final schemes = await _apiService.getSchemes(limit: limit);
      _schemes = schemes;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load schemes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedSchemes({int limit = 3}) async {
    try {
      final schemes = await _apiService.getSchemes(limit: limit);
      _featuredSchemes = schemes;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured schemes: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Scheme? getSchemeById(int id) {
    try {
      return _schemes.firstWhere((scheme) => scheme.id == id);
    } catch (e) {
      return null;
    }
  }
}
