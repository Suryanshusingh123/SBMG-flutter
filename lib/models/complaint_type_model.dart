class ComplaintType {
  final int id;
  final String name;
  final String description;

  const ComplaintType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ComplaintType.fromJson(Map<String, dynamic> json) {
    print('📋 Parsing ComplaintType: ${json['id']} - ${json['name']}');
    return ComplaintType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
