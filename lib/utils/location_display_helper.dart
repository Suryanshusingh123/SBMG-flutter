import 'package:geocoding/geocoding.dart';

typedef LocationUpdateCallback = void Function();

class LocationResolver {
  LocationResolver._();

  static final Map<String, String> _cache = {};
  static final Set<String> _pending = {};
  static final Set<String> _failed = {};

  static String? getCached(String key) => _cache[key];

  static bool isPending(String key) => _pending.contains(key);

  static bool isFailed(String key) => _failed.contains(key);

  static bool hasValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return false;
    }
    if (latitude.isNaN || longitude.isNaN) {
      return false;
    }
    if (latitude == 0.0 && longitude == 0.0) {
      return false;
    }
    if (latitude > 90 || latitude < -90) {
      return false;
    }
    if (longitude > 180 || longitude < -180) {
      return false;
    }
    return true;
  }

  static Future<void> resolve({
    required String key,
    required double latitude,
    required double longitude,
    required void Function(String address) onResolved,
    void Function()? onFailed,
  }) async {
    if (_cache.containsKey(key)) {
      onResolved(_cache[key]!);
      return;
    }

    if (_pending.contains(key)) {
      return;
    }

    if (!hasValidCoordinates(latitude, longitude)) {
      onFailed?.call();
      return;
    }

    _pending.add(key);

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        _failed.add(key);
        onFailed?.call();
        return;
      }

      final address = _formatPlacemark(placemarks.first) ??
          '$latitude, $longitude';

      _cache[key] = address;
      _failed.remove(key);
      onResolved(address);
    } catch (_) {
      _failed.add(key);
      onFailed?.call();
    } finally {
      _pending.remove(key);
    }
  }

  static (double?, double?) extractCoordinates(Map<String, dynamic> data) {
    double? parseCoordinate(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null;
        return double.tryParse(trimmed);
      }
      return null;
    }

    double? latitude;
    double? longitude;

    const latKeys = [
      'lat',
      'latitude',
      'lat_value',
      'latLongLat',
      'location_latitude',
      'lat_value_decimal',
    ];

    const longKeys = [
      'long',
      'lng',
      'longitude',
      'latLongLong',
      'location_longitude',
      'long_value_decimal',
    ];

    for (final key in latKeys) {
      latitude = parseCoordinate(data[key]);
      if (latitude != null) break;
    }

    for (final key in longKeys) {
      longitude = parseCoordinate(data[key]);
      if (longitude != null) break;
    }

    if (latitude == null || longitude == null) {
      final latLongString = data['lat_long'] ?? data['coordinates'];
      if (latLongString is String) {
        final parts = latLongString.split(',');
        if (parts.length == 2) {
          latitude = parseCoordinate(parts[0]);
          longitude = parseCoordinate(parts[1]);
        }
      }
    }

    if (!hasValidCoordinates(latitude, longitude)) {
      return (null, null);
    }

    return (latitude, longitude);
  }

  static String? _formatPlacemark(Placemark place) {
    final parts = <String>[];

    void addIfNotEmpty(String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      if (!parts.contains(trimmed)) {
        parts.add(trimmed);
      }
    }

    addIfNotEmpty(place.street);
    addIfNotEmpty(place.subLocality);
    addIfNotEmpty(place.locality);
    addIfNotEmpty(place.subAdministrativeArea);
    addIfNotEmpty(place.administrativeArea);
    addIfNotEmpty(place.postalCode);
    addIfNotEmpty(place.country);

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(', ');
  }
}

class LocationDisplayHelper {
  LocationDisplayHelper._();

  static String buildDisplay({
    required String cacheKey,
    double? latitude,
    double? longitude,
    String? locationField,
    String? district,
    String? block,
    String? village,
    required LocationUpdateCallback scheduleUpdate,
    String fetchingLabel = 'Fetching address...',
    String unavailableLabel = 'Location not available',
  }) {
    if (LocationResolver.hasValidCoordinates(latitude, longitude)) {
      final cached = LocationResolver.getCached(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      if (!LocationResolver.isPending(cacheKey) &&
          !LocationResolver.isFailed(cacheKey)) {
        LocationResolver.resolve(
          key: cacheKey,
          latitude: latitude!,
          longitude: longitude!,
          onResolved: (_) => scheduleUpdate(),
          onFailed: scheduleUpdate,
        );
      }

      if (!LocationResolver.isFailed(cacheKey)) {
        return fetchingLabel;
      }
    }

    final trimmedLocation = locationField?.trim();
    if (trimmedLocation != null && trimmedLocation.isNotEmpty) {
      return trimmedLocation;
    }

    final administrativeParts = <String>[];

    void addPart(String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      administrativeParts.add(trimmed);
    }

    addPart(district);
    addPart(block);
    addPart(village);

    if (administrativeParts.isNotEmpty) {
      return administrativeParts.join(' | ');
    }

    return unavailableLabel;
  }
}

