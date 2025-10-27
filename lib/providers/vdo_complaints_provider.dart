import 'package:flutter/material.dart';
import '../models/api_complaint_model.dart';
import '../services/complaints_service.dart';

class VdoComplaintsProvider with ChangeNotifier {
  final ComplaintsService _complaintsService = ComplaintsService();

  // State
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
  List<ApiComplaintModel> get openComplaints {
    final openComplaints = _complaints
        .where((c) => c.status.toUpperCase() == 'OPEN')
        .toList();
    print('🔍 OPEN COMPLAINTS: ${openComplaints.length}/${_complaints.length}');
    return openComplaints;
  }

  List<ApiComplaintModel> get resolvedComplaints {
    final resolvedComplaints = _complaints
        .where((c) => c.status.toUpperCase() == 'RESOLVED')
        .toList();
    print(
      '🔍 RESOLVED COMPLAINTS: ${resolvedComplaints.length}/${_complaints.length}',
    );
    return resolvedComplaints;
  }

  List<ApiComplaintModel> get verifiedComplaints {
    final verifiedComplaints = _complaints
        .where((c) => c.status.toUpperCase() == 'VERIFIED')
        .toList();
    print(
      '🔍 VERIFIED COMPLAINTS: ${verifiedComplaints.length}/${_complaints.length}',
    );
    return verifiedComplaints;
  }

  List<ApiComplaintModel> get closedComplaints {
    final closedComplaints = _complaints
        .where((c) => c.status.toUpperCase() == 'CLOSED')
        .toList();
    print(
      '🔍 CLOSED COMPLAINTS: ${closedComplaints.length}/${_complaints.length}',
    );
    return closedComplaints;
  }

  // Load complaints
  Future<void> loadComplaints() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _complaintsService.getComplaintsForSupervisor();

      if (response['success'] == true) {
        final complaints = response['complaints'] as List<ApiComplaintModel>;

        print('🔍 API RESPONSE DEBUG:');
        print('   - Total complaints received: ${complaints.length}');

        // Check for duplicate IDs
        final ids = complaints.map((c) => c.id).toList();
        final uniqueIds = ids.toSet();
        if (ids.length != uniqueIds.length) {
          print(
            '   ⚠️ DUPLICATE IDs FOUND: ${ids.length} total, ${uniqueIds.length} unique',
          );
        }

        // Extract village name from first complaint if available
        String villageName = 'Gram Panchayat';
        if (complaints.isNotEmpty) {
          villageName = complaints[0].villageName;
        }

        // Remove duplicates based on ID
        final uniqueComplaints = <int, ApiComplaintModel>{};
        for (final complaint in complaints) {
          uniqueComplaints[complaint.id] = complaint;
        }
        final deduplicatedComplaints = uniqueComplaints.values.toList();

        print('🔧 DEDUPLICATION:');
        print('   - Before: ${complaints.length} complaints');
        print('   - After: ${deduplicatedComplaints.length} complaints');

        _complaints = deduplicatedComplaints;
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
