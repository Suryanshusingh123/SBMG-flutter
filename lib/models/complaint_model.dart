class ComplaintModel {
  final String id;
  final String type;
  final String description;
  final List<String> imagePaths;
  final List<ComplaintLocation> imageLocations;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final String? assignedTo;
  final String? remarks;
  final List<ComplaintTimeline> timeline;
  final String? resolutionDate;
  final String? resolutionDetails;
  final String? districtName;
  final String? blockName;
  final String? villageName;
  final String? location;
  final DateTime? resolvedAt;
  final DateTime? verifiedAt;
  final DateTime? closedAt;

  ComplaintModel({
    required this.id,
    required this.type,
    required this.description,
    required this.imagePaths,
    required this.imageLocations,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    required this.userId,
    this.assignedTo,
    this.remarks,
    this.timeline = const [],
    this.resolutionDate,
    this.resolutionDetails,
    this.districtName,
    this.blockName,
    this.villageName,
    this.location,
    this.resolvedAt,
    this.verifiedAt,
    this.closedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'imagePaths': imagePaths,
      'imageLocations': imageLocations.map((loc) => loc.toJson()).toList(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'assignedTo': assignedTo,
      'remarks': remarks,
      'timeline': timeline.map((t) => t.toJson()).toList(),
      'resolutionDate': resolutionDate,
      'resolutionDetails': resolutionDetails,
      'districtName': districtName,
      'blockName': blockName,
      'villageName': villageName,
      'location': location,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
    };
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse date strings as UTC
    DateTime parseUTC(String dateString) {
      DateTime dateTime;
      if (dateString.endsWith('Z') || dateString.contains('+') || dateString.contains('-', dateString.indexOf('T'))) {
        // Has timezone info, parse as is
        dateTime = DateTime.parse(dateString);
      } else {
        // No timezone info, assume UTC and add 'Z'
        dateTime = DateTime.parse('${dateString}Z');
      }
      // Ensure it's in UTC
      return dateTime.isUtc ? dateTime : dateTime.toUtc();
    }

    return ComplaintModel(
      id: json['id'].toString(),
      type: json['complaint_type'] ?? json['type'] ?? 'Unknown',
      description: json['description'],
      imagePaths: json['media_urls'] != null
          ? List<String>.from(json['media_urls'])
          : [],
      imageLocations: _createImageLocationsFromJson(json),
      status: json['status_name'] ?? json['status'] ?? 'unknown',
      createdAt: parseUTC(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? parseUTC(json['updated_at'])
          : null,
      userId: json['mobile_number'] ?? json['userId'] ?? '',
      assignedTo: json['assignedTo'],
      remarks: json['remarks'],
      timeline: [],
      resolutionDate: json['resolutionDate'],
      resolutionDetails: json['resolutionDetails'],
      districtName: json['district_name'],
      blockName: json['block_name'],
      villageName: json['village_name'],
      location: json['location'],
      resolvedAt: json['resolved_at'] != null
          ? parseUTC(json['resolved_at'])
          : null,
      verifiedAt: json['verified_at'] != null
          ? parseUTC(json['verified_at'])
          : null,
      closedAt: json['closed_at'] != null
          ? parseUTC(json['closed_at'])
          : null,
    );
  }

  static List<ComplaintLocation> _createImageLocationsFromJson(
    Map<String, dynamic> json,
  ) {
    List<ComplaintLocation> locations = [];

    // Extract coordinates from the main complaint data
    final lat = json['lat'] != null
        ? double.tryParse(json['lat'].toString())
        : null;
    final long = json['long'] != null
        ? double.tryParse(json['long'].toString())
        : null;

    if (lat != null && long != null) {
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

      locations.add(
        ComplaintLocation(
          latitude: lat,
          longitude: long,
          address:
              null, // Don't use location here, use it directly from complaint.location
          timestamp: parseUTC(json['created_at']),
        ),
      );
    }

    return locations;
  }
}

class ComplaintLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  ComplaintLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ComplaintLocation.fromJson(Map<String, dynamic> json) {
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

    return ComplaintLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      timestamp: parseUTC(json['timestamp']),
    );
  }
}

class ComplaintTimeline {
  final String status;
  final String responsibleParty;
  final DateTime timestamp;
  final String? description;

  ComplaintTimeline({
    required this.status,
    required this.responsibleParty,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'responsibleParty': responsibleParty,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory ComplaintTimeline.fromJson(Map<String, dynamic> json) {
    return ComplaintTimeline(
      status: json['status'],
      responsibleParty: json['responsibleParty'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
    );
  }
}
