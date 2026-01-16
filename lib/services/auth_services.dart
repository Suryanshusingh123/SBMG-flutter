import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/connstants.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storageService = StorageService();
  static const String _tokenKey = 'citizen_auth_token';
  static const String _roleKey = 'user_role';
  static const String _usernameKey = 'user_username';
  static const String _villageIdKey = 'user_village_id';
  static const String _blockIdKey = 'user_block_id';
  static const String _districtIdKey = 'user_district_id';
  static const String _smdSelectedDistrictKey = 'smd_selected_district_id';
  static const String _smdSelectedBlockKey = 'smd_selected_block_id';
  static const String _smdSelectedGpKey = 'smd_selected_gp_id';

  /// Send OTP to mobile number
  Future<String> sendOtp(String mobileNumber) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.sendOtpEndpoint}?mobile_number=$mobileNumber',
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 AUTH API REQUEST: SEND OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('📱 Mobile Number: $mobileNumber');
      print('🔑 Headers: ${ApiConstants.publicHeaders}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        url,
        headers: ApiConstants.publicHeaders,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 AUTH API RESPONSE: SEND OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['detail'] ?? 'OTP sent successfully';
        print('✅ SUCCESS: $message');
        return message;
      } else {
        final error = json.decode(response.body);
        final errorMsg = error['detail'] ?? 'Failed to send OTP';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ AUTH API ERROR: SEND OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Verify OTP and get authentication token
  Future<String> verifyOtp(String mobileNumber, String otp) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.verifyOtpEndpoint}?mobile_number=$mobileNumber&otp=$otp',
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 AUTH API REQUEST: VERIFY OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('📱 Mobile Number: $mobileNumber');
      print('🔐 OTP: $otp');
      print('🔑 Headers: ${ApiConstants.publicHeaders}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        url,
        headers: ApiConstants.publicHeaders,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 AUTH API RESPONSE: VERIFY OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] as String;

        print(
          '🎫 Token Received: ${token.substring(0, 10)}...${token.substring(token.length - 10)}',
        );

        // Save token to local storage
        await _storageService.saveString(_tokenKey, token);
        print('💾 Token saved to local storage');
        print('✅ SUCCESS: OTP verified and user authenticated');

        return token;
      } else {
        final error = json.decode(response.body);
        final errorMsg = error['detail'] ?? 'Invalid OTP';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ AUTH API ERROR: VERIFY OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      print('🔍 Auth Check: User is NOT LOGGED IN (No token)');
      return false;
    }

    // Check if token is expired
    final isExpired = await _isTokenExpired(token);
    if (isExpired) {
      print('🔍 Auth Check: Token is EXPIRED - clearing stored token and data');
      // Clear expired token and associated data
      await _storageService.remove(_tokenKey);
      await _storageService.remove(_roleKey);
      await _storageService.remove(_usernameKey);
      await _storageService.remove(_villageIdKey);
      await _storageService.remove(_blockIdKey);
      await _storageService.remove(_districtIdKey);
      print('🗑️ Expired token and user data cleared');
      return false;
    }

    print('🔍 Auth Check: User is LOGGED IN (Valid token)');
    return true;
  }

  // Check if token is expired
  // Validates JWT tokens by checking expiration time
  Future<bool> _isTokenExpired(String token) async {
    if (token.isEmpty) {
      print('❌ Token is empty');
      return true;
    }

    // Try to decode as JWT only if it has the JWT format (3 parts separated by dots)
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        // This is a JWT token, decode and check expiration
        final payload = parts[1];
        final normalized = base64.normalize(payload);
        final decoded = utf8.decode(base64.decode(normalized));
        final Map<String, dynamic> payloadData = json.decode(decoded);

        if (payloadData.containsKey('exp')) {
          final expValue = payloadData['exp'];
          // Handle both integer (Unix timestamp) and string formats
          int expirationTimestamp;

          if (expValue is int) {
            expirationTimestamp = expValue;
          } else if (expValue is String) {
            expirationTimestamp = int.tryParse(expValue) ?? 0;
          } else {
            print('⚠️ Invalid exp format, treating as expired for safety');
            return true;
          }

          // Convert to DateTime
          final expirationTime = DateTime.fromMillisecondsSinceEpoch(
            expirationTimestamp * 1000,
          );
          final now = DateTime.now();

          // Add a 60 second buffer to avoid edge cases
          final isValid = now.isBefore(
            expirationTime.subtract(Duration(seconds: 60)),
          );

          print('🔍 JWT Token expires at: $expirationTime');
          print('🔍 Current time: $now');
          print('🔍 Token is ${isValid ? "VALID" : "EXPIRED"}');
          print(
            '🔍 Token expires in: ${expirationTime.difference(now).inSeconds} seconds',
          );

          return !isValid;
        } else {
          print(
            '🔍 JWT token has no exp field, treating as expired for safety',
          );
          return true;
        }
      }
    } catch (e) {
      // Not a JWT token or decode failed
      print('⚠️ Token decode failed or not a JWT: $e');
      // Treat non-JWT tokens as valid (legacy support)
      // But log a warning
      print('⚠️ Treating non-JWT token as valid (legacy format)');
      return false;
    }

    // Not a JWT token (less than 3 parts), treat as valid for backward compatibility
    print('🔍 Token is not a JWT (UUID/legacy format), considering valid');
    return false;
  }

  /// Get stored authentication token
  Future<String?> getToken() async {
    final token = await _storageService.getString(_tokenKey);
    if (token != null) {
      print(
        '🎫 Token Retrieved: ${token.substring(0, 10)}...${token.substring(token.length - 10)}',
      );
    } else {
      print('🔴 No token found in storage');
    }
    return token;
  }

  /// Logout user (clear token and location data)
  Future<void> logout() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🚪 AUTH: USER LOGOUT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    await _storageService.remove(_tokenKey);
    await _storageService.remove(_roleKey);
    await _storageService.remove(_usernameKey);
    await _storageService.remove(_villageIdKey);
    await _storageService.remove(_blockIdKey);
    await _storageService.remove(_districtIdKey);
    print('🗑️ Token and location data removed from storage');
    print('✅ User logged out successfully');
    print('⏰ Timestamp: ${DateTime.now()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Get authorization header with token
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      ...ApiConstants.publicHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get stored village ID
  Future<int?> getVillageId() async {
    try {
      final villageId = await _storageService.getString(_villageIdKey);
      return villageId != null ? int.tryParse(villageId) : null;
    } catch (e) {
      print('❌ Error getting village ID: $e');
      return null;
    }
  }

  /// Get stored block ID
  Future<int?> getBlockId() async {
    try {
      final blockId = await _storageService.getString(_blockIdKey);
      return blockId != null ? int.tryParse(blockId) : null;
    } catch (e) {
      print('❌ Error getting block ID: $e');
      return null;
    }
  }

  /// Get stored district ID
  Future<int?> getDistrictId() async {
    try {
      final districtId = await _storageService.getString(_districtIdKey);
      return districtId != null ? int.tryParse(districtId) : null;
    } catch (e) {
      print('❌ Error getting district ID: $e');
      return null;
    }
  }

  /// Get stored user role
  Future<String?> getRole() async {
    try {
      final role = await _storageService.getString(_roleKey);
      return role;
    } catch (e) {
      print('❌ Error getting role: $e');
      return null;
    }
  }

  /// Get stored username
  Future<String?> getUsername() async {
    try {
      final username = await _storageService.getString(_usernameKey);
      return username;
    } catch (e) {
      print('❌ Error getting username: $e');
      return null;
    }
  }

  /// Get SMD selected district ID (for SMD users who select their district)
  Future<int?> getSmdSelectedDistrictId() async {
    try {
      final districtId = await _storageService.getString(
        _smdSelectedDistrictKey,
      );
      return districtId != null ? int.tryParse(districtId) : null;
    } catch (e) {
      print('❌ Error getting SMD selected district ID: $e');
      return null;
    }
  }

  Future<void> setSmdSelectedDistrictId(int districtId) async {
    try {
      await _storageService.saveString(
        _smdSelectedDistrictKey,
        districtId.toString(),
      );
      print('💾 Saved SMD selected district: $districtId');
    } catch (e) {
      print('❌ Error saving SMD selected district ID: $e');
    }
  }

  Future<void> clearSmdSelectedDistrictId() async {
    try {
      await _storageService.remove(_smdSelectedDistrictKey);
    } catch (e) {
      print('❌ Error clearing SMD selected district ID: $e');
    }
  }

  /// Check if SMD has selected a district
  Future<bool> hasSmdSelectedDistrict() async {
    try {
      return await _storageService.containsKey(_smdSelectedDistrictKey);
    } catch (e) {
      print('❌ Error checking SMD selected district: $e');
      return false;
    }
  }

  /// Get SMD selected block ID
  Future<int?> getSmdSelectedBlockId() async {
    try {
      final blockId = await _storageService.getString(_smdSelectedBlockKey);
      return blockId != null ? int.tryParse(blockId) : null;
    } catch (e) {
      print('❌ Error getting SMD selected block ID: $e');
      return null;
    }
  }

  /// Set SMD selected block ID
  Future<void> setSmdSelectedBlockId(int blockId) async {
    try {
      await _storageService.saveString(_smdSelectedBlockKey, blockId.toString());
      print('💾 Saved SMD selected block: $blockId');
    } catch (e) {
      print('❌ Error saving SMD selected block ID: $e');
    }
  }

  /// Clear SMD selected block ID
  Future<void> clearSmdSelectedBlockId() async {
    try {
      await _storageService.remove(_smdSelectedBlockKey);
    } catch (e) {
      print('❌ Error clearing SMD selected block ID: $e');
    }
  }

  /// Get SMD selected GP ID
  Future<int?> getSmdSelectedGpId() async {
    try {
      final gpId = await _storageService.getString(_smdSelectedGpKey);
      return gpId != null ? int.tryParse(gpId) : null;
    } catch (e) {
      print('❌ Error getting SMD selected GP ID: $e');
      return null;
    }
  }

  /// Set SMD selected GP ID
  Future<void> setSmdSelectedGpId(int gpId) async {
    try {
      await _storageService.saveString(_smdSelectedGpKey, gpId.toString());
      print('💾 Saved SMD selected GP: $gpId');
    } catch (e) {
      print('❌ Error saving SMD selected GP ID: $e');
    }
  }

  /// Clear SMD selected GP ID
  Future<void> clearSmdSelectedGpId() async {
    try {
      await _storageService.remove(_smdSelectedGpKey);
    } catch (e) {
      print('❌ Error clearing SMD selected GP ID: $e');
    }
  }

  /// Get all location IDs as a map
  Future<Map<String, int?>> getLocationIds() async {
    final villageId = await getVillageId();
    final blockId = await getBlockId();
    final districtId = await getDistrictId();

    return {
      'village_id': villageId,
      'block_id': blockId,
      'district_id': districtId,
    };
  }

  /// Get inspection location for a specific role
  Future<Map<String, dynamic>?> getInspectionLocation(String role) async {
    try {
      final storageKey = 'inspection_location_$role';
      final locationJson = await _storageService.getString(storageKey);
      if (locationJson != null) {
        return json.decode(locationJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error getting inspection location: $e');
      return null;
    }
  }

  /// Save inspection location for a specific role
  Future<void> saveInspectionLocation(String role, Map<String, dynamic> location) async {
    try {
      final storageKey = 'inspection_location_$role';
      await _storageService.saveString(storageKey, json.encode(location));
      print('💾 Saved inspection location for $role');
    } catch (e) {
      print('❌ Error saving inspection location: $e');
    }
  }

  /// Clear inspection location for a specific role
  Future<void> clearInspectionLocation(String role) async {
    try {
      final storageKey = 'inspection_location_$role';
      await _storageService.remove(storageKey);
      print('🗑️ Cleared inspection location for $role');
    } catch (e) {
      print('❌ Error clearing inspection location: $e');
    }
  }

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.meEndpoint}',
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 AUTH API REQUEST: GET CURRENT USER');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('🔑 Headers: ${await getAuthHeaders()}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.get(url, headers: await getAuthHeaders());

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 AUTH API RESPONSE: GET CURRENT USER');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Store location IDs
        if (data['village_id'] != null) {
          await _storageService.saveString(
            _villageIdKey,
            data['village_id'].toString(),
          );
          print('💾 Village ID saved: ${data['village_id']}');
        } else {
          await _storageService.remove(_villageIdKey);
        }
        if (data['block_id'] != null) {
          await _storageService.saveString(
            _blockIdKey,
            data['block_id'].toString(),
          );
          print('💾 Block ID saved: ${data['block_id']}');
        } else {
          await _storageService.remove(_blockIdKey);
        }
        if (data['district_id'] != null) {
          await _storageService.saveString(
            _districtIdKey,
            data['district_id'].toString(),
          );
          print('💾 District ID saved: ${data['district_id']}');
        } else {
          await _storageService.remove(_districtIdKey);
          await clearSmdSelectedDistrictId();
        }

        // Store role if provided by API
        if (data['role'] != null) {
          await _storageService.saveString(_roleKey, data['role']);
          print('💾 Role saved from API: ${data['role']}');
        }

        // If role not in API response, get from stored value
        if (data['role'] == null) {
          final storedRole = await getRole();
          if (storedRole != null) {
            data['role'] = storedRole;
            print('🔍 Role retrieved from storage: $storedRole');
          }
        }

        print('✅ SUCCESS: User information retrieved');
        return {'success': true, 'user': data};
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['message'] ?? error['detail'] ?? 'Failed to get user info';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ AUTH API ERROR: GET CURRENT USER');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Admin login with username and password
  Future<Map<String, dynamic>> adminLogin({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 AUTH API REQUEST: ADMIN LOGIN');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('👤 Username: $username');
      print('🔑 Headers: ${ApiConstants.defaultHeaders}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: json.encode({'username': username, 'password': password}),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 AUTH API RESPONSE: ADMIN LOGIN');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        final tokenType = data['token_type'] as String;

        // Save token to local storage
        await _storageService.saveString(_tokenKey, accessToken);
        print('💾 Admin token saved to local storage');
        print('✅ SUCCESS: Admin login successful');

        // Extract role from username (assuming format: district.block.village.role)
        final usernameParts = username.split('.');
        final role = usernameParts.length > 3 ? usernameParts[3] : 'admin';

        // Store role and username for navigation
        await _storageService.saveString(_roleKey, role);
        await _storageService.saveString(_usernameKey, username);
        print('💾 Role and username saved: $role, $username');

        return {
          'success': true,
          'token': accessToken,
          'token_type': tokenType,
          'user': {'role': role, 'username': username},
        };
      } else {
        final error = json.decode(response.body);
        final errorMsg = error['message'] ?? error['detail'] ?? 'Login failed';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ AUTH API ERROR: ADMIN LOGIN');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Request password reset OTP
  Future<Map<String, dynamic>> requestPasswordReset({
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.resetPasswordRequestEndpoint}',
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 AUTH API REQUEST: RESET PASSWORD REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('📱 Phone Number: $phoneNumber');
      print('🔑 Headers: ${ApiConstants.defaultHeaders}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: json.encode({'phone_number': phoneNumber}),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 AUTH API RESPONSE: RESET PASSWORD REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Password reset OTP sent');
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully',
        };
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['message'] ?? error['detail'] ?? 'Failed to send OTP';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ AUTH API ERROR: RESET PASSWORD REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Verify password reset OTP
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.resetPasswordVerifyEndpoint}',
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 AUTH API REQUEST: VERIFY RESET PASSWORD OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('📱 Phone Number: $phoneNumber');
      print('🔐 OTP: $otp');
      print('🔑 Headers: ${ApiConstants.defaultHeaders}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: json.encode({'phone_number': phoneNumber, 'otp': otp}),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 AUTH API RESPONSE: VERIFY RESET PASSWORD OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: OTP verified for password reset');
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
        };
      } else {
        final error = json.decode(response.body);
        final errorMsg = error['message'] ?? error['detail'] ?? 'Invalid OTP';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ AUTH API ERROR: VERIFY RESET PASSWORD OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Set new password after OTP verification
  Future<Map<String, dynamic>> setNewPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.resetPasswordSetEndpoint}',
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 AUTH API REQUEST: SET NEW PASSWORD');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $url');
      print('📱 Phone Number: $phoneNumber');
      print('🔐 OTP: $otp');
      print('🔑 Headers: ${ApiConstants.defaultHeaders}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: json.encode({
          'phone_number': phoneNumber,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 AUTH API RESPONSE: SET NEW PASSWORD');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Password updated successfully');
        return {
          'success': true,
          'message': data['message'] ?? 'Password updated successfully',
        };
      } else {
        final error = json.decode(response.body);
        final errorMsg =
            error['message'] ?? error['detail'] ?? 'Failed to update password';
        print('❌ ERROR: Status ${response.statusCode} - $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ AUTH API ERROR: SET NEW PASSWORD');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Exception: $e');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
