import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/connstants.dart';
import 'auth_services.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final AuthService _authService = AuthService();

  /// Mark attendance (start attendance)
  Future<Map<String, dynamic>> markAttendance({
    required String startLat,
    required String startLong,
    required int villageId,
    String remarks = 'attendance',
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.attendanceLogEndpoint}',
      );

      final headers = await _authService.getAuthHeaders();
      final body = json.encode({
        'start_lat': startLat,
        'start_long': startLong,
        'village_id': villageId,
        'remarks': remarks,
      });

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 ATTENDANCE API REQUEST: MARK ATTENDANCE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('📦 Request Body: $body');
      print('🔑 Headers: $headers');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(url, headers: headers, body: body);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 ATTENDANCE API RESPONSE: MARK ATTENDANCE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Attendance marked successfully');
        return {
          'success': true,
          'data': data,
          'message': 'Attendance marked successfully',
        };
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['detail'] ?? error['message'] ?? 'Failed to mark attendance';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ATTENDANCE API ERROR: MARK ATTENDANCE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// End attendance
  Future<Map<String, dynamic>> endAttendance({
    required int attendanceId,
    required String endLat,
    required String endLong,
    String remarks = 'attendance',
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.attendanceEndEndpoint}',
      );

      final headers = await _authService.getAuthHeaders();
      final body = json.encode({
        'attendance_id': attendanceId,
        'end_lat': endLat,
        'end_long': endLong,
        'remarks': remarks,
      });

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 ATTENDANCE API REQUEST: END ATTENDANCE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('📦 Request Body: $body');
      print('🔑 Headers: $headers');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.put(url, headers: headers, body: body);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 ATTENDANCE API RESPONSE: END ATTENDANCE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Attendance ended successfully');
        return {
          'success': true,
          'data': data,
          'message': 'Attendance ended successfully',
        };
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['detail'] ?? error['message'] ?? 'Failed to end attendance';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ATTENDANCE API ERROR: END ATTENDANCE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Get attendance logs
  Future<Map<String, dynamic>> getAttendanceLogs({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.attendanceMyEndpoint}?page=$page&limit=$limit',
      );

      final headers = await _authService.getAuthHeaders();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 ATTENDANCE API REQUEST: GET LOGS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('🔑 Headers: $headers');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.get(url, headers: headers);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 ATTENDANCE API RESPONSE: GET LOGS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Attendance logs retrieved');
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['detail'] ??
            error['message'] ??
            'Failed to get attendance logs';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ATTENDANCE API ERROR: GET LOGS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
