import 'package:flutter/material.dart';
import '../models/api_complaint_model.dart';
import '../services/complaints_service.dart';

class SmdComplaintsProvider extends ChangeNotifier {
  final ComplaintsService _complaintsService = ComplaintsService();

  List<ApiComplaintModel> _complaints = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _villageName = 'Gram Panchayat';

  // Getters
  List<ApiComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
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
      _errorMessage = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get complaint status color
  Color getComplaintStatusColor(ApiComplaintModel complaint) {
    switch (complaint.status.toUpperCase()) {
      case 'VERIFIED':
        return const Color(0xFF10B981); // Green for verified
      case 'RESOLVED':
        return const Color(0xFF3B82F6); // Blue for resolved
      case 'CLOSED':
        return const Color(0xFF6B7280); // Gray for closed
      case 'OPEN':
      default:
        return const Color(0xFFEF4444); // Red for open
    }
  }

  // Get complaint status text
  String getComplaintStatusText(ApiComplaintModel complaint) {
    switch (complaint.status.toUpperCase()) {
      case 'VERIFIED':
        return 'Verified';
      case 'RESOLVED':
        return 'Resolved';
      case 'CLOSED':
        return 'Closed';
      case 'OPEN':
      default:
        return 'Open';
    }
  }
}
