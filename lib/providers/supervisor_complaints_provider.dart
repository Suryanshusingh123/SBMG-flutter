import 'package:flutter/material.dart';
import '../models/api_complaint_model.dart';
import '../services/complaints_service.dart';
import '../services/api_services.dart';

class SupervisorComplaintsProvider with ChangeNotifier {
  final ComplaintsService _complaintsService = ComplaintsService();
  final ApiService _apiService = ApiService();

  // Loading states
  bool _isLoading = true;
  String? _errorMessage;

  // Data
  List<ApiComplaintModel> _complaints = [];
  Map<int, String> _complaintTypeNames = {};
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
        try {
          final types = await _apiService.getComplaintTypes();
          _complaintTypeNames = {for (var t in types) t.id: t.name};
        } catch (_) {}
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

  /// Display title for list card: use complaint type name by ID when available so list matches details page.
  String getComplaintTypeDisplayName(ApiComplaintModel complaint) {
    if (complaint.complaintTypeId != 0 && _complaintTypeNames.containsKey(complaint.complaintTypeId)) {
      return _complaintTypeNames[complaint.complaintTypeId]!;
    }
    return complaint.complaintType.isNotEmpty ? complaint.complaintType : 'Complaint';
  }

  /// Resolve complaint type name by ID (for details screen when API returns id but not type name).
  String? getComplaintTypeNameById(int id) => _complaintTypeNames[id];

  // Refresh complaints
  Future<void> refresh() async {
    await loadComplaints();
  }
}
