class Event {
  final int id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final bool active;
  final List<EventMedia> media;
  final bool isBookmarked;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.active,
    this.media = const [],
    this.isBookmarked = false,
  });

  // Factory constructor to create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    final eventTitle =
        (json['title'] ?? json['name'] ?? 'Untitled Event') as String;
    print('📋 Parsing Event: ${json['id']} - $eventTitle');
    return Event(
      id: json['id'] as int,
      title: eventTitle,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      active: json['active'] as bool,
      media:
          (json['media'] as List<dynamic>?)
              ?.map((mediaJson) => EventMedia.fromJson(mediaJson))
              .toList() ??
          [],
    );
  }

  // Convert Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'active': active,
      'media': media.map((m) => m.toJson()).toList(),
    };
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? active,
    List<EventMedia>? media,
    bool? isBookmarked,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      active: active ?? this.active,
      media: media ?? this.media,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class EventMedia {
  final int id;
  final int eventId;
  final String mediaUrl;

  const EventMedia({
    required this.id,
    required this.eventId,
    required this.mediaUrl,
  });

  factory EventMedia.fromJson(Map<String, dynamic> json) {
    return EventMedia(
      id: json['id'] as int,
      eventId: json['event_id'] as int,
      mediaUrl: json['media_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'event_id': eventId, 'media_url': mediaUrl};
  }
}
