import '../services/auth_services.dart';

/// Utility class for managing user location data
class LocationUtils {
  static final AuthService _authService = AuthService();

  /// Get user's village ID
  static Future<int?> getVillageId() async {
    return await _authService.getVillageId();
  }

  /// Get user's block ID
  static Future<int?> getBlockId() async {
    return await _authService.getBlockId();
  }

  /// Get user's district ID
  static Future<int?> getDistrictId() async {
    return await _authService.getDistrictId();
  }

  /// Get all location IDs as a map
  static Future<Map<String, int?>> getAllLocationIds() async {
    return await _authService.getLocationIds();
  }

  /// Check if user has complete location data
  static Future<bool> hasCompleteLocationData() async {
    final villageId = await getVillageId();
    final blockId = await getBlockId();
    final districtId = await getDistrictId();

    return villageId != null && blockId != null && districtId != null;
  }

  /// Get location data as a formatted string for display
  static Future<String> getLocationDisplayString() async {
    final locationIds = await getAllLocationIds();
    final villageId = locationIds['village_id'];
    final blockId = locationIds['block_id'];
    final districtId = locationIds['district_id'];

    if (villageId == null || blockId == null || districtId == null) {
      return 'Location data not available';
    }

    return 'Village: $villageId, Block: $blockId, District: $districtId';
  }

  /// Get location data for API requests
  static Future<Map<String, int>> getLocationDataForApi() async {
    final locationIds = await getAllLocationIds();

    return {
      if (locationIds['village_id'] != null)
        'village_id': locationIds['village_id']!,
      if (locationIds['block_id'] != null) 'block_id': locationIds['block_id']!,
      if (locationIds['district_id'] != null)
        'district_id': locationIds['district_id']!,
    };
  }
}
