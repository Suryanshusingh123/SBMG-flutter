class Scheme {
  final int id;
  final String name;
  final String? description;
  final String? eligibility;
  final String? benefits;
  final DateTime startTime;
  final DateTime endTime;
  final bool active;
  final List<SchemeMedia> media;
  final bool isBookmarked;

  const Scheme({
    required this.id,
    required this.name,
    this.description,
    this.eligibility,
    this.benefits,
    required this.startTime,
    required this.endTime,
    required this.active,
    this.media = const [],
    this.isBookmarked = false,
  });

  // Factory constructor to create Scheme from JSON
  factory Scheme.fromJson(Map<String, dynamic> json) {
    print('📋 Parsing Scheme: ${json['id']} - ${json['name']}');
    return Scheme(
      id: json['id'] as int,
      name: (json['name'] ?? 'Untitled Scheme') as String,
      description: json['description'] as String?,
      eligibility: json['eligibility'] as String?,
      benefits: json['benefits'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      active: json['active'] as bool,
      media:
          (json['media'] as List<dynamic>?)
              ?.map((mediaJson) => SchemeMedia.fromJson(mediaJson))
              .toList() ??
          [],
    );
  }

  // Convert Scheme to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'eligibility': eligibility,
      'benefits': benefits,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'active': active,
      'media': media.map((m) => m.toJson()).toList(),
    };
  }

  Scheme copyWith({
    int? id,
    String? name,
    String? description,
    String? eligibility,
    String? benefits,
    DateTime? startTime,
    DateTime? endTime,
    bool? active,
    List<SchemeMedia>? media,
    bool? isBookmarked,
  }) {
    return Scheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      eligibility: eligibility ?? this.eligibility,
      benefits: benefits ?? this.benefits,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      active: active ?? this.active,
      media: media ?? this.media,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class SchemeMedia {
  final int id;
  final int schemeId;
  final String mediaUrl;

  const SchemeMedia({
    required this.id,
    required this.schemeId,
    required this.mediaUrl,
  });

  factory SchemeMedia.fromJson(Map<String, dynamic> json) {
    return SchemeMedia(
      id: json['id'] as int,
      schemeId: json['scheme_id'] as int,
      mediaUrl: json['media_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'scheme_id': schemeId, 'media_url': mediaUrl};
  }
}
