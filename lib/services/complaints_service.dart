import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/connstants.dart';
import '../models/api_complaint_model.dart';
import 'auth_services.dart';

class ComplaintsService {
  static final ComplaintsService _instance = ComplaintsService._internal();
  factory ComplaintsService() => _instance;
  ComplaintsService._internal();

  final AuthService _authService = AuthService();

  /// Get complaints for supervisor analytics
  Future<Map<String, dynamic>> getComplaintsForAnalytics({
    int? gpId,
    int? districtId,
    int? blockId,
    int limit = 500,
    String orderBy = 'newest',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      // Use stored village ID if gpId not provided AND no district filter is being used
      if (gpId == null && districtId == null) {
        gpId = await _authService.getVillageId();
      }

      final queryParams = <String, String>{};

      // Add gp_id if provided
      if (gpId != null) {
        queryParams['gp_id'] = gpId.toString();
      }

      // Add district_id if provided
      if (districtId != null) {
        queryParams['district_id'] = districtId.toString();
      }

      // Add block_id if provided
      if (blockId != null) {
        queryParams['block_id'] = blockId.toString();
      }

      queryParams['limit'] = limit.toString();
      queryParams['order_by'] = orderBy;

      // Add date range parameters if provided
      if (fromDate != null) {
        queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
      }
      if (toDate != null) {
        queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.complaintsEndpoint}',
      ).replace(queryParameters: queryParams);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 COMPLAINTS API REQUEST: GET ANALYTICS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      if (gpId != null) print('🏘️ GP ID: $gpId');
      if (districtId != null) print('🏛️ District ID: $districtId');
      if (blockId != null) print('📦 Block ID: $blockId');
      print('📊 Limit: $limit');
      print('📅 Order By: $orderBy');
      if (fromDate != null) print('📅 From Date: $fromDate');
      if (toDate != null) print('📅 To Date: $toDate');
      print('🔑 Headers: ${await _authService.getAuthHeaders()}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.get(
        url,
        headers: await _authService.getAuthHeaders(),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 COMPLAINTS API RESPONSE: GET ANALYTICS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Complaints data retrieved');
        return {'success': true, 'complaints': data};
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['message'] ?? error['detail'] ?? 'Failed to get complaints';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ COMPLAINTS API ERROR: GET ANALYTICS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Calculate analytics from complaints data
  Map<String, dynamic> calculateAnalytics(
    List<dynamic> complaints, {
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    if (complaints.isEmpty) {
      return {
        'totalComplaints': 0,
        'openComplaints': 0,
        'resolvedComplaints': 0,
        'verifiedComplaints': 0,
        'closedComplaints': 0,
        'todaysComplaints': 0,
        'complaintsByType': <String, int>{},
        'complaintsByStatus': <String, int>{},
      };
    }

    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    int totalComplaints = complaints.length;
    int openComplaints = 0;
    int resolvedComplaints = 0;
    int verifiedComplaints = 0;
    int closedComplaints = 0;
    int todaysComplaints = 0;

    Map<String, int> complaintsByType = {};
    Map<String, int> complaintsByStatus = {};

    // Filter complaints by date range if provided
    List<dynamic> filteredComplaints = complaints;
    if (fromDate != null || toDate != null) {
      filteredComplaints = complaints.where((complaint) {
        final createdAt = complaint['created_at'] as String?;
        if (createdAt == null) return false;

        final complaintDate = DateTime.tryParse(createdAt);
        if (complaintDate == null) return false;

        // Convert to date only (remove time component) for comparison
        final complaintDateOnly = DateTime.utc(
          complaintDate.year,
          complaintDate.month,
          complaintDate.day,
        );

        bool withinRange = true;

        if (fromDate != null) {
          final fromDateOnly = DateTime.utc(
            fromDate.year,
            fromDate.month,
            fromDate.day,
          );
          withinRange =
              withinRange && complaintDateOnly.isAtSameMomentAs(fromDateOnly) ||
              complaintDateOnly.isAfter(fromDateOnly);
        }

        if (toDate != null) {
          final toDateOnly = DateTime.utc(
            toDate.year,
            toDate.month,
            toDate.day,
          );
          withinRange =
              withinRange &&
              (complaintDateOnly.isAtSameMomentAs(toDateOnly) ||
                  complaintDateOnly.isBefore(toDateOnly));
        }

        return withinRange;
      }).toList();
    }

    // Update total complaints count to reflect filtered data
    totalComplaints = filteredComplaints.length;

    print('📊 Analytics Calculation:');
    print(
      '   📅 Date Range: ${fromDate?.toIso8601String().split('T')[0]} to ${toDate?.toIso8601String().split('T')[0]}',
    );
    print('   📈 Total Complaints: ${complaints.length} (unfiltered)');
    print('   📈 Filtered Complaints: ${filteredComplaints.length}');

    for (var complaint in filteredComplaints) {
      // Count by status
      String status = complaint['status'] ?? 'UNKNOWN';
      complaintsByStatus[status] = (complaintsByStatus[status] ?? 0) + 1;

      switch (status.toUpperCase()) {
        case 'OPEN':
          openComplaints++;
          break;
        case 'RESOLVED':
          resolvedComplaints++;
          break;
        case 'VERIFIED':
          verifiedComplaints++;
          break;
        case 'CLOSED':
          closedComplaints++;
          break;
      }

      // Count by type
      String complaintType = complaint['complaint_type'] ?? 'Unknown';
      complaintsByType[complaintType] =
          (complaintsByType[complaintType] ?? 0) + 1;

      // Count today's complaints
      if (complaint['created_at'] != null) {
        try {
          final createdAt = DateTime.parse(complaint['created_at']).toUtc();
          final complaintDate = DateTime.utc(
            createdAt.year,
            createdAt.month,
            createdAt.day,
          );
          if (complaintDate.isAtSameMomentAs(today)) {
            todaysComplaints++;
          }
        } catch (e) {
          print('Error parsing date: ${complaint['created_at']}');
        }
      }
    }

    return {
      'totalComplaints': totalComplaints,
      'openComplaints': openComplaints,
      'resolvedComplaints': resolvedComplaints,
      'verifiedComplaints': verifiedComplaints,
      'closedComplaints': closedComplaints,
      'todaysComplaints': todaysComplaints,
      'complaintsByType': complaintsByType,
      'complaintsByStatus': complaintsByStatus,
    };
  }

  /// Get complaints with analytics
  Future<Map<String, dynamic>> getComplaintsWithAnalytics({
    int? gpId,
    int? districtId,
    int? blockId,
    int limit = 500,
    String orderBy = 'newest',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await getComplaintsForAnalytics(
      gpId: gpId,
      districtId: districtId,
      blockId: blockId,
      limit: limit,
      orderBy: orderBy,
      fromDate: fromDate,
      toDate: toDate,
    );

    if (response['success'] == true) {
      final complaints = response['complaints'] as List<dynamic>;
      final analytics = calculateAnalytics(
        complaints,
        fromDate: fromDate,
        toDate: toDate,
      );

      return {
        'success': true,
        'complaints': complaints,
        'analytics': analytics,
      };
    } else {
      return response;
    }
  }

  /// Get complaints for supervisor complaints screen
  Future<Map<String, dynamic>> getComplaintsForSupervisor({
    int? gpId,
    int limit = 500,
    String orderBy = 'newest',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      // Use stored village ID if gpId not provided
      if (gpId == null) {
        gpId = await _authService.getVillageId();
        if (gpId == null) {
          return {'success': false, 'message': 'Village ID not found'};
        }
      }

      final url =
          Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.complaintsEndpoint}',
          ).replace(
            queryParameters: {
              'gp_id': gpId.toString(),
              'limit': limit.toString(),
              'order_by': orderBy,
            },
          );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 COMPLAINTS API REQUEST: GET FOR SUPERVISOR');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('🏘️ GP ID: $gpId');
      print('📊 Limit: $limit');
      print('📅 Order By: $orderBy');
      print('🔑 Headers: ${await _authService.getAuthHeaders()}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.get(
        url,
        headers: await _authService.getAuthHeaders(),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 COMPLAINTS API RESPONSE: GET FOR SUPERVISOR');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final complaints = (data as List)
            .map((json) => ApiComplaintModel.fromJson(json))
            .toList();

        print('✅ SUCCESS: Complaints data retrieved and parsed');
        print('📊 Total complaints: ${complaints.length}');

        return {'success': true, 'complaints': complaints};
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['message'] ?? error['detail'] ?? 'Failed to get complaints';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ COMPLAINTS API ERROR: GET FOR SUPERVISOR');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
