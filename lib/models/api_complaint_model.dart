import '../utils/location_display_helper.dart';

class ApiComplaintModel {
  final int id;
  final String description;
  final String mobileNumber;
  final int complaintTypeId;
  final String createdAt;
  final int statusId;
  final String complaintType;
  final String status;
  final String villageName;
  final String blockName;
  final String districtName;
  final String? updatedAt;
  final List<String> mediaUrls;
  final List<ComplaintMedia> media;
  final List<ComplaintComment> comments;
  final String? assignedWorker;
  final String? assignmentDate;
  final double? latitude;
  final double? longitude;
  final String? location;

  ApiComplaintModel({
    required this.id,
    required this.description,
    required this.mobileNumber,
    required this.complaintTypeId,
    required this.createdAt,
    required this.statusId,
    required this.complaintType,
    required this.status,
    required this.villageName,
    required this.blockName,
    required this.districtName,
    this.updatedAt,
    required this.mediaUrls,
    required this.media,
    required this.comments,
    this.assignedWorker,
    this.assignmentDate,
    this.latitude,
    this.longitude,
    this.location,
  });

  factory ApiComplaintModel.fromJson(Map<String, dynamic> json) {
    print('🔍 PARSING COMPLAINT ${json['id']}:');
    print('   - Raw media_urls: ${json['media_urls']}');
    print('   - Raw media_urls type: ${json['media_urls'].runtimeType}');

    final mediaUrls = json['media_urls'] != null
        ? (json['media_urls'] as List).map((e) => e.toString()).toList()
        : <String>[];

    print('   - Parsed mediaUrls: $mediaUrls');
    print('   - Parsed mediaUrls length: ${mediaUrls.length}');

    return ApiComplaintModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      complaintTypeId: json['complaint_type_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      statusId: json['status_id'] ?? 0,
      complaintType: json['complaint_type'] ?? '',
      status: json['status'] ?? '',
      villageName: json['village_name'] ?? '',
      blockName: json['block_name'] ?? '',
      districtName: json['district_name'] ?? '',
      updatedAt: json['updated_at'],
      mediaUrls: mediaUrls,
      media: json['media'] != null
          ? (json['media'] as List)
                .map((m) => ComplaintMedia.fromJson(m))
                .toList()
          : [],
      comments: json['comments'] != null
          ? (json['comments'] as List)
                .map((c) => ComplaintComment.fromJson(c))
                .toList()
          : [],
      assignedWorker: json['assigned_worker'],
      assignmentDate: json['assignment_date'],
      latitude: json['lat'] != null
          ? double.tryParse(json['lat'].toString())
          : null,
      longitude: json['long'] != null
          ? double.tryParse(json['long'].toString())
          : null,
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'mobile_number': mobileNumber,
      'complaint_type_id': complaintTypeId,
      'created_at': createdAt,
      'status_id': statusId,
      'complaint_type': complaintType,
      'status': status,
      'village_name': villageName,
      'block_name': blockName,
      'district_name': districtName,
      'updated_at': updatedAt,
      'media_urls': mediaUrls,
      'media': media.map((m) => m.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'assigned_worker': assignedWorker,
      'assignment_date': assignmentDate,
      'lat': latitude,
      'long': longitude,
    };
  }

  // Helper methods
  String get fullLocation => '$villageName, $blockName, $districtName';

  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Today';
    }
  }

  String get firstMediaUrl {
    if (mediaUrls.isNotEmpty) {
      final url = mediaUrls.first;
      // Return the raw path (will be processed by ApiConstants.getMediaUrl())
      return url;
    }
    return '';
  }

  bool get hasMedia => mediaUrls.isNotEmpty;

  bool get isOpen => status.toUpperCase() == 'OPEN';
  bool get isResolved => status.toUpperCase() == 'RESOLVED';
  bool get isVerified => status.toUpperCase() == 'VERIFIED';
  bool get isClosed => status.toUpperCase() == 'CLOSED';

  // Enhanced status checks based on comments
  bool get hasResolutionComment => comments.any(
    (comment) => comment.comment.toUpperCase().contains('[RESOLVED]'),
  );
  bool get hasVerificationComment => comments.any(
    (comment) => comment.comment.toUpperCase().contains('[VERIFIED]'),
  );

  // Smart status determination
  bool get isActuallyResolved =>
      isResolved || (hasResolutionComment && !hasVerificationComment);
  bool get isActuallyVerified => isVerified || hasVerificationComment;

  Map<String, dynamic> toMap() {
    print('🔍 TO MAP DEBUG:');
    print('   - location: $location (${location.runtimeType})');
    print('   - latitude: $latitude (${latitude.runtimeType})');
    print('   - longitude: $longitude (${longitude.runtimeType})');
    print('   - mediaUrls: $mediaUrls (${mediaUrls.runtimeType})');
    print('   - mediaUrls length: ${mediaUrls.length}');

    final map = {
      'id': id.toString(),
      'title': description, // Using description as title
      'description': description,
      'status': status.toLowerCase(),
      'created_at': createdAt, // Fixed: was 'date'
      'date': createdAt, // Keep both for compatibility
      'villageName': villageName,
      'hasMedia': hasMedia,
      'firstMediaUrl': firstMediaUrl,
      'priority': complaintType, // Using complaintType as priority
      'mobileNumber': mobileNumber,
      'complaintType': complaintType,
      'complaint_type':
          complaintType, // Added snake_case version for API compatibility
      'blockName': blockName,
      'districtName': districtName,
      'location': location, // Added location field
      'lat': latitude, // Added lat field
      'long': longitude, // Added long field
      'media_urls': mediaUrls, // Added media_urls field
      'comments': comments.map((c) => c.toJson()).toList(),
    };

    print(
      '   - map location: ${map['location']} (${map['location'].runtimeType})',
    );
    print('   - map lat: ${map['lat']} (${map['lat'].runtimeType})');
    print('   - map long: ${map['long']} (${map['long'].runtimeType})');

    return map;
  }
}

extension ApiComplaintModelLocationExtension on ApiComplaintModel {
  bool get hasValidCoordinates =>
      LocationResolver.hasValidCoordinates(latitude, longitude);

  String? get trimmedLocation {
    final value = location?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String get administrativeLocationSummary {
    final parts = <String>[];

    void addPart(String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      parts.add(trimmed);
    }

    addPart(districtName);
    addPart(blockName);
    addPart(villageName);

    return parts.join(' | ');
  }
}

class ComplaintMedia {
  final int id;
  final String mediaUrl;
  final String uploadedAt;

  ComplaintMedia({
    required this.id,
    required this.mediaUrl,
    required this.uploadedAt,
  });

  factory ComplaintMedia.fromJson(Map<String, dynamic> json) {
    return ComplaintMedia(
      id: json['id'] ?? 0,
      mediaUrl: json['media_url'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'media_url': mediaUrl, 'uploaded_at': uploadedAt};
  }
}

class ComplaintComment {
  final int id;
  final int complaintId;
  final String comment;
  final String commentedAt;
  final String userName;

  ComplaintComment({
    required this.id,
    required this.complaintId,
    required this.comment,
    required this.commentedAt,
    required this.userName,
  });

  factory ComplaintComment.fromJson(Map<String, dynamic> json) {
    return ComplaintComment(
      id: json['id'] ?? 0,
      complaintId: json['complaint_id'] ?? 0,
      comment: json['comment'] ?? '',
      commentedAt: json['commented_at'] ?? '',
      userName: json['user_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'comment': comment,
      'commented_at': commentedAt,
      'user_name': userName,
    };
  }
}
