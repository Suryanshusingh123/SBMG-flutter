import 'package:flutter/material.dart';
import '../models/api_complaint_model.dart';
import '../services/complaints_service.dart';

class SupervisorComplaintsProvider with ChangeNotifier {
  final ComplaintsService _complaintsService = ComplaintsService();

  // Loading states
  bool _isLoading = true;
  String? _errorMessage;

  // Data
  List<ApiComplaintModel> _complaints = [];
  String _villageName = 'Gram Panchayat';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ApiComplaintModel> get complaints => _complaints;
  String get villageName => _villageName;

  // Filtered complaints by status
  List<ApiComplaintModel> get openComplaints =>
      _complaints.where((c) => c.isOpen).toList();

  List<ApiComplaintModel> get resolvedComplaints =>
      _complaints.where((c) => c.isResolved).toList();

  List<ApiComplaintModel> get verifiedComplaints =>
      _complaints.where((c) => c.isVerified).toList();

  List<ApiComplaintModel> get closedComplaints =>
      _complaints.where((c) => c.isClosed).toList();

  // Load complaints
  Future<void> loadComplaints() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _complaintsService.getComplaintsForSupervisor();

      if (response['success'] == true) {
        final complaints = response['complaints'] as List<ApiComplaintModel>;

        // Extract village name from first complaint if available
        String villageName = 'Gram Panchayat';
        if (complaints.isNotEmpty) {
          villageName = complaints[0].villageName;
        }

        _complaints = complaints;
        _villageName = villageName;
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = response['message'] ?? 'Failed to load complaints';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading complaints: $e');
      _errorMessage = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh complaints
  Future<void> refresh() async {
    await loadComplaints();
  }
}
