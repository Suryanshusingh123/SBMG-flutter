import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../config/connstants.dart';
import '../models/scheme_model.dart';
import '../models/event_model.dart';
import '../models/geography_model.dart';
import '../models/complaint_type_model.dart';
import '../models/inspection_model.dart';
import '../models/contractor_model.dart';
import 'auth_services.dart';

/// Custom exception for when survey is already filled
class SurveyAlreadyFilledException implements Exception {
  final String message;
  SurveyAlreadyFilledException(this.message);
  
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Private method to make HTTP requests
  Future<http.Response> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        // Handle JSON body encoding
        if (body is Map<String, dynamic>) {
          response = await http.post(
            url,
            headers: headers,
            body: json.encode(body),
          );
        } else {
          response = await http.post(url, headers: headers, body: body);
        }
        break;
      case 'PUT':
        // Handle JSON body encoding
        if (body is Map<String, dynamic>) {
          response = await http.put(
            url,
            headers: headers,
            body: json.encode(body),
          );
        } else {
          response = await http.put(url, headers: headers, body: body);
        }
        break;
      case 'PATCH':
        // Handle JSON body encoding
        if (body is Map<String, dynamic>) {
          response = await http.patch(
            url,
            headers: headers,
            body: json.encode(body),
          );
        } else {
          response = await http.patch(url, headers: headers, body: body);
        }
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // Handle 401 Unauthorized response
    if (response.statusCode == 401) {
      print('🚨 401 Unauthorized response detected - logging out user');
      _handle401Error();
    }

    return response;
  }

  // Handle 401 error by logging out the user
  void _handle401Error() async {
    try {
      final authService = AuthService();
      await authService.logout();
      print('✅ User logged out due to unauthorized session');
    } catch (e) {
      print('❌ Error during 401 logout: $e');
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Schemes API methods
  Future<List<Scheme>> getSchemes({
    int skip = 0,
    int limit = 100,
    bool active = true,
  }) async {
    try {
      final endpoint =
          '${ApiConstants.schemesEndpoint}?skip=$skip&limit=$limit&active=$active';
      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response);

      if (data is List) {
        final schemes = data.map((json) => Scheme.fromJson(json)).toList();
        print('✅ Schemes fetched: ${schemes.length} items');
        return schemes;
      } else {
        throw Exception('Invalid response format for schemes');
      }
    } catch (e) {
      print('❌ Error fetching schemes: $e');
      throw Exception('Failed to fetch schemes: $e');
    }
  }

  Future<Scheme?> getSchemeById(int schemeId) async {
    try {
      final endpoint = '${ApiConstants.schemesEndpoint}$schemeId';
      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');

      final data = _handleResponse(response);
      print('✅ Scheme fetched: ID $schemeId');
      return Scheme.fromJson(data);
    } catch (e) {
      print('❌ Error fetching scheme: $e');
      throw Exception('Failed to fetch scheme: $e');
    }
  }

  // Events API methods
  Future<List<Event>> getEvents({
    int skip = 0,
    int limit = 100,
    bool active = true,
  }) async {
    try {
      final endpoint =
          '${ApiConstants.eventsEndpoint}?skip=$skip&limit=$limit&active=$active';
      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response);

      if (data is List) {
        final events = data.map((json) => Event.fromJson(json)).toList();
        print('✅ Events fetched: ${events.length} items');
        return events;
      } else {
        throw Exception('Invalid response format for events');
      }
    } catch (e) {
      print('❌ Error fetching events: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<Event?> getEventById(int eventId) async {
    try {
      final endpoint = '${ApiConstants.eventsEndpoint}$eventId';
      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');

      final data = _handleResponse(response);
      print('✅ Event fetched: ID $eventId');
      return Event.fromJson(data);
    } catch (e) {
      print('❌ Error fetching event: $e');
      throw Exception('Failed to fetch event: $e');
    }
  }

  // Geography APIs

  /// Fetch all districts
  Future<List<District>> getDistricts({int skip = 0, int limit = 100}) async {
    try {
      final endpoint =
          '${ApiConstants.districtsEndpoint}?skip=$skip&limit=$limit';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response) as List<dynamic>;
      final districts = data.map((json) => District.fromJson(json)).toList();

      print('✅ Districts fetched: ${districts.length} items');
      return districts;
    } catch (e) {
      print('❌ Error fetching districts: $e');
      throw Exception('Failed to fetch districts: $e');
    }
  }

  /// Fetch blocks for a district
  Future<List<Block>> getBlocks({
    required int districtId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final endpoint =
          '${ApiConstants.blocksEndpoint}?district_id=$districtId&skip=$skip&limit=$limit';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response) as List<dynamic>;
      final blocks = data.map((json) => Block.fromJson(json)).toList();

      print(
        '✅ Blocks fetched: ${blocks.length} items for district $districtId',
      );
      return blocks;
    } catch (e) {
      print('❌ Error fetching blocks: $e');
      throw Exception('Failed to fetch blocks: $e');
    }
  }

  /// Fetch villages for a block
  Future<List<Village>> getVillages({
    required int blockId,
    required int districtId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final endpoint =
          '${ApiConstants.villagesEndpoint}?block_id=$blockId&district_id=$districtId&skip=$skip&limit=$limit';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response) as List<dynamic>;
      final villages = data.map((json) => Village.fromJson(json)).toList();

      print('✅ Villages fetched: ${villages.length} items for block $blockId');
      return villages;
    } catch (e) {
      print('❌ Error fetching villages: $e');
      throw Exception('Failed to fetch villages: $e');
    }
  }

  /// Fetch Gram Panchayats for a block and district
  Future<List<GramPanchayat>> getGramPanchayats({
    required int blockId,
    required int districtId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final endpoint =
          '${ApiConstants.contractorEndpoint}?block_id=$blockId&district_id=$districtId&skip=$skip&limit=$limit';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response) as List<dynamic>;
      final gramPanchayats = data
          .map((json) => GramPanchayat.fromJson(json))
          .toList();

      print(
        '✅ Gram Panchayats fetched: ${gramPanchayats.length} items for block $blockId',
      );
      return gramPanchayats;
    } catch (e) {
      print('❌ Error fetching Gram Panchayats: $e');
      throw Exception('Failed to fetch Gram Panchayats: $e');
    }
  }

  /// Fetch a single Gram Panchayat/Village by ID
  Future<GramPanchayat> getGramPanchayatById(int gpId) async {
    try {
      final endpoint = '${ApiConstants.villagesEndpoint}/$gpId';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response);
      final gramPanchayat = GramPanchayat.fromJson(data);

      print('✅ Gram Panchayat fetched: ${gramPanchayat.name}');
      return gramPanchayat;
    } catch (e) {
      print('❌ Error fetching Gram Panchayat: $e');
      throw Exception('Failed to fetch Gram Panchayat: $e');
    }
  }

  /// Fetch contractor for a village
  Future<Contractor> getContractorByVillageId(int villageId) async {
    try {
      final endpoint =
          '${ApiConstants.contractorEndpoint}/$villageId/contractor';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');

      final data = _handleResponse(response);
      print('📦 Contractor Response Data: $data');
      print('✅ Contractor fetched: Village ID $villageId');
      return Contractor.fromJson(data);
    } catch (e) {
      print('❌ Error fetching contractor: $e');
      throw Exception('Failed to fetch contractor: $e');
    }
  }

  // Complaint APIs

  /// Fetch all complaint types
  Future<List<ComplaintType>> getComplaintTypes() async {
    try {
      final endpoint = ApiConstants.complaintTypesEndpoint;

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response) as List<dynamic>;
      final complaintTypes = data
          .map((json) => ComplaintType.fromJson(json))
          .toList();

      print('✅ Complaint types fetched: ${complaintTypes.length} items');
      return complaintTypes;
    } catch (e) {
      print('❌ Error fetching complaint types: $e');
      throw Exception('Failed to fetch complaint types: $e');
    }
  }

  /// Fetch user's complaints
  Future<List<Map<String, dynamic>>> getMyComplaints({
    required String token,
    int limit = 100,
    String orderBy = 'newest',
  }) async {
    try {
      final endpoint =
          '${ApiConstants.myComplaintsEndpoint}?limit=$limit&order_by=$orderBy';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: {'accept': 'application/json', 'token': token},
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response) as List<dynamic>;
      final complaints = data.cast<Map<String, dynamic>>();

      print('✅ My complaints fetched: ${complaints.length} items');
      return complaints;
    } catch (e) {
      print('❌ Error fetching my complaints: $e');
      throw Exception('Failed to fetch my complaints: $e');
    }
  }

  // Submit complaint with media files
  Future<Map<String, dynamic>> submitComplaint({
    required String token,
    required int complaintTypeId,
    required int gpId,
    required String description,
    required List<File> files,
    required double lat,
    required double long,
    required String location,
  }) async {
    try {
      // Get location string from coordinates if not provided
      String locationString = location;
      if (locationString.isEmpty) {
        locationString = await _getLocationFromCoordinates(lat, long);
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.submitComplaintEndpoint}',
      );

      print('🔵 API Request: POST $url');
      print('📋 Complaint Type ID: $complaintTypeId');
      print('📍 GP ID: $gpId');
      print('📝 Description: $description');
      print('📷 Files: ${files.length}');
      print('🌍 Location: Lat $lat, Long $long');
      print('📍 Location String: $locationString');
      print('🔑 Token: $token');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({'accept': 'application/json', 'token': token});

      // Add form fields
      request.fields['complaint_type_id'] = complaintTypeId.toString();
      request.fields['gp_id'] = gpId.toString();
      request.fields['description'] = description;
      request.fields['lat'] = lat.toString();
      request.fields['long'] = long.toString();
      request.fields['location'] = locationString;

      // Add files
      print('📁 Processing ${files.length} files...');
      if (files.isEmpty) {
        print('⚠️  Warning: No files to upload');
      }

      for (var i = 0; i < files.length; i++) {
        var file = files[i];
        print('📎 File ${i + 1}/${files.length}: ${file.path}');
        print('   - File exists: ${await file.exists()}');

        if (!await file.exists()) {
          print('❌ File does not exist: ${file.path}');
          throw Exception('File does not exist: ${file.path}');
        }

        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        print('   - File size: $length bytes');

        var multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
        print('✅ Added file to request: ${file.path.split('/').last}');
      }

      // Send request
      print('🚀 Sending multipart request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Complaint submitted successfully');
        return data;
      } else {
        print('❌ ERROR: Status ${response.statusCode} - ${response.body}');
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error submitting complaint: $e');
      throw Exception('Failed to submit complaint: $e');
    }
  }

  /// Get latest annual survey for a Gram Panchayat
  Future<Map<String, dynamic>> getLatestAnnualSurveyForGp(int gpId) async {
    try {
      final endpoint = '${ApiConstants.annualSurveyEndpoint}/$gpId';
      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = _handleResponse(response);
        print('✅ Annual Survey fetched for GP ID $gpId');
        return data;
      } else if (response.statusCode == 404) {
        // Handle 404 case specifically
        final errorData = json.decode(response.body);
        throw Exception(
          'Survey not found: ${errorData['message'] ?? 'Survey not found for this Gram Panchayat'}',
        );
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching annual survey: $e');
      rethrow;
    }
  }

  /// Close complaint with resolution comment
  Future<Map<String, dynamic>> closeComplaint({
    required int complaintId,
    required String resolution,
    required String token,
  }) async {
    try {
      final endpoint =
          '/api/v1/citizen/$complaintId/close?resolution=$resolution';
      print('🔵 API Request: POST ${ApiConstants.baseUrl}$endpoint');
      print('📋 Complaint ID: $complaintId');
      print('💬 Resolution: $resolution');

      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await http.post(
        url,
        headers: {'accept': 'application/json', 'user-token': token},
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = _handleResponse(response);
      print('✅ Complaint closed successfully');
      return data;
    } catch (e) {
      print('❌ Error closing complaint: $e');
      throw Exception('Failed to close complaint: $e');
    }
  }

  /// VDO verify complaint with comment and media
  Future<Map<String, dynamic>> verifyComplaint({
    required int complaintId,
    required String comment,
    List<File>? mediaFiles,
  }) async {
    try {
      final token = await _getAuthToken();

      final url =
          '${ApiConstants.baseUrl}/api/v1/complaints/vdo/complaints/$complaintId/verify';

      print('🔵 VDO VERIFICATION API REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('🆔 Complaint ID: $complaintId');
      print('💬 Comment: $comment');
      print('📁 Media Files: ${mediaFiles?.length ?? 0}');
      print('🎫 Token Retrieved: ${token.substring(0, 20)}...');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final request = http.MultipartRequest('PATCH', Uri.parse(url));

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add comment
      request.fields['comment'] = comment;

      // Add media files if provided
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (int i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          if (await file.exists()) {
            final multipartFile = await http.MultipartFile.fromPath(
              'media',
              file.path,
              filename: file.path.split('/').last,
            );
            request.files.add(multipartFile);
            print('📎 Added media file: ${file.path.split('/').last}');
          }
        }
      }

      print('🔑 Headers: ${request.headers}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🟢 VDO VERIFICATION API RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final data = _handleResponse(response);
      print('✅ Complaint verified successfully');
      return data;
    } catch (e) {
      print('❌ Error verifying complaint: $e');
      throw Exception('Failed to verify complaint: $e');
    }
  }

  /// Fetch complaint details by ID (public API)
  Future<Map<String, dynamic>> getComplaintDetails({
    required int complaintId,
  }) async {
    try {
      final endpoint = '/api/v1/public/$complaintId/details';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 COMPLAINT DETAILS API REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: ${ApiConstants.baseUrl}$endpoint');
      print('🆔 Complaint ID: $complaintId');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 COMPLAINT DETAILS API RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final data = _handleResponse(response) as Map<String, dynamic>;

      print('✅ Complaint details fetched successfully');
      print('📋 Complaint Data:');
      print('   - ID: ${data['id']}');
      print('   - Status: ${data['status']}');
      print('   - Description: ${data['description']}');
      print('   - Village: ${data['village_name']}');
      print('   - Media URLs: ${data['media_urls']}');
      print('   - Media Count: ${(data['media'] as List?)?.length ?? 0}');
      print('   - Comments Count: ${(data['comments'] as List?)?.length ?? 0}');

      return data;
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ COMPLAINT DETAILS API ERROR');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🆔 Complaint ID: $complaintId');
      print('📍 Endpoint: /api/v1/public/$complaintId/details');
      print('🔍 Error Details:');
      print('   - Error Message: $e');
      print('   - Error Type: ${e.runtimeType}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Failed to fetch complaint details: $e');
    }
  }

  /// Fetch contractor details for a Gram Panchayat
  Future<ContractorDetails> getContractorByGpId(int gpId) async {
    try {
      final endpoint = '${ApiConstants.contractorEndpoint}/$gpId/contractor';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 CONTRACTOR API REQUEST: GET DETAILS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: ${ApiConstants.baseUrl}$endpoint');
      print('🏘️ GP ID: $gpId');
      print('🔑 Headers: ${ApiConstants.publicHeaders}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 CONTRACTOR API RESPONSE: GET DETAILS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('📊 Response Headers: ${response.headers}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final data = _handleResponse(response);
      final contractor = ContractorDetails.fromJson(data);

      print('✅ SUCCESS: Contractor details retrieved');
      print('📋 Contractor Information:');
      print('   - Contractor ID: ${contractor.id}');
      print('   - Person Name: ${contractor.personName}');
      print('   - Person Phone: ${contractor.personPhone}');
      print('   - Village ID: ${contractor.villageId}');
      print('   - Village Name: ${contractor.villageName}');
      print('   - Block Name: ${contractor.blockName}');
      print('   - District Name: ${contractor.districtName}');
      print('   - Contract Start Date: ${contractor.contractStartDate}');
      print('   - Contract End Date: ${contractor.contractEndDate ?? 'N/A'}');
      print('📋 Agency Information:');
      print('   - Agency ID: ${contractor.agency.id}');
      print('   - Agency Name: ${contractor.agency.name}');
      print('   - Agency Phone: ${contractor.agency.phone}');
      print('   - Agency Email: ${contractor.agency.email}');
      print('   - Agency Address: ${contractor.agency.address}');
      print('📋 Calculated Values:');
      print(
        '   - Formatted Start Date: ${contractor.formattedContractStartDate}',
      );
      print('   - Contract Duration: ${contractor.contractDuration}');
      print('   - Work Frequency: ${contractor.workFrequency}');

      return contractor;
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ CONTRACTOR API ERROR: GET DETAILS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🏘️ GP ID: $gpId');
      print('📍 Endpoint: ${ApiConstants.contractorEndpoint}/$gpId/contractor');
      print('🔍 Error Details:');
      print('   - Error Message: $e');
      print('   - Error Type: ${e.runtimeType}');
      print('   - Stack Trace: ${StackTrace.current}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Failed to fetch contractor: $e');
    }
  }

  /// Update contractor details
  Future<ContractorDetails> updateContractor({
    required int contractorId,
    required int agencyId,
    required String personName,
    required String personPhone,
    required int gpId,
    required String contractStartDate,
    required String contractEndDate,
  }) async {
    try {
      final endpoint = '/api/v1/contractors/contractors/$contractorId';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 CONTRACTOR API REQUEST: UPDATE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: ${ApiConstants.baseUrl}$endpoint');
      print('🏘️ Contractor ID: $contractorId');
      print('📋 Update Data:');
      print('   - Agency ID: $agencyId');
      print('   - Person Name: $personName');
      print('   - Person Phone: $personPhone');
      print('   - GP ID: $gpId');
      print('   - Contract Start Date: $contractStartDate');
      print('   - Contract End Date: $contractEndDate');
      print('🔑 Headers: ${await AuthService().getAuthHeaders()}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final body = {
        'agency_id': agencyId,
        'person_name': personName,
        'person_phone': personPhone,
        'gp_id': gpId,
        'contract_start_date': contractStartDate,
        'contract_end_date': contractEndDate,
      };

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'PUT',
        headers: await AuthService().getAuthHeaders(),
        body: body,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 CONTRACTOR API RESPONSE: UPDATE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _handleResponse(response);
        final contractor = ContractorDetails.fromJson(data);

        print('✅ SUCCESS: Contractor updated');
        print('📋 Updated Contractor ID: ${contractor.id}');
        print('📋 Updated Person Name: ${contractor.personName}');

        return contractor;
      } else {
        final error = _handleResponse(response);
        throw Exception(error['message'] ?? 'Failed to update contractor');
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ CONTRACTOR API ERROR: UPDATE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🏘️ Contractor ID: $contractorId');
      print('🔍 Error Details:');
      print('   - Error Message: $e');
      print('   - Error Type: ${e.runtimeType}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Failed to update contractor: $e');
    }
  }

  // Annual Survey APIs

  /// Submit village master data form
  Future<Map<String, dynamic>> submitVillageMasterData({
    required Map<String, dynamic> formData,
  }) async {
    try {
      final endpoint = ApiConstants.annualSurveyFillEndpoint;

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 VILLAGE MASTER DATA API REQUEST: SUBMIT FORM');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: ${ApiConstants.baseUrl}$endpoint');
      print('📋 Form Data: $formData');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Get authentication token
      final token = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print(
        '🔑 Using authenticated headers with token: ${token.substring(0, 20)}...',
      );

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'POST',
        headers: headers,
        body: formData,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 VILLAGE MASTER DATA API RESPONSE: SUBMIT FORM');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('📊 Response Headers: ${response.headers}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final data = _handleResponse(response);

      print('✅ SUCCESS: Village master data submitted');
      print('📋 Response Data: $data');

      return {'success': true, 'data': data};
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ VILLAGE MASTER DATA API ERROR: SUBMIT FORM');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 Endpoint: ${ApiConstants.annualSurveyFillEndpoint}');
      print('🔍 Error Details:');
      print('   - Error Message: $e');
      print('   - Error Type: ${e.runtimeType}');
      print('   - Stack Trace: ${StackTrace.current}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {
        'success': false,
        'message': 'Failed to submit village master data: $e',
      };
    }
  }

  // Attendance APIs

  /// Fetch attendance view data for VDO (contractor attendance)
  Future<Map<String, dynamic>> getAttendanceView({
    required int villageId,
    int skip = 0,
    int limit = 500,
  }) async {
    try {
      final endpoint =
          '${ApiConstants.attendanceViewEndpoint}?village_id=$villageId&skip=$skip&limit=$limit';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 ATTENDANCE VIEW API REQUEST: GET DATA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: ${ApiConstants.baseUrl}$endpoint');
      print('🏘️ Village ID: $villageId');
      print('📊 Skip: $skip, Limit: $limit');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Get authentication token
      final token = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print(
        '🔑 Using authenticated headers with token: ${token.substring(0, 20)}...',
      );

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: headers,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 ATTENDANCE VIEW API RESPONSE: GET DATA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('📊 Response Headers: ${response.headers}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final data = _handleResponse(response);

      print('✅ SUCCESS: Attendance view data retrieved');
      print('📋 Response Summary:');
      print('   - Total attendances: ${data['total'] ?? 0}');
      print(
        '   - Attendances in response: ${(data['attendances'] as List).length}',
      );
      print('   - Page: ${data['page'] ?? 1}');
      print('   - Limit: ${data['limit'] ?? limit}');
      print('   - Total pages: ${data['total_pages'] ?? 1}');

      // Log individual attendance details
      final attendances = data['attendances'] as List;
      for (int i = 0; i < attendances.length; i++) {
        final attendance = attendances[i];
        print('   📋 Attendance ${i + 1}:');
        print('      - ID: ${attendance['id']}');
        print('      - Contractor: ${attendance['contractor_name']}');
        print('      - Date: ${attendance['date']}');
        print('      - Start Time: ${attendance['start_time']}');
        print('      - End Time: ${attendance['end_time']}');
        print('      - Agency: ${attendance['agency']['name']}');
      }

      return {'success': true, 'data': data};
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ATTENDANCE VIEW API ERROR: GET DATA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🏘️ Village ID: $villageId');
      print('📍 Endpoint: ${ApiConstants.attendanceViewEndpoint}');
      print('🔍 Error Details:');
      print('   - Error Message: $e');
      print('   - Error Type: ${e.runtimeType}');
      print('   - Stack Trace: ${StackTrace.current}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {
        'success': false,
        'message': 'Failed to fetch attendance data: $e',
      };
    }
  }

  /// Fetch attendance view data for BDO (with date range filters)
  Future<Map<String, dynamic>> getAttendanceViewForBDO({
    int? villageId,
    int? blockId,
    int? districtId,
    String? startDate,
    String? endDate,
    int skip = 0,
    int limit = 500,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (villageId != null) queryParams['village_id'] = villageId.toString();
      if (blockId != null) queryParams['block_id'] = blockId.toString();
      if (districtId != null) {
        queryParams['district_id'] = districtId.toString();
      }
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      queryParams['skip'] = skip.toString();
      queryParams['limit'] = limit.toString();

      final endpoint =
          '${ApiConstants.attendanceViewEndpoint}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 ATTENDANCE VIEW API REQUEST: BDO GET DATA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: ${ApiConstants.baseUrl}$endpoint');
      print('🏛️ District ID: $districtId');
      print('📦 Block ID: $blockId');
      print('🏘️ Village ID: $villageId');
      print('📅 Start Date: $startDate');
      print('📅 End Date: $endDate');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final token = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: headers,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 ATTENDANCE VIEW API RESPONSE: BDO GET DATA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final data = _handleResponse(response);

      print('✅ SUCCESS: Attendance view data retrieved');
      print('📋 Response Summary:');
      print('   - Total attendances: ${data['total'] ?? 0}');
      print(
        '   - Attendances in response: ${(data['attendances'] as List).length}',
      );

      return {'success': true, 'data': data};
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ATTENDANCE VIEW API ERROR: BDO GET DATA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 Error: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {
        'success': false,
        'message': 'Failed to fetch attendance data: $e',
      };
    }
  }

  // Inspection APIs

  /// Fetch inspections
  Future<InspectionResponse> getInspections({
    int? villageId,
    int? districtId,
    int? blockId,
    int? gpId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      queryParams['page'] = page.toString();
      queryParams['page_size'] = pageSize.toString();

      if (villageId != null) queryParams['village_id'] = villageId.toString();
      if (districtId != null) {
        queryParams['district_id'] = districtId.toString();
      }
      if (blockId != null) queryParams['block_id'] = blockId.toString();
      if (gpId != null) queryParams['gp_id'] = gpId.toString();

      final endpoint =
          '${ApiConstants.inspectionsEndpoint}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      print('🔵 API Request: GET ${ApiConstants.baseUrl}$endpoint');
      print('📋 Request Parameters:');
      if (villageId != null) print('   - Village ID: $villageId');
      if (districtId != null) print('   - District ID: $districtId');
      if (blockId != null) print('   - Block ID: $blockId');
      if (gpId != null) print('   - GP ID: $gpId');
      print('   - Page: $page');
      print('   - Page Size: $pageSize');
      print('   - Endpoint: $endpoint');

      // Get authentication token
      final token = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print(
        '🔑 Using authenticated headers with token: ${token.substring(0, 20)}...',
      );

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: headers,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('📊 Response Headers: ${response.headers}');

      final data = _handleResponse(response);
      final inspectionResponse = InspectionResponse.fromJson(data);

      print('✅ Inspections fetched successfully:');
      print('   - Total items: ${inspectionResponse.items.length}');
      print('   - Total count: ${inspectionResponse.total}');
      print('   - Current page: ${inspectionResponse.page}');
      print('   - Page size: ${inspectionResponse.pageSize}');
      print('   - Total pages: ${inspectionResponse.totalPages}');

      // Log individual inspection details
      for (int i = 0; i < inspectionResponse.items.length; i++) {
        final inspection = inspectionResponse.items[i];
        print('   📋 Inspection ${i + 1}:');
        print('      - ID: ${inspection.id}');
        print('      - Village: ${inspection.villageName}');
        print('      - Date: ${inspection.date}');
        print('      - Officer: ${inspection.officerName}');
        print('      - Role: ${inspection.officerRole}');
        print('      - Visibly Clean: ${inspection.visiblyClean}');
        print('      - Overall Score: ${inspection.overallScore}');
        print('      - Remarks: ${inspection.remarks}');
      }

      return inspectionResponse;
    } catch (e) {
      print('❌ Error fetching inspections:');
      if (villageId != null) print('   - Village ID: $villageId');
      if (districtId != null) print('   - District ID: $districtId');
      if (blockId != null) print('   - Block ID: $blockId');
      if (gpId != null) print('   - GP ID: $gpId');
      print('   - Page: $page');
      print('   - Page Size: $pageSize');
      print('   - Error: $e');
      print('   - Error Type: ${e.runtimeType}');
      throw Exception('Failed to fetch inspections: $e');
    }
  }

  /// Submit a new inspection
  Future<Map<String, dynamic>> submitInspection(
    Map<String, dynamic> data,
  ) async {
    try {
      final endpoint = ApiConstants.inspectionsEndpoint;

      print('🔵 API Request: POST ${ApiConstants.baseUrl}$endpoint');
      print('📋 Request Data: ${json.encode(data)}');

      final token = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print(
        '🔑 Using authenticated headers with token: ${token.substring(0, 20)}...',
      );

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'POST',
        headers: headers,
        body: data,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final responseData = _handleResponse(response);

      print('✅ Inspection submitted successfully');
      return {'success': true, 'data': responseData};
    } catch (e) {
      print('❌ Error submitting inspection: $e');
      throw Exception('Failed to submit inspection: $e');
    }
  }

  // Get authentication token
  Future<String> _getAuthToken() async {
    final authService = AuthService();
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found. Please login again.');
    }
    return token;
  }

  // Reverse geocoding to get location string from coordinates
  Future<String> _getLocationFromCoordinates(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> locationParts = [];

        if (place.locality?.isNotEmpty == true) {
          locationParts.add(place.locality!);
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          locationParts.add(place.administrativeArea!);
        }
        if (place.country?.isNotEmpty == true) {
          locationParts.add(place.country!);
        }

        return locationParts.isNotEmpty
            ? locationParts.join(', ')
            : 'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      print('❌ Error getting location from coordinates: $e');
      return 'Unknown Location';
    }
  }

  /// Upload media for a complaint
  Future<Map<String, dynamic>> uploadComplaintMedia({
    required int complaintId,
    required File imageFile,
  }) async {
    try {
      final token = await _getAuthToken();
      final endpoint = '/api/v1/complaints/$complaintId/media';
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      print('🔵 Upload Media API Request: POST $url');
      print('📎 File: ${imageFile.path}');

      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🟢 Upload Media API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Media uploaded successfully');
        return data;
      } else {
        print('❌ ERROR: Status ${response.statusCode} - ${response.body}');
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error uploading media: $e');
      throw Exception('Failed to upload media: $e');
    }
  }

  /// Resolve a complaint
  Future<Map<String, dynamic>> resolveComplaint({
    required int complaintId,
    required String resolutionComment,
  }) async {
    try {
      final token = await _getAuthToken();
      final endpoint = '/api/v1/complaints/$complaintId/resolve';
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      print('🔵 Resolve API Request: PATCH $url');
      print('💬 Comment: $resolutionComment');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({'resolution_comment': resolutionComment});

      final response = await http.patch(url, headers: headers, body: body);

      print('🟢 Resolve API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Complaint resolved successfully');
        return data;
      } else {
        print('❌ ERROR: Status ${response.statusCode} - ${response.body}');
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error resolving complaint: $e');
      throw Exception('Failed to resolve complaint: $e');
    }
  }

  /// Get active FY (Financial Year) for annual surveys
  Future<int> getActiveFyId() async {
    try {
      final endpoint = ApiConstants.annualSurveyActiveFyEndpoint;
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      print('🔵 API Request: GET $url');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _makeRequest(
        endpoint: endpoint,
        method: 'GET',
        headers: ApiConstants.publicHeaders,
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final data = _handleResponse(response);
      
      if (data is List && data.isNotEmpty) {
        final fyId = data[0]['id'] as int;
        print('✅ Active FY ID retrieved: $fyId');
        return fyId;
      } else {
        throw Exception('No active FY found');
      }
    } catch (e) {
      print('❌ Error getting active FY: $e');
      throw Exception('Failed to get active FY: $e');
    }
  }

  /// Submit annual survey form
  Future<Map<String, dynamic>> submitAnnualSurvey({
    required int fyId,
    required int gpId,
    required int vdoId,
    required Map<String, dynamic> surveyData,
  }) async {
    try {
      final token = await _getAuthToken();
      final endpoint = ApiConstants.annualSurveyFillEndpoint;
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      print('🔵 API Request: POST $url');
      print('📋 Survey Data: ${json.encode(surveyData)}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(surveyData),
      );

      print('🟢 API Response: Status ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Annual survey submitted successfully');
        return data;
      } else if (response.statusCode == 500) {
        // Form already filled - 500 error indicates survey already submitted
        print('⚠️  Survey already filled for this GP');
        throw SurveyAlreadyFilledException(
          'This survey has already been submitted for this Gram Panchayat for the current financial year. You can only submit the survey once per year.'
        );
      } else if (response.statusCode == 422) {
        // Validation error
        print('❌ Validation Error: Status ${response.statusCode}');
        final errorData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'detail': []};
        
        // Extract validation errors
        List<String> errors = [];
        if (errorData['detail'] is List) {
          for (var error in errorData['detail']) {
            if (error['msg'] != null) {
              final field = error['loc'] != null && (error['loc'] as List).isNotEmpty
                  ? (error['loc'] as List).last
                  : 'field';
              errors.add('$field: ${error['msg']}');
            }
          }
        }
        
        final errorMessage = errors.isNotEmpty
            ? errors.join('\n')
            : 'Validation failed. Please check your input.';
        throw Exception(errorMessage);
      } else {
        print('❌ ERROR: Status ${response.statusCode} - ${response.body}');
        final errorData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'message': 'Failed to submit survey'};
        throw Exception(errorData['message'] ?? 'Failed to submit survey');
      }
    } catch (e) {
      print('❌ Error submitting annual survey: $e');
      throw e;
    }
  }
}
