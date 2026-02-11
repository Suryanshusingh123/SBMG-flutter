import 'package:flutter/material.dart';
import '../models/api_complaint_model.dart';
import '../services/complaints_service.dart';
import '../services/auth_services.dart';
import '../services/api_services.dart';

class CeoComplaintsProvider extends ChangeNotifier {
  final ComplaintsService _complaintsService = ComplaintsService();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  List<ApiComplaintModel> _complaints = [];
  Map<int, String> _complaintTypeNames = {};
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

      // Get saved location for COMPLAINTS page (includes district, block, and GP)
      // Fallback to old inspection location or district storage for backward compatibility
      var savedLocation = await _authService.getPageLocation('ceo', 'complaints');
      if (savedLocation == null) {
        savedLocation = await _authService.getInspectionLocation('ceo');
      }
      
      // Get district ID from saved location, fallback to old storage method
      int? districtId;
      if (savedLocation != null && savedLocation['districtId'] != null) {
        districtId = savedLocation['districtId'] as int?;
        print('📍 Using district ID from saved COMPLAINTS page location: $districtId');
      } else {
        // Fallback to old storage method for backward compatibility
        districtId = await _authService.getDistrictId();
        print('📍 Using district ID from old storage method: $districtId');
      }

      if (districtId == null) {
        debugPrint('❌ [CEO Complaints] District ID not available. Aborting call.');
        _errorMessage = 'District information not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get saved Block/GP selection if available
      final blockId = savedLocation?['blockId'] as int?;
      final gpId = savedLocation?['gpId'] as int?;

      debugPrint('📡 [CEO Complaints] Fetching complaints for districtId=$districtId');
      if (blockId != null) debugPrint('   - Block ID: $blockId');
      if (gpId != null) debugPrint('   - GP ID: $gpId');
      
      // Use getComplaintsWithAnalytics to support Block/GP filtering
      final response = await _complaintsService.getComplaintsWithAnalytics(
        districtId: districtId,
        blockId: blockId,
        gpId: gpId,
        limit: 10000, // High limit to get all complaints for accurate total count
        orderBy: 'newest',
      );

      if (response['success'] == true) {
        // Convert raw complaints to ApiComplaintModel
        final rawComplaints = response['complaints'] as List<dynamic>;
        final complaints = rawComplaints
            .map((json) => ApiComplaintModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Apply client-side filtering if GP ID is specified
        List<ApiComplaintModel> filteredComplaints = complaints;
        if (gpId != null) {
          final beforeCount = filteredComplaints.length;
          final gpName = savedLocation?['gpName'] as String?;
          if (gpName != null && gpName.isNotEmpty) {
            filteredComplaints = filteredComplaints.where((complaint) {
              return complaint.villageName.toLowerCase().trim() == gpName.toLowerCase().trim();
            }).toList();
          } else if (blockId != null) {
            final blockName = savedLocation?['blockName'] as String?;
            if (blockName != null && blockName.isNotEmpty) {
              filteredComplaints = filteredComplaints.where((complaint) {
                return complaint.blockName.toLowerCase().trim() == blockName.toLowerCase().trim();
              }).toList();
            }
          }
          final afterCount = filteredComplaints.length;
          if (beforeCount != afterCount) {
            print('⚠️ API returned ${beforeCount} complaints, but only ${afterCount} match selected location');
          }
        } else if (blockId != null) {
          final blockName = savedLocation?['blockName'] as String?;
          if (blockName != null && blockName.isNotEmpty) {
            final beforeCount = filteredComplaints.length;
            filteredComplaints = filteredComplaints.where((complaint) {
              return complaint.blockName.toLowerCase().trim() == blockName.toLowerCase().trim();
            }).toList();
            final afterCount = filteredComplaints.length;
            if (beforeCount != afterCount) {
              print('⚠️ Filtered by block name: ${beforeCount} -> ${afterCount} complaints');
            }
          }
        }

        // Determine location name for display
        String locationName = 'District';
        if (savedLocation != null) {
          if (savedLocation['gpName'] != null) {
            locationName = savedLocation['gpName'] as String;
          } else if (savedLocation['blockName'] != null) {
            locationName = savedLocation['blockName'] as String;
          } else if (savedLocation['districtName'] != null) {
            locationName = savedLocation['districtName'] as String;
          }
        } else if (filteredComplaints.isNotEmpty) {
          locationName = filteredComplaints[0].villageName;
        }

        _complaints = filteredComplaints;
        _villageName = locationName;
        try {
          final types = await _apiService.getComplaintTypes();
          _complaintTypeNames = {for (var t in types) t.id: t.name};
        } catch (_) {}
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

  /// Display title for list card: use complaint type name by ID when available so list matches details page.
  String getComplaintTypeDisplayName(ApiComplaintModel complaint) {
    if (complaint.complaintTypeId != 0 && _complaintTypeNames.containsKey(complaint.complaintTypeId)) {
      return _complaintTypeNames[complaint.complaintTypeId]!;
    }
    return complaint.complaintType.isNotEmpty ? complaint.complaintType : 'Complaint';
  }

  /// Resolve complaint type name by ID (for details screen when API returns id but not type name).
  String? getComplaintTypeNameById(int id) => _complaintTypeNames[id];
}
