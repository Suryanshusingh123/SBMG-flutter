class HandoutModel {
  final String id;
  final String tag;
  final String title;
  final String language;
  final String shortDescription;
  final String documentKey;
  final String type;
  final List<String> speciality;

  HandoutModel({
    required this.id,
    required this.tag,
    required this.title,
    required this.language,
    required this.shortDescription,
    required this.documentKey,
    required this.type,
    required this.speciality,
  });

  factory HandoutModel.fromJson(Map<String, dynamic> json) {
    return HandoutModel(
      id: json['id'] ?? '',
      tag: json['tag'] ?? '',
      title: json['title'] ?? '',
      language: json['language'] ?? '',
      shortDescription: json['short_description'] ?? '',
      documentKey: json['document_key'] ?? '',
      type: json['type'] ?? '',
      speciality: List<String>.from(json['speciality'] ?? []),
    );
  }
} 