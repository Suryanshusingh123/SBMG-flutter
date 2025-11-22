import 'package:flutter/material.dart';
import '../models/api_complaint_model.dart';
import '../services/complaints_service.dart';
import '../services/auth_services.dart';

class CeoComplaintsProvider extends ChangeNotifier {
  final ComplaintsService _complaintsService = ComplaintsService();
  final AuthService _authService = AuthService();

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

      final districtId = await _authService.getDistrictId();

      if (districtId == null) {
        debugPrint('❌ [CEO Complaints] District ID not available. Aborting call.');
        _errorMessage = 'District information not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('📡 [CEO Complaints] Fetching complaints for districtId=$districtId');
      final response = await _complaintsService.getComplaintsForBdo(
        districtId: districtId,
        blockId: null,
      );

      if (response['success'] == true) {
        final complaints = response['complaints'] as List<ApiComplaintModel>;

        _complaints = complaints;
        _villageName = 'District';
        _isLoading = false;
        notifyListeners();

        debugPrint(
          '✅ [CEO Complaints] Loaded ${complaints.length} complaints for districtId=$districtId',
        );
      } else {
        _errorMessage = response['message'] ?? 'Failed to load complaints';
        _isLoading = false;
        notifyListeners();

        debugPrint(
          '❌ [CEO Complaints] API error for districtId=$districtId -> $_errorMessage',
        );
      }
    } catch (e) {
      _errorMessage = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();

      debugPrint('💥 [CEO Complaints] Exception while fetching complaints: $e');
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
