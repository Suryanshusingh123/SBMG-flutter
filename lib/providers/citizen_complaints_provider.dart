import 'dart:io';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../models/complaint_type_model.dart';
import '../services/api_services.dart';
import '../config/connstants.dart';
import '../utils/auth_error_handler.dart';

/// Parses complaint_type from API (String or object with 'name').
String _complaintTypeNameFromJson(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim().isEmpty ? '' : value;
  if (value is Map && value['name'] != null) {
    return value['name'].toString().trim();
  }
  return '';
}

class ComplaintsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ComplaintType> _complaintTypes = [];
  final List<ComplaintModel> _complaints = [];
  bool _isLoadingTypes = false;
  bool _isLoadingComplaints = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<ComplaintType> get complaintTypes => _complaintTypes;
  List<ComplaintModel> get complaints => _complaints;
  bool get isLoadingTypes => _isLoadingTypes;
  bool get isLoadingComplaints => _isLoadingComplaints;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<ComplaintModel> get openComplaints =>
      _complaints.where((c) => c.status == 'open').toList();

  List<ComplaintModel> get closedComplaints =>
      _complaints.where((c) => c.status == 'closed').toList();

  Future<void> loadComplaintTypes() async {
    _isLoadingTypes = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final types = await _apiService.getComplaintTypes();
      _complaintTypes = types;
      _isLoadingTypes = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load complaint types';
      _isLoadingTypes = false;
      notifyListeners();
    }
  }

  Future<void> loadMyComplaints({
    required String token,
    int limit = 100,
    String orderBy = 'newest',
    BuildContext? context,
  }) async {
    _isLoadingComplaints = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load complaint types if needed so we can resolve type name from complaint_type_id
      if (_complaintTypes.isEmpty) {
        await loadComplaintTypes();
      }

      final complaintsData = await _apiService.getMyComplaints(
        token: token,
        limit: limit,
        orderBy: orderBy,
      );

      // Convert API response to ComplaintModel
      _complaints.clear();
      for (final complaintData in complaintsData) {
        // Extract latitude and longitude from API response
        final lat = complaintData['lat'] != null
            ? double.tryParse(complaintData['lat'].toString())
            : null;
        final long = complaintData['long'] != null
            ? double.tryParse(complaintData['long'].toString())
            : null;

        print('🔍 Complaint ${complaintData['id']}: lat=$lat, long=$long');

        // Create ComplaintLocation if coordinates are available
        List<ComplaintLocation> imageLocations = [];
        if (lat != null && long != null) {
          print('🌍 Coordinates found: lat=$lat, long=$long');
          // Display coordinates directly instead of reverse geocoding
          final address =
              'Lat: ${lat.toStringAsFixed(6)}, Long: ${long.toStringAsFixed(6)}';
          print('📍 Displaying coordinates: $address');
          
          // Helper function to parse date strings as UTC
          DateTime parseUTC(String dateString) {
            DateTime dateTime;
            if (dateString.endsWith('Z') || dateString.contains('+') || dateString.contains('-', dateString.indexOf('T'))) {
              dateTime = DateTime.parse(dateString);
            } else {
              dateTime = DateTime.parse('${dateString}Z');
            }
            return dateTime.isUtc ? dateTime : dateTime.toUtc();
          }
          
          imageLocations.add(
            ComplaintLocation(
              latitude: lat,
              longitude: long,
              address: address,
              timestamp: complaintData['created_at'] != null
                  ? parseUTC(complaintData['created_at'])
                  : DateTime.now().toUtc(),
            ),
          );
        } else {
          print(
            '⚠️ No coordinates available for complaint ${complaintData['id']}',
          );
        }

        final typeVal = complaintData['complaint_type'];
        final typeName = _complaintTypeNameFromJson(typeVal);
        String typeStr = typeName.isNotEmpty
            ? typeName
            : (typeVal?.toString().trim().isNotEmpty == true
                ? typeVal.toString().trim()
                : 'Unknown');
        // Resolve from complaint_type_id when API returns id but not type name
        if (typeStr == 'Unknown') {
          final typeId = complaintData['complaint_type_id'];
          if (typeId != null) {
            final id = typeId is int ? typeId : int.tryParse(typeId.toString());
            if (id != null) {
              final resolved = getComplaintTypeById(id);
              if (resolved != null) typeStr = resolved.name;
            }
          }
        }

        final complaint = ComplaintModel(
          id: complaintData['id'].toString(),
          type: typeStr,
          description: complaintData['description'] ?? '',
          imagePaths:
              (complaintData['media_urls'] as List<dynamic>?)
                  ?.map((url) => ApiConstants.getMediaUrl(url.toString()))
                  .toList() ??
              [],
          imageLocations: imageLocations,
          status:
              (complaintData['status'] as String?)?.toLowerCase() ?? 'unknown',
          createdAt: complaintData['created_at'] != null
              ? DateTime.parse(complaintData['created_at'])
              : DateTime.now(),
          userId: complaintData['mobile_number'] ?? '',
          assignedTo: complaintData['assigned_worker'] ?? 'Not assigned',
          timeline: [], // API doesn't provide timeline data
          updatedAt: complaintData['updated_at'] != null
              ? DateTime.parse(complaintData['updated_at'])
              : null,
          districtName: complaintData['district_name'],
          blockName: complaintData['block_name'],
          villageName: complaintData['village_name'],
          location: complaintData['location'],
        );

        print(
          '🔍 Complaint ${complaintData['id']} location field: ${complaintData['location']}',
        );

        _complaints.add(complaint);
      }

      _isLoadingComplaints = false;
      notifyListeners();
    } catch (e) {
      _isLoadingComplaints = false;

      // Check if it's an authentication error
      if (AuthErrorHandler.isAuthError(e) &&
          context != null &&
          context.mounted) {
        // Show login dialog for 401 errors
        final loginResult = await AuthErrorHandler.showLoginRequiredDialog(
          context,
        );

        // If user successfully logged in, try to fetch complaints again
        if (loginResult == true && context.mounted) {
          // The screen will handle refetching complaints after login
          _errorMessage = null; // Clear error message
        } else {
          _errorMessage = 'Authentication required to view complaints';
        }
      } else {
        _errorMessage = 'Failed to load complaints: ${e.toString()}';
      }

      notifyListeners();
    }
  }

  Future<bool> submitComplaint({
    required String token,
    required int complaintTypeId,
    required int gpId,
    required String description,
    required List<File> files,
    required double lat,
    required double long,
    required String location,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.submitComplaint(
        token: token,
        complaintTypeId: complaintTypeId,
        gpId: gpId,
        description: description,
        files: files,
        lat: lat,
        long: long,
        location: location,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit complaint: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      rethrow; // Re-throw the error so the screen can handle it
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  ComplaintType? getComplaintTypeById(int id) {
    try {
      return _complaintTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}
